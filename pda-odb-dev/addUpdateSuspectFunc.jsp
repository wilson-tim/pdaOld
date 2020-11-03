<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.dbb.SNoBean, com.utils.date.vsbCalendar" %>
<%@ page import="com.vsb.recordBean" %>
<%@ page import="com.vsb.loginBean" %>
<%@ page import="com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addUpdateSuspectFunc" value="false">
  addUpdateSuspectFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addUpdateSuspectFunc">
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
    <%-- If enf_evidence screen action is Suspect --%>
    <% String suspect = ""; %>
    <% suspect = recordBean.getSuspect_ref(); %>

    <%-- pda searched for suspect --%>
    <if:IfTrue cond='<%= recordBean.getNew_suspect_flag().equals("N") %>' >
      <%-- insert suspect ref into comp_enf record --%>
      <sql:query>
        Update comp_enf
        set suspect_ref = '<%= recordBean.getSuspect_ref() %>'
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:execute />

      <%-- if pda updated suspect information update relevant suspect_ref record --%>
      <if:IfTrue cond='<%= recordBean.getUpdate_flag().equals("update") %>' >
        <sql:query>
          update enf_suspect
          set title = '<%= recordBean.getSus_title().toUpperCase() %>',
            surname = '<%= recordBean.getSus_surname().toUpperCase() %>',
            fstname = '<%= recordBean.getSus_fstname().toUpperCase() %>',
            midname  = '<%= recordBean.getSus_midname().toUpperCase() %>',
            build_no  = '<%= recordBean.getSus_build_no().toUpperCase() %>',
            build_name  = '<%= recordBean.getSus_build_name().toUpperCase() %>',
            addr1 = '<%= recordBean.getSus_addr1().toUpperCase() %>',
            addr2 = '<%= recordBean.getSus_addr2().toUpperCase() %>',
            addr3  = '<%= recordBean.getSus_addr3().toUpperCase() %>',
            postcode = '<%= recordBean.getSus_postcode().toUpperCase() %>',
            home_phone  = '<%= recordBean.getSus_homeno() %>',
            work_phone = '<%= recordBean.getSus_workno() %>',
            mobile = '<%= recordBean.getSus_mobno() %>',
            est_age = '<%= recordBean.getSus_age() %>',
            <if:IfTrue cond='<%= recordBean.getDob_date().equals("") %>' >
              dob = null,
            </if:IfTrue>
            <if:IfTrue cond='<%= !recordBean.getDob_date().equals("") %>' >
              dob = '<%= recordBean.getDob_date() %>',
            </if:IfTrue>
            sex = '<%= recordBean.getSus_sex() %>',
            external_ref_type = '<%= recordBean.getExternal_ref_type() %>',
            external_ref = '<%= recordBean.getExternal_ref() %>'
          where suspect_ref = '<%= recordBean.getSuspect_ref() %>'
        </sql:query>
        <sql:execute />
      </if:IfTrue>
      <%-- if suspect text was added create new records in the enf_sus_text table: see below --%>
    </if:IfTrue>

    <%-- pda created new suspect --%>
    <if:IfTrue cond='<%= recordBean.getNew_suspect_flag().equals("Y") %>' >
      <% String enf_suspect = "0"; %>

      <%-- Get the last suspect serial number --%>
      <sql:query>
        select serial_no
        from s_no
        where sn_func = 'enf_suspect'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="enf_suspect" />
        <sql:wasNull>
          <%-- update the s_no table with the initial value --%>
          <% pageContext.setAttribute("enf_suspect", "1"); %>
          <sql:statement id="stmt2" conn="con1">
            <sql:query>
              update s_no
              set serial_no = 1
              where sn_func = 'enf_suspect'
            </sql:query>
            <sql:execute />
          </sql:statement>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <%-- insert into s_no the new serial number, and give it it's initial value --%>
        <% pageContext.setAttribute("enf_suspect", "1"); %>
        <sql:statement id="stmt2" conn="con1">
          <sql:query>
            insert into s_no (serial_no, sn_func)
            values (1, 'enf_suspect')
          </sql:query>
          <sql:execute />
        </sql:statement>
      </sql:wasEmpty>

      <%-- Create the next suspect serial number --%>
      <% enf_suspect = ((String)pageContext.getAttribute("enf_suspect")).trim(); %>
      <% suspect = enf_suspect; %>

      <%-- Update the old suspect serial number with the next one --%>
      <sql:query>
        update s_no
        set serial_no = <%= enf_suspect %> + 1
        where sn_func = 'enf_suspect'
      </sql:query>
      <sql:execute />

      <%-- create new suspect_enf record --%>
      <sql:query>
        Insert into enf_suspect (
          suspect_ref,
          title,
          surname,
          fstname,
          midname,
          build_no,
          build_name,
          addr1,
          addr2,
          addr3,
          postcode,
          home_phone,
          work_phone,
          mobile,
          est_age,
          dob,
          sex,
          date_entered,
          entered_by,
          ent_time_h,
          ent_time_m,
          orig_compl_no,
          actions,
          external_ref_type,
          external_ref
        ) values (
          '<%= enf_suspect %>',
          '<%= recordBean.getSus_title().toUpperCase() %>',
          '<%= recordBean.getSus_surname().toUpperCase() %>',
          '<%= recordBean.getSus_fstname().toUpperCase() %>',
          '<%= recordBean.getSus_midname().toUpperCase() %>',
          '<%= recordBean.getSus_build_no().toUpperCase() %>',
          '<%= recordBean.getSus_build_name().toUpperCase() %>',
          '<%= recordBean.getSus_addr1().toUpperCase() %>',
          '<%= recordBean.getSus_addr2().toUpperCase() %>',
          '<%= recordBean.getSus_addr3().toUpperCase() %>',
          '<%= recordBean.getSus_postcode().toUpperCase() %>',
          '<%= recordBean.getSus_homeno() %>',
          '<%= recordBean.getSus_workno() %>',
          '<%= recordBean.getSus_mobno() %>',
          '<%= recordBean.getSus_age() %>',
          <if:IfTrue cond='<%= recordBean.getDob_date().equals("") %>' >
            null,
          </if:IfTrue>
          <if:IfTrue cond='<%= !recordBean.getDob_date().equals("") %>' >
            '<%= recordBean.getDob_date() %>',
          </if:IfTrue>
          '<%= recordBean.getSus_sex() %>',
          '<%= date %>',
          '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
          '<%= time_h %>',
          '<%= time_m %>',
          '<%= recordBean.getComplaint_no() %>',
          0,
          '<%= recordBean.getExternal_ref_type() %>',
          '<%= recordBean.getExternal_ref() %>'
        )
      </sql:query>
      <sql:execute />

      <%-- create company_enf record or use existing --%>
      <if:IfTrue cond = '<%= recordBean.getSus_company() != null  || !(recordBean.getSus_company().equals("")) %>' >
        <if:IfTrue cond = '<%= ! recordBean.getEnfcompany().equals("new") %>' >
          <sql:query>
            update enf_suspect
            set company_ref = '<%= recordBean.getEnfcompany() %>'
            where suspect_ref = '<%= enf_suspect %>'
          </sql:query>
          <sql:execute />
        </if:IfTrue>

        <if:IfTrue cond = '<%= recordBean.getEnfcompany().equals("new") %>' >
          <% int enf_company = 0; %>
          <%-- Get the last suspect serial number --%>
          <sql:query>
            select serial_no
            from s_no
            where sn_func = 'enf_company'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="enf_company" />
            <sql:wasNull>
              <%-- update the s_no table with the initial value --%>
              <% pageContext.setAttribute("enf_company", "1"); %>
              <sql:statement id="stmt2" conn="con1">
                <sql:query>
                  update s_no
                  set serial_no = 1
                  where sn_func = 'enf_company'
                </sql:query>
                <sql:execute />
              </sql:statement>
            </sql:wasNull>
          </sql:resultSet>
          <sql:wasEmpty>
            <%-- insert into s_no the new serial number, and give it it's initial value --%>
            <% pageContext.setAttribute("enf_company", "1"); %>
            <sql:statement id="stmt2" conn="con1">
              <sql:query>
                insert into s_no (serial_no, sn_func)
                values (1, 'enf_company')
              </sql:query>
              <sql:execute />
            </sql:statement>
          </sql:wasEmpty>

          <%-- Create the next suspect serial number --%>
          <% enf_company = Integer.parseInt((String)pageContext.getAttribute("enf_company")); %>

          <%-- Update the old suspect serial number with the next one --%>
          <sql:query>
            update s_no
            set serial_no = <%= enf_company %> + 1
            where sn_func = 'enf_company'
          </sql:query>
          <sql:execute />

          <sql:query>
            insert into enf_company (
              company_ref,
              company_name
            ) values (
              '<%= enf_company %>',
              '<%= recordBean.getSus_newco().toUpperCase().replace('*',' ').replace('%',' ').trim() %>'
            )
          </sql:query>
          <sql:execute />

          <sql:query>
            update enf_suspect
            set company_ref = '<%= enf_company %>'
            where suspect_ref = '<%= enf_suspect %>'
          </sql:query>
          <sql:execute />
        </if:IfTrue>
      </if:IfTrue>

      <%-- insert suspect_ref into comp_enf record --%>
      <sql:query>
        update comp_enf
        set suspect_ref = '<%= enf_suspect %>'
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:execute />
    </if:IfTrue>

    <%-- if suspect text was added create new records in the enf_sus_text table --%>
    <%-- suspect text --%>
    <% String sus_text_flag = "Y"; %>
    <if:IfTrue cond='<%= recordBean.getSus_text() == null || recordBean.getSus_text().equals("") %>' >
      <% sus_text_flag = "N"; %>
    </if:IfTrue>

    <%-- define the comp_seq varible --%>
    <% int enf_sus_seq = 1; %>

    <%-- Is there any text to add --%>
    <if:IfTrue cond='<%= sus_text_flag.equals("Y") %>' >
      <%-- set the comp_seq number value --%>
      <% pageContext.setAttribute("max_comp_seq_no", "0"); %>
      <% enf_sus_seq = 1; %>
      <sql:query>
        select max(seq)
        from enf_sus_text
        where suspect_ref = '<%= suspect %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="max_comp_seq_no" />
        <sql:wasNull>
          <% pageContext.setAttribute("max_comp_seq_no", "0"); %>
        </sql:wasNull>
      </sql:resultSet>
      <% enf_sus_seq = Integer.parseInt((String)pageContext.getAttribute("max_comp_seq_no")) + 1; %>

      <%
        String tempTextIn = "";

        //get rid of newline and carriage return chars
        tempTextIn = recordBean.getSus_text();
        tempTextIn = tempTextIn.replace('\n',' ');
        tempTextIn = tempTextIn.replace('\r',' ');
      %>

      <%-- The text should be split into 60 char lines, and there should be a --%>
      <%-- single record for each line. --%>
      <%
        String allText = tempTextIn.trim();
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
            insert into enf_sus_text (
              suspect_ref,
              seq,
              username,
              doa,
              time_entered_h,
              time_entered_m,
              txt
            ) values (
              '<%= suspect %>',
              '<%= enf_sus_seq %>',
              '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
              '<%= date %>',
              '<%= time_h %>',
              '<%= time_m %>',
              '<%= DbUtils.cleanString(line) %>'
            )
          </sql:query>
          <sql:execute />
      <%
          enf_sus_seq = enf_sus_seq + 1;
        } while (flag == true);
      %>

      <%-- update comp text flag to 'Y' --%>
      <sql:query>
        update enf_suspect
        set text_flag = 'Y'
        where suspect_ref = '<%= suspect %>'
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  </sql:statement>
  <sql:closeConnection conn="con1"/>

  <%-- ensure that the printing error status is set to "ok" as no printing occured. --%>
  <% recordBean.setPrinting_error("ok"); %>
</sess:equalsAttribute>
