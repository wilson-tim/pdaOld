<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, com.vsb.helperBean, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.vsb.recordBean, com.vsb.loginBean" %>
<%@ page import="com.vsb.graffDetailsBean, com.vsb.dartDetailsBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="graffDetailsBean" scope="session" class="com.vsb.graffDetailsBean" />
<jsp:useBean id="dartDetailsBean" scope="session" class="com.vsb.dartDetailsBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addDartGraffFunc" value="false">
  addDartGraffFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addDartGraffFunc">
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
      <%-- do we update or do we insert --%>
      <% boolean update_detail = false; %>
      <sql:query>
        select count(*)
        from comp_dart_header
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="count" />
        <if:IfTrue cond='<%= Integer.parseInt(((String) pageContext.getAttribute("count")).trim()) > 0 %>' >
          <% update_detail = true; %>
        </if:IfTrue>
      </sql:resultSet>
      
      <if:IfTrue cond='<%= update_detail %>' >
        <%-- update --%>
  
        <%-- do the header and header log --%>
        <sql:query>
          update comp_dart_header
          set rep_needle_qty = '<%= dartDetailsBean.getRep_needle_qty() %>',
            rep_crack_pipe_qty = '<%= dartDetailsBean.getRep_crack_pipe_qty() %>',
            rep_condom_qty = '<%= dartDetailsBean.getRep_condom_qty() %>',
            col_needle_qty = '<%= dartDetailsBean.getCol_needle_qty() %>',
            col_crack_pipe_qty = '<%= dartDetailsBean.getCol_crack_pipe_qty() %>',
            col_condom_qty = '<%= dartDetailsBean.getCol_condom_qty() %>',
            wo_est_cost = '<%= dartDetailsBean.getWo_est_cost() %>',
            refuse_pay = '<%= dartDetailsBean.getRefuse_pay() %>',
            est_duration_h = '<%= dartDetailsBean.getEst_duration_h() %>',
            est_duration_m = '<%= dartDetailsBean.getEst_duration_m() %>',
            po_code = '<%= ((String)pageContext.getAttribute("po_code")).trim() %>',
            completion_date = '<%= date %>',
            completion_time_h = '<%= time_h %>',
            completion_time_m = '<%= time_m %>'
          where complaint_no = '<%= recordBean.getComplaint_no() %>' 
        </sql:query>
        <sql:execute/>
  
        <%-- make a log entry of the update --%>
        <% int next_seq = 0; %>
        <sql:query>
          select count(*)
          from comp_dart_hdr_log
          where complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="count" />
        </sql:resultSet>
        <% next_seq = Integer.parseInt(((String) pageContext.getAttribute("count")).trim()) + 1; %>
  
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
            '<%= recordBean.getComplaint_no() %>',
            '<%= dartDetailsBean.getRep_needle_qty() %>',
            '<%= dartDetailsBean.getRep_crack_pipe_qty() %>',
            '<%= dartDetailsBean.getRep_condom_qty() %>',
            '<%= dartDetailsBean.getCol_needle_qty() %>',
            '<%= dartDetailsBean.getCol_crack_pipe_qty() %>',
            '<%= dartDetailsBean.getCol_condom_qty() %>',
            '<%= dartDetailsBean.getWo_est_cost() %>',
            '<%= dartDetailsBean.getRefuse_pay() %>',
            '<%= dartDetailsBean.getEst_duration_h() %>',
            '<%= dartDetailsBean.getEst_duration_m() %>',
            '<%= ((String)pageContext.getAttribute("po_code")).trim() %>',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>',
            <%= next_seq %>,
            '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>'
          )
        </sql:query>
        <sql:execute/>
      </if:IfTrue>
      <if:IfTrue cond='<%= ! update_detail %>' >
        <%-- insert --%>
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
            '<%= recordBean.getComplaint_no() %>',
            '<%= dartDetailsBean.getRep_needle_qty() %>',
            '<%= dartDetailsBean.getRep_crack_pipe_qty() %>',
            '<%= dartDetailsBean.getRep_condom_qty() %>',
            '<%= dartDetailsBean.getCol_needle_qty() %>',
            '<%= dartDetailsBean.getCol_crack_pipe_qty() %>',
            '<%= dartDetailsBean.getCol_condom_qty() %>',
            '<%= dartDetailsBean.getWo_est_cost() %>',
            '<%= dartDetailsBean.getRefuse_pay() %>',
            '<%= dartDetailsBean.getEst_duration_h() %>',
            '<%= dartDetailsBean.getEst_duration_m() %>',
            '<%= ((String)pageContext.getAttribute("po_code")).trim() %>',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>'
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
            '<%= recordBean.getComplaint_no() %>',
            '<%= dartDetailsBean.getRep_needle_qty() %>',
            '<%= dartDetailsBean.getRep_crack_pipe_qty() %>',
            '<%= dartDetailsBean.getRep_condom_qty() %>',
            '<%= dartDetailsBean.getCol_needle_qty() %>',
            '<%= dartDetailsBean.getCol_crack_pipe_qty() %>',
            '<%= dartDetailsBean.getCol_condom_qty() %>',
            '<%= dartDetailsBean.getWo_est_cost() %>',
            '<%= dartDetailsBean.getRefuse_pay() %>',
            '<%= dartDetailsBean.getEst_duration_h() %>',
            '<%= dartDetailsBean.getEst_duration_m() %>',
            '<%= ((String)pageContext.getAttribute("po_code")).trim() %>',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>',
            1,
            '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>'
          )
        </sql:query>
        <sql:execute/>
      </if:IfTrue>
  
      <%-- do the detail and detail log --%>
      <%-- we only insert into this table even if we are updating, we just --%>
      <%-- delete the ones already there, saves doing check on each insert --%>
      <sql:query>
        delete from comp_dart_detail
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:execute/>
  
      <%-- get the sequence number for the next comp_dart_dtl_log entries --%>
      <%-- all the below inserts get the same sequence number --%>
      <% int next_seq = 0; %>
      <sql:query>
        select count(*)
        from comp_dart_dtl_log
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="count" />
      </sql:resultSet>
      <% next_seq = Integer.parseInt(((String) pageContext.getAttribute("count")).trim()) + 1; %>
  
      <%-- As the insert for each group is almost the same, a generic insert --%>
      <%-- will be used, and the differences taken cars of by variables. --%>
      <%
        // string of category
        String category = "";
        //array of the ticked items
        String[] category_array = null;
        
        // number of gategories
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
                    '<%= recordBean.getComplaint_no() %>',
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
                    '<%= recordBean.getComplaint_no() %>',
                    '<%= category %>',
                    '<%= category_array[j].trim() %>',
                    <%= next_seq %>,
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
      <%-- do we update or do we insert --%>
      <% boolean update_detail = false; %>
      <sql:query>
        select count(*)
        from comp_ert_header
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="count" />
        <if:IfTrue cond='<%= Integer.parseInt(((String) pageContext.getAttribute("count")).trim()) > 0 %>' >
          <% update_detail = true; %>
        </if:IfTrue>
      </sql:resultSet>
      <if:IfTrue cond='<%= update_detail %>' >
        <%-- update --%>
        <sql:query>
          update comp_ert_header
          set volume_ref = '<%= graffDetailsBean.getVolume_ref() %>',
            tag_offensive = '<%= graffDetailsBean.getTag_offensive() %>',
            tag_visible = '<%= graffDetailsBean.getTag_visible() %>',
            tag_recognisable = '<%= graffDetailsBean.getTag_recognisable() %>',
            tag_known_offender = '<%= graffDetailsBean.getTag_known_offender() %>',
            tag_offender_info = '<%= graffDetailsBean.getTag_offender_info().toUpperCase() %>',
            tag_repeat_offence = '<%= graffDetailsBean.getTag_repeat_offence() %>',
            tag_offences_ref = '<%= graffDetailsBean.getTag_offences_ref() %>',
            rem_workforce_ref = '<%= graffDetailsBean.getRem_workforce_ref() %>',
            wo_est_cost = <%= graffDetailsBean.getWo_est_cost() %>,
            refuse_pay = '<%= graffDetailsBean.getRefuse_pay() %>',
            est_duration_h = '<%= graffDetailsBean.getEst_duration_h() %>',
            est_duration_m = '<%= graffDetailsBean.getEst_duration_m() %>',
            po_code = '<%= ((String)pageContext.getAttribute("po_code")).trim() %>',
            graffiti_level_ref = '<%= graffDetailsBean.getGraffiti_level_ref() %>',
            completion_date = '<%= date %>',
            completion_time_h = '<%= time_h %>',
            completion_time_m = '<%= time_m %>',
            indemnity_response = '<%= graffDetailsBean.getIndemnity_response() %>',
            <if:IfTrue cond='<%= graffDetailsBean.getIndemnity_response().equals("Y") %>' >
              indemnity_date = '<%= graffDetailsBean.getIndemnity_date() %>',
              indemnity_time_h = '<%= graffDetailsBean.getIndemnity_time_h() %>',
              indemnity_time_m = '<%= graffDetailsBean.getIndemnity_time_m() %>',
            </if:IfTrue>
            <if:IfTrue cond='<%= ! graffDetailsBean.getIndemnity_response().equals("Y") %>' >
              indemnity_date = null,
              indemnity_time_h = '',
              indemnity_time_m = '',
            </if:IfTrue>
            cust_responsible = '<%= graffDetailsBean.getCust_responsible() %>',
            <if:IfTrue cond='<%= ! graffDetailsBean.getLandlord_perm_date().equals("") %>' >
              landlord_perm_date = '<%= graffDetailsBean.getLandlord_perm_date() %>'
            </if:IfTrue>
            <if:IfTrue cond='<%= graffDetailsBean.getLandlord_perm_date().equals("") %>' >
              landlord_perm_date = null
            </if:IfTrue>
          where complaint_no = '<%= recordBean.getComplaint_no() %>' 
        </sql:query>
        <sql:execute/>
        <%-- make a log entry of the update --%>
        <% int next_seq = 0; %>
        <sql:query>
          select count(*)
          from comp_ert_hdr_log
          where complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="count" />
        </sql:resultSet>
        <% next_seq = Integer.parseInt(((String) pageContext.getAttribute("count")).trim()) + 1; %>
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
            <%= next_seq %>,
            '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>'
          )
        </sql:query>
        <sql:execute/>
      </if:IfTrue>
      <if:IfTrue cond='<%= ! update_detail %>' >
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
            '<%= recordBean.getComplaint_no() %>',
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
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>',
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
            '<%= recordBean.getComplaint_no() %>',
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
            '<%= date %>',
            '<%= time_h %>',
            '<%= time_m %>',
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
      </if:IfTrue>
  
      <%-- Only update or insert a Tag if one was entered --%>
      <if:IfTrue cond='<%= ! graffDetailsBean.getTag().trim().equals("") %>' >
        <%-- do we update or do we insert --%>
        <% boolean update_tag = false; %>
        <sql:query>
          select count(*)
          from comp_ert_tags
          where complaint_no = '<%= recordBean.getComplaint_no() %>'
          and seq_no = 1
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="count" />
          <if:IfTrue cond='<%= Integer.parseInt(((String) pageContext.getAttribute("count")).trim()) > 0 %>' >
            <% update_tag = true; %>
          </if:IfTrue>
        </sql:resultSet>
        
        <if:IfTrue cond='<%= update_tag %>' >
          <%-- update --%>
          <sql:query>
            update comp_ert_tags
            set username = '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
              tag = '<%= graffDetailsBean.getTag().toUpperCase() %>',
              doa = '<%= date %>'
            where complaint_no = '<%= recordBean.getComplaint_no() %>'
            and seq_no = 1
          </sql:query>
          <sql:execute/>
        </if:IfTrue>
        <if:IfTrue cond='<%= ! update_tag %>' >
          <%-- insert --%>
          <sql:query>
            insert into comp_ert_tags (
              complaint_no,
              seq_no,
              username,
              tag,
              doa
            ) values (
              '<%= recordBean.getComplaint_no() %>',
              1,
              '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
              '<%= graffDetailsBean.getTag().toUpperCase() %>',
              '<%= date %>'
            )
          </sql:query>
          <sql:execute/>
        </if:IfTrue>
      </if:IfTrue>
  
      <%-- do the detail and detail log --%>
      <%-- we only insert into this table even if we are updating, we just --%>
      <%-- delete the ones already there, saves doing check on each insert --%>
      <sql:query>
        delete from comp_ert_detail
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:execute/>
  
      <%-- get the sequence number for the next comp_ert_dtl_log entries --%>
      <%-- all the below inserts get the same sequence number --%>
      <% int next_seq = 0; %>
      <sql:query>
        select count(*)
        from comp_ert_dtl_log
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="count" />
      </sql:resultSet>
      <% next_seq = Integer.parseInt(((String) pageContext.getAttribute("count")).trim()) + 1; %>
  
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
                    '<%= recordBean.getComplaint_no() %>',
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
                    '<%= recordBean.getComplaint_no() %>',
                    '<%= category %>',
                    '<%= category_array[j].trim() %>',
                    <%= next_seq %>,
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
  
    <%-- If there is a wo_est_cost then set the complaint to HOLD --%>
    <%-- otherwise close the complaint --%>
    <% boolean wo_est_cost_exist = true; %>
    <if:IfTrue cond='<%= (dartDetailsBean.getWo_est_cost() == null || dartDetailsBean.getWo_est_cost().equals("")) && (graffDetailsBean.getWo_est_cost() == null || graffDetailsBean.getWo_est_cost().equals("")) %>' >
      <% wo_est_cost_exist = false; %>
    </if:IfTrue> 
  
    <if:IfTrue cond='<%= wo_est_cost_exist == true %>' >
      <%-- set complaint to HOLD --%>
      <sql:query>
        update comp
        set action_flag = 'H',
          comp_code = '<%= recordBean.getFault_code() %>'
        where complaint_no = '<%= recordBean.getComplaint_no()%>'
      </sql:query>
      <sql:execute />
    </if:IfTrue> 
  
    <if:IfTrue cond='<%= wo_est_cost_exist == false %>' >
      <%-- Close the default diry record --%>
      <sql:query>
        update diry
        set action_flag = 'C',
          dest_flag = 'C',
          date_done = '<%= date %>',
          done_time_h = '<%= time_h %>',
          done_time_m = '<%= time_m %>',
          po_code = '<%= ((String)pageContext.getAttribute("po_code")).trim() %>'
        where source_ref = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:execute />
    
      <%-- close the complaint --%>
      <sql:query>
        update comp
        set action_flag = 'N',
          date_closed = '<%= date %>',
          time_closed_h = '<%= time_h %>',
          time_closed_m = '<%= time_m %>',
          comp_code = '<%= recordBean.getFault_code() %>'
        where complaint_no = '<%= recordBean.getComplaint_no()%>'
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  
    <%-- delete any occurance of the complaint from the inspection --%>
    <%-- list table, as it should no longer be accessed. --%>
    <sql:query>
      delete from insp_list
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:execute/>
    
  </sql:statement>
  <sql:closeConnection conn="con1"/>
  
  <% recordBean.setUpdate_text("Y"); %>
</sess:equalsAttribute>
