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
	
	property string urlString
	property url 	tileUrl2 : "WaterTile.qml"
	property url 	tileNow : "WaterNow.qml"

	//property url 	thumbnailIcon1: "qrc:/../apps/graph/drawables/waterTapTile-thumb.svg"    //werkt
	//property url 	thumbnailIcon1: Qt.resolvedUrl("image:///apps/graph/drawables/waterTapTile-thumb.svg")  //werkt
	property url 	thumbnailIcon1: ("qrc://apps/graph/drawables/waterTapTile-thumb.svg")    //werkt

	
	property		WaterConfigScreen  waterConfigScreen
	property url 	waterConfigScreenUrl : "WaterConfigScreen.qml"
	property string popupString : "Water instellen en herstarten als nodig" + "..."
	property string configMsgUuid : ""

	property url	waterTodayTileUrl : "WaterTodayTile.qml"
	
  	property int 	waterflow : 0
	property int 	waterquantity : 0
	property int 	todayValue : 0
	property int 	dayAvgValue : 200
	
        property string urlString2 : "192.168.10.135"
	property bool  	debugOutput : false
	
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


	
	
	signal waterUpdated()	

	
	property variant waterSettingsJson : {
		'urlString' : ""
	}

	function init() {
		registry.registerWidget("tile", tileNow, this, null, {thumbLabel: qsTr("Nu"), thumbIcon: thumbnailIcon1, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileUrl2, this, null, {thumbLabel: qsTr("Text"), thumbIcon: thumbnailIcon1, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("screen", waterConfigScreenUrl, this, "waterConfigScreen")
		registry.registerWidget("tile", waterTodayTileUrl, this, null,  {thumbLabel: qsTr("Vandaag"), thumbIcon:  thumbnailIcon1, thumbCategory:  "general", thumbWeight: 30, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("popup", waterRebootPopupUrl, waterApp, "waterRebootPopup");
	}

	FileIO {id: waterSettingsFile;	source: "file:///mnt/data/tsc/water_userSettings.json"}
	FileIO {id: water_lastFiveDays;	source: "file:///mnt/data/tsc/appData/water_lastFiveDays.txt"}
	FileIO {id: water_totalValue;	source: "file:///mnt/data/tsc/appData/water_totalValue.txt"}

		
	Component.onCompleted: {
		for (var i = 0; i <= 5; i++){lastFiveDays[i] = 0 }
		dateTimeNow= new Date()
		scrapeTimer.running = true
		scrapeTimer2.running = true
		
		waterSettingsJson = JSON.parse(waterSettingsFile.read())
		try {
			urlString = waterSettingsJson['urlString']
		} catch(e) {
		}
		
		//calculate the average 5 day value for the daytile
		try {var lastFiveDaysString = water_lastFiveDays.read() ; if (lastFiveDaysString.length >2 ){lastFiveDays = lastFiveDaysString.split(',') }} catch(e) { }
		var totalForAvg = 0
		var avgcounter = 0
		for (var i in lastFiveDays){
			if (debugOutput) cconsole.log("*********Water lastFiveDays[i]: " + lastFiveDays[i])
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
///////////////////////////////////////////////////////////////// GET DATA //////////////////////////////////////////////////////////////////////////////	

	function getData(fivemin){
		if (debugOutput) console.log("*********Water Start getData")
		if (urlString !=""){
			var http = new XMLHttpRequest()
			http.open("GET", "http://" + urlString + "/water.html", true); //check the feeds from the webpage
			http.onreadystatechange = function() {
				if (http.readyState === XMLHttpRequest.DONE) {
					if (http.status === 200) {
						if (debugOutput) onsole.log("*********Water http.responseText: " + http.responseText)
						var JsonString = http.responseText
						var JsonObject= JSON.parse(JsonString)
						// {"waterflow":"0","waterquantity":"1031188"}
						waterflow = parseInt(JsonObject.waterflow)
						waterquantity = parseInt(JsonObject.waterquantity)
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
						if (fivemin){doData()}
					} else {
						if (debugOutput) console.log("*********Water error: " + http.status)
					}
				}
			}
			http.send();
		}
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
			getData(from5min)
        }
    }
	
    Timer {
            id: scrapeTimer2   //interval to write the data to the rrd
            interval: 30000
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
				getData(from5min)
			}
    }
	
///////////////////////////////////////// SAVE ALL TO SETTINGS ///////////////////////////////////////////////////////////////////////////////////////////////// 
   	function saveSettings() {
		var setJson = {
			"urlString" : urlString,
		}
		waterSettingsFile.write(JSON.stringify(setJson))
		waterSettingsJson = JSON.parse(waterSettingsFile.read())
		getData()
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
