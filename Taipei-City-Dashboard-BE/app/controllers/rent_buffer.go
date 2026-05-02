package controllers

import (
	"bytes"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"TaipeiCityDashboardBE/app/models"
	"TaipeiCityDashboardBE/app/services/rentheatmap"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// rentMapDataDir picks where MOI GeoJSON files are written.
// - RENT_MAPDATA_DIR: absolute path (required in K8s/Docker unless you mount sibling FE repo).
// - Default: ../Taipei-City-Dashboard-FE/public/mapData when that repo layout exists (local dev).
// - Otherwise: os.TempDir()/rent_mapdata (writable; FE will NOT see files unless you mount the same path as nginx /mapData).
func rentMapDataDir() string {
	if d := os.Getenv("RENT_MAPDATA_DIR"); d != "" {
		return filepath.Clean(d)
	}
	dev := filepath.Clean(filepath.Join("..", "Taipei-City-Dashboard-FE", "public", "mapData"))
	publicDir := filepath.Join(dev, "..") // .../public
	if fi, err := os.Stat(publicDir); err == nil && fi.IsDir() {
		return dev
	}
	return filepath.Join(os.TempDir(), "rent_mapdata")
}

// moiBrowserUserAgent avoids some upstream WAFs that reject Go's default User-Agent.
const moiBrowserUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

const rentHeatmapNoDataReason = "有效租約樣本 未達40筆 因此無此行政區資料"

// moiRentTypeForCalBuffer pairs MOI form field selectedrenttype with chart metadata.
type moiRentTypeForCalBuffer struct {
	FormValue string
	Name      string
	Icon      string
	SortKey   int
}

// moiCalBufferRentTypes: first entry (全部類別) drives heatmap + bounds when MOI succeeds; all four slots appear in QuartileChart (missing = is_no_data like rent_quartiles).
// FormValue must match MOI「房屋類型」options exactly.
var moiCalBufferRentTypes = []moiRentTypeForCalBuffer{
	{"全部類別", "全部類別", "pie_chart", 1},
	{"整戶(層)", "整戶(層)", "apartment", 2},
	{"獨立套房", "獨立套房", "bed", 3},
	{"分租套(雅)房", "分租套(雅)房", "group", 4},
}

func emptyRentHeatmapFC() map[string]interface{} {
	return map[string]interface{}{
		"type":     "FeatureCollection",
		"features": []interface{}{},
	}
}

func normalizeMOISelectedBuffer(s *string) string {
	if s == nil || *s == "" {
		return "1公里"
	}
	switch *s {
	case "1公里", "2.5公里", "5公里":
		return *s
	default:
		return "1公里"
	}
}

func encodeMoiCalRentBufferMultipart(cx, cy float64, selectedRentType, selectedBuffer string) (contentType string, body *bytes.Buffer, err error) {
	var buf bytes.Buffer
	w := multipart.NewWriter(&buf)
	write := func(name, val string) error { return w.WriteField(name, val) }
	cxStr := strconv.FormatFloat(cx, 'f', 2, 64)
	cyStr := strconv.FormatFloat(cy, 'f', 2, 64)
	if err := write("cx", cxStr); err != nil {
		return "", nil, err
	}
	if err := write("cy", cyStr); err != nil {
		return "", nil, err
	}
	if err := write("selectedbuffer", selectedBuffer); err != nil {
		return "", nil, err
	}
	if err := write("selectedrentshow", "中位數"); err != nil {
		return "", nil, err
	}
	if err := write("selectedrenttype", selectedRentType); err != nil {
		return "", nil, err
	}
	if err := write("selectedbuildage", "全部類別"); err != nil {
		return "", nil, err
	}
	if err := w.Close(); err != nil {
		return "", nil, err
	}
	return w.FormDataContentType(), &buf, nil
}

func postMOICalRentBuffer(client *http.Client, moiURL string, cx, cy float64, selectedRentType, selectedBuffer string) ([]byte, error) {
	formType, formBody, err := encodeMoiCalRentBufferMultipart(cx, cy, selectedRentType, selectedBuffer)
	if err != nil {
		return nil, err
	}
	req, err := http.NewRequest(http.MethodPost, moiURL, formBody)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", formType)
	req.Header.Set("User-Agent", moiBrowserUserAgent)
	req.Header.Set("Accept", "application/json, text/javascript, */*; q=0.01")
	req.Header.Set("Origin", "https://moisagis.moi.gov.tw")
	req.Header.Set("Referer", "https://moisagis.moi.gov.tw/rent/")
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	raw, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("MOI HTTP %d", resp.StatusCode)
	}
	return raw, nil
}

func replaceRentHeatmapMoiQuartilesTable(cx, cy float64, lng, lat *float64, rows []gin.H) error {
	if models.DBDashboard == nil {
		return fmt.Errorf("dashboard db not connected")
	}
	return models.DBDashboard.Transaction(func(tx *gorm.DB) error {
		if err := tx.Exec("DELETE FROM public.rent_heatmap_moi_quartiles").Error; err != nil {
			return err
		}
		var lngV, latV any
		if lng != nil {
			lngV = *lng
		}
		if lat != nil {
			latV = *lat
		}
		for _, row := range rows {
			if err := tx.Exec(`INSERT INTO public.rent_heatmap_moi_quartiles
(rent_type, name, icon, q1_rent, median_rent, q3_rent, is_no_data, no_data_reason, center_cx, center_cy, lng, lat, sort_key, updated_at)
VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?, NOW())`,
				row["rent_type"], row["name"], row["icon"],
				row["q1"], row["median"], row["q3"],
				row["is_no_data"], row["no_data_reason"],
				cx, cy, lngV, latV, row["sort_key"]).Error; err != nil {
				return err
			}
		}
		return nil
	})
}

// PostRentCalRentBuffer calls MOI calrentbuffer up to four times. Each type is stored (or marked is_no_data if MOI fails).
// Heatmap/bounds only from a successful「全部類別」response; merged circle points (three colors) from 整戶(層)／獨立套房／分租套(雅)房 when those parses succeed.
// JSON body: prefer "cx","cy" (EPSG:3826 meters, same as MOI form); otherwise "lng","lat" (WGS84) are converted server-side.
func PostRentCalRentBuffer(c *gin.Context) {
	var body struct {
		Lng            *float64 `json:"lng,omitempty"`
		Lat            *float64 `json:"lat,omitempty"`
		Cx             *float64 `json:"cx,omitempty"`
		Cy             *float64 `json:"cy,omitempty"`
		SelectedBuffer *string  `json:"selected_buffer,omitempty"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}

	var cx, cy float64
	switch {
	case body.Cx != nil && body.Cy != nil:
		cx, cy = *body.Cx, *body.Cy
	case body.Lng != nil && body.Lat != nil:
		cx, cy = rentheatmap.WGS84ToTM2(*body.Lng, *body.Lat)
	default:
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  "error",
			"message": "provide cx,cy (TM2 meters) or lng,lat (WGS84 degrees)",
		})
		return
	}

	t := strconv.FormatInt(time.Now().Unix(), 10)
	moiURL := fmt.Sprintf("https://moisagis.moi.gov.tw/rent/cfm/calrentbuffer.cfm?_t=%s", t)
	client := &http.Client{Timeout: 120 * time.Second}
	selectedBuffer := normalizeMOISelectedBuffer(body.SelectedBuffer)

	series := make([]gin.H, 0, len(moiCalBufferRentTypes))
	dbRows := make([]gin.H, 0, len(moiCalBufferRentTypes))
	var warnings []string
	heatmap := emptyRentHeatmapFC()
	bounds := emptyRentHeatmapFC()
	var parsedForCircle [3]*rentheatmap.MOICalRentBufferParsed

	for i, rt := range moiCalBufferRentTypes {
		raw, err := postMOICalRentBuffer(client, moiURL, cx, cy, rt.FormValue, selectedBuffer)
		if err != nil {
			warnings = append(warnings, fmt.Sprintf("%s: %v", rt.FormValue, err))
			series = append(series, noDataQuartileSeriesRow(rt))
			dbRows = append(dbRows, noDataDBRow(rt))
			continue
		}
		parsed, err := rentheatmap.ParseMOICalRentBufferJSON(raw)
		if err != nil {
			warnings = append(warnings, fmt.Sprintf("%s: %v", rt.FormValue, err))
			series = append(series, noDataQuartileSeriesRow(rt))
			dbRows = append(dbRows, noDataDBRow(rt))
			continue
		}
		series = append(series, gin.H{
			"name":       rt.Name,
			"icon":       rt.Icon,
			"q1":         parsed.Q1,
			"median":     parsed.Median,
			"q3":         parsed.Q3,
			"sort_key":   rt.SortKey,
			"is_no_data": false,
		})
		dbRows = append(dbRows, gin.H{
			"rent_type":      rt.FormValue,
			"name":           rt.Name,
			"icon":           rt.Icon,
			"q1":             parsed.Q1,
			"median":         parsed.Median,
			"q3":             parsed.Q3,
			"sort_key":       rt.SortKey,
			"is_no_data":     false,
			"no_data_reason": nil,
		})
		if i == 0 {
			hm, b, berr := rentheatmap.BuildGeoJSONFromParsed(parsed)
			if berr != nil {
				warnings = append(warnings, fmt.Sprintf("%s heatmap: %v", rt.FormValue, berr))
			} else {
				heatmap, bounds = hm, b
			}
		} else if i >= 1 && i <= 3 {
			parsedForCircle[i-1] = parsed
		}
	}

	tw, tsu, tsh := rentheatmap.BuildRentHeatmapTypeSplitFCs(
		parsedForCircle[0], parsedForCircle[1], parsedForCircle[2],
	)

	outDir := rentMapDataDir()
	out := gin.H{
		"status":                   "success",
		"dir":                      outDir,
		"selected_buffer":          selectedBuffer,
		"rent_heatmap":             heatmap,
		"rent_heatmap_bounds":      bounds,
		"rent_heatmap_type_whole":  tw,
		"rent_heatmap_type_suite":  tsu,
		"rent_heatmap_type_shared": tsh,
		"rent_quartile_series":     series,
	}
	if len(warnings) > 0 {
		out["rent_moi_warnings"] = warnings
	}
	if werr := rentheatmap.WriteRentHeatmapBundleToDir(outDir, heatmap, bounds, tw, tsu, tsh); werr != nil {
		out["disk_write_warning"] = werr.Error()
	}
	if err := replaceRentHeatmapMoiQuartilesTable(cx, cy, body.Lng, body.Lat, dbRows); err != nil {
		out["db_write_warning"] = err.Error()
	}
	c.JSON(http.StatusOK, out)
}

func noDataQuartileSeriesRow(rt moiRentTypeForCalBuffer) gin.H {
	return gin.H{
		"name":           rt.Name,
		"icon":           rt.Icon,
		"sort_key":       rt.SortKey,
		"is_no_data":     true,
		"no_data_reason": rentHeatmapNoDataReason,
		"q1":             nil,
		"median":         nil,
		"q3":             nil,
	}
}

func noDataDBRow(rt moiRentTypeForCalBuffer) gin.H {
	return gin.H{
		"rent_type":      rt.FormValue,
		"name":           rt.Name,
		"icon":           rt.Icon,
		"q1":             nil,
		"median":         nil,
		"q3":             nil,
		"sort_key":       rt.SortKey,
		"is_no_data":     true,
		"no_data_reason": rentHeatmapNoDataReason,
	}
}
