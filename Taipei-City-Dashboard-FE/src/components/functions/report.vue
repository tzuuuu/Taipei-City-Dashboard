<script setup>
//jarrenpoh
import { useAdminStore } from "../../store/adminStore";
import { ref } from 'vue';

const adminStore = useAdminStore();
const year = ref('');
const month = ref('');
const day = ref('');
const hour = ref('');
const minute = ref('');
const second = ref('');
const address = ref('');
const vehicleType = ref('');

const sendTrafficViolationsReport = async () => {
	const reportTime = `${year.value}-${month.value}-${day.value} ${hour.value}:${minute.value}:${second.value}`;
    const componentData = {
        ReporterName: '匿名',
        ContactPhone: '未提供',
        Longitude: '未知',
        Latitude: '未知',
        Address: address.value,
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
	address.value = "";
	vehicleType.value = "";

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
		<div>地點：<input v-model="address" type="text" /></div>
		<div>
			違停車輛類型：
			<select v-model="vehicleType">
				<option>請選擇車輛類型</option>
				<option value="汽車">汽車</option>
				<option value="重型機車">重型機車</option>
				<option value="機車">機車</option>
				<option value="腳踏車">腳踏車</option>
				<option value="腳踏車">貨車</option>
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
