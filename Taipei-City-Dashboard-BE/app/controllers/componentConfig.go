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
    // Bind the JSON to the violation variable
    if err := c.ShouldBindJSON(&violation); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "sdsd"+err.Error()})
        return
    }

    // Save the new record to the database
	err = models.AddTrafficViolation(violation.ReporterName,violation.ContactPhone,violation.Longitude,violation.Latitude,violation.Address,violation.ReportTime,violation.Vehicle,violation.Violation,violation.Comments)

    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "sdsd"+err.Error()})
        return
    }

	// // 讀本地資料
	geoJSON, err := readGeoJSON("/Taipei-City-Dashboard-FE/public/mapData/traffic_accident_location_view.geojson")
	if err != nil {
		fmt.Println("Error reading GeoJSON:", err)
        return
    }
	// 加資料
	addNewViolation(geoJSON, violation, 31.2304, 121.4737)
	// 寫回去
	err = writeGeoJSON("/Taipei-City-Dashboard-FE/public/mapData/traffic_accident_location_view.geojson", geoJSON)
    if err != nil {
		fmt.Println("Error writing GeoJSON:", err)
        return
    }

    // Return the newly created violation
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

func addNewViolation(geoJSON *models.GeoJSON, violation models.TrafficViolation, lat, lon float64) {
    newFeature := models.Feature{
        Type: "Feature",
        Properties: violation,
        Geometry: models.Geometry{
            Type: "Point",
            Coordinates: [][]float64{{lon, lat}},
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
