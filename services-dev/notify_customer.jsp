<%@ page import="java.io.*, java.util.*" %>
<%@ page import="com.utils.helperBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="helperBean" scope="session" class="com.utils.helperBean" />

<%
  String output = "";
  String[] cmd = new String[1];
 
  // CHECK THAT ALL THE PARAMETERS ARE SUPPLIED.
  if ( request.getParameter("complaint_no") != null ) {

    // Find out what OS we are being run on.
    // Use the File.separator as the java.lang.System.getProperties("os.name")
    // will give a number of different names for the various unix and windows
    // versions.
    if (File.separator.equals("/")) {
      // unix
  
      // compose the command string to be executed by the service.
      // MAKE SURE THAT YOU APPEND THE PATH TO THE SCRIPT/EXECUTABLE YOU WISH TO RUN
      // TO LIMIT SECURITY ISSUES OF A USER RUNNING ANY SCRIPT/EXECUTABLE.
      // UNIX: {contender_home}/../bin/cdev {cdev_db} fglgo_email_and_sms {complaint_no} 
      cmd = new String[] {
              request.getParameter("contender_home") + File.separator + ".." + File.separator +
                "bin" + File.separator + "cdev",
              request.getParameter("cdev_db"),
              "fglgo_email_and_sms",
              request.getParameter("complaint_no")
            };
  
    } else if (File.separator.equals("\\")) {
      // windows
  
      // compose the command string to be executed by the service.
      // MAKE SURE THAT YOU APPEND THE PATH TO THE SCRIPT/EXECUTABLE YOU WISH TO RUN
      // TO LIMIT SECURITY ISSUES OF A USER RUNNING ANY SCRIPT/EXECUTABLE.
      // WINDOWS: cmd /c "{contender_home}/bin/cdev.bat {cdev_db} && notify.bat {complaint_no}"
      cmd = new String[] {
              "cmd",
              "/c",
               request.getParameter("contender_home") + File.separator +
                "bin" + File.separator + "cdev.bat " + request.getParameter("cdev_db") + " && " + 
                "fglgo_email_and_sms.bat " + request.getParameter("complaint_no")
            };
  
    }  
  
    // Create the array that will store the environmental variables passed from the URL
    String[] envp = new String[2];
  
    // Populate the String array with the required environment variables.
    envp[0] = "PATH="            + request.getParameter("system_path");
    envp[1] = "CONTENDER_HOME="  + request.getParameter("contender_home");
  
    output = helperBean.runCommand(cmd, envp);
  } else {
    output = "One or more null parameters supplied.";
  }
  
  // Set the output value into the page scope
  pageContext.setAttribute("output", output);
%>

<%-- Return the output message, 'ok' means the command succeeded --%>
<c:out value="${output}" escapeXml="false" />
