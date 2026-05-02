/**
 * MOI calrentbuffer.cfm returns JSON with DATA in TWD97 / EPSG:3826 (meters).
 * Build Mapbox-ready GeoJSON: heatmap (points + weight) and bounds (polygon in WGS84).
 * CRS conversion matches TaipeiCityDashboardBE/app/services/rentheatmap/tm3826.go (no proj4).
 */

const PI = Math.PI;

function deg2rad(d) {
	return (d * PI) / 180;
}

function rad2deg(r) {
	return (r * 180) / PI;
}

/** Krüger EPSG:3826 coefficients — same as Go tm3826.init() */
function computeTm3826Coeffs() {
	const tm3826A = 6378137.0;
	const tm3826InvF = 298.257222101;
	const f = 1.0 / tm3826InvF;
	const n = f / (2.0 - f);
	const n2 = n * n;
	const n3 = n2 * n;
	const n4 = n2 * n2;
	const A = (tm3826A / (1.0 + n)) * (1.0 + n2 / 4.0 + n4 / 64.0);
	return {
		n,
		A,
		a1: n / 2.0 - (2.0 * n2) / 3.0 + (5.0 * n3) / 16.0,
		a2: (13.0 * n2) / 48.0 - (3.0 * n3) / 5.0,
		a3: (61.0 * n3) / 240.0,
		b1: n / 2.0 - (2.0 * n2) / 3.0 + (37.0 * n3) / 96.0,
		b2: n2 / 48.0 + n3 / 15.0,
		b3: (17.0 * n3) / 480.0,
		d1: 2.0 * n - (2.0 * n2) / 3.0 - 2.0 * n3,
		d2: (7.0 * n2) / 3.0 - (8.0 * n3) / 5.0,
		d3: (56.0 * n3) / 15.0,
	};
}

const TM3826_LON0 = 121.0;
const TM3826_K0 = 0.9999;
const TM3826_FALSE_E = 250000.0;
const TM3826_FALSE_N = 0.0;

const tm3826 = computeTm3826Coeffs();

/**
 * WGS84 lon/lat (degrees) → EPSG:3826 easting/northing (meters).
 * @returns {[number, number]} [easting, northing]
 */
export function wgs84ToEPSG3826(lonDeg, latDeg) {
	const c = tm3826;
	const phi = deg2rad(latDeg);
	const lam = deg2rad(lonDeg);
	const lam0 = deg2rad(TM3826_LON0);
	const dlam = lam - lam0;

	const sn = Math.sin(phi);
	const t =
		Math.sinh(
			Math.atanh(sn) -
				((2 * Math.sqrt(c.n)) / (1 + c.n)) *
					Math.atanh(((2 * Math.sqrt(c.n)) / (1 + c.n)) * sn),
		);
	const xip = Math.atan2(t, Math.cos(dlam));
	const etap = Math.atanh(Math.sin(dlam) / Math.sqrt(1 + t * t));

	const s1 = Math.sin(2 * xip);
	const c1 = Math.cos(2 * xip);
	const s2 = Math.sin(4 * xip);
	const c2 = Math.cos(4 * xip);
	const s3 = Math.sin(6 * xip);
	const c3 = Math.cos(6 * xip);
	const sh1 = Math.sinh(2 * etap);
	const ch1 = Math.cosh(2 * etap);
	const sh2 = Math.sinh(4 * etap);
	const ch2 = Math.cosh(4 * etap);
	const sh3 = Math.sinh(6 * etap);
	const ch3 = Math.cosh(6 * etap);

	const etap2 =
		etap + c.a1 * c1 * sh1 + c.a2 * c2 * sh2 + c.a3 * c3 * sh3;
	const xip2 =
		xip + c.a1 * s1 * ch1 + c.a2 * s2 * ch2 + c.a3 * s3 * ch3;

	const e = TM3826_FALSE_E + TM3826_K0 * c.A * etap2;
	const n = TM3826_FALSE_N + TM3826_K0 * c.A * xip2;
	return [e, n];
}

/**
 * EPSG:3826 easting/northing (meters) → WGS84 lon/lat (degrees).
 * @returns {[number, number]} [lng, lat]
 */
export function epsg3826ToWgs84(e, n) {
	const c = tm3826;
	const xi = (n - TM3826_FALSE_N) / (TM3826_K0 * c.A);
	const eta = (e - TM3826_FALSE_E) / (TM3826_K0 * c.A);

	const s1 = Math.sin(2 * xi);
	const c1 = Math.cos(2 * xi);
	const s2 = Math.sin(4 * xi);
	const c2 = Math.cos(4 * xi);
	const s3 = Math.sin(6 * xi);
	const c3 = Math.cos(6 * xi);
	const sh1 = Math.sinh(2 * eta);
	const ch1 = Math.cosh(2 * eta);
	const sh2 = Math.sinh(4 * eta);
	const ch2 = Math.cosh(4 * eta);
	const sh3 = Math.sinh(6 * eta);
	const ch3 = Math.cosh(6 * eta);

	const xip =
		xi - c.b1 * s1 * ch1 - c.b2 * s2 * ch2 - c.b3 * s3 * ch3;
	const etap =
		eta - c.b1 * c1 * sh1 - c.b2 * c2 * sh2 - c.b3 * c3 * sh3;

	const sxi = Math.sin(xip);
	const cxi = Math.cos(xip);
	const ch = Math.cosh(etap);
	const chi = Math.asin(sxi / ch);

	const sC1 = Math.sin(2 * chi);
	const sC2 = Math.sin(4 * chi);
	const sC3 = Math.sin(6 * chi);
	const phi = chi + c.d1 * sC1 + c.d2 * sC2 + c.d3 * sC3;

	const lam0 = deg2rad(TM3826_LON0);
	const lam = lam0 + Math.atan2(Math.sinh(etap), cxi);

	return [rad2deg(lam), rad2deg(phi)];
}

function ring3826ToWgs84(ring) {
	return ring.map(([x, y]) => {
		const [lng, lat] = epsg3826ToWgs84(x, y);
		return [lng, lat];
	});
}

/**
 * @param {object} moiRoot - Parsed JSON from backend (entire MOI document, usually { DATA: {...} }).
 * @returns {{ heatmap: object, bounds: object }}
 */
export function buildRentHeatmapGeojsonsFromMoiResponse(moiRoot) {
	const inner =
		moiRoot &&
		typeof moiRoot === "object" &&
		"data" in moiRoot &&
		moiRoot.data != null
			? moiRoot.data
			: moiRoot;
	const data = inner?.DATA;
	if (!data || typeof data !== "object") {
		throw new Error("租屋熱區：回應缺少 DATA");
	}
	if (data.TEXT && String(data.TEXT).toUpperCase() !== "SUCCESS") {
		throw new Error(String(data.TEXT || "租屋熱區查詢失敗"));
	}

	const features2 = Array.isArray(data.features2) ? data.features2 : [];
	const heatmapFeatures = features2
		.filter((row) => Array.isArray(row) && row.length >= 2)
		.map((row) => {
			const x = Number(row[0]);
			const y = Number(row[1]);
			const w = row.length >= 3 ? Number(row[2]) : 1;
			const [lng, lat] = epsg3826ToWgs84(x, y);
			return {
				type: "Feature",
				properties: { weight: Number.isFinite(w) ? w : 1 },
				geometry: { type: "Point", coordinates: [lng, lat] },
			};
		});

	const heatmapGeojson = {
		type: "FeatureCollection",
		features: heatmapFeatures,
	};

	let poly3826 = null;
	const geomWrap = data.geometry;
	if (geomWrap && geomWrap.geometry && geomWrap.geometry.type === "Polygon") {
		poly3826 = geomWrap.geometry.coordinates;
	} else if (geomWrap && geomWrap.type === "Polygon") {
		poly3826 = geomWrap.coordinates;
	}

	if (!poly3826 || !Array.isArray(poly3826[0])) {
		return {
			heatmap: heatmapGeojson,
			bounds: { type: "FeatureCollection", features: [] },
		};
	}

	const wgsRings = poly3826.map((ring) => ring3826ToWgs84(ring));
	const boundsGeojson = {
		type: "FeatureCollection",
		features: [
			{
				type: "Feature",
				properties: {
					name: "rent_heatmap_bounds",
					rent_median: data.RENT_MEDIAN,
					rent_q1: data.RENT_Q1,
					rent_q3: data.RENT_Q3,
				},
				geometry: { type: "Polygon", coordinates: wgsRings },
			},
		],
	};

	return { heatmap: heatmapGeojson, bounds: boundsGeojson };
}
