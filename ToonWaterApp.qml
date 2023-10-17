//
// Water by Oepi-Loepi
//

import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0
import BxtClient 1.0

App {
	id: waterApp
	
	property bool  	debugOutput : false
	
	property url 	tileUrl2 : "WaterTile.qml"
	property url 	tileNow : "WaterNow.qml"

	//property url 	thumbnailIcon1: "qrc:/../apps/graph/drawables/waterTapTile-thumb.svg"    //werkt
	//property url 	thumbnailIcon1: Qt.resolvedUrl("image:///apps/graph/drawables/waterTapTile-thumb.svg")  //werkt
	property url 	thumbnailIcon1: ("qrc://apps/graph/drawables/waterTapTile-thumb.svg")    //werkt
	property url 	minVersionURL: "https://raw.githubusercontent.com/ToonSoftwareCollective/toonWater/main/minversion.txt"    //werkt
	
	property	WaterConfigScreen  waterConfigScreen
	property url 	waterConfigScreenUrl : "WaterConfigScreen.qml"
	
	property	WaterTariffScreen  waterTariffScreen
	property url 	waterTariffScreenUrl : "WaterTariffScreen.qml"
	
	property string popupString : "Water instellen en herstarten als nodig" + "..."
	property string configMsgUuid : ""

	property url	waterTodayTileUrl : "WaterTodayTile.qml"
	property url	waterTodayTileEurUrl : "WaterTodayTileEuro.qml"
	
  	property int 	waterflow : 0
	property int 	waterquantity : 0
	property int 	todayValue : 0
	property int 	dayAvgValue : 200
	
	
    property int 	waterflowMobile : 0
	property int 	watertodayMobile : 0
	
	property date 	dateTimeNow
	property int 	dday
	property int 	hrs
	property int 	mins
	property string dtime : "0"
	
	property int	totallast5min : 0
	property int	avglast5min  : 0
	property int	oldquantity  : 0
	property int	yesterdayquantity  : 0
	property bool	from5min : false
	property variant lastFiveDays: []
	
	property url 	waterRebootPopupUrl: "WaterRebootPopup.qml"
	property 		Popup waterRebootPopup
	
	property bool  	domMode: false

	property bool  	updateAvailable : false
	property int	newmajor : 1
	property int	newminor : 1 
	property int	newbuild : 1
	
	property string urlDomString:""
	property string domIdxFlow: ""
	property string domIdxQuantity:""
	property string urlEspString
	
	property bool	newDomoticz : false
	
	property string waterTariff : "1.0000"

	
	signal waterUpdated()	

	
	property variant waterSettingsJson : {
		'urlEspString' : "",
		'domMode' : "",
		'urlDomString' : "",
		'domIdxFlow' : "",
		'domIdxQuantity' : ""
	}

	function init() {
		registry.registerWidget("tile", tileNow, this, null, {thumbLabel: qsTr("Nu"), thumbIcon: thumbnailIcon1, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileUrl2, this, null, {thumbLabel: qsTr("Text"), thumbIcon: thumbnailIcon1, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("screen", waterConfigScreenUrl, this, "waterConfigScreen")
		registry.registerWidget("screen", waterTariffScreenUrl, this, "waterTariffScreen")
		registry.registerWidget("tile", waterTodayTileUrl, this, null,  {thumbLabel: qsTr("Vandaag m3"), thumbIcon:  thumbnailIcon1, thumbCategory:  "general", thumbWeight: 30, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", waterTodayTileEurUrl, this, null,  {thumbLabel: qsTr("Vandaag EUR"), thumbIcon:  thumbnailIcon1, thumbCategory:  "general", thumbWeight: 30, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("popup", waterRebootPopupUrl, waterApp, "waterRebootPopup");
	}

	FileIO {id: waterSettingsFile;	source: "file:///mnt/data/tsc/water_userSettings.json"}
	FileIO {id: water_lastFiveDays;	source: "file:///mnt/data/tsc/appData/water_lastFiveDays.txt"}
	FileIO {id: water_totalValue;	source: "file:///mnt/data/tsc/appData/water_totalValue.txt"}
	FileIO {id: pwrusageFile;	source: "file:///mnt/data/qmf/config/config_happ_pwrusage.xml"}
	FileIO {id: water_mobile;	source: "file:///qmf/www/water.html"}
	
		
	Component.onCompleted: {
		for (var i = 0; i <= 5; i++){lastFiveDays[i] = 0 }
		dateTimeNow= new Date()
		scrapeTimer.running = true
		scrapeTimer2.running = true
		checkupdatetimer.running = true
		
		waterSettingsJson = JSON.parse(waterSettingsFile.read())
		try {
			urlEspString = waterSettingsJson['urlString']
		} catch(e) {
		}
		
		//new version so new try
		try {
				var domModeTXT= waterSettingsJson['domMode']
				if (domModeTXT == 'Domoticz'){
					domMode = true
				}else{
					domMode = false
				}
				urlDomString = waterSettingsJson['urlDomString']
				domIdxFlow = waterSettingsJson['domIdxFlow']
				domIdxQuantity = waterSettingsJson['domIdxQuantity']
		} catch(e) {
		}
		
		
		if (domMode){
			if (debugOutput) console.log("*********Water get version from Domoticz")
			var http = new XMLHttpRequest();
			http.open("GET", urlDomString + "/json.htm?type=command&param=getversion", true)
			http.onreadystatechange = function() {
				if (http.readyState == XMLHttpRequest.DONE) {
					if (http.status === 200 || http.status === 300  || http.status === 302) {
						try {
							var JsonString = http.responseText
							if (debugOutput) console.log("*********Water http.responseText: " + http.responseText)
							var JsonObject = JSON.parse(JsonString)
							var mainVersion= parseInt((JsonObject.version).split('.')[0])
							var minorVersion= parseInt((JsonObject.version).split('.')[1])
							if (debugOutput) console.log("*********Water mainVersion: " + mainVersion)
							if (debugOutput) console.log("*********Water minorVersion: " + minorVersion)
							if (mainVersion>2022 || (mainVersion === 2022 & minorVersion >2)){
								newDomoticz = true
							}else{
								newDomoticz = false
							}
							if (debugOutput) console.log("*********Water newDomoticz: " + newDomoticz)
						}
						catch(e){
							newDomoticz = true
							if (debugOutput) console.log("*********Water error -> newDomoticz: " + newDomoticz)
						}
					} else {
						if (debugOutput) console.log("*********Water error: " + http.status)
						newDomoticz = true
						if (debugOutput) console.log("*********Water error -> newDomoticz: " + newDomoticz)
					}
				}
			}
			http.send();
		}
		
		getTariff()
		
		//calculate the average 5 day value for the daytile
		try {var lastFiveDaysString = water_lastFiveDays.read() ; if (lastFiveDaysString.length >2 ){lastFiveDays = lastFiveDaysString.split(',') }} catch(e) { }
		var totalForAvg = 0
		var avgcounter = 0
		for (var i in lastFiveDays){
			if (debugOutput) console.log("*********Water lastFiveDays[i]: " + lastFiveDays[i])
			if (!isNaN(lastFiveDays[i]) & (parseInt(lastFiveDays[i])>0)){
					totalForAvg = totalForAvg + parseInt(lastFiveDays[i])
					if (debugOutput) console.log("*********Water parsed lastFiveDays[i]: " + lastFiveDays[i])
					avgcounter ++
				}
			}
		if((totalForAvg>0) && (avgcounter >3)) {dayAvgValue = parseInt(totalForAvg/avgcounter)} //calculate the avg for at least 3 days
		//console.log("*********Water dayAvgValue : " + dayAvgValue)
		
		try {
			var totalValueString = water_totalValue.read(); 
			if (totalValueString.length > 0 ){
				yesterdayquantity = parseInt(totalValueString); 
				//console.log("*********Water yesterdayquantity from disk " + yesterdayquantity)
			}
		} catch(e) {}

	}
	
///////////////////////////////////////////////////////////////// GET BILLING TARIFF ///////////////////////////////////////////////////////////////////////////	
	function getTariff(){
		console.log("*********Water get Tariff")
		var waterfound = false
		var pwrusageString =  pwrusageFile.read()
		var pwrusageArray = pwrusageString.split("<billingInfo>")
		for (var t in pwrusageArray){
			var n201 = pwrusageArray[t].indexOf('</billingInfo>')
			var partOfString = pwrusageArray[t].substring(0, n201)
			if (partOfString.indexOf("water")>-1){
				waterfound = true
				var n205 = partOfString.indexOf('<price>') + "<price>".length
				var n206 = partOfString.indexOf('</price>')
				waterTariff = partOfString.substring(n205,n206)
				console.log("*********Water waterTariff " + waterTariff)
			}
		}
    }
	
///////////////////////////////////////////////////////////////// GET DATA ESP ///////////////////////////////////////////////////////////////////////////

	function getESPData(fivemin){
		if (debugOutput) console.log("*********Water Start getESPData")
		if (urlEspString !=""){
			var http = new XMLHttpRequest()
			http.open("GET", "http://" + urlEspString + "/water.html", true); //check the feeds from the webpage
			http.onreadystatechange = function() {
				if (http.readyState === XMLHttpRequest.DONE) {
					if (http.status === 200) {
						if (debugOutput) console.log("*********Water http.responseText: " + http.responseText)
						var JsonString = http.responseText
						// {"waterflow":"0","waterquantity":"1294748","today":"48","currentBatch":"0","breakdetect":"0","leakdetect":"0","RSSI":"-29","version":"1.4.39","update":"0","pulselength":13693","pulsetime":"2186"}
						// add an extra \" because of a firmware error
						
						if (debugOutput) console.log("*********Water http.responseText.indexOf : " + http.responseText.indexOf('ength\":\"'))
						
						
						if(http.responseText.indexOf('pulselength') > 0){
							if(http.responseText.indexOf('ength\":\"') == -1){
								var n1 = http.responseText.indexOf('ength":') + 'engt\":'.length +1
								var newString = http.responseText.substring(0, n1) + "\"" + http.responseText.substring(n1, http.responseText.length)
								JsonString = newString;
								if (debugOutput) console.log("*********Water JsonString: " + JsonString)
							}
						}
						
						var JsonObject= JSON.parse(JsonString)
						
						waterflow = parseInt(JsonObject.waterflow)
						waterquantity = parseInt(JsonObject.waterquantity)
						updateAvailable = false
						updateAvailable = !(JsonObject.hasOwnProperty('version'))
						if (!updateAvailable){
							var versionArray = JsonObject.version.split('.');
							var oldmajor =  parseInt(versionArray[0]);
							if (debugOutput) console.log("*********oldmajor: " + oldmajor)
							if (debugOutput) console.log("*********newmajor: " + newmajor)
							var oldminor =  parseInt(versionArray[1]);
							if (debugOutput) console.log("*********oldminor: " + oldminor)
							if (debugOutput) console.log("*********newminor: " + newminor)
							var oldbuild =  parseInt(versionArray[2]);
							if (debugOutput) console.log("*********oldbuild: " + oldbuild)
							if (debugOutput) console.log("*********newbuild: " + newbuild)
							
							
							if (newmajor>oldmajor & !updateAvailable){updateAvailable = true;}
							if (newmajor==oldmajor & newminor>oldminor & !updateAvailable){updateAvailable = true;}
							if (newmajor==oldmajor & newminor==oldminor & newbuild>oldbuild & !updateAvailable ){updateAvailable = true;}
							if (debugOutput) console.log("*********updateAvailable from version check: " + updateAvailable)
						}				

						if (debugOutput) console.log("*********Water waterflow: " + waterflow)
						if (debugOutput) console.log("*********Water waterquantity: " + waterquantity)
						if (yesterdayquantity == 0){yesterdayquantity = waterquantity}
						if (yesterdayquantity  > waterquantity){
						try {var totalValueString = water_totalValue.read(); if (totalValueString.length > 0 ){yesterdayquantity = parseInt(totalValueString)}} catch(e) {}
						}
						//console.log("*********Water waterquantity " + waterquantity)
						//console.log("*********Water yesterdayquantity " + yesterdayquantity)
						todayValue = waterquantity - yesterdayquantity
						//console.log("*********Water todayValue " + todayValue)
						waterUpdated()
						if (waterflowMobile != waterflow || watertodayMobile != todayValue ){
						    water_mobile.write("{\"result\":\"ok\",\"water\": {\"flow\":" + waterflow + ", \"total\":" + waterquantity + ", \"value\":" + todayValue + ", \"avgValue\":" + dayAvgValue + "}}")
						    waterflowMobile = waterflow
							watertodayMobile = todayValue
						}
						if (fivemin){doData()}
					} else {
						if (debugOutput) console.log("*********Water error: " + http.status)
					}
				}
			}
			http.send();
		}
    }
	
	function getMinVersion(){
		var http = new XMLHttpRequest()
		http.open("GET", minVersionURL, true); //check the feeds from the webpage
		http.onreadystatechange = function() {
			if (http.readyState === XMLHttpRequest.DONE) {
				if (http.status === 200) {
					if (debugOutput) console.log("*********Water http.responseText: " + http.responseText)
					var totalNewVersion = http.responseText
						var versionArray = totalNewVersion.split('.');
						newmajor =  parseInt(versionArray[0]);
						if (debugOutput) console.log("*********newmajor: " + newmajor)
						newminor =  parseInt(versionArray[1]);
						if (debugOutput) console.log("*********newminor: " + newminor)
						newbuild =  parseInt(versionArray[2]);
						if (debugOutput) console.log("*********newbuild: " + newbuild)
				}else {
					if (debugOutput) console.log("*********Water error: " + http.status)
				}
			}
		}
		http.send();
	}
				
	
///////////////////////////////////////////////////////////////// GET DATA Domoticz ///////////////////////////////////////////////////////////////////////////	
			
	function getDomoticzData(fivemin){
		if (debugOutput) console.log("*********Water Start getDomoticzData")
		var http = new XMLHttpRequest();
		var urlpart = ""
		if(newDomoticz){
			urlpart = "/json.htm?type=command&param=getdevices&rid="
		}else{
			urlpart = "/json.htm?type=devices&rid="
		}
		http.open("GET", urlDomString + urlpart + domIdxFlow, true)
		http.onreadystatechange = function() {
			if (http.readyState == XMLHttpRequest.DONE) {
				if (http.status === 200 || http.status === 300  || http.status === 302) {
					try {
						var JsonString = http.responseText
						if (debugOutput) console.log("*********Water http.responseText: " + http.responseText)
						var JsonObject = JSON.parse(JsonString)
						waterflow= parseInt((JsonObject.result[0].Data).split(' ')[0])
						if (debugOutput) console.log("*********Water waterflow: " + waterflow)
						if (debugOutput) console.log("*********Water waterquantity: " + waterquantity)
						getDomoticzData2(fivemin, waterflow)
					}
					catch(e){
						waterflow = 0
					}
				} else {
					if (debugOutput) console.log("*********Water error: " + http.status)
				}
			}
		}
		http.send();
    }
	
	function getDomoticzData2(fivemin, waterflow){
		if (debugOutput) console.log("*********Water Start getDomoticzData")
		var http = new XMLHttpRequest();
		var urlpart = ""
		if(newDomoticz){
			urlpart = "/json.htm?type=command&param=getdevices&rid="
		}else{
			urlpart = "/json.htm?type=devices&rid="
		}
		http.open("GET", urlDomString + urlpart + domIdxFlow, true)
		http.onreadystatechange = function() {
			if (http.readyState == XMLHttpRequest.DONE) {
				if (http.status === 200 || http.status === 300  || http.status === 302) {
						var JsonString = http.responseText
						if (debugOutput) console.log("*********Water http.responseText: " + http.responseText)
						var JsonObject= JSON.parse(JsonString)
						var reswaterquantity= (JsonObject.result[0].Data).split(' ')[0]
						waterquantity= reswaterquantity
						//console.log("*********Water waterquantity: " + reswaterquantity)
						if (reswaterquantity.indexOf("e+")>-1){
							var number = reswaterquantity.split("e+")[0]
							var number2 = reswaterquantity.split("e+")[1]
							//console.log("*********Water number: " +number)
							//console.log("*********Water number2: " + number2)
							var newnumber = parseInt(parseFloat(number) * Math.pow(10,parseInt(number2)))
							//console.log("*********Water newnumber: " + newnumber)
							waterquantity= newnumber
							
						}
						if (reswaterquantity.indexOf(".")>-1){
							var leftstring = reswaterquantity.split(".")[0]
							var rightstring = reswaterquantity.split(".")[1]
							if (rightstring.length == 0)rightstring = "000"
							if (rightstring.length == 1)rightstring = rightstring + "00"
							if (rightstring.length == 2)rightstring = rightstring + "0"
							if (rightstring.length == 3)rightstring = rightstring
							reswaterquantity = leftstring  + rightstring
							//console.log("*********Water reswaterquantity: " + reswaterquantity)
							waterquantity= parseInt(reswaterquantity)
						}
						
						if (reswaterquantity.indexOf(",")>-1){
							var leftstring = reswaterquantity.split(",")[0]
							var rightstring = reswaterquantity.split(",")[1]
							if (rightstring.length == 0)rightstring = "000"
							if (rightstring.length == 1)rightstring = rightstring + "00"
							if (rightstring.length == 2)rightstring = rightstring + "0"
							if (rightstring.length == 3)rightstring = rightstring
							reswaterquantity = leftstring  + rightstring
							//console.log("*********Water reswaterquantity: " + reswaterquantity)
							waterquantity= parseInt(reswaterquantity)
						}
						if (debugOutput) console.log("*********Water waterflow: " + waterflow)
						if (debugOutput) console.log("*********Water waterquantity: " + waterquantity)
						if (yesterdayquantity  > waterquantity){
							try {var totalValueString = water_totalValue.read(); if (totalValueString.length > 0 ){yesterdayquantity = parseInt(totalValueString)}} catch(e) {}
						}
						if (debugOutput) console.log("*********Water waterquantity " + waterquantity)
						if (debugOutput) console.log("*********Water yesterdayquantity " + yesterdayquantity)
						todayValue = waterquantity - yesterdayquantity
						if (debugOutput) console.log("*********Water todayValue " + todayValue)
						waterUpdated()
						if (waterflowMobile != waterflow || watertodayMobile != todayValue ){
					             water_mobile.write("{\"result\":\"ok\",\"water\": {\"flow\":" + waterflow + ", \"total\":" + waterquantity + ", \"value\":" + todayValue + ", \"avgValue\":" + dayAvgValue + "}}")
						     waterflowMobile = waterflow
							watertodayMobile = todayValue
						}
						if (fivemin){doData()}
				} else {
					if (debugOutput) console.log("*********Water error: " + http.status)
				}
			}
		}
		http.send();
    }
	

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////DO DATA  //////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
    function doData(){
	
		doEachtimeStuff()
		
		if (mins>=0 & mins <=4){
			doHourlyStuff()
		}
		
		if (dtime>=0 & dtime<=4){ //it is a new day
			doDailyStuff()
		}
    }


/////////////////////////////////////////WRITE 5MIN   DATA/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////Each time data was received      /////////////////////////////////////////////////////////////////////////////////
	
	function doEachtimeStuff(){
		var this5minquantity= 0
		var this5minflow= this5minquantity *12  //(flow per hour)
		if (oldquantity>0){
			var this5minquantity= waterquantity - oldquantity
			var this5minflow= this5minquantity *12
		}
		//push current 5 minutes into the array for the RRA  flow
		var http2 = new XMLHttpRequest()
		var url2 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=water_flow&rra=5min&samples=%7B%22" + parseInt(dateTimeNow.getTime()/1000)+ "%22%3A" + parseInt(this5minflow) + "%7D"
		http2.open("GET", url2, true)
		http2.send()
		
		oldquantity = waterquantity
		
		//push quantity into the 5yrhours RRA data
		//produced this day so it must be in the RRA of next hour 00 mins
		var nexthour = new Date();
		nexthour.setMinutes (nexthour.getMinutes() + 60);  //60 minutes extra
		nexthour.setSeconds(0); //round to full hour
		nexthour.setMinutes(0); //round to full hour
		var http3 = new XMLHttpRequest()
		var url3 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=water_quantity&rra=10yrhours&samples=%7B%22" + parseInt(nexthour.getTime()/1000)+ "%22%3A" + parseInt(waterquantity) + "%7D"
		http3.open("GET", url3, true)
		http3.send()
	}


/////////////////////////////////////////WRITE HOURLY DATA/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////At the beginning of a new hour ///////////////////////////////////////////////////////////////////////////////////

	function doHourlyStuff(){
		//it seems like the last hour is deleted when the new hour is set (dunno why) so we just set the previos hour again.
		//push quantity into the 10yrhours RRA data
		//produced this day so it must be in the RRA of next hour 00 mins
		var thishour = new Date();
		thishour.setSeconds(0); //round to full hour
		thishour.setMinutes(0); //round to full hour
		var http3 = new XMLHttpRequest()
		var url3 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=water_quantity&rra=10yrhours&samples=%7B%22" + parseInt(thishour.getTime()/1000)+ "%22%3A" + parseInt(waterquantity) + "%7D"
		http3.open("GET", url3, true)
		http3.send()
	}
	

/////////////////////////////////////////WRITE DAILY DATA/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////At the beginning of the day//////////////////////////////////////////////////////////////////////////////////////

	function doDailyStuff(){
	
		//shift the last5day array 1 day to the left, push today the the last pos and create a new string
		var lastFiveDaysString = parseInt(lastFiveDays[1])
		for (var g = 2; g <= 4; g++) {
			 lastFiveDaysString += "," + parseInt(lastFiveDays[g])
		}
		lastFiveDaysString += "," + parseInt(todayValue)
		water_lastFiveDays.write(lastFiveDaysString)
		
		
		//calculate the average 5 day value for the daytile
		lastFiveDays = lastFiveDaysString.split(',')
		var totalForAvg = 0
		var avgcounter = 0
		for (var i in lastFiveDays){
			if (!isNaN(lastFiveDays[i]) & (parseInt(lastFiveDays[i])>0)){
					totalForAvg = totalForAvg + parseInt(lastFiveDays[i])
					avgcounter ++
				}
			}
		if((totalForAvg>0) && (avgcounter >3)) {dayAvgValue = parseInt(totalForAvg/avgcounter)} //calculate the avg for at least 3 days
		if (debugOutput) console.log("*********Water dayAvgValue : " + dayAvgValue)
		
		water_totalValue.write(parseInt(waterquantity))
		yesterdayquantity = waterquantity
		//doDelayedDailyStuff()
		todayValue = 0
	}
///////////////////////////////////////// TIMERS /////////////////////////////////////////////////////////////////////////////////////////////////

    Timer {
		id: scrapeTimer   //interval to get the water data
		interval: 10000
		repeat: true
		running: false
		triggeredOnStart: true
		onTriggered: {
			if (debugOutput) console.log("*********Water Start timer getData")
			from5min = false
			if (domMode){
				getDomoticzData(from5min)
			}else{
				getESPData(from5min)
			}
        }
    }
	
    Timer {
            id: scrapeTimer2   //interval to write the data to the rrd
            interval: 300000
            repeat: true
            running: false
            triggeredOnStart: true
            onTriggered: {
				dateTimeNow= new Date()
				dtime = parseInt(Qt.formatDateTime (dateTimeNow,"hh") + "" + Qt.formatDateTime (dateTimeNow,"mm"))
				dday = dateTimeNow.getDate()
				hrs = parseInt(Qt.formatDateTime(dateTimeNow,"hh"))
				mins = parseInt(Qt.formatDateTime(dateTimeNow,"mm"))
				if (debugOutput) console.log("*********Water dtime : " + dtime)
				from5min = true
				if (domMode){
					getDomoticzData(from5min)
				}else{
					getESPData(from5min)
				}
			}
    }
	
	Timer {
            id: checkupdatetimer   //interval to write the data to the rrd
            interval: 12*60*60*1000
            repeat: true
            running: false
            triggeredOnStart: true
            onTriggered: {
				getMinVersion()
			}
    }
///////////////////////////////////////// SAVE ALL TO SETTINGS ///////////////////////////////////////////////////////////////////////////////////////////////// 
   	function saveSettings() {
		var tempDomModeTxt
		if (domMode){
			tempDomModeTxt = "Domoticz"
		}else{
			tempDomModeTxt = "ESP"
		}		
		var setJson = {
			"urlDomString" : urlDomString,
			"domIdxFlow" : domIdxFlow,
			"domIdxQuantity" : domIdxQuantity,
			"domMode" : tempDomModeTxt,
			"urlString" : urlEspString
		}
		waterSettingsFile.write(JSON.stringify(setJson))
		waterSettingsJson = JSON.parse(waterSettingsFile.read())
		from5min = true
		if (domMode){
			getDomoticzData(from5min)
		}else{
			getESPData(from5min)
		}
	}
	
	function restartToon() {
		var restartToonMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, configMsgUuid, "specific1", "RequestReboot");
		bxtClient.sendMsg(restartToonMessage);
	}
	
	BxtDiscoveryHandler {
		id: configDiscoHandler
		deviceType: "hcb_config"
		onDiscoReceived: {
			configMsgUuid = deviceUuid
		}
	}
	
}
