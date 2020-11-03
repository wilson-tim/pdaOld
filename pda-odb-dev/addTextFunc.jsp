<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, com.vsb.helperBean" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*, java.io.IOException, javax.naming.*" %>
<%@ page import="com.vsb.defaultDetailsBean, com.vsb.compSampDetailsBean" %>
<%@ page import="com.vsb.woDetailsBean, com.vsb.textBean, com.vsb.conSumDefaultDetailsBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.loginBean, com.vsb.surveyGradingBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"  %>

<jsp:useBean id="conSumDefaultDetailsBean" scope="session" class="com.vsb.conSumDefaultDetailsBean" />
<jsp:useBean id="compSampDetailsBean"      scope="session" class="com.vsb.compSampDetailsBean" />
<jsp:useBean id="defaultDetailsBean"       scope="session" class="com.vsb.defaultDetailsBean" />
<jsp:useBean id="surveyGradingBean"        scope="session" class="com.vsb.surveyGradingBean" />
<jsp:useBean id="recordBean"               scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"               scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="loginBean"                scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="textBean"                 scope="session" class="com.vsb.textBean" />
<jsp:useBean id="woDetailsBean"            scope="session" class="com.vsb.woDetailsBean" />
<jsp:useBean id="DbUtils"                  scope="session" class="com.db.DbUtils" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addTextFunc" value="false">
  addTextFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addTextFunc">
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
  <%-- This has previously been defaulted --%>
  <if:IfTrue cond='<%= recordBean.getComp_action_flag().trim().equals("D") %>' >
    <if:IfTrue cond='<%= recordBean.getDefault_route().equals("conSumDefaultDetails") %>' >
      <if:IfTrue cond='<%= conSumDefaultDetailsBean.getText() == null 
                        || conSumDefaultDetailsBean.getText().equals("") %>' >
        <% text_flag = "N"; %>
      </if:IfTrue>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! recordBean.getDefault_route().equals("conSumDefaultDetails") %>' >
      <if:IfTrue cond='<%= defaultDetailsBean.getText() == null 
                        || defaultDetailsBean.getText().equals("") %>' >
        <% text_flag = "N"; %>
      </if:IfTrue>
    </if:IfTrue>
  </if:IfTrue>
  <%-- This has not previously been defaulted --%>
  <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("D") %>' >
    <%-- A complaint has just been generated for the default --%>
    <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("") %>' >
      <%-- If new complaint is going to be linked to a works order, and it is a --%>
      <%-- Hways statutory item then get the text from woDetails --%>
      <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") && recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service()) %>' >
        <if:IfTrue cond='<%= woDetailsBean.getComp_text() == null || woDetailsBean.getComp_text().equals("") %>' >
          <% text_flag = "N"; %>
        </if:IfTrue>
      </if:IfTrue>
      <if:IfTrue cond='<%= ! (recordBean.getAction_flag().equals("W") && recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service())) %>' >
        <if:IfTrue cond='<%= textBean.getText() == null || textBean.getText().equals("") %>' >
          <% text_flag = "N"; %>
        </if:IfTrue>
      </if:IfTrue>
    </if:IfTrue>
    <%-- the complaint already existed --%>
    <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("") %>' >
      <%-- 07/10/2010  TW  New conditions covering NI195 via Inspect route --%>
      <if:IfTrue cond='<%= recordBean.getDefault_route().equals("surveyAddDefault") %>' >
        <%-- textBean text assigned by surveyAddDefaultScript.jsp --%>
        <if:IfTrue cond='<%= textBean.getText() == null || textBean.getText().equals("") %>' >
          <% text_flag = "N"; %>
        </if:IfTrue>
      </if:IfTrue>
      <if:IfTrue cond='<%= ! recordBean.getDefault_route().equals("surveyAddDefault") %>' >
        <%-- 07/10/2010  TW  This was the original code --%>
        <if:IfTrue cond='<%= compSampDetailsBean.getText() == null 
                          || compSampDetailsBean.getText().equals("") %>' >
          <% text_flag = "N"; %>
        </if:IfTrue>
      </if:IfTrue>
    </if:IfTrue>
  </if:IfTrue>
  <%-- This is a Works Order --%>
  <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("W") %>' >
    <% text_flag = "N"; %>  
  </if:IfTrue>
  
  <%-- Which print should be done once text has been added. --%>
  <% String do_print = "Y"; %>
  <% String print_type = "default"; %>
  <%-- If this has previously been defaulted, check if it has just been credited. --%>
  <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("D") %>' >
    <if:IfTrue cond='<%= defaultDetailsBean.getActionTaken().equals("Credit") 
                      || defaultDetailsBean.getActionTaken().equals("Credit-All") %>' >
      <%-- just been credited so indicate should do a credit print. --%>
      <% print_type = "credit"; %>
    </if:IfTrue>
  </if:IfTrue>
  <%-- A works order has been created --%>
  <if:IfTrue cond='<%= !recordBean.getWo_key().equals("") %>' >
    <% print_type = "worksorder"; %>
  </if:IfTrue>
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
  
    <%-- Get key which says whether to copy comp text to def text --%>
    <% pageContext.setAttribute("comp_to_def", "N"); %>
    <sql:query>
      select c_field
      from keys
      where service_c = '<%= recordBean.getService_c() %>'
      and   keyname = 'COMP_TEXT TO DEFS'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="comp_to_def" />
      <sql:wasNull>
        <% pageContext.setAttribute("comp_to_def", "N"); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("comp_to_def", "Y"); %>
    </sql:wasEmpty>
    
    <%-- Do the text addition stuff here, making sure to check whether --%>
    <%-- to keep the default and complaint in sync --%>
    <%-- define the comp_seq varible --%>
    <% int comp_seq = 1; %>
    <% int default_seq = 1; %>
    <%-- Is there any text to add --%>
    <if:IfTrue cond='<%= text_flag.equals("Y") %>' >
      <%-- The only times we wish to enter the complaint and default text updates is when
           NOT( comp_to_def is set to 'N' AND the default_route is from conSumDefaultDetails)
     If this condition is true, we want to skip this section and only update the defaults
     text --%> 
      <if:IfTrue cond='<%=  ! ((((String)pageContext.getAttribute("comp_to_def")).trim().equals("N")) 
                            && (recordBean.getDefault_route().equals("conSumDefaultDetails"))) %>' >
        <%-- set the comp_seq number value --%>
        <% pageContext.setAttribute("max_comp_seq_no", "0"); %>
        <% comp_seq = 1; %>
        <sql:query>
          select max(seq)
          from comp_text
          where complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="max_comp_seq_no" />
          <sql:wasNull>
            <% pageContext.setAttribute("max_comp_seq_no", "0"); %>
          </sql:wasNull>
        </sql:resultSet>
        <% comp_seq = Integer.parseInt((String)pageContext.getAttribute("max_comp_seq_no")) + 1; %>
    
        <% String tempTextIn = ""; %>
         <%-- This has previously been defaulted --%>
        <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("D") %>' >
          <if:IfTrue cond='<%= recordBean.getDefault_route().equals("conSumDefaultDetails") %>' >
            <%-- get rid of newline and carriage return chars --%>
            <%
              tempTextIn = conSumDefaultDetailsBean.getText();
              tempTextIn = tempTextIn.replace('\n',' ');
              tempTextIn = tempTextIn.replace('\r',' ');
            %>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! recordBean.getDefault_route().equals("conSumDefaultDetails") %>' >
            <%-- get rid of newline and carriage return chars --%>
            <%
              tempTextIn = defaultDetailsBean.getText();
              tempTextIn = tempTextIn.replace('\n',' ');
              tempTextIn = tempTextIn.replace('\r',' ');
            %>
          </if:IfTrue>
        </if:IfTrue>
        <%-- This has not previously been defaulted --%>
        <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("D") %>' >
          <%-- A complaint has just been generated for the default --%>
          <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("") %>' >
            <%-- If new complaint is going to be linked to a works order, and it is a --%>
            <%-- Hways statutory item then get the text from woDetails --%>
            <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") && recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service()) %>' >
              <% tempTextIn = woDetailsBean.getComp_text(); %>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! (recordBean.getAction_flag().equals("W") && recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service())) %>' >
              <% tempTextIn = textBean.getText(); %>
            </if:IfTrue>
            <%-- get rid of newline and carriage return chars --%>
            <%
              tempTextIn = tempTextIn.replace('\n',' ');
              tempTextIn = tempTextIn.replace('\r',' ');
            %>
          </if:IfTrue>
          <%-- The complaint already existed --%>
          <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("") %>' >
            <%-- 07/10/2010  TW  New conditions covering NI195 via Inspect route --%>
            <if:IfTrue cond='<%= recordBean.getDefault_route().equals("surveyAddDefault") %>' >
              <%-- get rid of newline and carriage return chars --%>
              <%-- textBean text assigned by surveyAddDefaultScript.jsp --%>
              <%
                tempTextIn = textBean.getText();
                tempTextIn = tempTextIn.replace('\n',' ');
                tempTextIn = tempTextIn.replace('\r',' ');
              %>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! recordBean.getDefault_route().equals("surveyAddDefault") %>' >
              <%-- 07/10/2010  TW  This was the original code --%>
              <%-- get rid of newline and carriage return chars --%>
              <%
                tempTextIn = compSampDetailsBean.getText();
                tempTextIn = tempTextIn.replace('\n',' ');
                tempTextIn = tempTextIn.replace('\r',' ');
              %>
            </if:IfTrue>
          </if:IfTrue>
        </if:IfTrue>
    
        <%-- The text should be split into 56 char lines, and there should be a --%>
        <%-- single record for each line. --%>
        <%
          String allText = tempTextIn.trim();
          String line;
          int lineIndex;
          boolean flag = true;
          do {
            if (allText.length() <= 56) {
              line = allText;
              flag = false;
            } else {
              lineIndex = allText.lastIndexOf(" ", 56);
              // Space not found so use the whole 56
              if (lineIndex == -1) {
                lineIndex = 56;
              } else {
                lineIndex = lineIndex + 1;
              }
              line = allText.substring(0,lineIndex);
              allText = allText.substring(lineIndex);
            }
    
            // if contractor adding text add << >> to text
            if (recordBean.getDefault_route().equals("conSumDefaultDetails")) {
              line = "<<" + line + ">>";
          }
        %>
            <sql:query>
              insert into comp_text (
                complaint_no,
                seq,
                username,
                doa,
                time_entered_h,
                time_entered_m,
                txt
              ) values (
                '<%= recordBean.getComplaint_no() %>',
                '<%= comp_seq %>',
                '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
                '<%= date %>',
                '<%= time_h %>',
                '<%= time_m %>',
                '<%= DbUtils.cleanString(line) %>'
              )
            </sql:query>
            <sql:execute />
        <%
            comp_seq = comp_seq + 1;
          } while (flag == true);
        %>
    
        <%-- update comp text flag to 'Y' --%>
        <sql:query>
          update comp
          set text_flag = 'Y'
          where complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:execute />
    
        <%-- if the comp_to_def key is set, and a default exists, then clear the default text and copy --%>
        <%-- the complaint text into it --%>
        <%-- If the complaint sent to Hold/Inspect then the default won't exist, so don't need an explict --%>
        <%-- check for a complaint sent to hold/inspect. --%>
        <if:IfTrue cond='<%= ((String)pageContext.getAttribute("comp_to_def")).trim().equals("Y")
                          && !(recordBean.getDefault_no().equals("")) %>' >
          <%-- delete the defaults --%>
           <sql:query>
            delete from defi_nb
            where default_no = '<%= recordBean.getDefault_no() %>'
          </sql:query>
          <sql:execute />
    
          <%
            ArrayList comp_text = new ArrayList();
            ArrayList comp_username = new ArrayList();
            ArrayList comp_doa = new ArrayList();
            ArrayList comp_time_entered_h = new ArrayList();
            ArrayList comp_time_entered_m = new ArrayList();
            int index = 1;
            String value = "";
          %>
          <sql:query>
            select seq, txt, username,
              doa, time_entered_h, time_entered_m
            from comp_text
            where complaint_no = '<%= recordBean.getComplaint_no() %>'
            order by seq
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="def_seq" />
            <% index = Integer.parseInt((String)pageContext.getAttribute("def_seq")); %>
    
            <sql:getColumn position="2" to="txt" />
            <% value = ((String)pageContext.getAttribute("txt")).trim(); %>
            <% comp_text.add(value); %>
    
            <sql:getColumn position="3" to="username" />
            <% value = ((String)pageContext.getAttribute("username")).trim(); %>
            <% comp_username.add(value); %>
    
            <sql:getDate position="4" to="doa" format="<%= application.getInitParameter("db_date_fmt") %>" />
            <% value = ((String)pageContext.getAttribute("doa")).trim(); %>
            <% comp_doa.add(value); %>
    
            <sql:getColumn position="5" to="time_entered_h" />
            <sql:wasNull>
              <% value = ""; %>
            </sql:wasNull>
            <sql:wasNotNull>
              <% value = ((String)pageContext.getAttribute("time_entered_h")).trim(); %>
            </sql:wasNotNull>
            <% comp_time_entered_h.add(value); %>
    
            <sql:getColumn position="6" to="time_entered_m" />
            <sql:wasNull>
              <% value = ""; %>
            </sql:wasNull>
            <sql:wasNotNull>
              <% value = ((String)pageContext.getAttribute("time_entered_m")).trim(); %>
            </sql:wasNotNull>
            <% comp_time_entered_m.add(value); %>
          </sql:resultSet>
    
          <%
            String text_line = "";
            for(int i=0; i < comp_text.size(); i++) {
              text_line = DbUtils.cleanString((String) comp_text.get(i));
          %>
            <sql:query>
              insert into defi_nb (
                default_no,
                item_ref,
                feature_ref,
                seq_no,
                username,
                doa,
                time_entered_h,
                time_entered_m,
                txt
              ) values (
                '<%= recordBean.getDefault_no() %>',
                '<%= recordBean.getItem_ref()%>',
                '<%= recordBean.getFeature_ref()%>',
                '<%= i + 1 %>',
                '<%= DbUtils.cleanString((String) comp_username.get(i)) %>',
                '<%= DbUtils.cleanString((String) comp_doa.get(i)) %>',
                '<%= DbUtils.cleanString((String) comp_time_entered_h.get(i)) %>',
                '<%= DbUtils.cleanString((String) comp_time_entered_m.get(i)) %>',
                '<%= text_line %>'
              )
            </sql:query>
            <sql:execute />
          <%
            }
          %>
          <%-- update defi text flag to 'Y' --%>
          <sql:query>
            update defi
            set text_flag = 'Y'
            where default_no = '<%= recordBean.getDefault_no() %>'
          </sql:query>
          <sql:execute />
        </if:IfTrue>
      </if:IfTrue>
  
      <%-- This section will be run if the default has come from the 'Contractor Summary
           and the COMP_TO_DEF key has been set to 'N'--%>
      <if:IfTrue cond='<%=  ((String)pageContext.getAttribute("comp_to_def")).trim().equals("N") 
                            && recordBean.getDefault_route().equals("conSumDefaultDetails") %>'>
        <%-- set the comp_seq number value --%>

        <% pageContext.setAttribute("max_comp_seq_no", "0"); %>
        <% default_seq = 1; %>
        <sql:query>
          select max(seq_no)
          from defi_nb
          where default_no = '<%= recordBean.getDefault_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="max_def_seq_no" />
          <sql:wasNull>
            <% pageContext.setAttribute("max_def_seq_no", "0"); %>
          </sql:wasNull>
        </sql:resultSet>
        <% default_seq = Integer.parseInt((String)pageContext.getAttribute("max_def_seq_no")) + 1; %>
        <% String tempTextIn = ""; %>
        <%-- get rid of newline and carriage return chars --%>
        <%
          tempTextIn = conSumDefaultDetailsBean.getText();
          tempTextIn = tempTextIn.replace('\n',' ');
          tempTextIn = tempTextIn.replace('\r',' ');
        %>
        <%-- The text should be split into 56 char lines, and there should be a --%>
        <%-- single record for each line. --%>
        <%
          String allText = tempTextIn.trim();
          String line;
          int lineIndex;
          boolean flag = true;
          do {
            if (allText.length() <= 56) {
               line = allText;
              flag = false;
            } else {
              lineIndex = allText.lastIndexOf(" ", 56);
              // Space not found so use the whole 56
              if (lineIndex == -1) {
                lineIndex = 56;
              } else {
                lineIndex = lineIndex + 1;
              }
              line = allText.substring(0,lineIndex);
              allText = allText.substring(lineIndex);
            }
            // if contractor adding text add << >> to text
            line = "<<" + line + ">>";
        %>
            <sql:query>
              INSERT INTO defi_nb(
                default_no,
                item_ref,
                feature_ref,
                seq_no,
                username,
                doa,
                time_entered_h,
                time_entered_m,
                txt
              ) values (
                '<%= recordBean.getDefault_no() %>',
                '<%= recordBean.getItem_ref() %>',
                '<%= recordBean.getFeature_ref() %>',
                '<%= default_seq %>',
                '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
                '<%= date %>',
                '<%= time_h %>',
                '<%= time_m %>',
                '<%= DbUtils.cleanString(line) %>'
              )
            </sql:query>
            <sql:execute />
        <%
            default_seq = default_seq + 1;
          } while (flag == true);
        %>
    
        <%-- update default text flag to 'Y' --%>
        <sql:query>
          UPDATE defi
          SET text_flag = 'Y'
          WHERE default_no = '<%= recordBean.getDefault_no() %>'
        </sql:query>
        <sql:execute />
      </if:IfTrue>
    </if:IfTrue>
  
    <%-- Check if has been previously defaulted and cleared, there are three --%>
    <%-- different routes which could be taken, but they all end up going --%>
    <%-- through clearDefaultFunc which sets the recordBean clearedDefault --%>
    <%-- attribute to "Y". The routes are; --%>
    <%-- (i) route taken via defaultDetailsScript and clearDefaultFunc --%>
    <%-- (ii) route taken via pickFault1Script, addDefaultFunc and clearDefaultFunc --%>
    <%-- (iii) route taken via textScript, addComplaintFunc, addDefaultFunc and clearDefaultFunc --%>
    <%-- If the default has just been cleared, check if should do a print. --%>
    <if:IfTrue cond='<%= recordBean.getClearedDefault().equals("Y") %>' >
      <% pageContext.setAttribute("print_cleared", "N"); %>
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'PRINT_CLEARED_DEF'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="print_cleared" />
        <sql:wasNull>
          <% pageContext.setAttribute("print_cleared", "N"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("print_cleared", "Y"); %>
      </sql:wasEmpty>
  
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("print_cleared")).trim().equals("N") %>' >
        <% do_print = "N"; %>
      </if:IfTrue>
    </if:IfTrue>
  
  </sql:statement>
  <sql:closeConnection conn="con1"/>
  
  <%-- If user only updateing the text, i.e. jumped straight to this Func from --%>
  <%-- compSampDetails or defaultDetails, then don't do any prints. --%>
  <if:IfTrue cond='<%= recordBean.getUpdate_text().equals("Y") %>' >
    <% do_print = "N"; %>
  </if:IfTrue>
  
  <%-- If the complaint was sent to Hold, Inspect or 'No Further Action' then don't do any prints. --%>
  <if:IfTrue cond='<%= recordBean.getAction_flag().equals("H") || recordBean.getAction_flag().equals("I") || recordBean.getAction_flag().equals("N") %>' >
    <% do_print = "N"; %>
  </if:IfTrue>
  
  <%-- If the default has been updated by contractor then don't do any prints. --%>
  <if:IfTrue cond='<%= recordBean.getDefault_route().equals("conSumDefaultDetails") %>' >
    <% do_print = "N"; %>
  </if:IfTrue>
  
  <%-- If this is a Works Order which has been processed from inspList. NOT a new works order --%>
  <%-- NOTE: Works orders are currently not able to be seen in the inspList. --%>
  <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("W") %>' >
    <% do_print = "N"; %>
  </if:IfTrue>

  <%-- If this is a standalone Enforcement which has just been added i.e. the service is the enforcement service, --%>
  <%-- then don't do a print, as there is nothing to print. --%>
  <if:IfTrue cond='<%= recordBean.getEnforce_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getEnf_service()) %>' >
    <% do_print = "N"; %>
  </if:IfTrue>
  
  <%
    //ensure that the printing error status is set to "ok" as no printing occured above.
    recordBean.setPrinting_error("ok");
  %>
  
  <if:IfTrue cond='<%= do_print.equals("Y") %>' >
    <%-- send the contractor notification --%>
    <%
  
      String COMMAND = "";
      String CONTRACT_REF = "";
      String DEFAULT_NO = "";
      String CREDIT_TIME_H = "";
      String CREDIT_TIME_M = "";
      String WO_KEY = "";
      String print_msg = "";
  
      //Build the COMMAND variable with the correct parameters for defaults or credits:
      if(print_type.equals("default"))
      {
        //The default will just have been updated so use the
        //fglgo_def_prnt program to send the notification
        //fglgo_def_prnt 'contract_ref' default_no
  
        COMMAND = "fglgo_def_prnt"; 
        CONTRACT_REF = recordBean.getContract_ref();
        DEFAULT_NO = recordBean.getDefault_no();
        CREDIT_TIME_H = "";
        CREDIT_TIME_M = "";
        WO_KEY = "";
      }
      else if(print_type.equals("credit"))
      {
        //The default will just have been credited so use the
        //fglgo_creditpr program to send the notification
        //fglgo_creditpr 'contract_ref' default_no hours(24) mins
  
        COMMAND = "fglgo_creditpr";
        CONTRACT_REF = recordBean.getContract_ref();
        DEFAULT_NO = recordBean.getDefault_no();
        CREDIT_TIME_H = recordBean.getCredit_time_h();
        CREDIT_TIME_M = recordBean.getCredit_time_m();
        WO_KEY = "";
      }
      else if(print_type.equals("worksorder"))
      {
        //The works order will just have been created so use the
        //fglgo_wo_rep program to send the notification
        //fglgo_wo_rep ?????
  
        COMMAND = "fglgo_wo_rep";
        CONTRACT_REF = recordBean.getWo_contract_ref(); 
        DEFAULT_NO = "";
        CREDIT_TIME_H = "";
        CREDIT_TIME_M = "";
        WO_KEY = recordBean.getWo_key();
      }
  
  
      // Kick off printing client with the environmental variables from the java:comp/env
      // JNDI resource.
      // The output of the printing client is the string 'ok' if no errors occur.
      // alternatelly an error message or java exception are returned as strings.
      
      // obtain the initial context, which holds the server/web.xml environment variables.
      Context initCtx = new InitialContext();
      Context envCtx = (Context) initCtx.lookup("java:comp/env");
     
      // Put all values that are going to be used in the <c:import ...> call, into the pageContext
      // So that the <c:import ...> tag can access them. 
      pageContext.setAttribute("print_service", (String)envCtx.lookup("print_service"));
      pageContext.setAttribute("contender_home", (String)envCtx.lookup("contender_home"));
      pageContext.setAttribute("system_path", (String)envCtx.lookup("system_path"));
      pageContext.setAttribute("cdev_db", (String)envCtx.lookup("cdev_db"));
      pageContext.setAttribute("COMMAND", COMMAND);
      pageContext.setAttribute("CONTRACT_REF", CONTRACT_REF);
      pageContext.setAttribute("DEFAULT_NO", DEFAULT_NO);
      pageContext.setAttribute("CREDIT_TIME_H", CREDIT_TIME_H);
      pageContext.setAttribute("CREDIT_TIME_M", CREDIT_TIME_M);
      pageContext.setAttribute("WO_KEY", WO_KEY);
    %>
  
    <%-- Make the web service call, the returned value is stored in the --%>
    <%-- pageContext variable "webPage" --%> 
    <%-- Need to catch the web service call, just incase the service is inaccesible --%>
    <c:catch var="caughtError"> 
      <c:import url="${print_service}" var="webPage" >
        <c:param name="contender_home" value="${contender_home}" />
        <c:param name="system_path" value="${system_path}" />
        <c:param name="cdev_db" value="${cdev_db}" />
        <c:param name="command" value="${COMMAND}" />
        <c:param name="contract_ref" value="${CONTRACT_REF}" />
        <c:param name="default_no" value="${DEFAULT_NO}" />
        <c:param name="credit_time_h" value="${CREDIT_TIME_H}" />
        <c:param name="credit_time_m" value="${CREDIT_TIME_M}" />
        <c:param name="wo_key" value="${WO_KEY}" />
      </c:import>
    </c:catch>
      
    <%
      String returnedValue = "";
      Exception caughtError = (Exception)pageContext.getAttribute("caughtError");
      if (caughtError == null) {
        // No caught error so use value returned from web service 
        returnedValue = ((String)pageContext.getAttribute("webPage")).trim();
      } else {
        // There is a caught error so use that value 
        returnedValue = caughtError.toString().trim();
      }
      recordBean.setPrinting_error(returnedValue); 
    %>
  </if:IfTrue>
</sess:equalsAttribute>
