<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.dbb.SNoBean, com.utils.date.vsbCalendar" %>
<%@ page import="com.vsb.recordBean" %>
<%@ page import="com.vsb.systemKeysBean" %>
<%@ page import="com.vsb.loginBean" %>
<%@ page import="com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="updateEvidenceFunc" value="false">
  updateEvidenceFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="updateEvidenceFunc">
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
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- Find out what version of contender is being run against the database --%>
    <%-- 10/05/2010  TW  Read contender_version from systemKeysBean --%>
    <% String contender_version = systemKeysBean.getContender_version(); %>

    <%-- Create the complaint_no to use --%>
    <% int complaint_no = 0; %>

    <%-- use recordBean complaint_no only if coming from the enfList --%>
    <% complaint_no = Integer.parseInt(recordBean.getComplaint_no()); %>

    <% String evidence = ""; %>
    <if:IfTrue cond='<%= ! recordBean.getEvidence().equals("") %>'>
      <% evidence = recordBean.getEvidence(); %>
    </if:IfTrue>
 
    <sql:query>
      Update comp_enf
      <%-- Evidence is handled differently in v7 and v8 --%>
      <if:IfTrue cond='<%= contender_version.equals("v7") || contender_version.equals("") %>'>
        set evidence = '<%= evidence %>'
      </if:IfTrue>
      <if:IfTrue cond='<%= contender_version.equals("v8") %>'>
        set evidence = null
      </if:IfTrue>
      where complaint_no = '<%= complaint_no %>'
    </sql:query>
    <sql:execute />

    <%-- For Contender v8 add the evidence text if it exists --%>
    <if:IfTrue cond='<%= contender_version.equals("v8") %>' >
      <if:IfTrue cond='<%= ! evidence.equals("") %>'>
        <%-- set the evidence_seq number value --%>
        <% pageContext.setAttribute("max_evidence_seq_no", "0"); %>
        <% int evidence_seq = 1; %>
        <sql:query>
          select max(seq)
          from evidence_text
          where complaint_no = <%= complaint_no %>
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="max_evidence_seq_no" />
          <sql:wasNull>
            <% pageContext.setAttribute("max_evidence_seq_no", "0"); %>
          </sql:wasNull>
        </sql:resultSet>
        <% evidence_seq = Integer.parseInt((String)pageContext.getAttribute("max_evidence_seq_no")) + 1; %>

        <%-- The text should be split into 60 char lines, and there should be a --%>
        <%-- single record for each line. --%>
        <%
          String tempTextIn = "";
          tempTextIn = evidence;
          tempTextIn = tempTextIn.replace('\n',' ');
          tempTextIn = tempTextIn.replace('\r',' ');

          String allText = tempTextIn.trim();
          String line;
          int lineIndex;
          boolean flag = true;
          do {
            if (allText.length() <= 60) {
              line = allText;
              flag = false;
            } else {
              lineIndex = allText.lastIndexOf(" ", 60);
              // Space not found so use the whole 60
              if (lineIndex == -1) {
                lineIndex = 60;
              } else {
                lineIndex = lineIndex + 1;
              }
              line = allText.substring(0,lineIndex);
              allText = allText.substring(lineIndex);
            }
          %>
            <sql:query>
              insert into evidence_text (
                complaint_no,
                seq,
                username,
                doa,
                time_entered_h,
                time_entered_m,
                txt
              ) values (
                <%= complaint_no %>,
                <%= evidence_seq %>,
                '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
                '<%= date %>',
                '<%= time_h %>',
                '<%= time_m %>',
                '<%= DbUtils.cleanString(line) %>'
              )
            </sql:query>
            <sql:execute />
        <%
            evidence_seq = evidence_seq + 1;
          } while (flag == true);
        %>
      </if:IfTrue>
    </if:IfTrue>
 
  </sql:statement>
  <sql:closeConnection conn="con1"/>

  <%-- ensure that the printing error status is set to "ok" as no printing occured. --%>
  <% recordBean.setPrinting_error("ok"); %>
</sess:equalsAttribute>
