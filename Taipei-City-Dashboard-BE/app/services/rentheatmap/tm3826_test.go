package rentheatmap

import (
	"math"
	"testing"
)

// Reference from PROJ (+proj=tmerc ... ellps=GRS80): node -e "const p=require('proj4'); ..."
func TestTM2ToWGS84_sample(t *testing.T) {
	lon, lat := TM2ToWGS84(303490.82, 2763182.16)
	wantLon, wantLat := 121.52981753982446, 24.975624855187853
	if math.Abs(lon-wantLon) > 1e-4 || math.Abs(lat-wantLat) > 1e-4 {
		t.Fatalf("got lon=%.10f lat=%.10f want lon=%.10f lat=%.10f", lon, lat, wantLon, wantLat)
	}
}

func TestWGS84ToTM2_roundTrip(t *testing.T) {
	lon0, lat0 := 121.5654, 25.0330
	e, n := WGS84ToTM2(lon0, lat0)
	lon1, lat1 := TM2ToWGS84(e, n)
	if math.Abs(lon1-lon0) > 1e-6 || math.Abs(lat1-lat0) > 1e-6 {
		t.Fatalf("roundtrip got lon=%.10f lat=%.10f want lon=%.10f lat=%.10f", lon1, lat1, lon0, lat0)
	}
}
