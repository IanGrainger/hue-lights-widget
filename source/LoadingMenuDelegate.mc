using Toybox.WatchUi;
using Toybox.Communications;

class LoadingMenuDelegate extends WatchUi.MenuInputDelegate {
	var callback;
    function initialize(updateCallback) {
        MenuInputDelegate.initialize();
        callback = updateCallback;
    }
    
    function onMenuItem(item) {
    	callback.invoke(item);
    }
}
