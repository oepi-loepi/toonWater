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

	property string fieldText5 : "URL zoals \"192.168.10.5\":"
	property string tempURL: app.urlString

	property string fieldText1 : "Nieuwe waterstand:"
	property string tempTotal: app.waterquantity
	property bool waterTotalChanged : false

	property string oldConfigQmfFileString
	property bool debugOutput : app.debugOutput
	
	FileIO {id: qmf_tenant_Configfile;	source: "file:///qmf/etc/qmf_tenant.xml"}
	FileIO {id: qmf_tenant_Configfile_bak;	source: "file:///qmf/etc/qmf_tenant.waterbackup"}

	onShown: {
		addCustomTopRightButton("Opslaan")
		inputField5.inputText = tempURL
		inputField1.inputText = tempTotal
	}

	onCustomButtonClicked: {
		configChangeStep = 0
		stepRunning  = true
	}

	function saveFieldData1(text) {
		tempTotal= text
		if (tempTotal != app.waterquantity){waterTotalChanged = true}
	}

	function saveFieldData5(text) {
		tempURL= text
	}

	Text {
		id: mytext1
		text:  "Instellingen"
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top: parent.top
			left:parent.left
			leftMargin:100
			topMargin:100
		}
	}

	Text {
		id: setText1
		text:  "URL zoals \"192.168.10.135\""
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top: mytext1.bottom
			topMargin:  isNxt ? 10:8
			left:mytext1.left
		}
	}


	EditTextLabel4421 { 
		id: inputField5 ; 
		width: isNxt?  200 : 160
		height: isNxt? 35:28;	
		leftTextAvailableWidth: isNxt? 100:80; 
		leftText: ""
		anchors {
			top: setText1.bottom
			topMargin:  isNxt ? 8:6
			left:mytext1.left
		}
		onClicked: {
			qkeyboard.open(setText1.text, inputField5.inputText, saveFieldData5)
		}
	}
	
	Text {
		id: setText2
		text:  "Nieuwe waterstand"
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top: inputField5.bottom
			topMargin:  isNxt ? 10:8
			left:mytext1.left
		}
	}
	
	EditTextLabel4421 { 
		id: inputField1
		width: isNxt?  200 : 160
		height: isNxt? 35:28;	
		leftTextAvailableWidth: isNxt? 100:80; 
		leftText: ""
		anchors {
			top: setText2.bottom
			topMargin:  isNxt ? 8:6
			left:mytext1.left
		}
		onClicked: {
			qkeyboard.open(setText2.text, inputField1.inputText, saveFieldData1)
		}
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

	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	function modRRDConfig(configChangeStep){
		var configfileString
		var oldconfigfileString
		
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
				console.log("*********Water save app setting")
				app.urlString = tempURL
				app.saveSettings()
				app.popupString = "Instellingen opgeslagen" + "..." 
				break;
			}
			
			case 3: {
				if (waterTotalChanged){
					console.log("*********Water save new counter")
					var http = new XMLHttpRequest()
					var url = "http://" + app.urlString + "/setnew?" + tempTotal
					http.open("GET", url, true)
					http.send();
					app.popupString = "Nieuwe tellerstand opgeslagen" + "..." 
				}
				break;
			}
				
			case 4: {
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
			
			case 5: {
				if  ((needRestart || needReboot)) {
					console.log("*********Water creating backup of rewrite qmf_tenant ")
					qmf_tenant_Configfile_bak.write(oldConfigQmfFileString)
					app.popupString = "Backup van qmf_tenant maken" + "..." 
				}
				break;
			}
			
			case 6: {
				if (needRestart && !needReboot) {
					console.log("*********Water restart")
					console.log("*********Water restarting Toon")
					app.popupString = "Herstarten van Toon" + "..." 
					app.waterRebootPopup.hide()
					Qt.quit();
				}
				break;
			}
			
			case 7: {
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

