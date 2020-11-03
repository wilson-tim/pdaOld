function drawYMap(X,Y){
	var H = 256;
	var W = 512;
	var Z = 1;
	var T = '';
	
	// Create a map object
	var map = new YMap(document.getElementById('map'));
 
	// Add map type control
	map.addTypeControl();
	map.addZoomShort();
	p = map.getCenterLatLon();
	map.addMarker(p);
 
	// Set map type to either of: YAHOO_MAP_SAT, YAHOO_MAP_HYB, YAHOO_MAP_REG
	map.setMapType(YAHOO_MAP_REG);var d = document.getElementById('map')
 
	var d = document.getElementById('map');
 
	d.style.height = H + 'px';var d = document.getElementById('map')
	d.style.width = W + 'px';
 
	// Display the map centered on a geocoded location
	map.drawZoomAndCenter( X, Z);
    YEvent.Capture(map, EventsList.MouseClick, myCallback);  

    function myCallback(_e, _c){  
        /*   
           It is optional to specify the location of the Logger.   
           Do so by sending a YCoordPoint to the initPos function.  
         */  
        var mapmapCoordCenter = map.convertLatLonXY(map.getCenterLatLon());  
        YLog.initPos(mapCoordCenter); //call initPos to set the starting location  
        currentGeoPoint = new YGeoPoint( _c.Lat, _c.Lon);  
        placeMarker(currentGeoPoint);  
        displayPolyLines(currentGeoPoint);    
    } 
}