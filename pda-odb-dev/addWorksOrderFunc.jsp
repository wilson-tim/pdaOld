<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, com.vsb.helperBean, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.vsb.recordBean, com.vsb.textBean, com.vsb.loginBean, com.vsb.compSampDetailsBean" %>
<%@ page import="com.vsb.woTaskBean, com.vsb.woDetailsBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>

<jsp:useBean id="DbUtils"             scope="session" class="com.db.DbUtils"              />
<jsp:useBean id="helperBean"          scope="session" class="com.vsb.helperBean"          />
<jsp:useBean id="recordBean"          scope="session" class="com.vsb.recordBean"          />
<jsp:useBean id="textBean"            scope="session" class="com.vsb.textBean"            />
<jsp:useBean id="loginBean"           scope="session" class="com.vsb.loginBean"           />
<jsp:useBean id="compSampDetailsBean" scope="session" class="com.vsb.compSampDetailsBean" />
<jsp:useBean id="woTaskBean"          scope="session" class="com.vsb.woTaskBean"          />
<jsp:useBean id="woDetailsBean"       scope="session" class="com.vsb.woDetailsBean"       />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addWorksOrderFunc" value="false">
  addWorksOrderFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addWorksOrderFunc">
  <%--
    This is a brief outline about what the below sql actually does.
    
    a) a works order is created.
    b) the works order text box is used to fill in the complaint text.
    c) a works order diry is created.
    d) the already created (in addComplaintFunc.jsp) complaint and diry are updated.
    e) control passes to the addTextFunc page. (see addTextFunc.jsp for further details).
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
    <%-- Create a new works order --%>
    <%
      String del_addr1 = "";
      String del_addr2 = "";
      String del_addr3 = "";
      String del_build_name = "";
      String del_postcode = "";
      String del_build_no = "";
    %>
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
  
    <%-- Set up the *_addr1 and *_addr2 --%>
    <% del_addr1 = location_desc; %>
    <% del_addr2 = location_name; %>
    
    <%-- Set up the del_addr3/inv_addr3 --%>
    <% del_addr3 = recordBean.getArea_ward_desc(); %>
  
    <%-- Set up the del_build_name/inv_build_name --%>
    <% del_build_name = long_build_name; %>
  
    <%-- set up the *_postcode and *_build_no --%>
    <% del_postcode = recordBean.getPostcode(); %>
    <% del_build_no = recordBean.getBuild_no(); %>
  
    <%-- set the inv_* details --%>
    <%
      String inv_site_ref = "";
      String inv_contact = "";
      String inv_build_no = "";
      String inv_build_name = "";
      String inv_addr1 = "";
      String inv_addr2 = "";
      String inv_addr3 = "";
      String inv_postcode = "";
      String inv_phone = "";
  
      inv_site_ref = recordBean.getSite_ref();
      inv_contact = recordBean.getDel_contact().toUpperCase();
      inv_build_no = del_build_no;
      inv_build_name = del_build_name;
      inv_addr1 = del_addr1;
      inv_addr2 = del_addr2;
      inv_addr3 = del_addr3;
      inv_postcode = del_postcode;
      inv_phone = recordBean.getDel_phone();
    %>
  
    <%-- get the payment method --%>
    <sql:query>
      select c_field
      from keys
      where keyname = 'WO_PAYMETH_PREPD'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="paymeth" />
      <sql:wasNull>
        <% pageContext.setAttribute("paymeth", "P"); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("paymeth", "P"); %>
    </sql:wasEmpty>
   
    <%-- get the initial wo_h_stat for the service --%>
    <sql:query>
      select c_field
      from keys
      where service_c = '<%= recordBean.getService_c() %>'
      and  keyname = 'WO_H_INIT_STATUS'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="wo_h_stat" />
      <sql:wasNull>
        <% pageContext.setAttribute("wo_h_stat", "I"); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("wo_h_stat", "I"); %>
    </sql:wasEmpty>
 
    <%-- Get the last works order serial number --%>
    <sql:query>
      select serial_no
      from s_no
      where sn_func = 'WK_ORD'
      and   contract_ref = '<%= recordBean.getWo_contract_ref() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="wk_ord" />
      <sql:wasNull>
        <%-- update the s_no table with the initial value --%>
        <% pageContext.setAttribute("wk_ord", "1"); %>
        <sql:statement id="stmt2" conn="con1">
          <sql:query>
            update s_no
            set serial_no = 1
            where sn_func = 'WK_ORD'
            and   contract_ref = '<%= recordBean.getWo_contract_ref() %>'
          </sql:query>
          <sql:execute />
        </sql:statement>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <%-- insert into s_no the new serial number, and give it it's initial value --%>
      <% pageContext.setAttribute("wk_ord", "1"); %>
      <sql:statement id="stmt2" conn="con1">
        <sql:query>
          insert into s_no (serial_no, sn_func, contract_ref) 
          values (1, 'WK_ORD', '<%= recordBean.getWo_contract_ref() %>')
        </sql:query>
        <sql:execute />
      </sql:statement>
    </sql:wasEmpty>
  
    <%-- Create the next suspect serial number --%>
    <% int wo_ref = Integer.parseInt((String)pageContext.getAttribute("wk_ord")); %>
  
    <%-- Update the old serial number with the next one --%>
    <sql:query>
      update s_no
      set serial_no = <%= wo_ref %> + 1
      where sn_func = 'WK_ORD'
      and   contract_ref = '<%= recordBean.getWo_contract_ref() %>'
    </sql:query>
    <sql:execute />
  
    <%-- Get the last works order serial number --%>
    <sql:query>
      select serial_no
      from s_no
      where sn_func = 'wo_h'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="wo_h" />
      <sql:wasNull>
        <%-- update the s_no table with the initial value --%>
        <% pageContext.setAttribute("wo_h", "1"); %>
        <sql:statement id="stmt2" conn="con1">
          <sql:query>
            update s_no
            set serial_no = 1
            where sn_func = 'wo_h'
          </sql:query>
          <sql:execute />
        </sql:statement>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <%-- insert into s_no the new serial number, and give it it's initial value --%>
      <% pageContext.setAttribute("wo_h", "1"); %>
      <sql:statement id="stmt2" conn="con1">
        <sql:query>
          insert into s_no (serial_no, sn_func) 
          values (1, 'wo_h')
        </sql:query>
        <sql:execute />
      </sql:statement>
    </sql:wasEmpty>
  
    <%-- Create the next serial number --%>
    <% int wo_key = Integer.parseInt((String)pageContext.getAttribute("wo_h")); %>
  
    <%-- Update the old serial number with the next one --%>
    <sql:query>
      update s_no
      set serial_no = <%= wo_key %> + 1
      where sn_func = 'wo_h'
    </sql:query>
    <sql:execute />
  
    <%-- Create the works order header --%>
    <sql:query>
      insert into wo_h (
        wo_ref,
        wo_key,
        wo_suffix,
        service_c,
        date_raised,
        time_raised_h,
        time_raised_m,
        username,
        del_site_ref,
        del_contact,
        del_build_no,
        del_build_name,
        del_addr1,
        del_addr2,
        del_addr3,
        del_postcode,
        del_phone,
        inv_site_ref,
        inv_contact,
        inv_build_no,
        inv_build_name,
        inv_addr1,
        inv_addr2,
        inv_addr3,
        inv_postcode,
        inv_phone,
        contract_ref,
        wo_type_f,
        wo_h_stat,
        action_ref,
        wo_paymeth,
        wo_payment_f,
        wo_date_due,
        expected_time_h,
        expected_time_m,
        wo_est_value,
        wo_act_value
      ) values (
        <%= wo_ref %>,
        <%= wo_key %>,
        '<%= recordBean.getWo_suffix() %>',
        '<%= recordBean.getService_c() %>',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        '<%= recordBean.getSite_ref() %>',
        '<%= recordBean.getDel_contact().toUpperCase() %>',
        '<%= del_build_no %>',
        '<%= del_build_name %>',
        '<%= del_addr1 %>',
        '<%= del_addr2 %>',
        '<%= del_addr3 %>',
        <if:IfTrue cond='<%= del_postcode.equals("") %>' >
          null,
        </if:IfTrue>
        <if:IfTrue cond='<%= ! del_postcode.equals("") %>' >
          '<%= del_postcode %>',
        </if:IfTrue>
        '<%= recordBean.getDel_phone() %>',
        '<%= inv_site_ref %>',
        '<%= inv_contact %>',
        '<%= inv_build_no %>',
        '<%= inv_build_name %>',
        '<%= inv_addr1 %>',
        '<%= inv_addr2 %>',
        '<%= inv_addr3 %>',
        <if:IfTrue cond='<%= inv_postcode.equals("") %>' >
          null,
        </if:IfTrue>
        <if:IfTrue cond='<%= ! inv_postcode.equals("") %>' >
          '<%= inv_postcode %>',
        </if:IfTrue>
        '<%= inv_phone %>',     
        '<%= recordBean.getWo_contract_ref() %>',
        '<%= recordBean.getWo_type_f() %>',
        '<%= ((String)pageContext.getAttribute("wo_h_stat")).trim() %>',
        null,
        '<%= ((String)pageContext.getAttribute("paymeth")).trim() %>',
        null,
        '<%= recordBean.getWo_due_date() %>',
        '23',
        '59',
        <%= recordBean.getWo_line_total() %>,
        <%= recordBean.getWo_line_total() %>
      )
    </sql:query>
    <sql:execute />
  
    <%-- Create the works order history if required --%>
    <sql:query>
      select c_field
      from keys
      where keyname = 'WO_STAT_ENHANCEMENTS'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="wo_stat_enhancements" />
      <sql:wasNull>
        <% pageContext.setAttribute("wo_stat_enhancements", "N"); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("wo_stat_enhancements", "N"); %>
    </sql:wasEmpty>
    <% String wo_stat_enhance = ((String)pageContext.getAttribute("wo_stat_enhancements")).trim(); %>
  
    <if:IfTrue cond='<%= wo_stat_enhance.equals("Y") %>' >
      <sql:query>
        insert into wo_stat_hist (
          wo_ref,
          wo_suffix,
          seq_no,
          wo_h_stat,
          user_name,
          change_date,
          change_time_h,
          change_time_m
        ) values (
          <%= wo_ref %>,
          '<%= recordBean.getWo_suffix() %>',
          1,
          '<%= ((String)pageContext.getAttribute("wo_h_stat")).trim() %>',
          '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
          '<%= date %>',
          '<%= time_h %>',
          '<%= time_m %>'
        )
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  
    <%-- Create the works order contractor --%>
    <sql:query>
      insert into wo_cont_h (
        wo_ref,
        wo_suffix
      ) values (
        <%= wo_ref %>,
        '<%= recordBean.getWo_suffix() %>'
      )
    </sql:query>
    <sql:execute />
  
    <%-- Get the last works order item serial number --%>
    <sql:query>
      select serial_no
      from s_no
      where sn_func = 'wo_i'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="wo_i" />
      <sql:wasNull>
        <%-- update the s_no table with the initial value --%>
        <% pageContext.setAttribute("wo_i", "1"); %>
        <sql:statement id="stmt2" conn="con1">
          <sql:query>
            update s_no
            set serial_no = 1
            where sn_func = 'wo_i'
          </sql:query>
          <sql:execute />
        </sql:statement>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <%-- insert into s_no the new serial number, and give it it's initial value --%>
      <% pageContext.setAttribute("wo_i", "1"); %>
      <sql:statement id="stmt2" conn="con1">
        <sql:query>
          insert into s_no (serial_no, sn_func) 
          values (1, 'wo_i')
        </sql:query>
        <sql:execute />
      </sql:statement>
    </sql:wasEmpty>
  
    <%-- Create the next serial number --%>
    <% int woi_serial_no = Integer.parseInt((String)pageContext.getAttribute("wo_i")); %>
  
    <%-- Update the old serial number with the next one --%>
    <sql:query>
      update s_no
      set serial_no = <%= woi_serial_no %> + 1
      where sn_func = 'wo_i'
    </sql:query>
    <sql:execute />
  
    <%-- Create the works order items from the task refs in the woTaskBean --%>
    <% int woi_no = 1;      %>
    <% Iterator woi_task_refs = woTaskBean.iterator();          %>
    <% while( woi_task_refs.hasNext() ) {                       %>
    <%   String woi_task_ref    = (String)woi_task_refs.next(); %>
    <%   String woi_task_rate   = (String)woDetailsBean.getWoi_task_rate( woi_task_ref );   %>
    <%   String woi_task_volume = (String)woDetailsBean.getWoi_task_volume( woi_task_ref ); %>
    <%   String line_total      = (String)woDetailsBean.getLine_total( woi_task_ref );      %>
      <sql:query>
        insert into wo_i (
          woi_serial_no,
          wo_ref,
          wo_suffix,
          woi_no,
          woi_site_ref,
          woi_task_ref,
          woi_feature_ref,
          woi_item_ref,
          woi_volume,
          woi_item_price,
          woi_line_total,
          woi_comp_date,
          del_build_no,
          del_build_name,
          del_addr1,
          del_addr2,
          woi_act_vol,
          woi_act_price,
          woi_act_line_total
        ) values (
          <%= woi_serial_no %>,
          <%= wo_ref %>,
          '<%= recordBean.getWo_suffix() %>',
          <%= woi_no %>,
          '<%= recordBean.getSite_ref() %>',
          '<%= woi_task_ref %>',
          null,
          null,
          <%= woi_task_volume %>,
          <%= woi_task_rate %>,
          <%= line_total %>,
          '<%= recordBean.getWo_due_date() %>',
          '<%= del_build_no %>',
          '<%= del_build_name %>',
          '<%= del_addr1 %>',
          '<%= del_addr2 %>',
          <%= woi_task_volume %>,
          <%= woi_task_rate %>,
          <%= line_total %>
        )
      </sql:query>
      <sql:execute />

      <%-- Update the woi_no for the next task --%>
      <% woi_no++; %>
    <% } // END while loop woi_task_refs %>

    <%-- Does the works order copy the complaint text --%>
    <% String comp_text_to_wo = "Y"; %>
    <sql:query>
      select c_field
      from keys
      where service_c = '<%= recordBean.getService_c() %>'
      and   keyname = 'COMP_TEXT TO WO'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="c_field" />
      <sql:wasNotNull>
        <% comp_text_to_wo = ((String)pageContext.getAttribute("c_field")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>

    <%-- Does the complaint have any text --%>
    <% String comp_text_flag = "N"; %>
    <sql:query>
      SELECT text_flag
        FROM comp
       WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="comp_text_flag" />
      <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("comp_text_flag") ) %>'>
        <if:IfTrue cond='<%= ((String)pageContext.getAttribute("comp_text_flag")).trim().equals("Y")  %>'>
          <% comp_text_flag = "Y"; %>
        </if:IfTrue>
      </if:IfTrue>
    </sql:resultSet>
  
    <%-- If the complaint does have text, add it now before checking for any
         new added text in the textBean or compSampDetails Bean. The code below
         copies all the text from the comp_txt table related to the complaint
         and replicates it in the wo_h_txt table for the new works order  --%>
    <%-- This only happens if the works order is set to copy the complaint text --%>
    <%-- Create a sequence number counter --%>
    <% int sequenceCount = 1; %>
    <if:IfTrue cond='<%= comp_text_flag.equals("Y") && comp_text_to_wo.equals("Y") %>'>
    
      <%-- delete the works order txt --%>
      <%-- We know that this will always be a new works order so there is no
           need to delete the works order txt --%>
      <%-- DO NOTHING --%>
    
      <%
        ArrayList comp_text           = new ArrayList();
        ArrayList comp_username       = new ArrayList();
        ArrayList comp_doa            = new ArrayList();
        ArrayList comp_time_entered_h = new ArrayList();
        ArrayList comp_time_entered_m = new ArrayList();
        int index    = 1;
        String value = "";
      %>
      <sql:query>
        SELECT seq, 
               txt, 
               username,
               doa, 
               time_entered_h, 
               time_entered_m
          FROM comp_text
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
      ORDER BY seq
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="wo_seq" />
        <% index = Integer.parseInt((String)pageContext.getAttribute("wo_seq")); %>
    
        <sql:getColumn position="2" to="txt" />
        <% value = ((String)pageContext.getAttribute("txt")).trim(); %>
        <% comp_text.add(value); %>
    
        <sql:getColumn position="3" to="username" />
        <% value = ((String)pageContext.getAttribute("username")).trim(); %>
        <% comp_username.add(value); %>
    
        <sql:getDate position="4" to="doa" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <% value = ((String)pageContext.getAttribute("doa")).trim(); %>
        <% comp_doa.add(value); %>
    
        <sql:getColumn position="5" to="time_entered_h" />
        <sql:wasNull>
          <% value = ""; %>
        </sql:wasNull>
        <sql:wasNotNull>
          <% value = ((String)pageContext.getAttribute("time_entered_h")).trim(); %>
        </sql:wasNotNull>
        <% comp_time_entered_h.add(value); %>
    
        <sql:getColumn position="6" to="time_entered_m" />
        <sql:wasNull>
          <% value = ""; %>
        </sql:wasNull>
        <sql:wasNotNull>
          <% value = ((String)pageContext.getAttribute("time_entered_m")).trim(); %>
        </sql:wasNotNull>
        <% comp_time_entered_m.add(value); %>
      </sql:resultSet>
    
      <%
        String text_line = "";
        int i=0;
        for(i=0; i < comp_text.size(); i++) {
          text_line = DbUtils.cleanString((String) comp_text.get(i));
      %>
        <sql:query>
          INSERT INTO wo_h_txt (
            wo_ref,
            wo_suffix,
            seq,
            username,
            doa,
            time_entered_h,
            time_entered_m,
            txt
          ) VALUES (
            '<%= wo_ref %>',
            '<%= recordBean.getWo_suffix()%>',
            '<%= i + 1 %>',
            '<%= DbUtils.cleanString((String) comp_username.get(i)) %>',
            '<%= DbUtils.cleanString((String) comp_doa.get(i)) %>',
            '<%= DbUtils.cleanString((String) comp_time_entered_h.get(i)) %>',
            '<%= DbUtils.cleanString((String) comp_time_entered_m.get(i)) %>',
            '<%= text_line %>'
          )
        </sql:query>
        <sql:execute />
      <%
        }
      %>
  
      <%-- Set the sequence number to the new sequence number --%>
      <% sequenceCount = i+1; %>
    </if:IfTrue>
  
    <%-- Need to check for new text in the compSampDetailsBean or
         the textBean, depending on whether we are coming from the
         inspection list or the SchedOrComp route --%>
    <%-- This only happens if the works order is set to copy the complaint text --%>
    <%-- If it is set to be seperate from the complaint then the text will be got from woDetailsBean --%>
    <% String text_flag  = "Y"; %>
    <% String tempTextIn = ""; %>
    <if:IfTrue cond='<%= comp_text_to_wo.equals("Y") %>'>
      <%-- There would be no action flag set if coming from the SchedOrComp route --%>
      <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("") %>'>
        <if:IfTrue cond='<%= textBean.getText() == null || textBean.getText().equals("") %>' >
          <% text_flag = "N"; %>
        </if:IfTrue>
        <if:IfTrue cond='<%= text_flag.equals("Y") %>'>
          <%-- If new complaint is going to be linked to a works order, and it is a --%>
          <%-- Hways statutory item then get the text from woDetails --%>
          <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") && recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service()) %>' >
            <% tempTextIn = woDetailsBean.getComp_text(); %>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! (recordBean.getAction_flag().equals("W") && recordBean.getInsp_item_flag().equals("Y") && recordBean.getService_c().equals(recordBean.getHway_service())) %>' >
            <% tempTextIn = textBean.getText(); %>
          </if:IfTrue>
        </if:IfTrue>
      </if:IfTrue>
      <%-- The action flag would be 'I' if coming from the compSampDetails route --%>
      <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("I") %>'>
        <if:IfTrue cond='<%= compSampDetailsBean.getText() == null || compSampDetailsBean.getText().equals("") %>' >
          <% text_flag = "N"; %>
        </if:IfTrue>
        <if:IfTrue cond='<%= text_flag.equals("Y") %>'>
          <% tempTextIn = compSampDetailsBean.getText(); %>
        </if:IfTrue>
      </if:IfTrue>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! comp_text_to_wo.equals("Y") %>'>
      <if:IfTrue cond='<%= woDetailsBean.getText() == null || woDetailsBean.getText().equals("") %>' >
        <% text_flag = "N"; %>
      </if:IfTrue>
      <if:IfTrue cond='<%= text_flag.equals("Y") %>'>
        <% tempTextIn = woDetailsBean.getText(); %>
      </if:IfTrue>
    </if:IfTrue>
    
    <%-- just put the works order text into the works order --%>
    <%-- Is there any text to add --%>
    <if:IfTrue cond='<%= text_flag.equals("Y") %>' >
      <%-- get rid of newline and carriage return chars --%>
      <%
        tempTextIn = tempTextIn.replace('\n',' ');
        tempTextIn = tempTextIn.replace('\r',' ');
      %>
    
      <%-- The text should be split into 56 char lines, and there should be a --%>
      <%-- single record for each line. --%>
      <%
        String allText = tempTextIn.trim();
        String line;
        int lineIndex;
        boolean flag = true;
        int seq = sequenceCount;
        do {
          if (allText.length() <= 56) {
            line = allText;
            flag = false;
          } else {
            lineIndex = allText.lastIndexOf(" ", 56);
            // Space not found so use the whole 56
            if (lineIndex == -1) {
              lineIndex = 56;
            } else {
              lineIndex = lineIndex + 1;
            }
            line = allText.substring(0,lineIndex);
            allText = allText.substring(lineIndex);
          }
      %> 
          <sql:query>
            insert into wo_h_txt (
              wo_ref,
              wo_suffix,
              seq,
              username,
              doa,
              time_entered_h,
              time_entered_m,
              txt
            ) values (
              '<%= wo_ref %>',
              '<%= recordBean.getWo_suffix() %>',
              '<%= seq %>',
              '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
              '<%= date %>',
              '<%= time_h %>',
              '<%= time_m %>',
              '<%= DbUtils.cleanString(line) %>'
            )
          </sql:query>
          <sql:execute />
      <%
          seq = seq + 1;
        } while (flag == true);
      %>
    </if:IfTrue>
    
    <%-- If either text flag is set to Y, update the wo_h text flag to 'Y' --%>
    <if:IfTrue cond='<%= comp_text_flag.equals("Y") || text_flag.equals("Y") %>'>
      <sql:query>
        UPDATE wo_h
        SET wo_text = 'Y'
        WHERE wo_ref  = <%= wo_ref %>
        AND wo_suffix = '<%= recordBean.getWo_suffix() %>'
      </sql:query>
      <sql:execute />
    </if:IfTrue>
    
    <%-- Get the diry_ref from the complaint diry record --%>
    <sql:query>
      select diry_ref
      from diry
      where source_flag = 'C'
      and   source_ref = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="comp_diry_ref" />
    </sql:resultSet>
    
    <%-- get the works order diry ref --%>
    <%-- get the next diry.diry_ref from s_no table --%>
    <sql:query>
      select serial_no
      from s_no
      where sn_func = 'diry'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="works_diry_ref" />
    </sql:resultSet>
    <% int works_diry_ref = Integer.parseInt((String)pageContext.getAttribute("works_diry_ref")); %>
  
    <%-- update the s_no table with the next diry.diry_ref --%>
    <sql:query>
      update s_no
      set serial_no = <%= works_diry_ref %> + 1
      where sn_func = 'diry'
    </sql:query>
    <sql:execute />
    
    <%-- Insert a new diry record for the works order --%>
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
        dest_ref,
        dest_date,
        dest_time_h,
        dest_time_m,
        dest_user
      ) values (
        '<%= works_diry_ref %>',
        '<%= ((String)pageContext.getAttribute("comp_diry_ref")).trim() %>',
        'W',
        '<%= wo_key %>',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        '<%= recordBean.getSite_ref() %>',
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getWo_contract_ref() %>',
        null,
        null,
        null,
        '<%= recordBean.getWo_due_date() %>',
        '<%= recordBean.getPa_area() %>',
        'N',
        null,
        null,
        null,
        null,
        null,
        null
      )
    </sql:query>
    <sql:execute /> 
  
    <%-- Update the wo_h table with the works_diry_ref --%>
    <sql:query>
      update wo_h
      set action_ref = '<%= works_diry_ref %>'
      where wo_key = '<%= wo_key %>'
    </sql:query>
    <sql:execute />
    
    <%-- Update the comp table with the wo_ref --%>
    <sql:query>
      update comp
      set dest_ref = '<%= wo_ref %>',
        action_flag = 'W',
        dest_suffix = '<%= recordBean.getWo_suffix() %>'
      where complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:execute />
    
    <%-- Update the complaint diry records next_record and dest_ref fields with the --%>
    <%-- works order records info. This completes the complaint record. --%>
    
    <%-- The complaint diry update --%>
    <sql:query>
      update diry
      set next_record = '<%= works_diry_ref %>',
        dest_ref = '<%= wo_key %>',
        action_flag = 'W',
        dest_flag = 'W',
        dest_date = '<%= date %>',
        dest_time_h = '<%= time_h %>',
        dest_time_m = '<%= time_m %>',
        dest_user = '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>'
      where diry_ref = '<%= ((String)pageContext.getAttribute("comp_diry_ref")).trim() %>'
    </sql:query>
    <sql:execute />

    <%-- delete any occurance of the complaint from the inspection --%>
    <%-- list table, as it has been closed. --%>
    <sql:query>
      delete from insp_list
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:execute/>
  
    <%-- we do want printing so make sure it knows we are a works order, --%>
    <%-- i.e. set the recordBean Wo_key --%>
    <% recordBean.setWo_key(Integer.toString(wo_key)); %>
  </sql:statement>
  <sql:closeConnection conn="con1"/>
  
</sess:equalsAttribute>
