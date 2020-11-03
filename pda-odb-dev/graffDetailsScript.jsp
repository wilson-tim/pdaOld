<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.graffDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, com.utils.date.vsbCalendar" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="graffDetailsBean"  scope="session" class="com.vsb.graffDetailsBean" />
<jsp:useBean id="recordBean"        scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"        scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="graffDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Get the database format for the date --%>
<% String dbDateFormat = application.getInitParameter("db_date_fmt"); %>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="graffDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="graffDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="graffDetailsBean" property="*" />

    <%-- make sure all the none ticked checkbox attributes are set to "N" --%>
    <if:IfTrue cond="<%= graffDetailsBean.getTag_offensive().equals("") %>">
      <% graffDetailsBean.setTag_offensive("N"); %>
    </if:IfTrue>
    <if:IfTrue cond="<%= graffDetailsBean.getTag_visible().equals("") %>">
      <% graffDetailsBean.setTag_visible("N"); %>
    </if:IfTrue>
    <if:IfTrue cond="<%= graffDetailsBean.getTag_recognisable().equals("") %>">
      <% graffDetailsBean.setTag_recognisable("N"); %>
    </if:IfTrue>
    <if:IfTrue cond="<%= graffDetailsBean.getTag_known_offender().equals("") %>">
      <% graffDetailsBean.setTag_known_offender("N"); %>
    </if:IfTrue>
    <if:IfTrue cond="<%= graffDetailsBean.getTag_repeat_offence().equals("") %>">
      <% graffDetailsBean.setTag_repeat_offence("N"); %>
    </if:IfTrue>
    <if:IfTrue cond="<%= graffDetailsBean.getRefuse_pay().equals("") %>">
      <% graffDetailsBean.setRefuse_pay("N"); %>
    </if:IfTrue>
    <if:IfTrue cond="<%= graffDetailsBean.getIndemnity_response().equals("") %>">
      <% graffDetailsBean.setIndemnity_response("N"); %>
    </if:IfTrue>
    <if:IfTrue cond="<%= graffDetailsBean.getCust_responsible().equals("") %>">
      <% graffDetailsBean.setCust_responsible("N"); %>
    </if:IfTrue>
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="graffDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <jsp:setProperty name="graffDetailsBean" property="action" value="" />
  <jsp:setProperty name="graffDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="graffDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="addGraffDetails" >
  <jsp:setProperty name="graffDetailsBean" property="action" value="" />
  <jsp:setProperty name="graffDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="graffDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="surveyAddDefault" >
  <jsp:setProperty name="graffDetailsBean" property="action" value="" />
  <jsp:setProperty name="graffDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="graffDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="graffDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("surveyAddDefault")    ||
                       ((String)session.getAttribute("input")).equals("addGraffDetails") ||
                       ((String)session.getAttribute("input")).equals("compSampDetails")    %>' >

    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <%-- Initialise the form bean by populating the form bean with the values from the record --%>
      <sql:query>
        SELECT volume_ref,
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
          graffiti_level_ref,
          indemnity_response,
          indemnity_date,
          indemnity_time_h,
          indemnity_time_m,
          cust_responsible,
          landlord_perm_date
        FROM comp_ert_header
        WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="volume_ref" />
        <% graffDetailsBean.setVolume_ref((String)pageContext.getAttribute("volume_ref")); %>
        <sql:wasNull>
          <% graffDetailsBean.setVolume_ref(""); %>
        </sql:wasNull>
        
        <sql:getColumn position="2" to="tag_offensive" />
        <% graffDetailsBean.setTag_offensive((String)pageContext.getAttribute("tag_offensive")); %>
        <sql:wasNull>
          <% graffDetailsBean.setTag_offensive(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="3" to="tag_visible" />
        <% graffDetailsBean.setTag_visible((String)pageContext.getAttribute("tag_visible")); %>
        <sql:wasNull>
          <% graffDetailsBean.setTag_visible(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="4" to="tag_recognisable" />
        <% graffDetailsBean.setTag_recognisable((String)pageContext.getAttribute("tag_recognisable")); %>
        <sql:wasNull>
          <% graffDetailsBean.setTag_recognisable(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="5" to="tag_known_offender" />
        <% graffDetailsBean.setTag_known_offender((String)pageContext.getAttribute("tag_known_offender")); %>
        <sql:wasNull>
          <% graffDetailsBean.setTag_known_offender(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="6" to="tag_offender_info" />
        <% graffDetailsBean.setTag_offender_info((String)pageContext.getAttribute("tag_offender_info")); %>
        <sql:wasNull>
          <% graffDetailsBean.setTag_offender_info(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="7" to="tag_repeat_offence" />
        <% graffDetailsBean.setTag_repeat_offence((String)pageContext.getAttribute("tag_repeat_offence")); %>
        <sql:wasNull>
          <% graffDetailsBean.setTag_repeat_offence(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="8" to="tag_offences_ref" />
        <% graffDetailsBean.setTag_offences_ref((String)pageContext.getAttribute("tag_offences_ref")); %>
        <sql:wasNull>
          <% graffDetailsBean.setTag_offences_ref(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="9" to="rem_workforce_ref" />
        <% graffDetailsBean.setRem_workforce_ref((String)pageContext.getAttribute("rem_workforce_ref")); %>
        <sql:wasNull>
          <% graffDetailsBean.setRem_workforce_ref(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="10" to="wo_est_cost" />
        <% graffDetailsBean.setWo_est_cost((String)pageContext.getAttribute("wo_est_cost")); %>
        <sql:wasNull>
          <% graffDetailsBean.setWo_est_cost("0"); %>
        </sql:wasNull>
  
        <sql:getColumn position="11" to="refuse_pay" />
        <% graffDetailsBean.setRefuse_pay((String)pageContext.getAttribute("refuse_pay")); %>
        <sql:wasNull>
          <% graffDetailsBean.setRefuse_pay(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="12" to="est_duration_h" />
        <% graffDetailsBean.setEst_duration_h((String)pageContext.getAttribute("est_duration_h")); %>
        <sql:wasNull>
          <% graffDetailsBean.setEst_duration_h(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="13" to="est_duration_m" />
        <% graffDetailsBean.setEst_duration_m((String)pageContext.getAttribute("est_duration_m")); %>
        <sql:wasNull>
          <% graffDetailsBean.setEst_duration_m(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="14" to="graffiti_level_ref" />
        <% graffDetailsBean.setGraffiti_level_ref((String)pageContext.getAttribute("graffiti_level_ref")); %>
        <sql:wasNull>
          <% graffDetailsBean.setGraffiti_level_ref(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="15" to="indemnity_response" />
        <% graffDetailsBean.setIndemnity_response((String)pageContext.getAttribute("indemnity_response")); %>
        <sql:wasNull>
          <% graffDetailsBean.setIndemnity_response(""); %>
        </sql:wasNull>
  
        <sql:getDate position="16" to="indemnity_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <% graffDetailsBean.setIndemnity_date((String)pageContext.getAttribute("indemnity_date")); %>
        <sql:wasNull>
          <% graffDetailsBean.setIndemnity_date(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="17" to="indemnity_time_h" />
        <% graffDetailsBean.setIndemnity_time_h((String)pageContext.getAttribute("indemnity_time_h")); %>
        <sql:wasNull>
          <% graffDetailsBean.setIndemnity_time_h(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="18" to="indemnity_time_m" />
        <% graffDetailsBean.setIndemnity_time_m((String)pageContext.getAttribute("indemnity_time_m")); %>
        <sql:wasNull>
          <% graffDetailsBean.setIndemnity_time_m(""); %>
        </sql:wasNull>
  
        <sql:getColumn position="19" to="cust_responsible" />
        <% graffDetailsBean.setCust_responsible((String)pageContext.getAttribute("cust_responsible")); %>
        <sql:wasNull>
          <% graffDetailsBean.setCust_responsible(""); %>
        </sql:wasNull>
  
        <sql:getDate position="20" to="landlord_perm_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <% graffDetailsBean.setLandlord_perm_date((String)pageContext.getAttribute("landlord_perm_date")); %>
        <sql:wasNull>
          <% graffDetailsBean.setLandlord_perm_date(""); %>
        </sql:wasNull>          
        
      </sql:resultSet>
      <sql:wasEmpty>
        <% graffDetailsBean.setVolume_ref("");         %>
        <% graffDetailsBean.setTag_offensive("");      %>
        <% graffDetailsBean.setTag_visible("");        %>
        <% graffDetailsBean.setTag_recognisable("");   %>
        <% graffDetailsBean.setTag_known_offender(""); %>
        <% graffDetailsBean.setTag_offender_info("");  %>
        <% graffDetailsBean.setTag_repeat_offence(""); %>
        <% graffDetailsBean.setTag_offences_ref("");   %>
        <% graffDetailsBean.setRem_workforce_ref("");  %>
        <% graffDetailsBean.setWo_est_cost("0");       %>
        <% graffDetailsBean.setRefuse_pay("");         %>
        <% graffDetailsBean.setEst_duration_h("");     %>
        <% graffDetailsBean.setEst_duration_m("");     %>
        <% graffDetailsBean.setGraffiti_level_ref(""); %>
        <% graffDetailsBean.setIndemnity_response(""); %>
        <% graffDetailsBean.setIndemnity_date("");     %>
        <% graffDetailsBean.setIndemnity_time_h("");   %>
        <% graffDetailsBean.setIndemnity_time_m("");   %>
        <% graffDetailsBean.setCust_responsible("");   %>
        <% graffDetailsBean.setLandlord_perm_date(""); %>
      </sql:wasEmpty>

      <%-- Initialise the day/month/year fields in the bean for the indemnity date if not blank --%>
      <if:IfTrue cond='<%= !graffDetailsBean.getIndemnity_date().equals("") %>'>
        <% vsbCalendar indemnityCalendar = new vsbCalendar( graffDetailsBean.getIndemnity_date(), dbDateFormat ); %>
        <% graffDetailsBean.setIndemnity_day( indemnityCalendar.getDay() );     %>
        <% graffDetailsBean.setIndemnity_month( indemnityCalendar.getMonth() ); %>
        <% graffDetailsBean.setIndemnity_year( indemnityCalendar.getYear() );   %>
      </if:IfTrue>

      <%-- Initialise the day/month/year fields on the bean for the indemnity date if it is blank to todays date --%>
      <if:IfTrue cond='<%= graffDetailsBean.getIndemnity_date().equals("") %>'>
        <% vsbCalendar todaysCalendar = new vsbCalendar( dbDateFormat );        %>
        <% graffDetailsBean.setIndemnity_day( todaysCalendar.getDay() );        %>
        <% graffDetailsBean.setIndemnity_month( todaysCalendar.getMonth() );    %>
        <% graffDetailsBean.setIndemnity_year( todaysCalendar.getYear() );      %>
        <% graffDetailsBean.setIndemnity_time_h( todaysCalendar.getHours() );   %>
        <% graffDetailsBean.setIndemnity_time_m( todaysCalendar.getMinutes() ); %>
      </if:IfTrue>
      
      <%-- Initialise the day/month/year fields in the bean for the landlord responsible date if not blank --%>
      <if:IfTrue cond='<%= !graffDetailsBean.getLandlord_perm_date().equals("") %>'>
        <% vsbCalendar landlordCalendar = new vsbCalendar( graffDetailsBean.getLandlord_perm_date(), dbDateFormat ); %>
        <% graffDetailsBean.setLandlord_perm_day( landlordCalendar.getDay() );     %>
        <% graffDetailsBean.setLandlord_perm_month( landlordCalendar.getMonth() ); %>
        <% graffDetailsBean.setLandlord_perm_year( landlordCalendar.getYear() );   %>
      </if:IfTrue>
      
      <%-- get the tag if it exists --%>
      <sql:query>
        select tag
        from comp_ert_tags
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
        and seq_no = 1
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="tag" />
        <% graffDetailsBean.setTag((String)pageContext.getAttribute("tag")); %>
        <sql:wasNull>
          <% graffDetailsBean.setTag(""); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% graffDetailsBean.setTag(""); %>
      </sql:wasEmpty>
  
      <% int i = 0; %>
  
      <%-- Surface --%>
      <% String[] ref_ertsur = new String[50]; %>
      <% i = 0; %>
      <sql:query>
        select lookup_code
        from comp_ert_detail
        where lookup_func = 'ERTSUR'
        and   complaint_no = '<%= recordBean.getComplaint_no() %>'
        order by lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_code" />
        <% ref_ertsur[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
        <% i = i + 1; %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% ref_ertsur = null; %>
      </sql:wasEmpty>
      <% graffDetailsBean.setRef_ertsur(ref_ertsur); %>
      
      <%-- Material --%>
      <% String[] ref_ertmat = new String[50]; %>
      <% i = 0; %>
      <sql:query>
        select lookup_code
        from comp_ert_detail
        where lookup_func = 'ERTMAT'
        and   complaint_no = '<%= recordBean.getComplaint_no() %>'
        order by lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_code" />
        <% ref_ertmat[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
        <% i = i + 1; %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% ref_ertmat = null; %>
      </sql:wasEmpty>
      <% graffDetailsBean.setRef_ertmat(ref_ertmat); %>
  
      <%-- nature of Offensive Graffiti --%>
      <% String[] ref_ertoff = new String[50]; %>
      <% i = 0; %>
      <sql:query>
        select lookup_code
        from comp_ert_detail
        where lookup_func = 'ERTOFF'
        and   complaint_no = '<%= recordBean.getComplaint_no() %>'
        order by lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_code" />
        <% ref_ertoff[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
        <% i = i + 1; %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% ref_ertoff = null; %>
      </sql:wasEmpty>
      <% graffDetailsBean.setRef_ertoff(ref_ertoff); %>

      <%-- Ownership --%>
      <% String[] ref_ertown = new String[50]; %>
      <% i = 0; %>
      <sql:query>
        select lookup_code
        from comp_ert_detail
        where lookup_func = 'ERTOWN'
        and   complaint_no = '<%= recordBean.getComplaint_no() %>'
        order by lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_code" />
        <% ref_ertown[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
        <% i = i + 1; %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% ref_ertown = null; %>
      </sql:wasEmpty>
      <% graffDetailsBean.setRef_ertown(ref_ertown); %>

      <%-- Operation --%>
      <% String[] ref_ertopp = new String[50]; %>
      <% i = 0; %>
      <sql:query>
        select lookup_code
        from comp_ert_detail
        where lookup_func = 'ERTOPP'
        and   complaint_no = '<%= recordBean.getComplaint_no() %>'
        order by lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_code" />
        <% ref_ertopp[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
        <% i = i + 1; %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% ref_ertopp = null; %>
      </sql:wasEmpty>
      <% graffDetailsBean.setRef_ertopp(ref_ertopp); %>

      <%-- Item --%>
      <% String[] ref_ertitm = new String[50]; %>
      <% i = 0; %>
      <sql:query>
        select lookup_code
        from comp_ert_detail
        where lookup_func = 'ERTITM'
        and   complaint_no = '<%= recordBean.getComplaint_no() %>'
        order by lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_code" />
        <% ref_ertitm[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
        <% i = i + 1; %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% ref_ertitm = null; %>
      </sql:wasEmpty>
      <% graffDetailsBean.setRef_ertitm(ref_ertitm); %>
 
      <%-- preventative action taken --%>
      <% String[] ref_ertact = new String[50]; %>
      <% i = 0; %>
      <sql:query>
        select lookup_code
        from comp_ert_detail
        where lookup_func = 'ERTACT'
        and   complaint_no = '<%= recordBean.getComplaint_no() %>'
        order by lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_code" />
        <% ref_ertact[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
        <% i = i + 1; %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% ref_ertact = null; %>
      </sql:wasEmpty>
      <% graffDetailsBean.setRef_ertact(ref_ertact); %>
  
      <%-- abusive behaviour encountered --%>
      <% String[] ref_abuse = new String[50]; %>
      <% i = 0; %>
      <sql:query>
        select lookup_code
        from comp_ert_detail
        where lookup_func = 'ERTABU'
        and   complaint_no = '<%= recordBean.getComplaint_no() %>'
        order by lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_code" />
        <% ref_abuse[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
        <% i = i + 1; %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% ref_abuse = null; %>
      </sql:wasEmpty>
      <% graffDetailsBean.setRef_abuse(ref_abuse); %>
  
      <%-- method of removal used --%>
      <% String[] ref_ertmet = new String[50]; %>
      <% i = 0; %>
      <sql:query>
        select lookup_code
        from comp_ert_detail
        where lookup_func = 'ERTMET'
        and   complaint_no = '<%= recordBean.getComplaint_no() %>'
        order by lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_code" />
        <% ref_ertmet[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
        <% i = i + 1; %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% ref_ertmet = null; %>
      </sql:wasEmpty>
      <% graffDetailsBean.setRef_ertmet(ref_ertmet); %>
  
      <%-- equipment and material used for removal --%>
      <% String[] ref_ertequ = new String[50]; %>
      <% i = 0; %>
      <sql:query>
        select lookup_code
        from comp_ert_detail
        where lookup_func = 'ERTEQU'
        and   complaint_no = '<%= recordBean.getComplaint_no() %>'
        order by lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_code" />
        <% ref_ertequ[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
        <% i = i + 1; %>
      </sql:resultSet>
      <sql:wasEmpty>
        <% ref_ertequ = null; %>
      </sql:wasEmpty>
      <% graffDetailsBean.setRef_ertequ(ref_ertequ); %> 
  
    </sql:statement>
    <sql:closeConnection conn="con"/>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Flag to control if the terms and conditions form is used --%>
<% String use_graff_tc = ""; %>

<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
<sql:statement id="stmt" conn="con">
  <%-- Set the Terms and Conditions form control switch--%>
  <sql:query>
    SELECT c_field
      FROM keys
     WHERE keyname = 'ERT_T_AND_C_INFO'
       AND service_c = 'ALL'
  </sql:query>
  <sql:resultSet id="rsetlist">
    <sql:getColumn position="1" to="use_graff_tc" />
    <sql:wasNotNull>
      <% use_graff_tc = ((String)pageContext.getAttribute("use_graff_tc")).trim(); %>
    </sql:wasNotNull>
  </sql:resultSet>
</sql:statement>
<sql:closeConnection conn="con"/>
        
<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="graffDetails" >
  <%-- Only do validation if we are not trying to go back or jump --%>
  <if:IfTrue cond='<%= ! graffDetailsBean.getAction().equals("Back") && 
                       ! graffDetailsBean.getAction().equals("Inspect") && 
                       ! graffDetailsBean.getAction().equals("Sched/Comp") %>' >
                       
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= graffDetailsBean.getTag_offensive().equals("N") && graffDetailsBean.getRef_ertoff() != null %>' >
      <jsp:setProperty name="graffDetailsBean" property="error" 
        value="The offensive nature of the graffiti has been selected but the graffiti has not been flagged as offensive." />
      <jsp:forward page="graffDetailsView.jsp" />
    </if:IfTrue>

    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= graffDetailsBean.getTag_recognisable().equals("N") && !graffDetailsBean.getTag().equals("") %>' >
      <jsp:setProperty name="graffDetailsBean" property="error" 
        value="The tag id has been given but the tag is flagged as not recognisable." />
      <jsp:forward page="graffDetailsView.jsp" />
    </if:IfTrue>

    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= graffDetailsBean.getTag_known_offender().equals("N") && 
                        !graffDetailsBean.getTag_offender_info().equals("") %>' >
      <jsp:setProperty name="graffDetailsBean" property="error" 
        value="The offender details has been given but the offender is flagged as unknown." />
      <jsp:forward page="graffDetailsView.jsp" />
    </if:IfTrue>

    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= graffDetailsBean.getTag_repeat_offence().equals("N") && 
                         !(graffDetailsBean.getTag_offences_ref() == null || 
                           graffDetailsBean.getTag_offences_ref().equals("")) %>' >
      <%-- Blank the number of times for a repeat offence, just incase the user is trying --%>
      <%-- to unselect them. --%>
      <% graffDetailsBean.setTag_offences_ref(""); %>
      <jsp:setProperty name="graffDetailsBean" property="error" 
        value="The number of times for a repeat offence has been selected but a repeat offence has not been flagged." />
      <jsp:forward page="graffDetailsView.jsp" />
    </if:IfTrue>

    <%-- works order estimated cost validation --%>
    <if:IfTrue cond='<%= graffDetailsBean.getWo_est_cost() != null && 
                        !graffDetailsBean.getWo_est_cost().equals("") && 
                        !helperBean.isStringDouble(graffDetailsBean.getWo_est_cost()) %>' >
      <jsp:setProperty name="graffDetailsBean" property="error"
        value="If supplying an estimated cost, it must be a number." />
      <jsp:forward page="graffDetailsView.jsp" />
    </if:IfTrue>

    <%-- works order duration field (hrs) validation --%>
    <if:IfTrue cond='<%= graffDetailsBean.getEst_duration_h() != null && 
                        !graffDetailsBean.getEst_duration_h().equals("") && 
                        !helperBean.isStringInt(graffDetailsBean.getEst_duration_h()) %>' >
      <jsp:setProperty name="graffDetailsBean" property="error"
        value="If supplying a duration (hrs), it must be an integer." />
      <jsp:forward page="graffDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= graffDetailsBean.getEst_duration_h() != null && 
                        !graffDetailsBean.getEst_duration_h().equals("") && 
                        Integer.parseInt(graffDetailsBean.getEst_duration_h()) <= 0 %>' >
      <jsp:setProperty name="graffDetailsBean" property="error"
        value="If supplying a duration (hrs), it must be greater than zero." />
      <jsp:forward page="graffDetailsView.jsp" />
    </if:IfTrue>
    
    <%-- works order duration field (mins) validation --%>
    <if:IfTrue cond='<%= graffDetailsBean.getEst_duration_m() != null && 
                        !graffDetailsBean.getEst_duration_m().equals("") && 
                        !helperBean.isStringInt(graffDetailsBean.getEst_duration_m()) %>' >
      <jsp:setProperty name="graffDetailsBean" property="error"
        value="If supplying a duration (mins), it must be an integer." />
      <jsp:forward page="graffDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= graffDetailsBean.getEst_duration_m() != null && 
                        !graffDetailsBean.getEst_duration_m().equals("") && 
                        Integer.parseInt(graffDetailsBean.getEst_duration_m()) <= 0 %>' >
      <jsp:setProperty name="graffDetailsBean" property="error"
        value="If supplying a duration (mins), it must be greater than zero." />
      <jsp:forward page="graffDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= graffDetailsBean.getEst_duration_m() != null && 
                        !graffDetailsBean.getEst_duration_m().equals("") &&  
                        Integer.parseInt(graffDetailsBean.getEst_duration_m()) >= 60 %>' >
      <jsp:setProperty name="graffDetailsBean" property="error"
        value="If supplying a duration (mins), it must be less than 60." />
      <jsp:forward page="graffDetailsView.jsp" />
    </if:IfTrue>

    <%-- Switch Off Date Validation if we are not using the terms and conditions form in graffiti --%>
    <if:IfTrue cond='<%= use_graff_tc.equals("Y") %>'>

      <%-- Get the indemnity day, month and year --%>
      <% String indemnityDay   = graffDetailsBean.getIndemnity_day(); %>
      <% String indemnityMonth = graffDetailsBean.getIndemnity_month(); %>
      <% String indemnityYear  = graffDetailsBean.getIndemnity_year(); %>
      <%-- If an incomplete indemnity date has been entered flag an error --%>
      <if:IfTrue cond='<%= !(indemnityDay.equals("")&&indemnityMonth.equals("")&&indemnityYear.equals(""))
                        && !(!indemnityDay.equals("")&&!indemnityMonth.equals("")&&!indemnityYear.equals("")) %>'>
        <jsp:setProperty name="graffDetailsBean" property="error" 
          value="Incomplete indemnity date has been entered. Please try again." />
        <jsp:forward page="graffDetailsView.jsp" />
      </if:IfTrue>
    
      <%-- Get the landlord permission day, month and year --%>
      <% String landlordPermDay   = graffDetailsBean.getLandlord_perm_day(); %>
      <% String landlordPermMonth = graffDetailsBean.getLandlord_perm_month(); %>
      <% String landlordPermYear  = graffDetailsBean.getLandlord_perm_year(); %>
      <%-- If an incomplete indemnity date has been entered flag an error --%>
      <if:IfTrue cond='<%= !(landlordPermDay.equals("")&&landlordPermMonth.equals("")&&landlordPermYear.equals(""))
                        && !(!landlordPermDay.equals("")&&!landlordPermMonth.equals("")&&!landlordPermYear.equals("")) %>'>
        <jsp:setProperty name="graffDetailsBean" property="error" 
          value="Incomplete landlord permission date has been entered. Please try again." />
        <jsp:forward page="graffDetailsView.jsp" />
      </if:IfTrue>
      
      <%-- We know the dates either have valid data or they are all blank --%>
      <% boolean isIndemnityDateBlank = false; %>
      <%-- Check if the indemnity date entered is blank--%>
      <if:IfTrue cond='<%= indemnityDay.equals("") %>'>
        <% isIndemnityDateBlank = true; %>
      </if:IfTrue>
    
      <% boolean isLandlordPermDateBlank = false; %>
      <%-- Check if the landlord permission date entered is blank--%>
      <if:IfTrue cond='<%= landlordPermDay.equals("") %>'>
        <% isLandlordPermDateBlank = true; %>
      </if:IfTrue>
    
      <% GregorianCalendar calendar = new GregorianCalendar(); %>
  
      <%    
        // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
        // as it is just being used to turn a string date (re_inspect_date) into a real date.
        SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
        // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
        // the converted re_inspect_date back into a string but in the database format.
        SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
      %>
      
      <%----------- CHECKING THE INDEMNITY DATE AND TIME VARIABLES IF DATE IS NOT BLANK---------------%>
      <if:IfTrue cond='<%= !isIndemnityDateBlank %>'>
        <% // Convert string dates to integers
          int iDay   = new Integer( indemnityDay ).intValue();
          int iMonth = new Integer( indemnityMonth ).intValue();
          int iYear  = new Integer( indemnityYear ).intValue();
        %> 
        
        <if:IfTrue cond="<%= iDay > 30 && (iMonth == 4 || iMonth == 6 
                          || iMonth == 9 || iMonth == 11) %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="You have entered an invalid agreement date.<br/>Please try again" />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
        
        <if:IfTrue cond="<%= (calendar.isLeapYear(iYear) && iMonth == 2 && iDay > 29) ||
                             (!calendar.isLeapYear(iYear) && iMonth == 2 && iDay > 28) %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="You have entered an invalid agreement date.<br/>Please try again" />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
     
        <%-- checking that if the hours have been added then the mins should have been as well --%>
        <if:IfTrue cond="<%= graffDetailsBean.getIndemnity_time_h() != null &&
                            !graffDetailsBean.getIndemnity_time_h().equals("") &&
                             (graffDetailsBean.getIndemnity_time_m() == null ||
                              graffDetailsBean.getIndemnity_time_m().equals("")) %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="If supplying a time, you must supply the hours AND mins." />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
    
        <%-- checking that if the mins have been added then the hours should have been as well --%>
        <if:IfTrue cond="<%= graffDetailsBean.getIndemnity_time_m() != null &&
                            !graffDetailsBean.getIndemnity_time_m().equals("") &&
                             (graffDetailsBean.getIndemnity_time_h() == null ||
                              graffDetailsBean.getIndemnity_time_h().equals("")) %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="If supplying a time, you must supply the hours AND mins." />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
        
        <%-- rectify_time_h field (hrs) validation --%>
        <if:IfTrue cond="<%= graffDetailsBean.getIndemnity_time_h() != null &&
                            !graffDetailsBean.getIndemnity_time_h().equals("") &&
                            !helperBean.isStringInt(graffDetailsBean.getIndemnity_time_h()) %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="If supplying a time (hrs), it must be an integer." />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
    
        <if:IfTrue cond="<%= graffDetailsBean.getIndemnity_time_h() != null &&
                            !graffDetailsBean.getIndemnity_time_h().equals("") &&
                            Integer.parseInt(graffDetailsBean.getIndemnity_time_h()) < 0 %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="If supplying a time (hrs), it must NOT be less than zero." />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
    
        <if:IfTrue cond="<%= graffDetailsBean.getIndemnity_time_h() != null &&
                            !graffDetailsBean.getIndemnity_time_h().equals("") &&
                            Integer.parseInt(graffDetailsBean.getIndemnity_time_h()) > 23 %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="If supplying a time (hrs), it must NOT be greater than 23." />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
    
        <%-- rectify_time_m field (mins) validation --%>
        <if:IfTrue cond="<%= graffDetailsBean.getIndemnity_time_m() != null &&
                            !graffDetailsBean.getIndemnity_time_m().equals("") &&
                            !helperBean.isStringInt(graffDetailsBean.getIndemnity_time_m()) %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="If supplying a time (mins), it must be an integer." />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
    
        <if:IfTrue cond="<%= graffDetailsBean.getIndemnity_time_m() != null &&
                            !graffDetailsBean.getIndemnity_time_m().equals("") &&
                             Integer.parseInt(graffDetailsBean.getIndemnity_time_m()) < 0 %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="If supplying a time (mins), it must NOT be less than zero." />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
    
        <if:IfTrue cond="<%= graffDetailsBean.getIndemnity_time_m() != null &&
                            !graffDetailsBean.getIndemnity_time_m().equals("") &&
                            Integer.parseInt(graffDetailsBean.getIndemnity_time_m()) >= 60 %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="If supplying a time (mins), it must be less than 60." />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
        <%
          // Create the new date from the indemnity day, month and year
          String indemnity_date  = indemnityYear + "-" + indemnityMonth + "-" + indemnityDay;
          Date tempIndemnityDate = formatStDate.parse(indemnity_date);
          indemnity_date         = formatDbDate.format(tempIndemnityDate);
          // add the idemnity date to the graffity bean
          graffDetailsBean.setIndemnity_date(indemnity_date);
        %>
      </if:IfTrue>
      <%------------------------------ END OF INDEMNITY DATE AND TIME CHECK ------------------------------%>
      <%----------------- CHECKING THE LANDLORD PERMISSIONS DATE VARIABLES IF NOT BLANK ------------------%>
      <%-- Invalid entry --%>
      <if:IfTrue cond='<%= !isLandlordPermDateBlank %>'>
        <% // Convert string dates to integers
          int lDay   = new Integer( landlordPermDay ).intValue();
          int lMonth = new Integer( landlordPermMonth ).intValue();
          int lYear  = new Integer( landlordPermYear ).intValue();
        %> 
        <if:IfTrue cond="<%= lDay > 30 && (lMonth == 4 || 
                             lMonth == 6 || lMonth == 9 || lMonth == 11) %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="You have entered an invalid landlord permissions form date.<br/>Please try again" />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
      
        <if:IfTrue cond="<%= (calendar.isLeapYear(lYear) && lMonth == 2 && lDay > 29) ||
                            (!calendar.isLeapYear(lYear) && lMonth == 2 && lDay > 28) %>">
          <jsp:setProperty name="graffDetailsBean" property="error"
            value="You have entered an invalid landlord permissions form date.<br/>Please try again" />
          <jsp:forward page="graffDetailsView.jsp" />
        </if:IfTrue>
        <%
          // Create the new date string from the landlords day, month and year values
          String landlord_perm_date = landlordPermYear + "-" + landlordPermMonth + "-" + landlordPermDay;
          Date tempLandlordPermDate = formatStDate.parse(landlord_perm_date);
          landlord_perm_date = formatDbDate.format(tempLandlordPermDate);
          // add the landlord permissions date to the graffity bean
          graffDetailsBean.setLandlord_perm_date(landlord_perm_date);
        %>        
      </if:IfTrue>
      <%--------------------------- END OF LANDLORD PERMISSIONS DATE CHECK --------------------------------%>
    </if:IfTrue>
  </if:IfTrue>

  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= graffDetailsBean.getAction().equals("W/O") %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>

    <%-- Indicate what triggered the user action i.e. not triggered by the 'Action' button --%>
    <% recordBean.setUser_triggered("graffDetails"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">graffDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">contract</sess:setAttribute>
    <c:redirect url="contractScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= graffDetailsBean.getAction().equals(application.getInitParameter("def_name_verb")) %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>

    <%-- Indicate what triggered the user action i.e. not triggered by the 'Action' button --%>
    <% recordBean.setUser_triggered("graffDetails"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">graffDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">streetLength</sess:setAttribute>
    <c:redirect url="streetLengthScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <%-- 01/07/2010  TW  Check for Finish or Text button click --%>
  <if:IfTrue cond='<%= graffDetailsBean.getAction().equals("Finish") || graffDetailsBean.getAction().equals("Text") %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>

    <%-- Valid entry --%>
    <%-- We are NOT creating a default graffiti for the BV199 --%>
    <if:IfTrue cond='<%= ! recordBean.getBv_default_flag().equals("Y") %>'>
      <%-- We are inspecting a graffiti --%>
      <if:IfTrue cond='<%= ! recordBean.getDart_graff_flag().equals("Y") %>'>
        <%-- add graffiti details --%>
        <sess:setAttribute name="form">addDartGraffFunc</sess:setAttribute>
        <c:import url="addDartGraffFunc.jsp" var="webPage" />
        <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>
  
        <%-- add complaint text --%>
        <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
        <c:import url="addTextFunc.jsp" var="webPage" />
        <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>
  
        <%-- run the veolia link if required --%>
        <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
        <c:import url="veoliaLinkFunc.jsp" var="webPage" />
        <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">graffDetails</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">updateStatus</sess:setAttribute>
        <c:redirect url="updateStatusScript.jsp" />
      </if:IfTrue>
      <%-- We are creating a graffiti complaint --%>
      <if:IfTrue cond='<%= recordBean.getDart_graff_flag().equals("Y") %>'>
        <% recordBean.setCharge_flag("N"); %>
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">graffDetails</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
        <c:redirect url="addEnforcementScript.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- We are creating a default graffiti for the BV199 --%>
    <if:IfTrue cond='<%= recordBean.getBv_default_flag().equals("Y") %>'>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">graffDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">streetLength</sess:setAttribute>
      <c:redirect url="streetLengthScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= graffDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">graffDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= graffDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">graffDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= graffDetailsBean.getAction().equals("Back") %>' >  
    <% recordBean.setCharge_flag("N"); %>
    <% recordBean.setUser_triggered(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">graffDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= graffDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${graffDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="graffDetailsView.jsp" />
