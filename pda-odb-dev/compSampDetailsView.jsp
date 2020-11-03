<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.vsb.compSampDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="compSampDetailsBean" scope="session" class="com.vsb.compSampDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="compSampDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

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
  <title>compSampDetails</title>
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
  <form onSubmit="return singleclick();" action="compSampDetailsScript.jsp" method="post">
    <%-- Open database connection --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">

    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Complaint / Sample Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="compSampDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td align="center" colspan="2"><b><jsp:getProperty name="recordBean" property="site_name_1" /></b></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Item</b></td>
        <td><jsp:getProperty name="recordBean" property="item_ref" /></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td colspan="2"><jsp:getProperty name="recordBean" property="item_desc" /></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Enquiry Ref.</b></td>
        <td><%= recordBean.getComplaint_no() %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td colspan="2"><jsp:getProperty name="recordBean" property="comp_desc" /></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td colspan="2">
          <%-- Get the name for the position field, default to 'Exact Location' --%>
          <% String position = "Exact Location"; %>
          <sql:query>
            select c_field
            from keys
            where service_c = 'ALL'
            and   keyname = 'POSITION_TITLE'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="c_field" />
            <sql:wasNotNull>
              <% position = (String)pageContext.getAttribute("c_field"); %>
            </sql:wasNotNull>
            <sql:wasNull>
              <% position = "Exact Location"; %>
            </sql:wasNull>
          </sql:resultSet>
          <sql:wasEmpty>
            <% position = "Exact Location"; %>
          </sql:wasEmpty>

          <b><%= position %></b>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <input type="text" name="exact_location" maxlength="70" size="24"
            value="<%= recordBean.getExact_location() %>" />
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td colspan="2">
          <b>Source</b>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td colspan="2"><jsp:getProperty name="recordBean" property="source_desc" /></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
 
      <%-- Hway Defect details --%>
      <% boolean isDefect = false; %>
      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getHway_service()) %>' >
        <% String defect_fault_codes_string = ""; %>
        <%-- Get the fault codes that are allowed to have defects applied to them --%>
        <sql:query>
          SELECT c_field
            FROM keys
           WHERE keyname = 'MS_FAULT_CODES'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="c_field" />
          <sql:wasNotNull>
            <% defect_fault_codes_string = ((String)pageContext.getAttribute("c_field")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
  
        <%-- Create an arraylist of individual fault codes from the comma separated list --%>
        <% ArrayList defect_fault_codes = helperBean.splitCommaList( defect_fault_codes_string ); %>
	      <%-- Only show defect details if this Hway is a defect --%>
        <if:IfTrue cond='<%= defect_fault_codes.contains( recordBean.getComp_code() ) %>'>
          <%-- If the Defect X and Y values are blank, then assume that this is not a --%>
          <%-- defect and allow the item and fault to be changed. --%>
          <if:IfTrue cond='<%= recordBean.getDefect_view_x().equals("") && recordBean.getDefect_view_y().equals("")%>'>
            <% isDefect = false; %>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! recordBean.getDefect_view_x().equals("") || ! recordBean.getDefect_view_y().equals("")%>'>
            <% isDefect = true; %>
          </if:IfTrue>
    	  <tr bgcolor="#ecf5ff">
            <td><b>X Value</b></td>
            <td>
              <%= recordBean.getDefect_view_x() %>   
            </td>
          </tr>
          <tr bgcolor="#ffffff">
            <td><b>Y Value</b></td>
            <td>
              <%= recordBean.getDefect_view_y() %>   
            </td>
          </tr>
          <tr bgcolor="#ecf5ff">
            <td><b>Linear</b></td>
            <td>
              <%= recordBean.getDefect_view_linear() %>   
            </td>
          </tr>
          <tr bgcolor="#ffffff">
            <td><b>Area</b></td>
            <td>
              <%= recordBean.getDefect_view_area() %>   
            </td>
          </tr>
          <tr bgcolor="#ecf5ff">
            <td><b>Urgency</b></td>
            <td>
              <%= recordBean.getDefect_view_priority() %>   
            </td>
          </tr>
          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
        </if:IfTrue>
      </if:IfTrue>

      <tr bgcolor="#ecf5ff">
        <td><b>Item Volume</b></td>
        <td><%= recordBean.getTotal_volume() %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Date Raised</b></td>
        <td><%= helperBean.dispDate(recordBean.getComp_date(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Time Raised</b></td>
        <td><%= recordBean.getComp_time_h() %>:<%= recordBean.getComp_time_m() %></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Date Due</b></td>
        <td><%= helperBean.dispDate(recordBean.getDate_due(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Occur Day</b></td>
        <td><%= recordBean.getOccur_day() %></td>
      </tr>
    </table>
   
    <% String color="#ecf5ff"; %>
    <table width="100%">
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Occur Day</b></td>
        <td><b>Start Time</b></td>
        <td><b>End Time</b></td>
      </tr>
      <sql:query>
        select occur_day, start_time_h, start_time_m, end_time_h, end_time_m, seq_no
        from si_i_sched
        where site_ref = '<%= recordBean.getSite_ref() %>'
        and   item_ref = '<%= recordBean.getItem_ref() %>'
        and   feature_ref = '<%= recordBean.getFeature_ref() %>'
        and   contract_ref = '<%= recordBean.getContract_ref() %>'
        order by occur_day, seq_no
      </sql:query>
      <sql:resultSet id="rset">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>
        <tr bgcolor="<%= color %>">
          <sql:getColumn position="1" to="occur_day" />
          <td><%= helperBean.occurDayNames(((String)pageContext.getAttribute("occur_day")).trim()) %></td>
          <sql:getColumn position="2" to="start_time_h" />
          <sql:wasNull>
            <td>&nbsp;</td>
          </sql:wasNull>
          <sql:wasNotNull>
            <td><sql:getColumn position="2" />:<sql:getColumn position="3" /></td>
          </sql:wasNotNull>
          <sql:getColumn position="4" to="end_time_h" />
          <sql:wasNull>
            <td>&nbsp;</td>
          </sql:wasNull>
          <sql:wasNotNull>
            <td><sql:getColumn position="4" />:<sql:getColumn position="5" /></td>
          </sql:wasNotNull>
        </tr>
      </sql:resultSet>
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td>
          <b>Remarks</b><br/>
          <input type="text" name="remarks" maxlength="210" size="24"
            value="<%= compSampDetailsBean.getRemarks() %>" />
        </td>
      </tr>
      <tr>
        <td>
          <b>Previous Text</b><br/>
          <textarea rows="4" cols="28" name="textOut" readonly="readonly" ><jsp:getProperty name="compSampDetailsBean" property="textOut" /></textarea>
        </td>
      </tr>
      <tr>
        <td>
          <b>Text</b><br/>
          <textarea rows="4" cols="28" name="text" ><jsp:getProperty name="compSampDetailsBean" property="text" /></textarea>
        </td>
      </tr>
    </table>
    <table width="100%">
      <tr><td>&nbsp;</td></tr>
      <tr>
        <td>
          <b><input type="submit" name="action" value="Update Text"
            style="font-weight:bold; width: 18em; font-size: 85%" /></b>
        </td>
      </tr>
      <tr>
        <td>
          <b><input type="submit" name="action" value="Action"
            style="font-weight:bold; width: 18em; font-size: 85%" /></b>
        </td>
      </tr>
      <tr>
        <td>
          <b><input type="submit" name="action" value="No Further Action"
            style="font-weight:bold; width: 18em; font-size: 85%" /></b>
        </td>
      </tr>
      <tr>
        <td>
          <b><input type="submit" name="action" value="Place on Hold"
            style="font-weight:bold; width: 18em; font-size: 85%" /></b>
        </td>
      </tr>
      <%-- Don't allow complaints sent to inspect, to not be checked --%>
      <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("I") %>' >
        <tr>
          <td>
            <b><input type="submit" name="action" value="Not Checked"
              style="font-weight:bold; width: 18em; font-size: 85%" /></b>
          </td>
        </tr>
      </if:IfTrue>

      <%-- See if this is a Fly Capture record --%>
      <% int complaint_no = Integer.parseInt(recordBean.getComplaint_no()); %>
      <% boolean isFlyCap = false; %>
      <%-- Check for a Flycapture complaint --%>
      <sql:query>
        SELECT complaint_no
          FROM comp_flycap
         WHERE complaint_no = <%= complaint_no %>
      </sql:query>
      <sql:resultSet id="rset">
        <%-- do nothing --%>
      </sql:resultSet>
      <sql:wasNotEmpty>
        <% isFlyCap = true; %>
      </sql:wasNotEmpty>

      <%-- Only allow none flycapture, and defect, 'I' and 'P' complaints  --%>
      <%-- to change their item and fault codes. --%>
      <%-- 11/05/2010  TW  Split this condition to allow for conditional wording on button --%>
      <%-- if:IfTrue cond='<percent= isFlyCap == false && isDefect == false && (recordBean.getComp_action_flag().equals("I") || recordBean.getComp_action_flag().equals("P")) percent>' --%>
      <% boolean isInDiry = false; %>
      <sql:query>
        select date_due
        from diry
        where source_flag = 'C'
        and   source_ref = '<%= complaint_no %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getDate position="1" to="date_due" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <sql:wasNotNull>
          <% isInDiry = true; %>
        </sql:wasNotNull>
      </sql:resultSet>
      <if:IfTrue cond='<%= isFlyCap == false && isDefect == false && ( recordBean.getComp_action_flag().equals("P") || ( recordBean.getComp_action_flag().equals("I") && isInDiry == false ) ) %>'>
        <tr>
          <td>
            <b><input type="submit" name="action" value="Change Item/Fault"
              style="font-weight:bold; width: 18em; font-size: 85%" /></b>
          </td>
        </tr>
      </if:IfTrue>
      <if:IfTrue cond='<%= isFlyCap == false && isDefect == false && recordBean.getComp_action_flag().equals("I") && isInDiry == true %>'>
        <tr>
          <td>
            <b><input type="submit" name="action" value="Change Item/Fault/Insp. Date"
              style="font-weight:bold; width: 18em; font-size: 85%" /></b>
          </td>
        </tr>
      </if:IfTrue>

      <%-- AV's are sent to a works order via the avDetails screen - which is got to --%>
      <%-- via the 'Action' button - and NOT via the 'Add Works Order' button. --%>
      <if:IfTrue cond='<%= ! recordBean.getService_c().equals( recordBean.getAv_service() ) %>'>
        <tr><td>&nbsp;</td></tr>
        <tr><td>Add a works order:</td></tr>
        <tr>
          <td>
            <b><input type="submit" name="action" value="Add Works Order"
              style="font-weight:bold; width: 18em; font-size: 85%" /></b>
          </td>
        </tr>
      </if:IfTrue>
      <tr><td>&nbsp;</td></tr>
    </table>
    <%-- Use Map Module --%>
    <app:equalsInitParameter name="use_map" match="Y" >
      <%-- Check if we should display the trade details button --%>
      <%-- NOTE: If we end up adding more options here for different services, we should make the trade --%>
      <%-- button a generic services button, and poissibly have a switch to catch each different service. --%>
      <%-- TRADE Service --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals( recordBean.getTrade_service() ) %>'>
        <jsp:include page="include/map_trade_buttons.jsp" flush="true" />      
        <jsp:include page="include/back_cust_buttons.jsp" flush="true" />
      </if:IfTrue>
      <%-- TREES Service --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals( recordBean.getTrees_service() ) %>'>
        <jsp:include page="include/map_tree_buttons.jsp" flush="true" />      
        <jsp:include page="include/back_cust_buttons.jsp" flush="true" />      
      </if:IfTrue>
      <%-- No Special Service --%>
      <if:IfTrue cond='<%= (!(recordBean.getService_c().equals( recordBean.getTrade_service()) )) &&
                           (!(recordBean.getService_c().equals( recordBean.getTrees_service()) )) %>'>
        <jsp:include page="include/back_map_cust_buttons.jsp" flush="true" />
      </if:IfTrue>      
    </app:equalsInitParameter>
    <%-- Do not show map module button --%>
    <app:equalsInitParameter name="use_map" match="N" >
      <%-- TRADE Service --%>    
      <if:IfTrue cond='<%= recordBean.getService_c().equals( recordBean.getTrade_service() ) %>'>
        <jsp:include page="include/back_trade_cust_buttons.jsp" flush="true" />
      </if:IfTrue>
      <%-- TREES Service --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals( recordBean.getTrees_service() ) %>'>
        <jsp:include page="include/back_tree_cust_buttons.jsp" flush="true" />
      </if:IfTrue>
      <%-- No Special Service --%>
      <if:IfTrue cond='<%= (!(recordBean.getService_c().equals( recordBean.getTrade_service()) )) &&
                           (!(recordBean.getService_c().equals( recordBean.getTrees_service()) )) %>'>
        <jsp:include page="include/back_cust_buttons.jsp" flush="true" />
      </if:IfTrue>      
    </app:equalsInitParameter>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="compSampDetails" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />

    <%-- Close database connection --%>
    </sql:statement>
    <sql:closeConnection conn="con"/>

  </form>
</body>
</html>
