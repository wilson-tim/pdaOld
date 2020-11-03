<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.marketDetailsBean, com.vsb.recordBean" %>
<%@ page import="com.db.PagingBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag"              prefix="do"   %>
<%@ taglib uri="http://java.sun.com/jstl/xml"                  prefix="x"    %>

<jsp:useBean id="marketDetailsBean" scope="session" class="com.vsb.marketDetailsBean" />
<jsp:useBean id="recordBean"    scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="marketDetailsPagingBean" scope="session" class="com.db.PagingBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at beginning --%>
<sess:equalsAttribute name="form" match="marketDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="marketDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="marketDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="marketDetailsBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="pitch_no" param="pitch_no" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="marketDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="marketsList" >
  <jsp:setProperty name="marketDetailsBean" property="action" value="" />
  <jsp:setProperty name="marketDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="marketDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="changeTrader" >
  <jsp:setProperty name="marketDetailsBean" property="action" value="" />
  <jsp:setProperty name="marketDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="marketDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="updateStatus" >
  <jsp:setProperty name="marketDetailsBean" property="action" value="" />
  <jsp:setProperty name="marketDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="marketDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- Set the page number to 1 and set the sort order the first time we are viewing the form --%>
<sess:equalsAttribute name="input" match="marketDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("marketsList") %>' >
    <jsp:setProperty name="marketDetailsBean" property="page_number" value="1" />
    <sess:setAttribute name="sort_order">pitch</sess:setAttribute>
  </if:IfTrue>
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("changeTrader") %>' >
    <jsp:setProperty name="marketDetailsBean" property="page_number" value="1" />
    <sess:setAttribute name="sort_order">pitch</sess:setAttribute>
  </if:IfTrue>
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("updateStatus") %>' >
    <jsp:setProperty name="marketDetailsBean" property="page_number" value="1" />
    <sess:setAttribute name="sort_order">pitch</sess:setAttribute>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- We need to check if the ordering of the list has been changed. If  --%>
<%-- it has we need to re-create the list and show page 1 again. We use --%>
<%-- the order_changed flag to test if the order has been changed below --%>
<% boolean ordering_changed = false; %>
<if:IfTrue cond='<%= marketDetailsBean.getAction().equals("Pitch") %>' >
  <sess:setAttribute name="sort_order">pitch</sess:setAttribute>
  <% ordering_changed = true; %>
</if:IfTrue>
<if:IfTrue cond='<%= marketDetailsBean.getAction().equals("Confirmed") %>' >
  <sess:setAttribute name="sort_order">confirmed</sess:setAttribute>
  <% ordering_changed = true; %>
</if:IfTrue>

<% String sort_order = "P"; %>
<sess:equalsAttribute name="sort_order" match="pitch" >
  <% sort_order = "P"; %>
</sess:equalsAttribute>
<sess:equalsAttribute name="sort_order" match="confirmed" >
  <% sort_order = "A"; %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Assign marketRecord variable for use in the VIEW, but only the first time through the SCRIPT --%>
<sess:equalsAttribute name="input" match="marketDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <do:SOAPrequest url="<%= getServletContext().getInitParameter("soap:endpoint") %>" action="get_markets" id="xmltext">
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
        <soapenv:Header/>
        <soapenv:Body>
          <dat:get_markets>
            <market_ref><%= recordBean.getMarket_ref() %></market_ref>
          </dat:get_markets>
        </soapenv:Body>
      </soapenv:Envelope>
    </do:SOAPrequest>
    <%-- Did the SOAP request succeed? --%>
    <if:IfTrue cond='<%= (((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1) %>' >
      <%-- Next commented out command is for testing --%>
      <%-- System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|"); --%>
      <jsp:setProperty name="marketDetailsBean" property="error"
        value="The PDA web services are currently unavailable, please try again later." />
      <jsp:forward page="marketDetailsView.jsp" />
    </if:IfTrue>
    <%-- marketDetails --%>
    <x:parse xml="${xmltext}" var="marketRecord" scope="session" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Assign pitchesList and recordCount variables for use in the VIEW, but only the first time through the SCRIPT --%>
<%-- or if returning from changeTrader having selected a new trader --%>
<%--
<sess:equalsAttribute name="input" match="marketDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
--%>
    <%-- set the number of records per page --%>
    <% int recordsOnPage = new Integer(application.getInitParameter("records_on_pitches_list")).intValue(); %>
    <% marketDetailsPagingBean.setRecordsOnPage(recordsOnPage); %>
    <do:SOAPrequest url="<%= getServletContext().getInitParameter("soap:endpoint") %>" action="get_pitches" id="xmltext">
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
        <soapenv:Header/>
        <soapenv:Body>
          <dat:get_pitches>
            <market_ref><%= recordBean.getMarket_ref() %></market_ref>
            <pitch_no></pitch_no>
            <sort_order><%= sort_order %></sort_order>
          </dat:get_pitches>
        </soapenv:Body>
      </soapenv:Envelope>
    </do:SOAPrequest>
    <%-- Did the SOAP request succeed? --%>
    <if:IfTrue cond='<%= (((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1) %>' >
      <%-- Next commented out command is for testing --%>
      <%-- System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|"); --%>
      <jsp:setProperty name="marketDetailsBean" property="error"
        value="The PDA web services are currently unavailable, please try again later." />
      <jsp:forward page="marketDetailsView.jsp" />
    </if:IfTrue>
    <%-- pitchesList --%>
    <x:parse xml="${xmltext}" var="pitchesList" scope="session" />
    <%-- recordCount --%>
    <% int recordCount = 0; %>
    <x:forEach var="n" select="$pitchesList//pitches/element" >
      <% recordCount++; %>
    </x:forEach>
    <% marketDetailsPagingBean.setRecordCount(recordCount); %>
<%--
   </if:IfTrue>
 </sess:equalsAttribute>
--%>

<%-- set the current page number the user is on, unless the ordering --%>
<%-- has been changed, in which case we set it to page 1 --%>
<%
   if(ordering_changed) {
     marketDetailsPagingBean.setCurrentPageNum( 1 );
   } else {
     marketDetailsPagingBean.setCurrentPageNum( new Integer(marketDetailsBean.getPage_number()).intValue() );
   }
%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="marketDetails" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= marketDetailsBean.getAction().equals("Enforce") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=marketDetailsBean.getPitch_no() == null || marketDetailsBean.getPitch_no().equals("") %>' >
      <jsp:setProperty name="marketDetailsBean" property="error"
        value="Please select a pitch." />
      <jsp:forward page="marketDetailsView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Get trader_ref --%>
    <c:set var="pitch_no" ><%= recordBean.getPitch_no() %></c:set>
    <c:set var="trader_ref"><x:out select="$pitchesList//element[pitch_no=$pitch_no]/trader_ref" /></c:set>
    <% String trader_ref = (String)pageContext.getAttribute("trader_ref"); %>
    <% recordBean.setTrader_ref(trader_ref); %>

    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- The module is inspectors --%>
      <app:equalsInitParameter name="module" match="pda-in" >
        <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'PDA_INSPECTOR_ROLE'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="pda_role" />
          <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
        </sql:resultSet>
      </app:equalsInitParameter>

      <%-- The module is town warden --%>
      <app:equalsInitParameter name="module" match="pda-tw" >
        <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'PDA_WARDEN_ROLE'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="pda_role" />
          <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
        </sql:resultSet>
      </app:equalsInitParameter>

      <sql:query>
        select c_field
        from keys
        where keyname = 'ENF_SERVICE'
        and   service_c = 'ALL'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="enf_service" />
        <% recordBean.setEnf_service((String) pageContext.getAttribute("enf_service")); %>
        <% recordBean.setService_c((String) pageContext.getAttribute("enf_service")); %>
      </sql:resultSet>

      <% recordBean.setAction_flag("N"); %>
      <% recordBean.setEnf_list_flag("N"); %>
      <% recordBean.setEnforce_flag("Y"); %>

      <%-- Get the site_ref --%>
      <% recordBean.setSite_ref(""); %>
      <sql:query>
        SELECT pitch_site_ref
        FROM market_pitch
        WHERE market_ref = '<%= recordBean.getMarket_ref() %>'
          AND pitch_no = '<%= recordBean.getPitch_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="site_ref" />
        <% recordBean.setSite_ref((String) pageContext.getAttribute("site_ref")); %>
      </sql:resultSet>

      <%-- Get the ENFORCE's patrol area --%>
      <sql:query>
        SELECT pa_area
        FROM site_pa
        WHERE site_ref = '<%= recordBean.getSite_ref() %>'
        AND   pa_func = 'ENFORC'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="pa_area" />
        <% recordBean.setPa_area((String) pageContext.getAttribute("pa_area")); %>
      </sql:resultSet>

      <%-- get the site name --%>
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

      <%-- Are the recordBean.build_no and recordBean.build_sub_no --%>
      <%-- the display version or the normal version. --%>
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

    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">marketDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">law</sess:setAttribute>
    <c:redirect url="lawScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= marketDetailsBean.getAction().equals("Details") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=marketDetailsBean.getPitch_no() == null || marketDetailsBean.getPitch_no().equals("") %>' >
      <jsp:setProperty name="marketDetailsBean" property="error"
        value="Please select a pitch." />
      <jsp:forward page="marketDetailsView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <% recordBean.setTrader_ref(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">marketDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">pitchDetails</sess:setAttribute>
    <c:redirect url="pitchDetailsScript.jsp" />
  </if:IfTrue>
  
  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= marketDetailsBean.getAction().equals("|<<") %>' >
    <% marketDetailsPagingBean.first(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="marketDetailsView.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= marketDetailsBean.getAction().equals(">>|") %>' >
    <% marketDetailsPagingBean.last(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="marketDetailsView.jsp" />
  </if:IfTrue>

  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= marketDetailsBean.getAction().equals(" < ") %>' >
    <% marketDetailsPagingBean.previous(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="marketDetailsView.jsp" />
  </if:IfTrue>

  <%-- Next view 6 --%>
  <if:IfTrue cond='<%= marketDetailsBean.getAction().equals(" > ") %>' >
    <% marketDetailsPagingBean.next(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="marketDetailsView.jsp" />
  </if:IfTrue>

  <%-- Next view 7 --%>
  <if:IfTrue cond='<%= marketDetailsBean.getAction().equals("Pitch") %>' >
    <sess:setAttribute name="sort_order">pitch</sess:setAttribute>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="marketDetailsView.jsp" />
  </if:IfTrue>

  <%-- Next view 8 --%>
  <if:IfTrue cond='<%= marketDetailsBean.getAction().equals("Confirmed") %>' >
    <sess:setAttribute name="sort_order">confirmed</sess:setAttribute>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="marketDetailsView.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= marketDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">marketDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= marketDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">marketDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= marketDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">marketDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= marketDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${marketDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="marketDetailsView.jsp" />
