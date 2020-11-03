<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectMarketTraderBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag"              prefix="do"   %>
<%@ taglib uri="http://java.sun.com/jstl/xml"                  prefix="x"    %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql"  %>

<jsp:useBean id="enfSuspectMarketTraderBean" scope="session" class="com.vsb.enfSuspectMarketTraderBean" />
<jsp:useBean id="recordBean"       scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"       scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectMarketTrader" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfSuspectMarketTrader" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfSuspectMarketTraderBean" property="all" value="clear" />
    <jsp:setProperty name="enfSuspectMarketTraderBean" property="*" />

    <%-- Add the new values to the record --%>

  </if:IfParameterEquals>
</req:existsParameter>
    
<%-- clear errors --%>
<jsp:setProperty name="enfSuspectMarketTraderBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfEvidence" >
  <jsp:setProperty name="enfSuspectMarketTraderBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectMarketTraderBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectMarketTraderBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- Assign pitchRecord variable for use in the VIEW, but only the first time through the SCRIPT --%>
<sess:equalsAttribute name="input" match="enfSuspectMarketTrader" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <do:SOAPrequest url="<%= getServletContext().getInitParameter("soap:endpoint") %>" action="get_trader_list" id="xmltext">
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
        <soapenv:Header/>
        <soapenv:Body>
          <dat:get_trader_list>
             <trader_ref><%= recordBean.getTrader_ref() %></trader_ref>
             <trader_name/>
             <trader_ta/>
             <contact_init/>
             <contact_name/>
             <contact_surname/>
          </dat:get_trader_list>
        </soapenv:Body>
      </soapenv:Envelope>
    </do:SOAPrequest>
    <%-- Did the SOAP request succeed? --%>
    <if:IfTrue cond='<%= (((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1) %>' >
      <%-- Next commented out command is for testing --%>
      <%-- System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|"); --%>
      <jsp:setProperty name="enfSuspectMarketTraderBean" property="error"
        value="The PDA web services are currently unavailable, please try again later." />
      <jsp:forward page="enfSuspectMarketTraderView.jsp" />
    </if:IfTrue>
    <%-- traderRecords --%>
    <x:parse xml="${xmltext}" var="traderRecords" scope="session" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfSuspectMarketTrader" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= enfSuspectMarketTraderBean.getAction().equals("Change") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectMarketTrader</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfSuspectMarketTraders</sess:setAttribute>
    <c:redirect url="enfSuspectMarketTradersScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= enfSuspectMarketTraderBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <% recordBean.setExternal_ref_type("T"); %>
    <% recordBean.setExternal_ref(recordBean.getTrader_ref()); %>

    <%-- Assign recordBean properties ready for checkSuspectFunc.jsp call by textScript.jsp --%>
    <x:set var="traderRecord" select="$traderRecords//element[position()=1]" />

    <%-- General details --%>
    <c:set var="sus_surname"><x:out select="$traderRecord/contact_surname" /></c:set>
    <c:set var="sus_fstname"><x:out select="$traderRecord/contact_name" /></c:set>
    <c:set var="sus_midname"><x:out select="$traderRecord/contact_init" /></c:set>
    <c:set var="sus_workno"><x:out select="$traderRecord/contact_tel" /></c:set>
    <c:set var="sus_mobno"><x:out select="$traderRecord/contact_mobile" /></c:set>
    <c:set var="site_ref"><x:out select="$traderRecord/trader_site_ref" /></c:set>
    <c:set var="sus_company"><x:out select="$traderRecord/trader_name" /></c:set>

    <%
      recordBean.setSus_title("");
      recordBean.setSus_surname((String)pageContext.getAttribute("sus_surname"));
      recordBean.setSus_fstname((String)pageContext.getAttribute("sus_fstname"));
      recordBean.setSus_midname((String)pageContext.getAttribute("sus_midname"));
      recordBean.setSus_age("");
      recordBean.setSus_sex("");
      recordBean.setSus_homeno("");
      recordBean.setSus_workno((String)pageContext.getAttribute("sus_workno"));
      recordBean.setSus_mobno((String)pageContext.getAttribute("sus_mobno"));
      recordBean.setSite_ref((String)pageContext.getAttribute("site_ref"));
      recordBean.setSus_company((String)pageContext.getAttribute("sus_company"));
    %>

    <%-- Address details --%>
    <%
      String location_c = "";
      String postcode = "";
      String build_no = "";
      String build_sub_no = "";
      String build_no_disp = "";
      String build_sub_no_disp = "";
      String build_name = "";
      String build_sub_name = "";
      String location_name = "";
      String locality_name = "";
      String town_name = "";
      String temp_addr = "";
    %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select site.location_c,
          site.postcode,
          site.build_no,
          site.build_sub_no,
          site.build_no_disp,
          site.build_sub_no_disp,
          site.build_name,
          site.build_sub_name,
          locn.location_name,
          locn.locality_name,
          locn.town_name
        from site, locn
        where site_ref = '<%= recordBean.getSite_ref() %>'
          and site.location_c = locn.location_c
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="location_c" />
        <% location_c = ((String) pageContext.getAttribute("location_c")); %>
        <sql:getColumn position="2" to="postcode" />
        <% postcode =((String) pageContext.getAttribute("postcode")); %>
        <sql:getColumn position="3" to="build_no" />
        <% build_no = ((String) pageContext.getAttribute("build_no")); %>
        <sql:getColumn position="4" to="build_sub_no" />
        <% build_sub_no = ((String) pageContext.getAttribute("build_sub_no")); %>
        <sql:getColumn position="5" to="build_no_disp" />
        <% build_no_disp = ((String) pageContext.getAttribute("build_no_disp")); %>
        <sql:getColumn position="6" to="build_sub_no_disp" />
        <% build_sub_no_disp = ((String) pageContext.getAttribute("build_sub_no_disp")); %>
        <sql:getColumn position="7" to="build_name" />
        <% build_name = ((String) pageContext.getAttribute("build_name")); %>
        <sql:getColumn position="8" to="build_sub_name" />
        <% build_sub_name = ((String) pageContext.getAttribute("build_sub_name")); %>
        <sql:getColumn position="9" to="location_name" />
        <% location_name = ((String) pageContext.getAttribute("location_name")); %>
        <sql:getColumn position="10" to="locality_name" />
        <% locality_name = ((String) pageContext.getAttribute("locality_name")); %>
        <sql:getColumn position="11" to="town_name" />
        <% town_name = ((String) pageContext.getAttribute("town_name")); %>
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
        <% build_no = ((String) pageContext.getAttribute("build_no_disp")); %>
        <% build_sub_no = ((String) pageContext.getAttribute("build_sub_no_disp")); %>
      </if:IfTrue>

    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%
      String addr1 = location_name;
      String addr2 = locality_name;
      String addr3 = town_name;

      if ( (addr1 == null || addr1.equals("") ) ) {
        addr1 = addr2;
        addr2 = addr3;
        addr3 = "";
      }

      if ( (addr1 == null || addr1.equals("") ) ) {
        addr1 = addr2;
        addr2 = addr3;
        addr3 = "";
      }

      if ( (addr2 == null || addr2.equals("") ) ) {
        addr2 = addr3;
        addr3 = "";
      }
    %>

    <%
      recordBean.setLocation_c(location_c);
      recordBean.setSus_build_no(build_no);
      recordBean.setSus_build_name(build_name);
      recordBean.setSus_addr1(addr1);
      recordBean.setSus_addr2(addr2);
      recordBean.setSus_addr3(addr3);
      recordBean.setSus_postcode(postcode);
    %>

            <if:IfTrue cond='<%= recordBean.getComingFromMarketsList().equals("Y") %>' >
              <sess:setAttribute name="form">checkSuspectFunc</sess:setAttribute>
              <c:import url="checkSuspectFunc.jsp" var="webPage" />
              <% helperBean.throwException("checkSuspectFunc", (String)pageContext.getAttribute("webPage")); %>
            </if:IfTrue>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectMarketTrader</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfSuspectText</sess:setAttribute>
    <c:redirect url="enfSuspectTextScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfSuspectMarketTraderBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectMarketTrader</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfSuspectMarketTraderBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectMarketTrader</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfSuspectMarketTraderBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectMarketTrader</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfSuspectMarketTraderBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfSuspectMarketTraderBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfSuspectMarketTraderView.jsp" />
