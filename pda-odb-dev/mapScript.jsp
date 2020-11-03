<%@ page errorPage="error.jsp" %>
<%@ page import="javax.naming.*, com.vsb.mapBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="mapBean" scope="session" class="com.vsb.mapBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="map" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="map" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
   
    <%-- Setup the bean with the forms data --%>
    <% String action = ((String)request.getParameter("action")).trim(); %>
    <if:IfTrue cond='<%= action.equals("Back") || action.equals("JSubmit") 
                      || action.equals("Capture") || action.equals("Submit") %>' >
      <%-- use the values for xWorldCenter, yWorldCenter and zoom passed in by user --%>
      <jsp:setProperty name="mapBean" property="all" value="clear" />
      <jsp:setProperty name="mapBean" property="*" />
    </if:IfTrue>
    <if:IfTrue cond='<%= !action.equals("Back") && !action.equals("JSubmit") && !action.equals("Capture") && !action.equals("Submit") %>' >
      <%-- Keep the old values for xWorldCenter, yWorldCenter and zoom --%>
      <jsp:setProperty name="mapBean" property="action" value="<%= (String)request.getParameter("action") %>" />
    </if:IfTrue>
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors, unless the input is from the addCaptureFunc --%>
<sess:equalsAttribute name="input" match="addCaptureFunc" value="false">
  <jsp:setProperty name="mapBean" property="error" value="" />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <jsp:setProperty name="mapBean" property="action" value="" />
  <jsp:setProperty name="mapBean" property="all" value="clear" />
  <jsp:setProperty name="mapBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="defaultDetails" >
  <jsp:setProperty name="mapBean" property="action" value="" />
  <jsp:setProperty name="mapBean" property="all" value="clear" />
  <jsp:setProperty name="mapBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="text" >
  <jsp:setProperty name="mapBean" property="action" value="" />
  <jsp:setProperty name="mapBean" property="all" value="clear" />
  <jsp:setProperty name="mapBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Get the map movement and zoom settings. --%>
<%
  // obtain the initial context, which holds the server/web.xml environment variables.
  Context initCtx = new InitialContext();
  Context envCtx = (Context) initCtx.lookup("java:comp/env");

  // Put all values that are going to be used in the <c:import ...> call, into the pageContext
  // So that the <c:import ...> tag can access them. All others into variables.
  String map_type = (String)envCtx.lookup("map_type");
  String start_zoom = (String)envCtx.lookup("start_zoom");
  double min_zoom = Double.parseDouble((String)envCtx.lookup("min_zoom"));
  double max_zoom = Double.parseDouble((String)envCtx.lookup("max_zoom"));
  double zoom_inc = Double.parseDouble((String)envCtx.lookup("zoom_inc"));
  int movement_inc = Integer.parseInt((String)envCtx.lookup("movement_inc"));
%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="map" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <% 
      mapBean.setXWorldCenter( recordBean.getMap_easting()  );
      mapBean.setYWorldCenter( recordBean.getMap_northing() );
      mapBean.setZoom(start_zoom);
    %>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Do each time through --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="map" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= !mapBean.getAction().equals("Back") && 
                       !mapBean.getAction().equals("Inspect") &&
                       !mapBean.getAction().equals("Sched/Comp") %>' >
    <% double xWorldCenter = Double.parseDouble(mapBean.getXWorldCenter()); %>
    <% double yWorldCenter = Double.parseDouble(mapBean.getYWorldCenter()); %>
    <% double zoom = Double.parseDouble(mapBean.getZoom()); %>

    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= mapBean.getAction().equals("<") %>' >
      <if:IfTrue cond='<%= map_type.equals("cartology") || map_type.equals("WMS") %>' >
        <% 
          xWorldCenter = xWorldCenter - (movement_inc * zoom);
          mapBean.setXWorldCenter(Double.toString(xWorldCenter));
        %>
      </if:IfTrue>
      <if:IfTrue cond='<%= map_type.equals("googleMaps") || map_type.equals("multimap") %>' >
        <% 
          xWorldCenter = xWorldCenter - ((movement_inc * 2) * ((min_zoom + 1) - zoom)) ;
          mapBean.setXWorldCenter(Double.toString(xWorldCenter));
        %>
      </if:IfTrue>
    </if:IfTrue>

    <if:IfTrue cond='<%= mapBean.getAction().equals(">") %>' >
      <if:IfTrue cond='<%= map_type.equals("cartology") || map_type.equals("WMS") %>' >
        <% 
          xWorldCenter = xWorldCenter + (movement_inc * zoom);
          mapBean.setXWorldCenter(Double.toString(xWorldCenter));
        %>
      </if:IfTrue> 
      <if:IfTrue cond='<%= map_type.equals("googleMaps") || map_type.equals("multimap") %>' >
        <% 
          xWorldCenter = xWorldCenter + ((movement_inc * 2) * ((min_zoom + 1) - zoom));
          mapBean.setXWorldCenter(Double.toString(xWorldCenter));
        %>
      </if:IfTrue> 
    </if:IfTrue> 

    <if:IfTrue cond='<%= mapBean.getAction().equals("Up") %>' >
      <if:IfTrue cond='<%= map_type.equals("cartology") || map_type.equals("WMS") %>' >
        <% 
          yWorldCenter = yWorldCenter + (movement_inc * zoom);
          mapBean.setYWorldCenter(Double.toString(yWorldCenter));
        %>
      </if:IfTrue> 
      <if:IfTrue cond='<%= map_type.equals("googleMaps") || map_type.equals("multimap") %>' >
        <% 
          yWorldCenter = yWorldCenter + ((movement_inc * 2) * ((min_zoom + 1) - zoom));
          mapBean.setYWorldCenter(Double.toString(yWorldCenter));
        %>
      </if:IfTrue> 
    </if:IfTrue> 

    <if:IfTrue cond='<%= mapBean.getAction().equals("Down") || map_type.equals("WMS")%>' >
      <if:IfTrue cond='<%= map_type.equals("cartology") %>' >
        <% 
          yWorldCenter = yWorldCenter - (movement_inc * zoom);
          mapBean.setYWorldCenter(Double.toString(yWorldCenter));
        %>
      </if:IfTrue>
      <if:IfTrue cond='<%= map_type.equals("googleMaps") || map_type.equals("multimap") %>' >
        <% 
          yWorldCenter = yWorldCenter - ((movement_inc * 2) * ((min_zoom + 1) - zoom));
          mapBean.setYWorldCenter(Double.toString(yWorldCenter));
        %>
      </if:IfTrue>
    </if:IfTrue>

    <if:IfTrue cond='<%= mapBean.getAction().equals("+") %>' >
      <if:IfTrue cond='<%= map_type.equals("cartology") || map_type.equals("WMS")%>' >
        <% 
          zoom = zoom - zoom_inc;
          if (zoom <= min_zoom) {
            zoom = min_zoom;
          }
          mapBean.setZoom(Double.toString(zoom));
        %>
      </if:IfTrue>
      <if:IfTrue cond='<%= map_type.equals("googleMaps") || map_type.equals("multimap") %>' >
        <% 
          zoom = zoom + zoom_inc;
          if (zoom >= min_zoom) {
            zoom = min_zoom;
          }
          mapBean.setZoom(Double.toString(zoom));
        %>
      </if:IfTrue>
    </if:IfTrue>

    <if:IfTrue cond='<%= mapBean.getAction().equals("-") %>' >
      <if:IfTrue cond='<%= map_type.equals("cartology") || map_type.equals("WMS") %>' >
        <% 
          zoom = zoom + zoom_inc;
          if (zoom >= max_zoom ) {
            zoom = max_zoom;
          }
          mapBean.setZoom(Double.toString(zoom));
        %>
      </if:IfTrue>
      <if:IfTrue cond='<%= map_type.equals("googleMaps") || map_type.equals("multimap") %>' >
        <% 
          zoom = zoom - zoom_inc;
          if (zoom <= max_zoom ) {
            zoom = max_zoom;
          }
          mapBean.setZoom(Double.toString(zoom));
        %>
      </if:IfTrue>
    </if:IfTrue>
    
    <if:IfTrue cond='<%= mapBean.getAction().equals("JSubmit") %>' >
      <%-- The section below automatically uses the zoom --%>
      <if:IfTrue cond='<%= map_type.equals("cartology") || map_type.equals("WMS") %>' >
        <%
          if (zoom <= min_zoom) {
            zoom = min_zoom;
          }
          if (zoom >= max_zoom) {
            zoom = max_zoom;
          }
          mapBean.setZoom(Double.toString(zoom));
        %>
      </if:IfTrue>
      <if:IfTrue cond='<%= map_type.equals("googleMaps") || map_type.equals("multimap") %>' >
        <%
          if (zoom >= min_zoom) {
            zoom = min_zoom;
          }
          if (zoom <= max_zoom) {
            zoom = max_zoom;
          }
          mapBean.setZoom(Double.toString(zoom));
        %>
      </if:IfTrue>
    </if:IfTrue>

    <if:IfTrue cond='<%= mapBean.getAction().equals("Submit") %>' >
      <%-- The section below automatically uses the zoom --%>
      <if:IfTrue cond='<%= map_type.equals("cartology") || map_type.equals("WMS") %>' >
        <%
          if (zoom <= min_zoom) {
            zoom = min_zoom;
          }
          if (zoom >= max_zoom) {
            zoom = max_zoom;
          }
          mapBean.setZoom(Double.toString(zoom));
        %>
      </if:IfTrue>
      <if:IfTrue cond='<%= map_type.equals("googleMaps") || map_type.equals("multimap") %>' >
        <%
          if (zoom >= min_zoom) {
            zoom = min_zoom;
          }
          if (zoom <= max_zoom) {
            zoom = max_zoom;
          }
          mapBean.setZoom(Double.toString(zoom));
        %>
      </if:IfTrue>
    </if:IfTrue>

    <%-- Setup the different zoom rounding for the different map types --%>
    <if:IfTrue cond='<%= map_type.equals("cartology") || map_type.equals("WMS") %>' >
      <% mapBean.setZoom(String.valueOf(helperBean.roundDouble((new Double(mapBean.getZoom())).doubleValue(),1))); %>
    </if:IfTrue>
    <if:IfTrue cond='<%= map_type.equals("googleMaps") || map_type.equals("multimap") %>' >
      <% mapBean.setZoom(String.valueOf(Math.round((new Double(mapBean.getZoom())).doubleValue()))); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= mapBean.getAction().equals("Capture") %>' >
      <%-- Set the record bean values to the new easting/northing values --%>
      <% recordBean.setMap_easting( mapBean.getXWorldCenter() ); %>
      <% recordBean.setMap_northing( mapBean.getYWorldCenter() ); %>
      <%-- If we are coming from the Inspections List --%>
      <if:IfTrue cond='<%= !recordBean.getComp_action_flag().equals("") %>'>
        <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
        <sql:statement id="stmt" conn="con1">
          <%-- Update comp easting and northing values --%>
          <sql:query>
            UPDATE comp
               SET easting  = <%= recordBean.getMap_easting() %>,
                   northing = <%= recordBean.getMap_northing() %>
             WHERE complaint_no = <%= recordBean.getComplaint_no() %>
          </sql:query>
          <sql:execute />
        </sql:statement>
        <sql:closeConnection conn="con1"/>
      </if:IfTrue>
      <%-- Send a message indicating that the eastings and northings
           were updated, if coming from a default in the Inspection List --%>
      <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("") %>'>
      <jsp:setProperty name="mapBean" property="error"
                      value="Enquiry easting/northing values updated." />
      </if:IfTrue>
      <%-- Otherwise, inform the user that the new Enquiry will have these values --%>
      <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("") %>'>
        <jsp:setProperty name="mapBean" property="error"
                        value="Enquiry easting/northing will be set to selected values." />
      </if:IfTrue>
    </if:IfTrue>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">map</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">map</sess:setAttribute>
    <jsp:forward page="mapView.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= mapBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">map</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= mapBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">map</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>
  
  <%-- Previous view --%>
  <if:IfTrue cond='<%= mapBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">map</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= mapBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${mapBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="mapView.jsp" />
