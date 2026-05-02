const LINE_COLOR_MAP = {
	blue: "#0072CE",
	red: "#E60012",
	orange: "#F58220",
	green: "#008659",
	yellow: "#F5C400",
	brown: "#8B5A2B",
	light_green: "#8BC34A",
	pink: "#D81B60",
	purple: "#7B3FB6",
	gray: "#6B7280",
};

const DEFAULT_BADGE_COLORS = ["#4B5563", "#9CA3AF"];

function normalizeHexColor(value, fallback) {
	if (typeof value !== "string") {
		return fallback;
	}
	const trimmed = value.trim();
	if (!trimmed) {
		return fallback;
	}
	if (/^#[0-9a-fA-F]{6}$/.test(trimmed)) {
		return trimmed;
	}
	if (/^[0-9a-fA-F]{6}$/.test(trimmed)) {
		return `#${trimmed}`;
	}
	return LINE_COLOR_MAP[trimmed.toLowerCase()] || fallback;
}

function normalizeColorList(value) {
	if (Array.isArray(value)) {
		return value.map((item) => normalizeHexColor(item, "")).filter(Boolean);
	}
	if (typeof value === "string") {
		return value
			.split(/[\s,|/]+/)
			.map((item) => normalizeHexColor(item, ""))
			.filter(Boolean);
	}
	return [];
}

export function getStationBadgeColors(feature) {
	const properties = feature?.properties || {};
	const badgeColors = normalizeColorList(properties.badge_colors);
	if (badgeColors.length > 0) {
		return badgeColors.slice(0, 2);
	}

	const lineColors = normalizeColorList(properties.line_colors);
	if (lineColors.length > 0) {
		return lineColors.slice(0, 2);
	}

	const lineColor = normalizeHexColor(
		properties.line_color || properties.color || properties.line,
		DEFAULT_BADGE_COLORS[0],
	);
	return [lineColor, lineColor];
}

export function getStationBadgeIconKey(colors) {
	const normalized = (colors?.length ? colors : DEFAULT_BADGE_COLORS)
		.slice(0, 2)
		.map((color) => normalizeHexColor(color, DEFAULT_BADGE_COLORS[0]))
		.map((color) => color.replace("#", "").toLowerCase());

	if (normalized.length === 1) {
		normalized.push(normalized[0]);
	}

	return `station-rent-${normalized.join("-")}`;
}

export function createStationBadgeSvg(colors) {
	const [leftColor, rightColor] = (
		colors?.length ? colors : DEFAULT_BADGE_COLORS
	)
		.slice(0, 2)
		.map((color, index) =>
			normalizeHexColor(
				color,
				DEFAULT_BADGE_COLORS[index] || DEFAULT_BADGE_COLORS[0],
			),
		);
	const safeLeft = leftColor || DEFAULT_BADGE_COLORS[0];
	const safeRight = rightColor || safeLeft;
	const svg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 72 72" width="72" height="72" aria-hidden="true" role="img">
  <defs>
    <clipPath id="station-badge-clip">
      <circle cx="36" cy="36" r="30" />
    </clipPath>
  </defs>
  <g clip-path="url(#station-badge-clip)">
    <rect x="6" y="6" width="30" height="60" fill="${safeLeft}" />
    <rect x="36" y="6" width="30" height="60" fill="${safeRight}" />
  </g>
  <circle cx="36" cy="36" r="30" fill="none" stroke="rgba(255,255,255,0.96)" stroke-width="4" />
  <circle cx="36" cy="36" r="24" fill="rgba(17,24,39,0.12)" />
</svg>`;

	return svg.trim();
}

export function createStationBadgeSvgDataUrl(colors) {
	const svg = createStationBadgeSvg(colors);
	return `data:image/svg+xml;base64,${btoa(svg)}`;
}
