<%@ page errorPage="error.jsp" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.vsb.compTreeDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"          prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>

<jsp:useBean id="compTreeDetailsBean" scope="session" class="com.vsb.compTreeDetailsBean" />
<jsp:useBean id="recordBean"      scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"      scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="compTreeDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<app:equalsInitParameter name="use_xhtml" match="Y">
  <html xmlns="http://www.w3.org/1999/xhtml">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <html>
</app:equalsInitParameter>
<head>
  <!-- Set iPhone OS Safari attributes -->
  <meta name = "viewport" content = "width = device-width">

  <%-- Stop the browser from caching the page --%>
  <meta http-equiv="Cache-Control" content="no-cache"/>
  <meta http-equiv="Pragma" content="no-cache"/>
  <%-- Stop any proxy servers from caching the page --%>
  <% response.addHeader("Cache-Control", "no-cache"); %>

  <meta http-equiv="Refresh" content="<app:initParameter name="refreshInterval"/>" />
  <app:equalsInitParameter name="use_xhtml" match="Y">
    <meta http-equiv="Content-Type" content="application/xhtml+xml" />
    <% response.setContentType("application/xhtml+xml"); %>
  </app:equalsInitParameter>
  <app:equalsInitParameter name="use_xhtml" match="Y" value="false">
    <meta http-equiv="Content-Type" content="text/html" />
  </app:equalsInitParameter>
  <title>compTreeDetails</title>
  <style type="text/css">
    @import url("global.css");
  </style>
  <!-- Disable the browser back button -->
  <script type="text/javascript">window.history.go(1);</script>
  <!-- Make all submit buttons single click only -->
  <script type="text/javascript">
    var allowed = true;
    function singleclick() {
      if (allowed == true ) {
        allowed = false;
        return true;
      } else {
        return false;
      }
    }
  </script>
</head>

<body onUnload="">
  <form onSubmit="return singleclick();" action="compTreeDetailsScript.jsp" method="post">
    <%-- Title --%>
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Tree Detail</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="compTreeDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>      
    </table>
    <%-- Site Name --%>
    <table width="100%">
      <tr>
        <td align="center"><b><%= recordBean.getSite_name_1() %></b></td>
      </tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
    </table>
    <%-- Initialise static tree variable descriptions --%>    
    <% String trees_item     = ""; %>
    <% String trees_feature  = ""; %>
    <% String trees_contract = ""; %>
    <% String round_c        = ""; %>
    <% String species_desc   = ""; %>
    <% String height_desc    = ""; %>
    <% String age_desc       = ""; %>
    <% String crown_desc     = ""; %>
    <% String dbh_desc       = ""; %>
    <% String condition_desc = ""; %>
    <% String vigour_desc    = ""; %>
    <% String pavement_desc  = ""; %>
    <% String boundary_desc  = ""; %>
    <% String building_desc  = ""; %>
    <% String issue_desc     = ""; %>
    <% String easting        = ""; %>
    <% String northing       = ""; %>
    <%-- Tree Details --%>
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
      <%-- Get the round_c --%>
      <sql:query>
        SELECT round_c
        FROM si_d 
        WHERE site_ref = '<%= recordBean.getSite_ref() %>'
        AND   detail_ref = '<%= recordBean.getTree_ref() %>'
        AND   item_ref = '<%= trees_item %>'
        AND   feature_ref = '<%= trees_feature %>'
        AND   contract_ref = '<%= trees_contract %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="round_c" />
        <sql:wasNotNull>
          <% round_c = ((String)pageContext.getAttribute("round_c")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the species description --%>
      <sql:query>
        SELECT species_desc FROM trees_species WHERE species_ref = <%= compTreeDetailsBean.getSpecies_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="species_desc" />
        <sql:wasNotNull>
          <% species_desc = ((String)pageContext.getAttribute("species_desc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the height description --%>
      <sql:query>
        SELECT height_desc FROM trees_height WHERE height_ref = <%= compTreeDetailsBean.getHeight_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="height_desc" />
        <sql:wasNotNull>
          <% height_desc = ((String)pageContext.getAttribute("height_desc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the age description --%>
      <sql:query>
        SELECT age_desc FROM trees_age WHERE age_ref = <%= compTreeDetailsBean.getAge_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="age_desc" />
        <sql:wasNotNull>
          <% age_desc = ((String)pageContext.getAttribute("age_desc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the crown description --%>
      <sql:query>
        SELECT crown_desc FROM trees_crown WHERE crown_ref = <%= compTreeDetailsBean.getCrown_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="crown_desc" />
        <sql:wasNotNull>
          <% crown_desc = ((String)pageContext.getAttribute("crown_desc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the dbh description --%>
      <sql:query>
        SELECT dbh_desc FROM trees_dbh WHERE dbh_ref = <%= compTreeDetailsBean.getDbh_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="dbh_desc" />
        <sql:wasNotNull>
          <% dbh_desc = ((String)pageContext.getAttribute("dbh_desc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the condition description --%>
      <sql:query>
        SELECT condition_desc FROM trees_condition WHERE condition_ref = <%= compTreeDetailsBean.getCondition_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="condition_desc" />
        <sql:wasNotNull>
          <% condition_desc = ((String)pageContext.getAttribute("condition_desc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the vigour description --%>
      <sql:query>
        SELECT vigour_desc FROM trees_vigour WHERE vigour_ref = <%= compTreeDetailsBean.getVigour_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="vigour_desc" />
        <sql:wasNotNull>
          <% vigour_desc = ((String)pageContext.getAttribute("vigour_desc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the pavement description --%>
      <sql:query>
        SELECT pavement_desc FROM trees_pavement WHERE pavement_ref = <%= compTreeDetailsBean.getPavement_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="pavement_desc" />
        <sql:wasNotNull>
          <% pavement_desc = ((String)pageContext.getAttribute("pavement_desc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the boundary description --%>
      <sql:query>
        SELECT boundary_desc FROM trees_boundary WHERE boundary_ref = <%= compTreeDetailsBean.getBoundary_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="boundary_desc" />
        <sql:wasNotNull>
          <% boundary_desc = ((String)pageContext.getAttribute("boundary_desc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the building description --%>
      <sql:query>
        SELECT building_desc FROM trees_building WHERE building_ref = <%= compTreeDetailsBean.getBuilding_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="building_desc" />
        <sql:wasNotNull>
          <% building_desc = ((String)pageContext.getAttribute("building_desc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the issue description --%>
      <sql:query>
        SELECT issue_desc FROM trees_issue WHERE issue_ref = <%= compTreeDetailsBean.getIssue_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="issue_desc" />
        <sql:wasNotNull>
          <% issue_desc = ((String)pageContext.getAttribute("issue_desc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Get the easting and northing --%>
      <sql:query>
        SELECT easting, northing FROM trees WHERE tree_ref = <%= recordBean.getTree_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="easting" />
        <sql:wasNotNull>
          <% easting = ((String)pageContext.getAttribute("easting")).trim(); %>
        </sql:wasNotNull>
        <sql:getColumn position="2" to="northing" />
        <sql:wasNotNull>
          <% northing = ((String)pageContext.getAttribute("northing")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>
    <table width="100%">
      <tr bgcolor="#ffffff">
        <td><b>Ref</b></td>
        <td><%= recordBean.getTree_ref() %></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Seq</b></td>
        <td><%= compTreeDetailsBean.getTr_no() %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Round</b></td>
        <td><%= round_c %></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Desc</b></td>
        <td><%= compTreeDetailsBean.getTree_desc() %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Pos</b></td>
        <td><%= compTreeDetailsBean.getPosition() %></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Pos Ref</b></td>
        <td><%= compTreeDetailsBean.getPosition_ref() %></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <%-- Trees Static Descriptions --%>
      <tr bgcolor="#ecf5ff">
        <td><b>Species</b></td>
        <td><%= species_desc %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Age</b></td>
        <td><%= age_desc %></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <app:equalsInitParameter name="sutton_tree_fields" match="Y">
          <td><b>Spread</b></td>
        </app:equalsInitParameter>
        <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
          <td><b>Crown</b></td>
        </app:equalsInitParameter>
        <td><%= crown_desc %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Height</b></td>
        <td><%= height_desc %></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <app:equalsInitParameter name="sutton_tree_fields" match="Y">
          <td><b>Cond P/S</b></td>
        </app:equalsInitParameter>
        <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
          <td><b>Cond</b></td>
        </app:equalsInitParameter>
        <td><%= condition_desc %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>DBH</b></td>
        <td><%= dbh_desc %></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <app:equalsInitParameter name="sutton_tree_fields" match="Y">
          <td><b>Life</b></td>
        </app:equalsInitParameter>
        <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
          <td><b>Vigour</b></td>
        </app:equalsInitParameter>
        <td><%= vigour_desc %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <app:equalsInitParameter name="sutton_tree_fields" match="Y">
          <td><b>Base Type</b></td>
        </app:equalsInitParameter>
        <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
          <td><b>Paving</b></td>
        </app:equalsInitParameter>
        <td><%= pavement_desc %></td>
      </tr>
      <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
        <tr bgcolor="#ecf5ff">
          <td><b>Boundary</b></td>
          <td><%= boundary_desc %></td>
        </tr>
        <tr bgcolor="#ffffff">
          <td><b>Building</b></td>
          <td><%= building_desc %></td>
        </tr>
      </app:equalsInitParameter>
      <tr bgcolor="#ecf5ff">
        <td><b>Issue</b></td>
        <td><%= issue_desc %></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <%-- Show the user where they are if using maps --%>
      <app:equalsInitParameter name="use_map" match="Y" >
        <% String xWorldCenter = easting; %>
        <% String yWorldCenter = northing; %>
        <tr>
          <td colspan="2">
            <%
              // obtain the initial context, which holds the server/web.xml environment variables.
              Context initCtx = new InitialContext();
              Context envCtx = (Context) initCtx.lookup("java:comp/env");
        
              // Put all values that are going to be used in the <c:import ...> call, into the pageContext
              // So that the <c:import ...> tag can access them. All others into variables.
              String map_service = (String)envCtx.lookup("map_service");
              String map_type = (String)envCtx.lookup("map_type");
              String start_zoom = (String)envCtx.lookup("start_zoom");
              String xPixels = (String)envCtx.lookup("x_pixels");
              String yPixels = (String)envCtx.lookup("y_pixels");
              String show_map_type = (String)envCtx.lookup("show_map_type");
            %>
       
            <%-- Setup the different zoom rounding for the different map types --%>
            <if:IfTrue cond='<%= map_type.equals("cartology") || map_type.equals("WMS") %>' >
              <% start_zoom = String.valueOf(helperBean.roundDouble((new Double(start_zoom)).doubleValue(),1)); %>
            </if:IfTrue>
            <if:IfTrue cond='<%= map_type.equals("googleMaps") || map_type.equals("multimap") %>' >
              <% start_zoom = String.valueOf(Math.round((new Double(start_zoom)).doubleValue())); %>
            </if:IfTrue>
 
            <img width="<%= xPixels %>" height="<%= yPixels %>" alt="No map data available" 
                 src='<%= map_service + 
                     "?E=" + xWorldCenter +
                     "&N=" + yWorldCenter +
                     "&Z=" + start_zoom +
                     "&X=" + xPixels +
                     "&Y=" + yPixels +
                     "&M=" + show_map_type %>' />
            <if:IfTrue cond='<%= map_type.equals("multimap") %>' >
              <br/>
              <a href="http://clients.multimap.com/about/legal_and_copyright/">Terms of use</a>
            </if:IfTrue>
          </td>
        </tr>
        <tr><td colspan="2">&nbsp;</td></tr>
      </app:equalsInitParameter>
      <%-- Easting and Northing --%>
      <tr bgcolor="#ecf5ff">
        <td><b>E</b></td>
        <td><%= easting %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>N</b></td>
        <td><%= northing %></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
    </table>
    <jsp:include page="include/back_button.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="compTreeDetails" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>

</html>
