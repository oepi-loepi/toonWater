import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0
import FileIO 1.0

Screen {
	id: waterConfigScreen
	screenTitle: "Water"
	
	property int configChangeStep : 0
	property bool stepRunning : false
	property bool needReboot : false
	property bool needRestart : false
	property string tempEspURL: app.urlEspString
	property string tempDomURL: app.urlDomString
	property string tempdomIdxFlow: app.domIdxFlow
	property string tempdomIdxQuantity: app.domIdxQuantity
	property bool	tempDomMode: app.domMode

	property string fieldText1 : "Nieuwe waterstand:"
	property string tempTotal: app.waterquantity
	property bool   waterTotalChanged : false
	property bool   waterTarifffound: false

	property string oldConfigQmfFileString
	property bool   debugOutput : app.debugOutput
	
	FileIO {id: qmf_tenant_Configfile;	source: "file:///qmf/etc/qmf_tenant.xml"}
	FileIO {id: qmf_tenant_Configfile_bak;	source: "file:///qmf/etc/qmf_tenant.waterbackup"}
	FileIO {id: pwrusageFile;	source: "file:///mnt/data/qmf/config/config_happ_pwrusage.xml"}
	FileIO {id: pwrusageFileBak;	source: "file:///mnt/data/qmf/config/config_happ_pwrusage.bak"}
	FileIO {id: usageInfo;	source: "usageInfo.txt"}
	FileIO {id: billingInfo;	source: "billingInfo.txt"}

	onShown: {
		addCustomTopRightButton("Opslaan")
		getTariff()
		enableDomMode.isSwitchedOn = tempDomMode
		inputField1.inputText = tempTotal
		espIP.inputText =tempEspURL
		domoticzIP.inputText = tempDomURL
		idxFlow.inputText = tempdomIdxFlow
		idxQuantity.inputText = tempdomIdxQuantity
	}

	onCustomButtonClicked: {
		configChangeStep = 0
		stepRunning  = true
	}

	function saveFieldData1(text) {
		tempTotal= text
		if (tempTotal != app.waterquantity){waterTotalChanged = true}
	}
	
	
	function saveespURL(text) {
		if (text) {
			tempEspURL = text;
		}
	}

	function saveDomoticzURL1(text) {
		if (text) {
			 tempDomURL = text;
		}
	}

	function saveidxFlow(text) {
		if (text) {
			tempdomIdxFlow = text;
		}
	}
	
	function saveidxQuantity(text) {
		if (text) {
			tempdomIdxQuantity = text;
		}
	}

	Text {
		id: mytext1
		text:  "Instellingen"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			top: parent.top
			left: parent.left
			leftMargin: 20
			topMargin:20
		}
	}
	
	EditTextLabel4421 { 
		id: inputField1
		width: (parent.width*0.4) - 40		
		height: 30		
		leftTextAvailableWidth: 200
		leftText: "Handmatig totaal (geen kommas, punten spaties etc"
		labelFontSize: isNxt ? 18:14
		labelFontFamily: qfont.semiBold.name
		anchors {
			left: idxQuantity.left
			top: mytext1.bottom
			topMargin: 6
		}
		onClicked: {
			qkeyboard.open(inputField1.leftText, inputField1.inputText, saveFieldData1)
		}
	}
	
	NewTextLabel {
		id: tariffButton
		width: isNxt ? 284 : 220  
		height: isNxt ? 35 : 30
		buttonActiveColor: "lightgrey"
		buttonHoverColor: "blue"
		enabled : true
		textColor : "black"
		textDisabledColor : "grey"
		buttonText: "tarieven"
		anchors {
			top: mytext1.bottom
			topMargin: 6
			left: inputField1.right
			leftMargin: 30
			}
		onClicked: {
				onClicked: {stage.openFullscreen(app.waterTariffScreenUrl)}	
			}
		visible: waterTarifffound
	}


	NewTextLabel {
		id: savequantityText
		width: isNxt ? 120 : 96;  
		height: isNxt ? 40:32
		buttonActiveColor: "lightgreen"
		buttonHoverColor: "blue"
		enabled : true
		textColor : "black"
		buttonText:  "Annuleer"
		anchors {
			top: inputField1.top
			left: inputField1.right
			leftMargin: isNxt? 20: 16
			}
		onClicked: {
			tempTotal = app.waterquantity
			inputField1.inputText = tempTotal
			waterTotalChanged = false
		}
		visible: waterTotalChanged
	}

	Text {
		id: warning1TXT
		width:  parent.width
		text: "Deze versie ondersteund het uitlezen van Domoticz in plaats van een ESP (Wemos)"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			left: parent.left
			leftMargin: isNxt ? 20:16
			top:savequantityText.bottom
			topMargin: isNxt ? 10:8
		}
	}

	Text {
		id: warning2TXT
		width:  parent.width
		text: "Echter wordt dringend geadviseerd de mogelijkheid van de ESP optie te gebruiken in plaats van de Domoticz optie."
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			left: parent.left
			leftMargin: isNxt ? 20:16
			top:warning1TXT.bottom
		}
	}

	Text {
		id: warning3TXT
		width:  parent.width
		text: "De Domoticz optie is namelijk traag en zal achter lopen op de werkelijkheid."
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			left: parent.left
			leftMargin: isNxt ? 20:16
			top:warning2TXT.bottom
		}
	}

	Text {
		id: domModeTXT
		width:  160
		text: "Domoticz Mode"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			left: parent.left
			leftMargin: isNxt ? 20:16
			top:warning3TXT.bottom
			topMargin: isNxt ? 10:8
		}
	}

	OnOffToggle {
		id: enableDomMode
		height:  30
		leftIsSwitchedOn: true
		anchors {
			left: domModeTXT.right
			leftMargin: isNxt ? 60 : 48
			top: domModeTXT.top		
		}
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				tempDomMode = true;
			} else {
				tempDomMode = false;			}
		}
	}

	Text {
		id: domModeTXT2
		width:  160
		text: "ESP Mode, maakt gebruik van een geflashde Wemos D1 Mini"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			left: enableDomMode.right
			leftMargin: isNxt ? 65 : 25
			top: domModeTXT.top		
		}
	}

	Text {
		id: myLabel
		text: "IP adres van de ESP (bijvoorbeeld: 192.168.10.135)"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			left: parent.left
			top: domModeTXT.bottom		
			leftMargin: 20
			topMargin: 10
		}
		visible: !tempDomMode
	}

	EditTextLabel4421 {
		id: espIP
		width: (parent.width*0.6)	
		height: 30
		leftTextAvailableWidth: 200
		leftText: "esp8266 IP"
		labelFontSize: isNxt ? 18:14
		labelFontFamily: qfont.semiBold.name
		anchors {
			left: myLabel.left
			top: myLabel.bottom
			topMargin: 10
		}
		onClicked: {
			qkeyboard.open("IP adres van de ESP", espIP.inputText, saveespURL)
		}
		visible: !tempDomMode
	}

	Text {
		id: myLabel88
		text: "URL van Domoticz (bijvoorbeekd: http://192.168.10.185:8080)"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			left: parent.left
			top: domModeTXT.bottom		
			leftMargin: 20
			topMargin: 10
		}
		visible: tempDomMode
	}

	EditTextLabel4421 {
		id:  domoticzIP
		width: (parent.width*0.6)	
		height: 30
		leftTextAvailableWidth: 200
		leftText: "Domoticz URL"
		labelFontSize: isNxt ? 18:14
		labelFontFamily: qfont.semiBold.name
		anchors {
			left: myLabel.left
			top: myLabel.bottom
			topMargin: 10
		}

		onClicked: {
			qkeyboard.open("URL van Domoticz incl. Port", domoticzIP.inputText, saveDomoticzURL1)
		}
		visible: tempDomMode
	}

	Text {
		id: myLabel2
		text: "IDX from Domoticz (Devices Tab) :"
		font.pixelSize:  isNxt ? 20 : 16
		font.family: qfont.regular.name

		anchors {
			left: myLabel.left
			top: domoticzIP.bottom
			topMargin: 10
		}
		visible: tempDomMode
	}

	EditTextLabel4421 {
		id: idxFlow
		width: (parent.width*0.4) - 40		
		height: 30		
		leftTextAvailableWidth: 200
		leftText: "Flow IDX"
		labelFontSize: isNxt ? 18:14
		labelFontFamily: qfont.semiBold.name
		anchors {
			left: myLabel2.left
			top: myLabel2.bottom
			topMargin: 6
		}

		onClicked: {
			qkeyboard.open("Flow IDX", idxFlow.inputText, saveidxFlow)
		}
		visible: tempDomMode
	}


	EditTextLabel4421 {
		id: idxQuantity
		width: (parent.width*0.4) - 40		
		height: 30		
		leftTextAvailableWidth: 200
		leftText: "Quantity IDX"
		labelFontSize: isNxt ? 18:14
		labelFontFamily: qfont.semiBold.name
		anchors {
			left: idxFlow.left
			top: idxFlow.bottom
			topMargin: 6
		}

		onClicked: {
			qkeyboard.open("Meter IDX", idxQuantity.inputText, saveidxQuantity)
		}
		visible: tempDomMode
	}



	Image {
		id: qrCode
		source: "file:///qmf/qml/apps/toonWater/drawables/qrCode.png"
		anchors {
			right:  parent.right	
			bottom: parent.bottom
			rightMargin:10
			bottomMargin:10
		}
		width: isNxt ? 150:120
		height: isNxt ? 150:120
		fillMode: Image.PreserveAspectFit	
	}

	Text {
		id: myLabel90
		text: "Nog geen meter?"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 18:14
		anchors {
			horizontalCenter: qrCode.horizontalCenter
			bottom: qrCode.top		
			bottomMargin:10
		}
	}


	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	function getTariff(){

				console.log("*********Water check billingInfo in config_happ_pwrusage.xml")
				var waterfound = false
				var pwrusageString =  pwrusageFile.read()
				var pwrusageArray = pwrusageString.split("<billingInfo>")
				for (var t in pwrusageArray){
					var n201 = pwrusageArray[t].indexOf('</billingInfo>')
					var partOfString = pwrusageArray[t].substring(0, n201)
					if (partOfString.indexOf("water")>-1){
							waterTarifffound = true
					}
				}
	}



	function modRRDConfig(configChangeStep){
		var configfileString
		var oldconfigfileString
		var oldpwrusageString =  pwrusageFile.read()
		
		if (debugOutput) console.log("*********Water configChangeStep = " + configChangeStep)
		switch (configChangeStep) {
		
			case 0: {
				console.log("*********Water show popup")
				app.popupString = "Water instellen en herstarten als nodig" + "..."
				app.waterRebootPopup.show()
				break;
			}
		
			case 1: {
				console.log("*********Water check Water features in qmf_tenant")
				try {
					var rewrite_qmf_tenant = false
					configfileString =  qmf_tenant_Configfile.read()
					oldConfigQmfFileString = configfileString
					if (debugOutput) console.log("*********Water configfileString : " + configfileString)
					
					var fl = configfileString.length
					var n201 = configfileString.indexOf('<FT_WaterInsights_rel>')
					var n202 = configfileString.indexOf('</FT_WaterInsights_rel>',n201)
					console.log("*********Water oldvalue of FT_WaterInsights_rel: " + configfileString.substring(n201, n202))
					
					if (configfileString.substring(n201, n202) != "<FT_WaterInsights_rel>1"){
						rewrite_qmf_tenant = true
						console.log("*********Water setting FT_WaterInsights_rel to 1 ")
						var newconfigfileString = configfileString.substring(0, n201) + "<FT_WaterInsights_rel>1" + configfileString.substring(n202, configfileString.length)
						configfileString = newconfigfileString
						if (debugOutput) console.log("*********Water configfileString : " + configfileString)
					}
					else{
						console.log("*********Water no need to update FT_WaterInsights_rel")
					}
					if (rewrite_qmf_tenant){
						needRestart = true
						qmf_tenant_Configfile.write(newconfigfileString)
						console.log("*********Water new qmf_tenant saved")
						app.popupString = "Water Features aangezet" + "..." 
					}
					else{
						console.log("*********Water no need to rewrite qmf_tenant")
						app.popupString = "Water Features stonden reeds aan" + "..." 
					}
				} catch(e) { }
				break;
			}
			
			case 2: {
				console.log("*********Water check usageInfo in config_happ_pwrusage.xml")
				var waterfound = false
				var pwrusageString =  pwrusageFile.read()
				var pwrusageArray = pwrusageString.split("<usageInfo>")
				for (var t in pwrusageArray){
					var n201 = pwrusageArray[t].indexOf('</usageInfo>')
					var partOfString = pwrusageArray[t].substring(0, n201)
					if (partOfString.indexOf("water")>-1){waterfound = true}
				}
				if (waterfound == false){
					app.popupString = "Injecting usageInfo in config_happ_pwrusage.xml" + "..." 
					pwrusageFileBak.write(oldpwrusageString)
					var firstpart = pwrusageString.split("</Config>")[0]
					var newString = firstpart + usageInfo.read() + "</Config>"
					pwrusageFile.write(newString)
					needReboot = true
				}else{
					app.popupString = "Water usageInfo reeds in config_happ_pwrusage.xml" + "..." 
				}
				break;  
			}

			case 3: {
				console.log("*********Water check billingInfo in config_happ_pwrusage.xml")
				var waterfound = false
				var pwrusageString =  pwrusageFile.read()
				var pwrusageArray = pwrusageString.split("<billingInfo>")
				for (var t in pwrusageArray){
					var n201 = pwrusageArray[t].indexOf('</billingInfo>')
					var partOfString = pwrusageArray[t].substring(0, n201)
					if (partOfString.indexOf("water")>-1){waterfound = true}
				}
				if (waterfound == false){
					app.popupString = "Injecting billingInfo in config_happ_pwrusage.xml" + "..." 
					pwrusageFileBak.write(oldpwrusageString)
					var firstpart = pwrusageString.split("</Config>")[0]
					var newString = firstpart + billingInfo.read() + "</Config>"
					pwrusageFile.write(newString)
					needReboot = true
				}else{
					app.popupString = "Water billingInfo reeds in config_happ_pwrusage.xml" + "..." 
				}
				break;  
			}


			case 4: {
				if (app.urlDomString != tempDomURL || app.domIdxFlow != tempdomIdxFlow || app.domIdxQuantity != tempdomIdxQuantity || app.domMode != tempDomMode || app.urlEspString != tempEspURL){
					console.log("*********Water save app setting")
					app.urlDomString = tempDomURL
					app.domIdxFlow = tempdomIdxFlow
					app.domIdxQuantity = tempdomIdxQuantity
					app.domMode = 	tempDomMode
					app.urlEspString = tempEspURL
					app.saveSettings()
					app.popupString = "Instellingen opgeslagen" + "..." 
					needRestart = true
				}else{
					app.popupString = "Geen veranderingen in instellingen" + "..." 
				}
				break;
			}
			
			case 5: {
				if (waterTotalChanged){
					console.log("*********Water save new counter")
					var http = new XMLHttpRequest()
					var url = "http://" + app.urlEspString + "/setnew?" + tempTotal
					http.open("GET", url, true)
					http.send();
					app.popupString = "Nieuwe tellerstand opgeslagen" + "..." 
				}
				break;
			}
				
			case 6: {
				if (!needRestart && !needReboot) {
					console.log("*********Water no changes so no need to restart")
					app.popupString = "Restart niet nodig" + "..." 
					app.waterRebootPopup.hide()
					configChangeStep = 20
					stepRunning = false
					hide()
					break
				}
				break;
			}
			
			case 7: {
				if  ((needRestart || needReboot)) {
					console.log("*********Water creating backup of rewrite qmf_tenant ")
					qmf_tenant_Configfile_bak.write(oldConfigQmfFileString)
					app.popupString = "Backup van qmf_tenant maken" + "..." 
				}
				break;
			}
			
			case 8: {
				if (needRestart && !needReboot) {
					console.log("*********Water restart")
					console.log("*********Water restarting Toon")
					app.popupString = "Herstarten van Toon" + "..." 
					app.waterRebootPopup.hide()
					Qt.quit();
				}
				break;
			}
			
			case 9: {
				if (needReboot) {
					console.log("*********Water reboot")
					console.log("*********Water restartingToon")
					app.popupString = "Rebooten van Toon" + "..." 
					app.waterRebootPopup.hide()
					app.restartToon()
				}
				break;
			}
			default: {
				console.log("*********Water to default case ")
				app.waterRebootPopup.hide()
				configChangeStep = 20
				stepRunning = false
				needReboot = false
				needRestart = false
				hide()
				break;
			}
		}
	}

	Timer {
		id: stepTimer   //interval to nicely save all and reboot
		interval: 3000
		repeat:true
		running: stepRunning 
		triggeredOnStart: true
		onTriggered: {
			modRRDConfig(configChangeStep)
			configChangeStep++
		}
    }
	

	
	
	
}

