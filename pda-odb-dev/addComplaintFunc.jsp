<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, com.vsb.helperBean, java.util.ArrayList, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="java.io.IOException, javax.naming.*" %>
<%@ page import="com.vsb.recordBean, com.vsb.textBean, com.vsb.loginBean, com.vsb.addCustDetailsBean" %>
<%@ page import="com.vsb.wasteTypesBean, com.vsb.graffDetailsBean, com.vsb.dartDetailsBean" %>
<%@ page import="com.vsb.surveyBean, com.vsb.defectSizeBean, com.vsb.defectDetailsBean" %>
<%@ page import="com.vsb.woDetailsBean, com.vsb.avAddDetailsBean, com.vsb.avMultiStatusBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>

<jsp:useBean id="DbUtils"            scope="session" class="com.db.DbUtils" />
<jsp:useBean id="helperBean"         scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean"         scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="textBean"           scope="session" class="com.vsb.textBean" />
<jsp:useBean id="addCustDetailsBean" scope="session" class="com.vsb.addCustDetailsBean" />
<jsp:useBean id="loginBean"          scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="wasteTypesBean"     scope="session" class="com.vsb.wasteTypesBean" />
<jsp:useBean id="graffDetailsBean"   scope="session" class="com.vsb.graffDetailsBean" />
<jsp:useBean id="dartDetailsBean"    scope="session" class="com.vsb.dartDetailsBean" />
<jsp:useBean id="surveyBean"         scope="session" class="com.vsb.surveyBean" />
<jsp:useBean id="defectSizeBean"     scope="session" class="com.vsb.defectSizeBean" />
<jsp:useBean id="defectDetailsBean"  scope="session" class="com.vsb.defectDetailsBean" />
<jsp:useBean id="woDetailsBean"      scope="session" class="com.vsb.woDetailsBean" />
<jsp:useBean id="avAddDetailsBean"   scope="session" class="com.vsb.avAddDetailsBean" />
<jsp:useBean id="avMultiStatusBean"  scope="session" class="com.vsb.avMultiStatusBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addComplaintFunc" value="false">
  addComplaintFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addComplaintFunc">
  <%-- ADD A COMPLAINT --%>
  <%--
    This is a brief outline about what the below sql actually does.
  
    1. a user wishes to create a complaint for the location supplied;
  
    a) a new complaint is created.
    b) the works order text box is used to fill in the complaint text.
    c) a complaint diry is created.
    d) control moves back to the calling form.
  
  --%>
  
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
  
    // 21/05/2010  TW  Inspection date may have been input in new form inspDate
    Date currentDate = new java.util.Date();
    date = recordBean.getDiry_date_due();
    if (date.equals("")) {
      date = formatDate.format(currentDate);
    }
    time = formatTime.format(currentDate);
    time_h = formatTime_h.format(currentDate);
    time_m = formatTime_m.format(currentDate);
  %>
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- Create a new complaint --%>
  
    <%-- CREATING A COMPLAINT --%>

    <%-- getting the information for the notify_customer service call --%>
    <% String complaint_closed = "N"; %>
    <% String notify_customer = "N"; %>
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
    <%-- Create a new complaint --%>
    <% int complaint_no = 0; %>
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
    <% recordBean.setComplaint_no(String.valueOf(complaint_no)); %>
  
    <%-- Update the old complaint serial number with the next one --%>
    <sql:query>
      update s_no
      set serial_no = <%= complaint_no %> + 1
      where sn_func = 'COMP'
    </sql:query>
    <sql:execute />

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
 
    <%-- Set up the remarks --%>
    <% String remarks_1 = ""; %>
    <% String remarks_2 = ""; %>
    <% String remarks_3 = ""; %>
    
    <%-- The text should be split into 70 char lines, and there should be a --%>
    <%-- single record for each line. --%>
    <% String tempRemarks = ""; %>

    <%-- If new complaint is going to be linked to a works order, and it is a --%>
    <%-- Hways statutory item then get the text from woDetails --%>
    <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") && recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service()) %>' >
      <% tempRemarks = woDetailsBean.getRemarks().toUpperCase(); %>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! (recordBean.getAction_flag().equals("W") && recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service())) %>' >
      <% tempRemarks = textBean.getRemarks().toUpperCase(); %>
    </if:IfTrue>

    <%
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

    <% String tempPosition = ""; %>
    <%-- If new complaint is going to be linked to a works order, and it is a --%>
    <%-- Hways statutory item then get the text from woDetails --%>
    <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") && recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service()) %>' >
      <% tempPosition = woDetailsBean.getExact_location().toUpperCase(); %>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! (recordBean.getAction_flag().equals("W") && recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service())) %>' >
      <% tempPosition = textBean.getExact_location().toUpperCase(); %>
    </if:IfTrue>
 
    <%-- Adding the complaint record --%>
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
        <%= complaint_no %>,
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
        '<%= tempPosition %>',
        '<%= remarks_1 %>',
        '<%= remarks_2 %>',
        '<%= remarks_3 %>',
        '<%= notice_type %>',
        '<%= recordBean.getService_c() %>',
        'N',
        '<%= recordBean.getFault_code() %>',
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getFeature_ref()%>',
        '<%= recordBean.getContract_ref()%>',
        '<%= recordBean.getOccur_day()%>',
        '<%= recordBean.getRound_c()%>',
        '<%= recordBean.getPa_area()%>',
        '<%= recordBean.getAction_flag() %>',
        null,
        <%-- Check if the user has provided easting values from the Map --%>
        <if:IfTrue cond = '<%= recordBean.getMap_easting().equals("") %>'>
          <%-- If they havn't, check if there is a value in the Site_Details table --%>
          <if:IfTrue cond = '<%= ((String)pageContext.getAttribute("easting")).trim().equals("") %>'>
            null,
          </if:IfTrue>
          <if:IfTrue cond = '<%= !((String)pageContext.getAttribute("easting")).trim().equals("") %>'>
            <%= ((String)pageContext.getAttribute("easting")).trim() %>,
          </if:IfTrue>
        </if:IfTrue>
        <%-- If they have insert the Map values --%>
        <if:IfTrue cond = '<%= !recordBean.getMap_easting().equals("") %>'>
            <%= recordBean.getMap_easting() %>,
        </if:IfTrue>
        <%-- Check if the user has provided northing values from the Map --%>
        <if:IfTrue cond = '<%= recordBean.getMap_northing().equals("") %>'>
          <%-- If they havn't, check if there is a value in the Site_Details table --%>
          <if:IfTrue cond = '<%= ((String)pageContext.getAttribute("northing")).trim().equals("") %>'>
            null,
          </if:IfTrue>
          <if:IfTrue cond = '<%= !((String)pageContext.getAttribute("northing")).trim().equals("") %>'>
            <%= ((String)pageContext.getAttribute("northing")).trim() %>,
          </if:IfTrue>
        </if:IfTrue>
        <%-- If they have insert the Map values --%>
        <if:IfTrue cond = '<%= !recordBean.getMap_northing().equals("") %>'>
            <%= recordBean.getMap_northing() %>,
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
    <% int customer_no = Integer.parseInt((String)pageContext.getAttribute("customer_no")); %>
  
    <%-- update the s_no table with the next customer.customer_no --%>
    <sql:query>
      update s_no
      set serial_no = <%= customer_no %> + 1
      where sn_func = 'customer'
    </sql:query>
    <sql:execute />
  
    <%-- Needs further work if customer is "E" and/or there is an address to add --%>
    <if:IfTrue cond='<%= addCustDetailsBean.getConfirm().equals("No") || ((String)application.getInitParameter("use_cust_dets")).trim().equals("N") || recordBean.getService_c().equals(recordBean.getAv_service()) %>' >
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
  
    <%-- add additional complaint tables --%>
    <sql:query>
      insert into comp_destination (complaint_no)
      values (<%= complaint_no %>)
    </sql:query>
    <sql:execute />
  
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
        <%= complaint_no %>,
        <%= customer_no %>,
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        1,
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= cs_flag %>'
      )
    </sql:query>
    <sql:execute />
  
    <%-- Add the fly capture information --%>
    <if:IfTrue cond='<%= recordBean.getFly_cap_flag().equals("Y") %>' >
      <% double load_qty = (new Float(recordBean.getLoad_qty())).floatValue(); %>
      <% double unit_cost = (new Float(recordBean.getLoad_unit_cost())).floatValue(); %>
      <% double load_est_cost = helperBean.roundDouble(load_qty * unit_cost, 2); %>
      <sql:query>
        insert into comp_flycap (
          complaint_no,
          landtype_ref,
          dominant_waste_ref,
          dominant_waste_qty,
          load_ref,
          load_unit_cost,
          load_qty,
          load_est_cost
        ) values (
          <%= complaint_no %>,
          '<%= recordBean.getLand_type() %>',
          '<%= recordBean.getDom_waste_type() %>',
          <%= recordBean.getDom_waste_qty() %>,
          '<%= recordBean.getLoad_ref() %>',
          <%= recordBean.getLoad_unit_cost() %>,
          <%= recordBean.getLoad_qty() %>,
          <%= load_est_cost %>
        )
      </sql:query>
      <sql:execute />
      <%-- There may be none or more additional waste items. These are held in --%>
      <%-- array in the wasteTypesBean. The arrays are: --%>
      <%--    wasteTypesBean.getWaste_types() --%>
      <%--    wasteTypesBean.getWaste_qtys()  --%>
      <%-- The same index will retreive the qty for the associated type. --%>
      <%-- If the index returns a blank ("") waste_type then that waste type --%>
      <%-- was not picked by the user, only waste_types picked by the --%>
      <%-- user will have a none blank value. --%>
      <% String[] waste_types = wasteTypesBean.getWaste_types(); %>
      <% String[] waste_qtys = wasteTypesBean.getWaste_qtys(); %>
  
      <%-- If the user selected any additional waste_types, loop through all the --%>
      <%-- waste_types (including the blank ones) and add the none blank ones, and --%>
      <%-- the associated quantity, to the comp_flycap_addw table. --%>
      <%
        if (waste_types != null) {
          int seq = 1;
          for(int i=0; i < waste_types.length; i++) {
            // check for a none blank quantity
            if (! waste_types[i].trim().equals("")) {
      %>
              <sql:query>
                insert into comp_flycap_addw (
                  complaint_no,
                  sequence,
                  waste_ref,
                  waste_qty
                ) values (
                  <%= complaint_no %>,
                  <%= seq %>,
                  '<%= waste_types[i].trim() %>',
                  <%= waste_qtys[i].trim() %>
                )
              </sql:query>
              <sql:execute />
      <%
              seq = seq + 1;
            }
          }
        }
      %>
    </if:IfTrue>
  
    <%-- Add the dart/graffiti information --%>
    <if:IfTrue cond='<%= recordBean.getDart_graff_flag().equals("Y") %>' >
      <%-- Get po_code --%>
      <sql:query>
        select po_code
        from pda_user
        where user_name = '<%= loginBean.getUser_name() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="po_code" />
      </sql:resultSet>
  
      <%-- Add the dart information --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getDart_service()) %>' >
        <%-- insert header information --%>
        <sql:query>
          insert into comp_dart_header (
            complaint_no,
            rep_needle_qty,
            rep_crack_pipe_qty,
            rep_condom_qty,
            col_needle_qty,
            col_crack_pipe_qty,
            col_condom_qty,
            wo_est_cost,
            refuse_pay,
            est_duration_h,
            est_duration_m,
            po_code,
            completion_date,
            completion_time_h,
            completion_time_m
          ) values (
            <%= recordBean.getComplaint_no() %>,
            <%= dartDetailsBean.getRep_needle_qty() %>,
            <%= dartDetailsBean.getRep_crack_pipe_qty() %>,
            <%= dartDetailsBean.getRep_condom_qty() %>,
            <%= dartDetailsBean.getCol_needle_qty() %>,
            <%= dartDetailsBean.getCol_crack_pipe_qty() %>,
            <%= dartDetailsBean.getCol_condom_qty() %>,
            <%= dartDetailsBean.getWo_est_cost() %>,
            '<%= dartDetailsBean.getRefuse_pay() %>',
            '<%= dartDetailsBean.getEst_duration_h() %>',
            '<%= dartDetailsBean.getEst_duration_m() %>',
            '<%= ((String)pageContext.getAttribute("po_code")).trim() %>',
            null,
            null,
            null
          )
        </sql:query>
        <sql:execute/>
        <%-- make a log entry of the insert --%>
        <sql:query>
          insert into comp_dart_hdr_log (
            complaint_no,
            rep_needle_qty,
            rep_crack_pipe_qty,
            rep_condom_qty,
            col_needle_qty,
            col_crack_pipe_qty,
            col_condom_qty,
            wo_est_cost,
            refuse_pay,
            est_duration_h,
            est_duration_m,
            po_code,
            completion_date,
            completion_time_h,
            completion_time_m,
            log_seq,
            log_username,
            log_date,
            log_time_h,
            log_time_m
          ) values (
            <%= recordBean.getComplaint_no() %>,
            <%= dartDetailsBean.getRep_needle_qty() %>,
            <%= dartDetailsBean.getRep_crack_pipe_qty() %>,
            <%= dartDetailsBean.getRep_condom_qty() %>,
            <%= dartDetailsBean.getCol_needle_qty() %>,
            <%= dartDetailsBean.getCol_crack_pipe_qty() %>,
            <%= dartDetailsBean.getCol_condom_qty() %>,
            <%= dartDetailsBean.getWo_est_cost() %>,
            '<%= dartDetailsBean.getRefuse_pay() %>',
            '<%= dartDetailsBean.getEst_duration_h() %>',
            '<%= dartDetailsBean.getEst_duration_m() %>',
            '<%= ((String)pageContext.getAttribute("po_code")).trim() %>',
            null,
            null,
            null,
            1,
            '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>'
          )
        </sql:query>
        <sql:execute/>
  
        <%-- insert detail information --%>
        <%-- As the insert for each group is almost the same, a generic insert --%>
        <%-- will be used, and the differences taken cars of by variables. --%>
        <%
          // string of category
          String category = "";
          //array of the ticked items
          String[] category_array = null;
  
          // number of categories
          for(int i=1; i <= 4; i++) {
            switch (i) {
              case 1:
                // Reported Categories
                category = "DRTREP";
                category_array = dartDetailsBean.getRep_cats();
                break;
              case 2:
                // Drug Paraphernalia
                category = "DRTPAR";
                category_array = dartDetailsBean.getDrug_para();
                break;
              case 3:
                // Anti-social waste washdown
                category = "DRTASW";
                category_array = dartDetailsBean.getAsww_cats();
                break;
              case 4:
                // Abusive behaviour
                category = "ABUSE";
                category_array = dartDetailsBean.getAbuse_cats();
                break;
            }
  
            // looped for each one of the above categories
            if (category_array != null) {
              for(int j=0; j < category_array.length; j++) {
                // check for a none null quantity
                if (category_array[j] != null) {
        %>
                  <%-- do the table insert --%>
                  <sql:query>
                    insert into comp_dart_detail (
                      complaint_no,
                      lookup_func,
                      lookup_code
                    ) values (
                      <%= recordBean.getComplaint_no() %>,
                      '<%= category %>',
                      '<%= category_array[j].trim() %>'
                    )
                  </sql:query>
                  <sql:execute/>
  
                  <%-- do the log insert --%>
                  <sql:query>
                    insert into comp_dart_dtl_log (
                      complaint_no,
                      lookup_func,
                      lookup_code,
                      log_seq,
                      log_username,
                      log_date,
                      log_time_h,
                      log_time_m
                    ) values (
                      <%= recordBean.getComplaint_no() %>,
                      '<%= category %>',
                      '<%= category_array[j].trim() %>',
                      1,
                      '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
                      '<%= date %>',
                      '<%= time_h %>',
                      '<%= time_m %>'
                    )
                  </sql:query>
                  <sql:execute/>
        <%
                } //if - null value check
              } //for loop - loop through array
            } //if - null array check
          } //for loop - loop through categories
        %>
      </if:IfTrue>
  
      <%-- Add the graffiti information --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getGraffiti_service()) %>' >
        <%-- insert --%>
        <sql:query>
          insert into comp_ert_header (
            complaint_no,
            volume_ref,
            tag_offensive,
            tag_visible,
            tag_recognisable,
            tag_known_offender,
            tag_offender_info,
            tag_repeat_offence,
            tag_offences_ref,
            rem_workforce_ref,
            wo_est_cost,
            refuse_pay,
            est_duration_h,
            est_duration_m,
            po_code,
            graffiti_level_ref,
            completion_date,
            completion_time_h,
            completion_time_m,
            indemnity_response,
            indemnity_date,
            indemnity_time_h,
            indemnity_time_m,
            cust_responsible,
            landlord_perm_date
          ) values (
            <%= recordBean.getComplaint_no() %>,
            '<%= graffDetailsBean.getVolume_ref() %>',
            '<%= graffDetailsBean.getTag_offensive() %>',
            '<%= graffDetailsBean.getTag_visible() %>',
            '<%= graffDetailsBean.getTag_recognisable() %>',
            '<%= graffDetailsBean.getTag_known_offender() %>',
            '<%= graffDetailsBean.getTag_offender_info().toUpperCase() %>',
            '<%= graffDetailsBean.getTag_repeat_offence() %>',
            '<%= graffDetailsBean.getTag_offences_ref() %>',
            '<%= graffDetailsBean.getRem_workforce_ref() %>',
            <%= graffDetailsBean.getWo_est_cost() %>,
            '<%= graffDetailsBean.getRefuse_pay() %>',
            '<%= graffDetailsBean.getEst_duration_h() %>',
            '<%= graffDetailsBean.getEst_duration_m() %>',
            '<%= ((String)pageContext.getAttribute("po_code")).trim() %>',
            '<%= graffDetailsBean.getGraffiti_level_ref() %>',
            null,
            null,
            null,
            '<%= graffDetailsBean.getIndemnity_response() %>',
            <if:IfTrue cond='<%= graffDetailsBean.getIndemnity_response().equals("Y") %>' >
              '<%= graffDetailsBean.getIndemnity_date() %>',
              '<%= graffDetailsBean.getIndemnity_time_h() %>',
              '<%= graffDetailsBean.getIndemnity_time_m() %>',
            </if:IfTrue>
            <if:IfTrue cond='<%= ! graffDetailsBean.getIndemnity_response().equals("Y") %>' >
              null,
              '',
              '',
            </if:IfTrue>
            '<%= graffDetailsBean.getCust_responsible() %>',
            <if:IfTrue cond='<%= !graffDetailsBean.getLandlord_perm_date().equals("") %>' >
              '<%= graffDetailsBean.getLandlord_perm_date() %>'
            </if:IfTrue>
            <if:IfTrue cond='<%= graffDetailsBean.getLandlord_perm_date().equals("") %>' >
              null
            </if:IfTrue>
          )
        </sql:query>
        <sql:execute/>

        
        <%-- make a log entry of the insert --%>
        <sql:query>
          insert into comp_ert_hdr_log (
            complaint_no,
            volume_ref,
            tag_offensive,
            tag_visible,
            tag_recognisable,
            tag_known_offender,
            tag_offender_info,
            tag_repeat_offence,
            tag_offences_ref,
            rem_workforce_ref,
            wo_est_cost,
            refuse_pay,
            est_duration_h,
            est_duration_m,
            po_code,
            graffiti_level_ref,
            completion_date,
            completion_time_h,
            completion_time_m,
            indemnity_response,
            indemnity_date,
            indemnity_time_h,
            indemnity_time_m,
            cust_responsible,
            landlord_perm_date,
            log_seq,
            log_username,
            log_date,
            log_time_h,
            log_time_m
          ) values (
            <%= recordBean.getComplaint_no() %>,
            '<%= graffDetailsBean.getVolume_ref() %>',
            '<%= graffDetailsBean.getTag_offensive() %>',
            '<%= graffDetailsBean.getTag_visible() %>',
            '<%= graffDetailsBean.getTag_recognisable() %>',
            '<%= graffDetailsBean.getTag_known_offender() %>',
            '<%= graffDetailsBean.getTag_offender_info().toUpperCase() %>',
            '<%= graffDetailsBean.getTag_repeat_offence() %>',
            '<%= graffDetailsBean.getTag_offences_ref() %>',
            '<%= graffDetailsBean.getRem_workforce_ref() %>',
            <%= graffDetailsBean.getWo_est_cost() %>,
            '<%= graffDetailsBean.getRefuse_pay() %>',
            '<%= graffDetailsBean.getEst_duration_h() %>',
            '<%= graffDetailsBean.getEst_duration_m() %>',
            '<%= ((String)pageContext.getAttribute("po_code")).trim() %>',
            '<%= graffDetailsBean.getGraffiti_level_ref() %>',
            null,
            null,
            null,
            '<%= graffDetailsBean.getIndemnity_response() %>',
            <if:IfTrue cond='<%= graffDetailsBean.getIndemnity_response().equals("Y") %>' >
              '<%= graffDetailsBean.getIndemnity_date() %>',
              '<%= graffDetailsBean.getIndemnity_time_h() %>',
              '<%= graffDetailsBean.getIndemnity_time_m() %>',
            </if:IfTrue>
            <if:IfTrue cond='<%= ! graffDetailsBean.getIndemnity_response().equals("Y") %>' >
              null,
              '',
              '',
            </if:IfTrue>
            '<%= graffDetailsBean.getCust_responsible() %>',
            <if:IfTrue cond='<%= ! graffDetailsBean.getLandlord_perm_date().equals("") %>' >
              '<%= graffDetailsBean.getLandlord_perm_date() %>',
            </if:IfTrue>
            <if:IfTrue cond='<%= graffDetailsBean.getLandlord_perm_date().equals("") %>' >
              null,
            </if:IfTrue>
            1,
            '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>'
          )
        </sql:query>
        <sql:execute/>
  
        <%-- insert tag only if one was entered --%>
        <if:IfTrue cond='<%= ! graffDetailsBean.getTag().trim().equals("") %>' >
          <sql:query>
            insert into comp_ert_tags (
              complaint_no,
              seq_no,
              username,
              tag,
              doa
            ) values (
              <%= recordBean.getComplaint_no() %>,
              1,
              '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
              '<%= graffDetailsBean.getTag().toUpperCase() %>',
              '<%= date %>'
            )
          </sql:query>
          <sql:execute/>
        </if:IfTrue>
  
        <%-- insert detail information --%>
        <%-- As the insert for each group is almost the same, a generic insert --%>
        <%-- will be used, and the differences taken cars of by variables. --%>
        <%
          // string of category
          String category = "";
          //array of the ticked items
          String[] category_array = null;
  
          // number of gategories
          for(int i=1; i <= 10; i++) {
            switch (i) {
              case 1:
                // Graffiti Material
                category = "ERTMAT";
                category_array = graffDetailsBean.getRef_ertmat();
                break;
              case 2:
                // Nature of Offensive Graffiti
                category = "ERTOFF";
                category_array = graffDetailsBean.getRef_ertoff();
                break;
              case 3:
                // Graffiti Ownership
                category = "ERTOWN";
                category_array = graffDetailsBean.getRef_ertown();
                break;
              case 4:
                // Graffiti Operation
                category = "ERTOPP";
                category_array = graffDetailsBean.getRef_ertopp();
                break;
              case 5:
                // Graffiti Item
                category = "ERTITM";
                category_array = graffDetailsBean.getRef_ertitm();
                break;
              case 6:
                // Preventative action taken
                category = "ERTACT";
                category_array = graffDetailsBean.getRef_ertact();
                break;
              case 7:
                // Abusive behaviour
                category = "ERTABU";
                category_array = graffDetailsBean.getRef_abuse();
                break;
              case 8:
                // Method of removal
                category = "ERTMET";
                category_array = graffDetailsBean.getRef_ertmet();
                break;
              case 9:
                // Equipment and material used for removal
                category = "ERTEQU";
                category_array = graffDetailsBean.getRef_ertequ();
                break;
              case 10:
                // Surface graffiti is on
                category = "ERTSUR";
                category_array = graffDetailsBean.getRef_ertsur();
                break;
            }
  
            // looped for each one of the above categories
            if (category_array != null) {
              for(int j=0; j < category_array.length; j++) {
                // check for a none null quantity
                if (category_array[j] != null) {
        %>
                  <%-- do the table insert --%>
                  <sql:query>
                    insert into comp_ert_detail (
                      complaint_no,
                      lookup_func,
                      lookup_code
                    ) values (
                      <%= recordBean.getComplaint_no() %>,
                      '<%= category %>',
                      '<%= category_array[j].trim() %>'
                    )
                  </sql:query>
                  <sql:execute/>
  
                  <%-- do the log insert --%>
                  <sql:query>
                    insert into comp_ert_dtl_log (
                      complaint_no,
                      lookup_func,
                      lookup_code,
                      log_seq,
                      log_username,
                      log_date,
                      log_time_h,
                      log_time_m
                    ) values (
                      <%= recordBean.getComplaint_no() %>,
                      '<%= category %>',
                      '<%= category_array[j].trim() %>',
                      1,
                      '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
                      '<%= date %>',
                      '<%= time_h %>',
                      '<%= time_m %>'
                    )
                  </sql:query>
                  <sql:execute/>
        <%
                } //if - null value check
              } //for loop - loop through array
            } //if - null array check
          } //for loop - loop through categories
        %>
      </if:IfTrue>
    </if:IfTrue>
  
    <%-- Insert a new diry record for the complaint --%>
    <%-- There is no previous diry so leave source fields blank --%>
    <%-- next_record and dest_ref will be filled in when the works order is added --%>
    <%-- get the next diry.diry_ref from s_no table --%>
    <sql:query>
      select serial_no
      from s_no
      where sn_func = 'diry'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="diry_ref" />
    </sql:resultSet>
    <% int diry_ref = Integer.parseInt((String)pageContext.getAttribute("diry_ref")); %>
  
    <%-- update the s_no table with the next diry.diry_ref --%>
    <sql:query>
      update s_no
      set serial_no = <%= diry_ref %> + 1
      where sn_func = 'diry'
    </sql:query>
    <sql:execute />
  
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
        date_due,
        pa_area,
        action_flag,
        dest_flag,
        dest_date,
        dest_time_h,
        dest_time_m,
        dest_user
      ) values (
        <%= diry_ref %>,
        null,
        'C',
        <%= complaint_no %>,
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        '<%= recordBean.getSite_ref() %>',
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getContract_ref()%>',
        null,
        null,
        '<%= recordBean.getFeature_ref()%>',
        '<%= date %>',
        '<%= recordBean.getPa_area() %>',
        '<%= recordBean.getAction_flag() %>',
        null,
        null,
        null,
        null,
        null
      )
    </sql:query>
    <sql:execute />
  
    <%-- If this is a Doorstep complaint add the results of the doorstep survey --%>
    <%-- 29/06/2010  TW  the doorstep fault code may be a comma delimited list of fault codes --%>
    <% ArrayList doorstep_fault_codes = helperBean.splitCommaList( recordBean.getDoorstep_fault_code() ); %>
    <if:IfTrue cond='<%= doorstep_fault_codes.contains( recordBean.getFault_code() ) %>' >
      <%-- We want to populate the monitor tables to store the surveys results --%>
      <%-- For each survey the monitor_result_hdr needs a new record, and  --%>
      <%-- for each question on the survey the monitor_result_dtl needs a new record --%>

      <%-- Get the last monitor header serial number --%>
      <% String serial_no = ""; %>
      <sql:query>
        SELECT serial_no
        FROM s_no
        WHERE sn_func = 'monitor_result_hdr'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="serial_no" />
        <% serial_no = ((String)pageContext.getAttribute("serial_no")).trim(); %>
        <sql:wasNull>
          <%-- update the s_no table with the initial value --%>
          <% serial_no = "1"; %>
          <sql:statement id="stmt2" conn="con1">
            <sql:query>
              UPDATE s_no
              SET serial_no = 1
              WHERE sn_func = 'monitor_result_hdr'
            </sql:query>
            <sql:execute />
          </sql:statement>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <%-- insert into s_no the new serial number, and give it it's initial value --%>
        <% serial_no = "1"; %>
        <sql:statement id="stmt2" conn="con1">
          <sql:query>
            INSERT INTO s_no (serial_no, sn_func)
            values (1, 'monitor_result_hdr')
          </sql:query>
          <sql:execute />
        </sql:statement>
      </sql:wasEmpty>

      <%-- Increase the sequence number for the next survey --%>
      <sql:query>
        UPDATE s_no
        SET serial_no = <%= (new Integer(serial_no)).intValue() + 1 %>
        WHERE sn_func = 'monitor_result_hdr'
      </sql:query>
      <sql:execute />          
      
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
          <%= complaint_no %>,
          null,
          '<%= date %>',
          '<%= time_h %>',
          '<%= time_m %>',
          '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>'
        )
      </sql:query>
      <sql:execute />      

      <%-- Get the iterator of all the question id's, loop through      --%>
      <%-- them get their attributes and print them to screen           --%>
      <% Iterator questionIds = surveyBean.getKeyIterator();              %>
      <% while( questionIds.hasNext() ){                                  %>
      <%-- Get the question id                                          --%>
      <%   String id = DbUtils.cleanString( (String)questionIds.next() ); %>
      <%-- Get the questions reference number                           --%>
      <%   String question_ref = DbUtils.cleanString( surveyBean.getQuestion_ref(id) );  %>
      <%-- Get the actual question                                      --%>
      <%   String question_text = DbUtils.cleanString( surveyBean.getQuestion_text(id) );%>
      <%-- Get the questions sequence number                            --%>
      <%   String question_seq = DbUtils.cleanString( surveyBean.getQuestion_seq(id) );  %>
      <%-- Get the questions answers                                    --%>
      <%   String[] question_answer = surveyBean.getAnswer(id);           %>
      <%---------- WHILE LOOP CONTINUES BELOW !!! ------------------------%>
      <%-- For each String returned run the query to add a new record to the --%>
      <%-- monitor_results_dtl --%>
        <% for(int i=0; i<question_answer.length; i++){ %>
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
              '<%= DbUtils.cleanString( question_answer[i] ) %>'
            )
          </sql:query>
          <sql:execute />
        <%-- End of if statement !!!!--%>
        <% } %>
      <%-- End of While loop !!!!--%>    
      <% } %>

      <%-- close the complaint --%>
      <sql:query>
        UPDATE comp
        SET date_closed   = '<%= date %>',
            time_closed_h = '<%= time_h %>',
            time_closed_m = '<%= time_m %>'
      WHERE complaint_no  = '<%= complaint_no %>'
      </sql:query>
      <sql:execute />

      <%-- Close the default diry record --%>
      <sql:query>
        UPDATE diry
           SET action_flag = 'C',
               dest_date = '<%= date %>',
               dest_time_h = '<%= time_h %>',
               dest_time_m = '<%= time_m %>',
               dest_user = '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>'
         WHERE diry_ref = '<%= diry_ref %>'
      </sql:query>
      <sql:execute />
     
      <%-- Flag complaint as closed for the notify_customer service --%> 
      <% complaint_closed = "Y"; %>
    </if:IfTrue>
    
    
    <%-- Add trade complaint information if this complaint is for a trade site --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getTrade_service()) %>' >
      <%-- COMP_TR row--%>
      <sql:query>
        INSERT INTO comp_tr(
          complaint_no,
          agree_task_no,
          task_ref,
          exact_locn,
          comp_code,
          coll_day,
          time_hr,
          time_min,
          round_ref,
          coll_day_no,
          before_after,
          to_time_h,
          to_time_m
        ) VALUES (
         <%= complaint_no %>,
         <%= recordBean.getTat_no() %>,
        '<%= recordBean.getTat_ref() %>',
        '<%= recordBean.getTat_exact_locn() %>',
        '<%= recordBean.getFault_code() %>',
        '<%= recordBean.getTat_coll_day() %>',
        '<%= recordBean.getTat_time_hr() %>',
        '<%= recordBean.getTat_time_min() %>',
        '<%= recordBean.getTat_round_ref() %>',
         <%= recordBean.getTat_coll_day_no() %>,
        '<%= recordBean.getTat_before_after() %>',
        '<%= recordBean.getTat_to_time_h() %>',
        '<%= recordBean.getTat_to_time_m() %>'
        )
      </sql:query>
      <sql:execute />
      <%-- COMP_TRADE row --%>
      <sql:query>
        INSERT INTO comp_trade (
          complaint_no,
          agreement_no,
          agreement_name,
          site_name
        ) VALUES (
         <%= complaint_no %>,
         <%= recordBean.getTa_no() %>,
         '<%= recordBean.getTa_name() %>',
         '<%= recordBean.getTrade_name() %>'
        )
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  
    <%-- Add AV complaint information if this complaint is for an AV --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getAv_service()) %>' >
      <%-- COMP_AV row--%>
      <sql:query>
        INSERT INTO comp_av(
          complaint_no,
          car_id,
          make_ref,
          model_ref,
          colour_ref,
          road_fund_flag,
          last_seq,
          vin
        ) VALUES (
          <%= complaint_no %>,
         '<%= recordBean.getAv_car_id().toUpperCase() %>',
         '<%= recordBean.getAv_make_ref() %>',
         '<%= recordBean.getAv_model_ref() %>',
         '<%= recordBean.getAv_colour_ref() %>',
         'N',
         1,
         '<%= recordBean.getAv_vin().toUpperCase() %>'
        )
      </sql:query>
      <sql:execute />
      <%-- Update sticker time and date if a sticker was added --%>
      <if:IfTrue cond='<%= recordBean.getAv_is_stickered().equals("Y") %>'>
        <%-- 08/07/2010  TW  Check for new inputs from avAddDetails form --%>
        <%
          String av_stick_date   = date;
          String av_stick_time_h = time_h;
          String av_stick_time_m = time_m;
          if ( recordBean.getComingFromSchedComp().equals("Y") && !avAddDetailsBean.getAv_stick_date().equals("") ) {
            av_stick_date   = avAddDetailsBean.getAv_stick_date();
            av_stick_time_h = avAddDetailsBean.getAv_stick_time_h();
            av_stick_time_m = avAddDetailsBean.getAv_stick_time_m();
          }
        %>
        <sql:query>
          UPDATE comp_av
          SET date_stickered   = '<%= av_stick_date %>',
              time_stickered_h = '<%= av_stick_time_h %>',
              time_stickered_m = '<%= av_stick_time_m %>'
          WHERE complaint_no   = <%= complaint_no %>          
        </sql:query>
        <sql:execute />
      </if:IfTrue>
      <%-- Update tax disc flag, if tax was valid --%>
      <if:IfTrue cond='<%= recordBean.getAv_is_taxed().equals("Y") %>'>
        <sql:query>
          UPDATE comp_av
          SET road_fund_flag   = 'Y',
              road_fund_valid  = '<%= avAddDetailsBean.getAv_tax_date() %>'
          WHERE complaint_no   = <%= complaint_no %>          
        </sql:query>
        <sql:execute />
      </if:IfTrue>
      <%-- COMP_AV_HIST row--%>
      <%
        for( int j=0; j< avMultiStatusBean.size(); j++ ){
      %>
      <sql:query>
        INSERT INTO comp_av_hist(
          complaint_no,
          status_ref,
          seq,
          doa,
          toa_h,
          toa_m,
          username,
          status_date,
          status_time_h,
          status_time_m,
          notes      
        ) VALUES (
          <%= complaint_no %>,
          '<%= avMultiStatusBean.getStatusByIx(j) %>',
          <%= String.valueOf(j + 1) %>,
         '<%= date %>',
         '<%= time_h %>',
         '<%= time_m %>',
         '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
         '<%= date %>',
         '<%= time_h %>',
         '<%= time_m %>',
         '<%= avMultiStatusBean.getTextByIx(j) %>'
        )
      </sql:query>
      <sql:execute />
      <%-- Update the Abandoned Vehicles sequence number --%>
      <sql:query>
        UPDATE comp_av
        SET last_seq = <%= String.valueOf(j + 1) %>
        WHERE complaint_no = <%= recordBean.getComplaint_no() %>
      </sql:query>
      <sql:execute />
      <%
        }
      %>
    </if:IfTrue>

    <%-- Add Tree complaint information if this complaint is for an Tree --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getTrees_service()) %>' >
      <%-- COMP_TREE row--%>
      <sql:query>
        INSERT INTO comp_tree(
          complaint_no,
          tree_ref,
          item_ref
        ) VALUES (
          <%= complaint_no %>,
          <%= recordBean.getTree_ref() %>,
          '<%= recordBean.getItem_ref() %>'
        )
      </sql:query>
      <sql:execute />
    </if:IfTrue>

    
    <%-- Add Defect complaint details if the complaint is a defect --%>
    <if:IfTrue cond='<%= recordBean.getDefect_flag().equals("Y") ||
                         recordBean.getDefect_flag().equals("I") %>' >
      <sql:query>
        INSERT INTO comp_measurement(
          complaint_no,
          x_value,
          y_value,
          z_value,
          linear_value,
          area_value,
          priority
        ) VALUES (
          <%= complaint_no %>,
          <%= defectSizeBean.getX() %>,
          <%= defectSizeBean.getY() %>,
          0,
          <%= defectDetailsBean.getLinear() %>,
          <%= defectDetailsBean.getArea() %>,
          '<%= defectDetailsBean.getPriority() %>'
        )
      </sql:query>
      <sql:execute />
    </if:IfTrue>
    
    
    <%-- close the complaint if 'No Action' flag is set --%>
    <if:IfTrue cond='<%= recordBean.getAction_flag().equals("N") %>'>
      <sql:query>
        UPDATE comp
        SET date_closed   = '<%= date %>',
            time_closed_h = '<%= time_h %>',
            time_closed_m = '<%= time_m %>'
      WHERE complaint_no  = '<%= complaint_no %>'
      </sql:query>
      <sql:execute />

      <%-- Close the default diry record --%>
      <sql:query>
        UPDATE diry
           SET action_flag = 'C',
               dest_flag = 'C',
               dest_date = '<%= date %>',
               dest_time_h = '<%= time_h %>',
               dest_time_m = '<%= time_m %>',
               dest_user = '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>'
         WHERE diry_ref = '<%= diry_ref %>'
      </sql:query>
      <sql:execute />

      <%-- Flag complaint as closed for the notify_customer service --%> 
      <% complaint_closed = "Y"; %>
    </if:IfTrue>
   
    <%-- Make the notify_customer web service call --%>
    <if:IfTrue cond='<%= complaint_closed.equals("Y") && notify_customer.equals("Y") %>'>
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
        pageContext.setAttribute("COMPLAINT_NO", String.valueOf(complaint_no));
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
        <%
          // Set the output value into the page scope
          pageContext.setAttribute("output", returnedValue);
        %>
        <c:out value="${output}" escapeXml="false" />
      </if:IfTrue>
    </if:IfTrue>

  </sql:statement>
  <sql:closeConnection conn="con1"/>
</sess:equalsAttribute>
