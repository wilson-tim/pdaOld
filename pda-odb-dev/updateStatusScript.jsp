<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.updateStatusBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.systemKeysBean" %>
<%@ page import="com.vsb.enfDetailsBean, com.vsb.enfEvidenceBean, com.vsb.enfActionBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="updateStatusBean" scope="session" class="com.vsb.updateStatusBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="enfDetailsBean" scope="session" class="com.vsb.enfDetailsBean" />
<jsp:useBean id="enfEvidenceBean" scope="session" class="com.vsb.enfEvidenceBean" />
<jsp:useBean id="enfActionBean" scope="session" class="com.vsb.enfActionBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="updateStatus" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="updateStatus" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="updateStatusBean" property="all" value="clear" />
    <jsp:setProperty name="updateStatusBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="updateStatusBean" property="error" value="" />
<%-- Do we care about any printing errors? --%>
<app:equalsInitParameter name="show_printing_errors" match="Y">
  <if:IfTrue cond='<%= ! recordBean.getPrinting_error().equals("ok") %>' >
      <jsp:setProperty name="updateStatusBean" property="error" value='<%= recordBean.getPrinting_error() %>' />
  </if:IfTrue>
</app:equalsInitParameter>

<%-- clear form fields if coming from any previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="updateStatus" value="false">
  <jsp:setProperty name="updateStatusBean" property="action" value="" />
  <jsp:setProperty name="updateStatusBean" property="all" value="clear" />
  <jsp:setProperty name="updateStatusBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="updateStatus" >
  <%-- Next view 1 --%>
  <%-- 03/08/2010  TW  New condition --%>
  <if:IfTrue cond='<%= updateStatusBean.getAction().equals("Add Action/Status") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- 03/08/2010  TW  Assign suspect_ref and action_seq for enfDetailsScript.jsp --%>
    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
      <sql:query>
        SELECT suspect_ref, action_seq
          FROM comp_enf
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="suspect_ref" />
        <% recordBean.setEnf_list_suspect_ref((String) pageContext.getAttribute("suspect_ref")); %>
        <sql:wasNull>
          <% recordBean.setEnf_list_suspect_ref(""); %>
        </sql:wasNull>
        <sql:getColumn position="2" to="action_seq" />
        <% recordBean.setEnf_list_action_seq((String) pageContext.getAttribute("action_seq")); %>
        <sql:wasNull>
          <% recordBean.setEnf_list_action_seq(""); %>
        </sql:wasNull>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con1"/>
    
    <%-- 31/08/2010  TW  Clear the text data; previous text data calculated by enfDetailsScript.jsp --%>
    <% enfDetailsBean.setText(""); %>

    <%-- 07/09/2010  TW  Assign evidence for enfEvidenceScript.jsp --%>
    <%-- Storage of evidence text is Contender version specific, see enfEvidenceScript.jsp --%>
    <% String contender_version = systemKeysBean.getContender_version(); %>
    <if:IfTrue cond='<%= contender_version.equals("v7") || contender_version.equals("") %>'>
      <% recordBean.setEnf_list_evidence(enfEvidenceBean.getEvidence()); %>
    </if:IfTrue>
    <if:IfTrue cond='<%= contender_version.equals("v8") %>'>
      <%
        String evidence = "";
        String evidence_txt = "";
      %>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con1">
        <sql:query>
          SELECT txt, seq
            FROM evidence_text
            WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
            ORDER BY seq asc
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="txt" />
          <%
            evidence_txt = (String)pageContext.getAttribute("txt");
            if((evidence.length() > 0) && (evidence_txt.length() > 0)) {
              evidence = evidence + " " + evidence_txt;
            } else {
              evidence = evidence + evidence_txt;
            }
          %>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con1"/>
      <% recordBean.setEnf_list_evidence(evidence); %>
    </if:IfTrue>

    <%-- 14/12/2010  TW  Clear action data --%>
    <% enfActionBean.setAutOff(""); %>
    <% enfActionBean.setAction_code(""); %>
    <% enfActionBean.setAction_text(""); %>
    <% recordBean.setEnf_action_txt(""); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">updateStatus</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfDetails</sess:setAttribute>
    <c:redirect url="enfDetailsScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= updateStatusBean.getAction().equals("OK") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- The module is town warden --%>
    <app:equalsInitParameter name="module" match="pda-tw" >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">updateStatus</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
      <c:redirect url="schedOrCompScript.jsp" />
    </app:equalsInitParameter>

    <%-- The module is inspectors --%>
    <app:equalsInitParameter name="module" match="pda-in" >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">updateStatus</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">mainMenu</sess:setAttribute>
      <c:redirect url="mainMenuScript.jsp" />
    </app:equalsInitParameter>
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= updateStatusBean.getAction().equals("Menu") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">updateStatus</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">mainMenu</sess:setAttribute>
    <c:redirect url="mainMenuScript.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= updateStatusBean.getAction().equals("Complaint") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Blank the complaint number so that things like the graffDetails form do not --%>
    <%-- repopulate their form with data from the just created complaint. --%>

    <%-- Retrieve the variables from the recordBean and then clear the recordBean and repopulate --%>
    <%-- it as if the user has moved through the login, mainMenu, schedOrComp, locLookup. --%>
    <%
      String savePda_role = recordBean.getPda_role();

      String saveGraffiti_service = recordBean.getGraffiti_service();
      String saveDart_service = recordBean.getDart_service();
      String saveRelaxed_search_flag = recordBean.getRelaxed_search_flag();

      String saveContender_version = recordBean.getContender_version();

      String saveSite_ref = recordBean.getSite_ref();
      String saveBuild_no_string = recordBean.getBuild_no_string();
      String saveSite_name_1 = recordBean.getSite_name_1();
      String saveLocation_c = recordBean.getLocation_c();
      String savePostcode = recordBean.getPostcode();
      String saveBuild_no = recordBean.getBuild_no();
      String saveBuild_sub_no = recordBean.getBuild_sub_no();
      String saveBuild_name = recordBean.getBuild_name();
      String saveBuild_sub_name = recordBean.getBuild_sub_name();
      String saveArea_ward_desc = recordBean.getArea_ward_desc();
      String saveLocation_name = recordBean.getLocation_name();
      String saveTrade_site_no = recordBean.getTrade_site_no();
      String saveTrade_name = recordBean.getTrade_name();
      String saveTrade_service = recordBean.getTrade_service();
      String saveService_c = recordBean.getService_c();

      String saveAv_service = recordBean.getAv_service();
      String saveHway_service = recordBean.getHway_service();
      String saveTrees_service = recordBean.getTrees_service();
      String saveEnf_service = recordBean.getEnf_service();
      String saveTrees_inst = recordBean.getTrees_inst();
      String saveService_count = recordBean.getService_count();
    %>

    <%-- Clear the previous record --%>
    <jsp:setProperty name="recordBean" property="all" value="clear" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="clearedDefault" value="N" />
    <jsp:setProperty name="recordBean" property="comingFromSchedComp" value="Y" />

    <%
      recordBean.setPda_role(savePda_role);

      recordBean.setGraffiti_service(saveGraffiti_service);
      recordBean.setDart_service(saveDart_service);
      recordBean.setRelaxed_search_flag(saveRelaxed_search_flag);

      recordBean.setContender_version(saveContender_version);

      recordBean.setSite_ref(saveSite_ref);
      recordBean.setBuild_no_string(saveBuild_no_string);
      recordBean.setSite_name_1(saveSite_name_1);
      recordBean.setLocation_c(saveLocation_c);
      recordBean.setPostcode(savePostcode);
      recordBean.setBuild_no(saveBuild_no);
      recordBean.setBuild_sub_no(saveBuild_sub_no);
      recordBean.setBuild_name(saveBuild_name);
      recordBean.setBuild_sub_name(saveBuild_sub_name);
      recordBean.setArea_ward_desc(saveArea_ward_desc);
      recordBean.setLocation_name(saveLocation_name);
      recordBean.setTrade_site_no(saveTrade_site_no);
      recordBean.setTrade_name(saveTrade_name);
      recordBean.setTrade_service(saveTrade_service);
      recordBean.setService_c(saveService_c);
   
      // From Service form
      recordBean.setAv_service(saveAv_service);
      recordBean.setHway_service(saveHway_service);
      recordBean.setTrees_service(saveTrees_service);
      recordBean.setEnf_service(saveEnf_service);
      recordBean.setTrees_inst(saveTrees_inst);
      recordBean.setService_count(saveService_count);
    %>

    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getTrees_service()) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">updateStatus</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">treesList</sess:setAttribute>
      <c:redirect url="treesListScript.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getHway_service()) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">updateStatus</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">itemLookup</sess:setAttribute>
      <c:redirect url="itemLookupScript.jsp" />
    </if:IfTrue>

    <%-- ### IF THE FLOW CHANGES IN THE FUTURE SO THAT THE SERVICES SCREEN IS ALWAYS SKIPPED --%>
    <%-- ### THEN THE SAME VARIABLES SAVED BY THE TREES SECTION ABOVE NEED TO BE DONE FOR --%>
    <%-- ### ALL SERVICES, AND THE ENFORCEMENT SERVICE WILL NEED THE ADDITIONAL VARIABLES OF --%>
    <%-- ### Action_flag, Enf_list_flag, Enforce_flag, and Pa_area SAVED. --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">updateStatus</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">service</sess:setAttribute>
    <c:redirect url="serviceScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <%-- NON --%>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="updateStatusView.jsp" />
