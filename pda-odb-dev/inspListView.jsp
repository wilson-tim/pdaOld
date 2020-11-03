<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.*, java.util.*, java.text.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.inspListBean, com.vsb.inspListBean, com.vsb.loginBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"          prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>

<jsp:useBean id="inspListBean"    scope="session" class="com.vsb.inspListBean" />
<jsp:useBean id="loginBean"       scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="recordBean"      scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"      scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="inspListPageSet" scope="session" class="com.db.PageSet" />
<jsp:useBean id="inspQueryBean"   scope="session" class="com.vsb.inspQueryBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="inspList" value="false">
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

  <meta http-equiv="Refresh" content="<app:initParameter name="listRefreshInterval"/>" />
  <app:equalsInitParameter name="use_xhtml" match="Y">
    <meta http-equiv="Content-Type" content="application/xhtml+xml" />
    <% response.setContentType("application/xhtml+xml"); %>
  </app:equalsInitParameter>
  <app:equalsInitParameter name="use_xhtml" match="Y" value="false">
    <meta http-equiv="Content-Type" content="text/html" />
  </app:equalsInitParameter>
  <title>inspList</title>
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
  <form onSubmit="return singleclick();" action="inspListScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Inspection List</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="inspListBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <sess:equalsAttribute name="sort_order" match="postcode" >
      <jsp:include page="include/sort_order_post_buttons.jsp" flush="true" />
    </sess:equalsAttribute>
    <sess:equalsAttribute name="sort_order" match="ward" >
      <jsp:include page="include/sort_order_ward_buttons.jsp" flush="true" />
    </sess:equalsAttribute>
    <sess:equalsAttribute name="sort_order" match="area" >
      <jsp:include page="include/sort_order_area_buttons.jsp" flush="true" />
    </sess:equalsAttribute>
    <sess:equalsAttribute name="sort_order" match="date" >
      <jsp:include page="include/sort_order_date_buttons.jsp" flush="true" />
    </sess:equalsAttribute>

    <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />

    <%-- create database connection --%>
    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    
    <table width="100%">
      <tr>
        <td colspan="2">
          <span class="subscript">
            items <%= inspListPageSet.getMinRecordInPage() %> - <%= inspListPageSet.getMaxRecordInPage() %> of <%= inspListPageSet.getRecordCount() %>
          </span>
        </td>
      </tr>
      
      <%-- Get the current page --%>
      <% Page thePage = inspListPageSet.getCurrentPage(); %>
      <%-- Decalre all the variables we will use below --%>
      <%
        String action_flag   = "";
        String action        = "";
        String item_ref      = "";
        String site_ref      = "";
        String contract_ref  = "";
        String feature_ref   = "";
        String service_c     = ""; 
        String state         = "";
        String due_date      = "";
        String end_time_h    = ""; 
        String end_time_m    = "";
        String start_time_h  = ""; 
        String start_time_m  = "";
        String tree_ref      = "";
        String tr_no         = "";
      %>
      <%-- For each item on the page. . . --%>
      <% while (thePage.next()) { %>              
        <%-- Set the complaint number for ease of use --%>
        <% String complaint_no = thePage.getField(3).trim(); %>
        
        <tr>
          <%-- Draw radio buttons on the form and check if any items have been selected--%>
          <td width="10">
            <if:IfTrue cond='<%= complaint_no.equals(inspListBean.getComplaint_no()) %>' >
              <input type="radio" 
                     name="complaint_no" 
                     id="<%= complaint_no %>"
                     value="<%= complaint_no %>"  
                     checked="checked" />
            </if:IfTrue>
            <if:IfTrue cond='<%= !complaint_no.equals(inspListBean.getComplaint_no()) %>' >
              <input type="radio" 
                     name="complaint_no" 
                     id="<%= complaint_no %>" 
                     value="<%= complaint_no %>" />
            </if:IfTrue>
          </td>
          
          <%-- Set the action_flag to the empty string if it is null--%>
          <% action_flag = ""; %>
          <if:IfTrue cond='<%= !(thePage.getField(1) == null) %>'>
            <% action_flag = thePage.getField(1).trim(); %>
          </if:IfTrue>

          <%-- Set the action to the empty string if it is null--%>
          <% action = ""; %>
          <if:IfTrue cond='<%= !(thePage.getField(2) == null) %>'>
            <% action = thePage.getField(2).trim(); %>
          </if:IfTrue>

          <%-- Set the item_ref to the empty string if it is null--%>
          <% item_ref = ""; %>
          <if:IfTrue cond='<%= !(thePage.getField(4) == null) %>'>
            <% item_ref = thePage.getField(4).trim(); %>
          </if:IfTrue>
          
          <%-- Check if the item_ref is empty, if so display blank--%>
          <if:IfTrue cond='<%= item_ref.equals("") %>'>
            <td align="center">&nbsp;</td>
          </if:IfTrue>
          <%-- Otherwise display the complaint type --%>
          <if:IfTrue cond='<%= ! item_ref.equals("") %>'>
            <if:IfTrue cond='<%= action_flag.equals("P") %>' >
              <td bgcolor="#259225" align="center"><font color="white"><b>Sample</b></font></td>
            </if:IfTrue>
            <if:IfTrue cond='<%= action_flag.equals("D") %>' >
              <td bgcolor="#259225" align="center"><font color="white"><b>Complaint</b></font></td>
            </if:IfTrue>
            <if:IfTrue cond='<%= action_flag.equals("I") %>' >
              <td bgcolor="#259225" align="center"><font color="white"><b>Complaint</b></font></td>
            </if:IfTrue>
          </if:IfTrue>
  
          <%-- Check if the action flag is blank, if so display nothing --%>
          <if:IfTrue cond='<%= action_flag.equals("") %>'>
            <td align="center">&nbsp;</td>
          </if:IfTrue>
          <%-- Otherwise display the action type --%>
          <if:IfTrue cond='<%= ! action_flag.equals("") %>'>
            <%-- Defaults --%>
            <if:IfTrue cond='<%= action_flag.equals("D") %>' >
              <if:IfTrue cond='<%= action.equals("") %>'>
                <%-- AMBER --%>
                <td bgcolor="#ff9966" align="center"><font color="white"><b><app:initParameter name="def_name_noun" /></b></font></td>
              </if:IfTrue>
              <if:IfTrue cond='<%= ! action.equals("") %>'>
                <%-- GREEN --%>
                <if:IfTrue cond='<%= action.equals("A") %>' >
                    <td  bgcolor="#259225" align="center"><font color="white"><b><app:initParameter name="def_name_noun" /></b></font></td>
                </if:IfTrue>
                <%-- AMBER --%>
                <if:IfTrue cond='<%= (!action.equals("A") && !action.equals("U")) %>' >
                    <td  bgcolor="#ff9966" align="center"><font color="white"><b><app:initParameter name="def_name_noun" /></b></font></td>
                </if:IfTrue>
                <%-- RED --%>
                <if:IfTrue cond='<%= action.equals("U") %>' >
                  <td bgcolor="#ff6565" align="center"><font color="white"><b><app:initParameter name="def_name_noun" /></b></font></td>
                </if:IfTrue>
              </if:IfTrue>
            </if:IfTrue>
            <%-- None BV199 Pending (Green) --%>
            <if:IfTrue cond='<%= action_flag.equals("P") && ! item_ref.equals(recordBean.getBv_item_ref().trim())%>' >
                <td bgcolor="#259225" align="center"><font color="white"><b>Pending</b></font></td>
            </if:IfTrue>
            <%-- BV199 Pending (Blue) --%>
            <if:IfTrue cond='<%= action_flag.equals("P") && item_ref.equals(recordBean.getBv_item_ref().trim())%>' >
                <td bgcolor="#3366cc" align="center"><font color="white"><b>NI195</b></font></td>
            </if:IfTrue>
            <%-- None BV199 Inspect (Green) --%>
            <if:IfTrue cond='<%= action_flag.equals("I") && !item_ref.equals(recordBean.getBv_item_ref().trim())%>' >
              <td bgcolor="#259225" align="center"><font color="white"><b>Inspect</b></font></td>
            </if:IfTrue>
            <%-- BV199 Inspect (Blue) --%>
            <if:IfTrue cond='<%= action_flag.equals("I") && item_ref.equals(recordBean.getBv_item_ref().trim())%>' >
              <td bgcolor="#3366cc" align="center"><font color="white"><b>Inspect</b></font></td>
            </if:IfTrue>
          </if:IfTrue>
        </tr>
        
        <%-- Display the address of the item in a seperate row --%>
        <tr>
          <td colspan="3">
            <label for="<%= complaint_no %>"><%= thePage.getField(7) %></label>
          </td>
        </tr>
  
        <%-- get some of the values needed in the below sections --%>
        <%-- site_ref --%>
        <% site_ref = ""; %>
        <if:IfTrue cond='<%= !(thePage.getField(5) == null) %>'>
          <% site_ref = thePage.getField(5).trim(); %>
        </if:IfTrue>
        <%-- contract_ref --%>
        <% contract_ref = ""; %>
        <if:IfTrue cond='<%= !(thePage.getField(15) == null) %>'>
          <% contract_ref = thePage.getField(15).trim(); %>
        </if:IfTrue>
        <%-- feature_ref --%>
        <% feature_ref = ""; %>
        <if:IfTrue cond='<%= !(thePage.getField(16) == null) %>'>
          <% feature_ref = thePage.getField(16).trim(); %>
        </if:IfTrue>
  
        <%-- decide wether to display the item_ref and complaint_no, or just the item_desc. --%>
        <%-- Use the item_ref and complaint_no --%>      
        <app:equalsInitParameter name="use_item_desc" match="Y" value="false">          
          <%-- Item and complaint_no --%>
          <%-- get the service of the complaint as we need to know if it is a graffiti --%>    
          <sql:statement id="stmt2" conn="con1">
            <sql:query>
              SELECT service_c
                FROM comp
               WHERE complaint_no = <%= complaint_no %>
            </sql:query>
            <sql:resultSet id="rset2">
              <sql:getColumn position="1" to="service_c" />
              <sql:wasNull>
                <% service_c = ""; %>
              </sql:wasNull>
              <sql:wasNotNull>
                <% service_c = ((String)pageContext.getAttribute("service_c")).trim(); %>
              </sql:wasNotNull>
            </sql:resultSet>
            <sql:wasEmpty>
              <% service_c = ""; %>
            </sql:wasEmpty>
          </sql:statement>
          <tr>
            <td bgcolor="#DDDDDD" colspan="3" align="center">
              <table width="100%">
                <tr>
                  <%-- If the service is a graffiti then need to check if there is any offensive --%>
                  <%-- graffiti, and flag the graffiti item in red if there is. --%>
                  <if:IfTrue cond='<%= service_c.equals(recordBean.getGraffiti_service()) %>'>
                    <% String tag_offensive = "N"; %>
                    <sql:statement id="stmt2" conn="con1">
                      <sql:query>
                        SELECT tag_offensive
                          FROM comp_ert_header
                         WHERE complaint_no = <%= complaint_no %>
                      </sql:query>
                      <sql:resultSet id="rset2">
                        <sql:getColumn position="1" to="tag_offensive" />
                        <sql:wasNull>
                          <% tag_offensive = "N"; %>
                        </sql:wasNull>
                        <sql:wasNotNull>
                          <% tag_offensive = ((String)pageContext.getAttribute("tag_offensive")).trim(); %>
                        </sql:wasNotNull>
                      </sql:resultSet>
                      <sql:wasEmpty>
                        <% tag_offensive = "N"; %>
                      </sql:wasEmpty>
                    </sql:statement>   

                    <if:IfTrue cond='<%= tag_offensive.equals("Y") %>'>
                      <td bgcolor="#ff6565" align="left">
                        <label for="<%= complaint_no %>">
                          <font color="white"><b><%= item_ref %></b></font>
                        </label>
                      </td>
                    </if:IfTrue>
                    <if:IfTrue cond='<%= tag_offensive.equals("N") || tag_offensive.equals("") %>'>
                      <td align="left">
                        <label for="<%= complaint_no %>"><b><%= item_ref %></b></label>
                      </td>
                    </if:IfTrue>
                  </if:IfTrue>
                  <if:IfTrue cond='<%= ! service_c.equals(recordBean.getGraffiti_service()) %>'>
                    <td align="left">
                      <label for="<%= complaint_no %>"><b><%= item_ref %></b></label>
                    </td>
                  </if:IfTrue>
                  <td align="right">
                    <label for="<%= complaint_no %>"><b><%= complaint_no %></b></label>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </app:equalsInitParameter>
        
        <%-- Use the item_desc instead of item_ref and complaint_no --%>
        <app:equalsInitParameter name="use_item_desc" match="Y" >
          <%-- Item --%>
          <%-- get the item description --%>
          <sql:statement id="stmt2" conn="con1">
            <sql:query>
              SELECT item_desc
                FROM item
               WHERE item_ref = '<%= item_ref %>'
                 AND contract_ref = '<%= contract_ref %>'
            </sql:query>
            <sql:resultSet id="rset2">
              <sql:getColumn position="1" to="item_desc" />
              <sql:wasNull>
                <% pageContext.setAttribute("item_desc",""); %>
              </sql:wasNull>
            </sql:resultSet>
            <sql:wasEmpty>
              <% pageContext.setAttribute("item_desc",""); %>
            </sql:wasEmpty>
          </sql:statement>
          <tr>
            <td bgcolor="#DDDDDD" colspan="3" align="center">
              <table width="100%">
                <tr>
                  <td align="left">
                    <label for="<%= complaint_no %>">
                      <b><%= ((String)pageContext.getAttribute("item_desc")).trim() %></b>
                    </label>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </app:equalsInitParameter>
        <%-- If this is the trees service add an extra row of information about the tree --%>
        <if:IfTrue cond="<%= service_c.equals( recordBean.getTrees_service() ) %>">         
          <sql:statement id="stmt2" conn="con1">
            <sql:query>
              SELECT tree_ref 
                FROM comp_tree 
               WHERE complaint_no = <%= complaint_no %> 
                 AND item_ref = '<%= recordBean.getTrees_item() %>'
            </sql:query>
            <sql:resultSet id="rset2">
              <sql:getColumn position="1" to="tree_ref" />
              <sql:wasNotNull>
                <% tree_ref = ((String)pageContext.getAttribute("tree_ref")).trim(); %>
              </sql:wasNotNull>
            </sql:resultSet>
            <sql:query>
              SELECT tr_no
                FROM trees
               WHERE tree_ref = <%= tree_ref %> 
            </sql:query>
            <sql:resultSet id="rset2">
              <sql:getColumn position="1" to="tr_no" />
              <sql:wasNotNull>
                <% tr_no = ((String)pageContext.getAttribute("tr_no")).trim(); %>
              </sql:wasNotNull>
            </sql:resultSet>
          </sql:statement>
          <tr>
            <td bgcolor="#DDDDDD" colspan="3" align="center">
              <table width="100%">
                <tr>
                  <td align="left">
                    <label for="<%= complaint_no %>"><b>Ref / Seq</b></label>
                  </td>
                  <td align="right">
                    <label for="<%= complaint_no %>"><b><%= tree_ref %>&nbsp;/&nbsp;<%= tr_no %></b></label>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </if:IfTrue>
        <%-- due date and time --%>
        <tr>
          <%-- Check if state is null and replace with empty string --%>
          <% state = ""; %>
          <if:IfTrue cond='<%= !(thePage.getField(14) == null) %>'>
            <% state = thePage.getField(14).trim(); %>
          </if:IfTrue>
          <%-- item has been processed so the date/time will have --%>
          <%-- changed, so flag it as such. --%>
          <if:IfTrue cond='<%= state.equals("P") %>' >
            <td bgcolor="#ff6565" colspan="3" align="center">
              <label for="<%= complaint_no %>"><font color="white"><b>PROCESSED</b></font></label>
            </td>
          </if:IfTrue>
          <%-- item has not been processed so the date/time will have --%>
          <%-- to be shown. --%>
          <if:IfTrue cond='<%= state.equals("A") %>' >
            <td bgcolor="#DDDDDD" colspan="3">
              <label for="<%= complaint_no %>">
                <%-- Check if due_date/time is null and replace with empty string --%>
                <%-- The due date should never be null, if it does there is bad data. --%>
                <% due_date = ""; %>
                <% end_time_h = ""; %>
                <% end_time_m = ""; %>
                <% start_time_h = ""; %>
                <% start_time_m = ""; %>
                <if:IfTrue cond='<%= !(thePage.getField(9) == null) %>'>
                  <% due_date = thePage.getField(9).trim(); %>

                  <%
                    // Set the default time zone to where we are, as the time zone
                    // returned from sco is GMT+00:00 which is fine but doesn't mentioned
                    // BST. So the default timezone has to be set to "Europe/London".
                    // Any objects which use the timezone (like SimpleDateFormat) will then
                    // be using the correct timezone.
                    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
                    TimeZone.setDefault(dtz);
  
                    SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
                    Date date = formatDate.parse(due_date);
                    GregorianCalendar gregDate = new GregorianCalendar();
                    gregDate.setTime(date);
                  %>
  
                  <%-- retrieve the samples times --%>
                  <sql:statement id="stmt2" conn="con1">
                    <sql:query>
                      select end_time_h,
                        end_time_m,
                        start_time_h,
                        start_time_m
                      from si_i_sched
                      where site_ref = '<%= site_ref %>'
                      and   item_ref = '<%= item_ref %>'
                      and   feature_ref = '<%= feature_ref %>'
                      and   contract_ref = '<%= contract_ref %>'
                      and   occur_day = '<%= helperBean.getOccur_day(gregDate) %>'
                      and   seq_no =
                       ( select max(seq_no)
                         from si_i_sched
                         where site_ref = '<%= site_ref %>'
                         and   item_ref = '<%= item_ref %>'
                         and   feature_ref = '<%= feature_ref %>'
                         and   contract_ref = '<%= contract_ref %>'
                         and   occur_day = '<%= helperBean.getOccur_day(gregDate) %>'
                       )
                    </sql:query>
                    <sql:resultSet id="rset2">
                      <sql:getColumn position="1" to="end_time_h" />
                      <sql:wasNull>
                        <% pageContext.setAttribute("end_time_h", ""); %>
                      </sql:wasNull>
                      <sql:getColumn position="2" to="end_time_m" />
                      <sql:wasNull>
                        <% pageContext.setAttribute("end_time_m", ""); %>
                      </sql:wasNull>
                      <sql:getColumn position="3" to="start_time_h" />
                      <sql:wasNull>
                        <% pageContext.setAttribute("start_time_h", ""); %>
                      </sql:wasNull>
                      <sql:getColumn position="4" to="start_time_m" />
                      <sql:wasNull>
                        <% pageContext.setAttribute("start_time_m", ""); %>
                      </sql:wasNull>
                    </sql:resultSet>
                    <sql:wasEmpty>
                      <% pageContext.setAttribute("end_time_h", ""); %>
                      <% pageContext.setAttribute("end_time_m", ""); %>
                      <% pageContext.setAttribute("start_time_h", ""); %>
                      <% pageContext.setAttribute("start_time_m", ""); %>
                    </sql:wasEmpty>

                    <% end_time_h = ((String)pageContext.getAttribute("end_time_h")).trim(); %>
                    <% end_time_m = ((String)pageContext.getAttribute("end_time_m")).trim(); %>
                    <% start_time_h = ((String)pageContext.getAttribute("start_time_h")).trim(); %>
                    <% start_time_m = ((String)pageContext.getAttribute("start_time_m")).trim(); %>
                  </sql:statement>

                </if:IfTrue>

                <b>Due</b>&nbsp;
                <%-- For samples check which time to use end time or start time --%>
                <if:IfTrue cond='<%= action_flag.equals("P") %>' >
                  <if:IfTrue cond='<%= end_time_h.equals("") %>' >
                    <%-- Use start time as end time does not exist --%>
                    <if:IfTrue cond='<%= start_time_h.equals("") %>' >
                      <%-- just use date as start time does not exist either --%>
                      <%= helperBean.dispDate( due_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
                    </if:IfTrue>
                    <if:IfTrue cond='<%= ! start_time_h.equals("") %>' >
                      <%= helperBean.dispDate( due_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %> @ <%= start_time_h %> : <%= start_time_m %>
                    </if:IfTrue>
                  </if:IfTrue>

                  <if:IfTrue cond='<%= ! end_time_h.equals("") %>' >
                    <%-- Use end time --%>
                    <%= helperBean.dispDate( due_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %> @ <%= end_time_h %> : <%= end_time_m %>
                  </if:IfTrue>
                </if:IfTrue>
  
                <%-- No check needed for complaints sent to inspect or Defaults --%>
                <if:IfTrue cond='<%= ! action_flag.equals("P") %>' >
                  <% end_time_h = thePage.getField(10).trim(); %>
                  <% end_time_m = thePage.getField(11).trim(); %>
                  <%= helperBean.dispDate( due_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %> @ <%= end_time_h %> : <%= end_time_m %>
                </if:IfTrue>
              </label>
            </td>
          </if:IfTrue>
        </tr>
        <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>
      <%
        }// END WHILE LOOP 
      %>
     
      <%-- If there are no items found --%>
      <if:IfTrue cond='<%= inspListPageSet.getRecordCount() == 0 %>' >
        <tr>
          <td colspan="2">
            <b>No sites available</b>
          </td>
        </tr>
      </if:IfTrue>
      <tr><td>&nbsp;</td></tr>
      <tr>
        <td colspan="2">
          <span class="subscript">
            items <%= inspListPageSet.getMinRecordInPage() %> - <%= inspListPageSet.getMaxRecordInPage() %> of <%= inspListPageSet.getRecordCount() %>
          </span>
        </td>
      </tr>
    </table>
    
    <%-- close database connection --%>
    <sql:closeConnection conn="con1"/>

    <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    <sess:equalsAttribute name="sort_order" match="postcode" >
      <jsp:include page="include/sort_order_post_buttons.jsp" flush="true" />
    </sess:equalsAttribute>
    <sess:equalsAttribute name="sort_order" match="ward" >
      <jsp:include page="include/sort_order_ward_buttons.jsp" flush="true" />
    </sess:equalsAttribute>
    <sess:equalsAttribute name="sort_order" match="area" >
      <jsp:include page="include/sort_order_area_buttons.jsp" flush="true" />
    </sess:equalsAttribute>
    <sess:equalsAttribute name="sort_order" match="date" >
      <jsp:include page="include/sort_order_date_buttons.jsp" flush="true" />
    </sess:equalsAttribute>
    <jsp:include page="include/back_details_buttons.jsp" flush="true" />
    <jsp:include page="include/sched_button.jsp" flush="true" />
    <jsp:include page="include/footer.jsp" flush="true" />

    <input type="hidden" name="page_number" value="<%= inspListPageSet.getCurrentPageNum() %>" />
    
    <input type="hidden" name="input" value="inspList" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
