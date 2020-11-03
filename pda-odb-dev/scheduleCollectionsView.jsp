<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.scheduleCollectionsBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="scheduleCollectionsBean" scope="session" class="com.vsb.scheduleCollectionsBean" />
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
<sess:equalsAttribute name="form" match="scheduleCollections" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%
  // Set the default time zone to where we are, as the time zone
  // returned from sco is GMT+00:00 which is fine but doesn't mentioned
  // BST. So the default timezone has to be set to "Europe/London".
  // Any objects which use the timezone (like SimpleDateFormat) will then
  // be using the correct timezone.
  TimeZone dtz = TimeZone.getTimeZone("Europe/London");
  TimeZone.setDefault(dtz);

  String date;
  String time;
  String time_h;
  String time_m;
  SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
  SimpleDateFormat formatTime = new SimpleDateFormat("HH:mm");
  SimpleDateFormat formatTime_h = new SimpleDateFormat("HH");
  SimpleDateFormat formatTime_m = new SimpleDateFormat("mm");

  Date currentDate = new java.util.Date();
  date = formatDate.format(currentDate);
  time = formatTime.format(currentDate);
  time_h = formatTime_h.format(currentDate);
  time_m = formatTime_m.format(currentDate);
%>

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
  <title>scheduleCollections</title>
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
  <form onSubmit="return singleclick();" action="scheduleCollectionsScript.jsp" method="post">
    <table width="100%" cellpadding="0" cellspacing="0" border="0">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Collection Schedules</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b>
        <jsp:getProperty name="scheduleCollectionsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>

    <sql:connection id="conn" jndiName="java:comp/env/jdbc/pda" />
    <table width="100%" cellpadding="0" cellspacing="0" border="0">
      <tr>
        <td align="center" colspan="2">
          <sql:statement id="stmt" conn="conn">
            <sql:query>
              select site_name_1 from site where site_ref = '<%= recordBean.getSite_ref() %>'
            </sql:query>
            <sql:resultSet id="rseta">
             <sql:getColumn position="1" to="site_name_1" />
              <% recordBean.setSite_name_1((String) pageContext.getAttribute("site_name_1")); %>
             </sql:resultSet>
          </sql:statement>
          <b><jsp:getProperty name="recordBean" property="site_name_1" /></b>
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
    </table>

    <table width="100%" cellpadding="0" cellspacing="2" border="0">
      <sql:statement id="stmt" conn="conn">
        <sql:query>

          <%--
                STEP ONE:
                Return all works order types that have collections on live schedule lists
                or closed schedule lists due today for this site.

                You can link the site_ref to the schedules by joining the compl table with
                the wo_h on the (wo|dest)_suffix and (wo|dest)_ref fields
         --%>

          select
              distinct wo_type.wo_type_desc,
              work_sched_hdr.wo_type_f
          from
              work_sched_hdr,
              wo_type
          where
              work_sched_hdr.schedule_ref in
              (
                select
                    schedule_ref
                from
                    work_schedule
                where
                    wo_key in
                    (
                      select
                          wo_h.wo_key
                      from
                          wo_h, comp
                      where
                          wo_h.wo_suffix = comp.dest_suffix
                          and wo_h.wo_ref = comp.dest_ref
                          and comp.site_ref = '<%= recordBean.getSite_ref() %>'
                    )
              )
              and (work_sched_hdr.status = 'L' or (work_sched_hdr.status = 'C' and work_sched_hdr.schedule_date = '<%= date %>'))
              and wo_type.wo_type_f = work_sched_hdr.wo_type_f

        </sql:query>
        <sql:resultSet id="rset">
          <sql:wasNotNull>
            <sql:getColumn position="1" to="wo_type_desc" />
            <sql:getColumn position="2" to="wo_type_f" />
            <tr>
              <td colspan="2" bgcolor="#3366cc" align="center">
                <h3><font color="white"><%= pageContext.getAttribute("wo_type_desc")%></font></h3>
                </td>
              </tr>
              <tr>
                <td colspan="2">
                  <table width="100%" cellpadding="4" cellspacing="0" border="0">
                    <sql:statement id="stmt2" conn="conn">
                      <sql:query>

                        <%--
                            STEP TWO:
                            For each works order type return all schedules that are live or closed but due today for this site.
                        --%>

                        select
                            work_sched_hdr.schedule_date,
                            work_sched_hdr.collection_day,
                            work_sched_hdr.schedule_ref
                        from
                            work_sched_hdr
                        where
                            work_sched_hdr.schedule_ref in
                            (
                              select
                                  work_schedule.schedule_ref
                              from
                                  work_schedule,
                                  comp,
                                  wo_h
                              where
                                  work_schedule.wo_key = wo_h.wo_key
                                  and wo_h.wo_suffix = comp.dest_suffix
                                  and wo_h.wo_ref = comp.dest_ref
                                  and comp.site_ref = '<%= recordBean.getSite_ref() %>'
                            )
                            and (work_sched_hdr.status = 'L' or (work_sched_hdr.status = 'C' and work_sched_hdr.schedule_date = '<%= date %>'))
                            and work_sched_hdr.wo_type_f = '<%= ((String)pageContext.getAttribute("wo_type_f")).trim() %>'
                        order by
                            work_sched_hdr.schedule_date asc

                      </sql:query>
                      <sql:resultSet id="rset2">
                        <sql:wasNotNull>
                          <sql:getDate position="1" to="schedule_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
                          <sql:getColumn position="2" to="collection_day" />
                          <sql:getColumn position="3" to="schedule_ref" />
                            <tr bgcolor="#ff6600">
                              <td>
                                 Sched: <strong><%= pageContext.getAttribute("schedule_ref")%></strong>
                              </td>
                              <td align="right">
                                <%= helperBean.dispDate((String)pageContext.getAttribute("schedule_date"), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt"))%> - <strong><%= pageContext.getAttribute("collection_day")%></strong>
                              </td>
                            </tr>
                            <sql:statement id="stmt3" conn="conn">
                              <sql:query>

                              <%--
                                  STEP THREE:
                                  For each schedule returned retrieve the individual works order details
                              --%>

                              select
                                  wo_h.wo_ref,
                                  wo_stat.wo_stat_desc
                              from
                                  comp,
                                  wo_h,
                                  wo_stat
                              where
                                  wo_h.wo_ref = comp.dest_ref
                                  and wo_h.wo_suffix = comp.dest_suffix
                                  and wo_h.wo_key in
                                  (
                                    select
                                        work_schedule.wo_key
                                    from
                                        work_schedule
                                    where
                                        work_schedule.schedule_ref = '<%= ((String)pageContext.getAttribute("schedule_ref")).trim()%>'
                                  )
                                  and comp.site_ref= '<%= recordBean.getSite_ref() %>'
                                  and wo_stat.wo_h_stat = wo_h.wo_h_stat

                              </sql:query>
                              <tr>
                                <td colspan="2" align="center">
                                  <table border="0" cellpadding="4" cellspacing="2" width="100%">
                                    <sql:resultSet id="rset3">
                                      <sql:getColumn position="1" to="wo_ref" />
                                      <sql:getColumn position="2" to="wo_h_stat" />
                                      <sql:wasNotNull>
                                        <tr bgcolor="#cccccc">
                                          <td colspan="2">
                                            W/O: <strong><%= pageContext.getAttribute("wo_ref")%></strong> - <%= pageContext.getAttribute("wo_h_stat")%>
                                          </td>
                                        </tr>
                                        <sql:statement id="stmt4" conn="conn">
                                          <sql:query>

                                            <%--
                                                STEP FOUR:
                                                For each works order return the collection details (items and quantity)
                                            --%>

                                            select
                                                comp_sched_item.collection_item,
                                                comp_sched_item.item_quantity
                                            from
                                                comp,
                                                wo_h,
                                                comp_sched_item
                                            where
                                                wo_h.wo_ref = comp.dest_ref
                                                and wo_h.wo_suffix = comp.dest_suffix
                                                and wo_h.wo_key in
                                                (
                                                  select
                                                      work_schedule.wo_key
                                                  from
                                                      work_schedule
                                                  where
                                                      work_schedule.schedule_ref = '<%= ((String)pageContext.getAttribute("schedule_ref")).trim()%>'
                                                )
                                                and site_ref= '<%= recordBean.getSite_ref() %>'
                                                and comp.complaint_no = comp_sched_item.complaint_no
                                                and wo_h.wo_ref = '<%= ((String)pageContext.getAttribute("wo_ref")).trim()%>'

                                          </sql:query>

                                          <sql:resultSet id="rset4">
                                            <sql:getColumn position="1" to="collection_item" />
                                            <sql:getColumn position="2" to="item_quantity" />
                                            <sql:wasNotNull>
                                              <tr valign="top" bgcolor="#eeeeee">
                                                <td width="100%">
                                                  <%= pageContext.getAttribute("collection_item")%>
                                                </td>
                                                <td>
                                                  <%= pageContext.getAttribute("item_quantity")%>
                                                </td>
                                              </tr>
                                            </sql:wasNotNull>
                                          </sql:resultSet>
                                        </sql:statement>
                                      </sql:wasNotNull>
                                    </sql:resultSet>
                                  </table>
                                </td>
                              </tr>
                            </sql:statement>
                          </sql:wasNotNull>
                        <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
                      </sql:resultSet>
                    </sql:statement>
                  </table>
                </td>
              </tr>
            </sql:wasNotNull>
          </sql:resultSet>
          <sql:wasEmpty>
            <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
            <tr>
              <td colspan="2">
                <b>No Collections have been scheduled for this site. </b>
              </td>
            </tr>
            <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
          </sql:wasEmpty>
        </sql:statement>
      <sql:closeConnection conn="conn"/>
    </table>
    <jsp:include page="include/back_button.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="scheduleCollections" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
