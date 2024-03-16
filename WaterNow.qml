import QtQuick 2.1
import qb.components 1.0

Tile {
	id: waterMeter

	QtObject {
		id: p
		property int currentFrame: 0
		property int numFrames: 6
		property int waterLevel: 0
		property int flow: app.waterflow


		function update() {
			var newWaterLevel = 0;
			var newNumFrames = 6;
			var value = parseFloat((flow).toFixed(1));
			if (isNaN(value)) {
				waterValue.text = '-';
			} else {
				if (value > 0 && value < 3.5) {
					newWaterLevel = 1;
				} else if (value >= 3.5 && value < 7) {
					newNumFrames = 5;
					newWaterLevel = 2;
				} else if (value >= 7 && value < 10.5) {
					newWaterLevel = 3;
				} else if (value >= 10.5 && value < 15) {
					newWaterLevel = 4;
				} else if (value >= 15) {
					newWaterLevel = 5;
				}
				waterValue.text = i18n.number(value, 1, i18n.omit_trail_zeros) + " " + qsTr("liter(s)/min.", "", value);
			}
			if (waterLevel !== newWaterLevel) {
				animationTimer.stop();
				currentFrame = 0;
				numFrames = newNumFrames;
				waterLevel = newWaterLevel;
				if (newWaterLevel > 0)
					animationTimer.restart();
			}
		}
	}
	
	Component.onCompleted: {
		p.update()
		app.waterUpdated.connect(p.update)
	}

	onClicked: stage.openFullscreen(app.graphScreenUrl, {agreementType: "water", unitType: "energy", intervalType: "hours"})

	Text {
		id: waterWidgetText
		color: dimmableColors.tileTitleColor
		text:"Water nu"
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: qfont.tileTitle
		font.family: qfont.regular.name
	}

	Image {
		id: waterIcon
		anchors.centerIn: parent
		source: "image://scaled/apps/graph/drawables/"
				+ "waterTapTile-l" + p.waterLevel + "-f" + (p.currentFrame+1) + (dimState ? "-dim" : "") + ".svg";
	}

	Text {
		id: waterValue
		color: dimmableColors.tileTextColor
		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
		}
		font.pixelSize: qfont.tileText
		font.family: qfont.regular.name
	}

	Timer {
		id: animationTimer
		interval: 200
		repeat: true
		onTriggered: (p.currentFrame = ((p.currentFrame + 1) % p.numFrames))
	}
}