package com.servlets;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

import javax.xml.soap.*;
import java.net.URL;
import org.w3c.dom.NodeList;
import org.apache.axis.encoding.Base64;
import com.ws.CartologySOAP;
import com.utils.helperBean;

public class MapImageCartologyServlet extends HttpServlet {

  public void doGet(HttpServletRequest request, HttpServletResponse response)
       throws ServletException, IOException {
    // Instantiate a helperBean and CartologySOAP objects
    helperBean helperBean = new helperBean();
    CartologySOAP CartologySOAP = new CartologySOAP();

    // Get the application (web.xml) configuration parameters
    ServletContext context = getServletContext();

    String XWorldCenter = request.getParameter("E");
    String YWorldCenter = request.getParameter("N");
    String Zoom = request.getParameter("Z");
    String Xsize = request.getParameter("X");
    String Ysize = request.getParameter("Y");

    CartologySOAP.setXmlNamespace(context.getInitParameter("cart_ns"));
    CartologySOAP.setEndpoint(context.getInitParameter("cart_ep"));
    boolean booleanResult;
    String stringResult;
    byte[] byteResult = null;

    // === Login ===
    try {
      booleanResult = CartologySOAP.Login(context.getInitParameter("cart_username"), context.getInitParameter("cart_password"));
    } catch (Exception e) {
      // Nothing here
    }

    // === GetImage ===
    try {
      byteResult = CartologySOAP.GetImage("", context.getInitParameter("cart_workspace"), Xsize, Ysize, context.getInitParameter("cart_bpp"), XWorldCenter, YWorldCenter, Zoom, context.getInitParameter("cart_file_type"), context.getInitParameter("cart_quality"));
    } catch (Exception e) {
      // Nothing here
    }

    // Add the cross-hairs to the image
    byte[] imageInBytes = helperBean.drawCrossHair( byteResult, Xsize, Ysize );
 
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
