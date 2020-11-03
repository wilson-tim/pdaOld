<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, com.vsb.helperBean, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="java.io.IOException, javax.naming.*" %>
<%@ page import="com.vsb.recordBean, com.vsb.loginBean" %>
<%@ page import="com.vsb.avDetailsBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c" %>

<jsp:useBean id="DbUtils"          scope="session" class="com.db.DbUtils" />
<jsp:useBean id="helperBean"       scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean"       scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean"        scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="avDetailsBean" scope="session" class="com.vsb.avDetailsBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addAVFunc" value="false">
  addAVFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addAVFunc">
  <%-- Set up the date variables --%>
  <%
    // Set the default time zone to where we are, as the time zone
    // returned from sco is GMT+00:00 which is fine but doesn't mentioned
    // BST. So the default timezone has to be set to "Europe/London".
    // Any objects which use the timezone (like SimpleDateFormat) will then
    // be using the correct timezone.
    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
    TimeZone.setDefault(dtz);
  
    String date;
    String time;
    String time_h;
    String time_m;
    SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
    SimpleDateFormat formatTime = new SimpleDateFormat("HH:mm");
    SimpleDateFormat formatTime_h = new SimpleDateFormat("HH");
    SimpleDateFormat formatTime_m = new SimpleDateFormat("mm");
  
    Date currentDate = new java.util.Date();
    date = formatDate.format(currentDate);
    time = formatTime.format(currentDate);
    time_h = formatTime_h.format(currentDate);
    time_m = formatTime_m.format(currentDate);
  %>
  
  <%-- Get the next sequence number for the comp_av_hist table --%>
  <%
    String seqString  = recordBean.getAv_last_seq();
    Integer    seqNo  = Integer.valueOf(seqString);
    int        seqInt = seqNo.intValue();
    seqInt++;
    String new_seq_no = String.valueOf(seqInt); 
  %>
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- getting the information for the notify_customer service call --%>
    <% String notify_customer = "N"; %>
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'NOTIFY_CUSTOMER'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="notify_customer" />
      <sql:wasNotNull>
        <% notify_customer = ((String)pageContext.getAttribute("notify_customer")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>

    <%-- Get po_code --%>
    <sql:query>
      SELECT po_code
      FROM pda_user
      WHERE user_name = '<%= loginBean.getUser_name() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="po_code" />
    </sql:resultSet>
  
    <%-- Add the Abandoned Vehicle History --%>
    <sql:query>
      INSERT INTO comp_av_hist (
        complaint_no,
        status_ref,
        seq,
        doa,
        toa_h,
        toa_m,
        username,
        status_date,
        status_time_h,
        status_time_m,
        vehicle_position,
        notes
      ) VALUES (
        <%= recordBean.getComplaint_no() %>,
        '<%= recordBean.getAv_status_ref() %>',
        <%= new_seq_no %>,
        '<%= recordBean.getAv_doa() %>',
        '<%= recordBean.getAv_toa_h() %>',
        '<%= recordBean.getAv_toa_m() %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= recordBean.getAv_position() %>',
        '<%= recordBean.getAv_notes() %>'
      )
    </sql:query>
    <sql:execute />
    
    <%-- Update the Abandoned Vehicles sequence number --%>
    <sql:query>
      UPDATE comp_av
      SET last_seq = <%= new_seq_no %>
      WHERE complaint_no = <%= recordBean.getComplaint_no() %>
    </sql:query>
    <sql:execute />
  
    <%-- Change the stickered date and time if a sticker was added--%>
    <if:IfTrue cond='<%= recordBean.getAv_is_stickered().equals("Y") %>'>
      <%-- 08/07/2010  TW  Check for new inputs from avDetails form --%>
      <%
        String av_stick_date   = date;
        String av_stick_time_h = time_h;
        String av_stick_time_m = time_m;
        if ( !avDetailsBean.getAv_stick_date().equals("") && !avDetailsBean.getAv_stick_time_h().equals("") && !avDetailsBean.getAv_stick_time_m().equals("") ) {
          av_stick_date   = avDetailsBean.getAv_stick_date();
          av_stick_time_h = avDetailsBean.getAv_stick_time_h();
          av_stick_time_m = avDetailsBean.getAv_stick_time_m();
        }
      %>
      <sql:query>
        UPDATE comp_av
        SET date_stickered   = '<%= av_stick_date %>',
            time_stickered_h = '<%= av_stick_time_h %>',
            time_stickered_m = '<%= av_stick_time_m %>'
        WHERE complaint_no = <%= recordBean.getComplaint_no() %>
      </sql:query>
      <sql:execute />
    </if:IfTrue>
    
    <%-- Check to see if the new status closes the complaint, or --%>
    <%--   puts it back on hold --%>
    <% boolean closeComp = false; %>
    <sql:query>
      SELECT closed_yn
        FROM av_status
       WHERE status_ref = '<%= recordBean.getAv_status_ref() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="closed_yn" />
      <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("closed_yn") ) %>'>
        <% pageContext.setAttribute("closed_yn", ""); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("closed_yn")).trim().equals("Y") %>'>
        <% closeComp = true; %>
      </if:IfTrue>
    </sql:resultSet>
  
    <%-- Don't remove the Works Order reference from the complaint if one existed --%>
    <%-- Check to see if there is a current works order reference on the complaint --%>
    <% boolean wo_present = false; %>
    <sql:query>
      SELECT dest_ref
        FROM comp
        WHERE complaint_no = <%= recordBean.getComplaint_no() %>
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="dest_ref" />
      <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("dest_ref") ) %>'>
        <% pageContext.setAttribute("dest_ref", ""); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("dest_ref")).trim().equals("W") %>'>
        <% wo_present = true; %>
      </if:IfTrue>
    </sql:resultSet>
    
    <%-- Set the complaint to Hold --%>
    <if:IfTrue cond='<%= !closeComp %>'>
      <sql:query>
        UPDATE comp
        <%-- SET action_flag = 'H' --%>
        SET action_flag = '<%= recordBean.getAction_flag() %>'
        WHERE complaint_no = <%= recordBean.getComplaint_no() %>
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  
    <%-- Set the diry to Hold --%>
    <if:IfTrue cond='<%= !closeComp %>'>
      <sql:query>
        UPDATE diry
        <%-- SET action_flag = 'H' --%>
        SET action_flag = '<%= recordBean.getAction_flag() %>'
        WHERE source_ref = <%= recordBean.getComplaint_no() %>
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  
    <%-- Close the complaint --%>
    <if:IfTrue cond='<%= closeComp %>'>
      <%-- Works Order not present --%>
      <if:IfTrue cond='<%= !wo_present %>'>
        <%-- Update Comp --%>
        <sql:query>
          UPDATE comp
          SET action_flag = 'N',
            date_closed   = '<%= date %>',
            time_closed_h = '<%= time_h %>',
            time_closed_m = '<%= time_m %>'
          WHERE complaint_no = <%= recordBean.getComplaint_no()%>
        </sql:query>
        <sql:execute />
        <%-- Update Diry --%>
        <sql:query>
          UPDATE diry
          SET action_flag  = 'C',
            dest_flag      = 'C',
            dest_ref       = 0,
            po_code        = '<%= ((String)pageContext.getAttribute("po_code")).trim() %>',
            date_done      = '<%= date %>',
            done_time_h    = '<%= time_h %>',
            done_time_m    = '<%= time_m %>'
          WHERE source_ref = <%= recordBean.getComplaint_no() %>
        </sql:query>
        <sql:execute />      
      </if:IfTrue>
      <%-- Works Order present --%>
      <if:IfTrue cond='<%= wo_present %>'>
        <%-- Update Comp --%>
        <sql:query>
          UPDATE comp
          SET date_closed    = '<%= date %>',
            time_closed_h    = '<%= time_h %>',
            time_closed_m    = '<%= time_m %>'
          WHERE complaint_no = <%= recordBean.getComplaint_no() %>
        </sql:query>
        <sql:execute />
        <%-- Update Diry --%>
        <sql:query>
          UPDATE diry
          SET po_code      = '<%= ((String)pageContext.getAttribute("po_code")).trim() %>',
            date_done      = '<%= date %>',
            done_time_h    = '<%= time_h %>',
            done_time_m    = '<%= time_m %>'
          WHERE source_ref = <%= recordBean.getComplaint_no() %>
        </sql:query>
        <sql:execute />
      </if:IfTrue>

      <%-- Make the notify_customer web service call --%>
      <if:IfTrue cond='<%= notify_customer.equals("Y") %>'>
        <%
          // notify_customer client environmental variables from the java:comp/env
          // JNDI resource.
          // The output of the printing client is the string 'ok' if no errors occur.
          // alternatelly an error message or java exception are returned as strings.
          
          // obtain the initial context, which holds the server/web.xml environment variables.
          Context initCtx = new InitialContext();
          Context envCtx = (Context) initCtx.lookup("java:comp/env");
         
          // Put all values that are going to be used in the <c:import ...> call, into the pageContext
          // So that the <c:import ...> tag can access them. 
          pageContext.setAttribute("notify_service", (String)envCtx.lookup("notify_service"));
          pageContext.setAttribute("contender_home", (String)envCtx.lookup("contender_home"));
          pageContext.setAttribute("system_path", (String)envCtx.lookup("system_path"));
          pageContext.setAttribute("cdev_db", (String)envCtx.lookup("cdev_db"));
          pageContext.setAttribute("COMPLAINT_NO", recordBean.getComplaint_no());
        %>
  
        <%-- Make the web service call, the returned value is stored in the --%>
        <%-- pageContext variable "webPage" --%> 
        <%-- Need to catch the web service call, just incase the service is inaccesible --%>
        <c:catch var="caughtError"> 
          <c:import url="${notify_service}" var="webPage" >
            <c:param name="contender_home" value="${contender_home}" />
            <c:param name="system_path" value="${system_path}" />
            <c:param name="cdev_db" value="${cdev_db}" />
            <c:param name="complaint_no" value="${COMPLAINT_NO}" />
          </c:import>
        </c:catch>
          
        <%
          String returnedValue = "";
          Exception caughtError = (Exception)pageContext.getAttribute("caughtError");
          if (caughtError == null) {
            // No caught error so use value returned from web service. This will be "ok" if
            // everything went ok.
            returnedValue = ((String)pageContext.getAttribute("webPage")).trim();
          } else {
            // There is a caught error so use that value 
            returnedValue = caughtError.toString().trim();
          }
        %>
  
        <%-- Only output an error message --%> 
        <if:IfTrue cond='<%= ! returnedValue.equals("ok") %>'>
          <%
            // Set the output value into the page scope
            pageContext.setAttribute("output", returnedValue);
          %>
          <c:out value="${output}" escapeXml="false" />
        </if:IfTrue>
      </if:IfTrue>

    </if:IfTrue>
  
    <%-- delete any occurance of the complaint from the inspection --%>
    <%-- list table, as it should no longer be accessed. --%>
    <sql:query>
      DELETE FROM insp_list
            WHERE complaint_no = <%= recordBean.getComplaint_no() %>
    </sql:query>
    <sql:execute/>
    
  </sql:statement>
  <sql:closeConnection conn="con1"/>
  
  <% recordBean.setUpdate_text("Y"); %>
</sess:equalsAttribute>
