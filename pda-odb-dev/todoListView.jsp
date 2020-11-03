<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.todoListLookupBean" %>
<%@ page import="com.vsb.todoRoundLookupBean" %>
<%@ page import="com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="todoListLookupBean" scope="session" class="com.vsb.todoListLookupBean" />
<jsp:useBean id="todoRoundLookupBean" scope="session" class="com.vsb.todoRoundLookupBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="todoList" value="false">
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
  <title>todoList</title>
  <style type="text/css">
    @import URL("global.css");
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
  <script type="text/javascript"> 
    function todolink(selectId,reasonId){
        var dropdown = document.getElementById( selectId )
        var myindex  = dropdown.selectedIndex;
        var SelValue = dropdown.options[myindex].text;
        var reasonLn = document.getElementById( reasonId )
        if(myindex>1){
            reasonLn.style.display="";
        }else{
            reasonLn.style.display="none";
        }
    }
  </script> 
<script language="javascript" type="text/javascript">
function imposeMaxLength(Object, MaxLen)
{
    if(Object.value.length>MaxLen){
        var s=Object.value;
        Object.value=s.substring(0,MaxLen-1);
        return false;
    }
  return (Object.value.length <= MaxLen);
}
</script>
</head>

<body onUnload="">
  <form onSubmit="return singleclick();" action="todoListScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Todo List Lookup</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="todoListLookupBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade /></td></tr>
    </table>
    <% String color="#ffffff"; %>
    <% int row_count=0; %>
    <jsp:include page="include/back_submit_buttons.jsp" flush="true" />
    <table cellpadding="2" cellspacing="0" width="100%">
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <sql:query>
            select serial_no, text 
            from todo_tasks
            where user_name = '<%=loginBean.getUser_name().toLowerCase() %>'
            and task_date = '<%=session.getAttribute("currentDate ")%>'
            and status is null
        </sql:query>
        <sql:resultSet id="rset">
          <%
            if(color=="#ffffff") {
              color = "#ecf5ff";
            } else if (color=="#ecf5ff") {
              color = "#ffffff";
            }
          %>
          <% row_count=row_count +1; %>
          <tr bgcolor="<%= color %>" >
            <sql:getColumn position="1" to="serial_no" />
            <sql:getColumn position="2" to="todo_text" />
            <% 
            String serial_no = ((String)pageContext.getAttribute("serial_no")).trim();
            String todo_text = ((String)pageContext.getAttribute("todo_text")).trim();
            String status = (String)session.getAttribute("todo"+serial_no+"Status");
            String reason = (String)session.getAttribute("todo"+serial_no+"Reason");
            String rerror = (String)session.getAttribute("todo"+serial_no+"Error");
            if(status==null) status="";
            if(reason==null) reason="";
            if(rerror==null) rerror="";
            if(todo_text==null) todo_text="";
%>
            <td valign="top"><%=todo_text %><input type="hidden" name="serial_no<%=row_count %>" value="<%=serial_no %>" /></td>
            <td><select id="todoStatus<%=row_count %>" name="todoStatus<%=row_count %>" onChange="todolink('todoStatus<%=row_count %>','todoReasonTD<%=row_count %>');">
                <option value=""></option>
                <option value="Done" <% if(status.equals("Done")){ %>selected<% } %> >Done</option>
                <option value="Done (Txt)" <% if(status.equals("Done (Txt)")){ %>selected<% } %> >Done (Txt)</option>
                <option value="Not Done" <% if(status.equals("Not Done")){ %>selected<% } %> >Not Done</option>
                </select>
            </td>
          </tr>
          <tr id="todoReasonTD<%=row_count %>"<%                
    if(rerror.equals("")){
%> style="display:none" <% } %> >
            <td colspan="2">
              <label style="width: 6%">Reason : </label>
              <textarea rows="4" cols="28" name="todoReason<%=row_count %>"
                        onkeypress="return imposeMaxLength(this, 255);"
                        onchange="return imposeMaxLength(this, 255);"
                        onkeyup="return imposeMaxLength(this,255)"
                        ><%=reason %></textarea>
            </td>
          </tr>
<%
    if(!rerror.equals("")){
%>         <tr><td><font color="#ff6565"><b><%=rerror %></b></font></td> </tr><%
}
%>
        </sql:resultSet>
        <sql:wasEmpty>
          <tr>
           <td colspan="2">
             <b>No Lists Found</b>
           </td>
         </tr>
        </sql:wasEmpty>
        <sql:wasNotEmpty>
          <tr>
            <td colspan="2">
              <span class="subscript"><sql:rowCount /> list(s)</span>
            </td>
          </tr>
        </sql:wasNotEmpty>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>
    <input type="hidden" name="row-count" value="<%=row_count %>" />
    <jsp:include page="include/back_submit_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="todoList" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>