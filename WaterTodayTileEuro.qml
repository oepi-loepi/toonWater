import QtQuick 2.1

BarTodayTile {
	id: waterTodayTileEUR
	titleText: "Water vandaag"
	lowerRectColor: dimmableColors.graphWater
	upperRectColor: dimmableColors.graphWaterSelected
	dayUsage : app.todayValue
	valueText : " EUR " + parseFloat(app.todayValue/1000 * parseFloat(app.waterTariff)).toFixed(2)
	avgDayValue : app.dayAvgValue
	onClicked: {
		stage.openFullscreen(app.graphScreenUrl, {agreementType: "water", unitType: "money", intervalType: "days"})
	}
}
