<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.loginBean, com.vsb.conSumWODetailsBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="conSumWODetailsBean" scope="session" class="com.vsb.conSumWODetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="conSumWODetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="conSumWODetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="conSumWODetailsBean" property="all" value="clear" />
    <jsp:setProperty name="conSumWODetailsBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="conSumWODetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="conSumList" >
  <jsp:setProperty name="conSumWODetailsBean" property="action" value="" />
  <jsp:setProperty name="conSumWODetailsBean" property="all" value="clear" />
  <jsp:setProperty name="conSumWODetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="conScheduleList" >
  <jsp:setProperty name="conSumWODetailsBean" property="action" value="" />
  <jsp:setProperty name="conSumWODetailsBean" property="all" value="clear" />
  <jsp:setProperty name="conSumWODetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Clear the textOut field --%>
<% conSumWODetailsBean.setTextOut(""); %>

<%-- Retrieve the record values used in the view --%>
<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <%-- get the conSumWODetails text --%>
  <%-- The text wil be split into 60 char lines, and there should be a --%>
  <%-- single record for each line. So will need to concatenate them all together --%>
  <sql:query>
    SELECT txt, 
           seq
    FROM wo_h_txt
    WHERE wo_ref  = <%= recordBean.getWo_ref() %>
    AND wo_suffix = '<%= recordBean.getWo_suffix() %>'
    ORDER BY seq ASC
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="text_line" />
    <% conSumWODetailsBean.setTextOut(conSumWODetailsBean.getTextOut() + pageContext.getAttribute("text_line") + "&#013;"); %>
  </sql:resultSet>
  
  <%-- get rid of double space characters --%>
  <%
    String tempTextOut = "";
    String lastChar = "";
    String nextChar = "";
    int textLength = conSumWODetailsBean.getTextOut().length();
    if (textLength > 0) {
      int i=0;
      int j=1;
      do {
        nextChar = conSumWODetailsBean.getTextOut().substring(i,j);
        if (!(lastChar.equals(" ") && nextChar.equals(" "))) {
          tempTextOut = tempTextOut + nextChar;
        }
        lastChar = nextChar;
        i++;
        j++;
      } while (i < textLength);
      conSumWODetailsBean.setTextOut(tempTextOut);
    }
  %>  
</sql:statement>
<sql:closeConnection conn="con"/>


<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="conSumWODetails" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= conSumWODetailsBean.getAction().equals("Finish") %>' >
    <%-- get rid of newline and carriage return chars --%>
    <%
      String tempTextIn = conSumWODetailsBean.getText();
      tempTextIn = tempTextIn.replace('\n',' ');
      tempTextIn = tempTextIn.replace('\r',' ');
      
      conSumWODetailsBean.setText(tempTextIn);
    %>
    <%-- Invalid entry --%>
    <%-- make sure the user has selected an action to be performed --%>
    <if:IfTrue cond='<%= conSumWODetailsBean.getActionTaken() == null 
                      || conSumWODetailsBean.getActionTaken().equals("") %>' >
      <jsp:setProperty name="conSumWODetailsBean" property="error"
        value="Please select an action to perform." />
      <jsp:forward page="conSumWODetailsView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= !(conSumWODetailsBean.getActionTaken() == null 
		        || conSumWODetailsBean.getActionTaken().equals("")) %>' >   
      <%-- Goto conSumFunc if the user has selected 'CANCELLED' --%>
      <if:IfTrue cond='<%= (conSumWODetailsBean.getActionTaken().equals("CANCELLED")) 
                          || conSumWODetailsBean.getActionTaken().equals("Not Actioned") %>' >      
        <%-- indicate the route which will be taken to get to addText --%>
        <% recordBean.setDefault_route("conSumWODetails"); %>

        <%-- update worksOrder --%>
        <sess:setAttribute name="form">conSumFunc</sess:setAttribute>
        <c:import url="conSumFunc.jsp" var="webPage" />
        <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

        <%-- add complaint text --%>
        <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
        <c:import url="addTextFunc.jsp" var="webPage" />
        <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

        <%-- run the veolia link if required --%>
        <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
        <c:import url="veoliaLinkFunc.jsp" var="webPage" />
        <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">conSumWODetails</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">updateStatus</sess:setAttribute>
        <c:redirect url="updateStatusScript.jsp" />
      </if:IfTrue>

      <%-- Goto conSumAction if the user selects 'Actioned' --%>
      <if:IfTrue cond='<%= (conSumWODetailsBean.getActionTaken().equals("CLEARED")) %>' >       
        <%-- indicate the route which will be taken to get to addText --%>
        <% recordBean.setDefault_route("conSumWODetails"); %>
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">conSumWODetails</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">conSumDate</sess:setAttribute>
        <c:redirect url="conSumDateScript.jsp" />
      </if:IfTrue>
    </if:IfTrue>
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= conSumWODetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumWODetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= conSumWODetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumWODetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= conSumWODetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumWODetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= conSumWODetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${conSumWODetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="conSumWODetailsView.jsp" />
