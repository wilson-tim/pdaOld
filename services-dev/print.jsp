<%@ page import="java.io.*, java.util.*" %>
<%@ page import="com.utils.helperBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="helperBean" scope="session" class="com.utils.helperBean" />

<%
  String output = "";
  String command = request.getParameter("command");
  //String cmd = "";
  String[] cmd = new String[1];
  
  // CHECK THAT THE command IS ONE OF THE ONES EXPECTED,
  // TO LIMIT SECURITY ISSUES OF A USER RUNNING ANY SCRIPT/EXECUTABLE.
  if ( command != null && (command.equals("fglgo_def_prnt") || command.equals("fglgo_creditpr") || command.equals("fglgo_wo_rep")) ) {
    // Find out what OS we are being run on.
    // Use the File.separator as the java.lang.System.getProperties("os.name")
    // will give a number of different names for the various unix and windows
    // versions.
    if (File.separator.equals("/")) {
      // unix

      // compose the command string to be executed by the service.
      // MAKE SURE THAT YOU APPEND THE PATH TO THE SCRIPT/EXECUTABLE YOU WISH TO RUN
      // TO LIMIT SECURITY ISSUES OF A USER RUNNING ANY SCRIPT/EXECUTABLE.
      // UNIX: {contender_home}/../bin/cdev {cdev_db} {command} {contract_ref} {default_no} PDA
      // UNIX: {contender_home}/../bin/cdev {cdev_db} {command} {contract_ref} {default_no} {credit_time_h} {credit_time_m} PDA
      // UNIX: {contender_home}/../bin/cdev {cdev_db} {command} {contract_ref} {wo_key} PDA
      if ( command.equals("fglgo_def_prnt") ) {
        cmd = new String[] { 
                request.getParameter("contender_home") + File.separator + ".." + File.separator + "bin" + File.separator + "cdev",
                request.getParameter("cdev_db"),
                command,
                request.getParameter("contract_ref"),
                request.getParameter("default_no"),
                "PDA"
              };
      } else if ( command.equals("fglgo_creditpr") ) {
        cmd = new String[] { 
                request.getParameter("contender_home") + File.separator + ".." + File.separator + "bin" + File.separator + "cdev",
                request.getParameter("cdev_db"),
                command,
                request.getParameter("contract_ref"),
                request.getParameter("default_no"),
                request.getParameter("credit_time_h"),
                request.getParameter("credit_time_m"),
                "PDA"
              };
      } else if ( command.equals("fglgo_wo_rep") ) {
        cmd = new String[] { 
                request.getParameter("contender_home") + File.separator + ".." + File.separator + "bin" + File.separator + "cdev",
                request.getParameter("cdev_db"),
                command,
                request.getParameter("contract_ref"),
                request.getParameter("wo_key"),
                "PDA"
              };
      }

    } else if (File.separator.equals("\\")) {
      // windows

      // compose the command string to be executed by the service.
      // MAKE SURE THAT YOU APPEND THE PATH TO THE SCRIPT/EXECUTABLE YOU WISH TO RUN
      // TO LIMIT SECURITY ISSUES OF A USER RUNNING ANY SCRIPT/EXECUTABLE.
      // Also must make sure that the .bat ending is on the command otherwise and error=2 will be
      // thrown, i.e. can't find command
      // WINDOWS: cmd /c "{contender_home}\bin\cdev.bat {cdev_db} && {command}.bat {contract_ref} {default_no} PDA"
      // WINDOWS: cmd /c "{contender_home}\bin\cdev.bat {cdev_db} && {command}.bat {contract_ref} {default_no} {credit_time_h} {credit_time_m} PDA"
      // WINDOWS: cmd /c "{contender_home}\bin\cdev.bat {cdev_db} && {command}.bat {contract_ref} {wo_key} PDA"
      if ( command.equals("fglgo_def_prnt") ) {
        cmd = new String[] {
                "cmd",
                "/c",
                request.getParameter("contender_home") + File.separator + 
                  "bin" + File.separator + "cdev.bat " + request.getParameter("cdev_db") + " && " +
                  command + ".bat" +
                  " '" + request.getParameter("contract_ref") + "' " + request.getParameter("default_no") +
                  " PDA"
              };
      } else if ( command.equals("fglgo_creditpr") ) {
        cmd = new String[] {
                "cmd",
                "/c",
                request.getParameter("contender_home") + File.separator + 
                  "bin" + File.separator + "cdev.bat " + request.getParameter("cdev_db") + " && " +
                  command + ".bat" +
                  " '" + request.getParameter("contract_ref") + "' " + request.getParameter("default_no") +
                  " " + request.getParameter("credit_time_h") + " " + request.getParameter("credit_time_m") +
                  " PDA"
              };
      } else if ( command.equals("fglgo_wo_rep") ) {
        cmd = new String[] {
                "cmd",
                "/c",
                request.getParameter("contender_home") + File.separator + 
                  "bin" + File.separator + "cdev.bat " + request.getParameter("cdev_db") + " && " +
                  command + ".bat" +
                  " '" + request.getParameter("contract_ref") + "' " + request.getParameter("wo_key") +
                  " PDA"
              };
      }

    }  
  
    // Create the array that will store the environmental variables passed from the URL
    String[] envp = new String[2];
  
    // Populate the String array with the required environment variables.
    envp[0] = "PATH="            + request.getParameter("system_path");
    envp[1] = "CONTENDER_HOME="  + request.getParameter("contender_home");
  
    output = helperBean.runCommand(cmd, envp);  
  } else {
    output = "Invalid command supplied: " + command;
  }
  
  // Set the output value into the page scope
  pageContext.setAttribute("output", output);
%>

<%-- Return the output message, 'ok' means the command succeeded --%>
<c:out value="${output}" escapeXml="false" />
