<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyTransectMeasureBean, com.vsb.surveyTransectMethodBean, com.vsb.surveySiteLookupBean, com.vsb.systemKeysBean" %>
<%@ page import="com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="surveyTransectMeasureBean" scope="session" class="com.vsb.surveyTransectMeasureBean" />
<jsp:useBean id="surveyTransectMethodBean" scope="session" class="com.vsb.surveyTransectMethodBean" />
<jsp:useBean id="surveySiteLookupBean" scope="session" class="com.vsb.surveySiteLookupBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveyTransectMeasure" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="surveyTransectMeasure" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="surveyTransectMeasureBean" property="all" value="clear" />
    <jsp:setProperty name="surveyTransectMeasureBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="bv_start_post" value='<%=surveyTransectMeasureBean.getStart_post()%>' />
    <jsp:setProperty name="recordBean" property="bv_stop_post" value='<%=surveyTransectMeasureBean.getEnd_post()%>' />
    <jsp:setProperty name="recordBean" property="bv_start_house" value='<%=surveyTransectMeasureBean.getStart_house()%>' />
    <jsp:setProperty name="recordBean" property="bv_stop_house" value='<%=surveyTransectMeasureBean.getEnd_house()%>' />
    <jsp:setProperty name="recordBean" property="bv_transect_desc" value='<%=surveyTransectMeasureBean.getTransect_desc()%>' />

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="surveyTransectMeasureBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="surveyTransectMethod" >
  <jsp:setProperty name="surveyTransectMeasureBean" property="action" value="" />
  <jsp:setProperty name="surveyTransectMeasureBean" property="all" value="clear" />
  <jsp:setProperty name="surveyTransectMeasureBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
    <if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("01") %>' >
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'SL_INSTALLATION'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="sl_switch" />
        <% surveyTransectMeasureBean.setSl_switch((String) pageContext.getAttribute("sl_switch")); %>
      </sql:resultSet>
      <sql:query>
        select
          count(sl_sf_id)
        from
          sl_sf
        where
          site_ref = '<%= surveySiteLookupBean.getSite_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="sl_count" />
      </sql:resultSet>
      <if:IfTrue cond='<%= ((String) pageContext.getAttribute("sl_count")).equals("0") %>' >
        <% surveyTransectMeasureBean.setSl_switch("N"); %>
      </if:IfTrue>
    </if:IfTrue>

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
    <if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("02") %>' >
      <sql:query>
        select
            count(build_no)
        from
            site
        where
            location_c IN
            (
              select
                  location_c
              from
                  site
              where
                  site_ref = '<%= recordBean.getBv_site_ref() %>'
            )
        <if:IfTrue cond='<%= use_supersites == true %>' >
          and
              site_ref not like '%S'
          and
              site_ref not like '%G'
        </if:IfTrue>
        <if:IfTrue cond='<%= use_supersites == false %>' >
          and
              site_c = 'P'
        </if:IfTrue>
        and
            build_no != ''
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="hn_count" />
        <% surveyTransectMeasureBean.setHn_count((String) pageContext.getAttribute("hn_count")); %>
      </sql:resultSet>
    </if:IfTrue>
  </sql:statement>
<sql:closeConnection conn="con"/>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="surveyTransectMeasure" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= surveyTransectMeasureBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= ((surveyTransectMeasureBean.getStart_post() == null || surveyTransectMeasureBean.getStart_post().equals("")) ||
                         (surveyTransectMeasureBean.getEnd_post() == null || surveyTransectMeasureBean.getEnd_post().equals("")))
                      && ((surveyTransectMeasureBean.getStart_house() == null || surveyTransectMeasureBean.getStart_house().equals("")) ||
                         (surveyTransectMeasureBean.getEnd_house() == null || surveyTransectMeasureBean.getEnd_house().equals("")))
                      && (surveyTransectMeasureBean.getTransect_desc() == null || surveyTransectMeasureBean.getTransect_desc().equals("")) %>' >
      <jsp:setProperty name="surveyTransectMeasureBean" property="error"
        value="Please enter transect information." />
      <jsp:forward page="surveyTransectMeasureView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%=  (surveyTransectMeasureBean.getStart_post() != null
                        && !surveyTransectMeasureBean.getStart_post().equals("")
                        && surveyTransectMeasureBean.getEnd_post() != null
                        && !surveyTransectMeasureBean.getEnd_post().equals("")
                        && surveyTransectMeasureBean.getStart_post().equals(surveyTransectMeasureBean.getEnd_post()))
                        ||(surveyTransectMeasureBean.getStart_house() != null
                        && !surveyTransectMeasureBean.getStart_house().equals("")
                        && surveyTransectMeasureBean.getEnd_house() != null
                        && !surveyTransectMeasureBean.getEnd_house().equals("")
                        && surveyTransectMeasureBean.getStart_house().equals(surveyTransectMeasureBean.getEnd_house())) %>'>
      <jsp:setProperty name="surveyTransectMeasureBean" property="error"
        value="Start and End points may not be the same." />
      <jsp:forward page="surveyTransectMeasureView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= surveyTransectMeasureBean.getTransect_desc().length() > 150 %>' >
      <%
        int n = surveyTransectMeasureBean.getTransect_desc().length() - 150;
        String error = "Transect descriptions are limited to 150 characters."+
        "Please delete " + n + " characters.";
      %>
      <jsp:setProperty name="surveyTransectMeasureBean" property="error" value='<%= error %>' />
      <jsp:forward page="surveyTransectMeasureView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyTransectMeasure</sess:setAttribute>
    <%-- Indicate which form we are going to next--%>
    <sess:setAttribute name="form">surveyLandUse</sess:setAttribute>
    <c:redirect url="surveyLandUseScript.jsp" />
  </if:IfTrue>

  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveyTransectMeasureBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyTransectMeasure</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveyTransectMeasureBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyTransectMeasure</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= surveyTransectMeasureBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyTransectMeasure</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= surveyTransectMeasureBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${surveyTransectMeasureBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="surveyTransectMeasureView.jsp" />
