<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.defaultAdditionalBean, com.vsb.recordBean" %>
<%@ page import="com.vsb.helperBean, com.vsb.surveyGradingBean, com.vsb.surveyAddDefaultBean" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*, java.math.BigDecimal" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="defaultAdditionalBean" scope="session" class="com.vsb.defaultAdditionalBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="surveyGradingBean" scope="session" class="com.vsb.surveyGradingBean" />
<jsp:useBean id="surveyAddDefaultBean" scope="session" class="com.vsb.surveyAddDefaultBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="defaultAdditional" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

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

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="defaultAdditional" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="defaultAdditionalBean" property="all" value="clear" />
    <jsp:setProperty name="defaultAdditionalBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="def_volume" value='<%= defaultAdditionalBean.getDef_volume() %>' />
    <jsp:setProperty name="recordBean" property="points" value='<%= defaultAdditionalBean.getPoints() %>' />
    <jsp:setProperty name="recordBean" property="value" value='<%= defaultAdditionalBean.getValue() %>' />

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="defaultAdditionalBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="defaultDate" >
  <jsp:setProperty name="defaultAdditionalBean" property="action" value="" />
  <jsp:setProperty name="defaultAdditionalBean" property="all" value="clear" />
  <jsp:setProperty name="defaultAdditionalBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- set up varaible outside sql section so can be used later --%>
<% double tot_defi_volume = 0.00; %>
<% String check_vol = "N"; %>

<%-- Check to see if we should show the VIEW or go to the next SCRIPT, --%>
<%-- but only the first time through the SCRIPT. --%>
<%-- Also get/calculate the volume, points and value. --%>
<sess:equalsAttribute name="input" match="defaultAdditional" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("defaultDate") %>' >
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <% recordBean.setShow_view("false"); %>
      <%-- check to see what allowed to edit --%>
      <sql:query>
        select prompt_for_points, prompt_for_value
        from defa
        where item_type = '<%= recordBean.getItem_type() %>'
        and   notice_rep_no = '<%= recordBean.getNotice_no() %>'
        and   default_algorithm = '<%= recordBean.getAlgorithm() %>'
       </sql:query>
      <sql:resultSet id="rset">
         <sql:getColumn position="1" to="edit_points" />
         <sql:wasNotNull>
           <% recordBean.setEdit_points((String) pageContext.getAttribute("edit_points")); %>
         </sql:wasNotNull>
         <sql:wasNull>
           <% recordBean.setEdit_points("Y"); %>
         </sql:wasNull>

         <sql:getColumn position="2" to="edit_value" />
         <sql:wasNotNull>
           <% recordBean.setEdit_value((String) pageContext.getAttribute("edit_value")); %>
         </sql:wasNotNull>
         <sql:wasNull>
           <% recordBean.setEdit_value("Y"); %>
         </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <%
          recordBean.setEdit_points("Y");
          recordBean.setEdit_value("Y");
        %>
      </sql:wasEmpty>

      <%-- Only check volumes if the DEF_CHECK_WHOLE_VOL system key is set to 'Y' --%>
      <sql:query>
        select c_field
        from keys
        where keyname = 'DEF_CHECK_WHOLE_VOL'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="check_vol" />
        <sql:wasNull>
          <% pageContext.setAttribute("check_vol", "N"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("check_vol", "N"); %>
      </sql:wasEmpty>
      <% check_vol = ((String)pageContext.getAttribute("check_vol")).trim(); %>

      <%-- get the volume --%>
      <%-- If the complaint comming from is not linked to a default then we are going to create --%>
      <%-- a new default so need the default keys volume. --%>
      <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("D") %>' >
        <sql:query>
          select n_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'DEFAULT_VOLUME'
         </sql:query>
         <sql:resultSet id="rset">
           <sql:getColumn position="1" to="def_volume" />
           <% recordBean.setDef_volume((String) pageContext.getAttribute("def_volume")); %>
         </sql:resultSet>
      </if:IfTrue>
      <%-- If the complaint comming from is linked to a default then we are going to create --%>
      <%-- a re-default so need the default's defi volume. --%>
      <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("D") %>' >
        <% recordBean.setDef_volume(recordBean.getVolume()); %>
      </if:IfTrue>

      <%-- Only try to total up the volumes already defaulted for the item, and still active, --%>
      <%-- if item has not been, defaulted --%>
      <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("D") %>' >
         <sql:query>
          select defi.volume
          from defi, defh
          where defi.item_ref = '<%= recordBean.getItem_ref() %>'
          and   defh.default_status = 'Y'
          and   defh.site_ref = '<%= recordBean.getSite_ref() %>'
          and   defh.cust_def_no = defi.default_no
         </sql:query>
         <sql:resultSet id="rset">
           <sql:getColumn position="1" to="defi_volume" />
           <sql:wasNull>
             <% pageContext.setAttribute("defi_volume", "0"); %>
           </sql:wasNull>
           <if:IfTrue cond='<%= ((String)pageContext.getAttribute("defi_volume")).trim().equals("") %>'>
             <% pageContext.setAttribute("defi_volume","0"); %>
           </if:IfTrue>
          <% tot_defi_volume = tot_defi_volume + (new Double((String) pageContext.getAttribute("defi_volume"))).doubleValue(); %>
         </sql:resultSet>
      </if:IfTrue>

      <%-- retrieve the task.unit_of_meas and the ta_r.task_rate --%>
      <sql:query>
        select task_ref
        from item
        where item_ref = '<%= recordBean.getItem_ref() %>'
        and   contract_ref = '<%= recordBean.getContract_ref() %>'
       </sql:query>
      <sql:resultSet id="rset">
         <sql:getColumn position="1" to="task_ref" />
      </sql:resultSet>

      <sql:query>
        select unit_of_meas
        from task
        where task_ref = '<%= ((String)pageContext.getAttribute("task_ref")).trim() %>'
       </sql:query>
      <sql:resultSet id="rset">
         <sql:getColumn position="1" to="unit_of_meas" />
        <sql:wasNull>
           <% pageContext.setAttribute("unit_of_meas","1.0"); %>
         </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("unit_of_meas","1.0"); %>
      </sql:wasEmpty>

      <%-- The cycle number is retrieved to get the task_rate. If there is no cycle number --%>
      <%-- then the task rate will be set to 1.0. --%>
      <sql:query>
        select cont_cycle_no
        from c_da
        where contract_ref = '<%= recordBean.getContract_ref() %>'
        and   period_start <= '<%= date %>'
        and   period_finish >= '<%= date %>'
       </sql:query>
      <sql:resultSet id="rset">
         <sql:getColumn position="1" to="cont_cycle_no" />
         <sql:wasNull>
           <% pageContext.setAttribute("cont_cycle_no",""); %>
         </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("cont_cycle_no",""); %>
      </sql:wasEmpty>

      <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("cont_cycle_no")).trim().equals("") %>' >
        <sql:query>
          select task_rate, start_date
          from ta_r
          where task_ref = '<%= ((String)pageContext.getAttribute("task_ref")).trim() %>'
          and   contract_ref = '<%= recordBean.getContract_ref() %>'
          and   cont_cycle_no = '<%= ((String)pageContext.getAttribute("cont_cycle_no")).trim() %>'
          and   start_date <= '<%= date %>'
          order by start_date asc
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="task_rate" />
          <sql:wasNull>
            <% pageContext.setAttribute("task_rate","1.0"); %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% pageContext.setAttribute("task_rate","1.0"); %>
        </sql:wasEmpty>
      </if:IfTrue>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("cont_cycle_no")).trim().equals("") %>' >
        <% pageContext.setAttribute("task_rate","1.0"); %>
      </if:IfTrue>

      <% String an_val_def_alg = "N"; %>
      <% String start_date = ""; %>
      <% String contract_value = "0.00"; %>
      <%-- Check to see if we are using the Wandsworth value calculation or not. --%>
      <%-- Only using the Wandsworth value on a re-default and for prority flags A and B --%>
      <%-- The priority flag check is done in the helperBean.getValue() method. --%>
      <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("D") %>' >
        <sql:query>
          select c_field
          from keys
          where keyname = 'AN_VAL_DEF_ALG'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="an_val_def_alg" />
          <sql:wasNull>
            <% pageContext.setAttribute("an_val_def_alg", "N"); %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% pageContext.setAttribute("an_val_def_alg", "N"); %>
        </sql:wasEmpty>
        <% an_val_def_alg = ((String)pageContext.getAttribute("an_val_def_alg")).trim(); %>

        <%-- Get the required values if we are using the wandsworth method --%>
        <if:IfTrue cond='<%= an_val_def_alg.equals("Y") %>' >
          <%-- get the start_date of the default --%>
          <sql:query>
            select start_date 
            from defh
            where cust_def_no = <%= recordBean.getDefault_no() %>
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getDate position="1" to="start_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
            <% start_date = ((String)pageContext.getAttribute("start_date")).trim(); %>
          </sql:resultSet>
       
          <%-- get the contract value --%>
          <%-- if the defaults start date is today or cannot find the value in the site_mark_log --%>
          <sql:query>
            select site_value 
            from site_mark
            where site_ref = '<%= recordBean.getSite_ref() %>'
            and   contract_ref = '<%= recordBean.getContract_ref() %>'
            and   lookup_code = 'CONVAL'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="site_value" />
            <% contract_value = ((String)pageContext.getAttribute("site_value")).trim(); %>
          </sql:resultSet>
          
          <%-- if the defaults start date is NOT today --%>
          <if:IfTrue cond='<%= ! start_date.equals(date) %>' >
            <sql:query>
              select site_value, log_seq 
              from site_mark_log
              where site_ref = '<%= recordBean.getSite_ref() %>'
              and   contract_ref = '<%= recordBean.getContract_ref() %>'
              and   lookup_code = 'CONVAL'
              and   log_date <= '<%= start_date %>'
              order by log_seq asc  
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="site_value" />
              <% contract_value = ((String)pageContext.getAttribute("site_value")).trim(); %>
            </sql:resultSet>
          </if:IfTrue>

        </if:IfTrue>
      </if:IfTrue>

      <%-- retrieve the defp3 record via the defp1.calc_id --%>
      <sql:query>
        select std_cv, std_pnts, std_val, fr_v_flag, fr_p_flag,
          d_u_o_m_flag, d_ta_r_flag, multip_v_flag, multip_p_flag, si_i_vol,
          fr_v, fr_p, d_u_o_m, D_ta_r, rounding, multip_v, multip_p
        from defp3
        where calc_id = (
          select calc_id
          from defp1
          where algorithm = '<%= recordBean.getAlgorithm() %>'
          and   default_level = '<%= recordBean.getDefault_level() %>'
          and   item_type = '<%= recordBean.getItem_type() %>'
          and   contract_ref = '<%= recordBean.getContract_ref() %>'
          and   priority = '<%= recordBean.getPriority() %>'
        )
       </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="defp3_std_cv" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_std_cv","N"); %>
        </sql:wasNull>

        <sql:getColumn position="2" to="defp3_std_pnts" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_std_pnts","N"); %>
        </sql:wasNull>

        <sql:getColumn position="3" to="defp3_std_val" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_std_val","N"); %>
        </sql:wasNull>

        <sql:getColumn position="4" to="defp3_fr_v_flag" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_fr_v_flag","N"); %>
        </sql:wasNull>

        <sql:getColumn position="5" to="defp3_fr_p_flag" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_fr_p_flag","N"); %>
        </sql:wasNull>

        <sql:getColumn position="6" to="defp3_d_u_o_m_flag" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_d_u_o_m_flag","N"); %>
        </sql:wasNull>

        <sql:getColumn position="7" to="defp3_d_ta_r_flag" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_d_ta_r_flag","N"); %>
        </sql:wasNull>

        <sql:getColumn position="8" to="defp3_multip_v_flag" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_multip_v_flag","N"); %>
        </sql:wasNull>

        <sql:getColumn position="9" to="defp3_multip_p_flag" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_multip_p_flag","N"); %>
        </sql:wasNull>

        <sql:getColumn position="10" to="defp3_si_i_vol" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_si_i_vol","N"); %>
        </sql:wasNull>

        <sql:getColumn position="11" to="defp3_fr_v" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_fr_v","0.00"); %>
        </sql:wasNull>

        <sql:getColumn position="12" to="defp3_fr_p" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_fr_p","0.00"); %>
        </sql:wasNull>

        <sql:getColumn position="13" to="defp3_d_u_o_m" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_d_u_o_m","1.00"); %>
        </sql:wasNull>

        <sql:getColumn position="14" to="defp3_d_ta_r" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_d_ta_r","1.00"); %>
        </sql:wasNull>

        <sql:getColumn position="15" to="defp3_rounding" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_rounding","N"); %>
        </sql:wasNull>

        <sql:getColumn position="16" to="defp3_multip_v" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_multip_v","1.00"); %>
        </sql:wasNull>

        <sql:getColumn position="17" to="defp3_multip_p" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp3_multip_p","1.00"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <%
          pageContext.setAttribute("defp3_std_cv","N");
          pageContext.setAttribute("defp3_std_pnts","N");
          pageContext.setAttribute("defp3_std_val","N");
          pageContext.setAttribute("defp3_fr_v_flag","N");
          pageContext.setAttribute("defp3_fr_p_flag","N");
          pageContext.setAttribute("defp3_d_u_o_m_flag","N");
          pageContext.setAttribute("defp3_d_ta_r_flag","N");
          pageContext.setAttribute("defp3_multip_v_flag","N");
          pageContext.setAttribute("defp3_multip_p_flag","N");
          pageContext.setAttribute("defp3_si_i_vol","N");
          pageContext.setAttribute("defp3_fr_v","0.00");
          pageContext.setAttribute("defp3_fr_p","0.00");
          pageContext.setAttribute("defp3_d_u_o_m","1.00");
          pageContext.setAttribute("defp3_d_ta_r","1.00");
          pageContext.setAttribute("defp3_rounding","N");
          pageContext.setAttribute("defp3_multip_v","1.00");
          pageContext.setAttribute("defp3_multip_p","1.00");
        %>
      </sql:wasEmpty>

      <%-- calculate points --%>
      <%
        double points = helperBean.getPoints( recordBean.getDef_volume(),
                                              recordBean.getTotal_volume(),
                                              ((String)pageContext.getAttribute("task_rate")).trim(),
                                              ((String)pageContext.getAttribute("defp3_std_pnts")).trim(),
                                              ((String)pageContext.getAttribute("defp3_fr_p_flag")).trim(),
                                              ((String)pageContext.getAttribute("defp3_d_u_o_m_flag")).trim(),
                                              ((String)pageContext.getAttribute("defp3_multip_p_flag")).trim(),
                                              ((String)pageContext.getAttribute("defp3_si_i_vol")).trim(),
                                              ((String)pageContext.getAttribute("defp3_fr_p")).trim(),
                                              ((String)pageContext.getAttribute("defp3_d_u_o_m")).trim(),
                                              ((String)pageContext.getAttribute("defp3_rounding")).trim(),
                                              ((String)pageContext.getAttribute("defp3_multip_p")).trim() );

        recordBean.setPoints(String.valueOf(points));
      %>

      <%-- calculate value --%>
      <%
        double value = helperBean.getValue( an_val_def_alg,
                                            application.getInitParameter("db_date_fmt"),
                                            start_date,
                                            recordBean.getPriority(),
                                            contract_value,
                                            recordBean.getDef_volume(),
                                            recordBean.getTotal_volume(),
                                            ((String)pageContext.getAttribute("task_rate")).trim(),
                                            ((String)pageContext.getAttribute("unit_of_meas")).trim(),
                                            ((String)pageContext.getAttribute("defp3_std_cv")).trim(),
                                            ((String)pageContext.getAttribute("defp3_std_val")).trim(),
                                            ((String)pageContext.getAttribute("defp3_fr_v_flag")).trim(),
                                            ((String)pageContext.getAttribute("defp3_d_u_o_m_flag")).trim(),
                                            ((String)pageContext.getAttribute("defp3_d_ta_r_flag")).trim(),
                                            ((String)pageContext.getAttribute("defp3_multip_v_flag")).trim(),
                                            ((String)pageContext.getAttribute("defp3_si_i_vol")).trim(),
                                            ((String)pageContext.getAttribute("defp3_fr_v")).trim(),
                                            ((String)pageContext.getAttribute("defp3_d_u_o_m")).trim(),
                                            ((String)pageContext.getAttribute("defp3_d_ta_r")).trim(),
                                            ((String)pageContext.getAttribute("defp3_rounding")).trim(),
                                            ((String)pageContext.getAttribute("defp3_multip_v")).trim() );

        recordBean.setValue(String.valueOf(value));
      %>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- The volume is only allowed to be edited if this is a default, and not a re-deafult --%>
    <% recordBean.setEdit_volume("N"); %>
    <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("D") %>' >
      <% recordBean.setEdit_volume("Y"); %>
      <% recordBean.setShow_view("true"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= recordBean.getEdit_points().equals("Y") %>' >
      <% recordBean.setShow_view("true"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= recordBean.getEdit_value().equals("Y") %>' >
      <% recordBean.setShow_view("true"); %>
    </if:IfTrue>

    <%-- Check to make sure that the value is not too big --%>
    <if:IfTrue cond='<%= (new Double(recordBean.getValue())).doubleValue() > 1000000.00 %>' >
      <% String text_out = ""; %>
      <% text_out = "The value of " + (new Double(recordBean.getValue())).doubleValue() + " is too large."; %>
      <jsp:setProperty name="defaultAdditionalBean" property="error"
        value='<%= text_out %>' />
      <jsp:forward page="defaultAdditionalView.jsp" />
    </if:IfTrue>

    <%-- Only check volumes if item has not been defaulted and the system key is set to 'Y' --%>
    <if:IfTrue cond='<%= !recordBean.getComp_action_flag().equals("D") && check_vol.equals("Y") %>' >
      <% String text_out = ""; %>
      <if:IfTrue cond='<%= (tot_defi_volume + (new Double(recordBean.getDef_volume())).doubleValue()) > (new Double(recordBean.getTotal_volume())).doubleValue() %>' >
        <%-- Rounds up the double value to 2 decimal places --%>
        <%
         double volumeCheck = (new Double(recordBean.getTotal_volume()).doubleValue()) - tot_defi_volume;
         BigDecimal volumeRoundUp = new BigDecimal(volumeCheck).setScale(2, BigDecimal.ROUND_HALF_UP); 
         text_out = "You cannot " + application.getInitParameter("def_name_verb").toLowerCase() + " more than the allowed volume of " + volumeRoundUp.toString();
        %>      
        <jsp:setProperty name="defaultAdditionalBean" property="error"
          value='<%= text_out %>' />
        <jsp:forward page="defaultAdditionalView.jsp" />
      </if:IfTrue>

      <if:IfTrue cond='<%= (new Double(recordBean.getDef_volume())).doubleValue() > (new Double(recordBean.getTotal_volume())).doubleValue() %>' >
        <% text_out = "You cannot " + application.getInitParameter("def_name_verb").toLowerCase() + " more than the allowed volume of " + (new Double(recordBean.getTotal_volume())).doubleValue(); %>
        <jsp:setProperty name="defaultAdditionalBean" property="error"
          value='<%= text_out %>' />
        <jsp:forward page="defaultAdditionalView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <if:IfTrue cond='<%= recordBean.getShow_view().equals("false") %>' >
      <%-- As this is a BV199 auto default there is no complaint as yet so need to add a complaint --%>
      <%-- first and then add a default --%>
      <if:IfTrue cond='<%= recordBean.getBv_default_flag().equals("Y") %>' >
        <%-- add complaint --%>
        <sess:setAttribute name="form">addComplaintFunc</sess:setAttribute>
        <c:import url="addComplaintFunc.jsp" var="webPage" />
        <% helperBean.throwException("addComplaintFunc", (String)pageContext.getAttribute("webPage")); %>
  
        <%-- add default --%>
        <sess:setAttribute name="form">addDefaultFunc</sess:setAttribute>
        <c:import url="addDefaultFunc.jsp" var="webPage" />
        <% helperBean.throwException("addDefaultFunc", (String)pageContext.getAttribute("webPage")); %>
  
        <%-- clear the default just made if required --%>
        <if:IfTrue cond='<%= recordBean.getClearDefault().equals("Y") %>' >
          <sess:setAttribute name="form">clearDefaultFunc</sess:setAttribute>
          <c:import url="clearDefaultFunc.jsp" var="webPage" />
          <% helperBean.throwException("clearDefaultFunc", (String)pageContext.getAttribute("webPage")); %>
        </if:IfTrue>
  
        <%-- add text --%>
        <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
        <c:import url="addTextFunc.jsp" var="webPage" />
        <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>
  
        <%-- run the veolia link if required --%>
        <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
        <c:import url="veoliaLinkFunc.jsp" var="webPage" />
        <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>
  
        <%-- We are creating a BV199 default so head back to the surveyAddDefault form --%>
        <%-- Set the flag in the surveyAddGrading been to reflect that this default is compelted --%>
        <% surveyGradingBean.setFlag( surveyAddDefaultBean.getBv_name(), "A" ); %>
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">defaultAdditional</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">surveyAddDefault</sess:setAttribute>
        <c:redirect url="surveyAddDefaultScript.jsp" />
      </if:IfTrue>

      <%-- the complaint has already been defaulted so we are re-defaulting it --%>
      <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("D") %>' >
        <%-- nothing to do in this form so move to the next --%>
        <%-- Indicate that the input section has been passed through --%>
        <sess:setAttribute name="input">defaultAdditional</sess:setAttribute>

        <%-- re-default --%>
        <sess:setAttribute name="form">reDefaultFunc</sess:setAttribute>
        <c:import url="reDefaultFunc.jsp" var="webPage" />
        <% helperBean.throwException("reDefaultFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- add text --%>
        <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
        <c:import url="addTextFunc.jsp" var="webPage" />
        <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- run the veolia link if required --%>
        <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
        <c:import url="veoliaLinkFunc.jsp" var="webPage" />
        <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">defaultAdditional</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">updateStatus</sess:setAttribute>
        <c:redirect url="updateStatusScript.jsp" />
      </if:IfTrue>

      <%-- There is no complaint as yet so need to add a complaint first and then add a default --%>
      <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("") %>' >
        <%-- nothing to do in this form so move to the next --%>
        <%-- Indicate that the input section has been passed through --%>
        <sess:setAttribute name="input">defaultAdditional</sess:setAttribute>

        <%-- add complaint --%>
        <sess:setAttribute name="form">addComplaintFunc</sess:setAttribute>
        <c:import url="addComplaintFunc.jsp" var="webPage" />
        <% helperBean.throwException("addComplaintFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- Add an enforcement complaint if required --%>
        <if:IfTrue cond='<%= recordBean.getEnforce_flag().equals("Y") %>' >
          <sess:setAttribute name="form">addEnforceFunc</sess:setAttribute>
          <c:import url="addEnforceFunc.jsp" var="webPage" />
          <% helperBean.throwException("addEnforceFunc", (String)pageContext.getAttribute("webPage")); %>

          <%-- This is NOT a standalone enforcement complaint, so we need to add the --%>
          <%-- complaint number to the record bean for the suspect to use and then set it back again after --%>
          <% recordBean.setComplaint_no( recordBean.getEnforce_complaint_no() ); %>

          <%-- Add the suspect if required --%>
          <if:IfTrue cond='<%= recordBean.getSuspect_flag().equals("Y") %>' >
            <sess:setAttribute name="form">addUpdateSuspectFunc</sess:setAttribute>
            <c:import url="addUpdateSuspectFunc.jsp" var="webPage" />
            <% helperBean.throwException("addUpdateSuspectFunc", (String)pageContext.getAttribute("webPage")); %>
          </if:IfTrue>

          <%-- Add the evidence if required --%>
          <if:IfTrue cond='<%= ! recordBean.getEvidence().equals("") %>'>
            <sess:setAttribute name="form">updateEvidenceFunc</sess:setAttribute>
            <c:import url="updateEvidenceFunc.jsp" var="webPage" />
            <% helperBean.throwException("updateEvidenceFunc", (String)pageContext.getAttribute("webPage")); %>
          </if:IfTrue>

          <% recordBean.setComplaint_no( recordBean.getComplaint_complaint_no() ); %>
        </if:IfTrue>

        <%-- add default --%>
        <sess:setAttribute name="form">addDefaultFunc</sess:setAttribute>
        <c:import url="addDefaultFunc.jsp" var="webPage" />
        <% helperBean.throwException("addDefaultFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- clear the default just made if required --%>
        <if:IfTrue cond='<%= recordBean.getClearDefault().equals("Y") %>' >
          <sess:setAttribute name="form">clearDefaultFunc</sess:setAttribute>
          <c:import url="clearDefaultFunc.jsp" var="webPage" />
          <% helperBean.throwException("clearDefaultFunc", (String)pageContext.getAttribute("webPage")); %>
        </if:IfTrue>

        <%-- add text --%>
        <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
        <c:import url="addTextFunc.jsp" var="webPage" />
        <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- run the veolia link if required --%>
        <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
        <c:import url="veoliaLinkFunc.jsp" var="webPage" />
        <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">defaultAdditional</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">updateStatus</sess:setAttribute>
        <c:redirect url="updateStatusScript.jsp" />
      </if:IfTrue>

      <%-- The complaint has not previously been defaulted so we need to add a new default --%>
      <%-- nothing to do in this form so move to the next --%>
      <%-- Indicate that the input section has been passed through --%>
      <sess:setAttribute name="input">defaultAdditional</sess:setAttribute>

      <%-- Add the additional stuff for graffiti and flyCapture Inspections --%>
      <%-- update flycapture --%>
      <if:IfTrue cond='<%= recordBean.getUser_triggered().equals("flyCapUpdate") %>' >
        <%-- Set the action flag to be 'H' for a Hold enquiry or 'N' for no further action --%>
        <app:equalsInitParameter name="fly_cap_h_or_n" match="H">
          <% recordBean.setAction_flag("H"); %>
        </app:equalsInitParameter>
        <app:equalsInitParameter name="fly_cap_h_or_n" match="N">
          <% recordBean.setAction_flag("N"); %>
        </app:equalsInitParameter>
    
        <%-- add/update Fly Capture Details details --%>
        <sess:setAttribute name="form">updateFlyCapFunc</sess:setAttribute>
        <c:import url="updateFlyCapFunc.jsp" var="webPage" />
        <% helperBean.throwException("updateFlyCapFunc", (String)pageContext.getAttribute("webPage")); %>
      </if:IfTrue>

      <%-- update graffiti --%>
      <if:IfTrue cond='<%= recordBean.getUser_triggered().equals("graffDetails") %>' >
        <%-- add graffiti details --%>
        <sess:setAttribute name="form">addDartGraffFunc</sess:setAttribute>
        <c:import url="addDartGraffFunc.jsp" var="webPage" />
        <% helperBean.throwException("addDartGraffFunc", (String)pageContext.getAttribute("webPage")); %>
      </if:IfTrue>

      <%-- add default --%>
      <sess:setAttribute name="form">addDefaultFunc</sess:setAttribute>
      <c:import url="addDefaultFunc.jsp" var="webPage" />
      <% helperBean.throwException("addDefaultFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- clear the default just made if required --%>
      <if:IfTrue cond='<%= recordBean.getClearDefault().equals("Y") %>' >
        <sess:setAttribute name="form">clearDefaultFunc</sess:setAttribute>
        <c:import url="clearDefaultFunc.jsp" var="webPage" />
        <% helperBean.throwException("clearDefaultFunc", (String)pageContext.getAttribute("webPage")); %>
      </if:IfTrue>

      <%-- add text --%>
      <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
      <c:import url="addTextFunc.jsp" var="webPage" />
      <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- run the veolia link if required --%>
      <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
      <c:import url="veoliaLinkFunc.jsp" var="webPage" />
      <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">defaultAdditional</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">updateStatus</sess:setAttribute>
      <c:redirect url="updateStatusScript.jsp" />
    </if:IfTrue>

  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="defaultAdditional" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= defaultAdditionalBean.getAction().equals("Finish") %>' >
    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
      <%-- Only check volumes if the DEF_CHECK_WHOLE_VOL system key is set to 'Y' --%>
      <sql:query>
        select c_field
        from keys
        where keyname = 'DEF_CHECK_WHOLE_VOL'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="check_vol" />
        <sql:wasNull>
          <% pageContext.setAttribute("check_vol", "N"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("check_vol", "N"); %>
      </sql:wasEmpty>
      <% check_vol = ((String)pageContext.getAttribute("check_vol")).trim(); %>
    
      <%-- Only try to total up the volumes already defaulted for the item, and still active, --%>
      <%-- if item has not been, defaulted --%>
      <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("D") && check_vol.equals("Y") %>' >
        <% tot_defi_volume = 0.00; %>
        <sql:query>
          select defi.volume
          from defi, defh
          where defi.item_ref = '<%= recordBean.getItem_ref() %>'
          and   defh.default_status = 'Y'
          and   defh.site_ref = '<%= recordBean.getSite_ref() %>'
          and   defh.cust_def_no = defi.default_no
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="defi_volume" />
          <sql:wasNull>
            <% pageContext.setAttribute("defi_volume","0"); %>
          </sql:wasNull>
          <if:IfTrue cond='<%= ((String)pageContext.getAttribute("defi_volume")).trim().equals("") %>'>
            <% pageContext.setAttribute("defi_volume","0"); %>
          </if:IfTrue>
          <% tot_defi_volume = tot_defi_volume + (new Double((String) pageContext.getAttribute("defi_volume"))).doubleValue(); %>
        </sql:resultSet>
      </if:IfTrue>
    </sql:statement>
    <sql:closeConnection conn="con1"/>

    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=defaultAdditionalBean.getDef_volume() == null || defaultAdditionalBean.getDef_volume().equals("") %>' >
      <jsp:setProperty name="defaultAdditionalBean" property="error"
        value="The volume must not be blank." />
      <jsp:forward page="defaultAdditionalView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= !helperBean.isStringDouble(defaultAdditionalBean.getDef_volume()) %>' >
      <jsp:setProperty name="defaultAdditionalBean" property="error"
        value="The volume must be a number." />
      <jsp:forward page="defaultAdditionalView.jsp" />
    </if:IfTrue>

    <%-- The volume must be greater than zero --%>
    <if:IfTrue cond='<%= (new Double(recordBean.getDef_volume())).doubleValue() <= 0.00 %>' >
      <jsp:setProperty name="defaultAdditionalBean" property="error"
        value="The volume must be greater than zero." />
      <jsp:forward page="defaultAdditionalView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%=defaultAdditionalBean.getPoints() == null || defaultAdditionalBean.getPoints().equals("") %>' >
      <jsp:setProperty name="defaultAdditionalBean" property="error"
        value="The points must not be blank." />
      <jsp:forward page="defaultAdditionalView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= !helperBean.isStringDouble(defaultAdditionalBean.getPoints()) %>' >
      <jsp:setProperty name="defaultAdditionalBean" property="error"
        value="The points must be a number." />
      <jsp:forward page="defaultAdditionalView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%=defaultAdditionalBean.getValue() == null || defaultAdditionalBean.getValue().equals("") %>' >
      <jsp:setProperty name="defaultAdditionalBean" property="error"
        value="The value must not be blank." />
      <jsp:forward page="defaultAdditionalView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= !helperBean.isStringDouble(defaultAdditionalBean.getValue()) %>' >
      <jsp:setProperty name="defaultAdditionalBean" property="error"
        value="The value must be a number." />
      <jsp:forward page="defaultAdditionalView.jsp" />
    </if:IfTrue>

    <%-- Only check volumes if item has not been defaulted --%>
    <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("D") && check_vol.equals("Y") %>' >
      <% String text_out = ""; %>
      <if:IfTrue cond='<%= (tot_defi_volume + (new Double(recordBean.getDef_volume())).doubleValue()) > (new Double(recordBean.getTotal_volume())).doubleValue() %>' >
        <%-- Rounds up the double value to 2 decimal places --%>
        <%
         double volumeCheck = (new Double(recordBean.getTotal_volume()).doubleValue()) - tot_defi_volume;
         BigDecimal volumeRoundUp = new BigDecimal(volumeCheck).setScale(2, BigDecimal.ROUND_HALF_UP); 
         text_out = "You cannot " + application.getInitParameter("def_name_verb").toLowerCase() + " more than the allowed volume of " + volumeRoundUp.toString();
        %>        
        <jsp:setProperty name="defaultAdditionalBean" property="error"
          value='<%= text_out %>' />
        <jsp:forward page="defaultAdditionalView.jsp" />
      </if:IfTrue>

      <if:IfTrue cond='<%= (new Double(recordBean.getDef_volume())).doubleValue() > (new Double(recordBean.getTotal_volume())).doubleValue() %>' >
        <% text_out = "You cannot " + application.getInitParameter("def_name_verb").toLowerCase() + " more than the allowed volume of " + (new Double(recordBean.getTotal_volume())).doubleValue(); %>
        <jsp:setProperty name="defaultAdditionalBean" property="error"
          value='<%= text_out %>' />
        <jsp:forward page="defaultAdditionalView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- As this is a BV199 auto default there is no complaint as yet so need to add a complaint --%>
    <%-- first and then add a default --%>
    <if:IfTrue cond='<%= recordBean.getBv_default_flag().equals("Y") %>' >
      <%-- add complaint --%>
      <sess:setAttribute name="form">addComplaintFunc</sess:setAttribute>
      <c:import url="addComplaintFunc.jsp" var="webPage" />
      <% helperBean.throwException("addComplaintFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- add default --%>
      <sess:setAttribute name="form">addDefaultFunc</sess:setAttribute>
      <c:import url="addDefaultFunc.jsp" var="webPage" />
      <% helperBean.throwException("addDefaultFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- clear the default just made if required --%>
      <if:IfTrue cond='<%= recordBean.getClearDefault().equals("Y") %>' >
        <sess:setAttribute name="form">clearDefaultFunc</sess:setAttribute>
        <c:import url="clearDefaultFunc.jsp" var="webPage" />
        <% helperBean.throwException("clearDefaultFunc", (String)pageContext.getAttribute("webPage")); %>
      </if:IfTrue>

      <%-- add text --%>
      <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
      <c:import url="addTextFunc.jsp" var="webPage" />
      <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- run the veolia link if required --%>
      <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
      <c:import url="veoliaLinkFunc.jsp" var="webPage" />
      <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- We are creating a BV199 default so head back to the surveyAddDefault form --%>
      <%-- Set the flag in the surveyAddGrading been to reflect that this default is compelted --%>
      <% surveyGradingBean.setFlag( surveyAddDefaultBean.getBv_name(), "A" ); %>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">defaultAdditional</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">surveyAddDefault</sess:setAttribute>
      <c:redirect url="surveyAddDefaultScript.jsp" />
    </if:IfTrue>

    <%-- the complaint has already been defaulted so we are re-defaulting it --%>
    <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("D") %>' >
      <%-- re-default --%>
      <sess:setAttribute name="form">reDefaultFunc</sess:setAttribute>
      <c:import url="reDefaultFunc.jsp" var="webPage" />
      <% helperBean.throwException("reDefaultFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- add text --%>
      <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
      <c:import url="addTextFunc.jsp" var="webPage" />
      <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- run the veolia link if required --%>
      <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
      <c:import url="veoliaLinkFunc.jsp" var="webPage" />
      <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">defaultAdditional</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">updateStatus</sess:setAttribute>
      <c:redirect url="updateStatusScript.jsp" />
    </if:IfTrue>

    <%-- There is no complaint as yet so need to add a complaint first and then add a default --%>
    <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("") %>' >
      <%-- add complaint --%>
      <sess:setAttribute name="form">addComplaintFunc</sess:setAttribute>
      <c:import url="addComplaintFunc.jsp" var="webPage" />
      <% helperBean.throwException("addComplaintFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- Add an enforcement complaint if required --%>
      <if:IfTrue cond='<%= recordBean.getEnforce_flag().equals("Y") %>' >
        <sess:setAttribute name="form">addEnforceFunc</sess:setAttribute>
        <c:import url="addEnforceFunc.jsp" var="webPage" />
        <% helperBean.throwException("addEnforceFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- This is NOT a standalone enforcement complaint, so we need to add the --%>
        <%-- complaint number to the record bean for the suspect to use and then set it back again after --%>
        <% recordBean.setComplaint_no( recordBean.getEnforce_complaint_no() ); %>
      
        <%-- Add the suspect if required --%>
        <if:IfTrue cond='<%= recordBean.getSuspect_flag().equals("Y") %>' >
          <sess:setAttribute name="form">addUpdateSuspectFunc</sess:setAttribute>
          <c:import url="addUpdateSuspectFunc.jsp" var="webPage" />
          <% helperBean.throwException("addUpdateSuspectFunc", (String)pageContext.getAttribute("webPage")); %>
        </if:IfTrue>
       
        <%-- Add the evidence if required --%>
        <if:IfTrue cond='<%= ! recordBean.getEvidence().equals("") %>'>
          <sess:setAttribute name="form">updateEvidenceFunc</sess:setAttribute>
          <c:import url="updateEvidenceFunc.jsp" var="webPage" />
          <% helperBean.throwException("updateEvidenceFunc", (String)pageContext.getAttribute("webPage")); %>
        </if:IfTrue>
 
        <% recordBean.setComplaint_no( recordBean.getComplaint_complaint_no() ); %>
      </if:IfTrue>

      <%-- Add the additional stuff for graffiti and flyCapture Inspections --%>
      <%-- update flycapture --%>
      <if:IfTrue cond='<%= recordBean.getUser_triggered().equals("flyCapUpdate") %>' >
        <%-- Set the action flag to be 'H' for a Hold enquiry or 'N' for no further action --%>
        <app:equalsInitParameter name="fly_cap_h_or_n" match="H">
          <% recordBean.setAction_flag("H"); %>
        </app:equalsInitParameter>
        <app:equalsInitParameter name="fly_cap_h_or_n" match="N">
          <% recordBean.setAction_flag("N"); %>
        </app:equalsInitParameter>
    
        <%-- add/update Fly Capture Details details --%>
        <sess:setAttribute name="form">updateFlyCapFunc</sess:setAttribute>
        <c:import url="updateFlyCapFunc.jsp" var="webPage" />
        <% helperBean.throwException("updateFlyCapFunc", (String)pageContext.getAttribute("webPage")); %>
      </if:IfTrue>

      <%-- update graffiti --%>
      <if:IfTrue cond='<%= recordBean.getUser_triggered().equals("graffDetails") %>' >
        <%-- add graffiti details --%>
        <sess:setAttribute name="form">addDartGraffFunc</sess:setAttribute>
        <c:import url="addDartGraffFunc.jsp" var="webPage" />
        <% helperBean.throwException("addDartGraffFunc", (String)pageContext.getAttribute("webPage")); %>
      </if:IfTrue>

      <%-- add default --%>
      <sess:setAttribute name="form">addDefaultFunc</sess:setAttribute>
      <c:import url="addDefaultFunc.jsp" var="webPage" />
      <% helperBean.throwException("addDefaultFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- clear the default just made if required --%>
      <if:IfTrue cond='<%= recordBean.getClearDefault().equals("Y") %>' >
        <sess:setAttribute name="form">clearDefaultFunc</sess:setAttribute>
        <c:import url="clearDefaultFunc.jsp" var="webPage" />
        <% helperBean.throwException("clearDefaultFunc", (String)pageContext.getAttribute("webPage")); %>
      </if:IfTrue>

      <%-- add text --%>
      <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
      <c:import url="addTextFunc.jsp" var="webPage" />
      <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- run the veolia link if required --%>
      <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
      <c:import url="veoliaLinkFunc.jsp" var="webPage" />
      <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">defaultAdditional</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">updateStatus</sess:setAttribute>
      <c:redirect url="updateStatusScript.jsp" />
    </if:IfTrue>

    <%-- The complaint has not previously been defaulted so we need to add a new default --%>
    <%-- add default --%>
    <sess:setAttribute name="form">addDefaultFunc</sess:setAttribute>
    <c:import url="addDefaultFunc.jsp" var="webPage" />
    <% helperBean.throwException("addDefaultFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- clear the default just made if required --%>
    <if:IfTrue cond='<%= recordBean.getClearDefault().equals("Y") %>' >
      <sess:setAttribute name="form">clearDefaultFunc</sess:setAttribute>
      <c:import url="clearDefaultFunc.jsp" var="webPage" />
      <% helperBean.throwException("clearDefaultFunc", (String)pageContext.getAttribute("webPage")); %>
    </if:IfTrue>

    <%-- add text --%>
    <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
    <c:import url="addTextFunc.jsp" var="webPage" />
    <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultAdditional</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= defaultAdditionalBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultAdditional</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= defaultAdditionalBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultAdditional</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= defaultAdditionalBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultAdditional</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= recordBean.getDefault_route() %></sess:setAttribute>
    <c:redirect url="${recordBean.default_route}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="defaultAdditionalView.jsp" />
