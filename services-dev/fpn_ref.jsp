<%@ page import="java.io.*, java.util.*" %>
<%@ page import="com.utils.helperBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="helperBean" scope="session" class="com.utils.helperBean" />

<%
  String output         = "";
  String[] cmd          = new String[1];
  String command        = "";
  String contender_home = "";
  String cdev_db        = "";
  String action_code    = "";
  String fpn_ref        = "";
  String system_path    = "";
  String error          = "";
  boolean isCheck       = false;
  boolean isError       = false;

  // Validate all the variables used in the script
  if( request.getParameter("command") != null || !request.getParameter("command").equals("") ) {
    command = request.getParameter("command");
    if( !command.equals("fglgo_enf_auto_generate_fpn") && !command.equals("fglgo_enf_user_entered_fpn") ) {
      isError = true;
      error = "Invalid command.";
    } else {
      if( command.equals("fglgo_enf_user_entered_fpn") ) {
        if( request.getParameter("fpn_ref") != null ) {
          fpn_ref = request.getParameter("fpn_ref");
          isCheck = true;
        } else {
          isError = true;
          error = "Variable 'fpn_ref' is either null or blank.";
        }
      }
    }
  } else {
    isError = true;
    error = "Variable command is either null or blank.";
  }  
  if( request.getParameter("contender_home") != null || !request.getParameter("contender_home").equals("") ) {
    contender_home = request.getParameter("contender_home");
  } else {
    isError = true;
    error = "System varaible 'contender_home' has not been defined.";
  }
  if( request.getParameter("cdev_db") != null ) {
    cdev_db = request.getParameter("cdev_db");
  } else {
    isError = true;
    error = "System varaible 'cdev_db' has not been defined.";
  }
  if( request.getParameter("action_code") != null ) {
    action_code = request.getParameter("action_code");
  } else {
    isError = true;
    error = "Variable 'action_code' is either null or blank.";
  }
  if( request.getParameter("system_path") != null ) {
    system_path = request.getParameter("system_path");
  } else {
    isError = true;
    error = "System varaible 'system_path' has not been defined";
  }

  // If an error has occured do not attempt to run the command
  if( !isError ) {
    // Find out what OS we are being run on.
    // Use the File.separator as the java.lang.System.getProperties("os.name")
    // will give a number of different names for the various unix and windows
    // versions.
    if (File.separator.equals("/")) {
      // UNIX
      // compose the command string to be executed by the service.
      // MAKE SURE THAT YOU APPEND THE PATH TO THE SCRIPT/EXECUTABLE YOU WISH TO RUN
      // TO LIMIT SECURITY ISSUES OF A USER RUNNING ANY SCRIPT/EXECUTABLE.
      // UNIX: {contender_home}/../bin/cdev {cdev_db} fglgo_enf_auto_generate_fpn {action_code}
      // /usr/universe/v7/../bin/cdev camdenv7 fglgo_enf_auto_generate_fpn FPN
      if( command.equals("fglgo_enf_user_entered_fpn") ) {
        cmd = new String[] { 
                contender_home + File.separator + ".." + File.separator + "bin" + File.separator + "cdev",
                cdev_db,
                "fglgo_enf_user_entered_fpn",
                action_code,
                fpn_ref
        };
      } else if( command.equals("fglgo_enf_auto_generate_fpn") ) {
        cmd = new String[] { 
                contender_home + File.separator + ".." + File.separator + "bin" + File.separator + "cdev",
                cdev_db,
                "fglgo_enf_auto_generate_fpn",
                action_code
        };
      }
    } else if (File.separator.equals("\\")) {
      // windows
  
      // compose the command string to be executed by the service.
      // MAKE SURE THAT YOU APPEND THE PATH TO THE SCRIPT/EXECUTABLE YOU WISH TO RUN
      // TO LIMIT SECURITY ISSUES OF A USER RUNNING ANY SCRIPT/EXECUTABLE.
      // Also must make sure that the .bat ending is on the command otherwise and error=2 will be
      // thrown, i.e. can't find command
      // WINDOWS: cmd /c "{contender_home}\bin\cdev.bat {cdev_db} && fglgo_enf_auto_generate_fpn.bat {action_code}"
      if( command.equals("fglgo_enf_user_entered_fpn") ) {
        cmd = new String[] {
                "cmd",
                "/c",
                contender_home + File.separator + 
                  "bin" + File.separator + "cdev.bat " + cdev_db + " && " +
                  "fglgo_enf_user_entered_fpn.bat " + action_code + " " + fpn_ref
        };
      } else if( command.equals("fglgo_enf_auto_generate_fpn") ) {
        cmd = new String[] {
                "cmd",
                "/c",
                contender_home + File.separator + 
                  "bin" + File.separator + "cdev.bat " + cdev_db + " && " +
                  "fglgo_enf_auto_generate_fpn.bat " + action_code
        };
      }
    }  
  
    // Create the array that will store the environmental variables passed from the URL
    String[] envp = new String[2];
  
    // Populate the String array with the required environment variables.
    envp[0] = "PATH="            + system_path;
    envp[1] = "CONTENDER_HOME="  + contender_home;
  
    output = helperBean.runOutputCommand(cmd, envp);

    // Set the output value into the page scope
    pageContext.setAttribute("output", output);
    
  } else {
    // Set the error output value into the page scope
    pageContext.setAttribute("output", error);
  }
  
%>

<%-- Return the output message, 'ok' means the command succeeded --%>
<c:out value="${output}" escapeXml="false" />
