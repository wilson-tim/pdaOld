<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyBean, com.vsb.recMonPropertiesBean, com.utils.date.dateBean, com.db.DbUtils" %>
<%@ page import="com.vsb.recordBean, com.vsb.loginBean, com.vsb.helperBean, com.dbb.SNoBean" %>
<%@ page import="java.util.Iterator, java.util.ArrayList " %>
<%@ page import="java.io.IOException, javax.naming.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c" %>

<jsp:useBean id="surveyBean"           scope="session" class="com.vsb.surveyBean" />
<jsp:useBean id="recMonPropertiesBean" scope="session" class="com.vsb.recMonPropertiesBean" />
<jsp:useBean id="loginBean"            scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="recordBean"           scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"           scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="DbUtils"              scope="session" class="com.db.DbUtils" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="recMonSurvey" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="recMonSurvey" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <% surveyBean.setAll("clear_answers"); %>
    <% surveyBean.setAction( request.getParameter("action") ); %>
    <%-- Get the iterator for the question id's -----------------------------%>
    <% Iterator qIdIterator = surveyBean.getKeyIterator();             %>
    <%-- Store the answers submitted by the user                           --%>
    <% while( qIdIterator.hasNext() ){                                       %>
    <%   String qId = (String)qIdIterator.next();                            %>
    <%   if( surveyBean.getQuestion_type( qId ).equals("CHECK")){      %>
    <%     String[] answers = request.getParameterValues( qId );             %>
    <%     surveyBean.addAnswer( qId, answers );                       %>
    <%   } else {                                                            %>
    <%     String answer_text = request.getParameter( qId );                 %>
    <%     surveyBean.addAnswer( qId, (new String[]{ answer_text }) ); %>
    <%   }//end if/else                                                      %>
    <% }//end while                                                          %>
    <% //surveyBean.print();                                           %>
    <%--------------------------End of code block----------------------------%>

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="surveyBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="recMonProperties" >
  <jsp:setProperty name="surveyBean" property="action" value="" />
  <jsp:setProperty name="surveyBean" property="all" value="clear" />
  <jsp:setProperty name="surveyBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="recMonSurvey" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
    <%-- Open a connection to get the questions for the survey--%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <%-- Create a variable to store the complaint code --%>
      <% String comp_code = ""; %>
      <sql:query>
        SELECT comp_code
          FROM mon_list
         WHERE complaint_no = <%= recMonPropertiesBean.getComplaint_no() %>
      </sql:query>
      <sql:resultSet id="rsetlist">
        <%-- Get the surveys complaint fault_code/ comp_code number --%>
        <sql:getColumn position="1" to="comp_code" />
        <% comp_code = ((String)pageContext.getAttribute("comp_code")).trim(); %>
      </sql:resultSet>
      
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
        WHERE question_comp_code = '<%= comp_code %>'
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

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="recMonSurvey" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= surveyBean.getAction().equals("Finish") %>' >
    <%---------------------- Depedancy Check --------------------------------%>
    <%-- Run through the questions and check to see that all the           --%>
    <%-- dependancies are correct and valid                                --%>
    <%-- Get the iterator for the question id's -----------------------------%>
    <% Iterator dependIdIterator = surveyBean.getKeyIterator();        %>
    <%-- Run through the questions one by one and call the checkDependancy --%>
    <%-- method                                                            --%>
    <% while( dependIdIterator.hasNext() ){                                  %>
    <%   String qId = (String)dependIdIterator.next();                       %>
    <%   if( !surveyBean.checkDependancy( qId ) ){                     %>
    <%     if( surveyBean.hasAnswer( qId ) ){                          %>
    <%       surveyBean.clearAnswer( qId );                            %>
             <jsp:setProperty name="surveyBean" property="error"
                              value='<%= "Q" 
                                    + surveyBean.getQuestion_dp( qId )
                                    + " must be checked in order to answer Q"
                                    + surveyBean.getQuestion_seq( qId )%>' 
             />             
             <jsp:forward page="recMonSurveyView.jsp" />              
    <%     }//end if                                                         %>
    <%   }else{                                                              %>
    <%     if( !surveyBean.isValid( qId ) ){                           %>
             <jsp:setProperty name="surveyBean" property="error"
                              value='<%= "Q" 
                                    + surveyBean.getQuestion_seq( qId )
                                    + ") " + surveyBean.getQuestion_text( qId )
                                    + " must have a valid answer entered " %>' 
             />
             <jsp:forward page="recMonSurveyView.jsp" />              
    <%     }//end if                                                         %>
    <%   }//end if/else                                                      %>
    <% }//end while                                                          %>
    <%--------------------------End of code block----------------------------%>
    
    <%-- Valid entry --%>
    <%-- Set up the dateBean for todays date --%>
    <% dateBean dateBean = new dateBean( application.getInitParameter("db_date_fmt") ); %>
    
    <%-- initialise the notify_customer flag --%>
    <% String notify_customer = "N"; %>

    <%-- Create an SQL connection to the database --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
    
      <%-- We want to populate the monitor tables to store the surveys results --%>
      <%-- For each survey the monitor_result_hdr needs a new record, and  --%>
      <%-- for each question on the survey the monitor_result_dtl needs a new record --%>
     
      <%-- First we need to get the number for this survey --%>
      <% SNoBean sNoBean  = new SNoBean( "java:comp/env", "jdbc/pda", "monitor_result_hdr" ); %>
      <% String serial_no = sNoBean.getSerial_noAsString();     %> 
      
      <%-- Create the header for this survey, which is a new row entry in monitor_result_hdr --%>
      <sql:query>
        INSERT INTO monitor_result_hdr(
          result_ref,
          complaint_no,
          customer_no,
          result_date,
          result_time_h,
          result_time_m,
          username
        ) VALUES (
          <%= serial_no %>,
          <%= recMonPropertiesBean.getComplaint_no() %>,
          null,
          '<%= dateBean.getDate() %>',
          '<%= dateBean.getTime_h() %>',
          '<%= dateBean.getTime_m() %>',
          '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>'
        )
      </sql:query>
      <sql:execute />

      <%-- Get the iterator of all the question id's, loop through      --%>
      <%-- them get their attributes and print them to screen           --%>
      <% Iterator questionIds = surveyBean.getKeyIterator();        %>
      <% while( questionIds.hasNext() ){                                  %>
      <%-- Get the question id                                          --%>
      <%   String id = (String)questionIds.next();                        %>
      <%-- Get the questions reference number                           --%>
      <%   String question_ref = surveyBean.getQuestion_ref(id);    %>
      <%-- Get the actual question                                      --%>
      <%   String question_text = surveyBean.getQuestion_text(id);  %>
      <%-- Get the questions sequence number                            --%>
      <%   String question_seq = surveyBean.getQuestion_seq(id);    %>
      <%-- Get the questions answers                                    --%>
      <%   String[] question_answer = surveyBean.getAnswer(id); %>
      <%---------- WHILE LOOP CONTINUES BELOW !!! ------------------------%>

      <%-- For each String returned run the query to add a new record to the --%>
      <%-- monitor_results_dtl --%>
        <% for(int i=0; i<question_answer.length; i++){ %>
        <sql:statement id="stmt2" conn="con">
          <sql:query>
            INSERT INTO monitor_result_dtl(       
              result_ref,
              question_ref,
              question_text,
              question_seq,
              answer_ref,
              answer_text
            ) VALUES (
              <%= serial_no %>,
              <%= question_ref %>,
              '<%= DbUtils.cleanString(question_text) %>',
              <%= question_seq %>,
              0,
              '<%= DbUtils.cleanString(question_answer[i]) %>'
            )
          </sql:query>
          <sql:execute />
        </sql:statement>
        <%-- End of if statement !!!!--%>
        <% } %>
      <%-- End of While loop !!!!--%>    
      <% } %>          
      
      <%-- Remove the survey from the inspection list --%>
      <sql:query>
        DELETE FROM mon_list
        WHERE complaint_no = <%= recMonPropertiesBean.getComplaint_no() %>
      </sql:query>
      <sql:execute />

      <%-- Get the diry_ref from the complaint_no --%>
      <sql:query>
        SELECT diry_ref
          FROM diry
         WHERE source_ref = '<%= recMonPropertiesBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="diry_ref" />
      </sql:resultSet>

      <%-- Close the diry record --%>
      <sql:query>
        UPDATE diry
           SET action_flag = 'C',
               dest_date = '<%= dateBean.getDate() %>',
               dest_time_h = '<%= dateBean.getTime_h() %>',
               dest_time_m = '<%= dateBean.getTime_m() %>',
               dest_user = '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>'
         WHERE diry_ref = '<%= ((String)pageContext.getAttribute("diry_ref")).trim() %>'
      </sql:query>
      <sql:execute />

      <%-- close the complaint --%>
      <sql:query>
        UPDATE comp
        SET date_closed = '<%= dateBean.getDate() %>',
            time_closed_h = '<%= dateBean.getTime_h() %>',
            time_closed_m = '<%= dateBean.getTime_m() %>',
            action_flag = 'N'
      WHERE complaint_no = '<%= recMonPropertiesBean.getComplaint_no()%>'
      </sql:query>
      <sql:execute />      

      <%-- getting the information for the notify_customer service call --%>
      <% notify_customer = "N"; %>
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'NOTIFY_CUSTOMER'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="notify_customer" />
        <sql:wasNotNull>
          <% notify_customer = ((String)pageContext.getAttribute("notify_customer")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>

    </sql:statement>
    <sql:closeConnection conn="con"/>
 
    <%-- Make the notify_customer web service call --%>
    <if:IfTrue cond='<%= notify_customer.equals("Y") %>'>
      <%
        // notify_customer client environmental variables from the java:comp/env
        // JNDI resource.
        // The output of the printing client is the string 'ok' if no errors occur.
        // alternatelly an error message or java exception are returned as strings.
        
        // obtain the initial context, which holds the server/web.xml environment variables.
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
       
        // Put all values that are going to be used in the <c:import ...> call, into the pageContext
        // So that the <c:import ...> tag can access them. 
        pageContext.setAttribute("notify_service", (String)envCtx.lookup("notify_service"));
        pageContext.setAttribute("contender_home", (String)envCtx.lookup("contender_home"));
        pageContext.setAttribute("system_path", (String)envCtx.lookup("system_path"));
        pageContext.setAttribute("cdev_db", (String)envCtx.lookup("cdev_db"));
        pageContext.setAttribute("COMPLAINT_NO", recMonPropertiesBean.getComplaint_no());
      %>

      <%-- Make the web service call, the returned value is stored in the --%>
      <%-- pageContext variable "webPage" --%> 
      <%-- Need to catch the web service call, just incase the service is inaccesible --%>
      <c:catch var="caughtError"> 
        <c:import url="${notify_service}" var="webPage" >
          <c:param name="contender_home" value="${contender_home}" />
          <c:param name="system_path" value="${system_path}" />
          <c:param name="cdev_db" value="${cdev_db}" />
          <c:param name="complaint_no" value="${COMPLAINT_NO}" />
        </c:import>
      </c:catch>
        
      <%
        String returnedValue = "";
        Exception caughtError = (Exception)pageContext.getAttribute("caughtError");
        if (caughtError == null) {
          // No caught error so use value returned from web service. This will be "ok" if
          // everything went ok.
          returnedValue = ((String)pageContext.getAttribute("webPage")).trim();
        } else {
          // There is a caught error so use that value 
          returnedValue = caughtError.toString().trim();
        }
      %>

      <%-- Only output an error message --%> 
      <if:IfTrue cond='<%= ! returnedValue.equals("ok") %>'>
        <% helperBean.throwException("notify_customer service", returnedValue); %>
      </if:IfTrue>
    </if:IfTrue>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonSurvey</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">recMonProperties</sess:setAttribute>
    <c:redirect url="recMonPropertiesScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= surveyBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonSurvey</sess:setAttribute>
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
    <sess:setAttribute name="previousForm">recMonSurvey</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= surveyBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonSurvey</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= surveyBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${surveyBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="recMonSurveyView.jsp" />
