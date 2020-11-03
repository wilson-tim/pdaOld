<%@ page errorPage="error.jsp" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="javax.naming.Context, javax.naming.InitialContext" %>
<%@ page import="com.db.DbUtils" %>
<%@ page import="com.dbb.SNoBean" %>
<%@ page import="com.vsb.recordBean" %>
<%@ page import="com.vsb.loginBean" %>
<%@ page import="com.vsb.helperBean" %>
<%@ page import="com.vsb.treesListBean" %>
<%@ page import="com.vsb.treeDetailsBean" %>
<%@ page import="com.vsb.treeAddBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="treesListBean" scope="session" class="com.vsb.treesListBean" />
<jsp:useBean id="treeDetailsBean" scope="session" class="com.vsb.treeDetailsBean" />
<jsp:useBean id="treeAddBean" scope="session" class="com.vsb.treeAddBean" />
<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addUpdateTreeFunc" value="false">
  addUpdateTreeFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addUpdateTreeFunc">
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


    // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
    // as it is just being used to turn a string date into a real date.
    SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
    // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
    // the converted real date back into a string but in the database format.
    SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
  %>
 
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- Is there any text to add --%>
    <% String text_flag = "Y"; %>

    <%-- Is there any text to add --%>
    <% String tempTextIn = ""; %>
    <%-- UPDATE SECTION --%>
    <if:IfTrue cond='<%= treesListBean.getAction().equals("Details") %>' >
      <if:IfTrue cond='<%= treeDetailsBean.getText() == null || treeDetailsBean.getText().equals("") %>' >
        <% text_flag = "N"; %>
      </if:IfTrue>
      <% tempTextIn = treeDetailsBean.getText(); %>
    </if:IfTrue>
    <%-- ADD SECTION --%>
    <if:IfTrue cond='<%= treesListBean.getAction().equals("Add") %>' >
      <if:IfTrue cond='<%= treeAddBean.getText() == null || treeAddBean.getText().equals("") %>' >
        <% text_flag = "N"; %>
      </if:IfTrue>
      <% tempTextIn = treeAddBean.getText(); %>
    </if:IfTrue>

    <%-- get rid of newline and carriage return chars --%>
    <%
      tempTextIn = tempTextIn.replace('\n',' ');
      String text = tempTextIn.replace('\r',' ');
    %>

    <%-- Add a new tree --%>
    <%-- get the trees item, feature and contract --%>
    <% String trees_item = ""; %>
    <% String trees_feature = ""; %>
    <% String trees_contract = ""; %>

    <%-- Get the TREES item --%>
    <sql:query>
      SELECT c_field FROM keys WHERE keyname = 'TREES_ITEM'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="c_field" />
      <sql:wasNotNull>
        <% trees_item = ((String)pageContext.getAttribute("c_field")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>
    <%-- Get the TREES feature --%>
    <sql:query>
      SELECT c_field FROM keys WHERE keyname = 'TREES_FEATURE'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="c_field" />
      <sql:wasNotNull>
        <% trees_feature = ((String)pageContext.getAttribute("c_field")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>
    <%-- Get the TREES contract --%>
    <sql:query>
      SELECT c_field FROM keys WHERE keyname = 'TREES_CONTRACT'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="c_field" />
      <sql:wasNotNull>
        <% trees_contract = ((String)pageContext.getAttribute("c_field")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>
 
    <%-- Update or Insert depending on whether a user picked a to add or update --%>
    <%-- a tree on the treesList form. --%>
    <% int tree_ref = 0; %>
    <% String log_status = ""; %>
    <%-- ADD SECTION --%>
    <if:IfTrue cond='<%= treesListBean.getAction().equals("Add") %>' >
      <%-- get the next tree_ref --%>
      <% pageContext.setAttribute("max_tree_ref", "0"); %>
      <sql:query>
        select max(tree_ref)
        from trees
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="max_tree_ref" />
        <sql:wasNull>
          <% pageContext.setAttribute("max_tree_ref", "0"); %>
        </sql:wasNull>
      </sql:resultSet>
      <% tree_ref = Integer.parseInt((String)pageContext.getAttribute("max_tree_ref")) + 1; %>

      <%-- Add the new tree_ref to the recordBean so that it can be used later --%>
      <% recordBean.setTree_ref(String.valueOf(tree_ref)); %>

      <%-- set the log_status to add 'A' --%>
      <% log_status = "A"; %>

      <%-- Add the tree record --%>
      <sql:query>
        insert into trees (
          tree_ref,
          tr_no,
          position,
          position_ref,
          species_ref,
          height_ref,
          age_ref,
          crown_ref,
          dbh_ref,
          condition_ref,
          vigour_ref,
          pavement_ref,
          boundary_ref,
          building_ref,
          osmapref,
          issue_ref,
          easting,
          northing,
          username,
          updated
        ) values (
          <%= tree_ref %>,
          <%= treeAddBean.getTr_no() %>,
          '<%= treeAddBean.getPosition() %>',
          <if:IfTrue cond='<%= treeAddBean.getPosition_ref().equals("") %>' >
            null,
          </if:IfTrue>
          <if:IfTrue cond='<%= !treeAddBean.getPosition_ref().equals("") %>' >
            <%= treeAddBean.getPosition_ref() %>,
          </if:IfTrue>
          <%= treeAddBean.getSpecies_ref() %>,
          <%= treeAddBean.getHeight_ref() %>,
          <%= treeAddBean.getAge_ref() %>,
          <%= treeAddBean.getCrown_ref() %>,
          <%= treeAddBean.getDbh_ref() %>,
          <%= treeAddBean.getCondition_ref() %>,
          <%= treeAddBean.getVigour_ref() %>,
          <%= treeAddBean.getPavement_ref() %>,
          <if:IfTrue cond='<%= treeAddBean.getBoundary_ref().equals("") %>' >
            null,
          </if:IfTrue>
          <if:IfTrue cond='<%= !treeAddBean.getBoundary_ref().equals("") %>' >
            <%= treeAddBean.getBoundary_ref() %>,
          </if:IfTrue>
          <if:IfTrue cond='<%= treeAddBean.getBuilding_ref().equals("") %>' >
            null,
          </if:IfTrue>
          <if:IfTrue cond='<%= !treeAddBean.getBuilding_ref().equals("") %>' >
            <%= treeAddBean.getBuilding_ref() %>,
          </if:IfTrue>
          '<%= treeAddBean.getOsmapref() %>',
          <%= treeAddBean.getIssue_ref() %>,
          <%= treeAddBean.getEasting() %>,
          <%= treeAddBean.getNorthing() %>,
          '<%= helperBean.restrict(loginBean.getUser_name(), 12) %>',
          '<%= date %>'
        )
      </sql:query>
      <sql:execute />

      <%-- get the frequency and freq_basis from the treeAddBean frequency attribute --%>
      <%
        StringTokenizer frequency_key = new StringTokenizer(treeAddBean.getFrequency(), "|");
        String frequency = frequency_key.nextToken();
        String freq_basis = frequency_key.nextToken();
      %>

      <%-- Now add an si_d entry --%>
      <sql:query>
        insert into si_d (
          service_c,
          detail_func,
          site_ref,
          item_ref,
          feature_ref,
          contract_ref,
          detail_ref,
          frequency,
          freq_basis,
          detail_status,
          round_c,
          next_due,
          prev_due,
          date_done,
          last_username,
          last_updated,
          done_flag
        ) values (
          '<%= recordBean.getService_c() %>',
          'TR',
          '<%= recordBean.getSite_ref() %>',
          '<%= trees_item %>',
          '<%= trees_feature %>',
          '<%= trees_contract %>',
          <%= tree_ref %>,
          <%= frequency %>,
          '<%= freq_basis %>',
          'S',
          '<%= treeAddBean.getRound_c() %>',
          <if:IfTrue cond='<%= treeAddBean.getNext_due().equals("") %>' >
            null,
          </if:IfTrue>
          <if:IfTrue cond='<%= !treeAddBean.getNext_due().equals("") %>' >
            '<%= treeAddBean.getNext_due() %>',
          </if:IfTrue>
          null,
          '<%= date %>',
          '<%= helperBean.restrict(loginBean.getUser_name(), 12) %>',
          '<%= date %>',
          'N'
        )
      </sql:query>
      <sql:execute />

      <%-- Does a si_i record exist, if so then we are updating si_i/si_f otherwise we are inserting. --%>
      <% boolean update_si_i = false; %>
      <sql:query>
        select site_ref
        from si_i
        where site_ref = '<%= recordBean.getSite_ref() %>'
        and   item_ref = '<%= trees_item %>'
        and   feature_ref = '<%= trees_feature %>'
        and   contract_ref = '<%= trees_contract %>'
      </sql:query>
      <sql:resultSet id="rset">
      </sql:resultSet>
      <sql:wasNotEmpty>
        <% update_si_i = true; %>
      </sql:wasNotEmpty>

      <% String si_log_status = ""; %>
      <%-- UPDATE si_i and si_f records --%>
      <if:IfTrue cond='<%= update_si_i %>' >
        <%-- set the si_log_status to update 'U' --%>
        <% si_log_status = "U"; %>

        <sql:query>
          update si_i 
          set volume = volume + 1
          where site_ref = '<%= recordBean.getSite_ref() %>'
          and   item_ref = '<%= trees_item %>'
          and   feature_ref = '<%= trees_feature %>'
          and   contract_ref = '<%= trees_contract %>'
        </sql:query>
        <sql:execute />

        <sql:query>
          update si_f 
          set volume = volume + 1
          where site_ref = '<%= recordBean.getSite_ref() %>'
          and   feature_ref = '<%= trees_feature %>'
        </sql:query>
        <sql:execute />
      </if:IfTrue>
      <%-- INSERT si_i and si_f records --%>
      <if:IfTrue cond='<%= ! update_si_i %>' >
        <%-- set the si_log_status to add 'A' --%>
        <% si_log_status = "A"; %>

        <%-- Get the easting and northing info from the site_detail table --%>
        <% String site_detail_easting = ""; %>
        <% String site_detail_northing = ""; %>
        <% String site_detail_easting_end = ""; %>
        <% String site_detail_northing_end = ""; %>
        <sql:query>
          select easting, northing, easting_end, northing_end
          from site_detail
          where site_ref = '<%= recordBean.getSite_ref() %>' 
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="field" />
          <sql:wasNotNull>
            <% site_detail_easting = ((String)pageContext.getAttribute("field")).trim(); %>
          </sql:wasNotNull>
          <sql:getColumn position="2" to="field" />
          <sql:wasNotNull>
            <% site_detail_northing = ((String)pageContext.getAttribute("field")).trim(); %>
          </sql:wasNotNull>
          <sql:getColumn position="3" to="field" />
          <sql:wasNotNull>
            <% site_detail_easting_end = ((String)pageContext.getAttribute("field")).trim(); %>
          </sql:wasNotNull>
          <sql:getColumn position="4" to="field" />
          <sql:wasNotNull>
            <% site_detail_northing_end = ((String)pageContext.getAttribute("field")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>

        <sql:query>
          insert into si_i (
            item_ref,
            site_ref,
            feature_ref,
            contract_ref,
            priority_flag,
            volume,
            item_status,
            easting,
            northing,
            easting_end,
            northing_end
          ) values (
            '<%= trees_item %>',
            '<%= recordBean.getSite_ref() %>',
            '<%= trees_feature %>',
            '<%= trees_contract %>',
            'A',
            1,
            'I',
            <if:IfTrue cond='<%= site_detail_easting.equals("") %>' >
              null,
            </if:IfTrue>
            <if:IfTrue cond='<%= !site_detail_easting.equals("") %>' >
              <%= site_detail_easting %>,
            </if:IfTrue>
            <if:IfTrue cond='<%= site_detail_northing.equals("") %>' >
              null,
            </if:IfTrue>
            <if:IfTrue cond='<%= !site_detail_northing.equals("") %>' >
              <%= site_detail_northing %>,
            </if:IfTrue>
            <if:IfTrue cond='<%= site_detail_easting_end.equals("") %>' >
              null,
            </if:IfTrue>
            <if:IfTrue cond='<%= !site_detail_easting_end.equals("") %>' >
              <%= site_detail_easting_end %>,
            </if:IfTrue>
            <if:IfTrue cond='<%= site_detail_northing_end.equals("") %>' >
              null
            </if:IfTrue>
            <if:IfTrue cond='<%= !site_detail_northing_end.equals("") %>' >
              <%= site_detail_northing_end %>
            </if:IfTrue>
          )
        </sql:query>
        <sql:execute />
         
        <sql:query>
          insert into si_f (
            feature_ref,
            site_ref,
            volume,
            easting,
            northing
          ) values (
            '<%= trees_feature %>',
            '<%= recordBean.getSite_ref() %>',
            1,
            <if:IfTrue cond='<%= site_detail_easting.equals("") %>' >
              null,
            </if:IfTrue>
            <if:IfTrue cond='<%= !site_detail_easting.equals("") %>' >
              <%= site_detail_easting %>,
            </if:IfTrue>
            <if:IfTrue cond='<%= site_detail_northing.equals("") %>' >
              null
            </if:IfTrue>
            <if:IfTrue cond='<%= !site_detail_northing.equals("") %>' >
              <%= site_detail_northing %>
            </if:IfTrue>
          )
        </sql:query>
        <sql:execute />
 
      </if:IfTrue>

      <%-- Insert the si_i and si_f log entries --%>

      <%-- If there already is a record then the log_seq gets set to the next one --%>
      <%-- otherwise it defaults to 1. --%>
      <%-- set the log_seq number value --%>
      <% pageContext.setAttribute("max_log_seq", "0"); %>
      <sql:query>
        select max(log_seq)
        from si_i_log
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="max_log_seq" />
        <sql:wasNull>
          <% pageContext.setAttribute("max_log_seq", "0"); %>
        </sql:wasNull>
      </sql:resultSet>
      <% int si_i_log_seq = Integer.parseInt((String)pageContext.getAttribute("max_log_seq")) + 1; %>
  
      <%-- Now add an si_i_log entry --%>
      <sql:query>
        insert into si_i_log (
          item_ref,
          site_ref,
          feature_ref,
          contract_ref,
          allocation_r,
          priority_flag,
          volume,
          contract_value,
          base_value,
          occur_day,
          occur_week,
          occur_month,
          date_due,
          observation,
          round_c,
          pa_area,
          occur_no,
          variance,
          item_status,
          am_pm,
          prev_date,
          attachment_ref,
          easting,
          northing,
          easting_end,
          northing_end,
          log_seq,
          log_username,
          log_date,
          log_time_h,
          log_time_m,
          log_status
        )
        select item_ref,
          site_ref,
          feature_ref,
          contract_ref,
          allocation_r,
          priority_flag,
          volume,
          contract_value,
          base_value,
          occur_day,
          occur_week,
          occur_month,
          date_due,
          observation,
          round_c,
          pa_area,
          occur_no,
          variance,
          item_status,
          am_pm,
          prev_date,
          attachment_ref,
          easting,
          northing,
          easting_end,
          northing_end,
          <%= si_i_log_seq %>,
          '<%= loginBean.getUser_name() %>',
          '<%= date %>',
          '<%= time_h %>',
          '<%= time_m %>',
          '<%= si_log_status %>'
        from si_i
        where site_ref = '<%= recordBean.getSite_ref() %>'
        and   item_ref = '<%= trees_item %>'
        and   feature_ref = '<%= trees_feature %>'
        and   contract_ref = '<%= trees_contract %>'
      </sql:query>
      <sql:execute />

      <%-- If there already is a record then the log_seq gets set to the next one --%>
      <%-- otherwise it defaults to 1. --%>
      <%-- set the log_seq number value --%>
      <% pageContext.setAttribute("max_log_seq", "0"); %>
      <sql:query>
        select max(log_seq)
        from si_f_log
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="max_log_seq" />
        <sql:wasNull>
          <% pageContext.setAttribute("max_log_seq", "0"); %>
        </sql:wasNull>
      </sql:resultSet>
      <% int si_f_log_seq = Integer.parseInt((String)pageContext.getAttribute("max_log_seq")) + 1; %>
  
      <%-- Now add an si_f_log entry --%>
      <sql:query>
        insert into si_f_log (
          feature_ref,
          site_ref,
          volume,
          easting,
          northing,
          log_seq,
          log_username,
          log_date,
          log_time_h,
          log_time_m,
          log_status
        )
        select feature_ref,
          site_ref,
          volume,
          easting,
          northing,
          <%= si_f_log_seq %>,
          '<%= loginBean.getUser_name() %>',
          '<%= date %>',
          '<%= time_h %>',
          '<%= time_m %>',
          '<%= si_log_status %>'
        from si_i
        where site_ref = '<%= recordBean.getSite_ref() %>'
        and   feature_ref = '<%= trees_feature %>'
      </sql:query>
      <sql:execute />

    </if:IfTrue>
    <%-- UPDATE SECTION --%>
    <if:IfTrue cond='<%= treesListBean.getAction().equals("Details") %>' >
      <% tree_ref = Integer.parseInt(recordBean.getTree_ref()); %>

      <%-- set the log_status to update 'U' --%>
      <% log_status = "U"; %>

      <%-- update the tree record --%>
      <sql:query>
        update trees
        set tr_no = <%= treeDetailsBean.getTr_no() %>,
          position = '<%= treeDetailsBean.getPosition() %>',
          <if:IfTrue cond='<%= treeDetailsBean.getPosition_ref().equals("") %>' >
            position_ref = null,
          </if:IfTrue>
          <if:IfTrue cond='<%= !treeDetailsBean.getPosition_ref().equals("") %>' >
            position_ref = <%= treeDetailsBean.getPosition_ref() %>,
          </if:IfTrue>
          species_ref = <%= treeDetailsBean.getSpecies_ref() %>,
          height_ref = <%= treeDetailsBean.getHeight_ref() %>,
          age_ref = <%= treeDetailsBean.getAge_ref() %>,
          crown_ref = <%= treeDetailsBean.getCrown_ref() %>,
          dbh_ref = <%= treeDetailsBean.getDbh_ref() %>,
          condition_ref = <%= treeDetailsBean.getCondition_ref() %>,
          vigour_ref = <%= treeDetailsBean.getVigour_ref() %>,
          pavement_ref = <%= treeDetailsBean.getPavement_ref() %>,
          <if:IfTrue cond='<%= treeDetailsBean.getBoundary_ref().equals("") %>' >
            boundary_ref = null,
          </if:IfTrue>
          <if:IfTrue cond='<%= !treeDetailsBean.getBoundary_ref().equals("") %>' >
            boundary_ref = <%= treeDetailsBean.getBoundary_ref() %>,
          </if:IfTrue>
          <if:IfTrue cond='<%= treeDetailsBean.getBuilding_ref().equals("") %>' >
            building_ref = null,
          </if:IfTrue>
          <if:IfTrue cond='<%= !treeDetailsBean.getBuilding_ref().equals("") %>' >
            building_ref = <%= treeDetailsBean.getBuilding_ref() %>,
          </if:IfTrue>
          osmapref = '<%= treeDetailsBean.getOsmapref() %>',
          issue_ref = <%= treeDetailsBean.getIssue_ref() %>,
          easting = <%= treeDetailsBean.getEasting() %>,
          northing = <%= treeDetailsBean.getNorthing() %>,
          username = '<%= helperBean.restrict(loginBean.getUser_name(), 12) %>',
          updated = '<%= date %>'
        where tree_ref = <%= tree_ref %> 
      </sql:query>
      <sql:execute />

      <%-- get the frequency and freq_basis from the treeDetailsBean frequency attribute --%>
      <%
        StringTokenizer frequency_key = new StringTokenizer(treeDetailsBean.getFrequency(), "|");
        String frequency = frequency_key.nextToken();
        String freq_basis = frequency_key.nextToken();
      %>

      <sql:query>
        update si_d
        set round_c = '<%= treeDetailsBean.getRound_c() %>',
            frequency = <%= frequency %>,
            freq_basis = '<%= freq_basis %>',
            <if:IfTrue cond='<%= !treeDetailsBean.getNext_due().equals("") %>' >
              prev_due = next_due,
            </if:IfTrue>
            <if:IfTrue cond='<%= treeDetailsBean.getNext_due().equals("") %>' >
              next_due = null,
            </if:IfTrue>
            <if:IfTrue cond='<%= !treeDetailsBean.getNext_due().equals("") %>' >
              next_due = '<%= treeDetailsBean.getNext_due() %>',
            </if:IfTrue>
            date_done = '<%= date %>'
        where site_ref = '<%= recordBean.getSite_ref() %>'
        and   item_ref = '<%= trees_item %>'
        and   feature_ref = '<%= trees_feature %>'
        and   contract_ref = '<%= trees_contract %>'
        and   detail_ref = <%= tree_ref %> 
      </sql:query>
      <sql:execute />
    </if:IfTrue>

    <%-- DO THE BELOW FOR BOTH THE INSERT AND UPDATE SECTIONS --%>

    <%-- Generate the tree_desc --%>
    <%-- obtain the initial context, which holds the server/web.xml environment variables. --%>
    <% Context initCtx = new InitialContext(); %>
    <% Context envCtx = (Context) initCtx.lookup("java:comp/env"); %>
    
    <%-- Put all values that are going to be used in the <c:import ...> call, into the pageContext --%>
    <%-- So that the <c:import ...> tag can access them. --%>
    <% pageContext.setAttribute("tree_desc_service", (String)envCtx.lookup("tree_desc_service")); %>
    <% pageContext.setAttribute("contender_home", (String)envCtx.lookup("contender_home")); %>
    <% pageContext.setAttribute("system_path", (String)envCtx.lookup("system_path")); %>
    <% pageContext.setAttribute("cdev_db", (String)envCtx.lookup("cdev_db")); %>
    
    <% pageContext.setAttribute("tree_ref", String.valueOf(tree_ref)); %>

    <%-- Make the web service call, the returned value is stored in the --%>
    <%-- pageContext variable "webPage" --%>
    <%-- Need to catch the web service call, just incase the service is inaccesible --%>
    <c:catch var="caughtError">
      <c:import url="${tree_desc_service}" var="webPage" >
        <c:param name="contender_home" value="${contender_home}" />
        <c:param name="system_path"    value="${system_path}"    />
        <c:param name="cdev_db"        value="${cdev_db}"        />
        <c:param name="tree_ref"        value="${tree_ref}"        />
      </c:import>
    </c:catch>
    
    <% String returnedValue = ""; %>
    <% String tree_desc = "UNKNOWN"; %>
    <% Exception caughtError = (Exception)pageContext.getAttribute("caughtError"); %>
    <if:IfTrue cond='<%= caughtError == null %>'>
      <%-- No caught error so use value returned from web service --%>
      <% returnedValue = ((String)pageContext.getAttribute("webPage")).trim(); %>
    
      <%-- Validate generated entry --%>
      <if:IfTrue cond='<%= !returnedValue.equals("-1") && !returnedValue.equals("-2") && !returnedValue.equals("") && returnedValue.length() <= 50 %>'>
        <%-- Value valid so use it --%>
        <% tree_desc = returnedValue; %>
      </if:IfTrue>
    </if:IfTrue>
    <if:IfTrue cond='<%= caughtError != null %>'>
      <% tree_desc = "UNKNOWN"; %>
    </if:IfTrue>

    <%-- add the tree_desc --%>
    <sql:query>
      update trees
      set tree_desc = '<%= tree_desc %>'
      where tree_ref = <%= tree_ref %>
    </sql:query> 
    <sql:execute />

    <%-- FOR ADDING A TREE --%>
    <if:IfTrue cond='<%= treesListBean.getAction().equals("Add") %>' >
      <%-- Update bothe the tree_ref and tree_desc with their newly created values. --%>
      <%-- Not needed for the update section as it retreives these values from the database --%>
      <%-- when when the page refreshes. --%>
      <% treeAddBean.setTree_ref(String.valueOf(tree_ref)); %>
      <% treeAddBean.setTree_desc(tree_desc); %>
    </if:IfTrue>

    <%-- Add the trees_log record --%>
    <%-- If there already is a record then the log_seq gets set to the next one --%>
    <%-- otherwise it defaults to 1. --%>
    <%-- set the log_seq number value --%>
    <% pageContext.setAttribute("max_log_seq", "0"); %>
    <sql:query>
      select max(log_seq)
      from trees_log
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="max_log_seq" />
      <sql:wasNull>
        <% pageContext.setAttribute("max_log_seq", "0"); %>
      </sql:wasNull>
    </sql:resultSet>
    <% int trees_log_seq = Integer.parseInt((String)pageContext.getAttribute("max_log_seq")) + 1; %>

    <sql:query>
      insert into trees_log (
        tree_ref,
        tree_desc,
        tr_no,
        position,
        position_ref,
        species_ref,
        height_ref,
        age_ref,
        crown_ref,
        dbh_ref,
        condition_ref,
        vigour_ref,
        pavement_ref,
        boundary_ref,
        building_ref,
        osmapref,
        issue_ref,
        easting,
        northing,
        username,
        updated,
        log_seq,
        log_username,
        log_date,
        log_time_h,
        log_time_m,
        log_status
      )
      select tree_ref,
        tree_desc,
        tr_no,
        position,
        position_ref,
        species_ref,
        height_ref,
        age_ref,
        crown_ref,
        dbh_ref,
        condition_ref,
        vigour_ref,
        pavement_ref,
        boundary_ref,
        building_ref,
        osmapref,
        issue_ref,
        easting,
        northing,
        username,
        updated,
        <%= trees_log_seq %>,
        '<%= loginBean.getUser_name() %>',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= log_status %>'
      from trees
      where tree_ref = <%= tree_ref %>
    </sql:query>
    <sql:execute />

    <%-- If there already is a record then the log_seq gets set to the next one --%>
    <%-- otherwise it defaults to 1. --%>
    <%-- set the log_seq number value --%>
    <% pageContext.setAttribute("max_log_seq", "0"); %>
    <sql:query>
      select max(log_seq)
      from si_d_log
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="max_log_seq" />
      <sql:wasNull>
        <% pageContext.setAttribute("max_log_seq", "0"); %>
      </sql:wasNull>
    </sql:resultSet>
    <% int si_d_log_seq = Integer.parseInt((String)pageContext.getAttribute("max_log_seq")) + 1; %>

    <%-- Now add an si_d_log entry --%>
    <sql:query>
      insert into si_d_log (
        service_c,
        detail_func,
        site_ref,
        item_ref,
        feature_ref,
        contract_ref,
        detail_ref,
        frequency,
        freq_basis,
        detail_status,
        round_c,
        next_due,
        prev_due,
        date_done,
        last_username,
        last_updated,
        done_flag,
        log_seq,
        log_username,
        log_date,
        log_time_h,
        log_time_m,
        log_status
      )
      select service_c,
        detail_func,
        site_ref,
        item_ref,
        feature_ref,
        contract_ref,
        detail_ref,
        frequency,
        freq_basis,
        detail_status,
        round_c,
        next_due,
        prev_due,
        date_done,
        last_username,
        last_updated,
        done_flag,
        <%= si_d_log_seq %>,
        '<%= loginBean.getUser_name() %>',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= log_status %>'
      from si_d
      where site_ref = '<%= recordBean.getSite_ref() %>'
      and   item_ref = '<%= trees_item %>'
      and   feature_ref = '<%= trees_feature %>'
      and   contract_ref = '<%= trees_contract %>'
      and   detail_ref = <%= tree_ref %> 
    </sql:query>
    <sql:execute />

    <%-- Add any text that needs adding --%>
    <if:IfTrue cond='<%= text_flag.equals("Y") %>' >
      <%-- set the text seq number value --%>
      <% pageContext.setAttribute("max_text_seq", "0"); %>
      <sql:query>
        select max(seq)
        from trees_text
        where tree_ref = <%= tree_ref %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="max_text_seq" />
        <sql:wasNull>
          <% pageContext.setAttribute("max_text_seq", "0"); %>
        </sql:wasNull>
      </sql:resultSet>
      <% int text_seq = Integer.parseInt((String)pageContext.getAttribute("max_text_seq")) + 1; %>

      <%-- The text should be split into 56 char lines, and there should be a --%>
      <%-- single record for each line. --%>
      <%
        String allText = text.trim();
        String line;
        int lineIndex;
        boolean flag = true;
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
            insert into trees_text (
              tree_ref,
              seq,
              username,
              doa,
              txt
            ) values (
              <%= tree_ref %>,
              <%= text_seq %>,
              '<%= loginBean.getUser_name() %>',
              '<%= date %>',
              '<%= DbUtils.cleanString(line) %>'
            )
          </sql:query>
          <sql:execute />
      <%
          text_seq = text_seq + 1;
        } while (flag == true);
      %>
    </if:IfTrue>

  </sql:statement>
  <sql:closeConnection conn="con1"/>

</sess:equalsAttribute>
