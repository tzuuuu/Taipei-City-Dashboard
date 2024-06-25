// Package controllers stores all the controllers for the Gin router.
package controllers

import (
	"TaipeiCityDashboardBE/app/models"
	"encoding/json"
	"fmt"
	"os"
	"io/ioutil"
	"net/http"
	"strconv"
	"github.com/gin-gonic/gin"
)

/*
GetAllComponents retrieves all public components from the database.
GET /api/v1/component

| Param         | Description                                         | Value                        | Default |
| ------------- | --------------------------------------------------- | ---------------------------- | ------- |
| pagesize      | Number of components per page.                      | `int`                        | -       |
| pagenum       | Page number. Only works if pagesize is defined.     | `int`                        | 1       |
| searchbyname  | Text string to search name by.                      | `string`                     | -       |
| searchbyindex | Text string to search index by.                     | `string`                     | -       |
| filterby      | Column to filter by. `filtervalue` must be defined. | `string`                     | -       |
| filtermode    | How the data should be filtered.                    | `eq`, `ne`, `gt`, `lt`, `in` | `eq`    |
| filtervalue   | The value to filter by.                             | `int`, `string`              | -       |
| sort          | The column to sort by.                              | `string`                     | -       |
| order         | Ascending or descending.                            | `asc`, `desc`                | `asc`   |
*/

type componentQuery struct {
	PageSize      int    `form:"pagesize"`
	PageNum       int    `form:"pagenum"`
	Sort          string `form:"sort"`
	Order         string `form:"order"`
	FilterBy      string `form:"filterby"`
	FilterMode    string `form:"filtermode"`
	FilterValue   string `form:"filtervalue"`
	SearchByIndex string `form:"searchbyindex"`
	SearchByName  string `form:"searchbyname"`
}

func GetAllComponents(c *gin.Context) {
	// Get all query parameters from context
	var query componentQuery
	c.ShouldBindQuery(&query)

	components, totalComponents, resultNum, err := models.GetAllComponents(query.PageSize, query.PageNum, query.Sort, query.Order, query.FilterBy, query.FilterMode, query.FilterValue, query.SearchByIndex, query.SearchByName)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// Return the components
	c.JSON(http.StatusOK, gin.H{"status": "success", "total": totalComponents, "results": resultNum, "data": components})
}

/*
GetComponentByID retrieves a public component from the database by ID.
GET /api/v1/component/:id
*/
func GetComponentByID(c *gin.Context) {
	// Get the component ID from the context
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid component ID"})
		return
	}

	// Find the component
	component, err := models.GetComponentByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "component not found"})
		return
	}

	// Return the component
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": component})
}

/*
UpdateComponent updates a component's config in the database.
PATCH /api/v1/component/:id
*/
func UpdateComponent(c *gin.Context) {
	var component models.Component

	// 1. Get the component ID from the context
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid component ID"})
		return
	}

	// 2. Check if the component exists
	_, err = models.GetComponentByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "component not found"})
		return
	}

	// 3. Bind the request body to the component and make sure it's valid
	err = c.ShouldBindJSON(&component)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 4. Update the component
	component, err = models.UpdateComponent(id, component.Name, component.HistoryConfig, component.MapFilter, component.TimeFrom, component.TimeTo, component.UpdateFreq, component.UpdateFreqUnit, component.Source, component.ShortDesc, component.LongDesc, component.UseCase, component.Links, component.Contributors)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 5. Return the component
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": component})
}

// jarrenpoh 發送交通違規項目
func AddTrafficViolation(c *gin.Context) {
	dir, err := os.Getwd()
	if err != nil {
		fmt.Println("Error getting current directory:", err)
		return
	}
	fmt.Println("Current directory:", dir)

	var violation models.TrafficViolation
	// 綁定 JSON 到 violation 變量
	if err := c.ShouldBindJSON(&violation); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "sdsd" + err.Error()})
		return
	}

	// 將新紀錄保存到數據庫
	err = models.AddTrafficViolation(violation.ReporterName, violation.ContactPhone, violation.Longitude, violation.Latitude, violation.Address, violation.ReportTime, violation.Vehicle, violation.Violation, violation.Comments, violation.VehicleNum)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "sdsd" + err.Error()})
		return
	}

	// 将经纬度从字符串转换为浮点数
	lat, err := strconv.ParseFloat(violation.Latitude, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid latitude value"})
		return
	}
 
	lon, err := strconv.ParseFloat(violation.Longitude, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid longitude value"})
		return
	}

	// 讀取本地資料
	geoJSONPath := "/opt/Taipei-City-Dashboard-FE/public/mapData/traffic_violations_report.geojson"
	if _, err := os.Stat(geoJSONPath); os.IsNotExist(err) {
		fmt.Println("GeoJSON file does not exist at:", geoJSONPath)
		files, err := ioutil.ReadDir("/opt/Taipei-City-Dashboard-FE/public/mapData")
		if err != nil {
			fmt.Println("Error reading directory:", err)
			return
		}
		for _, f := range files {
			fmt.Println("File in directory:", f.Name())
		}
		return
	}

	geoJSON, err := readGeoJSON(geoJSONPath)
	if err != nil {
		fmt.Println("Error reading GeoJSON:", err)
		fmt.Println("Attempted path:", geoJSONPath)
		fmt.Println("Current directory:", dir)
		files, _ := ioutil.ReadDir("/opt/Taipei-City-Dashboard-FE/public/mapData")
		for _, f := range files {
			fmt.Println("File:", f.Name())
		}
		return
	}

	// 添加新違規記錄
	addNewViolation(geoJSON, violation,lat,lon)

	// 寫回資料
	err = writeGeoJSON(geoJSONPath, geoJSON)
	if err != nil {
		fmt.Println("Error writing GeoJSON:", err)
		return
	}

	// 返回新建的違規記錄
	c.JSON(http.StatusCreated, gin.H{"status": "success", "data": violation})
}

func readGeoJSON(filePath string) (*models.GeoJSON, error) {
    data, err := ioutil.ReadFile(filePath)
    if err != nil {
        return nil, err
    }
    var geoJSON models.GeoJSON
    err = json.Unmarshal(data, &geoJSON)
    if err != nil {
        return nil, err
    }
    return &geoJSON, nil
}

func addNewViolation(geoJSON *models.GeoJSON, violation models.TrafficViolation,lat, lon float64) {
    newFeature := models.Feature{
        Type: "Feature",
        Properties: map[string]interface{}{
            "舉報人姓名":   violation.ReporterName,
            "通報人聯絡電話": violation.ContactPhone,
            "舉報地點經度":   violation.Longitude,
            "舉報地點緯度":   violation.Latitude,
            "舉報地點地址":   violation.Address,
            "舉報時間":     violation.ReportTime,
            "違規交通工具":   violation.Vehicle,
            "車牌":         violation.VehicleNum,
            "違規項目":     violation.Violation,
            "補充內容":     violation.Comments,
        },
        Geometry: models.Geometry{
            Type:        "Point",
			Coordinates: []float64{lon, lat},
        },
    }
    geoJSON.Features = append(geoJSON.Features, newFeature)
}

func writeGeoJSON(filePath string, geoJSON *models.GeoJSON) error {
    data, err := json.MarshalIndent(geoJSON, "", "  ")
    if err != nil {
        return err
    }
    return ioutil.WriteFile(filePath, data, 0644)
}

/*
UpdateComponentChartConfig updates a component's chart config in the database.
PATCH /api/v1/component/:id/chart
*/
func UpdateComponentChartConfig(c *gin.Context) {
	var chartConfig models.ComponentChart

	// 1. Get the component ID from the context
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid component ID"})
		return
	}

	// 2. Find the component and chart config
	component, err := models.GetComponentByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "component not found"})
		return
	}

	// 3. Bind the request body to the component and make sure it's valid
	err = c.ShouldBindJSON(&chartConfig)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 4. Update the chart config. Then update the update_time in components table.
	chartConfig, err = models.UpdateComponentChartConfig(component.Index, chartConfig.Color, chartConfig.Types, chartConfig.Unit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 5. Return the component
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": chartConfig})
}

/*
UpdateComponentMapConfig updates a component's map config in the database.
PATCH /api/v1/component/:id/map
*/
func UpdateComponentMapConfig(c *gin.Context) {
	var mapConfig models.ComponentMap

	// 1. Get the map config index from the context
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid map config ID"})
		return
	}

	// 2. Bind the request body to the component and make sure it's valid
	err = c.ShouldBindJSON(&mapConfig)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 3. Update the map config
	mapConfig, err = models.UpdateComponentMapConfig(id, mapConfig.Index, mapConfig.Title, mapConfig.Type, mapConfig.Source, mapConfig.Size, mapConfig.Icon, mapConfig.Paint, mapConfig.Property)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 4. Return the map config
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": mapConfig})
}

/*
DeleteComponent deletes a component from the database.
DELETE /api/v1/component/:id

Note: Associated chart config will also be deleted. Associated map config will only be deleted if no other components are using it.
*/
func DeleteComponent(c *gin.Context) {
	var component models.Component

	// 1. Get the component ID from the context
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid component ID"})
		return
	}

	// 2. Find the component
	component, err = models.GetComponentByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "component not found"})
		return
	}

	// 3. Delete the component
	deleteChartStatus, deleteMapStatus, err := models.DeleteComponent(id, component.Index, component.MapConfigIDs)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "chart_deleted": deleteChartStatus, "map_deleted": deleteMapStatus})
}
