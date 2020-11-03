<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfFpnPrintBean, com.vsb.enfActionBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.helperBean, com.vsb.systemKeysBean" %>
<%@ page import="javax.naming.Context, javax.naming.InitialContext" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="enfFpnPrintBean" scope="session" class="com.vsb.enfFpnPrintBean" />
<jsp:useBean id="enfActionBean" scope="session" class="com.vsb.enfActionBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
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
<sess:equalsAttribute name="form" match="enfFpnPrint" value="false">
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
  <title>enfFpnPrint</title>
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
</head>

<%-- This page only has what the fpn_print_page has on it plus an "OK" button --%>
<%-- this is so that it can be printed out and given to the customer. --%>
<body onUnload="">
  <form onSubmit="return singleclick();" action="enfFpnPrintScript.jsp" method="post">
    <%-- obtain the initial context, which holds the server/web.xml environment variables. --%>
    <% Context initCtx = new InitialContext(); %>
    <% Context envCtx = (Context) initCtx.lookup("java:comp/env"); %>

    <%-- Put all values that are going to be used in the <c:import ...> call, into the pageContext --%>
    <%-- So that the <c:import ...> tag can access them. --%>
    <% pageContext.setAttribute("fpn_print_page", (String)envCtx.lookup("fpn_print_page")); %>
    <% pageContext.setAttribute("fpn_ref", recordBean.getEnf_fpn_ref()); %>
    <% pageContext.setAttribute("complaint_no", recordBean.getComplaint_no()); %>

    <%-- Get all the fields which can be used on the FPN print --%>
    <% String tempString = ""; %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- comp --%>
      <sql:query>
        select exact_location, location_name, postcode
        from comp
        where complaint_no = <%= recordBean.getComplaint_no() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("exact_location", helperBean.restrict(tempString, 30)); %>
        <sql:getColumn position="2" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("comp_location_name", tempString); %>
        <sql:getColumn position="3" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("comp_postcode", tempString); %>
        <%-- position --%>
        <% tempString = helperBean.restrict((String)pageContext.getAttribute("comp_location_name"), 21); %>
        <% tempString = tempString + " " + (String)pageContext.getAttribute("comp_postcode"); %>
        <% pageContext.setAttribute("position", tempString); %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("exact_location", ""); %>
        <% pageContext.setAttribute("position", ""); %>
      </sql:wasEmpty>

      <%-- comp_enf --%>
      <sql:query>
        select offence_ref, offence_date, suspect_ref, action_seq,
               offence_time_h, offence_time_m
        from comp_enf
        where complaint_no = <%= recordBean.getComplaint_no() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("offence_ref", tempString); %>

        <sql:getDate position="2" to="field" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = helperBean.dispDate(((String)pageContext.getAttribute("field")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt") ); %>
        <% pageContext.setAttribute("offence_date", tempString); %>

        <sql:getColumn position="3" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("suspect_ref", tempString); %>

        <sql:getColumn position="4" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("action_seq", tempString); %>

        <sql:getColumn position="5" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("offence_time_h", tempString); %>

        <sql:getColumn position="6" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("offence_time_m", tempString); %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("offence_ref", ""); %>
        <% pageContext.setAttribute("offence_date", ""); %>
        <% pageContext.setAttribute("suspect_ref", ""); %>
        <% pageContext.setAttribute("action_seq", ""); %>
        <% pageContext.setAttribute("offence_time_h", ""); %>
        <% pageContext.setAttribute("offence_time_m", ""); %>
      </sql:wasEmpty>

      <%-- Action description and Islington CN number --%>
      <sql:query>
        select description 
        from enf_act
        where action_code = '<%= enfActionBean.getAction_code() %>' 
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("action_desc", helperBean.restrict(tempString, 30)); %>
        <if:IfTrue cond='<%= tempString.length() <= 4 %>' > 
          <% pageContext.setAttribute("cn_number", tempString); %>
        </if:IfTrue> 
        <if:IfTrue cond='<%= tempString.length() > 4 %>' > 
          <% pageContext.setAttribute("cn_number", tempString.substring(0,3)); %>
        </if:IfTrue> 
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("action_desc", ""); %>
        <% pageContext.setAttribute("cn_number", ""); %>
      </sql:wasEmpty>

      <%-- Offence description --%>
      <%-- Find out what version of contender is being run against the database --%>
      <%-- 10/05/2010  TW  Read contender_version from systemKeysBean --%>
      <% String contender_version = systemKeysBean.getContender_version(); %>
      
      <sql:query>
        <if:IfTrue cond='<%= contender_version.equals("v7") || contender_version.equals("") %>' >
          select lookup_text
          from allk
          where lookup_func = 'ENFDET'
          and   lookup_code = '<%= pageContext.getAttribute("offence_ref") %>'
        </if:IfTrue>
        <if:IfTrue cond='<%= contender_version.equals("v8") %>' >
          select offence_desc
          from enf_offence
          where offence_ref = '<%= pageContext.getAttribute("offence_ref") %>'
        </if:IfTrue>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("offence_desc", tempString); %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("offence_desc", ""); %>
      </sql:wasEmpty>

      <%-- enf_action --%>
      <sql:query>
        select aut_officer, action_ref
        from enf_action
        where complaint_no = <%= recordBean.getComplaint_no() %>
        and   action_seq = <%= pageContext.getAttribute("action_seq") %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("aut_officer", tempString); %>
        <sql:getColumn position="2" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("action_ref", tempString); %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("aut_officer", ""); %>
        <% pageContext.setAttribute("action_ref", ""); %>
      </sql:wasEmpty>

      <%-- enf_payment_config --%>
      <sql:query>
        select check_amount_1, no_of_days_1,
               check_amount_2, no_of_days_2,
               check_amount_3, no_of_days_3,
               check_amount_4, no_of_days_4,
               check_amount_5, no_of_days_5
        from enf_payment_config
        where init_action_ref = '<%= pageContext.getAttribute("action_ref") %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("check_amount_1", tempString); %>
        <sql:getColumn position="2" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("no_of_days_1", tempString); %>

        <sql:getColumn position="3" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("check_amount_2", tempString); %>
        <sql:getColumn position="4" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("no_of_days_2", tempString); %>

        <sql:getColumn position="5" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("check_amount_3", tempString); %>
        <sql:getColumn position="6" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("no_of_days_3", tempString); %>

        <sql:getColumn position="7" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("check_amount_4", tempString); %>
        <sql:getColumn position="8" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("no_of_days_4", tempString); %>

        <sql:getColumn position="9" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("check_amount_5", tempString); %>
        <sql:getColumn position="10" to="field" />
        <sql:wasNull>
          <% pageContext.setAttribute("field", ""); %>
        </sql:wasNull>
        <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
        <% pageContext.setAttribute("no_of_days_5", tempString); %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("check_amount_1", ""); %>
        <% pageContext.setAttribute("no_of_days_1", ""); %>
        <% pageContext.setAttribute("check_amount_2", ""); %>
        <% pageContext.setAttribute("no_of_days_2", ""); %>
        <% pageContext.setAttribute("check_amount_3", ""); %>
        <% pageContext.setAttribute("no_of_days_3", ""); %>
        <% pageContext.setAttribute("check_amount_4", ""); %>
        <% pageContext.setAttribute("no_of_days_4", ""); %>
        <% pageContext.setAttribute("check_amount_5", ""); %>
        <% pageContext.setAttribute("no_of_days_5", ""); %>
      </sql:wasEmpty>

      <%-- Do the checks to work out the value of the full_charge and discount_charge. --%>
      <% pageContext.setAttribute("full_charge", ""); %>
      <% pageContext.setAttribute("discount_charge", ""); %>
      <if:IfTrue cond='<%= !((String)pageContext.getAttribute("check_amount_1")).equals("") %>' >
        <% pageContext.setAttribute("discount_charge", pageContext.getAttribute("check_amount_1")); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("no_of_days_1")).equals("9999") %>' >
        <% pageContext.setAttribute("full_charge", pageContext.getAttribute("check_amount_1")); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("no_of_days_2")).equals("9999") %>' >
        <% pageContext.setAttribute("full_charge", pageContext.getAttribute("check_amount_2")); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("no_of_days_3")).equals("9999") %>' >
        <% pageContext.setAttribute("full_charge", pageContext.getAttribute("check_amount_3")); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("no_of_days_4")).equals("9999") %>' >
        <% pageContext.setAttribute("full_charge", pageContext.getAttribute("check_amount_4")); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("no_of_days_5")).equals("9999") %>' >
        <% pageContext.setAttribute("full_charge", pageContext.getAttribute("check_amount_5")); %>
      </if:IfTrue>

      <%-- enf_suspect --%>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("suspect_ref")).equals("") %>' >
        <% pageContext.setAttribute("title", ""); %>
        <% pageContext.setAttribute("surname", ""); %>
        <% pageContext.setAttribute("fstname", ""); %>
        <% pageContext.setAttribute("midname", ""); %>
        <% pageContext.setAttribute("dob", ""); %>
        <% pageContext.setAttribute("build_no", ""); %>
        <% pageContext.setAttribute("build_name", ""); %>
        <% pageContext.setAttribute("addr1", ""); %>
        <% pageContext.setAttribute("addr2", ""); %>
        <% pageContext.setAttribute("addr3", ""); %>
        <% pageContext.setAttribute("postcode", ""); %>
        <% pageContext.setAttribute("company_ref", ""); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= !((String)pageContext.getAttribute("suspect_ref")).equals("") %>' >
        <sql:query>
          select title, surname, fstname, midname, dob,
            build_no, build_name, addr1, addr2, addr3, postcode,
            company_ref
          from enf_suspect
          where suspect_ref = <%= pageContext.getAttribute("suspect_ref") %>
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("title", tempString); %>

          <sql:getColumn position="2" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("surname", tempString); %>

          <sql:getColumn position="3" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("fstname", tempString); %>

          <sql:getColumn position="4" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("midname", tempString); %>

          <sql:getDate position="5" to="field" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = helperBean.dispDate(((String)pageContext.getAttribute("field")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt") ); %>
          <% pageContext.setAttribute("dob", tempString); %>

          <sql:getColumn position="6" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("build_no", tempString); %>

          <sql:getColumn position="7" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("build_name", helperBean.restrict(tempString, 30)); %>

          <sql:getColumn position="8" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("addr1", helperBean.restrict(tempString, 30)); %>

          <sql:getColumn position="9" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("addr2", helperBean.restrict(tempString, 30)); %>

          <sql:getColumn position="10" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("addr3", helperBean.restrict(tempString, 30)); %>

          <sql:getColumn position="11" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("postcode", tempString); %>

          <sql:getColumn position="12" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("company_ref", tempString); %>
        </sql:resultSet>
        <sql:wasEmpty>
          <% pageContext.setAttribute("title", ""); %>
          <% pageContext.setAttribute("surname", ""); %>
          <% pageContext.setAttribute("fstname", ""); %>
          <% pageContext.setAttribute("midname", ""); %>
          <% pageContext.setAttribute("dob", ""); %>
          <% pageContext.setAttribute("build_no", ""); %>
          <% pageContext.setAttribute("build_name", ""); %>
          <% pageContext.setAttribute("addr1", ""); %>
          <% pageContext.setAttribute("addr2", ""); %>
          <% pageContext.setAttribute("addr3", ""); %>
          <% pageContext.setAttribute("postcode", ""); %>
          <% pageContext.setAttribute("company_ref", ""); %>
        </sql:wasEmpty>
      </if:IfTrue>

      <%-- enf_company --%>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("company_ref")).equals("") %>' >
        <% pageContext.setAttribute("company_name", ""); %>
      </if:IfTrue>
      <if:IfTrue cond='<%= !((String)pageContext.getAttribute("company_ref")).equals("") %>' >
        <sql:query>
          select company_name
          from enf_company
          where company_ref = <%= pageContext.getAttribute("company_ref") %>
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="field" />
          <sql:wasNull>
            <% pageContext.setAttribute("field", ""); %>
          </sql:wasNull>
          <% tempString = ((String)pageContext.getAttribute("field")).trim(); %>
          <% pageContext.setAttribute("company_name", helperBean.restrict(tempString, 30)); %>
        </sql:resultSet>
        <sql:wasEmpty>
          <% pageContext.setAttribute("company_name", ""); %>
        </sql:wasEmpty>
      </if:IfTrue>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- show the fpn print page, set in server.xml context. --%>
    <c:import url="fpn_print_pages/${fpn_print_page}.jsp">
      <c:param name="fpn_ref" value="${fpn_ref}" />
      <c:param name="complaint_no" value="${complaint_no}" />
      <c:param name="exact_location" value="${exact_location}" />
      <c:param name="position" value="${position}" />
      <c:param name="offence_ref" value="${offence_ref}" />
      <c:param name="offence_desc" value="${offence_desc}" />
      <c:param name="offence_time" value="${offence_time_h}:${offence_time_m}" />
      <c:param name="offence_date" value="${offence_date}" />
      <c:param name="aut_officer" value="${aut_officer}" />
      <c:param name="title" value="${title}" />
      <c:param name="surname" value="${surname}" />
      <c:param name="fstname" value="${fstname}" />
      <c:param name="midname" value="${midname}" />
      <c:param name="dob" value="${dob}" />
      <c:param name="build_no" value="${build_no}" />
      <c:param name="build_name" value="${build_name}" />
      <c:param name="addr1" value="${addr1}" />
      <c:param name="addr2" value="${addr2}" />
      <c:param name="addr3" value="${addr3}" />
      <c:param name="postcode" value="${postcode}" />
      <c:param name="company_name" value="${company_name}" />
      <c:param name="full_charge" value="${full_charge}" />
      <c:param name="discount_charge" value="${discount_charge}" />
      <c:param name="action_desc" value="${action_desc}" />
      <c:param name="cn_number" value="${cn_number}" />
    </c:import>

    <jsp:include page="include/ok_button.jsp" flush="true" />
    <input type="hidden" name="input" value="enfFpnPrint" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
