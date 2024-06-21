<!-- eslint-disable vue/multi-word-component-names -->
<script setup>

//jarrenpoh
import { useAdminStore } from "../../store/adminStore";
import { ref } from 'vue';

const adminStore = useAdminStore();
const year = ref('2024');  // TODO: 直接使用當下時間
const month = ref('6');
const day = ref('21');
const hour = ref('12');
const minute = ref('10');
const second = ref('10');
// const address = ref('');
const vehicleType = ref('');
const longitude = ref('121.5641661'); // TODO: 直接獲取用戶所在 經緯度   25.036960486042506, 121.56416612679072
const latitude = ref('25.0369604');
// const comments = ref(''); // TODO: 開放用戶上傳備註

const sendTrafficViolationsReport = async () => {
	const reportTime = `${year.value}-${month.value}-${day.value} ${hour.value}:${minute.value}:${second.value}`;
	const componentData = {
		ReporterName: '匿名',
		ContactPhone: '未提供',
		Longitude: longitude.value,
		Latitude: latitude.value,
		Address: '無',
		ReportTime: reportTime,
		Vehicle: vehicleType.value,
		Violation: '違規停車',
		Comments: '無'
	};

	year.value = "";
	day.value = "";
	month.value = "";
	hour.value = "";
	minute.value = "";
	second.value = "";
	// address.value = "";
	vehicleType.value = "";
	longitude.value = "";
	latitude.value = "";

	// eslint-disable-next-line no-console
	console.log("Component Data:", componentData);
	adminStore.sendTrafficViolationsReport(componentData);
}
</script>

<template>
	<div class="dashboardcomponent font-ms grid-1">
		<div>違停舉報</div>
		<div>
			日期：<input v-model="year" type="text" style="width: 48px" />年
			<input v-model="month" type="text" style="width: 48px" />月
			<input v-model="day" type="text" style="width: 48px" />日
		</div>
		<div>
			<span>
				時間：<input v-model="hour" type="text" style="width: 48px" />時
				<input v-model="minute" type="text" style="width: 48px" />分
				<input v-model="second" type="text" style="width: 48px" />秒
			</span>
		</div>
		<!-- <div>地點：<input v-model="address" type="text" /></div> -->
		<div>經度：<input v-model="longitude" type="text" /></div>
		<div>緯度：<input v-model="latitude" type="text" /></div>
		<div>
			違停車輛類型：
			<select v-model="vehicleType">
				<option>請選擇車輛類型</option>
				<option value="汽車">汽車</option>
				<option value="重型機車">重型機車</option>
				<option value="機車">機車</option>
				<option value="自行車">自行車</option>
				<option value="貨車">貨車</option>
			</select>
		</div>
		<div class="right"><input class="right" type="button" value="送出檢舉" @click="sendTrafficViolationsReport" /></div>
	</div>
</template>

<style scoped lang="scss">
.font-ms {
	font-size: var(--font-ms);
}
.grid-1 {
	display: grid;
	grid-template-columns: 1fr;
	gap: 8px;
}

.dashboardcomponent {
	height: 330px;
	max-height: 330px;
	width: calc(100% - var(--dashboardcomponent-font-m) * 2);
	max-width: calc(100% - var(--dashboardcomponent-font-m) * 2);
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	position: relative;
	padding: var(--dashboardcomponent-font-m);
	border-radius: 5px;
	background-color: var(--dashboardcomponent-color-component-background);
}
.right {
	display: flex;
	justify-content: right;
}
.flex {
	display: flex;
}
</style>
