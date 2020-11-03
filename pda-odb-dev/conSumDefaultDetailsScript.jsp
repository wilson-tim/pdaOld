<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.loginBean, com.vsb.conSumDefaultDetailsBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="conSumDefaultDetailsBean" scope="session" class="com.vsb.conSumDefaultDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="conSumDefaultDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="conSumDefaultDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="conSumDefaultDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="conSumDefaultDetailsBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="conSumDefaultDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="conSumList" >
  <jsp:setProperty name="conSumDefaultDetailsBean" property="action" value="" />
  <jsp:setProperty name="conSumDefaultDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="conSumDefaultDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Clear the textOut field --%>
<% conSumDefaultDetailsBean.setTextOut(""); %>

<%-- Retrieve the record values used in the view --%>
<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <%-- get the conSumDefaultDetails text --%>
  <%-- The text wil be split into 60 char lines, and there should be a --%>
  <%-- single record for each line. So will need to concatenate them all together --%>
  <sql:query>
    SELECT txt, seq_no
    FROM defi_nb
    WHERE default_no = '<%= recordBean.getDefault_no()%>'
    ORDER BY seq_no asc
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="text_line" />
    <% conSumDefaultDetailsBean.setTextOut(conSumDefaultDetailsBean.getTextOut() + pageContext.getAttribute("text_line") + "&#013;"); %>
  </sql:resultSet>
  
  <%-- get rid of double space characters --%>
  <%
    String tempTextOut = "";
    String lastChar = "";
    String nextChar = "";
    int textLength = conSumDefaultDetailsBean.getTextOut().length();
    if (textLength > 0) {
      int i=0;
      int j=1;
      do {
        nextChar = conSumDefaultDetailsBean.getTextOut().substring(i,j);
        if (!(lastChar.equals(" ") && nextChar.equals(" "))) {
          tempTextOut = tempTextOut + nextChar;
        }
        lastChar = nextChar;
        i++;
        j++;
      } while (i < textLength);
      conSumDefaultDetailsBean.setTextOut(tempTextOut);
    }
  %>  
</sql:statement>
<sql:closeConnection conn="con"/>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="conSumDefaultDetails" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= conSumDefaultDetailsBean.getAction().equals("Finish") %>' >
    <%-- get rid of newline and carriage return chars --%>
    <%
      String tempTextIn = conSumDefaultDetailsBean.getText();
      tempTextIn = tempTextIn.replace('\n',' ');
      tempTextIn = tempTextIn.replace('\r',' ');
      
      conSumDefaultDetailsBean.setText(tempTextIn);
    %>
    
    <%-- Invalid entry --%>
    <%-- make sure the user has selected an action to be performed --%>
    <if:IfTrue cond='<%= conSumDefaultDetailsBean.getActionTaken() == null 
                      || conSumDefaultDetailsBean.getActionTaken().equals("") %>' >
      <jsp:setProperty name="conSumDefaultDetailsBean" property="error"
        value="Please select an action to perform." />
      <jsp:forward page="conSumDefaultDetailsView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= !(conSumDefaultDetailsBean.getActionTaken() == null 
		        || conSumDefaultDetailsBean.getActionTaken().equals("")) %>' >   
      <%-- Goto conSumFunc if the user has selected 'Unjustified' or 'Not Actioned'--%>
      <if:IfTrue cond='<%= (conSumDefaultDetailsBean.getActionTaken().equals("U")) 
                          || conSumDefaultDetailsBean.getActionTaken().equals("N") %>' >      
        <%-- indicate the route which will be taken to get to addText --%>
        <% recordBean.setDefault_route("conSumDefaultDetails"); %>

        <%-- update default --%>
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
        <sess:setAttribute name="previousForm">conSumDefaultDetails</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">updateStatus</sess:setAttribute>
        <c:redirect url="updateStatusScript.jsp" />
      </if:IfTrue>

      <%-- Goto conSumAction if the user selects 'Actioned' --%>
      <if:IfTrue cond='<%= (conSumDefaultDetailsBean.getActionTaken().equals("A")) %>' >       
        <%-- indicate the route which will be taken to get to addText --%>
        <% recordBean.setDefault_route("conSumDefaultDetails"); %>
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">conSumDefaultDetails</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">conSumDate</sess:setAttribute>
        <c:redirect url="conSumDateScript.jsp" />
      </if:IfTrue>
    </if:IfTrue>
  </if:IfTrue>
    
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= conSumDefaultDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumDefaultDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= conSumDefaultDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumDefaultDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= conSumDefaultDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumDefaultDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= conSumDefaultDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${conSumDefaultDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="conSumDefaultDetailsView.jsp" />
