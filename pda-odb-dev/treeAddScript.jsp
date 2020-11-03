<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.treeAddBean, com.vsb.treesListBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="com.map.mappingUtils, java.text.SimpleDateFormat, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0"     prefix="req"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                     prefix="c"    %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if"   %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"          prefix="sql"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app"  %>

<jsp:useBean id="treeAddBean" scope="session" class="com.vsb.treeAddBean" />
<jsp:useBean id="treesListBean"   scope="session" class="com.vsb.treesListBean" />
<jsp:useBean id="recordBean"      scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"      scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="mappingUtils"    scope="session" class="com.map.mappingUtils" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="treeAdd" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="treeAdd" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="treeAddBean" property="all" value="clear" />
    <jsp:setProperty name="treeAddBean" property="*" />

  </if:IfParameterEquals>
</req:existsParameter>
    
<%-- clear errors --%>
<jsp:setProperty name="treeAddBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="treesList" >
  <jsp:setProperty name="treeAddBean" property="action" value="" />
  <jsp:setProperty name="treeAddBean" property="all" value="clear" />
  <jsp:setProperty name="treeAddBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <%-- Add the new values to the record --%>
  <jsp:setProperty name="recordBean" property="tree_ref" value='<%= treesListBean.getTree_ref() %>' />
</sess:equalsAttribute>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="treeAdd" value="false">
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
  <sql:statement id="stmt" conn="con">
    <%-- Get the easting and northing of the street, as a starting point for the tree --%>
    <sql:query>
      SELECT easting, northing
      FROM site_detail
      WHERE site_ref = '<%= recordBean.getSite_ref() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="easting" />
      <sql:wasNotNull>
        <% treeAddBean.setEasting( (String)pageContext.getAttribute("easting") ); %>          
      </sql:wasNotNull>
      <sql:getColumn position="2" to="northing" />
      <sql:wasNotNull>
        <% treeAddBean.setNorthing( (String)pageContext.getAttribute("northing") ); %>
      </sql:wasNotNull>
    </sql:resultSet>
  </sql:statement>
  <sql:closeConnection conn="con"/>

  <%-- Set up the tree_ref and tree_desc to be 'To Be Assigned' --%>
  <% treeAddBean.setTree_ref("To Be Assigned"); %>    
  <% treeAddBean.setTree_desc("To Be Assigned"); %>    
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="treeAdd" >
  <%-- get rid of newline and carriage return chars --%>
  <%
    String tempTextIn = treeAddBean.getText();
    tempTextIn = tempTextIn.replace('\n',' ');
    tempTextIn = tempTextIn.replace('\r',' ');

    treeAddBean.setText(tempTextIn);
  %>

  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= treeAddBean.getAction().equals("Add") %>' >
    <% String trees_item = ""; %>
    <% String trees_feature = ""; %>
    <% String trees_contract = ""; %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
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
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getTr_no()) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="A Seq number must be supplied." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isValid(treeAddBean.getTr_no()) && !helperBean.isStringInt(treeAddBean.getTr_no()) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="A Seq number must be an Integer." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <% boolean seq_exists = false; %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select trees.tr_no
        from si_d, trees
        where si_d.site_ref = '<%= recordBean.getSite_ref() %>'
        and   si_d.item_ref = '<%= trees_item %>'
        and   si_d.feature_ref = '<%= trees_feature %>'
        and   si_d.contract_ref = '<%= trees_contract %>'
        and   si_d.detail_ref = trees.tree_ref
        and   trees.tr_no = <%= treeAddBean.getTr_no() %>
      </sql:query>
      <sql:resultSet id="rset">
      </sql:resultSet>
      <sql:wasNotEmpty>
        <% seq_exists = true; %>
      </sql:wasNotEmpty>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- The seq/tr_no cannot already exist. --%>
    <if:IfTrue cond='<%= seq_exists %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="The supplied Seq number is already assigned to a tree on this road." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isValid(treeAddBean.getPosition_ref()) && !helperBean.isStringInt(treeAddBean.getPosition_ref()) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="A Pos Ref number must be an Integer." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getFrequency()) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="A Frequency must be supplied." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isValid(treeAddBean.getView_next_due()) && ! helperBean.isValidDateString(treeAddBean.getView_next_due(), application.getInitParameter("view_date_fmt")) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="The Next Due date is not a valid date." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isValid(treeAddBean.getView_next_due()) && helperBean.isDateBeforeToday(treeAddBean.getView_next_due(), application.getInitParameter("view_date_fmt")) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="The Next Due date cannot be in the past ." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isValid(treeAddBean.getView_next_due()) && helperBean.isDateAfter(treeAddBean.getView_next_due(), application.getInitParameter("view_date_fmt"), 60) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="The Next Due date cannot be more than 60 years in the future." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getSpecies_ref()) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="A Species must be supplied." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getAge_ref()) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="An Age must be supplied." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getCrown_ref()) %>' >
      <app:equalsInitParameter name="sutton_tree_fields" match="Y">
        <jsp:setProperty name="treeAddBean" property="error"
          value="A Spread must be supplied." />
      </app:equalsInitParameter>
      <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
        <jsp:setProperty name="treeAddBean" property="error"
          value="A Crown must be supplied." />
      </app:equalsInitParameter>
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getHeight_ref()) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="A Height must be supplied." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getCondition_ref()) %>' >
      <app:equalsInitParameter name="sutton_tree_fields" match="Y">
        <jsp:setProperty name="treeAddBean" property="error"
          value="Cond P/S  must be supplied." />
      </app:equalsInitParameter>
      <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
        <jsp:setProperty name="treeAddBean" property="error"
          value="Cond must be supplied." />
      </app:equalsInitParameter>
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getDbh_ref()) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="A DBH must be supplied." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getVigour_ref()) %>' >
      <app:equalsInitParameter name="sutton_tree_fields" match="Y">
        <jsp:setProperty name="treeAddBean" property="error"
          value="Life must be supplied." />
      </app:equalsInitParameter>
      <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
        <jsp:setProperty name="treeAddBean" property="error"
          value="Vigour must be supplied." />
      </app:equalsInitParameter>
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getPavement_ref()) %>' >
      <app:equalsInitParameter name="sutton_tree_fields" match="Y">
        <jsp:setProperty name="treeAddBean" property="error"
          value="A Base Type must be supplied." />
      </app:equalsInitParameter>
      <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
        <jsp:setProperty name="treeAddBean" property="error"
          value="Paving must be supplied." />
      </app:equalsInitParameter>
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <%-- Only mandatory if the sutton_tree_fields web.xml parameter is not 'Y' --%>
    <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
      <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getBoundary_ref()) %>' >
        <jsp:setProperty name="treeAddBean" property="error"
          value="A Boundary must be supplied." />
        <jsp:forward page="treeAddView.jsp" />
      </if:IfTrue>

      <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getBuilding_ref()) %>' >
        <jsp:setProperty name="treeAddBean" property="error"
          value="A Building must be supplied." />
        <jsp:forward page="treeAddView.jsp" />
      </if:IfTrue>
    </app:equalsInitParameter>

    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getIssue_ref()) %>' >
      <jsp:setProperty name="treeAddBean" property="error"
        value="An Issue must be supplied." />
      <jsp:forward page="treeAddView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Translate the View_next_due date into the Next_due date format --%>
    <if:IfTrue cond='<%= helperBean.isValid(treeAddBean.getView_next_due()) %>' >
    <%
      TimeZone dtz = TimeZone.getTimeZone("Europe/London");
      TimeZone.setDefault(dtz);

      SimpleDateFormat formatViewDate = new SimpleDateFormat(application.getInitParameter("view_date_fmt"));
      SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));

      Date viewDate = formatViewDate.parse(treeAddBean.getView_next_due());
      treeAddBean.setNext_due(formatDbDate.format(viewDate));
    %>
    </if:IfTrue>
    <if:IfTrue cond='<%= helperBean.isNotValid(treeAddBean.getView_next_due()) %>' >
      <% treeAddBean.setNext_due(""); %>
    </if:IfTrue>

    <%-- update tree --%>
    <sess:setAttribute name="form">addUpdateTreeFunc</sess:setAttribute>
    <c:import url="addUpdateTreeFunc.jsp" var="webPage" />
    <% helperBean.throwException("addUpdateTreeFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Need to refresh the text so that the user sees any text they have just added in the --%>
    <%-- greyed out none editable section, and clear out the text that they just added. --%>

    <%-- Give a message to indicate that the tree has been added --%>
    <jsp:setProperty name="treeAddBean" property="error"
        value="The tree has been ADDED." /> 

    <sess:setAttribute name="form">treeAdd</sess:setAttribute>
    <jsp:forward page="treeAddView.jsp" />
  </if:IfTrue>
  
  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= treeAddBean.getAction().equals("Item") %>' >
    <%-- Invalid entry --%>
    <%-- NONE --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treeAdd</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">itemLookup</sess:setAttribute>
    <c:redirect url="itemLookupScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= treeAddBean.getAction().equals("GPS") %>' >
    <%-- Invalid entry --%>
    <%-- NONE --%>

    <%-- Valid entry --%>
    <if:IfTrue cond='<%= ! treeAddBean.getGpsLat().trim().equals("") && ! treeAddBean.getGpsLng().trim().equals("") %>' >
      <%
        double lat = (new Double(treeAddBean.getGpsLat())).doubleValue();
        double lng = (new Double(treeAddBean.getGpsLng())).doubleValue();

        String estNth = mappingUtils.LatLngToOSRef(lat, lng);

        StringTokenizer stEN = new StringTokenizer(estNth, ",");
        double newE = (new Double(stEN.nextToken())).doubleValue();
        newE = helperBean.roundDouble(newE, 2);
        double newN = (new Double(stEN.nextToken())).doubleValue();
        newN = helperBean.roundDouble(newN, 2);

        treeAddBean.setEasting(String.valueOf(newE));
        treeAddBean.setNorthing(String.valueOf(newN));
      %>
    </if:IfTrue>

    <jsp:forward page="treeAddView.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= treeAddBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treeAdd</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= treeAddBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treeAdd</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= treeAddBean.getAction().equals("Back") %>' >
    <% recordBean.setAction_flag(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treeAdd</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= treeAddBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${treeAddBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="treeAddView.jsp" />
