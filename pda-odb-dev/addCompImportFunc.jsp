<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, com.vsb.helperBean, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.vsb.recordBean, com.vsb.textBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="textBean" scope="session" class="com.vsb.textBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addCompImportFunc" value="false">
  addCompImportFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addCompImportFunc">
  <%-- ADD A COMPLAINT --%>
  
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
  
  <%-- Is there any text to add --%>
  <% String text_flag = "Y"; %>
  <if:IfTrue cond='<%=textBean.getText() == null || textBean.getText().trim().equals("") %>' >
    <% text_flag = "N"; %>
  </if:IfTrue>
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- Create a new complaint, a new abandoned vehicle --%>
  
    <%-- CREATING A COMPLAINT --%>
  
    <%-- Get recvd_by --%>
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'PDA_SOURCE'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="recvd_by" />
    </sql:resultSet>
  
    <%-- Get the pda_user and set up the details_1 field --%>
    <% String details_1 = ""; %>
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'PDA_USER'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="pda_user" />
      <% details_1 = ((String) pageContext.getAttribute("pda_user")).trim() + ": " + loginBean.getUser_name(); %>
    </sql:resultSet>
  
    <%-- If the service is "AV" (Abandoned Vehicle) then setup the comp_code and itme_ref --%>
    <%-- to indicate an abandoned vehicles update --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals("AV") %>' >
      <sql:query>
        select c_field
        from keys
        where keyname = 'AV_COMP_CODE'
        and   service_c = 'ALL'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="comp_code" />
        <% recordBean.setFault_code((String) pageContext.getAttribute("comp_code")); %>
      </sql:resultSet>
  
      <sql:query>
        select c_field
        from keys
        where keyname = 'AV_ITEM'
        and   service_c = 'ALL'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="item_ref" />
        <% recordBean.setItem_ref((String) pageContext.getAttribute("item_ref")); %>
      </sql:resultSet>
  
      <% recordBean.setInt_ext_flag("I"); %>
    </if:IfTrue>
  
    <%-- If no customer details have been entered set the int_ext_flag = "I" --%>
    <if:IfTrue cond='<%= recordBean.getInt_ext_flag().equals("") %>' >
      <% recordBean.setInt_ext_flag("I"); %>
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
  
    <%-- Create a new comp_import record --%>
    <% int import_key = 0; %>
    <%-- Get the last comp_import serial number --%>
    <sql:query>
      select serial_no
      from s_no
      where sn_func = 'comp_import'
    </sql:query>
    <sql:resultSet id="rset">
    	<sql:getColumn position="1" to="comp_import" />
      	<sql:wasNull>
   	   	<%-- update the s_no table with the initial value --%>
   	   	<% pageContext.setAttribute("comp_import", "1"); %>
   	   	<sql:statement id="stmt2" conn="con1">
       		<sql:query>
         		update s_no
         		set serial_no = 1
         		where sn_func = 'comp_import'
        	</sql:query>
        	<sql:execute />
      	</sql:statement>
     	</sql:wasNull>
  	</sql:resultSet>
    <sql:wasEmpty>
    	<%-- insert into s_no the new serial number, and give it it's initial value --%>
      <% pageContext.setAttribute("comp_import", "1"); %>
      <sql:statement id="stmt2" conn="con1">
      	<sql:query>
        	insert into s_no (serial_no, sn_func)
         	values (1, 'comp_import')
       	</sql:query>
      	<sql:execute />
  		</sql:statement>
    </sql:wasEmpty>
  
    <%-- Create the next comp_import serial number --%>
    <% import_key = Integer.parseInt((String)pageContext.getAttribute("comp_import")); %>
  
    <%-- Update the old complaint serial number with the next one --%>
    <sql:query>
      update s_no
      set serial_no = <%= import_key %> + 1
      where sn_func = 'comp_import'
    </sql:query>
    <sql:execute />
  
    <%-- Adding the complaint record --%>
    <sql:query>
      insert into comp_import (
        import_key,
        import_ref,
        import_date,
        import_time,
        import_status,
        recvd_by,
        site_ref,
        location_c,
        build_no,
        build_name,
        location_name,
        postcode,
        exact_location,
        compl_name,
        compl_surname,
        compl_init,
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
        details_1,
        service_c,
        text_flag,
        comp_code,
        item_ref,
        int_ext_flag
      ) values (
        '<%= import_key %>',
        '<%= import_key %>',
        '<%= date %>',
        '<%= time %>',
        'W',
        '<%= DbUtils.cleanString(((String) pageContext.getAttribute("recvd_by")).trim()) %>',
        '<%= recordBean.getSite_ref() %>',
        '<%= recordBean.getLocation_c() %>',
        '<%= recordBean.getBuild_no() %>',
        '<%= long_build_name %>',
        '<%= recordBean.getLocation_name() %>',
        '<%= recordBean.getPostcode() %>',
        '<%= textBean.getExact_location().toUpperCase() %>',
        '<%= recordBean.getCompl_name().toUpperCase() %>',
        '<%= recordBean.getCompl_surname().toUpperCase() %>',
        '<%= recordBean.getCompl_init().toUpperCase() %>',
        '<%= recordBean.getCompl_site_ref() %>',
        '<%= recordBean.getCompl_location_c() %>',
        '<%= recordBean.getCompl_build_no().toUpperCase() %>',
        '<%= compl_long_build_name.toUpperCase() %>',
        '<%= recordBean.getCompl_addr2().toUpperCase() %>',
        '<%= recordBean.getCompl_addr3().toUpperCase() %>',
        '<%= recordBean.getCompl_addr4().toUpperCase() %>',
        '<%= recordBean.getCompl_postcode().toUpperCase() %>',
        '<%= recordBean.getCompl_phone().toUpperCase() %>',
        '<%= recordBean.getCompl_email() %>',
        '<%= details_1 %>',
        '<%= recordBean.getService_c() %>',
        '<%= text_flag %>',
        '<%= recordBean.getFault_code() %>',
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getInt_ext_flag() %>'
      )
    </sql:query>
    <sql:execute />
  
    <%-- Is there any text to add --%>
    <if:IfTrue cond='<%= text_flag.equals("Y") %>' >
      <%-- get rid of newline and carriage return chars --%>
      <%
        String tempTextIn = textBean.getText();
        tempTextIn = tempTextIn.replace('\n',' ');
        tempTextIn = tempTextIn.replace('\r',' ');
  
        textBean.setText(tempTextIn);
      %>
  
      <%-- The text should be split into 60 char lines, and there should be a --%>
      <%-- single record for each line. --%>
      <%
        String allText = textBean.getText();
        String line;
        int lineIndex;
        boolean flag = true;
        int comp_seq = 1;
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
            insert into comp_text_import (
              import_key,
              seq,
              username,
              doa,
              txt,
              time_entered_h,
  						time_entered_m,
              customer_no
            ) values (
              '<%= import_key %>',
              '<%= comp_seq %>',
              '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
              '<%= date %>',
              '<%= time_h %>',
         		  '<%= time_m %>',
              '<%= line %>',
              null
            )
          </sql:query>
          <sql:execute />
      <%
        comp_seq = comp_seq + 1;
        } while (flag == true);
      %>
    </if:IfTrue>
  
    <%-- If the service is "AV" (Abandoned Vehicle) then add an abandoned vehicle --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals("AV") %>' >
      <%-- CREATING AN ABANDONED VEHICLE --%>
  
      <%-- Insert a new comp_av for the complaint --%>
      <sql:query>
        insert into comp_av_import (
          import_key,
          car_id,
          make_desc,
          model_desc,
          colour_desc
        ) values (
          '<%= import_key %>',
          '<%= recordBean.getCar_id().toUpperCase() %>',
          '<%= recordBean.getMake_desc() %>',
          '<%= recordBean.getModel_desc() %>',
          '<%= recordBean.getColour_desc() %>'
        )
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  
    <%-- If the service is "HWAY" (Highways) then add a highway request --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals("HWAY") %>' >
      <%-- CREATING A HIGHWAY REQUEST --%>
  
      <%-- Insert a new comp_av for the complaint --%>
      <sql:query>
        insert into comp_hway_import (
          import_key,
          current_status,
          status_change_date,
          estimated_cost,
          final_cost,
          committed_cost
        ) values (
          '<%= import_key %>',
          'REC',
          '<%= date %>',
          '0',
          '0',
          '0'
        )
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  
  </sql:statement>
  <sql:closeConnection conn="con1"/>
</sess:equalsAttribute>
