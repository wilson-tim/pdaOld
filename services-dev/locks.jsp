<%@ page import="java.io.*, java.util.*" %>
<%@ page import="com.utils.helperBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="helperBean" scope="session" class="com.utils.helperBean" />

<%
  // Setup the Application atrributes if they don't exist.
  // This will only happen once, the first time someone tries to access the service.
  if ( application.getAttribute("inUse") == null ) {
    // create the Application attributes
    HashMap hashMapSessionUser = new HashMap();
    HashMap hashMapSessionComplaint_no = new HashMap();
    HashMap hashMapSessionTime = new HashMap();

    application.setAttribute("inUse", "true");
    application.setAttribute("sessionUser", hashMapSessionUser);
    application.setAttribute("sessionComplaint_no", hashMapSessionComplaint_no);
    application.setAttribute("sessionTime", hashMapSessionTime);
    application.setAttribute("inUse", "false");
  }
%>

<%
  // The session timeOut value (1 minute milliseconds)
  long timeOut = Long.parseLong(application.getInitParameter("locksTimeOut"));

  String output = "";
  boolean validInput = false;
  String session_id = request.getParameter("session_id");
  String user_name = request.getParameter("user_name");
  String complaint_no = request.getParameter("complaint_no");
  String func = request.getParameter("func");

  // Check for valid input 
  // CHECK THAT THE func IS NOT NULL
  if ( func != null ) {
    // CHECK THAT THE SPECIFIED func HAS THE CORRECT ARGUMENTS
    if ( func.equals("check") && session_id != null && complaint_no != null ) {
      validInput = true;
    } else if ( func.equals("exist") && complaint_no != null ) {
      validInput = true;
    } else if ( func.equals("list") ) {
      validInput = true;
    } else if ( func.equals("clear") && session_id != null ) {
      validInput = true;
    } else if ( func.equals("add") && session_id != null && user_name != null && complaint_no != null ) {
      validInput = true;
    } else if ( func.equals("refresh") && session_id != null ) {
      validInput = true;
    } else {
      validInput = false;
      output = "Invalid func (" + func + ") or arguments required and none supplied.";
    }
  } else {
    validInput = false;
    output = "No func supplied.";
  }
 
  // If the input is valid (validInput == true) then first refresh session locks and expire
  // any out of date ones and then process the func.
  if ( validInput == true ) {
    HashMap hashMapSessionUser;
    HashMap hashMapSessionComplaint_no;
    HashMap hashMapSessionTime;

    // Refresh and expire locks
    // Check to see if the locks are in use by another user, if they are wait until they aren't
    // or give up after 12 loops (12*250ms=3secs)
    int loops = 0;
    while ( ((String) application.getAttribute("inUse")).equals("true") && loops <= 12 ) {
      // wait 250 miliseconds before trying again
      try {
        java.lang.Thread.currentThread().sleep(250);
      } catch (InterruptedException e) { };

      loops = loops + 1;      
    }

    if ( loops <= 12 ) {
      // Set the locks as in use and then retreive and process the hashMaps
      application.setAttribute("inUse", "true");

      // retrieve and process hashMaps
      hashMapSessionUser = (HashMap) application.getAttribute("sessionUser");
      hashMapSessionComplaint_no = (HashMap) application.getAttribute("sessionComplaint_no");
      hashMapSessionTime = (HashMap) application.getAttribute("sessionTime");

      // create an iterator so we can obtain all the session_id's and then use them
      // to process each of the hashMaps
      long currentMillisecondTime = System.currentTimeMillis();
      Set keys = hashMapSessionTime.keySet();
      Iterator keyIter = keys.iterator();
      while(keyIter.hasNext()) {
        String nextSessionId = (String) keyIter.next();
        long sessionTime = Long.parseLong( (String) hashMapSessionTime.get(nextSessionId) );
        if (currentMillisecondTime - sessionTime > timeOut) {
          // The session has expired so remove it from the three hashMaps
          hashMapSessionUser.remove(nextSessionId);
          hashMapSessionComplaint_no.remove(nextSessionId);
          hashMapSessionTime.remove(nextSessionId);
        }
      }

      // PROCESS func 
      if ( func.equals("check") ) {
        // Returns true if the session_id has a lock on the complaint_no.
        // Returns true if the complaint_no has been locked.
        if ( hashMapSessionComplaint_no.containsKey(session_id) ) {
          if ( ((String)hashMapSessionComplaint_no.get(session_id)).equals(complaint_no) ) {
            output = "true";
          } else {
            output = "false";
          }
        } else {
          output = "false";
        }
      } else if ( func.equals("exist") ) {
        // Returns true if the complaint_no has been locked.
        if ( hashMapSessionComplaint_no.containsValue(complaint_no) ) {
          output = "true";
        } else {
          output = "false";
        }
      } else if ( func.equals("list") ) {
        // Just list the all the complaint_no's and there associated users, session_id's and times
        Set listKeys = hashMapSessionTime.keySet();
        Iterator listKeyIter = listKeys.iterator();
        output = "Current Millisecond Time: " + currentMillisecondTime + "</br>" +
                 "Time Out: " + timeOut + "</br>";
        while(listKeyIter.hasNext()) {
          String nextSessionId = (String) listKeyIter.next();
          String sessionUser = (String) hashMapSessionUser.get(nextSessionId);
          String sessionComplaint_no = (String) hashMapSessionComplaint_no.get(nextSessionId);
          String sessionTime = (String) hashMapSessionTime.get(nextSessionId);
          output = output + "Session Id: " + nextSessionId + 
                            ", User: " + sessionUser + 
                            ", Complaint No.: " + sessionComplaint_no +
                            ", Time: " + sessionTime;
        }
      } else if ( func.equals("clear") ) {
        // remove the lock for the session_id
        hashMapSessionUser.put(session_id, user_name);
        hashMapSessionComplaint_no.put(session_id, complaint_no);
        hashMapSessionTime.put(session_id, String.valueOf(currentMillisecondTime));
        
        output = "true";
      } else if ( func.equals("add") ) {
        // if a user is added who already has a lock on a complaint, then that lock is realeased
        // and the new one added. Each session_id can only have one lock at a time. The commplaint_no
        // cannot be locked by any other session_id.
        
        // check to make sure the complaint_no isn't already locked
        if ( hashMapSessionComplaint_no.containsValue(complaint_no) ) {
          output = "false";
        } else {
          hashMapSessionUser.put(session_id, user_name);
          hashMapSessionComplaint_no.put(session_id, complaint_no);
          hashMapSessionTime.put(session_id, String.valueOf(currentMillisecondTime));
        
          output = "true";
        }
      } else if ( func.equals("refresh") ) {
        // Refresh resets the session_id time with the current time, no need to check if it has expired
        // as that's already been done above.
        if ( hashMapSessionTime.containsKey(session_id) ) {
          hashMapSessionTime.put(session_id, String.valueOf(currentMillisecondTime));

          output = "true";
        } else {
          output = "false";
        }
      }
  
      // replace the hashMaps
      application.setAttribute("sessionUser", hashMapSessionUser);
      application.setAttribute("sessionComplaint_no", hashMapSessionComplaint_no);
      application.setAttribute("sessionTime", hashMapSessionTime);

      // Set the locks as not in use as we have now finished with the haspMaps
      application.setAttribute("inUse", "false");
    } else {
      output = "Cannot obtain resources. Attempt timed out.";
    }
  }
 
  // Set the output value into the page scope
  pageContext.setAttribute("output", output);
%>

<%-- Return the output message. --%>
<c:out value="${output}" escapeXml="false" />
