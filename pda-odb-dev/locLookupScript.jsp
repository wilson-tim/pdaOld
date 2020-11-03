<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.locLookupBean, com.vsb.recordBean, com.vsb.schedOrCompBean, com.vsb.systemKeysBean" %>
<%@ page import="com.db.*, javax.sql.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="locLookupBean" scope="session" class="com.vsb.locLookupBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="schedOrCompBean" scope="session" class="com.vsb.schedOrCompBean" />
<jsp:useBean id="locLookupPageSet" scope="session" class="com.db.PageSet" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="locLookup" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="locLookup" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="locLookupBean" property="all" value="clear" />
    <jsp:setProperty name="locLookupBean" property="*" />

    <%-- Add the new values to the record --%>
    <%-- If have selected a trade site, get the site_ref from the site_no --%>
    <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Trade") %>'>
      <if:IfTrue cond='<%= locLookupBean.getAction().equals("Agreement")
                           || locLookupBean.getAction().equals("Detail") %>'>        
        <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
          <sql:statement id="stmt" conn="con">
            <sql:query>
              SELECT site_ref
              FROM trade_site
              WHERE site_no = '<%= locLookupBean.getSite_ref() %>'
            </sql:query>
            <sql:resultSet id="rset0">
              <sql:getColumn position="1" to="site_ref" />
              <% recordBean.setSite_ref((String) pageContext.getAttribute("site_ref")); %>
            </sql:resultSet>
          </sql:statement>
        <sql:closeConnection conn="con"/>
      </if:IfTrue>
    </if:IfTrue>
    <%-- If not a trade site, the site_ref is already the site_ref --%>
    <if:IfTrue cond='<%= ! schedOrCompBean.getAction().equals("Trade") %>'>
      <jsp:setProperty name="recordBean" property="site_ref" param="site_ref" />
    </if:IfTrue>
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="locLookupBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="schedOrComp" >
  <jsp:setProperty name="locLookupBean" property="action" value="" />
  <jsp:setProperty name="locLookupBean" property="all" value="clear" />
  <jsp:setProperty name="locLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Populate the loclookupPageSet for use in the VIEW, but only the first time through the SCRIPT --%>
<sess:equalsAttribute name="input" match="locLookup" value="false">
  <sess:equalsAttribute name="input" match="schedOrComp">
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
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

      <% recordBean.setBuild_no_string("build_no"); %>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("comp_build_no_disp")).trim().equals("Y") %>' >
        <% recordBean.setBuild_no_string("build_no_disp"); %>
      </if:IfTrue>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- set the number of records per page --%>
    <% locLookupPageSet.setRecordsOnPage(20); %>

    <%-- Declare the query string variable --%>
    <% String queryString = ""; %>

    <%-- Declare the result set variable --%>
    <% java.sql.ResultSet rs = null; %>    
    
    <%-- Connect to the database using the context and datasource --%>
    <% DbSQL connection = new DbSQL(); %>
    <% connection.connect("java:comp/env", "jdbc/pda"); %>

    <%-- Do the super sites check for which method of super site search we are using --%>
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

    <%-- IF THIS IS A PROPERTY SEARCH WE NEED TO CHECK FOR ROAD SECTIONS,
         AND ROADS. THIS IS NOT THE CASE FOR A TRADE SEARCH, WHICH WILL SEARCH
         THROUGH TRADE SITES, AND THEN LINKS TO THE SITES TABLE, WITH A SITE_REF --%>
    <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Property") ||
                         schedOrCompBean.getAction().equals("Search") %>'>             
      <%-- SET UP QUERY TO FIND ALL MATCHING ROADS --%>
      <if:IfTrue cond='<%= use_supersites == true %>' >
        <%
          queryString =
            "select site_ref, site_name_1 " +
            "from site " +
            "where site_status = 'L' " +
            "and   site_ref like '%S' ";
        %>
      </if:IfTrue>
      <if:IfTrue cond='<%= use_supersites == false %>' >
        <%
          queryString =
            "select site_ref, site_name_1 " +
            "from site " +
            "where site_status = 'L' " +
            "and   site_c = 'S' ";
        %>
      </if:IfTrue>
      <%-- Use the build_no to find the site_ref if the user typed in a House No. --%>
      <if:IfTrue cond='<%= !(schedOrCompBean.getWardenHouseNo().equals("")) %>' >
        <%
          queryString = queryString +
            "and   " + recordBean.getBuild_no_string() + " like '" + schedOrCompBean.getWardenHouseNo().toUpperCase() + "' ";
        %>
      </if:IfTrue>
      <%-- Use the build_name to find the site_ref if the user typed in a Building Name --%>
      <if:IfTrue cond='<%= !(schedOrCompBean.getWardenBuildingName().equals("")) %>' >
        <%
          queryString = queryString +
            "and   (build_name like '" + schedOrCompBean.getWardenBuildingName().toUpperCase() + "' " +
               "or build_sub_name like '" + schedOrCompBean.getWardenBuildingName().toUpperCase() + "') ";
        %>
      </if:IfTrue>
      <%-- Use the location_name to find the location_c if the user typed in a location --%>
      <if:IfTrue cond='<%= !(schedOrCompBean.getWardenLoc().equals("")) %>' >
        <%
          queryString = queryString +
            "and   location_c IN " +
            "  (select location_c " +
            "  from locn " +
            "  where location_name like '" + schedOrCompBean.getWardenLoc().toUpperCase() + "') ";
        %>
      </if:IfTrue>
      <%-- Use the postcode to find the site_ref if the user typed in a postcode --%>
      <if:IfTrue cond='<%= !(schedOrCompBean.getWardenPostCode().equals("")) %>' >
        <%
          queryString = queryString +
            "and   postcode like '" + schedOrCompBean.getWardenPostCode().toUpperCase() + "' ";
        %>
      </if:IfTrue>
      <% queryString = queryString + " order by site_name_1"; %>
  
      <%-- Run a query for roads --%>
      <% rs = connection.query(queryString); %>
      <%-- populate the PageSet from the ResultSet --%>
      <% locLookupPageSet.setPageSet(rs, application.getInitParameter("db_date_fmt")); %>
  
      <%-- SET UP QUERY TO FIND ALL MATCHING ROAD SECTIONS --%>
      <if:IfTrue cond='<%= use_supersites == true %>' >
        <%
          queryString =
            "select site_ref, site_name_1 " +
            "from site " +
            "where site_status = 'L' " +
            "and   site_ref like '%G' ";
        %>
      </if:IfTrue>
      <if:IfTrue cond='<%= use_supersites == false %>' >
        <%
          queryString =
            "select site_ref, site_name_1 " +
            "from site " +
            "where site_status = 'L' " +
            "and   site_c = 'G' ";
        %>
      </if:IfTrue>
      <%-- Use the build_no to find the site_ref if the user typed in a House No. --%>
      <if:IfTrue cond='<%= !(schedOrCompBean.getWardenHouseNo().equals("")) %>' >
        <%
          queryString = queryString +
            "and   " + recordBean.getBuild_no_string() + " like '" + schedOrCompBean.getWardenHouseNo().toUpperCase() + "' ";
        %>
      </if:IfTrue>
      <%-- Use the build_name to find the site_ref if the user typed in a Building Name --%>
      <if:IfTrue cond='<%= !(schedOrCompBean.getWardenBuildingName().equals("")) %>' >
        <%
          queryString = queryString +
            "and   (build_name like '" + schedOrCompBean.getWardenBuildingName().toUpperCase() + "' " +
               "or build_sub_name like '" + schedOrCompBean.getWardenBuildingName().toUpperCase() + "') ";
        %>
      </if:IfTrue>
      <%-- Use the location_name to find the location_c if the user typed in a location --%>
      <if:IfTrue cond='<%= !(schedOrCompBean.getWardenLoc().equals("")) %>' >
        <%
          queryString = queryString +
            "and   location_c IN " +
            "  (select location_c " +
            "  from locn " +
            "  where location_name like '" + schedOrCompBean.getWardenLoc().toUpperCase() + "') ";
        %>
      </if:IfTrue>
      <%-- Use the postcode to find the site_ref if the user typed in a postcode --%>
      <if:IfTrue cond='<%= !(schedOrCompBean.getWardenPostCode().equals("")) %>' >
        <%
          queryString = queryString +
            "and   postcode like '" + schedOrCompBean.getWardenPostCode().toUpperCase() + "' ";
        %>
      </if:IfTrue>
      <% queryString = queryString + " order by site_name_1"; %>
  
      <%-- Run a query for road sections--%>
      <% rs = connection.query(queryString); %>
      <%-- populate the PageSet from the ResultSet --%>
      <% locLookupPageSet.addToPageSet(rs, application.getInitParameter("db_date_fmt")); %>
    </if:IfTrue>

    <%-- SET UP QUERY TO FIND ALL MATCHING SITES --%>
    <%-- THIS COULD ALSO BE FOR A TRADE SITE SEARCH,
         in which case the first part of the query will 
         have to be changed --%>
    <%-- If this is a PROPERTY search --%>
    <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Property") ||
                         schedOrCompBean.getAction().equals("Search") %>'>    
      <if:IfTrue cond='<%= use_supersites == true %>' >
        <%
          queryString =
            "select site.site_ref, site.site_name_1 " +
            "from site " +
            "where site.site_status = 'L' " +
            "and   site.site_ref not like '%S' " +
            "and   site.site_ref not like '%G' ";
        %>
      </if:IfTrue>
      <if:IfTrue cond='<%= use_supersites == false %>' >
        <%
          queryString =
            "select site.site_ref, site.site_name_1 " +
            "from site " +
            "where site.site_status = 'L' " +
            "and   site.site_c = 'P' ";
        %>
      </if:IfTrue>
    </if:IfTrue>
    <%-- If this is a TRADE search --%>
    <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Trade")%>'>    
      <%
        queryString =
          "SELECT trade_site.site_no, site.site_name_1, trade_site.ta_name, trade_site.site_name " +
          "FROM trade_site, site " +
          "WHERE trade_site.site_ref = site.site_ref " +
          "AND trade_site.status_ref = 'R' ";
      %>
      <%-- Use the trade name to find the site_ref if the user typed in a trade name --%>
      <if:IfTrue cond='<%= !(schedOrCompBean.getBusinessName().equals("") ||
                            schedOrCompBean.getBusinessName() == null) %>'>
        <%
        queryString +=
          "AND trade_site.ta_name LIKE '" + schedOrCompBean.getBusinessName().toUpperCase() + "' ";
        %>
      </if:IfTrue>
    </if:IfTrue>
    
    <%-- Use the build_no to find the site_ref if the user typed in a House No. --%>
    <if:IfTrue cond='<%= !(schedOrCompBean.getWardenHouseNo().equals("")) %>' >
      <%
        queryString = queryString +
          "and   " + recordBean.getBuild_no_string() + " like '" + schedOrCompBean.getWardenHouseNo().toUpperCase() + "' ";
      %>
    </if:IfTrue>
    <%-- Use the build_name to find the site_ref if the user typed in a Building Name --%>
    <if:IfTrue cond='<%= !(schedOrCompBean.getWardenBuildingName().equals("")) %>' >
      <%
        queryString = queryString +
          "and   (site.build_name like '" + schedOrCompBean.getWardenBuildingName().toUpperCase() + "' " +
             "or site.build_sub_name like '" + schedOrCompBean.getWardenBuildingName().toUpperCase() + "') ";
      %>
    </if:IfTrue>
    <%-- Use the location_name to find the location_c if the user typed in a location --%>
    <if:IfTrue cond='<%= !(schedOrCompBean.getWardenLoc().equals("")) %>' >
      <%
        queryString = queryString +
          "and   site.location_c IN " +
          "  (select location_c " +
          "  from locn " +
          "  where location_name like '" + schedOrCompBean.getWardenLoc().toUpperCase() + "') ";
      %>
    </if:IfTrue>
    <%-- Use the postcode to find the site_ref if the user typed in a postcode --%>
    <if:IfTrue cond='<%= !(schedOrCompBean.getWardenPostCode().equals("")) %>' >
      <%
        queryString = queryString +
          "and   site.postcode like '" + schedOrCompBean.getWardenPostCode().toUpperCase() + "' ";
      %>
    </if:IfTrue>
    <%-- If this is a PROPERTY Search, we continue adding to the Page Set --%>
    <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Property") ||
                         schedOrCompBean.getAction().equals("Search") %>'>        
      <% queryString = queryString + " order by site_name_1"; %>
      <%-- Run a query for sites--%>
      <% rs = connection.query(queryString); %>
      <%-- populate the PageSet from the ResultSet --%>
      <% locLookupPageSet.addToPageSet(rs, application.getInitParameter("db_date_fmt")); %>    
    </if:IfTrue>
    <%-- If this is a TRADE Search, we are populating a new Page Set --%>
    <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Trade")%>'>
      <%-- User has queried with a Business name --%>
      <if:IfTrue cond='<%= ! schedOrCompBean.getBusinessName().equals("") %>' >        
        <% queryString = queryString + " order by trade_site.ta_name"; %>
      </if:IfTrue>
      <%-- User has not queried with a Business name --%>
      <if:IfTrue cond='<%= schedOrCompBean.getBusinessName().equals("") %>' >        
        <% queryString = queryString + " order by site.site_name_1, trade_site.ta_name"; %>
      </if:IfTrue>
      <%-- Run a query for trade sites --%>
      <% rs = connection.query(queryString); %>
      <%-- populate the PageSet from the ResultSet --%>
      <% locLookupPageSet.setPageSet(rs, application.getInitParameter("db_date_fmt")); %>      
    </if:IfTrue>    

    <%-- close the ResultSet and disconnect from the database --%>
    <% rs.close(); %>
    <% connection.disconnect(); %>
  </sess:equalsAttribute>
</sess:equalsAttribute>

<%-- Skip View Section --%>
<%-- Only allow skip if allowed --%>
<app:equalsInitParameter name="use_property_service_skip" match="Y">
  <%-- if only one record found then skip to the next page, by faking it so that it appears the user --%>
  <%-- has just selected the one item and clicked the next page button. --%>
  <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
  <sess:equalsAttribute name="input" match="schedOrComp" value="false">
    <if:IfTrue cond='<%= locLookupPageSet.getRecordCount() == 1 %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">locLookup</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form"><%= locLookupBean.getSavedPreviousForm() %></sess:setAttribute>
      <c:redirect url="${locLookupBean.savedPreviousForm}Script.jsp" />
    </if:IfTrue>
  </sess:equalsAttribute>
  <%-- Do forwards skip --%>
  <sess:equalsAttribute name="input" match="schedOrComp" >
    <if:IfTrue cond='<%= locLookupPageSet.getRecordCount() == 1 %>' >
      <%-- This section mimics the 'input' section at the top of the script --%>
      <%-- manually imitating a user interaction with the view, but without showing the view --%>
  
      <%-- Indicate which form we are in/just-come-from --%>
      <sess:setAttribute name="input">locLookup</sess:setAttribute>
  
      <%-- Setup the bean with the forms data manually --%>
      <jsp:setProperty name="locLookupBean" property="all" value="clear" />
      <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Trade") %>'>
        <jsp:setProperty name="locLookupBean" property="action" value="Agreement" />
      </if:IfTrue>
      <if:IfTrue cond='<%= ! schedOrCompBean.getAction().equals("Trade") %>'>
        <jsp:setProperty name="locLookupBean" property="action" value="Service" />
      </if:IfTrue>
      <% 
        Page thePage = locLookupPageSet.getCurrentPage();
        thePage.next();
        String site_ref = thePage.getField(1).trim();
        locLookupBean.setSite_ref(site_ref);
      %>
  
      <%-- Add the new values to the record --%>
      <%-- If have selected a trade site, get the site_ref from the site_no --%>
      <if:IfTrue cond='<%= locLookupBean.getAction().equals("Agreement") %>'>        
        <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
          <sql:statement id="stmt" conn="con">
            <sql:query>
              SELECT site_ref
              FROM trade_site
              WHERE site_no = '<%= locLookupBean.getSite_ref() %>'
            </sql:query>
            <sql:resultSet id="rset0">
              <sql:getColumn position="1" to="site_ref" />
              <% recordBean.setSite_ref((String) pageContext.getAttribute("site_ref")); %>
            </sql:resultSet>
          </sql:statement>
        <sql:closeConnection conn="con"/>
      </if:IfTrue>
      <%-- If not a trade site, the site_ref is already the site_ref --%>
      <if:IfTrue cond='<%= ! locLookupBean.getAction().equals("Agreement") %>'> 
        <% recordBean.setSite_ref(locLookupBean.getSite_ref()); %>
      </if:IfTrue>
    </if:IfTrue>
  </sess:equalsAttribute>
</app:equalsInitParameter>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="locLookup" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= locLookupBean.getAction().equals("Service")
                    || locLookupBean.getAction().equals("Agreement")
                    || locLookupBean.getAction().equals("Detail") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=locLookupBean.getSite_ref() == null || locLookupBean.getSite_ref().equals("") %>' >
      <jsp:setProperty name="locLookupBean" property="error"
        value="Please choose a site." />
      <jsp:forward page="locLookupView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= locLookupBean.getAction().equals("Detail") %>' >
      <%
        int last_char = locLookupBean.getSite_ref().length() - 1;
        String check_last = locLookupBean.getSite_ref().substring(last_char);
      %>
      <if:IfTrue cond='<%= check_last.equals("S") || check_last.equals("G")%>'>
        <jsp:setProperty name="locLookupBean" property="error"
          value="You cannot check property details on a Street or Street Section. Please choose a property." />
        <jsp:forward page="locLookupView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- get the site name --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select site_name_1, location_c, postcode, build_no, build_sub_no,
          build_no_disp, build_sub_no_disp, build_name, build_sub_name, area_c, ward_code
        from site
        where site_ref = '<%= recordBean.getSite_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="site_name_1" />
        <% recordBean.setSite_name_1((String) pageContext.getAttribute("site_name_1")); %>
        <sql:getColumn position="2" to="location_c" />
        <% recordBean.setLocation_c((String) pageContext.getAttribute("location_c")); %>
        <sql:getColumn position="3" to="postcode" />
        <% recordBean.setPostcode((String) pageContext.getAttribute("postcode")); %>
        <sql:getColumn position="4" to="build_no" />
        <% recordBean.setBuild_no((String) pageContext.getAttribute("build_no")); %>
        <sql:getColumn position="5" to="build_sub_no" />
        <% recordBean.setBuild_sub_no((String) pageContext.getAttribute("build_sub_no")); %>
        <sql:getColumn position="6" to="build_no_disp" />
        <sql:getColumn position="7" to="build_sub_no_disp" />

        <sql:getColumn position="8" to="build_name" />
        <% recordBean.setBuild_name((String) pageContext.getAttribute("build_name")); %>
        <if:IfTrue cond='<%= recordBean.getBuild_name() == null || recordBean.getBuild_name().equals("") %>' >
          <% recordBean.setBuild_name(""); %>
        </if:IfTrue>

        <sql:getColumn position="9" to="build_sub_name" />
        <% recordBean.setBuild_sub_name((String) pageContext.getAttribute("build_sub_name")); %>
        <if:IfTrue cond='<%= recordBean.getBuild_sub_name() == null || recordBean.getBuild_sub_name().equals("") %>' >
          <% recordBean.setBuild_sub_name(""); %>
        </if:IfTrue>

        <sql:getColumn position="10" to="area_c" />
        <sql:wasNull>
          <% pageContext.setAttribute("area_c", ""); %>
        </sql:wasNull>
        <sql:getColumn position="11" to="ward_code" />
        <sql:wasNull>
          <% pageContext.setAttribute("ward_code", ""); %>
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
        <% recordBean.setBuild_no((String) pageContext.getAttribute("build_no_disp")); %>
        <% recordBean.setBuild_sub_no((String) pageContext.getAttribute("build_sub_no_disp")); %>
      </if:IfTrue>

      <%-- setup the area or ward of the address field --%>
      <%-- a "Y" means to use the area and a "N" means to use ward --%>
      <sql:query>
        select c_field
        from keys
        where keyname = 'DISP_WARD_OR_AREA'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
      </sql:resultSet>

      <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("Y") && 
                           (!((String) pageContext.getAttribute("area_c")).trim().equals("")) %>' >
        <sql:query>
          select area_name
          from area
          where area_c = '<%= ((String)pageContext.getAttribute("area_c")).trim() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="area_name" />
          <% recordBean.setArea_ward_desc((String) pageContext.getAttribute("area_name")); %>
        </sql:resultSet>
      </if:IfTrue>

      <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("N") &&
                           (!((String) pageContext.getAttribute("ward_code")).trim().equals("")) %>' >
        <sql:query>
          select ward_name
          from ward
          where ward_code = '<%= ((String)pageContext.getAttribute("ward_code")).trim() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="ward_code" />
          <% recordBean.setArea_ward_desc((String) pageContext.getAttribute("ward_code")); %>
        </sql:resultSet>
      </if:IfTrue>

      <%-- Get the location name and code and store it in the record bean --%>
      <sql:query>
        select location_name
        from locn
        where location_c = '<%= recordBean.getLocation_c() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="location_name" />
        <% recordBean.setLocation_name((String) pageContext.getAttribute("location_name")); %>
      </sql:resultSet>

      <%-- If we are going to an agreement, get the trade site number and redirect to agreement--%>
      <if:IfTrue cond='<%= locLookupBean.getAction().equals("Agreement") %>'>
        <sql:query>
          SELECT site_no,
                 ta_name,
                 site_name
          FROM trade_site
          WHERE site_no = '<%= locLookupBean.getSite_ref() %>'
        </sql:query>
        <sql:resultSet id="rset9">
          <sql:getColumn position="1" to="trade_site_no" />
          <% recordBean.setTrade_site_no((String) pageContext.getAttribute("trade_site_no")); %>
          <sql:getColumn position="2" to="trade_name" />
          <sql:wasNull>
            <% pageContext.setAttribute("trade_name",""); %>
          </sql:wasNull>
          <sql:getColumn position="3" to="site_name" />
          <sql:wasNull>
            <% pageContext.setAttribute("site_name",""); %>
          </sql:wasNull>
          <if:IfTrue cond='<%= !((String)pageContext.getAttribute("trade_name")).trim().equals("") %>'>
            <% recordBean.setTrade_name((String) pageContext.getAttribute("trade_name")); %>
          </if:IfTrue>
          <if:IfTrue cond='<%= ((String)pageContext.getAttribute("trade_name")).trim().equals("") %>'>
            <% recordBean.setTrade_name((String) pageContext.getAttribute("site_name")); %>
          </if:IfTrue>
        </sql:resultSet>
  
        <sql:query>
          select c_field
          from keys
          where keyname = 'TRADE_SERVICE'
          and   service_c = 'ALL'
        </sql:query>
        <sql:resultSet id="rset5">
          <sql:getColumn position="1" to="trade_service" />
          <% recordBean.setTrade_service((String) pageContext.getAttribute("trade_service")); %>
          <% recordBean.setService_c((String) pageContext.getAttribute("trade_service")); %>
        </sql:resultSet>  
      </if:IfTrue>
    
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <if:IfTrue cond='<%= locLookupBean.getAction().equals("Agreement") %>'>    
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">locLookup</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">agreement</sess:setAttribute>
      <c:redirect url="agreementScript.jsp" />
    </if:IfTrue>      

    <if:IfTrue cond='<%= locLookupBean.getAction().equals("Service") %>'>    
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">locLookup</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">service</sess:setAttribute>
      <c:redirect url="serviceScript.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= locLookupBean.getAction().equals("Detail") %>'>    
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">locLookup</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">propertyDetails</sess:setAttribute>
      <c:redirect url="propertyDetailsScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= locLookupBean.getAction().equals("|<<") %>' >
    <% locLookupPageSet.first(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="locLookupView.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= locLookupBean.getAction().equals(">>|") %>' >
    <% locLookupPageSet.last(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="locLookupView.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= locLookupBean.getAction().equals(" < ") %>' >
    <% locLookupPageSet.previous(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="locLookupView.jsp" />
  </if:IfTrue>

  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= locLookupBean.getAction().equals(" > ") %>' >
    <% locLookupPageSet.next(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="locLookupView.jsp" />
  </if:IfTrue>

  <%-- Next view 6 --%>
  <if:IfTrue cond='<%= locLookupBean.getAction().equals("Collect") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=locLookupBean.getSite_ref() == null || locLookupBean.getSite_ref().equals("") %>' >
      <jsp:setProperty name="locLookupBean" property="error"
        value="Please choose a site." />
      <jsp:forward page="locLookupView.jsp" />
    </if:IfTrue>
    <%
      int last_char = locLookupBean.getSite_ref().length() - 1;
      String check_last = locLookupBean.getSite_ref().substring(last_char);
    %>
    <if:IfTrue cond='<%= check_last.equals("S") || check_last.equals("G")%>'>
      <jsp:setProperty name="locLookupBean" property="error"
        value="You cannot check for collections on a Street or Street Section. Please choose a property." />
      <jsp:forward page="locLookupView.jsp" />
    </if:IfTrue>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">locLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">scheduleCollections</sess:setAttribute>
    <c:redirect url="scheduleCollectionsScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= locLookupBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">locLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= locLookupBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">locLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= locLookupBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">locLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= locLookupBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${locLookupBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="locLookupView.jsp" />
