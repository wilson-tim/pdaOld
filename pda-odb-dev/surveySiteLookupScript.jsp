<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveySiteLookupBean, com.vsb.recordBean, com.vsb.surveySiteSearchBean, com.vsb.systemKeysBean" %>
<%@ page import="com.db.*, javax.sql.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="surveySiteLookupBean" scope="session" class="com.vsb.surveySiteLookupBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="surveySiteSearchBean" scope="session" class="com.vsb.surveySiteSearchBean" />
<jsp:useBean id="surveyPageSet" scope="session" class="com.db.PageSet" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveySiteLookup" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="surveySiteLookup" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="surveySiteLookupBean" property="all" value="clear" />
    <jsp:setProperty name="surveySiteLookupBean" property="*" />

		<%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="bv_site_ref" value='<%=surveySiteLookupBean.getSite_ref()%>' />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="surveySiteLookupBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="surveySiteSearch" >
  <jsp:setProperty name="surveySiteLookupBean" property="action" value="" />
  <jsp:setProperty name="surveySiteLookupBean" property="all" value="clear" />
  <jsp:setProperty name="surveySiteLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>
<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="inspList" >
  <jsp:setProperty name="surveySiteLookupBean" property="action" value="" />
  <jsp:setProperty name="surveySiteLookupBean" property="all" value="clear" />
  <jsp:setProperty name="surveySiteLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Populate the pageSet for use in the VIEW, but only the first time through the SCRIPT --%>
<sess:equalsAttribute name="input" match="surveySiteLookup" value="false">
  <sess:equalsAttribute name="input" match="surveySiteSearch">

		<sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
			<sql:statement id="stmt" conn="con1">
				
					<%-- Get Item_ref --%>
					<sql:query>
						select c_field
						from keys
						where keyname = 'BV199_ITEM'
					</sql:query>
					<sql:resultSet id="rset">
						<sql:getColumn position="1" to="item_ref" />
					</sql:resultSet>
		
			</sql:statement>
		<sql:closeConnection conn="con1"/>

    <%-- set the number of records per page --%>
    <% surveyPageSet.setRecordsOnPage(20); %>

    <%-- Connect to the database using the context and datasource --%>
    <% DbSQL connection = new DbSQL(); %>
    <% connection.connect("java:comp/env", "jdbc/pda"); %>

    <%-- SET UP QUERY TO FIND ALL MATCHING ROADS --%>
    <% boolean use_supersites = true; %>
    <%
      if (systemKeysBean.getContender_version().equals("v7")) {
        use_supersites = true;
      } else if (systemKeysBean.getContender_version().equals("v8")) {
      	if (systemKeysBean.getGenerate_supersites().equals("Y")) {
          use_supersites = true;
      	} else if (systemKeysBean.getGenerate_supersites().equals("N")) {
      		use_supersites = false;
      	}
      }
    %>
    <% String queryString = ""; %>
    <if:IfTrue cond='<%= use_supersites == true %>' >
      <%
        queryString = 
        "select site.site_ref, site_name_1 " +
        "from site, si_i " +
        "where site_status = 'L' " +
        "and   site.site_ref like '%S' "+
				"and 	 site.site_ref = si_i.site_ref " +
				"and 	 si_i.item_ref = '" + ((String)pageContext.getAttribute("item_ref")).trim()  + "'";
      %>
    </if:IfTrue>
    <if:IfTrue cond='<%= use_supersites == false %>' >
      <%
        queryString = 
          "select site.site_ref, site_name_1 " +
          "from site, si_i " +
          "where site_status = 'L' " +
          "and   site_c = 'S' " +
				"and 	 site.site_ref = si_i.site_ref " +
				"and 	 si_i.item_ref = '" + ((String)pageContext.getAttribute("item_ref")).trim()  + "'";
      %>
    </if:IfTrue>

    <%-- Use the location_name to find the location_c if the user typed in a location --%>
    <if:IfTrue cond='<%= !(surveySiteSearchBean.getSurveyLocation().equals("")) %>' >
      <%
        queryString = queryString +
          "and   location_c IN " +
          "  (select location_c " +
          "  from locn " +
          "  where location_name like '" + surveySiteSearchBean.getSurveyLocation().toUpperCase() + "') ";
      %>
    </if:IfTrue>
    <%-- Use the postcode to find the site_ref if the user typed in a postcode --%>
    <if:IfTrue cond='<%= !(surveySiteSearchBean.getSurveyPostCode().equals("")) %>' >
      <%
        queryString = queryString +
          "and location_c IN" +
          " (select location_c " +
          " from site " +
          " where postcode like '" + surveySiteSearchBean.getSurveyPostCode().toUpperCase() + "') ";
       %>
    </if:IfTrue>
    <% queryString = queryString + " order by site_name_1"; %>

    <%-- Run a query for roads --%>
    <% java.sql.ResultSet rs = connection.query(queryString); %>
    <%-- populate the PageSet from the ResultSet --%>
    <% surveyPageSet.setPageSet(rs, application.getInitParameter("db_date_fmt")); %>

    <%-- SET UP QUERY TO FIND ALL MATCHING ROAD SECTIONS --%>
    <if:IfTrue cond='<%= use_supersites == true %>' >
      <%
      queryString =
        "select site.site_ref, site_name_1 " +
        "from site, si_i " +
        "where site_status = 'L' " +
        "and   site.site_ref like '%G' "+
				"and 	 site.site_ref = si_i.site_ref " +
				"and 	 si_i.item_ref = '" + ((String)pageContext.getAttribute("item_ref")).trim()  + "'";
      %>
    </if:IfTrue>
    <if:IfTrue cond='<%= use_supersites == false %>' >
      <%
        queryString = 
          "select site.site_ref, site_name_1 " +
          "from site, si_i " +
          "where site_status = 'L' " +
          "and   site_c = 'G' " +
				"and 	 site.site_ref = si_i.site_ref " +
				"and 	 si_i.item_ref = '" + ((String)pageContext.getAttribute("item_ref")).trim()  + "'";
      %>
    </if:IfTrue>

    <%-- Use the location_name to find the location_c if the user typed in a location --%>
    <if:IfTrue cond='<%= !(surveySiteSearchBean.getSurveyLocation().equals("")) %>' >
      <%
        queryString = queryString +
          "and   location_c IN " +
          "  (select location_c " +
          "  from locn " +
          "  where location_name like '" + surveySiteSearchBean.getSurveyLocation().toUpperCase() + "') ";
      %>
    </if:IfTrue>
    <%-- Use the postcode to find the site_ref if the user typed in a postcode --%>
    <if:IfTrue cond='<%= !(surveySiteSearchBean.getSurveyPostCode().equals("")) %>' >
      <%
        queryString = queryString +
          "and location_c IN" +
          " (select location_c " +
          " from site " +
          " where postcode like '" + surveySiteSearchBean.getSurveyPostCode().toUpperCase() + "') ";
      %>
    </if:IfTrue>
    <% queryString = queryString + " order by site_name_1"; %>

    <%-- Run a query for road sections--%>
    <% rs = connection.query(queryString); %>
    <%-- populate the PageSet from the ResultSet --%>
    <% surveyPageSet.addToPageSet(rs, application.getInitParameter("db_date_fmt")); %>

    <%-- close the ResultSet and disconnect from the database --%>
    <% rs.close(); %>
    <% connection.disconnect(); %>
  </sess:equalsAttribute>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="surveySiteLookup" >

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= surveySiteLookupBean.getAction().equals("|<<") %>' >
    <% surveyPageSet.first(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="surveySiteLookupView.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= surveySiteLookupBean.getAction().equals(">>|") %>' >
    <% surveyPageSet.last(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="surveySiteLookupView.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= surveySiteLookupBean.getAction().equals(" < ") %>' >
    <% surveyPageSet.previous(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="surveySiteLookupView.jsp" />
  </if:IfTrue>

  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= surveySiteLookupBean.getAction().equals(" > ") %>' >
    <% surveyPageSet.next(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="surveySiteLookupView.jsp" />
  </if:IfTrue>
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= surveySiteLookupBean.getAction().equals("Transect") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=surveySiteLookupBean.getSite_ref() == null || surveySiteLookupBean.getSite_ref().equals("") %>' >
      <jsp:setProperty name="surveySiteLookupBean" property="error"
        value="Please choose a site." />
      <jsp:forward page="surveySiteLookupView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- get the site name --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select site_name_1, location_c, postcode, build_no, build_sub_no,
          build_no_disp, build_sub_no_disp, build_name, build_sub_name, area_c, ward_code
        from site
        where site_ref = '<%= recordBean.getBv_site_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="bv_site_name_1" />
        <% recordBean.setBv_site_name_1((String) pageContext.getAttribute("bv_site_name_1")); %>
        <sql:getColumn position="2" to="bv_location_c" />
        <% recordBean.setBv_location_c((String) pageContext.getAttribute("bv_location_c")); %>
        <sql:getColumn position="3" to="bv_postcode" />
        <% recordBean.setBv_postcode((String) pageContext.getAttribute("bv_postcode")); %>
        <sql:getColumn position="4" to="bv_build_no" />
        <% recordBean.setBv_build_no((String) pageContext.getAttribute("bv_build_no")); %>
        <sql:getColumn position="5" to="bv_build_sub_no" />
        <% recordBean.setBv_build_sub_no((String) pageContext.getAttribute("bv_build_sub_no")); %>
        <sql:getColumn position="6" to="bv_build_no_disp" />
        <sql:getColumn position="7" to="bv_build_sub_no_disp" />

        <sql:getColumn position="8" to="bv_build_name" />
        <% recordBean.setBv_build_name((String) pageContext.getAttribute("bv_build_name")); %>
        <if:IfTrue cond='<%= recordBean.getBv_build_name() == null || recordBean.getBv_build_name().equals("") %>' >
          <% recordBean.setBv_build_name(""); %>
        </if:IfTrue>

        <sql:getColumn position="9" to="bv_build_sub_name" />
        <% recordBean.setBv_build_sub_name((String) pageContext.getAttribute("bv_build_sub_name")); %>
        <if:IfTrue cond='<%= recordBean.getBv_build_name() == null || recordBean.getBv_build_name().equals("") %>' >
          <% recordBean.setBv_build_sub_name(""); %>
        </if:IfTrue>

        <sql:getColumn position="10" to="bv_area_c" />
        <sql:wasNull>
          <% pageContext.setAttribute("bv_area_c", ""); %>
        </sql:wasNull>

        <sql:getColumn position="11" to="bv_ward_code" />
        <sql:wasNull>
          <% pageContext.setAttribute("bv_ward_code", ""); %>
        </sql:wasNull>
      </sql:resultSet>

      <%-- Are the recordBean.build_no and recordBean.build_sub_no, the display --%>
      <%-- version or the normal version. --%>
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'COMP_BUILD_NO_DISP'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="comp_build_no_disp" />
        <sql:wasNull>
          <% pageContext.setAttribute("comp_build_no_disp", "N"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("comp_build_no_disp", "N"); %>
      </sql:wasEmpty>

      <if:IfTrue cond='<%= ((String) pageContext.getAttribute("comp_build_no_disp")).trim().equals("Y") %>' >
        <% recordBean.setBv_build_no((String) pageContext.getAttribute("bv_build_no_disp")); %>
        <% recordBean.setBv_build_sub_no((String) pageContext.getAttribute("bv_build_sub_no_disp")); %>
      </if:IfTrue>

      <%-- setup the area or ward of the address field -->
      <%-- a "Y" means to use the area and a "N" means to use ward --%>
      <sql:query>
        select c_field
        from keys
        where keyname = 'DISP_WARD_OR_AREA'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
      </sql:resultSet>

      <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("Y") %>' >
        <sql:query>
          select area_name
          from area
          where area_c = '<%= ((String)pageContext.getAttribute("bv_area_c")).trim() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="bv_area_name" />
          <sql:wasNotNull>
            <% recordBean.setBv_area_ward_desc((String) pageContext.getAttribute("bv_area_name")); %>
          </sql:wasNotNull>
          <sql:wasNull>
            <% recordBean.setBv_area_ward_desc(""); %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% recordBean.setBv_area_ward_desc(""); %>
        </sql:wasEmpty>
      </if:IfTrue>

      <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("N") %>' >
        <sql:query>
          select ward_name
          from ward
          where ward_code = '<%= ((String)pageContext.getAttribute("bv_ward_code")).trim() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="bv_ward_name" />
          <sql:wasNotNull>
            <% recordBean.setBv_area_ward_desc((String) pageContext.getAttribute("bv_ward_name")); %>
          </sql:wasNotNull>
          <sql:wasNull>
            <% recordBean.setBv_area_ward_desc(""); %>
          </sql:wasNull>
        </sql:resultSet>
        <sql:wasEmpty>
          <% recordBean.setBv_area_ward_desc(""); %>
        </sql:wasEmpty>
      </if:IfTrue>

      <%-- Get the location name and code and store it in the record bean --%>
      <sql:query>
        select location_name
        from locn
        where location_c = '<%= recordBean.getBv_location_c() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="bv_location_name" />
        <% recordBean.setBv_location_name((String) pageContext.getAttribute("bv_location_name")); %>
      </sql:resultSet>

    	<sql:query>
    		select count(transect_ref)
    		from bv_transect
    		where site_ref = '<%= recordBean.getBv_site_ref() %>'
    	</sql:query>
    	<sql:resultSet id="rset">
    		<sql:getColumn position="1" to="tran_count" />
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("tran_count")).trim().equals("0") %>'>
			<%-- Indicate which form we are coming from when we forward to another form --%>
			<sess:setAttribute name="previousForm">surveySiteLookup</sess:setAttribute>
			<%-- Indicate which form we are going to next --%>
			<sess:setAttribute name="form">surveyExisting</sess:setAttribute>
			<c:redirect url="surveyExistingScript.jsp" />
    </if:IfTrue>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveySiteLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">surveyTransectMethod</sess:setAttribute>
    <c:redirect url="surveyTransectMethodScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveySiteLookupBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveySiteLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveySiteLookupBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveySiteLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= surveySiteLookupBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveySiteLookupBean</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= surveySiteLookupBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${surveySiteLookupBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="surveySiteLookupView.jsp" />
