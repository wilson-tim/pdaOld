<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.*" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="surveyTransectMethodBean" scope="session" class="com.vsb.surveyTransectMethodBean" />
<jsp:useBean id="surveyTransectMeasureBean" scope="session" class="com.vsb.surveyTransectMeasureBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addSurveyFunc" value="false">
  addSurveyFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addSurveyFunc">
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
  
    Date currentDate = new java.util.Date();
    date = formatDate.format(currentDate);
    time = formatTime.format(currentDate);
    time_h = formatTime_h.format(currentDate);
    time_m = formatTime_m.format(currentDate);
  %>
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
      <% int complaint_no = 0; %>
  
      <%-- CREATING A COMPLAINT FOR ADHOC SURVEYS --%>
      <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("") %>' >
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
          where location_c = '<%= recordBean.getBv_location_c() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="locn_type" />
        </sql:resultSet>
        <% int locn_type = Integer.parseInt((String)pageContext.getAttribute("locn_type")); %>
  
        <%-- Get Item_ref --%>
        <sql:query>
          select c_field
          from keys
          where keyname = 'BV199_ITEM'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="item_ref" />
        </sql:resultSet>
  
        <%-- Get feature_ref, contract_ref, occur_day, round_c, pa_area --%>
        <sql:query>
          select feature_ref, contract_ref, occur_day, round_c, pa_area
          from si_i
          where item_ref = '<%= ((String)pageContext.getAttribute("item_ref")).trim() %>'
          and site_ref = '<%= recordBean.getBv_site_ref() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="feature_ref" />
          <sql:wasNull>
            <% pageContext.setAttribute("feature_ref", ""); %>
          </sql:wasNull>
          <sql:getColumn position="2" to="contract_ref" />
          <sql:wasNull>
            <% pageContext.setAttribute("contract_ref", ""); %>
          </sql:wasNull>
          <sql:getColumn position="3" to="occur_day" />
          <sql:wasNull>
            <% pageContext.setAttribute("occur_day", ""); %>
          </sql:wasNull>
          <sql:getColumn position="4" to="round_c" />
          <sql:wasNull>
            <% pageContext.setAttribute("round_c", ""); %>
          </sql:wasNull>
          <sql:getColumn position="5" to="pa_area" />
          <sql:wasNull>
            <% pageContext.setAttribute("pa_area", ""); %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
         <% pageContext.setAttribute("feature_ref", ""); %>
         <% pageContext.setAttribute("contract_ref", ""); %>
         <% pageContext.setAttribute("occur_day", ""); %>
         <% pageContext.setAttribute("round_c", ""); %>
         <% pageContext.setAttribute("pa_area", ""); %>
        </sql:wasEmpty>
  
        <%-- Get service_c --%>
        <sql:query>
          select service_c
          from item
          where item_ref = '<%= ((String)pageContext.getAttribute("item_ref")).trim() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="service_c" />
        </sql:resultSet>
  
        <%-- get comp_code --%>
        <sql:query>
          select c_field
          from keys
          where keyname = 'BV199_COMP_CODE'
          and   service_c = 'ALL'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="comp_code" />
        </sql:resultSet>
  
        <%-- Create a new complaint --%>
  
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
        <% location_name = recordBean.getBv_location_name(); %>
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
          where site_ref = '<%= recordBean.getBv_site_ref() %>'
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
        <if:IfTrue cond='<%= ! recordBean.getBv_build_sub_no().equals("") %>' >
          <% long_build_name = recordBean.getBv_build_sub_no(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= ! recordBean.getBv_build_sub_name().equals("") %>' >
          <if:IfTrue cond='<%= ! long_build_name.trim().equals("") %>' >
            <% long_build_name = long_build_name + ", "; %>
          </if:IfTrue>
          <% long_build_name = long_build_name + recordBean.getBv_build_sub_name(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= ! recordBean.getBv_build_name().equals("") %>' >
          <if:IfTrue cond='<%= ! long_build_name.trim().equals("") %>' >
            <% long_build_name = long_build_name + ", "; %>
          </if:IfTrue>
          <% long_build_name = long_build_name + recordBean.getBv_build_name(); %>
        </if:IfTrue>
  
        <%-- Get easting and northing for the site --%>
        <sql:query>
          select easting, northing, easting_end, northing_end
          from site_detail
          where site_ref = '<%= recordBean.getBv_site_ref() %>'
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
  
        <%-- Get po_code --%>
        <sql:query>
          select po_code
          from pda_user
          where user_name = '<%= loginBean.getUser_name()%>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="po_code" />
        </sql:resultSet>
  
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
            date_closed,
            time_closed_h,
            time_closed_m,
            action_flag,
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
            '<%= recordBean.getBv_site_ref() %>',
            '<%= recordBean.getBv_location_c() %>',
            '<%= recordBean.getBv_build_no() %>',
            '<%= recordBean.getBv_build_sub_no() %>',
            '<%= long_build_name.trim() %>',
            '<%= recordBean.getBv_build_sub_name() %>',
            '<%= location_name.trim() %>',
            '<%= location_desc.trim() %>',
            '<%= recordBean.getBv_area_ward_desc() %>',
            '<%= recordBean.getBv_postcode() %>',
            '<%= notice_type.trim() %>',
            '<%= ((String)pageContext.getAttribute("service_c")).trim() %>',
            'N',
            '<%= ((String)pageContext.getAttribute("comp_code")).trim() %>',
            '<%= ((String)pageContext.getAttribute("item_ref")).trim() %>',
            '<%= ((String)pageContext.getAttribute("feature_ref")).trim() %>',
            '<%= ((String)pageContext.getAttribute("contract_ref")).trim() %>',
            '<%= ((String)pageContext.getAttribute("occur_day")).trim() %>',
            '<%= ((String)pageContext.getAttribute("round_c")).trim() %>',
            '<%= ((String)pageContext.getAttribute("pa_area")).trim() %>',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>',
            'N',
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
  
        <%-- add additional complaint tables --%>
        <sql:query>
          insert into comp_destination (complaint_no)
          values ('<%= complaint_no %>')
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
            '<%= complaint_no %>',
            '<%= customer_no  %>',
            '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
            '1',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>',
            '<%= cs_flag %>'
          )
        </sql:query>
        <sql:execute />
  
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
            date_done,
            done_time_h,
            done_time_m,
            dest_user,
            po_code
          ) values (
            <%= diry_ref %>,
            null,
            'C',
            '<%= complaint_no %>',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>',
            '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
            '<%= recordBean.getBv_site_ref() %>',
            '<%= ((String)pageContext.getAttribute("item_ref")).trim() %>',
            '<%= ((String)pageContext.getAttribute("contract_ref")).trim() %>',
            null,
            null,
            '<%= ((String)pageContext.getAttribute("feature_ref")).trim() %>',
            '<%= date %>',
            '<%= ((String)pageContext.getAttribute("pa_area")).trim() %>',
            'C',
            'C',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>',
            null,
            '<%= ((String)pageContext.getAttribute("po_code")).trim() %>'
          )
        </sql:query>
        <sql:execute />
      </if:IfTrue>
  
      <%-- UPDATE THE COMP IF THIS IS AN INSP LIST ITEM --%>
      <if:IfTrue cond='<%= recordBean.getComp_action_flag().trim().equals("P") || recordBean.getComp_action_flag().trim().equals("I") %>' >
        <%
          //store the complaint number for easy access
          complaint_no = Integer.parseInt((String)recordBean.getComplaint_no());
        %>
  
        <%-- DO NOT CHANGE RECVD_BY IF IT IS AN INSPECTION --%>
  
        <%-- get comp_code --%>
        <sql:query>
          select c_field
          from keys
          where keyname = 'BV199_COMP_CODE'
          and   service_c = 'ALL'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="comp_code" />
        </sql:resultSet>
  
        <%-- Get po_code --%>
        <sql:query>
          select po_code
          from pda_user
          where user_name = '<%= loginBean.getUser_name()%>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="po_code" />
        </sql:resultSet>
  
        <%-- Updating the comp --%>
        <sql:query>
          update comp
          set
          action_flag = 'N',
          comp_code = '<%= ((String)pageContext.getAttribute("comp_code")).trim() %>',
          date_closed = '<%= date %>',
          time_closed_h = '<%= time_h %>',
          time_closed_m = '<%= time_m %>'
          where complaint_no = '<%= complaint_no %>'
        </sql:query>
        <sql:execute />
  
        <%-- update the DIRY --%>
        <sql:query>
          update diry
          set
          action_flag = 'C',
          dest_flag = 'C',
          date_done = '<%= date %>',
          done_time_h = '<%= time_h %>',
          done_time_m = '<%= time_m %>',
          po_code = '<%= ((String)pageContext.getAttribute("po_code")).trim() %>'
          where source_ref = '<%= complaint_no %>'
        </sql:query>
        <sql:execute />
  
        <%-- Delete insp_list entry --%>
        <sql:query>
          delete from insp_list
          where complaint_no = '<%= complaint_no %>'
        </sql:query>
        <sql:execute />
      </if:IfTrue>
  
      <%-- 12/10/2010  TW  Copy the transect location details to the COMP record --%>
      <%
        String start_point = "";
        String end_point = "";
        String description = "";
        String transect_method = "";
        String exact_location = "";
      %>
      <if:IfTrue cond='<%= !(recordBean.getBv_transect_method() == null || recordBean.getBv_transect_method().equals("")) %>'>
   			<sql:query>
          select lookup_text
            from allk
						where lookup_func = 'BVMEAS'
            and lookup_code = '<%= recordBean.getBv_transect_method() %>'
            and   status_yn = 'Y'
				</sql:query>
        <sql:resultSet id="rset">
					<sql:getColumn position="1" to="transectMethod" />
            <% transect_method = ((String)pageContext.getAttribute("transectMethod")).trim(); %>
				</sql:resultSet>
        <if:IfTrue cond='<%= recordBean.getBv_transect_method().equals("01") %>' >
          <%
            start_point = recordBean.getBv_start_post();
            end_point = recordBean.getBv_stop_post();
            exact_location = transect_method + " start " + start_point + " end " + end_point;
          %>
        </if:IfTrue>
        <if:IfTrue cond='<%= recordBean.getBv_transect_method().equals("02") %>' >
          <%
            start_point = recordBean.getBv_start_house();
            end_point = recordBean.getBv_stop_house();
            exact_location = transect_method + " start " + start_point + " end " + end_point;
          %>
        </if:IfTrue>
        <if:IfTrue cond='<%= recordBean.getBv_transect_method().equals("03") %>' >
          <%
            description = recordBean.getBv_transect_desc();
            exact_location = transect_method + " " + description;
          %>
        </if:IfTrue>
        <if:IfTrue cond='<%= exact_location.length() > 70 %>' >
          <% exact_location = exact_location.substring(0, 70); %>
        </if:IfTrue>
        <sql:query>
          update comp
            set exact_location = '<%= exact_location %>'
            where complaint_no = '<%= complaint_no %>'
        </sql:query>
        <sql:execute />
      </if:IfTrue>

      <if:IfTrue cond='<%= recordBean.getBv_transect() == null || recordBean.getBv_transect().equals("") %>'>
        <%-- Create a new transect_ref record --%>
        <% int transect_ref = 0; %>
        <%-- Get the last transect_ref serial number --%>
        <sql:query>
          select serial_no
          from s_no
          where sn_func = 'bv_transect'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="transect_ref" />
        </sql:resultSet>
  
        <%-- Create the next transect_ref serial number --%>
        <%
          if(pageContext.getAttribute("transect_ref") == null)
          {
            transect_ref = 1;
            pageContext.setAttribute("transect_ref","1");
            %>
              <%-- Update the old complaint serial number with the next one  --%>
              <sql:query>
                insert into s_no (serial_no, sn_func)
                values (2, 'bv_transect')
              </sql:query>
              <sql:execute />
            <%
          }
          else
          {
            transect_ref = Integer.parseInt((String)pageContext.getAttribute("transect_ref"));
            %>
              <%-- Update the old complaint serial number with the next one  --%>
              <sql:query>
                update s_no
                set serial_no = <%= transect_ref %> + 1
                where sn_func = 'bv_transect'
              </sql:query>
              <sql:execute />
            <%
          }
        %>
  
        <%-- Get measurment info for transect --%>
        <if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("01") %>' >
          <%
            start_point = recordBean.getBv_start_post();
            end_point = recordBean.getBv_stop_post();
          %>
        </if:IfTrue>
        <if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("02") %>' >
          <%
            start_point = recordBean.getBv_start_house();
            end_point = recordBean.getBv_stop_house();
          %>
        </if:IfTrue>
        <if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("03") %>' >
          <%
            description = recordBean.getBv_transect_desc();
          %>
        </if:IfTrue>
  
        <%-- INSERT INTO TRANSECT --%>
        <sql:query>
          insert into bv_transect(
          transect_ref,
          transect_date,
          land_use,
          lowdensity_flag,
          ward_flag,
          site_ref,
          measure_method,
          start_ref,
          end_ref,
          description
          )values(
          '<%= ((String)pageContext.getAttribute("transect_ref")).trim() %>',
          '<%= date %>',
          '<%= recordBean.getBv_land_use() %>',
          '<%= recordBean.getBv_lowdensity_flag() %>',
          '<%= recordBean.getBv_ward_flag() %>',
          '<%= recordBean.getBv_site_ref() %>',
          '<%= recordBean.getBv_transect_method() %>',
          '<%= start_point %>',
          '<%= end_point %>',
          '<%= description %>')
        </sql:query>
        <sql:execute />
      </if:IfTrue>
  
      <if:IfTrue cond='<%= !(recordBean.getBv_transect() == null || recordBean.getBv_transect().equals("")) %>'>
        <%
          pageContext.setAttribute("transect_ref",recordBean.getBv_transect());
        %>
        <sql:query>
          update bv_transect
          set transect_date = '<%= date %>'
          where transect_ref = '<%= recordBean.getBv_transect() %>'
        </sql:query>
        <sql:execute />
      </if:IfTrue>
      
      <%-- INSERT COMP_BV199 STUFF --%>
      <sql:query>
        insert into comp_bv199
        (
          complaint_no,
          transect_ref,
          litter_grade,
          litter_text,
          detritus_grade,
          detritus_text,
          graffiti_grade,
          graffiti_text,
          flyposting_grade,
          flyposting_text
        )
        values
        (
          '<%= complaint_no %>',
          '<%= ((String)pageContext.getAttribute("transect_ref")).trim() %>',
          '<%= recordBean.getBv_litter_grade() %>',
          '<%= recordBean.getBv_litter_text().trim() %>',
          '<%= recordBean.getBv_detritus_grade() %>',
          '<%= recordBean.getBv_detritus_text().trim() %>',
          '<%= recordBean.getBv_graffiti_grade() %>',
          '<%= recordBean.getBv_graffiti_text().trim() %>',
          '<%= recordBean.getBv_fly_posting_grade() %>',
          '<%= recordBean.getBv_fly_posting_text().trim() %>'
        )
      </sql:query>
      <sql:execute />
  
      <%-- INSERT COMP_TEXT --%>
      <%-- Is there any text to add --%>
      <if:IfTrue cond='<%= recordBean.getBv_additional_text() != null
                           && !recordBean.getBv_additional_text().equals("") %>' >
  
        <%-- set the comp_seq number value --%>
        <% pageContext.setAttribute("max_comp_seq_no", "0"); %>
        <% int comp_seq = 1; %>
        <sql:query>
          select max(seq)
          from comp_text
          where complaint_no = '<%= complaint_no %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="max_comp_seq_no" />
          <sql:wasNull>
            <% pageContext.setAttribute("max_comp_seq_no", "0"); %>
          </sql:wasNull>
        </sql:resultSet>
        <% comp_seq = Integer.parseInt((String)pageContext.getAttribute("max_comp_seq_no")) + 1; %>
        
        <%-- get rid of newline and carriage return chars --%>
        <%
          String tempTextIn = recordBean.getBv_additional_text();
          tempTextIn = tempTextIn.replace('\n',' ');
          tempTextIn = tempTextIn.replace('\r',' ');
  
          recordBean.setBv_additional_text(tempTextIn);
        %>
  
        <%-- The text should be split into 60 char lines, and there should be a --%>
        <%-- single record for each line. --%>
        <%
          String allText = recordBean.getBv_additional_text();
          String line;
          int lineIndex;
          boolean flag = true;
          do {
            if (allText.length() <= 60) {
              line = allText;
              flag = false;
            } else {
              lineIndex = allText.lastIndexOf(" ", 60);
              // Space not found so use the whole 60
              if (lineIndex == -1) {
                lineIndex = 60;
              } else {
                lineIndex = lineIndex + 1;
              }
              line = allText.substring(0,lineIndex);
              allText = allText.substring(lineIndex);
            }
        %>
            <sql:query>
              insert into comp_text(
                complaint_no,
                seq,
                username,
                doa,
                time_entered_h,
                time_entered_m,
                txt,
                customer_no
              ) values (
                '<%= complaint_no %>',
                '<%= comp_seq %>',
                '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
                '<%= date %>',
                '<%= time_h %>',
                '<%= time_m %>',
                '<%= line %>',
                ''
              )
            </sql:query>
            <sql:execute />
        <%
          comp_seq = comp_seq + 1;
          } while (flag == true);
        %>
  
        <%-- update comp text flag to 'Y' --%>
        <sql:query>
          update comp
          set text_flag = 'Y'
          where complaint_no = '<%= complaint_no %>'
        </sql:query>
        <sql:execute />
      </if:IfTrue>

      <%-- ensure that the recordBean has its Complaint_no set for additional funcs --%>
      <%-- after this one to use --%>
      <% recordBean.setComplaint_no(String.valueOf(complaint_no)); %>
    </sql:statement>
  <sql:closeConnection conn="con1"/>
  
  <%
    //ensure that the printing error status is set to "ok" as no printing occured above.
    recordBean.setPrinting_error("ok");
  %>
</sess:equalsAttribute>
