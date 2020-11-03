<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.recordBean, com.vsb.systemKeysBean" %>
<%@ page import="com.vsb.loginBean, com.vsb.enfListBean, com.vsb.enfQueryBean" %>
<%@ page import="com.db.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="enfListBean" scope="session" class="com.vsb.enfListBean" />
<jsp:useBean id="enfQueryBean" scope="session" class="com.vsb.enfQueryBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="enfListPageSet" scope="session" class="com.db.PageSet" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfList" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfList" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfListBean" property="all" value="clear" />
    <jsp:setProperty name="enfListBean" property="*" />

    <%-- Clear the previous record --%>
    <jsp:setProperty name="recordBean" property="all" value="clear" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="complaint_no" param="complaint_no" />

    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
      <sql:query>
        SELECT evidence, suspect_ref, action_seq
          FROM comp_enf
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="evidence" />
        <% recordBean.setEnf_list_evidence((String) pageContext.getAttribute("evidence")); %>
        <sql:wasNull>
          <% recordBean.setEnf_list_evidence(""); %>
        </sql:wasNull>
        <sql:getColumn position="2" to="suspect_ref" />
        <% recordBean.setEnf_list_suspect_ref((String) pageContext.getAttribute("suspect_ref")); %>
        <sql:wasNull>
          <% recordBean.setEnf_list_suspect_ref(""); %>
        </sql:wasNull>
        <sql:getColumn position="3" to="action_seq" />
        <% recordBean.setEnf_list_action_seq((String) pageContext.getAttribute("action_seq")); %>
        <sql:wasNull>
          <% recordBean.setEnf_list_action_seq(""); %>
        </sql:wasNull>
      </sql:resultSet>

      <%-- The above evidence text is for v7 contender, v8 contender holds the evidence text --%>
      <%-- in a seperate table called enf_evidence as multiple lines, like complaint text. --%>
      <%-- Find out what version of contender is being run against the database --%>
      <%-- 10/05/2010  TW  Read contender_version from systemKeysBean --%>
      <% String contender_version = systemKeysBean.getContender_version(); %>

      <if:IfTrue cond='<%= contender_version.equals("v8") %>' >
        <%-- get the evidence text --%>
        <%-- The text wil be split into 60 char lines, and there should be a --%>
        <%-- single record for each line. So will need to concatenate them all together --%>
        <sql:query>
          select txt, seq
          from evidence_text
          where complaint_no = '<%= recordBean.getComplaint_no()%>'
          order by seq asc
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="text_line" />
          <sql:wasNotNull>
            <% recordBean.setEnf_list_evidence(recordBean.getEnf_list_evidence() + pageContext.getAttribute("text_line") + "&#013;"); %>
          </sql:wasNotNull>
        </sql:resultSet>

        <%-- get rid of double space characters --%>
        <%
          String tempTextOut = "";
          String lastChar = "";
          String nextChar = "";
          int textLength = recordBean.getEnf_list_evidence().length();
          if (textLength > 0) {
            int i=0;
            int j=1;
            do {
              nextChar = recordBean.getEnf_list_evidence().substring(i,j);
              if (!(lastChar.equals(" ") && nextChar.equals(" "))) {
                tempTextOut = tempTextOut + nextChar;
              }
              lastChar = nextChar;
              i++;
              j++;
            } while (i < textLength);
            recordBean.setEnf_list_evidence(tempTextOut);
          }
        %>
      </if:IfTrue>


      <%-- Get the site_ref --%>
      <sql:query>
        SELECT site_ref 
          FROM comp 
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="site_ref" />
        <% recordBean.setSite_ref((String) pageContext.getAttribute("site_ref")); %>
      </sql:resultSet>

      <%-- Get the site_name_1 --%>
      <sql:query>
        SELECT site_name_1 
          FROM site
         WHERE site_ref = '<%= recordBean.getSite_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="site_name_1" />
        <% recordBean.setSite_name_1((String) pageContext.getAttribute("site_name_1")); %>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con1"/>

    <%-- Reset enf_list_flag --%>
    <% recordBean.setEnf_list_flag("N"); %>

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfListBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="mainMenu" >
  <jsp:setProperty name="enfListBean" property="action" value="" />
  <jsp:setProperty name="enfListBean" property="all" value="clear" />
  <jsp:setProperty name="enfListBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfQuery" >
  <jsp:setProperty name="enfListBean" property="action" value="" />
  <jsp:setProperty name="enfListBean" property="all" value="clear" />
  <jsp:setProperty name="enfListBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="enfList" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Declare the query string variable --%>
    <% String queryString = ""; %>
                       
    <%-- set the number of records per page ( Application variable in web.xml ) --%>
    <% enfListPageSet.setRecordsOnPage(20); %>
    
    <%-- Declare the result set variable --%>
    <% java.sql.ResultSet rs = null; %>
    
    <%-- Connect to the database using the context and datasource --%>
    <% DbSQL connection = new DbSQL(); %>
    <% connection.connect("java:comp/env", "jdbc/pda"); %>
    
    <%-- Create the query string for the inspection list --%>
    <%
       // Add the complaints query
       queryString = "SELECT complaint_no, " +
                            "enf_officer, " +
                            "site_name_1, " +
                            "action_ref, " +
                            "enf_status, " +
                            "do_date, " +
                            "state, " +
                            "action_seq " +
                       "FROM enf_list " +
                      "WHERE (state = 'A' OR state = 'P') " +
                        "AND action_flag = 'N' " +
                        "AND user_name IN (" +
                            "SELECT user_name " +
                              "FROM pda_cover_list " +
                             "WHERE covered_by = '" + loginBean.getUser_name() + "' " +
                        ") "; 
    %>
    
    <%-- Check if the user has added query restrictions from the enforcement query page --%>
    <app:equalsInitParameter name="use_enf_manual_query" match="Y">
      <if:IfTrue cond='<%= !enfQueryBean.getEnf_status().equals("") %>'>
        <% queryString += "AND enf_status = '" + enfQueryBean.getEnf_status() + "'"; %>
      </if:IfTrue>
      <if:IfTrue cond='<%= !enfQueryBean.getEnf_action_code().equals("") %>'>
        <% queryString += "AND action_ref = '" + enfQueryBean.getEnf_action_code() + "'"; %>
      </if:IfTrue>
      <if:IfTrue cond='<%= !enfQueryBean.getEnf_law().equals("") %>'>
        <% queryString += "AND law_ref = '" + enfQueryBean.getEnf_law() + "'"; %>
      </if:IfTrue>
      <if:IfTrue cond='<%= !enfQueryBean.getEnf_offence().equals("") %>'>
        <% queryString += "AND offence_ref = '" + enfQueryBean.getEnf_offence() + "'"; %>
      </if:IfTrue>
      <if:IfTrue cond='<%= !enfQueryBean.getEnf_officer().equals("") %>'>
        <% queryString += "AND enf_officer = '" + enfQueryBean.getEnf_officer() + "'"; %>
      </if:IfTrue>
      <if:IfTrue cond='<%= !enfQueryBean.getEnf_site().equals("") %>'>
        <% queryString += "AND site_name_1 like '%" + enfQueryBean.getEnf_site().toUpperCase() + "%'"; %>
      </if:IfTrue>
      <if:IfTrue cond='<%= enfQueryBean.getIs_due_date_completed() %>'>
        <% queryString += "AND do_date = '" + enfQueryBean.getEnf_due_date() + "'"; %>
      </if:IfTrue>
      <if:IfTrue cond='<%= enfQueryBean.getIs_action_date_completed() %>'>
        <% queryString += "AND action_date = '" + enfQueryBean.getEnf_action_date() + "'"; %>
      </if:IfTrue>
    </app:equalsInitParameter>    
    
    <%
       // order by state, date, sitename
       queryString += "ORDER BY 7, 6, 3";
    %>
    
    <%-- Run a query for road sections--%>
    <% rs = connection.query(queryString); %>
    
    <%-- populate the PageSet from the ResultSet --%>
    <% enfListPageSet.setPageSet(rs, application.getInitParameter("db_date_fmt")); %>
    
    <%-- close the ResultSet and disconnect from the database --%>
    <% rs.close(); %>
    <% connection.disconnect(); %>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfList" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= enfListBean.getAction().equals("Details") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=enfListBean.getComplaint_no() == null ||
                        enfListBean.getComplaint_no().equals("") %>' >
      <jsp:setProperty name="enfListBean" property="error"
        value="Please choose an item." />
      <jsp:forward page="enfListView.jsp" />
    </if:IfTrue>

    <% pageContext.setAttribute("comp_exists", "false"); %>
    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
      <%-- check to see if the selected complaint still exists and --%>
      <%-- is still open. --%>
      <sql:query>
        SELECT complaint_no
          FROM comp
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
           AND date_closed is null
      </sql:query>
      <sql:resultSet id="rset">
        <%-- do nothing --%>
      </sql:resultSet>
      <sql:wasNotEmpty>
        <%-- The complaint exists and is still open --%>
        <% pageContext.setAttribute("comp_exists", "true"); %>
      </sql:wasNotEmpty>
      <sql:wasEmpty>
        <%-- The complaint does not exist or is closed --%>
        <% pageContext.setAttribute("comp_exists", "false"); %>
      </sql:wasEmpty>

      <if:IfTrue cond='<%=((String) pageContext.getAttribute("comp_exists")).trim().equals("false") %>' >
        <%-- delete any occurance of the complaint from the enforcement --%>
        <%-- list table, as it is no longer exists, or is closed. --%>
        <sql:query>
          DELETE FROM enf_list
          WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:execute/>
      </if:IfTrue>

      <%-- get the state of the currently selected item --%>
      <sql:query>
        SELECT state
          FROM enf_list
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
           AND (
                 user_name IN (
                       SELECT user_name
                         FROM pda_cover_list
                        WHERE covered_by = '<%= loginBean.getUser_name() %>'
                 )
               )
           AND (state = 'A' or state = 'P')
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="state" />
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con1"/>

    <if:IfTrue cond='<%=((String) pageContext.getAttribute("comp_exists")).trim().equals("false") %>' >
      <jsp:setProperty name="enfListBean" property="error"
        value="This item no longer exists, or is closed. Please choose another item." />
      <jsp:forward page="enfListView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%=((String) pageContext.getAttribute("state")).trim().equals("P") %>' >
      <jsp:setProperty name="enfListBean" property="error"
        value="This item has already been processed. Please choose another item." />
      <jsp:forward page="enfListView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Set enf_list_flag to indicate to enfEvidence and addUpdateEnforceFunc that --%>
    <%-- we are coming to them via enfList --%>
    <% recordBean.setEnf_list_flag("Y"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfDetails</sess:setAttribute>
    <c:redirect url="enfDetailsScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= enfListBean.getAction().equals("|<<") %>' >
    <% enfListPageSet.first(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="enfListView.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= enfListBean.getAction().equals(">>|") %>' >
    <% enfListPageSet.last(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="enfListView.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= enfListBean.getAction().equals(" < ") %>' >
    <% enfListPageSet.previous(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="enfListView.jsp" />
  </if:IfTrue>

  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= enfListBean.getAction().equals(" > ") %>' >
    <% enfListPageSet.next(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="enfListView.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfListBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfListBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfListBean.getAction().equals("Back") %>' >
    <%-- Reset enf_list_flag --%>
    <% recordBean.setEnf_list_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfListBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfListBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfListView.jsp" />
