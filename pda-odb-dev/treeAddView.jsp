<%@ page errorPage="error.jsp" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.vsb.treeAddBean, com.vsb.treesListBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"          prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>

<jsp:useBean id="treeAddBean" scope="session" class="com.vsb.treeAddBean" />
<jsp:useBean id="treesListBean"   scope="session" class="com.vsb.treesListBean" />
<jsp:useBean id="recordBean"      scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"      scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="treeAdd" value="false">
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
  <title>treeAdd</title>
  <style type="text/css">
    @import url("global.css");
  </style>
  <!-- Disable the browser back button -->
  <script type="text/javascript">window.history.go(1);</script>
  <script type="text/javascript" src="http://localhost:5151/gps"></script>
  <script type="text/javascript">
    function update() {
      document.forms[0].elements["gpsLat"].value = gpsLat;
      document.forms[0].elements["gpsLng"].value = gpsLng;
    }
  </script>
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

<body onUnload="" onLoad="update()">
  <form onSubmit="return singleclick();" action="treeAddScript.jsp" method="post">
    <%-- Title --%>
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Add Tree</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="treeAddBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>      
    </table>
    <%-- Site Name --%>
    <table width="100%">
      <tr>
        <td align="center"><b><%= recordBean.getSite_name_1() %></b></td>
      </tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
    </table>
    <%-- Tree Details --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
    <table width="100%">
      <tr bgcolor="#ffffff">
        <td><b>Ref</b></td>
        <td><%= treeAddBean.getTree_ref() %></td>
        <input type="hidden" name="tree_ref" value="<%= treeAddBean.getTree_ref() %>" />
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Seq</b></td>
        <td>
          <input type="text" name="tr_no" maxlength="4" size="4"
            value="<%= treeAddBean.getTr_no() %>" />
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Round</b></td>
        <td>
          <input type="text" name="round_c" maxlength="10" size="10"
            value="<%= treeAddBean.getRound_c() %>" />
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Desc</b></td>
        <td><%= treeAddBean.getTree_desc() %></td>
        <input type="hidden" name="tree_desc" value="<%= treeAddBean.getTree_desc() %>" />
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Pos</b></td>
        <td>
          <input type="text" name="position" maxlength="50" size="18"
            value="<%= treeAddBean.getPosition() %>" />
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Pos Ref</b></td>
        <td>
          <input type="text" name="position_ref" maxlength="10" size="18"
            value="<%= treeAddBean.getPosition_ref() %>" />
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Frequency</b></td>
        <td>
          <select name="frequency">
            <option value="" selected="selected" ></option>
          <%-- Get the frequency description --%>
          <sql:query>
            SELECT frequency, freq_basis, description
            FROM trees_freq_look
            ORDER BY description
          </sql:query>
          <sql:resultSet id="rset">
            <% String frequency = ""; %>
            <% String freq_basis = ""; %>
            <% String ref = ""; %>
            <sql:getColumn position="1" to="frequency" />
            <sql:wasNotNull>
              <% frequency = ((String)pageContext.getAttribute("frequency")).trim(); %>
            </sql:wasNotNull>
            <sql:getColumn position="2" to="freq_basis" />
            <sql:wasNotNull>
              <% freq_basis = ((String)pageContext.getAttribute("freq_basis")).trim(); %>
            </sql:wasNotNull>
            <% ref = frequency + "|" + freq_basis; %>
            <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getFrequency()) %>' >
              <option value="<%= ref %>" selected="selected" ><sql:getColumn position="3" /></option>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getFrequency()) %>' >
              <option value="<%= ref %>"><sql:getColumn position="3" /></option>
            </if:IfTrue>
          </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Next Due</b></td>
        <td>
          <input type="text" name="view_next_due" maxlength="10" size="10"
            value="<%= treeAddBean.getView_next_due() %>" /><br/>(<%= application.getInitParameter("view_date_fmt") %>)
          <input type="hidden" name="next_due" value="<%= treeAddBean.getNext_due() %>" />
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <%-- Trees Static Descriptions --%>
      <tr bgcolor="#ecf5ff">
        <td><b>Species</b></td>
        <td>
          <select name="species_ref">
            <option value="" selected="selected" ></option>
          <%-- Get the species description --%>
          <sql:query>
            SELECT species_ref, species_desc
            FROM trees_species 
            ORDER BY species_desc
          </sql:query>
          <sql:resultSet id="rset">
            <% String ref = ""; %>
            <sql:getColumn position="1" to="ref" />
            <sql:wasNotNull>
              <% ref = ((String)pageContext.getAttribute("ref")).trim(); %>
            </sql:wasNotNull>
            <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getSpecies_ref()) %>' >
              <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getSpecies_ref()) %>' >
              <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
            </if:IfTrue>
          </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Age</b></td>
        <td>
          <select name="age_ref">
            <option value="" selected="selected" ></option>
          <%-- Get the species description --%>
          <sql:query>
            SELECT age_ref, age_desc
            FROM trees_age
            ORDER BY age_desc
          </sql:query>
          <sql:resultSet id="rset">
            <% String ref = ""; %>
            <sql:getColumn position="1" to="ref" />
            <sql:wasNotNull>
              <% ref = ((String)pageContext.getAttribute("ref")).trim(); %>
            </sql:wasNotNull>
            <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getAge_ref()) %>' >
              <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getAge_ref()) %>' >
              <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
            </if:IfTrue>
          </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <app:equalsInitParameter name="sutton_tree_fields" match="Y">
          <td><b>Spread</b></td>
        </app:equalsInitParameter>
        <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
          <td><b>Crown</b></td>
        </app:equalsInitParameter>
        <td>
          <select name="crown_ref">
            <option value="" selected="selected" ></option>
          <%-- Get the species description --%>
          <sql:query>
            SELECT crown_ref, crown_desc
            FROM trees_crown
            ORDER BY crown_desc
          </sql:query>
          <sql:resultSet id="rset">
            <% String ref = ""; %>
            <sql:getColumn position="1" to="ref" />
            <sql:wasNotNull>
              <% ref = ((String)pageContext.getAttribute("ref")).trim(); %>
            </sql:wasNotNull>
            <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getCrown_ref()) %>' >
              <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getCrown_ref()) %>' >
              <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
            </if:IfTrue>
          </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Height</b></td>
        <td>
          <select name="height_ref">
            <option value="" selected="selected" ></option>
          <%-- Get the height description --%>
          <sql:query>
            SELECT height_ref, height_desc
            FROM trees_height 
            ORDER BY height_desc
          </sql:query>
          <sql:resultSet id="rset">
            <% String ref = ""; %>
            <sql:getColumn position="1" to="ref" />
            <sql:wasNotNull>
              <% ref = ((String)pageContext.getAttribute("ref")).trim(); %>
            </sql:wasNotNull>
            <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getHeight_ref()) %>' >
              <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getHeight_ref()) %>' >
              <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
            </if:IfTrue>
          </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <app:equalsInitParameter name="sutton_tree_fields" match="Y">
          <td><b>Cond P/S</b></td>
        </app:equalsInitParameter>
        <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
          <td><b>Cond</b></td>
        </app:equalsInitParameter>
        <td>
          <select name="condition_ref">
            <option value="" selected="selected" ></option>
          <%-- Get the condition description --%>
          <sql:query>
            SELECT condition_ref, condition_desc
            FROM trees_condition 
            ORDER BY condition_desc
          </sql:query>
          <sql:resultSet id="rset">
            <% String ref = ""; %>
            <sql:getColumn position="1" to="ref" />
            <sql:wasNotNull>
              <% ref = ((String)pageContext.getAttribute("ref")).trim(); %>
            </sql:wasNotNull>
            <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getCondition_ref()) %>' >
              <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getCondition_ref()) %>' >
              <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
            </if:IfTrue>
          </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>DBH</b></td>
        <td>
          <select name="dbh_ref">
            <option value="" selected="selected" ></option>
          <%-- Get the dbh description --%>
          <sql:query>
            SELECT dbh_ref, dbh_desc
            FROM trees_dbh 
            ORDER BY dbh_desc
          </sql:query>
          <sql:resultSet id="rset">
            <% String ref = ""; %>
            <sql:getColumn position="1" to="ref" />
            <sql:wasNotNull>
              <% ref = ((String)pageContext.getAttribute("ref")).trim(); %>
            </sql:wasNotNull>
            <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getDbh_ref()) %>' >
              <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getDbh_ref()) %>' >
              <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
            </if:IfTrue>
          </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <app:equalsInitParameter name="sutton_tree_fields" match="Y">
          <td><b>Life</b></td>
        </app:equalsInitParameter>
        <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
          <td><b>Vigour</b></td>
        </app:equalsInitParameter>
        <td>
          <select name="vigour_ref">
            <option value="" selected="selected" ></option>
          <%-- Get the vigour description --%>
          <sql:query>
            SELECT vigour_ref, vigour_desc
            FROM trees_vigour 
            ORDER BY vigour_desc
          </sql:query>
          <sql:resultSet id="rset">
            <% String ref = ""; %>
            <sql:getColumn position="1" to="ref" />
            <sql:wasNotNull>
              <% ref = ((String)pageContext.getAttribute("ref")).trim(); %>
            </sql:wasNotNull>
            <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getVigour_ref()) %>' >
              <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getVigour_ref()) %>' >
              <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
            </if:IfTrue>
          </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <app:equalsInitParameter name="sutton_tree_fields" match="Y">
          <td><b>Base Type</b></td>
        </app:equalsInitParameter>
        <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
          <td><b>Paving</b></td>
        </app:equalsInitParameter>
        <td>
          <select name="pavement_ref">
            <option value="" selected="selected" ></option>
          <%-- Get the pavement description --%>
          <sql:query>
            SELECT pavement_ref, pavement_desc
            FROM trees_pavement 
            ORDER BY pavement_desc
          </sql:query>
          <sql:resultSet id="rset">
            <% String ref = ""; %>
            <sql:getColumn position="1" to="ref" />
            <sql:wasNotNull>
              <% ref = ((String)pageContext.getAttribute("ref")).trim(); %>
            </sql:wasNotNull>
            <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getPavement_ref()) %>' >
              <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getPavement_ref()) %>' >
              <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
            </if:IfTrue>
          </sql:resultSet>
          </select>
        </td>
      </tr>
      <app:equalsInitParameter name="sutton_tree_fields" match="Y" value="false">
        <tr bgcolor="#ecf5ff">
          <td><b>Boundary</b></td>
          <td>
            <select name="boundary_ref">
            <option value="" selected="selected" ></option>
            <%-- Get the boundary description --%>
            <sql:query>
              SELECT boundary_ref, boundary_desc
              FROM trees_boundary 
              ORDER BY boundary_desc
            </sql:query>
            <sql:resultSet id="rset">
              <% String ref = ""; %>
              <sql:getColumn position="1" to="ref" />
              <sql:wasNotNull>
                <% ref = ((String)pageContext.getAttribute("ref")).trim(); %>
              </sql:wasNotNull>
              <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getBoundary_ref()) %>' >
                <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
              </if:IfTrue>
              <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getBoundary_ref()) %>' >
                <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
              </if:IfTrue>
            </sql:resultSet>
            </select>
          </td>
        </tr>
        <tr bgcolor="#ffffff">
          <td><b>Building</b></td>
          <td>
            <select name="building_ref">
            <option value="" selected="selected" ></option>
            <%-- Get the building description --%>
            <sql:query>
              SELECT building_ref, building_desc
              FROM trees_building 
              ORDER BY building_desc
            </sql:query>
            <sql:resultSet id="rset">
              <% String ref = ""; %>
              <sql:getColumn position="1" to="ref" />
              <sql:wasNotNull>
                <% ref = ((String)pageContext.getAttribute("ref")).trim(); %>
              </sql:wasNotNull>
              <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getBuilding_ref()) %>' >
                <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
              </if:IfTrue>
              <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getBuilding_ref()) %>' >
                <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
              </if:IfTrue>
            </sql:resultSet>
            </select>
          </td>
        </tr>
      </app:equalsInitParameter>
      <app:equalsInitParameter name="sutton_tree_fields" match="Y">
        <%-- the boundary_ref and building_ref are not shown, but still need it so --%>
        <%-- that addUpdateTreeFunc works correctly --%>
        <input type="hidden" name="boundary_ref" value="<%= treeAddBean.getBoundary_ref() %>" />
        <input type="hidden" name="building_ref" value="<%= treeAddBean.getBuilding_ref() %>" />
      </app:equalsInitParameter>
      <tr bgcolor="#ecf5ff">
        <td><b>Issue</b></td>
        <td>
          <select name="issue_ref">
            <option value="" selected="selected" ></option>
          <%-- Get the issue description --%>
          <sql:query>
            SELECT issue_ref, issue_desc
            FROM trees_issue
            ORDER BY issue_desc
          </sql:query>
          <sql:resultSet id="rset">
            <% String ref = ""; %>
            <sql:getColumn position="1" to="ref" />
            <sql:wasNotNull>
              <% ref = ((String)pageContext.getAttribute("ref")).trim(); %>
            </sql:wasNotNull>
            <if:IfTrue cond='<%= ref.trim().equals(treeAddBean.getIssue_ref()) %>' >
              <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! ref.trim().equals(treeAddBean.getIssue_ref()) %>' >
              <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
            </if:IfTrue>
          </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <%-- Show the user where they are if using maps --%>
      <app:equalsInitParameter name="use_map" match="Y" >
        <% String xWorldCenter = treeAddBean.getEasting(); %>
        <% String yWorldCenter = treeAddBean.getNorthing(); %>
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
        <td><%= treeAddBean.getEasting() %></td>
        <input type="hidden" name="easting" value="<%= treeAddBean.getEasting() %>" />
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>N</b></td>
        <td><%= treeAddBean.getNorthing() %></td>
        <input type="hidden" name="northing" value="<%= treeAddBean.getNorthing() %>" />
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
    </table>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- the osmapref is not shown, but still need it so that addUpdateTreeFunc works correctly --%>
    <input type="hidden" name="osmapref" value="<%= treeAddBean.getOsmapref() %>" />

    <table width="100%">
      <tr>
        <td>
          <b>Text</b><br/>
          <textarea rows="4" cols="28" name="text" ><jsp:getProperty name="treeAddBean" property="text" /></textarea>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
    </table>
    <jsp:include page="include/add_button.jsp" flush="true" />
    <table width="100%">
      <tr><td>&nbsp;</td></tr>
    </table>
    <jsp:include page="include/back_gps_item_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="gpsLat" value="" />
    <input type="hidden" name="gpsLng" value="" />
    <input type="hidden" name="input" value="treeAdd" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>

</html>
