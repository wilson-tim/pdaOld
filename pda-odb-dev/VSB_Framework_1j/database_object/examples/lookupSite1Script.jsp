<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.lookupSite1Bean, com.vsb.recordBean, com.vsb.townWardenBean" %>
<%@ page import="com.db.*, javax.sql.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="lookupSite1Bean" scope="session" class="com.vsb.lookupSite1Bean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="townWardenBean" scope="session" class="com.vsb.townWardenBean" />
<jsp:useBean id="pageSet" scope="session" class="com.db.PageSet" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="lookupSite1" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="lookupSite1" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="lookupSite1Bean" property="all" value="clear" />
    <jsp:setProperty name="lookupSite1Bean" property="*" />
    
    <%-- Clear the previous record --%>
    <jsp:setProperty name="recordBean" property="all" value="clear" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="site_ref" param="site_ref" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="lookupSite1Bean" property="error" value="" />

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="townWarden" >
  <jsp:setProperty name="lookupSite1Bean" property="action" value="" />
  <jsp:setProperty name="lookupSite1Bean" property="all" value="clear" />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Populate the pageSet for use in the VIEW, but only the first time through the SCRIPT --%>
<sess:equalsAttribute name="input" match="lookupSite1" value="false">
  <sess:equalsAttribute name="input" match="townWarden">
    <%-- set the number of records per page --%>
    <% pageSet.setRecordsOnPage(20); %>
    
    <%-- Connect to the database using the context and datasource --%>
    <% DbSQL connection = new DbSQL(); %>
    <% connection.connect("java:comp/env", "jdbc/pda"); %>
    
    <%-- SET UP QUERY TO FIND ALL MATCHING ROADS --%>
    <%
      String queryString = 
        "select site_ref, site_name_1 " +
        "from site " +
        "where site_status = \"L\" " +
        "and   site_ref matches \"*S\" ";
    %>
    <%-- Use the build_no to find the site_ref if the user typed in a House No. --%>
    <if:IfTrue cond='<%= !(townWardenBean.getWardenHouseNo().trim().equals("")) %>' >
      <% 
        queryString = queryString + 
          "and   build_no matches \"" + townWardenBean.getWardenHouseNo().toUpperCase() + "\"";
      %>
    </if:IfTrue>
    <%-- Use the build_name to find the site_ref if the user typed in a Building Name --%>
    <if:IfTrue cond='<%= !(townWardenBean.getWardenBuildingName().trim().equals("")) %>' >
      <%
        queryString = queryString + 
          "and   (build_name matches \"" + townWardenBean.getWardenBuildingName().toUpperCase() + "\"" +
             "or build_sub_name matches \"" + townWardenBean.getWardenBuildingName().toUpperCase() + "\")";
      %>
    </if:IfTrue>
    <%-- Use the location_name to find the location_c if the user typed in a location --%>
    <if:IfTrue cond='<%= !(townWardenBean.getWardenLoc().trim().equals("")) %>' >
      <%
        queryString = queryString +
          "and   location_c IN " +
          "  (select location_c " +
          "  from locn " +
          "  where location_name matches \"" + townWardenBean.getWardenLoc().toUpperCase() + "\")";
      %>
    </if:IfTrue>
    <%-- Use the postcode to find the site_ref if the user typed in a postcode --%>
    <if:IfTrue cond='<%= !(townWardenBean.getWardenPostCode().trim().equals("")) %>' >
      <%
        queryString = queryString +
          "and   postcode matches \"" + townWardenBean.getWardenPostCode().toUpperCase() + "\"";
      %>
    </if:IfTrue>
    <% queryString = queryString + " order by site_name_1"; %>
    
    <%-- Run a query for roads --%>
    <% java.sql.ResultSet rs = connection.query(queryString); %>
    <%-- populate the PageSet from the ResultSet --%>
    <% pageSet.setPageSet(rs); %>
    
    <%-- SET UP QUERY TO FIND ALL MATCHING SITES --%>
    <%
      queryString = 
        "select site_ref, site_name_1 " +
        "from site " +
        "where site_status = \"L\" " +
        "and   site_ref not matches \"*S\" ";
    %>
    <%-- Use the build_no to find the site_ref if the user typed in a House No. --%>
    <if:IfTrue cond='<%= !(townWardenBean.getWardenHouseNo().trim().equals("")) %>' >
      <% 
        queryString = queryString + 
          "and   build_no matches \"" + townWardenBean.getWardenHouseNo().toUpperCase() + "\"";
      %>
    </if:IfTrue>
    <%-- Use the build_name to find the site_ref if the user typed in a Building Name --%>
    <if:IfTrue cond='<%= !(townWardenBean.getWardenBuildingName().trim().equals("")) %>' >
      <%
        queryString = queryString + 
          "and   (build_name matches \"" + townWardenBean.getWardenBuildingName().toUpperCase() + "\"" +
             "or build_sub_name matches \"" + townWardenBean.getWardenBuildingName().toUpperCase() + "\")";
      %>
    </if:IfTrue>
    <%-- Use the location_name to find the location_c if the user typed in a location --%>
    <if:IfTrue cond='<%= !(townWardenBean.getWardenLoc().trim().equals("")) %>' >
      <%
        queryString = queryString +
          "and   location_c IN " +
          "  (select location_c " +
          "  from locn " +
          "  where location_name matches \"" + townWardenBean.getWardenLoc().toUpperCase() + "\")";
      %>
    </if:IfTrue>
    <%-- Use the postcode to find the site_ref if the user typed in a postcode --%>
    <if:IfTrue cond='<%= !(townWardenBean.getWardenPostCode().trim().equals("")) %>' >
      <%
        queryString = queryString +
          "and   postcode matches \"" + townWardenBean.getWardenPostCode().toUpperCase() + "\"";
      %>
    </if:IfTrue>
    <% queryString = queryString + " order by site_name_1"; %>
    
    <%-- Run a query for sites--%>
    <% rs = connection.query(queryString); %>
    <%-- populate the PageSet from the ResultSet --%>
    <% pageSet.addToPageSet(rs); %>
    
    <%-- close the ResultSet and disconnect from the database --%>
    <% rs.close(); %>
    <% connection.disconnect(); %>
  </sess:equalsAttribute>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="lookupSite1" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= lookupSite1Bean.getAction().equals("Submit") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=lookupSite1Bean.getSite_ref() == null || lookupSite1Bean.getSite_ref().trim().equals("") %>' >
      <jsp:setProperty name="lookupSite1Bean" property="error"
        value="Please choose a site" />
    	<jsp:forward page="lookupSite1View.jsp" />
    </if:IfTrue>
    
  	<%-- Valid entry --%>
  	<%-- get the site name --%>
  	<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
		<sql:statement id="stmt" conn="con">
  		<sql:query>
        select site_name_1, location_c, postcode, build_no, build_name, build_sub_name
        from site
        where site_ref = "<%= recordBean.getSite_ref() %>"
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
        
        <sql:getColumn position="5" to="build_name" />
        <% recordBean.setBuild_name((String) pageContext.getAttribute("build_name")); %>
        <if:IfTrue cond='<%= recordBean.getBuild_name() == null || recordBean.getBuild_name().trim().equals("") %>' >
          <% recordBean.setBuild_name(""); %>
        </if:IfTrue>
        
        <sql:getColumn position="6" to="build_sub_name" />
        <% recordBean.setBuild_sub_name((String) pageContext.getAttribute("build_sub_name")); %>
        <if:IfTrue cond='<%= recordBean.getBuild_name() == null || recordBean.getBuild_name().trim().equals("") %>' >
          <% recordBean.setBuild_sub_name(""); %>
        </if:IfTrue>
      </sql:resultSet>
      
      <%-- Get the location name and code and store it in the record bean --%>
			<sql:query>
			  select location_name
        from locn
        where location_c = "<%= recordBean.getLocation_c() %>"
			</sql:query>	
			<sql:resultSet id="rset">
			  <sql:getColumn position="1" to="location_name" />
        <% recordBean.setLocation_name((String) pageContext.getAttribute("location_name")); %>
      </sql:resultSet>
		</sql:statement>
		<sql:closeConnection conn="con"/>
		
		<%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">lookupSite1</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">service</sess:setAttribute>
  	<% response.sendRedirect("serviceScript.jsp"); %>
  	<jsp:forward page="" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= lookupSite1Bean.getAction().equals("|<<") %>' >
    <% pageSet.first(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>
    
  	<%-- Valid entry --%>
    <jsp:forward page="lookupSite1View.jsp" />
  </if:IfTrue>
  
  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= lookupSite1Bean.getAction().equals(">>|") %>' >
    <% pageSet.last(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>
    
  	<%-- Valid entry --%>
    <jsp:forward page="lookupSite1View.jsp" />
  </if:IfTrue>
  
  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= lookupSite1Bean.getAction().equals(" < ") %>' >
    <% pageSet.previous(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>
    
  	<%-- Valid entry --%>
    <jsp:forward page="lookupSite1View.jsp" />
  </if:IfTrue>
  
  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= lookupSite1Bean.getAction().equals(" > ") %>' >
    <% pageSet.next(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>
    
  	<%-- Valid entry --%>
    <jsp:forward page="lookupSite1View.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= lookupSite1Bean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">lookupSite1</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">townWarden</sess:setAttribute>
  	<% response.sendRedirect("townWardenScript.jsp"); %>
  	<jsp:forward page="" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="lookupSite1View.jsp" />
