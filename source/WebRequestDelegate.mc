//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.Time.Gregorian;

class WebRequestDelegate extends WatchUi.BehaviorDelegate {
	var notify;
	var ip = "192.168.1.241";
	var userId = "0ejHbRec5R4sIw3rSiLUouUB6Kh7Y-BeDWqNs-yi";
	
    // Set up the callback to the view
    function initialize(handler) {
        WatchUi.BehaviorDelegate.initialize();
        notify = handler;
        
        makeRequest();
    }
    
    function makeRequest() {
    	var fullUrl = "http://" + ip + "/api/" + userId + "/lights";
        System.println("requesting " + fullUrl);
        Communications.makeWebRequest(
            fullUrl,
            {
            },
            {
            	:method => Communications.HTTP_REQUEST_METHOD_GET,
                :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON}
            },
            method(:requestCallback)
        );
    }
    
    function requestCallback(responseCode, data) {
    	if (responseCode == 200) {
    		System.println("data " + data);
    		var message = "Request successful";
    		var ln1 = "Bedroom " + getLightStateStr(data, 1);
    		var ln2 = "Kitchen " + getLightStateStr(data, 2);
    		var ln3 = "Spare room " + getLightStateStr(data, 3);
    		message = ln1 + "\n" + ln2 + "\n" +ln3 + "\n";
        	notify.invoke(message);
        } else {
            notify.invoke("Failed to load\nError: " + responseCode.toString());
        }
    }
    
    function getLightStateStr(data, num) {
    	if(data[num.toString()]["state"]["on"] == true) {
    		return "on";
    	}
    	else {
    		return "off";
		}
    }
    
    function onSelect() {
		return onMenu();
    }
    
    function onMenu() {
		// special menu while loading!
		var myMenu = new WatchUi.Menu();
		// todo: use timeEntryActionDict {action => start/stop}
		myMenu.addItem("Bedroom on", {"light"=>1, "action"=>true});
		myMenu.addItem("Bedroom off", {"light"=>1, "action"=>false});
		myMenu.addItem("Kichen on", {"light"=>2, "action"=>true});
		myMenu.addItem("Kitchen off", {"light"=>2, "action"=>false});
		myMenu.addItem("Spare room on", {"light"=>3, "action"=>true});
		myMenu.addItem("Spare room off", {"light"=>3, "action"=>false});
    	WatchUi.pushView(myMenu, new LoadingMenuDelegate(method(:loadingMenuUpdateCallback)), WatchUi.SLIDE_IMMEDIATE);
    }
    
    function loadingMenuUpdateCallback(actionInfo) {
    	System.println("loading menu callback: " + actionInfo);
    	
    	switchLight(actionInfo);
    }
    
    function switchLight(actionInfo) {
    	var lightNum = actionInfo["light"];
    	var action = actionInfo["action"];
    	var actionStr = "on";
    	if(action == false) {actionStr="off";}
    	
        notify.invoke("Sending light " + lightNum + " " + actionStr);
        var fullUrl = "http://" + ip + "/api/" + userId + "/lights/" + lightNum + "/state";
        System.println("requesting " + fullUrl);
        Communications.makeWebRequest(
            fullUrl,
            {
            	"on" => action
            },
            {
            	:method => Communications.HTTP_REQUEST_METHOD_PUT
            	,
                :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON}
            },
            method(:switchCallback)
        );
    }

    // Receive the data from the web request
    function switchCallback(responseCode, data) {
    	if (responseCode == 200) {
    		System.println("data " + data);
    		var message = "Request successful";
        	notify.invoke(message);
            
			makeRequest();
        } else {
            notify.invoke("Failed to load\nError: " + responseCode.toString());
        }
    }
    
    // todo: create parent class which has this available!
//    function doHarvestTimeEntryPatch(timeEntryId, typeStr) {
//    	System.println("patching after load " + typeStr + " time entry: " + timeEntryId);
//    	Communications.makeWebRequest(
//            "https://httpproxy.now.sh/api",
//            {
//            	"url" =>"https://api.harvestapp.com/v2/time_entries/"+timeEntryId+"/"+typeStr+"?"+"access_token=5034.pt.Zs6dN9lcB0QYSS0OQgtbuiDGJmU3LBp7mJRS1UvKo2Hxm_LD9gGGs8N-r0lPfhw3AeJMpQvpTSd7wgtdmIOcyQ&account_id=97677",
//            	"method"=>"PATCH"
//            },
//            {
//            	:method => Communications.HTTP_REQUEST_METHOD_POST,
//                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
//            },
//            method(:patchCallback)
//        );
//    }
//    
//    function patchCallback(responseCode, data) {
//    	// this seems to give me an error message!?
//    	System.println("patch response code: " + responseCode + " data: " + data);
//		makeRequest();
//    }
}