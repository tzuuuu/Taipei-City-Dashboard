<!-- Developed by Taipei Urban Intelligence Center 2026 -->
<!-- Quartile (Q1/Median/Q3) multi-group chart, narrow-width friendly -->
<script setup>
import { computed, ref, watch } from "vue";

const props = defineProps([
	"chart_config",
	"activeChart",
	"series",
	"map_config",
	"map_filter",
	"map_filter_on",
]);

const items = computed(() => (Array.isArray(props.series) ? props.series : []));
const selectedCity = ref("");
const selectedDistrict = ref("");

const normalizedItems = computed(() =>
	items.value
		.map((it, index) => {
			const isNoData =
				Boolean(it.is_no_data) || it.no_data_reason != null;

			const q1 = it.q1 == null ? null : Number(it.q1);
			const median = it.median == null ? null : Number(it.median);
			const q3 = it.q3 == null ? null : Number(it.q3);

			// For "real" data rows, ensure quartile values are valid.
			if (!isNoData) {
				if (!Number.isFinite(q1) || !Number.isFinite(median) || !Number.isFinite(q3)) {
					return null;
				}
			}

			const min =
				it.min == null
					? (q1 ?? null)
					: Number(it.min);
			const max =
				it.max == null
					? (q3 ?? null)
					: Number(it.max);

			const sortKey = Number.isFinite(Number(it.sort_key))
				? Number(it.sort_key)
				: index;
			return {
				name: String(it.name ?? ""),
				icon: it.icon ? String(it.icon) : "stacked_line_chart",
				cityName: String(it.city_name ?? ""),
				districtName: String(it.district_name ?? ""),
				sortKey,
				isNoData,
				noDataReason: it.no_data_reason ?? null,
				min,
				q1,
				median,
				q3,
				max,
			};
		})
		.filter(Boolean),
);

const cityOptions = computed(() => {
	const values = [
		...new Set(
			normalizedItems.value.map((it) => it.cityName).filter(Boolean),
		),
	];
	return values.sort((a, b) => a.localeCompare(b, "zh-Hant"));
});

const districtOptions = computed(() => {
	const source = normalizedItems.value.filter((it) => {
		if (!selectedCity.value) return true;
		return it.cityName === selectedCity.value;
	});
	const values = [
		...new Set(source.map((it) => it.districtName).filter(Boolean)),
	];
	return values.sort((a, b) => {
		if (a === "全市" && b !== "全市") return -1;
		if (b === "全市" && a !== "全市") return 1;
		return a.localeCompare(b, "zh-Hant");
	});
});

const filteredItems = computed(() => {
	let result = [...normalizedItems.value];
	if (selectedCity.value) {
		result = result.filter((it) => it.cityName === selectedCity.value);
	}
	if (selectedDistrict.value) {
		result = result.filter(
			(it) => it.districtName === selectedDistrict.value,
		);
	}
	// Generic ordering:
	// - Prefer API-provided sort_key (if exists)
	// - Otherwise preserve incoming order (map index)
	return result.sort((a, b) => a.sortKey - b.sortKey);
});

const displayItems = computed(() =>
	filteredItems.value.filter((it) => !it.isNoData),
);

const hasData = computed(() => displayItems.value.length > 0);

const noDataReason = computed(() => {
	const found =
		filteredItems.value.find((it) => it.isNoData && it.noDataReason) ||
		null;
	return found?.noDataReason || "";
});

const shouldScroll = computed(() => displayItems.value.length > 4);

const showAreaSelectors = computed(() =>
	normalizedItems.value.some((it) => it.cityName || it.districtName),
);

watch(
	normalizedItems,
	() => {
		if (showAreaSelectors.value) {
			if (
				!selectedCity.value ||
				!cityOptions.value.includes(selectedCity.value)
			) {
				selectedCity.value = cityOptions.value[0] ?? "";
			}
			if (
				!selectedDistrict.value ||
				!districtOptions.value.includes(selectedDistrict.value)
			) {
				selectedDistrict.value = districtOptions.value[0] ?? "";
			}
		} else {
			selectedCity.value = "";
			selectedDistrict.value = "";
		}
	},
	{ immediate: true },
);

watch(selectedCity, () => {
	if (!districtOptions.value.includes(selectedDistrict.value)) {
		selectedDistrict.value = districtOptions.value[0] ?? "";
	}
});

function colorForIndex(i) {
	const colors = props.chart_config?.color;
	return Array.isArray(colors) && colors.length > 0
		? colors[i % colors.length]
		: "var(--color-highlight)";
}

function formatNumber(v) {
	if (!Number.isFinite(v)) return "-";
	// Match design: display as integer to avoid ugly decimals.
	const rounded = Math.round(v);
	return new Intl.NumberFormat("zh-TW").format(rounded);
}

function rangeStyle(_it, i) {
	// Align segment with the center of Q1/Q3 label columns (1/6 -> 5/6)
	return {
		left: "16.6667%",
		width: "66.6667%",
		backgroundColor: colorForIndex(i),
	};
}

function medianStyle() {
	return { left: "50%" };
}

function whiskerStyle(type, _i) {
	// color is applied via inline styles below
	return { left: type === "min" ? "0%" : "100%" };
}
</script>

<template>
	<div v-if="activeChart === 'QuartileChart'" class="QuartileChart">
		<div v-if="showAreaSelectors" class="QuartileChart__filters">
			<select v-model="selectedCity">
				<option v-for="city in cityOptions" :key="city" :value="city">
					{{ city }}
				</option>
			</select>
			<select v-model="selectedDistrict">
				<option
					v-for="district in districtOptions"
					:key="district"
					:value="district"
				>
					{{ district }}
				</option>
			</select>
		</div>

		<Transition name="quartile-fade" mode="out-in">
			<div
				:key="`${selectedCity || 'all'}-${selectedDistrict || 'all'}`"
				:class="[
					'QuartileChart__list',
					{
						'QuartileChart__list--scroll': shouldScroll,
						'QuartileChart__list--fit4': !shouldScroll,
					},
				]"
			>
				<div v-if="hasData">
					<div
						v-for="(it, i) in displayItems"
						:key="`${it.name}-${i}`"
						class="QuartileChart__row"
					>
						<div class="QuartileChart__left">
							<div
								class="QuartileChart__icon"
								:style="{ backgroundColor: colorForIndex(i) }"
							>
								<span>{{ it.icon }}</span>
							</div>
							<div class="QuartileChart__meta">
								<div class="QuartileChart__title">
									{{ it.name }}
								</div>
								<div class="QuartileChart__unit">
									{{
										props.chart_config?.unit
											? `單位：${props.chart_config.unit}`
											: ""
									}}
								</div>
							</div>
						</div>

						<div class="QuartileChart__right">
							<div class="QuartileChart__labels">
								<div class="QuartileChart__label">
									<div class="QuartileChart__labelKey">Q1</div>
									<div
										class="QuartileChart__labelVal"
										:style="{ color: colorForIndex(i) }"
									>
										{{ formatNumber(it.q1) }}
									</div>
								</div>
								<div class="QuartileChart__label">
									<div class="QuartileChart__labelKey">
										中位數
									</div>
									<div
										class="QuartileChart__labelVal QuartileChart__labelVal--median"
										:style="{ color: colorForIndex(i) }"
									>
										{{ formatNumber(it.median) }}
									</div>
								</div>
								<div class="QuartileChart__label">
									<div class="QuartileChart__labelKey">Q3</div>
									<div
										class="QuartileChart__labelVal"
										:style="{ color: colorForIndex(i) }"
									>
										{{ formatNumber(it.q3) }}
									</div>
								</div>
							</div>

							<div class="QuartileChart__track">
								<div
									class="QuartileChart__trackLine"
									:style="{
										backgroundColor: colorForIndex(i),
										opacity: 0.25,
									}"
								/>
								<div
									class="QuartileChart__whisker"
									:style="{
										...whiskerStyle('min', i),
										backgroundColor: colorForIndex(i),
										opacity: 0.42,
									}"
								/>
								<div
									class="QuartileChart__whisker"
									:style="{
										...whiskerStyle('max', i),
										backgroundColor: colorForIndex(i),
										opacity: 0.42,
									}"
								/>
								<div
									class="QuartileChart__range"
									:style="rangeStyle(it, i)"
								/>
								<div
									class="QuartileChart__median"
									:style="medianStyle(it)"
								/>
							</div>
						</div>
					</div>
				</div>
				<div v-else class="QuartileChart__noData">
					{{ noDataReason }}
				</div>
			</div>
		</Transition>
	</div>
</template>

<style scoped lang="scss">
.QuartileChart {
	height: 100%;
	width: 100%;
	overflow: hidden;
	overflow-x: hidden;
	box-sizing: border-box;
	padding-bottom: 8px;

	&__list {
		height: 100%;
		min-height: 0;
		overflow: hidden;
		box-sizing: border-box;
		padding-bottom: 8px;
	}

	&__list--scroll {
		overflow-y: auto;
	}

	&__list--fit4 {
		overflow: hidden;
	}

	&__filters {
		display: grid;
		grid-template-columns: auto auto;
		justify-content: start;
		gap: 6px;
		padding: 2px 2px 6px;

		select {
			height: auto;
			min-height: auto;
			font-size: var(--font-ms);
			line-height: 1.2;
			padding: 2px 6px;
			width: 85px;
			max-width: 44vw;
			justify-self: start;
		}
	}

	&__noData {
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		padding: 0 12px;
		text-align: center;
		font-size: var(--font-ms);
		color: var(--color-complement-text);
	}

	&__row {
		display: grid;
		grid-template-columns: minmax(88px, 120px) minmax(0, 1fr);
		align-items: center;
		column-gap: 6px;
		padding: 6px 2px;
		border-bottom: 1px solid var(--color-border);
	}

	&__row:last-child {
		padding-bottom: 10px;
		border-bottom: none;
	}

	&__left {
		display: flex;
		align-items: center;
		gap: 6px;
		min-width: 0;
	}

	&__icon {
		width: 30px;
		height: 30px;
		border-radius: 999px;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;

		span {
			font-family: var(--font-icon);
			font-size: 1rem;
			color: rgba(255, 255, 255, 0.95);
			user-select: none;
		}
	}

	&__meta {
		min-width: 0;
	}

	&__title {
		font-size: 1.05rem;
		font-weight: 600;
		color: var(--color-normal-text);
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	&__unit {
		font-size: 0.72rem;
		color: var(--color-complement-text);
		margin-top: 1px;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	&__right {
		min-width: 0;
	}

	&__labels {
		display: grid;
		grid-template-columns: repeat(3, minmax(0, 1fr));
		align-items: end;
		margin-bottom: 2px;
	}

	&__label {
		min-width: 0;
		text-align: center;
	}

	&__labelKey {
		font-size: var(--font-s);
		color: var(--color-complement-text);
		line-height: 1;
	}

	&__labelVal {
		margin-top: 1px;
		font-size: var(--font-ms);
		font-weight: 700;
		line-height: 1.1;
		white-space: nowrap;
	}

	&__track {
		position: relative;
		height: 16px;
	}

	&__trackLine {
		position: absolute;
		left: 0;
		right: 0;
		top: 50%;
		transform: translateY(-50%);
		height: 3px;
		border-radius: 999px;
		background: transparent;
	}

	&__range {
		position: absolute;
		top: 50%;
		transform: translateY(-50%);
		height: 5px;
		border-radius: 999px;
		z-index: 3;
	}

	&__median {
		position: absolute;
		top: 50%;
		transform: translate(-50%, -50%);
		width: 10px;
		height: 10px;
		border-radius: 999px;
		background: #fff;
		border: 2px solid rgba(0, 0, 0, 0.3);
		z-index: 4;
	}

	&__whisker {
		position: absolute;
		top: 50%;
		transform: translate(-50%, -50%);
		width: 2px;
		height: 11px;
		background: transparent;
		z-index: 2;
	}

	&__labelVal--median {
		font-size: 1.06rem;
	}
}

.quartile-fade-enter-active,
.quartile-fade-leave-active {
	transition:
		opacity 0.18s ease,
		transform 0.18s ease;
}

.quartile-fade-enter-from,
.quartile-fade-leave-to {
	opacity: 0;
	transform: translateY(4px);
}
</style>
