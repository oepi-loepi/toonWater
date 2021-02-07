import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Tile {
	id: todayTile

	property double dayLowUsage: 0
	property double dayUsage: 0
	property double avgDayValue: 0
	property double fixedDayCost: 0

	property bool isPowerTile: false
	property bool displayInEuro: false

	property alias titleText: titleText.text
	property alias valueText: valueText.text


	Text {
		id: titleText
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
		id: valueText
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
}
