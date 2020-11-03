<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfFpnRefBean, com.vsb.enfActionBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="java.util.StringTokenizer, javax.naming.Context, javax.naming.InitialContext" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="enfFpnRefBean" scope="session" class="com.vsb.enfFpnRefBean" />
<jsp:useBean id="enfActionBean" scope="session" class="com.vsb.enfActionBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfFpnRef" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfFpnRef" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfFpnRefBean" property="all" value="clear" />
    <jsp:setProperty name="enfFpnRefBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfFpnRefBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfStatus" >
  <jsp:setProperty name="enfFpnRefBean" property="action" value="" />
  <jsp:setProperty name="enfFpnRefBean" property="all" value="clear" />
  <jsp:setProperty name="enfFpnRefBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="enfFpnRef" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
    <%-- Open a connection to the database to help create the view --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
    <%-- Check if we need to generate an FPCN reference for this new action --%>
    <%-- Firstly, check if the action_code is in the list of valid FPCN codes --%>
    <% String fpcn_action_list = ""; %>
    <sql:query>
      select c_field
      from keys
      where keyname = 'ENF_FPCN_ACTION'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="fpcn_action_list" />
      <sql:wasNotNull>
        <% fpcn_action_list = ((String)pageContext.getAttribute("fpcn_action_list")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>
    <% boolean isActionFpcn = false; %>
    <%-- Go through the list and check if any of the action codes match this enforcements aciton code --%>
    <%-- If they do then set the isActionFpcn boolean to true --%>
    <if:IfTrue cond='<%= !fpcn_action_list.equals("") %>'>
      <% 
        StringTokenizer st = new StringTokenizer(fpcn_action_list, ",");
        while (st.hasMoreTokens()) {
          String nextAction = st.nextToken();
          if( nextAction.equals( enfActionBean.getAction_code() ) ) {
            isActionFpcn = true;
          }
        }
      %>
    </if:IfTrue>
    <%-- If the action is not in the FPCN list then we can skip this screen and create/update the enforcemant --%>
    <if:IfTrue cond='<%= !isActionFpcn %>'>
      <%-- add/update action and status --%>
      <sess:setAttribute name="form">addUpdateActionStatusFunc</sess:setAttribute>
      <c:import url="addUpdateActionStatusFunc.jsp" var="webPage" />
      <% helperBean.throwException("addUpdateActionStatusFunc", (String)pageContext.getAttribute("webPage")); %>
    
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">enfFpnRef</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">updateStatus</sess:setAttribute>
      <c:redirect url="updateStatusScript.jsp" />
    </if:IfTrue>
    <%-- If the action is in the FPCN list then we need to generate a new FPN number --%>
    <%-- So, we need to know if the FPN number is being auto-generated or not --%>
    <if:IfTrue cond='<%= isActionFpcn %>'>
      <% boolean isFpcnAutoGenerated = false; %>
      <% String reference_auto = "N"; %>
      <sql:query>
        select reference_auto
        from enf_act
        where action_code = '<%= enfActionBean.getAction_code() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="reference_auto" />
        <sql:wasNotNull>
          <% reference_auto = ((String)pageContext.getAttribute("reference_auto")).trim(); %>
          <%-- Store whether the FPN reference number for this action is auto-generated in the record bean --%>
          <if:IfTrue cond='<%= reference_auto.equals("Y") %>'>
            <% recordBean.setEnf_fpn_autogen_ref("Y"); %>
          </if:IfTrue>
          <if:IfTrue cond='<%= !reference_auto.equals("Y") %>'>
            <% recordBean.setEnf_fpn_autogen_ref("N"); %>
          </if:IfTrue>
        </sql:wasNotNull>
      </sql:resultSet>
    </if:IfTrue>
    </sql:statement>
    <sql:closeConnection conn="con"/>   
  </if:IfTrue>
</sess:equalsAttribute>

<%-- obtain the initial context, which holds the server/web.xml environment variables. --%>
<% Context initCtx = new InitialContext(); %>
<% Context envCtx = (Context) initCtx.lookup("java:comp/env"); %>
  
<%-- Put all values that are going to be used in the <c:import ...> call, into the pageContext --%>
<%-- So that the <c:import ...> tag can access them. --%>
<% pageContext.setAttribute("fpn_service"   , (String)envCtx.lookup("fpn_service"));    %>
<% pageContext.setAttribute("contender_home", (String)envCtx.lookup("contender_home")); %>
<% pageContext.setAttribute("system_path"   , (String)envCtx.lookup("system_path"));    %>
<% pageContext.setAttribute("cdev_db"       , (String)envCtx.lookup("cdev_db"));        %>
<% pageContext.setAttribute("action_code"   , enfActionBean.getAction_code());          %>

<%-- If the fpn reference is auto generated, generate it now and skip the view --%>
<if:IfTrue cond='<%= recordBean.getEnf_fpn_autogen_ref().equals("Y") %>'>
  <%-- Make sure the user has not pressed the 'Back' button after an auto-generated error --%>
  <if:IfTrue cond='<%= !enfFpnRefBean.getAction().equals("Back") %>' >    
    <% pageContext.setAttribute("command", "fglgo_enf_auto_generate_fpn"); %>
    <%-- Make the web service call, the returned value is stored in the --%>
    <%-- pageContext variable "webPage" --%> 
    <%-- Need to catch the web service call, just incase the service is inaccesible --%>
    <c:catch var="caughtError"> 
      <c:import url="${fpn_service}" var="webPage" >
        <c:param name="contender_home" value="${contender_home}" />
        <c:param name="system_path"    value="${system_path}"    />
        <c:param name="cdev_db"        value="${cdev_db}"        />
        <c:param name="command"        value="${command}"        />
        <c:param name="action_code"    value="${action_code}"    />
      </c:import>
    </c:catch>
  
    <%-- Run the fglgo web service --%>
    <% String returnedValue = ""; %>
    <% Exception caughtError = (Exception)pageContext.getAttribute("caughtError"); %>
    <if:IfTrue cond='<%= caughtError == null %>'>
      <%-- No caught error so use value returned from web service --%>
      <% returnedValue = ((String)pageContext.getAttribute("webPage")).trim(); %>
      <%-- Validate auto generated entry --%>
      <if:IfTrue cond='<%= returnedValue.equals("-1") || 
                           returnedValue.equals("-2") ||
                           returnedValue.equals("-3") %>'>
        <jsp:setProperty name="enfFpnRefBean" property="error" value="Unable to auto generate FPN number." />
        <jsp:forward page="enfFpnRefView.jsp" />
      </if:IfTrue>
      <if:IfTrue cond='<%= returnedValue.equals("-4") %>'>
        <jsp:setProperty name="enfFpnRefBean" property="error" value="Unable to auto generate FPN number. FPCN reference format is not configured." />
        <jsp:forward page="enfFpnRefView.jsp" />
      </if:IfTrue>
      <%-- If the return value is not -1,-2,-3 or-4 then we can assume a avlid number has been generated --%>
      <%-- Add the reference number to the record bean --%>
      <% recordBean.setEnf_fpn_ref(returnedValue); %> 

      <%-- add/update action and status --%>
      <sess:setAttribute name="form">addUpdateActionStatusFunc</sess:setAttribute>
      <c:import url="addUpdateActionStatusFunc.jsp" var="webPage" />
      <% helperBean.throwException("addUpdateActionStatusFunc", (String)pageContext.getAttribute("webPage")); %>
    
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">enfFpnRef</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">enfFpnPrint</sess:setAttribute>
      <c:redirect url="enfFpnPrintScript.jsp" />
    </if:IfTrue>
    <if:IfTrue cond='<%= caughtError != null %>'>
      <%-- There is a caught error so use that value and goto the view --%>
      <% returnedValue = caughtError.toString().trim(); %>
      <jsp:setProperty name="enfFpnRefBean" property="error" value="<%= returnedValue %>" />
      <jsp:forward page="enfFpnRefView.jsp" />
    </if:IfTrue>
  </if:IfTrue>
</if:IfTrue>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfFpnRef" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= enfFpnRefBean.getAction().equals("Submit") %>' >    
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= enfFpnRefBean.getFpn_ref().equals("") %>' >
      <jsp:setProperty name="enfFpnRefBean" property="error" value="Please enter a FPN number" />
      <jsp:forward page="enfFpnRefView.jsp" />
    </if:IfTrue>
    
    <%-- Put all values that are going to be used in the <c:import ...> call, into the pageContext --%>
    <%-- So that the <c:import ...> tag can access them. --%>
    <% pageContext.setAttribute("command", "fglgo_enf_user_entered_fpn"); %>
    <% pageContext.setAttribute("fpn_ref", enfFpnRefBean.getFpn_ref());   %>
    
    <%-- Run the fglgo web service --%>
    <%-- Check the FPN reference the user has entered is valid --%>    
    <%-- Make the web service call, the returned value is stored in the --%>
    <%-- pageContext variable "webPage" --%> 
    <%-- Need to catch the web service call, just incase the service is inaccesible --%>
    <c:catch var="caughtError"> 
      <c:import url="${fpn_service}" var="webPage" >
        <c:param name="contender_home" value="${contender_home}" />
        <c:param name="system_path"    value="${system_path}"    />
        <c:param name="cdev_db"        value="${cdev_db}"        />
        <c:param name="command"        value="${command}"        />
        <c:param name="action_code"    value="${action_code}"    />
        <c:param name="fpn_ref"        value="${fpn_ref}"        />
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
    %>
    <%-- If any standard error numbers are thrown (-1,-2,-3,-4,-5,-6,-7,-8) then throw general error --%>
    <if:IfTrue cond='<%= returnedValue.equals("-1") || 
                         returnedValue.equals("-2") ||
                         returnedValue.equals("-3") ||
                         returnedValue.equals("-4") ||
                         returnedValue.equals("-5") ||
                         returnedValue.equals("-6") ||
                         returnedValue.equals("-7") ||
                         returnedValue.equals("-8") 
                      %>' >
      <jsp:setProperty name="enfFpnRefBean" property="error" value="This FPN reference number is not valid." />
      <jsp:forward page="enfFpnRefView.jsp" />
    </if:IfTrue>
    <%-- If neither standard error numbers or 'valid' is returned, display the returned error value.--%>
    <if:IfTrue cond='<%= !returnedValue.equals("-1") &&
                         !returnedValue.equals("-2") &&
                         !returnedValue.equals("-3") &&
                         !returnedValue.equals("-4") &&
                         !returnedValue.equals("-5") &&
                         !returnedValue.equals("-6") &&
                         !returnedValue.equals("-7") &&
                         !returnedValue.equals("-8") &&
                         !returnedValue.equals("valid") %>' >
      <jsp:setProperty name="enfFpnRefBean" property="error" value="<%= returnedValue %>" />
      <jsp:forward page="enfFpnRefView.jsp" />
    </if:IfTrue>
        
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= returnedValue.equals("valid") %>'>      
      <%-- Add the reference number to the record bean --%>
      <% recordBean.setEnf_fpn_ref(enfFpnRefBean.getFpn_ref()); %> 

      <%-- add/update action and status --%>
      <sess:setAttribute name="form">addUpdateActionStatusFunc</sess:setAttribute>
      <c:import url="addUpdateActionStatusFunc.jsp" var="webPage" />
      <% helperBean.throwException("addUpdateActionStatusFunc", (String)pageContext.getAttribute("webPage")); %>
    
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">enfFpnRef</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">enfFpnPrint</sess:setAttribute>
      <c:redirect url="enfFpnPrintScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfFpnRefBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfFpnRef</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfFpnRefBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfFpnRef</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfFpnRefBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfFpnRef</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfFpnRefBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfFpnRefBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfFpnRefView.jsp" />
