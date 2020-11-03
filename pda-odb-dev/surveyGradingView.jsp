<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyGradingBean, com.vsb.surveyTransectMeasureBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql"  %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app"  %>

<jsp:useBean id="surveyGradingBean"         scope="session" class="com.vsb.surveyGradingBean" />
<jsp:useBean id="surveyTransectMeasureBean" scope="session" class="com.vsb.surveyTransectMeasureBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveyGrading" value="false">
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
  <title>surveyGrading</title>
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
  <%-- Check if we are automatically defaulting from a BV199 --%>
  <% boolean defaulting = false; %>
  <app:equalsInitParameter name="use_bv199_defaulting" match="Y">
    <% defaulting = true; %>
  </app:equalsInitParameter>  
  
  <form onSubmit="return singleclick();" action="surveyGradingScript.jsp" method="post">
  
    <table width="100%" border="0">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Transect Grading</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="surveyGradingBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>    
    <table width="100%" border="0">
      <tr>
        <td>
          <%-- Grab the BV199 grades and codes --%>
          <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
          <sql:statement id="stmt" conn="con">
            <sql:query>
                SELECT lookup_code, 
                       lookup_text
                  FROM allk
                 WHERE lookup_func = 'BVGRAD'
                 AND   status_yn = 'Y'
              ORDER BY lookup_code
            </sql:query>
          <%-- BV199 Table --%>
          <table align="center">
            <%-- LITTER --%>
            <if:IfTrue cond='<%=  surveyGradingBean.isLitter_defaulted() %>'>          
              <tr bgcolor="#ecf5ff"><td width="100%"><b>Litter ( Locked, already <%= application.getInitParameter("def_name_past").toLowerCase() %> )</b></td>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! surveyGradingBean.isLitter_defaulted() %>'>          
              <tr bgcolor="#ecf5ff"><td width="100%"><b>Litter</b></td>
            </if:IfTrue>
              <td>
                <%-- If the item has not been defaulted display the normal drop down list. --%>
                <if:IfTrue cond='<%= ! surveyGradingBean.isLitter_defaulted() %>'>
                  <select name="litter_grade">
                    <option>GRADE</option>
                    <sql:resultSet id="rset">
                      <sql:getColumn position="1" to="litter_grade" />
                      <% String litter_grade = ((String)pageContext.getAttribute("litter_grade")).trim(); %>
                      <if:IfTrue cond='<%= litter_grade.equals(surveyGradingBean.getLitter_grade()) %>' >
                        <option value="<sql:getColumn position="1" />"  selected="selected" >
                          <sql:getColumn position="2" />
                        </option>
                      </if:IfTrue>
                      <if:IfTrue cond='<%= ! litter_grade.equals(surveyGradingBean.getLitter_grade()) %>' >
                        <option value="<sql:getColumn position="1" />">
                          <sql:getColumn position="2" />
                        </option>
                      </if:IfTrue>
                    </sql:resultSet>
                  </select>
                </if:IfTrue>
                <%-- If the item has been defaulted, display the grade as text and create a hidden field for the value --%>
                <if:IfTrue cond='<%= surveyGradingBean.isLitter_defaulted() %>'>
                  <b><%= surveyGradingBean.getLitter_code() %></b>
                  <input type="hidden" name="litter_grade" value="<%= surveyGradingBean.getLitter_grade() %>">
                </if:IfTrue>
              </td>
            </tr>
            <tr>
              <td colspan="2">
                <if:IfTrue cond='<%= !surveyGradingBean.isLitter_defaulted() %>'>
                  <textarea cols="20" name="litter_text" rows="3"><%=surveyGradingBean.getLitter_text()%></textarea>
                </if:IfTrue>
                <if:IfTrue cond='<%= surveyGradingBean.isLitter_defaulted() %>'>
                  <textarea cols="20" 
                            name="litter_text" 
                            rows="3" 
                            readonly="readonly"><%=surveyGradingBean.getLitter_text()%></textarea>
                </if:IfTrue>
              </td>
            </tr>
            <%-- DETRITUS --%>
            <tr bgcolor="#ecf5ff">
            <if:IfTrue cond='<%=  surveyGradingBean.isDetrit_defaulted() %>'>          
              <tr bgcolor="#ecf5ff"><td width="100%"><b>Detritus ( Locked, already <%= application.getInitParameter("def_name_past").toLowerCase() %> )</b></td>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! surveyGradingBean.isDetrit_defaulted() %>'>          
              <tr bgcolor="#ecf5ff"><td width="100%"><b>Detritus</b></td>
            </if:IfTrue>
              <td>
                <%-- If the item has not been defaulted display the normal drop down list. --%>
                <if:IfTrue cond='<%= ! surveyGradingBean.isDetrit_defaulted() %>'>              
                  <select name="detritus_grade">
                    <option>GRADE</option>
                    <sql:resultSet id="rset">
                      <sql:getColumn position="1" to="detritus_grade" />
                       <% String detritus_grade = ((String)pageContext.getAttribute("detritus_grade")).trim(); %>
                      <if:IfTrue cond='<%= detritus_grade.equals(surveyGradingBean.getDetritus_grade()) %>' >
                        <option value="<sql:getColumn position="1" />"  selected="selected" >
                          <sql:getColumn position="2" />
                        </option>
                      </if:IfTrue>
                      <if:IfTrue cond='<%= ! detritus_grade.equals(surveyGradingBean.getDetritus_grade()) %>' >
                        <option value="<sql:getColumn position="1" />">
                          <sql:getColumn position="2" />
                        </option>
                      </if:IfTrue>
                    </sql:resultSet>
                  </select>
                </if:IfTrue>
                <%-- If the item has been defaulted, display the grade as text and create a hidden field for the value --%>
                <if:IfTrue cond='<%= surveyGradingBean.isDetrit_defaulted() %>'>
                  <b><%= surveyGradingBean.getDetrit_code() %></b>
                  <input type="hidden" name="detritus_grade" value="<%= surveyGradingBean.getDetritus_grade() %>">
                </if:IfTrue>
              </td>
            </tr>
            <tr>
              <td colspan="2">
                <if:IfTrue cond='<%= !surveyGradingBean.isDetrit_defaulted() %>'>
                  <textarea cols="20" name="detritus_text" rows="3"><%=surveyGradingBean.getDetritus_text()%></textarea>
                </if:IfTrue>
                <if:IfTrue cond='<%= surveyGradingBean.isDetrit_defaulted() %>'>
                  <textarea cols="20" 
                            name="detritus_text" 
                            rows="3" 
                            readonly="readonly"><%=surveyGradingBean.getDetritus_text()%></textarea>
                </if:IfTrue>
              </td>
            </tr>
            <%-- GRAFFITI --%>
            <tr bgcolor="#ecf5ff">
            <if:IfTrue cond='<%=  surveyGradingBean.isGrafft_defaulted() %>'>          
              <tr bgcolor="#ecf5ff"><td width="100%"><b>Graffiti ( Locked, already <%= application.getInitParameter("def_name_past").toLowerCase() %> )</b></td>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! surveyGradingBean.isGrafft_defaulted() %>'>          
              <tr bgcolor="#ecf5ff"><td width="100%"><b>Graffiti</b></td>
            </if:IfTrue>
              <td>
                <%-- If the item has not been defaulted display the normal drop down list. --%>
                <if:IfTrue cond='<%= ! surveyGradingBean.isGrafft_defaulted() %>'> 
                  <select name="graffiti_grade">
                    <option>GRADE</option>
                    <sql:resultSet id="rset">
                      <sql:getColumn position="1" to="graffiti_grade" />
                      <% String graffiti_grade = ((String)pageContext.getAttribute("graffiti_grade")).trim(); %>
                      <if:IfTrue cond='<%= graffiti_grade.equals(surveyGradingBean.getGraffiti_grade()) %>' >
                        <option value="<sql:getColumn position="1" />"  selected="selected" >
                          <sql:getColumn position="2" />
                        </option>
                      </if:IfTrue>
                      <if:IfTrue cond='<%= ! graffiti_grade.equals(surveyGradingBean.getGraffiti_grade()) %>' >
                        <option value="<sql:getColumn position="1" />">
                          <sql:getColumn position="2" />
                        </option>
                      </if:IfTrue>
                    </sql:resultSet>
                  </select>
                </if:IfTrue>
                <%-- If the item has been defaulted, display the grade as text and create a hidden field for the value --%>
                <if:IfTrue cond='<%= surveyGradingBean.isGrafft_defaulted() %>'>
                  <b><%= surveyGradingBean.getGrafft_code() %></b>
                  <input type="hidden" name="graffiti_grade" value="<%= surveyGradingBean.getGraffiti_grade() %>">
                </if:IfTrue>
              </td>
            </tr>
            <tr>
              <td colspan="2">
                <if:IfTrue cond='<%= !surveyGradingBean.isGrafft_defaulted() %>'>
                  <textarea cols="20" name="graffiti_text" rows="3"><%=surveyGradingBean.getGraffiti_text()%></textarea>
                </if:IfTrue>
                <if:IfTrue cond='<%= surveyGradingBean.isGrafft_defaulted() %>'>
                  <textarea cols="20" 
                            name="graffiti_text" 
                            rows="3" 
                            readonly="readonly"><%=surveyGradingBean.getGraffiti_text()%></textarea>
                </if:IfTrue>
              </td>
            </tr>
            <%-- FLY POSTING --%>
            <if:IfTrue cond='<%=  surveyGradingBean.isFlypos_defaulted() %>'>          
              <tr bgcolor="#ecf5ff"><td width="100%"><b>Fly Posting ( Locked, already <%= application.getInitParameter("def_name_past").toLowerCase() %> )</b></td>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! surveyGradingBean.isFlypos_defaulted() %>'>          
              <tr bgcolor="#ecf5ff"><td width="100%"><b>Fly Posting</b></td>
            </if:IfTrue>
              <td>
                <%-- If the item has not been defaulted display the normal drop down list. --%>
                <if:IfTrue cond='<%= ! surveyGradingBean.isFlypos_defaulted() %>'> 
                  <select name="flyposting_grade">
                    <option>GRADE</option>
                    <sql:resultSet id="rset">
                      <sql:getColumn position="1" to="flyposting_grade" />
                      <% String flyposting_grade = ((String)pageContext.getAttribute("flyposting_grade")).trim(); %>
                      <if:IfTrue cond='<%= flyposting_grade.equals(surveyGradingBean.getFlyposting_grade()) %>' >
                        <option value="<sql:getColumn position="1" />"  selected="selected" >
                          <sql:getColumn position="2" />
                        </option>
                      </if:IfTrue>
                      <if:IfTrue cond='<%= ! flyposting_grade.equals(surveyGradingBean.getFlyposting_grade()) %>' >
                        <option value="<sql:getColumn position="1" />">
                          <sql:getColumn position="2" />
                        </option>
                      </if:IfTrue>
                    </sql:resultSet>
                  </select>
                </if:IfTrue>
                <%-- If the item has been defaulted, display the grade as text and create a hidden field for the value --%>
                <if:IfTrue cond='<%= surveyGradingBean.isFlypos_defaulted() %>'>
                  <b><%= surveyGradingBean.getFlypos_code() %></b>
                  <input type="hidden" name="flyposting_grade" value="<%= surveyGradingBean.getFlyposting_grade() %>">
                </if:IfTrue>
              </td>
            </tr>
            <tr>
              <td colspan="2">
                <if:IfTrue cond='<%= !surveyGradingBean.isFlypos_defaulted() %>'>
                  <textarea cols="20" name="flyposting_text" rows="3"><%=surveyGradingBean.getFlyposting_text()%></textarea>
                </if:IfTrue>
                <if:IfTrue cond='<%= surveyGradingBean.isFlypos_defaulted() %>'>
                  <textarea cols="20" 
                            name="flyposting_text" 
                            rows="3" 
                            readonly="readonly"><%=surveyGradingBean.getFlyposting_text()%></textarea>
                </if:IfTrue>
              </td>
            </tr>
          </table>
          </sql:statement>
          <sql:closeConnection conn="con"/>
        </td>
      </tr>
    </table>
    <jsp:include page="include/back_continue_buttons.jsp" flush="true" />
    <%-- If we have already defaulted a BV199 item do not allow the user to exit --%>
    <if:IfTrue cond='<%= !surveyGradingBean.isAnyFlagDefaulted() %>'>
      <%@ include file="include/insp_sched_buttons.jsp" %>
    </if:IfTrue>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input"      value="surveyGrading" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
    </form>
  </body>
</html>
