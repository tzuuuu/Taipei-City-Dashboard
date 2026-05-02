// Package rentheatmap converts MOI calrentbuffer JSON into GeoJSON files (EPSG:4326).
package rentheatmap

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// moiRoot is the top-level MOI JSON. Buffer polygon + rent stats often sit next to DATA, not inside it.
type moiRoot struct {
	DATA          json.RawMessage `json:"DATA"`
	TEXT          string          `json:"TEXT"`
	RENTQ1        float64         `json:"RENT_Q1"`
	RENTMedianVal float64         `json:"RENT_MEDIAN"`
	RENTQ3        float64         `json:"RENT_Q3"`
	Geometry      json.RawMessage `json:"geometry"`
}

type moiData struct {
	TEXT          string          `json:"TEXT"`
	Features2     [][]float64     `json:"features2"`
	RENTQ1        float64         `json:"RENT_Q1"`
	RENTMedianVal float64         `json:"RENT_MEDIAN"`
	RENTQ3        float64         `json:"RENT_Q3"`
	Geometry      json.RawMessage `json:"geometry"`
}

// MOI nests a GeoJSON-like Feature under DATA.geometry.
type moiGeomFeature struct {
	Type     string `json:"type"`
	Geometry struct {
		Type        string        `json:"type"`
		Coordinates [][][]float64 `json:"coordinates"`
	} `json:"geometry"`
}

// MOICalRentBufferParsed holds fields extracted from one MOI calrentbuffer JSON response.
type MOICalRentBufferParsed struct {
	Features2 [][]float64
	Geom      json.RawMessage
	Q1        float64
	Median    float64
	Q3        float64
}

// ParseMOICalRentBufferJSON unmarshals MOI JSON and returns heatmap inputs + quartiles.
func ParseMOICalRentBufferJSON(moiRaw []byte) (*MOICalRentBufferParsed, error) {
	var root moiRoot
	if err := json.Unmarshal(moiRaw, &root); err != nil {
		return nil, fmt.Errorf("moi json: %w", err)
	}
	if len(root.DATA) == 0 {
		return nil, fmt.Errorf("moi json: missing DATA")
	}
	var data moiData
	if err := json.Unmarshal(root.DATA, &data); err != nil {
		return nil, fmt.Errorf("moi DATA: %w", err)
	}
	text := data.TEXT
	if text == "" {
		text = root.TEXT
	}
	if text != "" && text != "SUCCESS" {
		return nil, fmt.Errorf("moi TEXT=%s", text)
	}

	geom := data.Geometry
	if len(geom) == 0 || bytes.Equal(bytes.TrimSpace(geom), []byte("null")) {
		geom = root.Geometry
	}
	q1, median, q3 := data.RENTQ1, data.RENTMedianVal, data.RENTQ3
	if q1 == 0 {
		q1 = root.RENTQ1
	}
	if median == 0 {
		median = root.RENTMedianVal
	}
	if q3 == 0 {
		q3 = root.RENTQ3
	}

	return &MOICalRentBufferParsed{
		Features2: data.Features2,
		Geom:      geom,
		Q1:        q1,
		Median:    median,
		Q3:        q3,
	}, nil
}

// RentQuartilesFromMOIRaw returns RENT_Q1, RENT_MEDIAN, RENT_Q3 from a MOI response.
func RentQuartilesFromMOIRaw(moiRaw []byte) (q1, median, q3 float64, err error) {
	p, err := ParseMOICalRentBufferJSON(moiRaw)
	if err != nil {
		return 0, 0, 0, err
	}
	return p.Q1, p.Median, p.Q3, nil
}

// BuildGeoJSONFromMOIRaw parses MOI JSON into WGS84 FeatureCollections (rent_heatmap + rent_heatmap_bounds).
func BuildGeoJSONFromMOIRaw(moiRaw []byte) (heatmap map[string]interface{}, bounds map[string]interface{}, err error) {
	p, err := ParseMOICalRentBufferJSON(moiRaw)
	if err != nil {
		return nil, nil, err
	}
	heatmapFC, err := buildHeatmapFC(p.Features2)
	if err != nil {
		return nil, nil, err
	}
	boundsFC, err := buildBoundsFC(p.Geom, p.Q1, p.Median, p.Q3)
	if err != nil {
		return nil, nil, err
	}
	return heatmapFC, boundsFC, nil
}

// BuildGeoJSONFromParsed builds heatmap + bounds FeatureCollections from an already-parsed MOI payload.
func BuildGeoJSONFromParsed(p *MOICalRentBufferParsed) (heatmap map[string]interface{}, bounds map[string]interface{}, err error) {
	if p == nil {
		return nil, nil, fmt.Errorf("moi parsed: nil")
	}
	heatmapFC, err := buildHeatmapFC(p.Features2)
	if err != nil {
		return nil, nil, err
	}
	boundsFC, err := buildBoundsFC(p.Geom, p.Q1, p.Median, p.Q3)
	if err != nil {
		return nil, nil, err
	}
	return heatmapFC, boundsFC, nil
}

// WriteGeoJSONPairToDir writes rent_heatmap.geojson and rent_heatmap_bounds.geojson into dir.
func WriteGeoJSONPairToDir(dir string, heatmap, bounds map[string]interface{}) error {
	return WriteRentHeatmapBundleToDir(dir, heatmap, bounds, nil, nil, nil)
}

// WriteRentHeatmapBundleToDir writes heatmap, bounds, and per–戶型 heatmap point files (may be empty FCs).
func WriteRentHeatmapBundleToDir(dir string, heatmap, bounds, typeWhole, typeSuite, typeShared map[string]interface{}) error {
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return fmt.Errorf("mkdir %s: %w", dir, err)
	}
	if err := writeJSONAtomic(filepath.Join(dir, "rent_heatmap.geojson"), heatmap); err != nil {
		return err
	}
	if err := writeJSONAtomic(filepath.Join(dir, "rent_heatmap_bounds.geojson"), bounds); err != nil {
		return err
	}
	if typeWhole != nil {
		if err := writeJSONAtomic(filepath.Join(dir, "rent_heatmap_type_whole.geojson"), typeWhole); err != nil {
			return err
		}
	}
	if typeSuite != nil {
		if err := writeJSONAtomic(filepath.Join(dir, "rent_heatmap_type_suite.geojson"), typeSuite); err != nil {
			return err
		}
	}
	if typeShared != nil {
		if err := writeJSONAtomic(filepath.Join(dir, "rent_heatmap_type_shared.geojson"), typeShared); err != nil {
			return err
		}
	}
	return nil
}

// WriteGeoJSONFiles parses MOI response bytes, builds heatmap + bounds FeatureCollections in WGS84,
// and writes rent_heatmap.geojson and rent_heatmap_bounds.geojson into dir.
func WriteGeoJSONFiles(dir string, moiRaw []byte) error {
	h, b, err := BuildGeoJSONFromMOIRaw(moiRaw)
	if err != nil {
		return err
	}
	return WriteGeoJSONPairToDir(dir, h, b)
}

func buildHeatmapFC(rows [][]float64) (map[string]interface{}, error) {
	features := make([]map[string]interface{}, 0, len(rows))
	appendHeatmapPointRows(&features, rows, nil)
	return map[string]interface{}{
		"type":     "FeatureCollection",
		"features": features,
	}, nil
}

func emptyFeatureCollection() map[string]interface{} {
	return map[string]interface{}{
		"type":     "FeatureCollection",
		"features": []interface{}{},
	}
}

// BuildRentHeatmapTypeSplitFCs builds three point FeatureCollections for separate Mapbox heatmap layers
// (整戶(層) / 獨立套房 / 分租套(雅)房). Nil parsed → empty FC.
func BuildRentHeatmapTypeSplitFCs(pWhole, pSuite, pShared *MOICalRentBufferParsed) (whole, suite, shared map[string]interface{}) {
	mk := func(p *MOICalRentBufferParsed) map[string]interface{} {
		if p == nil {
			return emptyFeatureCollection()
		}
		fc, err := buildHeatmapFC(p.Features2)
		if err != nil {
			return emptyFeatureCollection()
		}
		return fc
	}
	return mk(pWhole), mk(pSuite), mk(pShared)
}

func appendHeatmapPointRows(features *[]map[string]interface{}, rows [][]float64, extra map[string]interface{}) {
	for _, row := range rows {
		if len(row) < 2 {
			continue
		}
		x, y := row[0], row[1]
		w := 1.0
		if len(row) >= 3 {
			w = row[2]
		}
		lon, lat := TM2ToWGS84(x, y)
		props := map[string]interface{}{"weight": w}
		if extra != nil {
			for k, v := range extra {
				props[k] = v
			}
		}
		*features = append(*features, map[string]interface{}{
			"type":       "Feature",
			"properties": props,
			"geometry": map[string]interface{}{
				"type":        "Point",
				"coordinates": []float64{lon, lat},
			},
		})
	}
}

func buildBoundsFC(geomRaw json.RawMessage, q1, median, q3 float64) (map[string]interface{}, error) {
	if len(geomRaw) == 0 || bytes.Equal(bytes.TrimSpace(geomRaw), []byte("null")) {
		return map[string]interface{}{
			"type":     "FeatureCollection",
			"features": []interface{}{},
		}, nil
	}
	// Some gateways return geometry as a JSON string containing a nested object.
	var asString string
	if err := json.Unmarshal(geomRaw, &asString); err == nil && asString != "" {
		geomRaw = json.RawMessage(asString)
	}
	var wrap moiGeomFeature
	if err := json.Unmarshal(geomRaw, &wrap); err != nil {
		return nil, fmt.Errorf("moi geometry: %w", err)
	}
	var outerRing [][]float64
	switch {
	case wrap.Geometry.Type == "Polygon" && len(wrap.Geometry.Coordinates) > 0:
		outerRing = ringTM2ToWGS84(wrap.Geometry.Coordinates[0])
	default:
		var loose struct {
			Geometry *struct {
				Type        string        `json:"type"`
				Coordinates [][][]float64 `json:"coordinates"`
			} `json:"geometry"`
		}
		if err := json.Unmarshal(geomRaw, &loose); err == nil && loose.Geometry != nil &&
			loose.Geometry.Type == "Polygon" && len(loose.Geometry.Coordinates) > 0 {
			outerRing = ringTM2ToWGS84(loose.Geometry.Coordinates[0])
		}
	}
	// MOI sample uses a GeoJSON Feature; live API may return a bare Polygon on DATA.geometry.
	if len(outerRing) < 4 {
		var bare struct {
			Type        string        `json:"type"`
			Coordinates [][][]float64 `json:"coordinates"`
		}
		if err := json.Unmarshal(geomRaw, &bare); err == nil && bare.Type == "Polygon" &&
			len(bare.Coordinates) > 0 {
			outerRing = ringTM2ToWGS84(bare.Coordinates[0])
		}
	}
	if len(outerRing) < 4 {
		return map[string]interface{}{
			"type":     "FeatureCollection",
			"features": []interface{}{},
		}, nil
	}
	wgsRing := outerRing
	feature := map[string]interface{}{
		"type": "Feature",
		"properties": map[string]interface{}{
			"name":        "rent_heatmap_bounds",
			"rent_q1":     q1,
			"rent_median": median,
			"rent_q3":     q3,
			"remark":      "租屋熱力圖範圍（EPSG:3826→WGS84，內政部 API）",
		},
		"geometry": map[string]interface{}{
			"type":        "Polygon",
			"coordinates": [][][]float64{wgsRing},
		},
	}
	return map[string]interface{}{
		"type":     "FeatureCollection",
		"features": []interface{}{feature},
	}, nil
}

func ringTM2ToWGS84(ring [][]float64) [][]float64 {
	out := make([][]float64, 0, len(ring))
	for _, pt := range ring {
		if len(pt) < 2 {
			continue
		}
		lon, lat := TM2ToWGS84(pt[0], pt[1])
		out = append(out, []float64{lon, lat})
	}
	return out
}

func writeJSONAtomic(path string, v interface{}) error {
	var buf bytes.Buffer
	enc := json.NewEncoder(&buf)
	enc.SetIndent("", "  ")
	if err := enc.Encode(v); err != nil {
		return fmt.Errorf("encode %s: %w", path, err)
	}
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, buf.Bytes(), 0o644); err != nil {
		return fmt.Errorf("write %s: %w", tmp, err)
	}
	_ = os.Remove(path)
	if err := os.Rename(tmp, path); err != nil {
		_ = os.Remove(tmp)
		return fmt.Errorf("rename to %s: %w", path, err)
	}
	return nil
}
