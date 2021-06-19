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
	
	property string  oldprice : ""
	property string  oldpriceNet : ""
	
	property string  newprice : oldprice
	property string  newpriceNet : oldpriceNet
	
	
	property string pwrusageFileString : "file:///mnt/data/qmf/config/config_happ_pwrusage.xml"
	
	FileIO {id: pwrusageFile;	source: "file:///mnt/data/qmf/config/config_happ_pwrusage.xml"}
	FileIO {id: pwrusageFileBak;	source: "file:///mnt/data/qmf/config/config_happ_pwrusage.bak"}

	onShown: {
		addCustomTopRightButton("Opslaan")
		getTariff()
		priceInput.inputText = newprice
		priceNetInput.inputText = newpriceNet
	}

	onCustomButtonClicked: {
		configChangeStep = 0
		stepRunning  = true
	}

	function saveprice(text) {
		if (text) {
			if(text.indexOf(',')>-1){text = text.replace(',','.')}
			newprice = text;
		}
	}

	function savepriceNet(text) {
		if (text) {
		     if(text.indexOf(',')>-1){text = text.replace(',','.')}
			 newpriceNet = text;
		}
	}

	Text {
		id: mytext1
		text:  "Prijzen"
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
		id: priceInput
		width: (parent.width*0.6)			
		height: 30		
		leftTextAvailableWidth: (parent.width*0.6)-100
		leftText: "Prijs inclusief belasting (bijv. 1.0000)"
		labelFontSize: isNxt ? 18:14
		labelFontFamily: qfont.semiBold.name
		anchors {
			left: mytext1.left
			top: mytext1.bottom
			topMargin: 6
		}
		onClicked: {
			qkeyboard.open(priceInput.leftText, priceInput.inputText,saveprice)
		}
	}


	EditTextLabel4421 {
		id: priceNetInput
		width: (parent.width*0.6)	
		height: 30
		leftTextAvailableWidth: (parent.width*0.6)-100
		leftText: "Prijs exclusief belasting (Netto)  (bijv. 0.8700)"
		labelFontSize: isNxt ? 18:14
		labelFontFamily: qfont.semiBold.name
		anchors {
			left: mytext1.left
			top: priceInput.bottom
			topMargin: 10
		}
		onClicked: {
			qkeyboard.open(priceNetInput.leftText, priceNetInput.inputText,savepriceNet)

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
							waterfound = true
							var n300 = pwrusageArray[t].indexOf('<price>') + "<price>".length
							var n301 = pwrusageArray[t].indexOf('</price>',n300)
							oldprice = pwrusageArray[t].substring(n300, n301)
							var n305 = pwrusageArray[t].indexOf('<priceNet>') + "<priceNet>".length
							var n306 = pwrusageArray[t].indexOf('</priceNet>',n305)
							oldpriceNet = pwrusageArray[t].substring(n305, n306)
							console.log("*********Water price : " + oldprice)
							console.log("*********Water priceNet : " + oldpriceNet)
					}
				}
	}
	
	function modTariff(configChangeStep){
		
		console.log("*********Water configChangeStep = " + configChangeStep)
		var oldpwrusageString =  pwrusageFile.read()

		switch (configChangeStep) {
		
			case 0: {
				console.log("*********Water show popup")
				app.popupString = "Water instellen en herstarten als nodig" + "..."
				app.waterRebootPopup.show()
				break;
			}
		
			case 1: {
				if (oldprice != newprice) {
					console.log("*********Water check pwrusageFileString for tariff")
					pwrusageFileBak.write(oldpwrusageString)
					try {
						var tariffOld = new XMLHttpRequest();
						tariffOld.onreadystatechange = function() {
							if (tariffOld.readyState == XMLHttpRequest.DONE) {
									var newContent = tariffOld.responseText
									newContent = newContent.replace('<price>' + oldprice + '</price>','<price>' + newprice + '</price>')
									var tariffNew = new XMLHttpRequest();
									tariffNew.open("PUT", pwrusageFileString);
									tariffNew.send(newContent);
									tariffNew.close;
									app.popupString = "Prijs inclusief belastingen opgeslagen" + "..." 
									needReboot = true
							}
						}
						tariffOld.open("GET", pwrusageFileString, true);
						tariffOld.send();
					} catch(e) { }
				}else{
					app.popupString = "Prijs inclusief belastingen niet gewijzigd" + "..." 
				}
				break;
			}
			
			case 2: {
				if (oldpriceNet != newpriceNet) {
					console.log("*********Water check pwrusageFileString for nett tariff")
					pwrusageFileBak.write(oldpwrusageString)
					try {
						var tariffOld = new XMLHttpRequest();
						tariffOld.onreadystatechange = function() {
							if (tariffOld.readyState == XMLHttpRequest.DONE) {
										var newContent = tariffOld.responseText
										newContent = newContent.replace('<priceNet>' + oldpriceNet + '</priceNet>','<priceNet>' + newpriceNet + '</priceNet>')
										var tariffNew = new XMLHttpRequest()
										tariffNew.open("PUT", pwrusageFileString)
										tariffNew.send(newContent)
										tariffNew.close
										app.popupString = "Prijs exclusief belastingen opgeslagen" + "..." 
										needReboot = true
							}
						}
						tariffOld.open("GET", pwrusageFileString, true);
						tariffOld.send();
					} catch(e) { }
				}else{
					app.popupString = "Prijs exclusief belastingen niet gewijzigd" + "..." 
				}
				break;
			}

				
			case 3: {
				if (!needReboot) {
					console.log("*********Water no changes in tariff so no need to restart")
					app.popupString = "Restart niet nodig" + "..." 
					app.waterRebootPopup.hide()
					configChangeStep = 20
					stepRunning = false
					hide()
					break
				}
				break;
			}
			
			
			case 4: {
				if (needReboot) {
					console.log("*********Water reboot")
					console.log("*********Water restartingToon")
					app.popupString = "Herstarten van Toon" + "..." 
					app.waterRebootPopup.hide()
					//app.restartToon()
					//Qt.quit();

				}
				break;
			}
			
			
			default: {
				console.log("*********Water to default case ")
				app.waterRebootPopup.hide()
				configChangeStep = 20
				stepRunning = false
				needReboot = false
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
			modTariff(configChangeStep)
			configChangeStep++
		}
    }
	

	
	
	
}

