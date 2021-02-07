import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0

Tile {
	id: barTodayTile
	
	property double dayUsage: 0
	property double avgDayValue: 0
	property string titleText: ""
	property string valueText: ""
	property alias lowerRectColor: usageIndicatorLowRect.color
	property alias upperRectColor: usageIndicatorUpperRect.color

	onClicked: {
		stage.openFullscreen(app.waterScreenUrl)
	}


	
	function updateTileGraphic() {
		var heightFullBar = backgroundRect.height - middleBarRect.height;	// full bar, subtract middle bar
		var heightHalfBar = heightFullBar / 2;

		if (dayUsage>0) {
			var usage = dayUsage;
			var total = usage;
			var avg = avgDayValue;

			var beamHeight = (total / avg) * heightHalfBar;

			// lower part
			if (beamHeight <= heightHalfBar) {
				usageIndicatorLowRect.height = beamHeight;
			// upper part without rounding (subtract 3 for non-rounding)
			} else {
				if (beamHeight <= (heightFullBar - 3)) {
					usageIndicatorUpperRect.height = beamHeight - heightHalfBar;
					usageIndicatorUpperRect.topRightRadiusRatio = 0;
					usageIndicatorUpperRect.topLeftRadiusRatio = 0;
					usageIndicatorLowRect.height = heightHalfBar;
				// most upper part with rounding
				} else if (beamHeight < heightFullBar) {
					usageIndicatorUpperRect.height = beamHeight - heightHalfBar;
					usageIndicatorUpperRect.topRightRadiusRatio = 1;
					usageIndicatorUpperRect.topLeftRadiusRatio = 1;
					usageIndicatorLowRect.height = heightHalfBar;
				// >= 200 %
				} else {
					usageIndicatorUpperRect.height = heightHalfBar;
					usageIndicatorUpperRect.topRightRadiusRatio = 1;
					usageIndicatorUpperRect.topLeftRadiusRatio = 1;
					usageIndicatorLowRect.height = heightHalfBar;
				}
			}
		} else {
			usageIndicatorLowRect.height = 0;
			usageIndicatorUpperRect.height = 0;
		}
	}
	
	Text {
		id: titleText1
		text: titleText
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: dimmableColors.tileTitleColor
	}

	Text {
		id: valueText1
		text: valueText
		anchors {
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileText
		}
		color: dimmableColors.tileTextColor
	}

	
	Rectangle {
		id: backgroundRect
		width: Math.round(34 * horizontalScaling)
		height: Math.round(78 * verticalScaling)
		anchors.centerIn: parent
		radius: designElements.radius
		color: dimmableColors.dayTileBackgroundBar
	}

	Rectangle {
		id: middleBarRect
		width: backgroundRect.width
		height: Math.round(2 * verticalScaling)
		anchors.centerIn: parent
		color: dimmableColors.dayTileMiddleBar
	}


	StyledRectangle {
		id: usageIndicatorLowRect
		radius: designElements.radius
		bottomRightRadiusRatio: 1
		bottomLeftRadiusRatio: 1
		topRightRadiusRatio: 0
		topLeftRadiusRatio: 0
		width: backgroundRect.width
		height: 0
		anchors {
			bottom: backgroundRect.bottom
			horizontalCenter: parent.horizontalCenter
		}
		color: dimmableColors.dayTileAverageBar
		mouseEnabled: false
	}

	StyledRectangle {
		id: usageIndicatorUpperRect
		radius: designElements.radius
		topRightRadiusRatio: 0
		topLeftRadiusRatio: 0
		bottomRightRadiusRatio: 0
		bottomLeftRadiusRatio: 0
		width: backgroundRect.width
		height: 0
		anchors {
			bottom: middleBarRect.top
			horizontalCenter: parent.horizontalCenter
		}
		color: fixedDayCost ? dimmableColors.dayTileAverageBar : dimmableColors.dayTileUsageBar
		mouseEnabled: false
	}
	
	Timer {
        id: openTimer   //when opening screen
        interval: 10000
	repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: updateTileGraphic()
    }


}
