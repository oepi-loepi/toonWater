import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

Tile {
    id: root 
	property bool dimState: screenStateController.dimmedColors
	property int flow: app.waterflow
	property int quan: app.waterquantity
	property int day: app.todayValue

	onClicked: {
			stage.openFullscreen(app.waterConfigScreenUrl)
	}
	
	Component.onCompleted: {
		app.waterUpdated.connect(updateWater)
	}

	function updateWater(){
		flow = app.waterflow
		quan = app.waterquantity
		day = app.todayValue
	}
	
	Text {
		id: tileTitle
		anchors {
			baseline: parent.top
			baselineOffset: 30
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: !dimState? "black" : "white"
		text: "Water"
	}

	
	Text {
		id: curFlow
		text: "Flow Nu: " + flow  + " l/m"
		color: !dimState? "black" : "white"
		anchors {
			top: tileTitle.bottom
			topMargin: isNxt? 5:4
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: isNxt? 22:18
		font.family: qfont.bold.name
    }
	
	Text {
		id: dayQuantity

		text: "Vandaag: " + parseFloat(day) + " l"
		color: !dimState? "black" : "white"
		anchors {
			top: curFlow.bottom
			topMargin: 1
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: isNxt? 22:18
		font.family: qfont.bold.name
    }

	Text {
		id: totalQuantity

		text: "Totaal: " + parseFloat(quan/1000).toFixed(3) + " m3"
		color: !dimState? "black" : "white"
		anchors {
			top: dayQuantity.bottom
			topMargin: 1
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: isNxt? 22:18
		font.family: qfont.bold.name
    }


}



