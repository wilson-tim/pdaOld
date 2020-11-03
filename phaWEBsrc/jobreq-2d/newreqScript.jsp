
<%@ page import="com.vsb.newreqBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>

<jsp:useBean id="newreqBean" scope="session" class="com.vsb.newreqBean" />

<%-- Make sure this is the form we are supposed to be on --%>
<sess:equalsAttribute name="form" match="newreq" value="false">
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="newreq" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="newreqBean" property="all" value="clear" />
    <jsp:setProperty name="newreqBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="newreqBean" property="error" value="" />

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="reqform" >
  <jsp:setProperty name="newreqBean" property="action" value="" />
  <jsp:setProperty name="newreqBean" property="all" value="clear" />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="newreq" >
  <%-- New request --%>
  <if:IfTrue cond='<%= newreqBean.getAction().equals("New Request") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
  
    <%-- Valid entry --%>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">reqform</sess:setAttribute>
  	<jsp:forward page="reqformScript.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="newreqView.jsp" />
