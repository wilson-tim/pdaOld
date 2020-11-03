<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.helperBean, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="java.io.IOException, javax.naming.*" %>
<%@ page import="com.vsb.defaultDetailsBean, com.vsb.recordBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="defaultDetailsBean" scope="session" class="com.vsb.defaultDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="clearDefaultFunc" value="false">
  clearDefaultFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="clearDefaultFunc">
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
  
  <%-- Is there any text to add --%>
  <% String text_flag = "Y"; %>
  <if:IfTrue cond='<%= defaultDetailsBean.getText() == null || defaultDetailsBean.getText().trim().equals("") %>' >
    <% text_flag = "N"; %>
  </if:IfTrue>
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- Add a clear transaction to the already created default header, --%>
    <%-- and close the default and complaint. --%>
   
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

    <%-- get the max seq_no of the defaults transactions --%>
    <sql:query>
      select max(seq_no)
      from deft
      where default_no = '<%= recordBean.getDefault_no()%>'
     </sql:query>
    <sql:resultSet id="rset">
       <sql:getColumn position="1" to="max_seq_no" />
    </sql:resultSet>
    <% int max_seq_no = Integer.parseInt((String)pageContext.getAttribute("max_seq_no")); %>
    
    <%-- assign the seq_no at which to add the clear transaction at --%>
    <% int add_seq_no = max_seq_no + 1; %>
    
    <sql:query>
      select notice_type
      from deft
      where seq_no = '<%= max_seq_no %>'
      and   default_no = '<%= recordBean.getDefault_no()%>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="deft_notice_type" />
    </sql:resultSet>
    
    <%-- adding deft record --%>
    <%-- Create the default item transaction --%>
    <sql:query>
      insert into deft (
        default_no,
        item_ref,
        feature_ref,
        default_level,
        seq_no,
        action_flag,
        trans_date,
        notice_type,
        notice_ref,
        priority_flag,
        points,
        value,
        source_flag,
        source_ref,
        credit_date,
        username,
        po_code,
        time_h,
        time_m,
        default_occ,
        default_sublevel,
        user_initials,
        credit_reason
      ) values (
        '<%= recordBean.getDefault_no() %>',
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getFeature_ref() %>',
        '0',
        <%= add_seq_no %>,
        'C',
        '<%= date %>',
        '<%= ((String)pageContext.getAttribute("deft_notice_type")).trim() %>',
        '<%= recordBean.getDefault_no()%>',
        '<%= recordBean.getPriority() %>',
        '0.00',
        '0.00',
        'D',
        '0',
        null,
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        '',
        '<%= time_h %>',
        '<%= time_m %>',
        '0',
        '',
        '',
        ''
      )
    </sql:query>
    <sql:execute />
    
    <%-- close the default --%>
    <%-- update the defh and defi records --%>
    <sql:query>
      update defh
      set clear_flag = 'N',
        default_status = 'N'
      where cust_def_no = '<%= recordBean.getDefault_no()%>'
    </sql:query>
    <sql:execute />
    
    <sql:query>
      update defi
      set item_status = 'N',
        clear_date = '<%= date %>'
      where default_no = '<%= recordBean.getDefault_no()%>'
    </sql:query>
    <sql:execute />
  
    <%-- Get the diry_ref from the default diry record --%>
    <sql:query>
      select diry_ref
      from diry
      where source_flag = 'D'
      and   source_ref = '<%= recordBean.getDefault_no() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="def_diry_ref" />
    </sql:resultSet>
  
    <%-- Close the default diry record --%>
    <sql:query>
      update diry
      set action_flag = 'C',
        dest_flag = 'C',
        dest_date = '<%= date %>',
        dest_time_h = '<%= time_h %>',
        dest_time_m = '<%= time_m %>',
        dest_user = '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>'
      where diry_ref = '<%= ((String)pageContext.getAttribute("def_diry_ref")).trim() %>'
    </sql:query>
    <sql:execute />
  
    <%-- close the complaint --%>
    <sql:query>
      update comp
      set date_closed = '<%= date %>',
        time_closed_h = '<%= time_h %>',
        time_closed_m = '<%= time_m %>'
      where complaint_no = '<%= recordBean.getComplaint_no()%>'
    </sql:query>
    <sql:execute />

    <%-- delete any occurance of the complaint from the inspection --%>
    <%-- list table, as it has been closed. --%>
    <sql:query>
      delete from insp_list
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:execute/>
   
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

  </sql:statement>
  <sql:closeConnection conn="con1"/>    
  
  <%-- The default has been cleared so set the recordBean clearedDefault --%>
  <%-- attribute to "Y", to indicate this fact to addTextFunc. --%>
  <% recordBean.setClearedDefault("Y"); %>
</sess:equalsAttribute>
