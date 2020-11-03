package com.servlets;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

import java.util.*;
import java.awt.*;
import java.net.URL;
import com.sun.jimi.core.*;
import com.map.mappingUtils;

public class MapImageWMSServlet extends HttpServlet {

  public void doGet(HttpServletRequest request, HttpServletResponse response)
       throws ServletException, IOException {
    // Instantiate a mappingUtils object
    mappingUtils mappingUtils = new mappingUtils();

    // Get the application (web.xml) configuration parameters
    ServletContext context = getServletContext();

    // Longitude and Latitude bounding box (Upper right (UR) and Lower left (LL))
    // E = Eastings Centre point
    // N = Northings Centre point
    // Z = Zoom (metres per pixel)
    // X = Horizontal image dimention, in pixels
    // Y = Vertical image dimention, in pixels
    // M = Ma layers (comma seperated WMS layers to display)
    double E = (new Double(request.getParameter("E"))).doubleValue();
    double N = (new Double(request.getParameter("N"))).doubleValue();
    double Z = (new Double(request.getParameter("Z"))).doubleValue();
    int X = Integer.parseInt(request.getParameter("X"));
    int Y = Integer.parseInt(request.getParameter("Y"));
    String M = request.getParameter("M");

    // Eastings and Northings UR 
    double EUR = E + ((Z*X)/2);
    double NUR = N + ((Z*Y)/2);

    // lat and long UR
    String latLngUR = mappingUtils.OSRefToLatLng(EUR, NUR);
    StringTokenizer stUR = new StringTokenizer(latLngUR, ",");
    String latUR = stUR.nextToken();
    String lngUR = stUR.nextToken();

    // Eastings and Northings LL 
    double ELL = E - ((Z*X)/2);
    double NLL = N - ((Z*Y)/2);

    // lat and long LL
    String latLngLL = mappingUtils.OSRefToLatLng(ELL, NLL);
    StringTokenizer stLL = new StringTokenizer(latLngLL, ",");
    String latLL = stLL.nextToken();
    String lngLL = stLL.nextToken();

    // === Get Image from URL ===
    // Set the awt headers to headless so they do not conflict with XWindows
    System.getProperties().setProperty("java.awt.headless", "true");
 
    // Create WMS URL:
    // STYLES list needs to mirror the LAYERS list, so there is a STYLE for each LAYER specified. 
    // Though we are using 'STYLES=' to use the default STYLE for each LAYER in the comma seperated list, and
    // therfore does not need to be specified.
    // <wms_base_url>?SERVICE=WMS&VERSION=<wms_version>&REQUEST=GetMap&LAYERS=<m>&STYLES=&SRS=<wms_srs>&BBOX=<bounding box>&WIDTH=<x>&HEIGHT=<y>&FORMAT=image/png
    // Change some things in the URL depending on the version
    String wmsVersion = context.getInitParameter("wms_version");
    String wmsCoordinateType = context.getInitParameter("wms_coordinate_type");
    String mapVersion = "";
    String mapRequest = "";
    String mapSrsCrs = "";
    String mapBBox = "";
    if (wmsVersion.equals("1.3.0")) {
      mapVersion = "VERSION=" + wmsVersion;
      mapRequest = "REQUEST=GetMap";
      mapSrsCrs = "CRS=" + context.getInitParameter("wms_crs");
      // Do we use the Longitude/Lattitude(LL) or Eastings/Northings(EN) for the bounding box
      if (wmsCoordinateType.equals("LL")) {
        mapBBox = "BBOX=" + lngLL + "," + latLL + "," + lngUR + "," + latUR;
      } else if (wmsCoordinateType.equals("EN")) {
        mapBBox = "BBOX=" + ELL + "," + NLL + "," + EUR + "," + NUR;
      }
    } else if (wmsVersion.equals("1.1.1") || wmsVersion.equals("1.1")) {
      mapVersion = "VERSION=" + wmsVersion;
      mapRequest = "REQUEST=GetMap";
      mapSrsCrs = "SRS=" + context.getInitParameter("wms_srs");
      // Do we use the Longitude/Lattitude(LL) or Eastings/Northings(EN) for the bounding box
      if (wmsCoordinateType.equals("LL")) {
        mapBBox = "BBOX=" + lngLL + "," + latLL + "," + lngUR + "," + latUR;
      } else if (wmsCoordinateType.equals("EN")) {
        mapBBox = "BBOX=" + ELL + "," + NLL + "," + EUR + "," + NUR;
      }
    } else if (wmsVersion.equals("1.0")) {
      mapVersion = "WMTEVR=" + wmsVersion;
      mapRequest = "REQUEST=map";
      mapSrsCrs = "SRS=" + context.getInitParameter("wms_srs");
      // For version 1.0 the boundng box point definitions are reversed
      // i.e. latitude, longitude and NOT longitude, latitude
      // Do we use the Longitude/Lattitude(LL) or Eastings/Northings(EN) for the bounding box
      if (wmsCoordinateType.equals("LL")) {
        mapBBox = "BBOX=" + latLL + "," + lngLL + "," + latUR + "," + lngUR;
      } else if (wmsCoordinateType.equals("EN")) {
        mapBBox = "BBOX=" + NLL + "," + ELL + "," + NUR + "," + EUR;
      }
    } else {
      // Default to the 1.3.0 version
      mapVersion = "VERSION=1.3.0";
      mapRequest = "REQUEST=GetMap";
      mapSrsCrs = "CRS=" + context.getInitParameter("wms_crs");
      // Do we use the Longitude/Lattitude(LL) or Eastings/Northings(EN) for the bounding box
      if (wmsCoordinateType.equals("LL")) {
        mapBBox = "BBOX=" + lngLL + "," + latLL + "," + lngUR + "," + latUR;
      } else if (wmsCoordinateType.equals("EN")) {
        mapBBox = "BBOX=" + ELL + "," + NLL + "," + EUR + "," + NUR;
      }
    }
    // The WMS base URL will include the '?' or '?NAME=value&' so no need to add it
    String surl = context.getInitParameter("wms_base_url") +
      mapVersion +
      "&" + mapRequest +
      "&LAYERS=" + M +
      "&STYLES=" +
      "&" + mapSrsCrs +
      "&" + mapBBox +
      "&WIDTH=" + X +
      "&HEIGHT=" + Y +
      "&FORMAT=image/png";
    URL url = new URL(surl);
 
    Image img = Jimi.getImage(url, Jimi.SYNCHRONOUS | Jimi.IN_MEMORY);
  
    // === Turn the image into a Byte array so that it can be streamed to the response output stream ===
    ByteArrayOutputStream bos = new ByteArrayOutputStream();
    try {
      Jimi.putImage("image/png", img, bos);
    } catch (Exception e) {
      // Nothing here
    } finally {
      bos.close();
    }  
    byte[] imageInBytes = bos.toByteArray();
    bos.close();
  
    // === Make the page returned, the image ===
    // Set content type
    response.setContentType("image/png");
  
    // Set content size
    response.setContentLength(imageInBytes.length);
                   
    // get the input and output streams
    ByteArrayInputStream in = new ByteArrayInputStream(imageInBytes);
    OutputStream outs = response.getOutputStream();
                                                   
    // Copy the contents of the file to the output stream
    byte[] buf = new byte[1024];
    int count = 0;
    while ((count = in.read(buf)) >= 0) {
      outs.write(buf, 0, count);
    }
    in.close();
  
    // Close the response
    outs.close();
  }

  public void doPost(HttpServletRequest request, HttpServletResponse response)
       throws ServletException, IOException {
    doGet(request, response);
  }
}
