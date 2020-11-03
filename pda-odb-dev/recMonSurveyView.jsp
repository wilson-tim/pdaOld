<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyBean, com.vsb.recordBean, com.vsb.recMonPropertiesBean" %>
<%@ page import="java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="surveyBean" scope="session" class="com.vsb.surveyBean" />
<jsp:useBean id="recMonPropertiesBean" scope="session" class="com.vsb.recMonPropertiesBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="recMonSurvey" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<app:equalsInitParameter name="use_xhtml" match="Y">
  <html xmlns="http://www.w3.org/1999/xhtml">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <html>
</app:equalsInitParameter>
<head>
  <!-- Set iPhone OS Safari attributes -->
  <meta name = "viewport" content = "width = device-width">

  <%-- Stop the browser from caching the page --%>
  <meta http-equiv="Cache-Control" content="no-cache"/>
  <meta http-equiv="Pragma" content="no-cache"/>
  <%-- Stop any proxy servers from caching the page --%>
  <% response.addHeader("Cache-Control", "no-cache"); %>

  <meta http-equiv="Refresh" content="<app:initParameter name="refreshInterval"/>" />
  <app:equalsInitParameter name="use_xhtml" match="Y">
    <meta http-equiv="Content-Type" content="application/xhtml+xml" />
    <% response.setContentType("application/xhtml+xml"); %>
  </app:equalsInitParameter>
  <app:equalsInitParameter name="use_xhtml" match="Y" value="false">
    <meta http-equiv="Content-Type" content="text/html" />
  </app:equalsInitParameter>
  <title>recMonSurvey</title>
  <style type="text/css">
    @import url("global.css");
  </style>
  <!-- Disable the browser back button -->
  <script type="text/javascript">window.history.go(1);</script>
  <!-- Make all submit buttons single click only -->
  <script type="text/javascript">
    var allowed = true;
    function singleclick() {
      if (allowed == true ) {
        allowed = false;
        return true;
      } else {
        return false;
      }
    }
  </script>
</head>

<body onUnload="">
  <form onSubmit="return singleclick();" action="recMonSurveyScript.jsp" method="post">
    <%-- Table for page title --%>
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b><app:initParameter name="monitoring_title"/> Survey</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="surveyBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    
    <%-- Open a connection to get the questions for the survey--%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">

    <%-- Get the site_name_1 for this complaint_no --%>
    <% String site_name_1 = ""; %>
    <sql:query>
      SELECT site_name_1
      FROM mon_list
      WHERE complaint_no = <%= recMonPropertiesBean.getComplaint_no() %>
    </sql:query>
    <sql:resultSet id="rset1">
      <sql:getColumn position="1" to="site_name_1" />
      <% site_name_1 = ((String)pageContext.getAttribute("site_name_1")).trim(); %>
    </sql:resultSet>
    
    <%-- The Address of the property --%>
    <table width="100%">
      <tr>
        <td align="center">
          <b><%= site_name_1 %></b>
        </td>
      </tr>
    </table>
    
    <%-- Title for the survey --%>
    <table cellpadding="2" cellspacing="0" width="100%">
      <tr>
        <td colspan="4" bgcolor="#ff6600" align="center">
          <h4><b>DETAILS OF WASTE</b></h4>
        </td>
      </tr>
    </table>
    <br /> 
    
    <%-- Create a simple counter to ensure at least one question was  --%>
    <%-- written to the screen                                        --%>
    <% int count = 0;                                                   %> 
    <%-- Get the iterator of all the question id's, loop through      --%>
    <%-- them get their attributes and print them to screen           --%>
    <% Iterator questionIds = surveyBean.getKeyIterator();        %>
    <% while( questionIds.hasNext() ){                                  %>
    <%-- Get the question id                                          --%>
    <%   String id = (String)questionIds.next();                        %>
    <%-- Get the questions reference number                           --%>
    <%   String question_ref = surveyBean.getQuestion_ref(id);    %>
    <%-- Get the answers variable                                     --%>
    <%   String question_text = surveyBean.getQuestion_text(id);  %>
    <%-- Get the questions sequence number                            --%>
    <%   String question_seq = surveyBean.getQuestion_seq(id);    %>
    <%-- Get the questions type                                       --%>
    <%   String question_type = surveyBean.getQuestion_type(id);  %>
    <%-- Get the question validiation value                           --%>
    <%   String question_valid = surveyBean.getQuestion_type(id); %>
    <%---------- WHILE LOOP CONTINUES BELOW !!! ------------------------%>

    <%-- Type: YESNO --%>
    <if:IfTrue cond='<%= question_type.equals("YESNO") %>' >
      <% count++ ; %>
      <table cellpadding="2" cellspacing="0" width="100%">
        <tr>
          <td>
            <label for='<%= id %>'><b><%= "Q" + question_seq + ") " +question_text %></b></label>
            <if:IfTrue cond='<%= surveyBean.isYesNoChecked( id ) %>'>
              <input type="checkbox" name='<%= id %>' id='<%= id %>' value='Y' checked="checked" />
            </if:IfTrue>
            <if:IfTrue cond='<%= !surveyBean.isYesNoChecked( id ) %>'>
              <input type="checkbox" name='<%= id %>' id='<%= id %>' value='Y' />
            </if:IfTrue>
          </td>
        </tr>
        <tr><td><hr size="1" noshade="noshade" /></td></tr>
      </table>          
    </if:IfTrue>
    
    <%-- Type: NUMBER --%>
    <if:IfTrue cond='<%= question_type.equals("NUMBER") %>' >
      <% count++ ; %>
      <table cellpadding="2" cellspacing="0" width="100%">
        <tr>
          <td colspan="2">
            <b><%= "Q" + question_seq + ") " +question_text %></b>
            <input type="text" name='<%= id %>' size="3" maxlength="3" 
                   value='<%= surveyBean.getSingleAnswer( id ) %>' />
          </td>
        </tr>        
        <tr><td><hr size="1" noshade="noshade" /></td></tr>
      </table>          
    </if:IfTrue>
    
    <%-- Type: TEXT --%>
    <if:IfTrue cond='<%= question_type.equals("TEXT") %>' >
      <table cellpadding="2" cellspacing="0" width="100%">
        <% count++ ; %>
        <tr>
          <td colspan="2">
            <b><%= "Q" + question_seq + ") " +question_text %></b>
          </td>
          <td colspan="2">
            <input type="text" name='<%= id %>' size="20" maxlength="20" 
            value='<%= surveyBean.getSingleAnswer( id ) %>' />
          </td>
        </tr>        
        <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
      </table>
    </if:IfTrue>
    
    <%-- Type: RADIO --%>
    <if:IfTrue cond='<%= question_type.equals("RADIO") %>' >
      <% count++ ; %>
      <%-- Set the colour of individual fields --%>
      <% String color="#ffffff"; %>
      <table cellpadding="2" cellspacing="0" width="100%">
        <tr>
          <td colspan="4">
            <b><%= "Q" + question_seq + ") " +question_text %></b>
          </td>
        </tr>
        <%-- Radio buttons have multiple fields, so we need to create a new query --%>
        <%-- to collect the answers to the question being asked --%>
        <sql:statement id="stmt2" conn="con">
          <sql:query>
            SELECT answer_ref,
                   answer_text,
                   answer_seq
            FROM monitor_answer
            WHERE question_ref = '<%= question_ref %>'
            ORDER BY answer_seq
          </sql:query>
          <sql:resultSet id="rset2">
            <%-- Alter the row color to seperate the individual fields in the radio box --%>
            <% 
              if(color=="#ffffff") {
              color = "#ecf5ff";
              } else if (color=="#ecf5ff") {
              color = "#ffffff";
              }
            %>
            <%-- Get the answers returned from the query--%>
            <%-- Get the answerss reference number --%>
            <sql:getColumn position="1" to="answer_ref" />
            <% String answer_ref = ((String)pageContext.getAttribute("answer_ref")).trim(); %>
            <%-- Get the answers variable --%>
            <sql:getColumn position="2" to="answer_text" />
            <% String answer_text = ((String)pageContext.getAttribute("answer_text")).trim(); %>
            <%-- Get the questions sequence number --%>
            <sql:getColumn position="3" to="answer_seq" />
            <% String answer_seq = ((String)pageContext.getAttribute("answer_seq")).trim(); %>
            <tr bgcolor="<%= color %>" >
              <td valign="top" width="10">
                <if:IfTrue cond='<%= surveyBean.isRadioChecked( id, answer_text ) %>'>
                  <input type="radio" name="<%= id %>" id="<%= answer_text %>" 
                         value="<%= answer_text %>" checked="checked" />
                </if:IfTrue>
                <if:IfTrue cond='<%= !surveyBean.isRadioChecked( id, answer_text ) %>'>
                  <input type="radio" name="<%= id %>" id="<%= answer_text %>" 
                                      value="<%= answer_text %>" />
                </if:IfTrue>
              </td>
              <td valign="top" colspan="3">
                <label for="<%= answer_text %>"><b><%= answer_text %></b></label>
              </td>
            </tr>
          </sql:resultSet>
          <sql:wasEmpty>
            <tr>
              <td>
                <b>No answers found for this question.</b><br />
                <b>Please report error to the system administrator</b>
              </td>
            </tr>
          </sql:wasEmpty> 
        </sql:statement>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
      </table>
    </if:IfTrue>        
    
    <%-- Type: CHECK --%>
    <if:IfTrue cond='<%= question_type.equals("CHECK") %>' >
      <% count++ ; %>
      <%-- Set the colour of individual fields --%>
      <% String color="#ffffff"; %>
      <table cellpadding="2" cellspacing="0" width="100%">
        <tr>
          <td colspan="4">
            <b><%= "Q" + question_seq + ") " +question_text %></b>
          </td>
        </tr>
        <%-- Radio buttons have multiple fields, so we need to create a new query --%>
        <%-- to collect the answers to the question being asked --%>
        <sql:statement id="stmt3" conn="con">
          <sql:query>
            SELECT answer_ref,
                   answer_text,
                   answer_seq
            FROM monitor_answer
            WHERE question_ref = '<%= question_ref %>'
          </sql:query>
          <sql:resultSet id="rset3">
            <% 
              if(color=="#ffffff") {
              color = "#ecf5ff";
              } else if (color=="#ecf5ff") {
              color = "#ffffff";
              }
            %>
            <%-- Get the answers returned from the query--%>
            <%-- Get the answerss reference number --%>
            <sql:getColumn position="1" to="answer_ref" />
            <% String answer_ref = ((String)pageContext.getAttribute("answer_ref")).trim(); %>
            <%-- Get the answers variable --%>
            <sql:getColumn position="2" to="answer_text" />
            <% String answer_text = ((String)pageContext.getAttribute("answer_text")).trim(); %>
            <%-- Get the questions sequence number --%>
            <sql:getColumn position="3" to="answer_seq" />
            <% String answer_seq = ((String)pageContext.getAttribute("answer_seq")).trim(); %>
            <tr bgcolor="<%= color %>" >
              <td valign="top" width="10">
                <if:IfTrue cond='<%= surveyBean.isChecked( id, answer_text ) %>'>
                  <input type="checkbox" name="<%= id %>" id="<%= answer_text %>" 
                         value="<%= answer_text %>" checked="checked" />
                </if:IfTrue>
                <if:IfTrue cond='<%= !surveyBean.isChecked( id, answer_text ) %>'>
                  <input type="checkbox" name="<%= id %>" id="<%= answer_text %>" 
                         value="<%= answer_text %>" />
                </if:IfTrue>
              </td>
              <td valign="top" colspan="3">
                <label for="<%= answer_text %>"><b><%= answer_text %></b></label>
              </td>
            </tr>
          </sql:resultSet>
          <sql:wasEmpty>
            <tr>
              <td>
                <b>No answers found for this question.</b><br />
                <b>Please report error to the system administrator</b>
              </td>
            </tr>
          </sql:wasEmpty> 
        </sql:statement>
        <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
      </table>
    </if:IfTrue>

    <%-- End of the while loop from above! All questions should have been printed --%>    
    <% } // !!!! END OF WHILE LOOP !!!! %>
    <%-- to the screen in the correct sequence order --%>    
    <%-- If no results are returned, inform the user that the module has not been --%>
    <%-- setup correctly --%>      
    <if:IfTrue cond='<%= count==0 %>'>
      <table width="100%">
        <tr>
          <td>
           <b>No questions found for the monitoring survey</b>
          </td>
        </tr>
      </table>
    </if:IfTrue>

    </sql:statement>
    <sql:closeConnection conn="con"/>    
    <%-- End of sql statement, closed connection --%>
    
    <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
    
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="recMonSurvey" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
