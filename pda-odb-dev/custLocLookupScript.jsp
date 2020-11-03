<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.custLocLookupBean, com.vsb.recordBean, com.vsb.custLocSearchBean, com.vsb.systemKeysBean" %>
<%@ page import="com.db.*, javax.sql.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="custLocLookupBean" scope="session" class="com.vsb.custLocLookupBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="custLocSearchBean" scope="session" class="com.vsb.custLocSearchBean" />
<jsp:useBean id="custLocLookupPageSet" scope="session" class="com.db.PageSet" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="custLocLookup" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="custLocLookup" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="custLocLookupBean" property="all" value="clear" />
    <jsp:setProperty name="custLocLookupBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="compl_site_ref" param="site_ref" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="custLocLookupBean" property="error" value="" />

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="custLocSearch" >
  <jsp:setProperty name="custLocLookupBean" property="action" value="" />
  <jsp:setProperty name="custLocLookupBean" property="all" value="clear" />
  <jsp:setProperty name="custLocLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Populate the custLocLookupPageSet for use in the VIEW, but only the first time through the SCRIPT --%>
<sess:equalsAttribute name="input" match="custLocLookup" value="false">
  <sess:equalsAttribute name="input" match="custLocSearch">
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
    <% custLocLookupPageSet.setRecordsOnPage(20); %>
    
    <%-- Connect to the database using the context and datasource --%>
    <% DbSQL connection = new DbSQL(); %>
    <% connection.connect("java:comp/env", "jdbc/pda"); %>
    
    <%-- SET UP QUERY TO FIND ALL MATCHING SITES --%>
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
          "select site_ref, site_name_1 " +
          "from site " +
          "where site_status = 'L' " +
          "and   site_ref not like '%S' " +
          "and   site_ref not like '%G' ";
      %>
    </if:IfTrue>
    <if:IfTrue cond='<%= use_supersites == false %>' >
      <%
        queryString = 
          "select site_ref, site_name_1 " +
          "from site " +
          "where site_status = 'L' " +
          "and   site_c = 'P' ";
      %>
    </if:IfTrue>
    <%-- Use the build_no to find the site_ref if the user typed in a House No. --%>
    <if:IfTrue cond='<%= !(custLocSearchBean.getCustomerHouseNo().equals("")) %>' >
      <% 
        queryString = queryString + 
          "and   " + recordBean.getBuild_no_string() + " like '" + custLocSearchBean.getCustomerHouseNo().toUpperCase() + "'";
      %>
    </if:IfTrue>
    <%-- Use the build_name to find the site_ref if the user typed in a Building Name --%>
    <if:IfTrue cond='<%= !(custLocSearchBean.getCustomerBuildingName().equals("")) %>' >
      <%
        queryString = queryString + 
          "and   (build_name like '" + custLocSearchBean.getCustomerBuildingName().toUpperCase() + "'" +
             "or build_sub_name like '" + custLocSearchBean.getCustomerBuildingName().toUpperCase() + "')";
      %>
    </if:IfTrue>
    <%-- Use the location_name to find the location_c if the user typed in a location --%>
    <if:IfTrue cond='<%= !(custLocSearchBean.getCustomerLoc().equals("")) %>' >
      <%
        queryString = queryString +
          "and   location_c IN " +
          "  (select location_c " +
          "  from locn " +
          "  where location_name like '" + custLocSearchBean.getCustomerLoc().toUpperCase() + "')";
      %>
    </if:IfTrue>
    <%-- Use the postcode to find the site_ref if the user typed in a postcode --%>
    <if:IfTrue cond='<%= !(custLocSearchBean.getCustomerPostCode().equals("")) %>' >
      <%
        queryString = queryString +
          "and   postcode like '" + custLocSearchBean.getCustomerPostCode().toUpperCase() + "'";
      %>
    </if:IfTrue>
    <% queryString = queryString + " order by site_name_1"; %>
    
    <%-- Run a query for sites--%>
    <% java.sql.ResultSet rs = connection.query(queryString); %>
    <%-- populate the PageSet from the ResultSet --%>
    <% custLocLookupPageSet.setPageSet(rs, application.getInitParameter("db_date_fmt")); %>
    
    <%-- close the ResultSet and disconnect from the database --%>
    <% rs.close(); %>
    <% connection.disconnect(); %>
  </sess:equalsAttribute>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="custLocLookup" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= custLocLookupBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= custLocLookupBean.getWasEmpty().equals("false") %>' >
      <if:IfTrue cond='<%= custLocLookupBean.getSite_ref() == null || custLocLookupBean.getSite_ref().equals("") %>' >
        <jsp:setProperty name="custLocLookupBean" property="error"
          value="Please choose a site." />
        <jsp:forward page="custLocLookupView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
    
    <if:IfTrue cond='<%= custLocLookupBean.getWasEmpty().equals("true") %>' >
      <if:IfTrue cond='<%= recordBean.getInt_ext_flag().equals("E") %>' >
      
        <%-- Check to make sure that the build no./build name, road and town are filled in --%>
        <if:IfTrue cond='<%= custLocLookupBean.getCompl_build_no().equals("") && custLocLookupBean.getCompl_build_name().equals("") %>' >
          <jsp:setProperty name="custLocLookupBean" property="error"
            value="Please enter building no./building name, street name and town." />
          <jsp:forward page="custLocLookupView.jsp" />
        </if:IfTrue>
        
        <if:IfTrue cond='<%= custLocLookupBean.getCompl_addr2().equals("") %>' >
          <jsp:setProperty name="custLocLookupBean" property="error"
            value="Please enter building no./building name, street name and town." />
          <jsp:forward page="custLocLookupView.jsp" />
        </if:IfTrue>
        
        <if:IfTrue cond='<%= custLocLookupBean.getCompl_addr4().equals("") %>' >
          <jsp:setProperty name="custLocLookupBean" property="error"
            value="Please enter building no./building name, street name and town." />
          <jsp:forward page="custLocLookupView.jsp" />
        </if:IfTrue>
        
      </if:IfTrue>
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= custLocLookupBean.getWasEmpty().equals("false") %>' >
      <%-- get the required fields --%>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <%-- retrieve information from the site --%>
        <sql:query>
          select location_c, build_no, build_sub_no, build_name, build_sub_name, postcode, area_c, ward_code
          from site
          where site_ref = '<%= recordBean.getCompl_site_ref() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="location_c" />
          <% recordBean.setCompl_location_c((String) pageContext.getAttribute("location_c")); %>
          <sql:getColumn position="2" to="build_no" />
          <% recordBean.setCompl_build_no((String) pageContext.getAttribute("build_no")); %>
          <sql:getColumn position="3" to="build_sub_no" />
          <% recordBean.setCompl_build_sub_no((String) pageContext.getAttribute("build_sub_no")); %>
          
          <sql:getColumn position="4" to="build_name" />
          <% recordBean.setCompl_build_name((String) pageContext.getAttribute("build_name")); %>
          <if:IfTrue cond='<%= recordBean.getCompl_build_name() == null || recordBean.getCompl_build_name().equals("") %>' >
            <% recordBean.setCompl_build_name(""); %>
          </if:IfTrue>
          
          <sql:getColumn position="5" to="build_sub_name" />
          <% recordBean.setCompl_build_sub_name((String) pageContext.getAttribute("build_sub_name")); %>
          <if:IfTrue cond='<%= recordBean.getCompl_build_sub_name() == null || recordBean.getCompl_build_sub_name().equals("") %>' >
            <% recordBean.setCompl_build_sub_name(""); %>
          </if:IfTrue>
          
          <sql:getColumn position="6" to="postcode" />
          <% recordBean.setCompl_postcode((String) pageContext.getAttribute("postcode")); %>
          <sql:getColumn position="7" to="area_c" />
          <sql:getColumn position="8" to="ward_code" />
        </sql:resultSet>
        
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
          <if:IfTrue cond='<%= pageContext.getAttribute("area_name") != null %>' >
            <sql:query>
              select area_name
              from area
              where area_c = '<%= ((String)pageContext.getAttribute("area_c")).trim() %>'
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="area_name" />
              <% recordBean.setCompl_addr4((String) pageContext.getAttribute("area_name")); %>
            </sql:resultSet>
          </if:IfTrue>
          <if:IfTrue cond='<%= recordBean.getCompl_addr4() == null || recordBean.getCompl_addr4().equals("") %>' >
            <% recordBean.setCompl_addr4(""); %>
          </if:IfTrue>
        </if:IfTrue>
        
        <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("N") %>' >
          <if:IfTrue cond='<%= pageContext.getAttribute("ward_code") != null %>' >
            <sql:query>
              select ward_name
              from ward
              where ward_code = '<%= ((String)pageContext.getAttribute("ward_code")).trim() %>'
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="ward_code" />
              <% recordBean.setCompl_addr4((String) pageContext.getAttribute("ward_code")); %>
            </sql:resultSet>
          </if:IfTrue>
          <if:IfTrue cond='<%= recordBean.getCompl_addr4() == null || recordBean.getCompl_addr4().equals("") %>' >
            <% recordBean.setCompl_addr4(""); %>
          </if:IfTrue>
        </if:IfTrue>
        
        <%-- setup the other two address fields addr2 and addr3 with the --%>
        <%-- primary and secondary (if it exists) location names --%>
        <sql:query>
          select location_name, locn_type
          from locn
          where location_c = '<%= recordBean.getCompl_location_c() %>'
        </sql:query>  
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="location_name" />
          <sql:getColumn position="2" to="locn_type" />
        </sql:resultSet>
        
        <if:IfTrue cond='<%= ((String)pageContext.getAttribute("locn_type")).trim().equals("1") %>' >
            <% recordBean.setCompl_addr2((String) pageContext.getAttribute("location_name")); %>
        </if:IfTrue>
        
        <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("locn_type")).trim().equals("1") %>' >
          <sql:query>
            select location_pname
            from locn_dp
            where location_c = '<%= recordBean.getCompl_location_c() %>'
          </sql:query>  
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="location_pname" />
            <% recordBean.setCompl_addr2((String) pageContext.getAttribute("location_pname")); %>
            <% recordBean.setCompl_addr3((String) pageContext.getAttribute("location_name")); %>
          </sql:resultSet>
        </if:IfTrue>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </if:IfTrue>
    
    <if:IfTrue cond='<%= custLocLookupBean.getWasEmpty().equals("true") %>' >
      <% recordBean.setCompl_build_no(custLocLookupBean.getCompl_build_no()); %>
      <% recordBean.setCompl_build_name(custLocLookupBean.getCompl_build_name()); %>
      <% recordBean.setCompl_build_sub_name(""); %>
      <% recordBean.setCompl_addr2(custLocLookupBean.getCompl_addr2()); %>
      <% recordBean.setCompl_addr3(""); %>
      <% recordBean.setCompl_addr4(custLocLookupBean.getCompl_addr4()); %>
      <% recordBean.setCompl_postcode(custLocLookupBean.getCompl_postcode()); %>
    </if:IfTrue>
    
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">custLocLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">faultLookup</sess:setAttribute>
    <c:redirect url="faultLookupScript.jsp" />
  </if:IfTrue>
  
  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= custLocLookupBean.getAction().equals("|<<") %>' >
    <% custLocLookupPageSet.first(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <jsp:forward page="custLocLookupView.jsp" />
  </if:IfTrue>
  
  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= custLocLookupBean.getAction().equals(">>|") %>' >
    <% custLocLookupPageSet.last(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <jsp:forward page="custLocLookupView.jsp" />
  </if:IfTrue>
  
  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= custLocLookupBean.getAction().equals(" < ") %>' >
    <% custLocLookupPageSet.previous(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <jsp:forward page="custLocLookupView.jsp" />
  </if:IfTrue>
  
  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= custLocLookupBean.getAction().equals(" > ") %>' >
    <% custLocLookupPageSet.next(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <jsp:forward page="custLocLookupView.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= custLocLookupBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">custLocLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= custLocLookupBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">custLocLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= custLocLookupBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">custLocLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= custLocLookupBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${custLocLookupBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="custLocLookupView.jsp" />
