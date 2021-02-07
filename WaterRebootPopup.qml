import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

Popup {
	id: container

	Rectangle {
		id: maskedArea

		anchors.fill: parent
		color: colors.dialogMaskedArea
		opacity: designElements.opacity
	}

	MouseArea {
		id: nonClickableArea

		anchors.fill: parent
	}

	Text {
		id: bigText_1

		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.top
			baselineOffset: Math.round(153 * verticalScaling)
		}

		text: app.popupString
		color: colors.softUpdatePopTextBig
		font.pixelSize: qfont.secondaryImportantBodyText
		font.family: qfont.semiBold.name
	}

	Throbber {
		id: loadingThrobber

		width: Math.round(90 * horizontalScaling)
		height: Math.round(87 * verticalScaling)

		anchors {
			centerIn: parent
		}

		Component.onCompleted: {
			smallDotColor = colors.fstDot;
			mediumDotColor = colors.fstDot;
			bigDotColor = colors.fstDot;
			largeDotColor = colors.fstDot;
		}
	}
}
