package rentheatmap

import (
	"encoding/json"
	"os"
	"path/filepath"
	"runtime"
	"testing"
)

func TestBuildGeoJSONFromMOIRaw_OrgTxtSample(t *testing.T) {
	_, thisFile, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("runtime.Caller")
	}
	repoRoot := filepath.Clean(filepath.Join(filepath.Dir(thisFile), "..", "..", "..", ".."))
	orgPath := filepath.Join(repoRoot, "Taipei-City-Dashboard-FE", "public", "mapData", "rent_heatmap_org.txt")
	raw, err := os.ReadFile(orgPath)
	if err != nil {
		t.Skipf("sample not found: %v", err)
	}
	hm, bounds, err := BuildGeoJSONFromMOIRaw(raw)
	if err != nil {
		t.Fatal(err)
	}
	hmf, ok := hm["features"].([]map[string]interface{})
	if !ok || len(hmf) == 0 {
		t.Fatal("expected heatmap features ([]map[string]interface{})")
	}
	bf, _ := bounds["features"].([]interface{})
	if len(bf) != 1 {
		t.Fatalf("expected 1 bounds feature, got %d", len(bf))
	}
}

func TestBuildGeoJSONFromMOIRaw_UppercaseGeometryKey(t *testing.T) {
	// Simulate ColdFusion-style key casing: Geometry instead of geometry
	inner := `{
		"TEXT": "SUCCESS",
		"features2": [[100000, 2000000, 1]],
		"RENT_Q1": 1,
		"RENT_MEDIAN": 2,
		"RENT_Q3": 3,
		"Geometry": {
			"type": "Feature",
			"geometry": {
				"type": "Polygon",
				"coordinates": [[[100000, 2000000],[101000, 2000000],[101000, 2001000],[100000, 2001000],[100000, 2000000]]]
			}
		}
	}`
	env := `{"DATA":` + inner + `}`
	_, bounds, err := BuildGeoJSONFromMOIRaw([]byte(env))
	if err != nil {
		t.Fatal(err)
	}
	bf, _ := bounds["features"].([]interface{})
	if len(bf) != 1 {
		t.Fatalf("expected 1 bounds feature with Geometry key, got %d: %s", len(bf), mustJSON(bounds))
	}
}

func TestBuildGeoJSONFromMOIRaw_DirectPolygonUnderGeometry(t *testing.T) {
	inner := `{
		"TEXT": "SUCCESS",
		"features2": [[100000, 2000000, 1]],
		"RENT_Q1": 1,
		"RENT_MEDIAN": 2,
		"RENT_Q3": 3,
		"geometry": {
			"type": "Polygon",
			"coordinates": [[[100000, 2000000],[101000, 2000000],[101000, 2001000],[100000, 2001000],[100000, 2000000]]]
		}
	}`
	env := `{"DATA":` + inner + `}`
	_, bounds, err := BuildGeoJSONFromMOIRaw([]byte(env))
	if err != nil {
		t.Fatal(err)
	}
	bf, _ := bounds["features"].([]interface{})
	if len(bf) != 1 {
		t.Fatalf("expected 1 bounds feature for bare Polygon, got %d", len(bf))
	}
}

func mustJSON(v interface{}) string {
	b, _ := json.Marshal(v)
	return string(b)
}

func TestBuildRentHeatmapTypeSplitFCs_Separates(t *testing.T) {
	p2 := &MOICalRentBufferParsed{Features2: [][]float64{{100000, 2000000, 1}}}
	p3 := &MOICalRentBufferParsed{Features2: [][]float64{{100100, 2000100, 1}}}
	w, su, sh := BuildRentHeatmapTypeSplitFCs(p2, p3, nil)
	wf, _ := w["features"].([]map[string]interface{})
	suf, _ := su["features"].([]map[string]interface{})
	if len(wf) != 1 || len(suf) != 1 {
		t.Fatalf("whole/suite feature counts: %d %d", len(wf), len(suf))
	}
	shf, _ := sh["features"].([]interface{})
	if len(shf) != 0 {
		t.Fatalf("shared should be empty, got %d", len(shf))
	}
}
