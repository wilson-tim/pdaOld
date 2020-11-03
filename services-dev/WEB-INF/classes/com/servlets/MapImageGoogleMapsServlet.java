package com.servlets;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

import java.util.*;
import java.awt.*;
import java.net.URL;
import com.sun.jimi.core.*;
import com.map.mappingUtils;

public class MapImageGoogleMapsServlet extends HttpServlet {

  public void doGet(HttpServletRequest request, HttpServletResponse response)
       throws ServletException, IOException {
    // Instantiate a mappingUtils object
    mappingUtils mappingUtils = new mappingUtils();

    // Get the application (web.xml) configuration parameters
    ServletContext context = getServletContext();

    //Longitude and Latitude
    double E = (new Double(request.getParameter("E"))).doubleValue();
    double N = (new Double(request.getParameter("N"))).doubleValue();
    String latLng = mappingUtils.OSRefToLatLng(E, N); 
  
    StringTokenizer st = new StringTokenizer(latLng, ","); 
    String lat = st.nextToken();
    String lng = st.nextToken();
  
    // === Get Image from URL ===
    // Set the awt headers to headless so they do not conflict with XWindows
    System.getProperties().setProperty("java.awt.headless", "true");
  
    // maptype (Default to "map" type if not supplied
    String mapType = request.getParameter("M");
    if (mapType == null) {
      mapType = "roadmap";
    }
 
    String surl = context.getInitParameter("google_maps_url") +
      "?center=" + lat + "," + lng +
      "&zoom=" + request.getParameter("Z") +
      "&size=" + request.getParameter("X") + "x" + request.getParameter("Y") +
      "&key=" + context.getInitParameter("google_maps_key") +
      "&sensor=" + context.getInitParameter("google_maps_sensor") +
      "&format=png" +
      "&maptype=" + mapType +
      "&markers=" + lat + "," + lng + ",red";
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
