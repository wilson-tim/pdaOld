<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyBean, com.db.DbUtils" %>
<%@ page import="com.vsb.recordBean, com.vsb.loginBean, com.vsb.helperBean " %>
<%@ page import="java.util.Iterator, java.util.ArrayList " %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c" %>

<jsp:useBean id="surveyBean" scope="session" class="com.vsb.surveyBean" />
<jsp:useBean id="loginBean"  scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="doorstepSurvey" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="doorstepSurvey" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data -----------------------------------%>
    <%
      surveyBean.setAll("clear_answers");
      // 06/07/2010  TW  ENTER keypress with cursor in TEXT input box causes NPE
      // surveyBean.setAction( request.getParameter("action") );
      if (request.getParameter("action") == null) {
        surveyBean.setAction( "Back" );
      } else {
        surveyBean.setAction( request.getParameter("action") );
      }
      // Get the iterator for the question id's
      Iterator qIdIterator = surveyBean.getKeyIterator();
      // Store the answers submitted by the user
      while( qIdIterator.hasNext() ){
        String qId = (String)qIdIterator.next();
        if( surveyBean.getQuestion_type( qId ).equals("CHECK")){
          String[] answers = request.getParameterValues( qId );
          surveyBean.addAnswer( qId, answers );
        } else {
          String answer_text = request.getParameter( qId );
          surveyBean.addAnswer( qId, (new String[]{ answer_text }) );
        }//end if/else
      }//end while
      //surveyBean.print();
    %>
    <%--------------------------End of code block------------------------------%>

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="surveyBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="faultLookup" >
  <jsp:setProperty name="surveyBean" property="action" value="" />
  <jsp:setProperty name="surveyBean" property="all" value="clear" />
  <jsp:setProperty name="surveyBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="doorstepSurvey" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
    <%-- Open a connection to get the questions for the survey--%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <%-- Each question has a different type RADIO; CHECK; TEXT; NUMBER; YESNO; --%>
      <sql:query>
        SELECT question_ref,
               question_text,
               question_seq,
               question_type,
               question_valid,
               question_comp_code,
               question_dp
        FROM monitor_question
        <%-- 29/06/2010  TW  the doorstep fault code may be a comma delimited list of fault codes --%>
        WHERE question_comp_code IN (<%= helperBean.quoteCommaList(recordBean.getDoorstep_fault_code()) %>)
        AND question_comp_code = '<%= recordBean.getFault_code() %>'
        ORDER BY question_seq
      </sql:query>
      <%-- Depending on the question_type returned we will generate form items that --%>
      <%-- corespond to those types --%>
      <sql:resultSet id="rsetlist">
      
        <%-- Get the questions reference number --%>
        <sql:getColumn position="1" to="question_ref" />
        <% String question_ref = ((String)pageContext.getAttribute("question_ref")).trim(); %>
        <%-- Get the answers variable --%>
        <sql:getColumn position="2" to="question_text" />
        <% String question_text = ((String)pageContext.getAttribute("question_text")).trim(); %>
        <%-- Get the questions sequence number --%>
        <sql:getColumn position="3" to="question_seq" />
        <% String question_seq = ((String)pageContext.getAttribute("question_seq")).trim(); %>
        <%-- Get the questions type --%>
        <sql:getColumn position="4" to="question_type" />
        <% String question_type = ((String)pageContext.getAttribute("question_type")).trim(); %>
        <%-- Get the question validiation value --%>
        <sql:getColumn position="5" to="question_valid" />
        <% String question_valid = ((String)pageContext.getAttribute("question_valid")).trim(); %>
        <%-- Get the questions comp_code --%>
        <sql:getColumn position="6" to="question_comp_code" />
        <% String question_comp_code = ((String)pageContext.getAttribute("question_comp_code")).trim(); %>
        <%-- Get the questions question_dp --%>
        <sql:getColumn position="7" to="question_dp" />
        <% String question_dp = ""; %>
        <sql:wasNotNull>
          <% question_dp = ((String)pageContext.getAttribute("question_dp")).trim(); %>
        </sql:wasNotNull>
        
        <%-- Create the inputs unique id string --%>
        <%-- "COMP_CODE" + "|" + "question_sequence_number" --%>
        <% String id = question_comp_code + "|" + question_seq; %>

        <%-- Add the question to the bean so it can be used by the script --%>
        <%-- This will help us avoid another query to the DB for the same --%>
        <%-- Information. The bean handles all the marshaling of data --%>
        <% surveyBean.addQuestion( id, 
                                         question_ref, 
                                         question_text, 
                                         question_seq, 
                                         question_type, 
                                         question_valid,
                                         question_comp_code,
                                         question_dp ); 
        %>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>    
    <%-- End of sql statement, closed connection --%>    
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Reset the action flag in case we have come back --%>
<% recordBean.setAction_flag(""); %>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="doorstepSurvey" >
  
  <%-- Next view --%>
  <if:IfTrue cond='<%= surveyBean.getAction().equals("Add " + application.getInitParameter("def_name_noun"))||
                       surveyBean.getAction().equals("Close as Comp")  %>' >
    <%---------------------- Depedancy Check --------------------------------%>
    <%-- Run through the questions and check to see that all the           --%>
    <%-- dependancies are correct and valid                                --%>
    <%-- Get the iterator for the question id's -----------------------------%>
    <% Iterator dependIdIterator = surveyBean.getKeyIterator();              %>
    <%-- Run through the questions one by one and call the checkDependancy --%>
    <%-- method                                                            --%>
    <% while( dependIdIterator.hasNext() ){                                  %>
    <%   String qId = (String)dependIdIterator.next();                       %>
    <%   if( !surveyBean.checkDependancy( qId ) ){                           %>
    <%     if( surveyBean.hasAnswer( qId ) ){                                %>
    <%       surveyBean.clearAnswer( qId );                                  %>
             <jsp:setProperty name="surveyBean" property="error"
                              value='<%= "Q" 
                                    + surveyBean.getQuestion_dp( qId )
                                    + "<br/>Must be checked in order to answer Q"
                                    + surveyBean.getQuestion_seq( qId )%>' 
             />             
             <jsp:forward page="doorstepSurveyView.jsp" />              
    <%     }//end if                                                         %>
    <%   }else{                                                              %>
    <%     if( !surveyBean.isValid( qId ) ){                                 %>
    <%       String error_text = "Q" + surveyBean.getQuestion_seq( qId ) + ") " + surveyBean.getQuestion_text( qId ) + "<br/>Must have a valid answer entered "; %>
    <%       String question_type = surveyBean.getQuestion_type( qId );      %>
    <%       if(question_type.equals("TEXT")){                                    %>
    <%           error_text = "Q" + surveyBean.getQuestion_seq( qId ) + ") " + surveyBean.getQuestion_text( qId ) + "<br/>Must have a valid text answer entered "; %>
    <%       } else if (question_type.equals("NUMBER")){                          %>
    <%           error_text = "Q" + surveyBean.getQuestion_seq( qId ) + ") " + surveyBean.getQuestion_text( qId ) + "<br/>Must have a valid numeric answer entered "; %>
    <%       } else if (question_type.equals("YESNO")){                           %>
    <%           error_text = "Q" + surveyBean.getQuestion_seq( qId ) + ") " + surveyBean.getQuestion_text( qId ) + "<br/>Must have a valid Y or N answer entered "; %>
    <%       }                                                               %>
             <jsp:setProperty name="surveyBean" property="error"
                              value='<%= error_text %>' />
             <jsp:forward page="doorstepSurveyView.jsp" />
    <%     }//end if                                                         %>
    <%   }//end if/else                                                      %>
    <% }//end while                                                          %>
    <%--------------------------End of code block----------------------------%>
    
    <%-- Valid entry --%>
    
    <%-- Next view 1 --%>
    <if:IfTrue cond='<%= surveyBean.getAction().equals("Close as Comp") %>'>
      <%-- 07/07/2010  TW  Should be setting the action to NFA (see addComplaintFunc.jsp) --%>
      <%-- Set the hold flag to Yes --%>
      <%-- recordBean.setAction_flag("H"); --%>
      <% recordBean.setAction_flag("N"); %>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">doorstepSurvey</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
      <c:redirect url="addEnforcementScript.jsp" />
    </if:IfTrue>

    <%-- Next view 1 --%>
    <if:IfTrue cond='<%= surveyBean.getAction().equals("Add " + application.getInitParameter("def_name_noun")) %>'>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">doorstepSurvey</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">doorstepFault</sess:setAttribute>
      <c:redirect url="doorstepFaultScript.jsp" />
    </if:IfTrue>
    
  </if:IfTrue>
    
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= surveyBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">doorstepSurvey</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= surveyBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">doorstepSurvey</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= surveyBean.getAction().equals("Back") %>' >
    <% recordBean.setAction_flag(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">doorstepSurvey</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= surveyBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${surveyBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="doorstepSurveyView.jsp" />

