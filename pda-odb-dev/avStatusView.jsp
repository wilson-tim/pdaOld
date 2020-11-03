<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.avStatusBean, com.vsb.avMultiStatusBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="avStatusBean" scope="session" class="com.vsb.avStatusBean" />
<jsp:useBean id="avMultiStatusBean" scope="session" class="com.vsb.avMultiStatusBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="avStatus" value="false">
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
  <title>avStatus</title>
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
  <form onSubmit="return singleclick();" action="avStatusScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>AV Status</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="avStatusBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td align="center"><b><jsp:getProperty name="recordBean" property="site_name_1" /></b></td></tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
    </table>
    <br/>
    <%-- Connect to Database --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- Is the AV_NEXT_STATUS key switched ON. If it is we will need to restrict the --%>
      <%-- status options shown in the drop down list. --%>
      <sql:query>
        SELECT c_field
        FROM keys
        WHERE service_c = 'ALL'
        AND   keyname = 'AV_NEXT_STATUS'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="av_next_status" />
        <sql:wasNull>
          <% pageContext.setAttribute("av_next_status", "N"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("av_next_status", "N"); %>
      </sql:wasEmpty>
      <%-- In case the AV_NEXT_STATUS is set to 'Y', we will need to know what the --%>
      <%-- AV_TYPE_PROMPT key is set to --%>
      <sql:query>
        SELECT c_field
        FROM keys
        WHERE service_c = 'ALL'
        AND   keyname = 'AV_TYPE_PROMPT'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="av_type_prompt" />
        <sql:wasNull>
          <% pageContext.setAttribute("av_type_prompt", "N"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("av_type_prompt", "N"); %>
      </sql:wasEmpty>
      <%-- Check to see if the user can raise a Works Order --%>
      <sql:query>
        SELECT c_field
        FROM keys
        WHERE service_c = 'ALL'
        AND   keyname = 'AV WO USED'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="av_wo_used" />
        <sql:wasNull>
          <% pageContext.setAttribute("av_wo_used", "N"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("av_wo_used", "N"); %>
      </sql:wasEmpty>

    <% boolean closeComp = false; %>
      <sql:query>
        SELECT closed_yn
          FROM av_status
        WHERE status_ref = '<%= avStatusBean.getStatus_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="closed_yn" />
        <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("closed_yn") ) %>'>
          <% pageContext.setAttribute("closed_yn", ""); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= ((String)pageContext.getAttribute("closed_yn")).trim().equals("Y") %>'>
          <% closeComp = true; %>
        </if:IfTrue>
      </sql:resultSet>

    <%-- Create the status drop down list based on the settings of the keys above. --%>         
    <table width="100%">
      <tr>
        <td>
          <b>Status</b>
        </td>
        <td>
          <select name="status_ref">
            <option value="" selected="selected" ></option>
            <%
              int status_count = avMultiStatusBean.getStatus_count();
              String status_ref = "";
            %>
            <if:IfTrue cond='<%= status_count == 0 %>' >
              <%-- First status selection --%>
              <%-- Check av_type_prompt = 'N'--%>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("av_type_prompt")).trim().equals("N") %>'>
                <%-- Check av_next_status = 'Y' display status's that are allowed from 'NONE' --%>
                <if:IfTrue cond='<%= ((String)pageContext.getAttribute("av_next_status")).trim().equals("Y") %>'>
                  <sql:query>
                    SELECT next_lookup_code
                      FROM allk_avstat_link
                     WHERE lookup_code = 'NONE'
                  </sql:query>
                </if:IfTrue>
                <%-- Check av_next_status = 'N', display all status's --%>
                <if:IfTrue cond='<%= ((String)pageContext.getAttribute("av_next_status")).trim().equals("N") %>'>
                  <sql:query>
                    SELECT status_ref
                      FROM av_status
                     ORDER BY status_ref
                  </sql:query>
                </if:IfTrue>
              </if:IfTrue>
              <%-- Check av_type_prompt = 'Y'. If it is, select status's from the allk table. These status's --%>
              <%-- relate to the buttons displayed to a user in Contender when adding a new AV --%>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("av_type_prompt")).trim().equals("Y") %>'>
                <sql:query>
                  SELECT lookup_text
                    FROM allk
                   WHERE lookup_code = 'STATUS'
                     AND lookup_func = 'AVTP'
                </sql:query>
              </if:IfTrue>
            </if:IfTrue>
            <if:IfTrue cond='<%= status_count > 0 %>' >
              <%-- Second and subsequent status selection --%>
              <% status_ref = avMultiStatusBean.getStatusByIx(status_count - 1); %>
              <%-- Check av_next_status = 'Y' display status's that are allowed from 'NONE' --%>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("av_next_status")).trim().equals("Y") %>'>
                <sql:query>
                  SELECT next_lookup_code
                    FROM allk_avstat_link
                   WHERE lookup_code = '<%= status_ref %>'
                </sql:query>
              </if:IfTrue>
              <%-- Check av_next_status = 'N', display all status's --%>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("av_next_status")).trim().equals("N") %>'>
                <sql:query>
                  SELECT status_ref
                    FROM av_status
                   ORDER BY status_ref
                </sql:query>
              </if:IfTrue>
            </if:IfTrue>
            <%-- Depending on the system keys, display the allowed status's for creating a new AV Complaint--%>
            <sql:resultSet id="rset">              
              <sql:getColumn position="1" to="avStatus_ref" />
              <sql:wasNull>
                 <% pageContext.setAttribute("avStatus_ref", ""); %>
              </sql:wasNull>
              <if:IfTrue cond='<%= (((String)pageContext.getAttribute("avStatus_ref")).trim().equals(avStatusBean.getStatus_ref())) %>' >
                <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="1" /></option>
              </if:IfTrue>
              <if:IfTrue cond='<%= !(((String)pageContext.getAttribute("avStatus_ref")).trim().equals(avStatusBean.getStatus_ref())) %>' >
                <option value="<sql:getColumn position="1" />"><sql:getColumn position="1" /></option>
              </if:IfTrue>
            </sql:resultSet>
          </select>
        </td>
      </tr>
      <%-- Text area for AV_History Notes--%>
      <tr>
        <td colspan="2">
          <b>Notes</b><br/>
          <textarea rows="8" cols="25" name="text"><jsp:getProperty name="avStatusBean" property="text" /></textarea>
        </td>
      </tr>
      
      <tr><td>&nbsp;</td></tr>
      <tr>
        <td>
          <b><input type="submit" name="action" value="Add Another Status"
            style="font-weight:bold; width: 18em; font-size: 85%" /></b>
        </td>
      </tr>

    </table>
    </sql:statement> 
    <sql:closeConnection conn="con"/>
    <br/>

    <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") %>'>
      <jsp:include page="include/back_wo_buttons.jsp" flush="true" />
    </if:IfTrue>
    <if:IfTrue cond='<%= !recordBean.getAction_flag().equals("W") %>'>
      <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
    </if:IfTrue>

    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="avStatus" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
