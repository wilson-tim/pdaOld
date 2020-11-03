<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectTextBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="enfSuspectTextBean" scope="session" class="com.vsb.enfSuspectTextBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectText" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfSuspectText" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfSuspectTextBean" property="all" value="clear" />
    <jsp:setProperty name="enfSuspectTextBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="sus_text" value='<%= enfSuspectTextBean.getSus_text() %>' />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfSuspectTextBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfSuspectDetails" >
  <jsp:setProperty name="enfSuspectTextBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectTextBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectTextBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfSuspectNewCo" >
  <jsp:setProperty name="enfSuspectTextBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectTextBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectTextBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfSuspectAdd" >
  <jsp:setProperty name="enfSuspectTextBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectTextBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectTextBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfSuspectNew" >
  <jsp:setProperty name="enfSuspectTextBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectTextBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectTextBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfSuspectMarketTrader" >
  <jsp:setProperty name="enfSuspectTextBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectTextBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectTextBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfSuspectMarketTraders" >
  <jsp:setProperty name="enfSuspectTextBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectTextBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectTextBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Clear the textOut field --%>
<% enfSuspectTextBean.setTextOut(""); %>

<%-- Retrieve the record values used in the view if a suspect which already exists has been picked --%>
<if:IfTrue cond='<%= ! recordBean.getSuspect_ref().equals("") %>' >
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
    <%-- get the enfSuspectText text --%>
    <%-- The text wil be split into 60 char lines, and there should be a --%>
    <%-- single record for each line. So will need to concatenate them all together --%>
    <sql:query>
      select txt, seq
      from enf_sus_text
      where suspect_ref = '<%= recordBean.getSuspect_ref()%>'
      order by seq asc
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="text_line" />
      <sql:wasNotNull>
        <% enfSuspectTextBean.setTextOut(enfSuspectTextBean.getTextOut() + pageContext.getAttribute("text_line") + "&#013;"); %>
      </sql:wasNotNull>
    </sql:resultSet>
    
    <%-- get rid of double space characters --%>
    <%
      String tempTextOut = "";
      String lastChar = "";
      String nextChar = "";
      int textLength = enfSuspectTextBean.getTextOut().length();
      if (textLength > 0) {
        int i=0;
        int j=1;
        do {
          nextChar = enfSuspectTextBean.getTextOut().substring(i,j);
          if (!(lastChar.equals(" ") && nextChar.equals(" "))) {
            tempTextOut = tempTextOut + nextChar;
          }
          lastChar = nextChar;
          i++;
          j++;
        } while (i < textLength);
        enfSuspectTextBean.setTextOut(tempTextOut);
      }
    %>
  </sql:statement>
  <sql:closeConnection conn="con"/>
</if:IfTrue>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfSuspectText" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= enfSuspectTextBean.getAction().equals("Add Text") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectText</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">text</sess:setAttribute>
    <c:redirect url="textScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= enfSuspectTextBean.getAction().equals("Finish") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- add/update suspect --%>
    <sess:setAttribute name="form">addUpdateSuspectFunc</sess:setAttribute>
    <c:import url="addUpdateSuspectFunc.jsp" var="webPage" />
    <% helperBean.throwException("addUpdateSuspectFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectText</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfSuspectTextBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectText</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfSuspectTextBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectText</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfSuspectTextBean.getAction().equals("Back") %>' >
    <% recordBean.setSus_text(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectText</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfSuspectTextBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfSuspectTextBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfSuspectTextView.jsp" />
