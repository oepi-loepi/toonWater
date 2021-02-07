import QtQuick 2.1

BarTodayTile {
	id: powerTodayTile
	titleText: "Water Vandaag"
	lowerRectColor: dimmableColors.graphWater
	upperRectColor: dimmableColors.graphWaterSelected
	
	onClicked: {
		stage.openFullscreen(app.waterScreenUrl)
	}
	dayUsage : app.todayValue
	valueText : parseFloat(app.todayValue/1000).toFixed(2) + " m3"
	avgDayValue : app.dayAvgValue
}
