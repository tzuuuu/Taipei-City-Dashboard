<script setup>
//jarrenpoh
import { useAdminStore } from "../../store/adminStore";
import { ref } from 'vue';

const adminStore = useAdminStore();
// const year = ref('');
// const month = ref('');
// const day = ref('');
// const hour = ref('');
// const minute = ref('');
// const second = ref('');
const address = ref('');
const vehicleType = ref('');
const reportName = ref('');
const contactPhone = ref('');
const comments = ref('');
const vehicleNum = ref('');

const getFormattedDateTime = () => {
	const now = new Date();
	const year = now.getFullYear();
	const month = String(now.getMonth() + 1).padStart(2, '0');
	const day = String(now.getDate()).padStart(2, '0');
	const hours = String(now.getHours()).padStart(2, '0');
	const minutes = String(now.getMinutes()).padStart(2, '0');
	const seconds = String(now.getSeconds()).padStart(2, '0');

	return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}

const geocodeAddress = async (address) => {
	const YOUR_API_KEY = ''; // Replace with your actual API key
	const response = await fetch(`https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(address)}&key=${YOUR_API_KEY}`);
	const data = await response.json();

	if (data.status === 'OK' && data.results.length > 0) {
		const location = data.results[0].geometry.location;
		return {
			latitude: location.lat,
			longitude: location.lng,
		};
	} else {
		throw new Error('Unable to geocode address');
	}
}

const sendTrafficViolationsReport = async () => {
	try {
		const location = await geocodeAddress(address.value);
		const componentData = {
			ReporterName: reportName.value,
			ContactPhone: contactPhone.value,
			Longitude: location.longitude.toString(),
			Latitude: location.latitude.toString(),
			Address: address.value,
			ReportTime: getFormattedDateTime(),
			Vehicle: vehicleType.value,
			Violation: '違停',
			Comments: comments.value,
			VehicleNum: vehicleNum.value,
		};
		console.log("Component Data:", componentData);
		adminStore.sendTrafficViolationsReport(componentData);
	} catch (error) {
		console.error("Error geocoding address:", error);
	}
}
</script>

<template>
	<div class="dashboardcomponent font-ms grid-1">
		<div>違停舉報</div>
		<div>舉報人姓名：<input v-model="reportName" type="text" /></div>
		<div>舉報人電話：<input v-model="contactPhone" type="text" /></div>
		<div>
			違停車輛類型：
			<select v-model="vehicleType">
				<option>請選擇車輛類型</option>
				<option value="汽車">汽車</option>
				<option value="重型機車">重型機車</option>
				<option value="機車">機車</option>
				<option value="腳踏車">腳踏車</option>
			</select>
		</div>
		<div>車牌：<input v-model="vehicleNum" type="text" /></div>
		<div>地點：<input v-model="address" type="text" /></div>
		<div>補充說明：<input v-model="comments" type="text" /></div>
		<!-- <div>
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
		</div> -->
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
