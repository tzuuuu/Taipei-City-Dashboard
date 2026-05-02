// TWD97 / TM2 zone 121 (EPSG:3826) ↔ WGS84 geographic, Krüger-style series (no external deps).
// Parameters match PROJ: +proj=tmerc +lat_0=0 +lon_0=121 +k=0.9999 +x_0=250000 +y_0=0 +ellps=GRS80
package rentheatmap

import "math"

const (
	tm3826A       = 6378137.0       // GRS80 semi-major axis (m)
	tm3826InvF   = 298.257222101   // GRS80 inverse flattening (EPSG:3826 / Taiwan TM2)
	tm3826Lon0   = 121.0           // central meridian (deg)
	tm3826K0     = 0.9999
	tm3826FalseE = 250000.0
	tm3826FalseN = 0.0
)

type tm3826Coeffs struct {
	n, A   float64
	a1, a2, a3 float64
	b1, b2, b3 float64
	d1, d2, d3 float64
}

var tm3826 tm3826Coeffs

func init() {
	f := 1.0 / tm3826InvF
	n := f / (2.0 - f)
	n2 := n * n
	n3 := n2 * n
	n4 := n2 * n2
	A := (tm3826A / (1.0 + n)) * (1.0 + n2/4.0 + n4/64.0)

	tm3826 = tm3826Coeffs{
		n: n,
		A: A,
		a1: n/2.0 - 2.0*n2/3.0 + 5.0*n3/16.0,
		a2: 13.0*n2/48.0 - 3.0*n3/5.0,
		a3: 61.0 * n3 / 240.0,
		b1: n/2.0 - 2.0*n2/3.0 + 37.0*n3/96.0,
		b2: n2/48.0 + n3/15.0,
		b3: 17.0 * n3 / 480.0,
		d1: 2.0*n - 2.0*n2/3.0 - 2.0*n3,
		d2: 7.0*n2/3.0 - 8.0*n3/5.0,
		d3: 56.0 * n3 / 15.0,
	}
}

func deg2rad(d float64) float64 { return d * math.Pi / 180.0 }
func rad2deg(r float64) float64 { return r * 180.0 / math.Pi }

// WGS84ToTM2 converts WGS84 lon/lat (degrees) to EPSG:3826 easting/northing (meters).
func WGS84ToTM2(lonDeg, latDeg float64) (e, n float64) {
	c := tm3826
	phi := deg2rad(latDeg)
	lam := deg2rad(lonDeg)
	lam0 := deg2rad(tm3826Lon0)
	dlam := lam - lam0

	sn, _ := math.Sincos(phi)
	t := math.Sinh(math.Atanh(sn) - (2*math.Sqrt(c.n)/(1+c.n))*math.Atanh((2*math.Sqrt(c.n)/(1+c.n))*sn))
	xip := math.Atan2(t, math.Cos(dlam))
	etap := math.Atanh(math.Sin(dlam) / math.Sqrt(1+t*t))

	s1 := math.Sin(2 * xip)
	c1 := math.Cos(2 * xip)
	s2 := math.Sin(4 * xip)
	c2 := math.Cos(4 * xip)
	s3 := math.Sin(6 * xip)
	c3 := math.Cos(6 * xip)
	sh1 := math.Sinh(2 * etap)
	ch1 := math.Cosh(2 * etap)
	sh2 := math.Sinh(4 * etap)
	ch2 := math.Cosh(4 * etap)
	sh3 := math.Sinh(6 * etap)
	ch3 := math.Cosh(6 * etap)

	etap2 := etap + c.a1*c1*sh1 + c.a2*c2*sh2 + c.a3*c3*sh3
	xip2 := xip + c.a1*s1*ch1 + c.a2*s2*ch2 + c.a3*s3*ch3

	e = tm3826FalseE + tm3826K0*c.A*etap2
	n = tm3826FalseN + tm3826K0*c.A*xip2
	return e, n
}

// TM2ToWGS84 converts EPSG:3826 easting/northing (meters) to WGS84 lon/lat (degrees).
func TM2ToWGS84(e, n float64) (lonDeg, latDeg float64) {
	c := tm3826
	xi := (n - tm3826FalseN) / (tm3826K0 * c.A)
	eta := (e - tm3826FalseE) / (tm3826K0 * c.A)

	s1 := math.Sin(2 * xi)
	c1 := math.Cos(2 * xi)
	s2 := math.Sin(4 * xi)
	c2 := math.Cos(4 * xi)
	s3 := math.Sin(6 * xi)
	c3 := math.Cos(6 * xi)
	sh1 := math.Sinh(2 * eta)
	ch1 := math.Cosh(2 * eta)
	sh2 := math.Sinh(4 * eta)
	ch2 := math.Cosh(4 * eta)
	sh3 := math.Sinh(6 * eta)
	ch3 := math.Cosh(6 * eta)

	xip := xi - c.b1*s1*ch1 - c.b2*s2*ch2 - c.b3*s3*ch3
	etap := eta - c.b1*c1*sh1 - c.b2*c2*sh2 - c.b3*c3*sh3

	sxi, cxi := math.Sincos(xip)
	ch := math.Cosh(etap)
	chi := math.Asin(sxi / ch)

	sC1, _ := math.Sincos(2 * chi)
	sC2, _ := math.Sincos(4 * chi)
	sC3, _ := math.Sincos(6 * chi)
	phi := chi + c.d1*sC1 + c.d2*sC2 + c.d3*sC3

	lam0 := deg2rad(tm3826Lon0)
	lam := lam0 + math.Atan2(math.Sinh(etap), cxi)

	lonDeg = rad2deg(lam)
	latDeg = rad2deg(phi)
	return lonDeg, latDeg
}
