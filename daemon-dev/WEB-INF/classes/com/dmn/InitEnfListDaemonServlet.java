package com.dmn;

import javax.servlet.ServletException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.PrintWriter;
import java.io.IOException;

import javax.naming.*;
import javax.sql.*;
import java.sql.*;

import com.dmn.EnfListDaemon;

public class InitEnfListDaemonServlet extends HttpServlet {
  private String error = "";
  private DataSource ds = null;
  private EnfListDaemon dmn = new EnfListDaemon();

  // Initialize the daemon: create a dataSource and then start the daemon
  public void init() throws ServletException {
    // Get the JNDI name of the database connection to use
    String dbDataSource = getInitParameter("dataSource");

    // Get a DataSource
    try {
      // obtain the initial context, which holds the server/web.xml environment variables.
      Context initCtx = new InitialContext();
      Context envCtx = (Context) initCtx.lookup("java:comp/env");
      // obtain the datasource from the context
      ds = (DataSource) envCtx.lookup(dbDataSource);
    } catch (NamingException cnfe) {
      error = "NamingException: " + cnfe;
    } catch (Exception e) {
      error = "Exception: An unkown error occurred while getting a DataSource - " + e;
    }

    // make this thread a daemon thread, this means that when the servlet is desroyed the
    // daemon thread will be also
    dmn.setDaemon(true);

    // set the daemon's datasource
    dmn.setDataSource(ds);

    // set the daemon's sleep time
    // Get the JNDI value of the daemon sleep time to use
    String sleepTime = getInitParameter("sleepTime");
    dmn.setSleepTime(sleepTime);
    
    // set the daemon's action
    // Get the JNDI value of the daemon action to use
    String startState = getInitParameter("startState");
    dmn.setAction(startState);
    
    // start the daemon
    dmn.start();
  }
  
  // The doGet() method informs users of the purpose of this servlet
  public void doGet(HttpServletRequest request,
                    HttpServletResponse response)
         throws ServletException, IOException {
    // process request
    String servletPath = request.getServletPath();
    String action = request.getParameter("action");
    // set the daemon's Action if the user supplied an action
    if (action != null) {
      if (action.equals("Pause")) {
        dmn.setAction("pause");
      } else if (action.equals("Run")) {
        dmn.setAction("run");
      }
    }
    
    PrintWriter out;
    String title = "Daemon Servlet";
    // get this servlets name to use in the html form section
    String form = servletPath.substring(servletPath.lastIndexOf("/") + 1);

    response.setContentType("text/html");
    out = response.getWriter();
    out.println("<html><head><title>");
    out.println(title);
    out.println("</title></head><body><form action=\"" + form + "\" method=\"post\">");
    out.println("<b>Initialization servlet for enf_list daemon.</b><br/>");
    if (! error.equals("")) {
      out.println(error + "<br/><br/>");
    } else {
      out.println("<br/>");
    }
    out.println("<input type=\"submit\" name=\"action\" value=\"Pause\">");
    out.println("<input type=\"submit\" name=\"action\" value=\"Run\">");
    out.println("<br/>");
    out.println("<b>Current daemon status: </b>");
    if (dmn.getAction().equals("pause")) {
      out.println("PAUSING");
    } else if (dmn.getAction().equals("run")) {
      out.println("RUNNING");
    }
    out.println("<br/>");
    out.println(dmn.getStatus());
    out.println("</form></body></html>");
    out.close();
  }

  // The doPost() method forwards all requests to the doGet() method
  public void doPost(HttpServletRequest request,
                    HttpServletResponse response)
         throws ServletException, IOException {
    doGet(request, response);
  }
  
  public void destroy() {}

}
