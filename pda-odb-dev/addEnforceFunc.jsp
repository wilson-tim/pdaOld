<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.dbb.SNoBean, com.utils.date.vsbCalendar" %>
<%@ page import="com.vsb.recordBean, com.vsb.systemKeysBean" %>
<%@ page import="com.vsb.loginBean" %>
<%@ page import="com.vsb.addCustDetailsBean" %>
<%@ page import="com.vsb.helperBean" %>
<%@ page import="com.vsb.textBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="addCustDetailsBean" scope="session" class="com.vsb.addCustDetailsBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="textBean" scope="session" class="com.vsb.textBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addEnforceFunc" value="false">
  addEnforceFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addEnforceFunc">
  <%-- Set up the date variables --%>
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
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- CREATING A COMPLAINT --%>

    <%-- Is there any text to add --%>
    <% String text_flag = "Y"; %>

    <%-- Create the complaint_no to use --%>
    <% int complaint_no = 0; %>

    <%-- Is there any text to add --%>
    <if:IfTrue cond='<%= textBean.getText() == null || textBean.getText().equals("") %>' >
      <% text_flag = "N"; %>
    </if:IfTrue>

    <%-- Get the last complaint serial number --%>
    <sql:query>
      select serial_no
      from s_no
      where sn_func = 'COMP'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="complaint_no" />
    </sql:resultSet>

    <%-- Create the next complaint serial number --%>
    <% complaint_no = Integer.parseInt((String)pageContext.getAttribute("complaint_no")); %>

    <%-- Is this a standalone enforcement complaint or one attached to a complaint --%>
    <% boolean standalone = false; %>
    <%-- Initialise the Complaint_complaint_no and Enforce_complaint_no --%>
    <% recordBean.setComplaint_complaint_no(""); %>
    <% recordBean.setEnforce_complaint_no(""); %>
    <%-- If this is NOT a standalone enforcement complaint, then we need to add the --%>
    <%-- complaint number to the record bean for the suspect --%>
    <if:IfTrue cond='<%= ! recordBean.getService_c().equals(recordBean.getEnf_service()) %>'>
      <% recordBean.setComplaint_complaint_no( recordBean.getComplaint_no() ); %>
      <% recordBean.setEnforce_complaint_no( String.valueOf(complaint_no) ); %>
      <% standalone = false; %>
    </if:IfTrue>
    <%-- If this is a standalone enforcement complaint, then we need to add the --%>
    <%-- complaint number to the record bean for the violia link --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getEnf_service()) %>'>
      <% recordBean.setComplaint_no( String.valueOf(complaint_no) ); %>
      <% standalone = true; %>
    </if:IfTrue>

    <%-- Update the old complaint serial number with the next one --%>
    <sql:query>
      update s_no
      set serial_no = <%= complaint_no %> + 1
      where sn_func = 'COMP'
    </sql:query>
    <sql:execute />

    <%-- Set the notice type --%>
    <% String notice_type = "N"; %>
  
    <%-- Get recvd_by --%>
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'HAND_HELD_REC_BY'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="recvd_by" />
    </sql:resultSet>
  
    <%-- get the locn_type to see if the location is part of another location. --%>
    <sql:query>
      select locn_type
      from locn
      where location_c = '<%= recordBean.getLocation_c() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="locn_type" />
    </sql:resultSet>
    <% int locn_type = Integer.parseInt((String)pageContext.getAttribute("locn_type")); %>
  
    <%-- set the location_desc and the location_name if any --%>
    <% String location_name = ""; %>
    <% String location_desc = ""; %>
    <% location_name = recordBean.getLocation_name(); %>
    <% String comp_loc_desc_town = "N"; %>
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'COMP_LOC_DESC_TOWN'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="comp_loc_desc_town" />
      <sql:wasNotNull>
        <% comp_loc_desc_town = ((String)pageContext.getAttribute("comp_loc_desc_town")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>

    <sql:query>
      select site_section, townname
      from site
      where site_ref = '<%= recordBean.getSite_ref() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="site_section" />
      <sql:wasNull>
        <% pageContext.setAttribute("site_section", ""); %>
      </sql:wasNull>
      <sql:getColumn position="2" to="townname" />
      <sql:wasNull>
        <% pageContext.setAttribute("townname", ""); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("site_section", ""); %>
      <% pageContext.setAttribute("townname", ""); %>
    </sql:wasEmpty>
    <if:IfTrue cond='<%= comp_loc_desc_town.equals("Y") %>'>
      <% location_desc = DbUtils.cleanString(((String)pageContext.getAttribute("townname")).trim()); %>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! comp_loc_desc_town.equals("Y") %>'>
      <% location_desc = DbUtils.cleanString(((String)pageContext.getAttribute("site_section")).trim()); %>
    </if:IfTrue>

    <%-- Set up the build_name (long_build_name) in the form "build_sub_no, build_sub_name, build_name" --%>
    <% String long_build_name = ""; %>
    <if:IfTrue cond='<%= ! recordBean.getBuild_sub_no().equals("") %>' >
      <% long_build_name = recordBean.getBuild_sub_no(); %>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! recordBean.getBuild_sub_name().equals("") %>' >
      <if:IfTrue cond='<%= ! long_build_name.trim().equals("") %>' >
        <% long_build_name = long_build_name + ", "; %>
      </if:IfTrue>
      <% long_build_name = long_build_name + recordBean.getBuild_sub_name(); %>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! recordBean.getBuild_name().equals("") %>' >
      <if:IfTrue cond='<%= ! long_build_name.trim().equals("") %>' >
        <% long_build_name = long_build_name + ", "; %>
      </if:IfTrue>
      <% long_build_name = long_build_name + recordBean.getBuild_name(); %>
    </if:IfTrue>
  
    <%-- Get easting and northing for the site --%>
    <sql:query>
      select easting, northing, easting_end, northing_end
      from site_detail
      where site_ref = '<%= recordBean.getSite_ref() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="easting" />
      <sql:wasNull>
        <% pageContext.setAttribute("easting", ""); %>
      </sql:wasNull>
  
      <sql:getColumn position="2" to="northing" />
      <sql:wasNull>
        <% pageContext.setAttribute("northing", ""); %>
      </sql:wasNull>
  
      <sql:getColumn position="3" to="easting_end" />
      <sql:wasNull>
        <% pageContext.setAttribute("easting_end", ""); %>
      </sql:wasNull>
  
      <sql:getColumn position="4" to="northing_end" />
      <sql:wasNull>
        <% pageContext.setAttribute("northing_end", ""); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("easting", ""); %>
      <% pageContext.setAttribute("northing", ""); %>
      <% pageContext.setAttribute("easting_end", ""); %>
      <% pageContext.setAttribute("northing_end", ""); %>
    </sql:wasEmpty>
  
    <%-- get the enf comp code --%>
    <sql:query>
      select c_field from keys
      where service_c = 'ALL'
      and keyname = 'ENF_COMP_CODE'
    </sql:query>
     <sql:resultSet id="rset">
      <sql:getColumn position="1" to="comp_code" />
    </sql:resultSet>
  
    <%-- get the enf item --%>
    <sql:query>
      select c_field from keys
      where service_c = 'ALL'
      and keyname = 'ENF_ITEM'
    </sql:query>
     <sql:resultSet id="rset">
      <sql:getColumn position="1" to="item_ref" />
    </sql:resultSet>
  
    <%-- get the enf service --%>
    <sql:query>
      select c_field from keys
      where service_c = 'ALL'
      and keyname = 'ENF_SERVICE'
    </sql:query>
     <sql:resultSet id="rset">
      <sql:getColumn position="1" to="service_c" />
    </sql:resultSet>
  
    <%-- get the enforce contract_ref --%>
    <sql:query>
      select contract_ref
      from cont
      where service_c = '<%= ((String)pageContext.getAttribute("service_c")).trim() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="contract_ref" />
    </sql:resultSet>
  
    <%-- get the enforce feature_ref --%>
    <sql:query>
      select feature_ref
      from it_f
      where item_ref = '<%= ((String)pageContext.getAttribute("item_ref")).trim() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="feature_ref" />
    </sql:resultSet>

    <%-- Get the ENFORCE's patrol area  as the patrol area will currently be the complaints --%>
    <sql:query>
      SELECT pa_area
      FROM site_pa
      WHERE site_ref = '<%= recordBean.getSite_ref() %>'
      AND   pa_func = 'ENFORC'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="pa_area" />
      <% recordBean.setPa_area((String) pageContext.getAttribute("pa_area")); %>
    </sql:resultSet>
 
    <%-- Set up the remarks --%>
    <% String remarks_1 = ""; %>
    <% String remarks_2 = ""; %>
    <% String remarks_3 = ""; %>
    
    <%-- The text should be split into 70 char lines, and there should be a --%>
    <%-- single record for each line. --%>
    <%
      String tempRemarks = "";
      tempRemarks = textBean.getRemarks().toUpperCase();
      tempRemarks = tempRemarks.replace('\n',' ');
      tempRemarks = tempRemarks.replace('\r',' ');

      String allText = tempRemarks.trim();
      String line;
      int count = 1;
      int lineIndex;
      boolean flag = true;
      do {
        if (allText.length() <= 70) {
          line = allText;
          flag = false;
        } else {
          lineIndex = allText.lastIndexOf(" ", 70);
          // Space not found so use the whole 70
          if (lineIndex == -1) {
            lineIndex = 70;
          } else {
            lineIndex = lineIndex + 1;
          }
          line = allText.substring(0,lineIndex);
          allText = allText.substring(lineIndex);
        }

        if (count == 1) {
          remarks_1 = DbUtils.cleanString(line);
        } else if (count == 2) {
          remarks_2 = DbUtils.cleanString(line);
        } else if (count == 3) {
          remarks_3 = DbUtils.cleanString(line);
        }

        count = count + 1;
      } while (flag == true);
    %>
 
    <sql:query>
      insert into comp (
        complaint_no,
        date_entered,
        ent_time_h,
        ent_time_m,
        entered_by,
        recvd_by,
        site_ref,
        location_c,
        build_no,
        build_sub_no,
        build_name,
        build_sub_name,
        location_name,
        location_desc,
        area_ward_desc,
        postcode,
        exact_location,
        details_1,
        details_2,
        details_3,
        notice_type,
        service_c,
        text_flag,
        comp_code,
        item_ref,
        feature_ref,
        contract_ref,
        occur_day,
        round_c,
        pa_area,
        action_flag,
        dest_suffix,
        easting,
        northing,
        easting_end,
        northing_end
      ) values (
        '<%= complaint_no %>',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        '<%= ((String)pageContext.getAttribute("recvd_by")).trim() %>',
        '<%= recordBean.getSite_ref() %>',
        '<%= recordBean.getLocation_c() %>',
        '<%= recordBean.getBuild_no() %>',
        '<%= recordBean.getBuild_sub_no() %>',
        '<%= long_build_name %>',
        '<%= recordBean.getBuild_sub_name() %>',
        '<%= location_name %>',
        '<%= location_desc %>',
        '<%= recordBean.getArea_ward_desc() %>',
        '<%= recordBean.getPostcode() %>',
        '<%= textBean.getExact_location().toUpperCase() %>',
        '<%= remarks_1 %>',
        '<%= remarks_2 %>',
        '<%= remarks_3 %>',
        '<%= notice_type %>',
        '<%= ((String)pageContext.getAttribute("service_c")).trim() %>',
        '<%= text_flag %>',
        '<%= ((String)pageContext.getAttribute("comp_code")).trim() %>',
        '<%= ((String)pageContext.getAttribute("item_ref")).trim() %>',
        '<%= ((String)pageContext.getAttribute("feature_ref")).trim() %>',
        '<%= ((String)pageContext.getAttribute("contract_ref")).trim() %>',
        '<%= recordBean.getOccur_day()%>',
        '<%= recordBean.getRound_c()%>',
        '<%= recordBean.getPa_area()%>',
        'N',
        null,
        <if:IfTrue cond = '<%= ((String)pageContext.getAttribute("easting")).trim().equals("") %>'>
          null,
        </if:IfTrue>
        <if:IfTrue cond = '<%= !((String)pageContext.getAttribute("easting")).trim().equals("") %>'>
          <%= ((String)pageContext.getAttribute("easting")).trim() %>,
        </if:IfTrue>
        <if:IfTrue cond = '<%= ((String)pageContext.getAttribute("northing")).trim().equals("") %>'>
          null,
        </if:IfTrue>
        <if:IfTrue cond = '<%= !((String)pageContext.getAttribute("northing")).trim().equals("") %>'>
          <%= ((String)pageContext.getAttribute("northing")).trim() %>,
        </if:IfTrue>
        <if:IfTrue cond = '<%= ((String)pageContext.getAttribute("easting_end")).trim().equals("") %>'>
          null,
        </if:IfTrue>
        <if:IfTrue cond='<%= !((String)pageContext.getAttribute("easting_end")).trim().equals("") %>'>
          <%= ((String)pageContext.getAttribute("easting_end")).trim() %>,
        </if:IfTrue>
        <if:IfTrue cond='<%= ((String)pageContext.getAttribute("northing_end")).trim().equals("") %>'>
          null
        </if:IfTrue>
        <if:IfTrue cond='<%= !((String)pageContext.getAttribute("northing_end")).trim().equals("") %>'>
          <%= ((String)pageContext.getAttribute("northing_end")).trim() %>
        </if:IfTrue>
      )
    </sql:query>
    <sql:execute />

    <%-- If the enforcement is a standalone enforcement record add a customer record to it. --%>
    <%-- If it is linked to a complaint use the complaints already added customer for the complaint. --%>
    <% String comp_customer_no = ""; %>
    <% int customer_no = 0; %>
    <if:IfTrue cond='<%= standalone == true %>'>
      <%-- Adding the customer record --%>
      <%-- get the next customer.customer_no from s_no table --%>
      <sql:query>
        select serial_no
        from s_no
        where sn_func = 'customer'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="customer_no" />
      </sql:resultSet>
      <% customer_no = Integer.parseInt((String)pageContext.getAttribute("customer_no")); %>
    
      <%-- update the s_no table with the next customer.customer_no --%>
      <sql:query>
        update s_no
        set serial_no = <%= customer_no %> + 1
        where sn_func = 'customer'
      </sql:query>
      <sql:execute />
    
      <%-- Needs further work if customer is "E" and/or there is an address to add --%>
      <if:IfTrue cond='<%= addCustDetailsBean.getConfirm().equals("No") || ((String)application.getInitParameter("use_cust_dets")).trim().equals("N") %>' >
        <%-- Get recvd_by --%>
        <sql:query>
          select full_name
          from pda_user
          where user_name = '<%= loginBean.getUser_name() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="full_name" />
          <sql:wasNull>
            <% pageContext.setAttribute("full_name", "NO NAME"); %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% pageContext.setAttribute("full_name", "NO NAME"); %>
        </sql:wasEmpty>
    
        <sql:query>
          insert into customer (
            customer_no,
            compl_init,
            compl_name,
            compl_surname,
            int_ext_flag
          ) values (
            <%= customer_no %>,
            null,
            '<%= DbUtils.cleanString(helperBean.firstName( ((String)pageContext.getAttribute("full_name")).trim() ).toUpperCase()) %>',
            '<%= DbUtils.cleanString(helperBean.surname( ((String)pageContext.getAttribute("full_name")).trim() ).toUpperCase()) %>',
            'I'
          )
        </sql:query>
        <sql:execute />
      </if:IfTrue>
      <if:IfTrue cond='<%= addCustDetailsBean.getConfirm().equals("Yes") %>' >
        <%-- Set up the compl_build_name (compl_long_build_name) in the --%>
        <%-- form "compl_build_sub_no, compl_build_sub_name, compl_build_name" --%>
        <% String compl_long_build_name = ""; %>
        <if:IfTrue cond='<%= ! recordBean.getCompl_build_sub_no().equals("") %>' >
          <% compl_long_build_name = recordBean.getCompl_build_sub_no(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= ! recordBean.getCompl_build_sub_name().equals("") %>' >
          <if:IfTrue cond='<%= ! compl_long_build_name.trim().equals("") %>' >
            <% compl_long_build_name = compl_long_build_name + ", "; %>
          </if:IfTrue>
          <% compl_long_build_name = compl_long_build_name + recordBean.getCompl_build_sub_name(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= ! recordBean.getCompl_build_name().equals("") %>' >
          <if:IfTrue cond='<%= ! compl_long_build_name.trim().equals("") %>' >
            <% compl_long_build_name = compl_long_build_name + ", "; %>
          </if:IfTrue>
          <% compl_long_build_name = compl_long_build_name + recordBean.getCompl_build_name(); %>
        </if:IfTrue>
        <sql:query>
          insert into customer (
            customer_no,
            compl_init,
            compl_name,
            compl_surname,
            compl_site_ref,
            compl_location_c,
            compl_build_no,
            compl_build_name,
            compl_addr2,
            compl_addr3,
            compl_addr4,
            compl_postcode,
            compl_phone,
            compl_email,
            int_ext_flag
          ) values (
            <%= customer_no %>,
            '<%= recordBean.getCompl_init().toUpperCase() %>',
            '<%= recordBean.getCompl_name().toUpperCase() %>',
            '<%= recordBean.getCompl_surname().toUpperCase() %>',
            '<%= recordBean.getCompl_site_ref() %>',
            '<%= recordBean.getCompl_location_c() %>',
            '<%= recordBean.getCompl_build_no() %>',
            '<%= compl_long_build_name.toUpperCase() %>',
            '<%= recordBean.getCompl_addr2().toUpperCase() %>',
            '<%= recordBean.getCompl_addr3().toUpperCase() %>',
            '<%= recordBean.getCompl_addr4().toUpperCase() %>',
            '<%= recordBean.getCompl_postcode().toUpperCase() %>',
            '<%= recordBean.getCompl_phone() %>',
            '<%= recordBean.getCompl_email() %>',
            '<%= recordBean.getInt_ext_flag() %>'
          )
        </sql:query>
        <sql:execute />
      </if:IfTrue>
    </if:IfTrue>
    <if:IfTrue cond='<%= standalone == false %>'>
      <%-- Get the linked complaints customer --%>
      <sql:query>
        select customer_no
        from comp_clink
        where complaint_no = '<%= recordBean.getComplaint_complaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="comp_customer_no" />
        <sql:wasNull>
          <% pageContext.setAttribute("comp_customer_no", ""); %>
        </sql:wasNull>
        <% comp_customer_no = ((String)pageContext.getAttribute("comp_customer_no")).trim(); %>
      </sql:resultSet>
    </if:IfTrue>
  
    <%-- Link the customer to the enforcement. Use the complaints if it is not a standalone enforcement, --%>
    <%-- otherwise use the just created customer. --%> 
    <%-- set the customer satisfation flag --%>
    <% String cs_flag = ""; %>
    <sql:query>
      select c_field
      from keys
      where keyname = 'CS_FLAG'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="cs_flag" />
    </sql:resultSet>
  
    <% cs_flag = ((String)pageContext.getAttribute("cs_flag")).trim(); %>
  
    <sql:query>
      insert into comp_clink (
        complaint_no,
        customer_no,
        username,
        seq_no,
        date_added,
        time_added_h,
        time_added_m,
        cust_satisfaction
      ) values (
        '<%= complaint_no %>',
        <if:IfTrue cond='<%= standalone == true %>'>
          '<%= customer_no %>',
        </if:IfTrue>
        <if:IfTrue cond='<%= standalone == false %>'>
          '<%= comp_customer_no %>',
        </if:IfTrue>
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        '1',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= cs_flag %>'
      )
    </sql:query>
    <sql:execute />

    <%-- add additional complaint tables --%>
 
    <%-- Add Any text to a non standalone enforcement, the standalone one will have this added --%>
    <%-- with the addTextFunc. --%>
    <if:IfTrue cond='<%= standalone == false %>'>
      <%-- set the comp_seq number value --%>
      <% pageContext.setAttribute("max_comp_seq_no", "0"); %>
      <% int comp_seq = 1; %>
      <sql:query>
        select max(seq)
        from comp_text
        where complaint_no = <%= complaint_no %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="max_comp_seq_no" />
        <sql:wasNull>
          <% pageContext.setAttribute("max_comp_seq_no", "0"); %>
        </sql:wasNull>
      </sql:resultSet>
      <% comp_seq = Integer.parseInt((String)pageContext.getAttribute("max_comp_seq_no")) + 1; %>
  
      <%-- The text should be split into 56 char lines, and there should be a --%>
      <%-- single record for each line. --%>
      <%
        String tempTextIn = "";
        tempTextIn = textBean.getText();
        tempTextIn = tempTextIn.replace('\n',' ');
        tempTextIn = tempTextIn.replace('\r',' ');
  
        String allTextComp = tempTextIn.trim();
        String lineComp;
        int lineIndexComp;
        boolean flagComp = true;
        do {
          if (allTextComp.length() <= 56) {
            lineComp = allTextComp;
            flagComp = false;
          } else {
            lineIndexComp = allTextComp.lastIndexOf(" ", 56);
            // Space not found so use the whole 56
            if (lineIndexComp == -1) {
              lineIndexComp = 56;
            } else {
              lineIndexComp = lineIndexComp + 1;
            }
            lineComp = allTextComp.substring(0,lineIndexComp);
            allTextComp = allTextComp.substring(lineIndexComp);
          }
        %>
          <sql:query>
            insert into comp_text (
              complaint_no,
              seq,
              username,
              doa,
              time_entered_h,
              time_entered_m,
              txt
            ) values (
              <%= complaint_no %>,
              <%= comp_seq %>,
              '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
              '<%= date %>',
              '<%= time_h %>',
              '<%= time_m %>',
              '<%= DbUtils.cleanString(lineComp) %>'
            )
          </sql:query>
          <sql:execute />
      <%
          comp_seq = comp_seq + 1;
        } while (flagComp == true);
      %>
    </if:IfTrue>
 
    <%-- Add generic comp_enf data --%>
  
    <%-- get the initial status --%>
    <sql:query>
      select c_field from keys
      where service_c = 'ALL'
      and keyname = 'ENF_INITIAL_STATUS'
    </sql:query>
     <sql:resultSet id="rset">
      <sql:getColumn position="1" to="status" />
    </sql:resultSet>
 
    <sql:query>
      insert into comp_enf (
        complaint_no,
        law_ref,
        offence_ref,
        offence_date,
        offence_time_h,
        offence_time_m,
        inv_officer,
        enf_officer,
        enf_status,
        actions,
        car_id,
        source_ref
      ) values (
        '<%= complaint_no %>',
        '<%= recordBean.getLaw() %>',
        '<%= recordBean.getOffence() %>',
        '<%= recordBean.getOffence_date() %>',
        <if:IfTrue cond='<%= ! recordBean.getOffence_time_h().equals("") %>'>
          '<%= recordBean.getOffence_time_h() %>',
        </if:IfTrue>
        <if:IfTrue cond='<%= recordBean.getOffence_time_h().equals("") %>'>
          null,
        </if:IfTrue>
        <if:IfTrue cond='<%= ! recordBean.getOffence_time_m().equals("") %>'>
          '<%= recordBean.getOffence_time_m() %>',
        </if:IfTrue>
        <if:IfTrue cond='<%= recordBean.getOffence_time_m().equals("") %>'>
          null,
        </if:IfTrue>
        '<%= recordBean.getInvOff()%>',
        '<%= recordBean.getEnfOff()%>',
        '<%= ((String)pageContext.getAttribute("status")).trim() %>',
        0,
        '<%= recordBean.getVehicle_reg().toUpperCase() %>',
        <if:IfTrue cond='<%= standalone == false %>'>
          '<%= recordBean.getComplaint_complaint_no() %>'
        </if:IfTrue>
        <if:IfTrue cond='<%= standalone == true %>'>
          null
        </if:IfTrue>
      )
    </sql:query>
    <sql:execute />

    <%-- For Contender v8 add the comp_enf_link table entry if not a standalone complaint --%>
    <%-- 10/05/2010  TW  Read contender_version from systemKeysBean --%>
    <if:IfTrue cond='<%= systemKeysBean.getContender_version().equals("v8") %>' >
      <if:IfTrue cond='<%= standalone == false %>'>
        <sql:query>
          insert into comp_enf_link (
            enf_complaint_no,
            source_complaint
          )
          values (
            '<%= complaint_no %>',
            '<%= recordBean.getComplaint_complaint_no() %>'
          )
        </sql:query>
        <sql:execute />
      </if:IfTrue>
    </if:IfTrue>

    <%-- Adding the additional enforcement tables only --%>
    <sql:query>
      insert into comp_destination (complaint_no)
      values ('<%= complaint_no %>')
    </sql:query>
    <sql:execute />

    <%-- Insert a new diry record for the enforcement --%>
    <%-- get the diry_ref of the complaint that this enforcement is linked to --%>
    <%-- or it will be blank if a standalone enforcement. --%>
    <if:IfTrue cond='<%= standalone == false %>'>
      <sql:query>
        select diry_ref
        from diry
        where source_flag = 'C'
        and   source_ref = '<%= recordBean.getComplaint_complaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="comp_diry_ref" />
      </sql:resultSet>
      <sql:wasEmpty>
        <%-- This is a standalone enforcement --%>
        <% pageContext.setAttribute("comp_diry_ref", ""); %>
      </sql:wasEmpty>
    </if:IfTrue>
    <if:IfTrue cond='<%= standalone == true %>'>
      <% pageContext.setAttribute("comp_diry_ref", ""); %>
    </if:IfTrue>
  
    <%-- get the next diry.diry_ref from s_no table --%>
    <sql:query>
      select serial_no
      from s_no
      where sn_func = 'diry'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="enf_diry_ref" />
    </sql:resultSet>
    <% int enf_diry_ref = Integer.parseInt((String)pageContext.getAttribute("enf_diry_ref")); %>
  
    <%-- update the s_no table with the next diry.diry_ref --%>
    <sql:query>
      update s_no
      set serial_no = <%= enf_diry_ref %> + 1
      where sn_func = 'diry'
    </sql:query>
    <sql:execute />
  
    <%-- Insert a new diry record for the enforcement --%>
    <sql:query>
      insert into diry (
        diry_ref,
        prev_record,
        source_flag,
        source_ref,
        source_date,
        source_time_h,
        source_time_m,
        source_user,
        site_ref,
        item_ref,
        contract_ref,
        inspect_ref,
        inspect_seq,
        feature_ref,
        pa_area,
        action_flag,
        dest_flag,
        dest_date,
        dest_time_h,
        dest_time_m,
        dest_user
      ) values (
        '<%= enf_diry_ref %>',
        '<%= ((String)pageContext.getAttribute("comp_diry_ref")).trim() %>',
        'C',
        '<%= complaint_no %>',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        '<%= recordBean.getSite_ref() %>',
        '<%= ((String)pageContext.getAttribute("item_ref")).trim() %>',
        '<%= ((String)pageContext.getAttribute("contract_ref")).trim() %>',
        null,
        null,
        '<%= ((String)pageContext.getAttribute("feature_ref")).trim() %>',
        '<%= recordBean.getPa_area() %>',
        'C',
        'C',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>'
      )
    </sql:query>
    <sql:execute />
  
  </sql:statement>
  <sql:closeConnection conn="con1"/>

  <%-- ensure that the printing error status is set to "ok" as no printing occured. --%>
  <% recordBean.setPrinting_error("ok"); %>
</sess:equalsAttribute>
