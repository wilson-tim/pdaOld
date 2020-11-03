<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfDetailsBean, com.vsb.enfActionBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="enfDetailsBean" scope="session" class="com.vsb.enfDetailsBean" />
<jsp:useBean id="enfActionBean" scope="session" class="com.vsb.enfActionBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="enfDetailsBean" property="*" />

    <%-- only do if there is an action for this enforcement --%>
    <if:IfTrue cond='<%= ! recordBean.getEnf_list_action_seq().equals("") %>' >
      <% recordBean.setEnf_list_action_code(""); %>
      <% recordBean.setEnf_list_status_code(""); %>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con1">
        <sql:query>
          SELECT action_ref, enf_status
            FROM enf_action 
          WHERE action_seq = '<%= recordBean.getEnf_list_action_seq() %>'
          AND complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="action_ref" />
          <sql:wasNotNull>
            <% recordBean.setEnf_list_action_code(((String)pageContext.getAttribute("action_ref")).trim()); %>
          </sql:wasNotNull>

          <sql:getColumn position="2" to="enf_status" />
          <sql:wasNotNull>
            <% recordBean.setEnf_list_status_code(((String)pageContext.getAttribute("enf_status")).trim()); %>
          </sql:wasNotNull>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con1"/>
    </if:IfTrue>

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfList" >
  <jsp:setProperty name="enfDetailsBean" property="action" value="" />
  <jsp:setProperty name="enfDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="enfDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="updateStatus" >
  <jsp:setProperty name="enfDetailsBean" property="action" value="" />
  <jsp:setProperty name="enfDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="enfDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Clear the textOut field --%>
<% enfDetailsBean.setTextOut(""); %>

<%-- Retrieve the record values used in the view --%>
<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <%-- get the enfDetails text --%>
  <%-- The text wil be split into 60 char lines, and there should be a --%>
  <%-- single record for each line. So will need to concatenate them all together --%>
  <sql:query>
    select txt, seq
    from comp_text
    where complaint_no = '<%= recordBean.getComplaint_no()%>'
    order by seq asc
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="text_line" />
    <sql:wasNotNull>
      <% enfDetailsBean.setTextOut(enfDetailsBean.getTextOut() + pageContext.getAttribute("text_line") + "&#013;"); %>
    </sql:wasNotNull>
  </sql:resultSet>
  
  <%-- get rid of double space characters --%>
  <%
    String tempTextOut = "";
    String lastChar = "";
    String nextChar = "";
    int textLength = enfDetailsBean.getTextOut().length();
    if (textLength > 0) {
      int i=0;
      int j=1;
      do {
        nextChar = enfDetailsBean.getTextOut().substring(i,j);
        if (!(lastChar.equals(" ") && nextChar.equals(" "))) {
          tempTextOut = tempTextOut + nextChar;
        }
        lastChar = nextChar;
        i++;
        j++;
      } while (i < textLength);
      enfDetailsBean.setTextOut(tempTextOut);
    }
  %>
</sql:statement>
<sql:closeConnection conn="con"/>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="enfDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfDetails" >
  <%-- get rid of newline and carriage return chars --%>
  <%
    String tempTextIn = enfDetailsBean.getText();
    tempTextIn = tempTextIn.replace('\n',' ');
    tempTextIn = tempTextIn.replace('\r',' ');
    
    enfDetailsBean.setText(tempTextIn);
  %>
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= enfDetailsBean.getAction().equals("Update Text") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= enfDetailsBean.getText().equals("") %>' >
      <jsp:setProperty name="enfDetailsBean" property="error"
        value="Please supply additional text." />
      <jsp:forward page="enfDetailsView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- add enforcement text --%>
    <sess:setAttribute name="form">addEnforceTextFunc</sess:setAttribute>
    <c:import url="addEnforceTextFunc.jsp" var="webPage" />
    <% helperBean.throwException("addEnforceTextFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= enfDetailsBean.getAction().equals("Update Evidence") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfEvidence</sess:setAttribute>
    <c:redirect url="enfEvidenceScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= enfDetailsBean.getAction().equals("Add/Update Suspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <% recordBean.setSuspect_flag("Y"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfSuspectMain</sess:setAttribute>
    <c:redirect url="enfSuspectMainScript.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= enfDetailsBean.getAction().equals("Update Status") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Need to make sure that enfActionBean.getAction_code() is blank as no action is being added --%>
    <%-- only the status changed --%>
    <% enfActionBean.setAction_code(""); %> 
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfStatus</sess:setAttribute>
    <c:redirect url="enfStatusScript.jsp" />
  </if:IfTrue>

  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= enfDetailsBean.getAction().equals("Add Action") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfAction</sess:setAttribute>
    <c:redirect url="enfActionScript.jsp" />
  </if:IfTrue>

  <%-- Next view 6 --%>
  <if:IfTrue cond='<%= enfDetailsBean.getAction().equals("Attachments") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfAttachments</sess:setAttribute>
    <c:redirect url="enfAttachmentsScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfDetailsView.jsp" />
