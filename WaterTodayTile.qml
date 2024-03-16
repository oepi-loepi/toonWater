import QtQuick 2.1

BarTodayTile {
	id: powerTodayTile
	titleText: "Water vandaag"
	lowerRectColor: dimmableColors.graphWater
	upperRectColor: dimmableColors.graphWaterSelected
	dayUsage : app.todayValue
	valueText : parseFloat(app.todayValue/1000).toFixed(2) + " m3"
	avgDayValue : app.dayAvgValue
	onClicked: {
		stage.openFullscreen(app.graphScreenUrl, {agreementType: "water", unitType: "energy", intervalType: "days"})
	}
}
