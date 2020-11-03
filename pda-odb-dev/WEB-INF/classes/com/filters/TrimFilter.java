package com.filters;

import javax.servlet.http.HttpServletResponseWrapper;
import javax.servlet.http.*;
import javax.servlet.*;
import java.io.*;
import java.util.*;

public final class TrimFilter implements Filter {
   private FilterConfig filterConfig = null;
   
   public void init(FilterConfig filterConfig) 
      throws ServletException {
      this.filterConfig = filterConfig;
   }
   public void destroy() {
      this.filterConfig = null;
   }
   public void doFilter(ServletRequest request,
      ServletResponse response,
      FilterChain chain) 
      throws IOException, ServletException {
        
    if (filterConfig == null) {
      return;
    }

    // Get the response writer before doing the chain
    PrintWriter out = response.getWriter();

    // Create the wrapper response object
    CharResponseWrapper wrapper = new CharResponseWrapper( (HttpServletResponse)response );

    // Get the Content MIME Type of the request so we can see if we are requesting a JSP or not.
    // We only want to do the removal of the blank lines if the request is for a JSP.
    String contentType = request.getContentType();
    
    // Here is where we do the nested filter chain call with our response
    // wrapper so that the filters further down the chain, and the servlet at
    // the end, does not close the response.
    chain.doFilter(request, wrapper);
  
    // Removes white space from both ends of the response
    String stringResp = wrapper.toString().trim();

    // Find the line delimiter
    String delim = "";
    if (stringResp.indexOf("\r\n") > 0) {
      // Windows
      delim = "\r\n";
    } else if (stringResp.indexOf("\r") > 0) {
      // Mac
      delim = "\r";
    } else if (stringResp.indexOf("\n") > 0) {
      // Linux
      delim = "\n";
    } else {
      // Linux
      delim = "\n";
    }

    // Remove the blank lines
    StringBuffer sb = new StringBuffer();
    StringTokenizer st  = new StringTokenizer(stringResp, delim);
    while (st.hasMoreTokens()) {
      String token = st.nextToken();
      // Check that the line is not blank
      if( ! token.trim().equals("") ) {
        sb.append( token );
        sb.append( delim );
      }
    }
    String trimmedResp = sb.toString();

    // Set the size of the response
    response.setContentLength(trimmedResp.length());

    // Wite out the response
    out.write(trimmedResp);

    // Close the response PrintWriter
    out.close();
  }
}
