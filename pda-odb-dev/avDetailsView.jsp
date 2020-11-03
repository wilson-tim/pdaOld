<%@ page import="com.vsb.avDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="java.util.*, java.text.*, java.text.SimpleDateFormat" %>
<%@ page import="java.util.GregorianCalendar" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="avDetailsBean" scope="session" class="com.vsb.avDetailsBean" />
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
<sess:equalsAttribute name="form" match="avDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Set up the date variables --%>
<%
  // Set the default time zone to where we are, as the time zone
  // returned from sco is GMT+00:00 which is fine but doesn't mentioned
  // BST. So the default timezone has to be set to "Europe/London".
  // Any objects which use the timezone (like SimpleDateFormat) will then
  // be using the correct timezone.
  TimeZone dtz = TimeZone.getTimeZone("Europe/London");
  TimeZone.setDefault(dtz);

  // Create calendar to create the year drop down boxes.
  GregorianCalendar gregDate = new GregorianCalendar();
%>

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
  <title>avDetails</title>
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
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
  <form onSubmit="return singleclick();" action="avDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>AV Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="avDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td align="center"><b><jsp:getProperty name="recordBean" property="site_name_1" /></b></td></tr>
    </table>
    <br/>
    <%-- Get the Abandoned Vehivles Details using the complaint ID --%>
    <sql:query>
      SELECT car_id,
             make_ref,
             model_ref,
             colour_ref,
             date_stickered,
             time_stickered_h,
             time_stickered_m,
             vehicle_class,
             road_fund_flag,
             last_seq,
             how_long_there,
             vin,
             road_fund_valid
        FROM comp_av
       WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <%-- Setup page variables --%>
    <sql:resultSet id="rset">
      <sql:getColumn position="1"  to="car_id" />
      <sql:getColumn position="2"  to="make_ref" />
        <%-- Set make_ref to "" if it is not valid--%>
        <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("make_ref") ) %>'>
          <% pageContext.setAttribute("make_ref", ""); %>
        </if:IfTrue>
      <sql:getColumn position="3"  to="model_ref" />
        <%-- Set model_ref to "" if it is not valid--%>
        <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("model_ref") ) %>'>
          <% pageContext.setAttribute("model_ref", ""); %>
        </if:IfTrue>
      <sql:getColumn position="4"  to="colour_ref" />
        <%-- Set colour_ref to "" if it is not valid--%>
        <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("colour_ref") ) %>'>
          <% pageContext.setAttribute("colour_ref", ""); %>
        </if:IfTrue>
      <sql:getDate position="5"  to="date_stickered" format="<%= application.getInitParameter("db_date_fmt") %>" />
      <sql:getColumn position="6"  to="time_stickered_h" />
      <sql:getColumn position="7"  to="time_stickered_m" />
      <sql:getColumn position="8"  to="vehicle_class" />
      <sql:getColumn position="9"  to="road_fund_flag" />
      <sql:getColumn position="10" to="last_seq" />
        <%-- Set last_seq to "1" if it is not valid, there should 
             always be 1 history for an AV --%>
        <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("last_seq") ) %>'>
          <% pageContext.setAttribute("last_seq", "1"); %>
        </if:IfTrue>
      <sql:getColumn position="11" to="how_long_there" />
      <sql:getColumn position="12" to="vin" />
      <sql:getColumn position="13" to="date_taxed" />
    </sql:resultSet>
    
    <%-- Get the make description --%>
    <sql:query>
      SELECT make_desc
        FROM makes
       WHERE make_ref = <%= pageContext.getAttribute("make_ref") %>
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1"  to="make_desc" />
    </sql:resultSet>
    
    <%-- Get the model description --%>
    <sql:query>
      SELECT model_desc
        FROM models
       WHERE model_ref = <%= pageContext.getAttribute("model_ref") %>
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1"  to="model_desc" />
    </sql:resultSet>
    
    <%-- Get the colour description --%>
    <sql:query>
      SELECT colour_desc
        FROM colour
       WHERE colour_ref = <%= pageContext.getAttribute("colour_ref") %>
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1"  to="colour_desc" />
    </sql:resultSet>
    
    <%-- Get the last history information from the comp_av_hist table --%>
    <sql:query>
      SELECT status_ref,
             notes
        FROM comp_av_hist
       WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
         AND seq = <%= ((String)pageContext.getAttribute("last_seq")).trim() %>
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1"  to="status_ref" />
      <%-- Set colour_ref to "" if it is not valid--%>
      <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("status_ref") ) %>'>
        <% pageContext.setAttribute("status_ref", "NONE"); %>
      </if:IfTrue>
      <sql:getColumn position="2"  to="notes" />
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("status_ref", "NONE"); %>
    </sql:wasEmpty>
    
    <%-- Get the status description from the av_status table --%>
    <sql:query>
      SELECT description
        FROM av_status
       WHERE status_ref = '<%= ((String)pageContext.getAttribute("status_ref")).trim() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1"  to="status_description" />
    </sql:resultSet>

    <%-- Is the AV_NEXT_STATUS key switched ON. If it is we will need to restrict the --%>
    <%-- status options shown in the drop down list. --%>
    <sql:query>
      SELECT c_field
      FROM keys
      WHERE service_c = 'ALL'
      AND   keyname = 'AV_NEXT_STATUS'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="av_next_status" />
      <sql:wasNull>
        <% pageContext.setAttribute("av_next_status", "N"); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("av_next_status", "N"); %>
    </sql:wasEmpty>

    <%-- The AV prompt is used when initially creating an AV complaint --%>
    <sql:query>
      SELECT c_field
      FROM keys
      WHERE service_c = 'ALL'
      AND   keyname = 'AV_TYPE_PROMPT'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="av_type_prompt" />
      <sql:wasNull>
        <% pageContext.setAttribute("av_type_prompt", "N"); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("av_type_prompt", "N"); %>
    </sql:wasEmpty>    

    <%-- Check to see if the user can raise a Works Order --%>
    <sql:query>
      SELECT c_field
      FROM keys
      WHERE service_c = 'ALL'
      AND   keyname = 'AV WO USED'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="av_wo_used" />
      <sql:wasNull>
        <% pageContext.setAttribute("av_wo_used", "N"); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("av_wo_used", "N"); %>
    </sql:wasEmpty>

    <%-- Check to see if there is already a works order in place --%>
    <sql:query>
      SELECT dest_suffix
        FROM comp
       WHERE complaint_no = <%= recordBean.getComplaint_no() %>
    </sql:query>
    <sql:resultSet id="rest">
      <sql:getColumn position="1"  to="dest_suffix" />
      <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("dest_suffix") ) %>'>
        <% pageContext.setAttribute("dest_suffix",""); %>
      </if:IfTrue>
    </sql:resultSet>

    <%-- Display the Abandoned Vehicles details in the table below: --%>
    <table width="100%">
      <%-- Car ID Row (registration) --%>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>Car ID</b>
        </td>
        <td>
          <%-- Check that the value is valid --%>
          <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("car_id") ) %>'>
            <%= ((String)pageContext.getAttribute("car_id")).trim() %>
          </if:IfTrue>
        </td>
      </tr>
      <%-- Car Make Row --%>
      <tr bgcolor="#ffffff">
        <td>
          <b>Make</b>
        </td>
        <td>
          <%-- Check that the value is valid --%>
          <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("make_desc") ) %>'>
            <%= ((String)pageContext.getAttribute("make_desc")).trim() %>
          </if:IfTrue>
        </td>
      </tr>
      <%-- Car Model Row --%>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>Model</b>
        </td>
        <td>
          <%-- Check that the value is valid --%>
          <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("model_desc") ) %>'>
            <%= ((String)pageContext.getAttribute("model_desc")).trim() %>
          </if:IfTrue>
        </td>
      </tr>
      <%-- Car Colour Row --%>
      <tr  bgcolor="#ffffff">
        <td>
          <b>Colour</b>
        </td>
        <td>
          <%-- Check that the value is valid --%>
          <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("colour_desc") ) %>'>
            <%= ((String)pageContext.getAttribute("colour_desc")).trim() %>
          </if:IfTrue>
        </td>
      </tr>
      <%-- Car Class Row --%>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>Class</b>
        </td>
        <td>
          <%-- Check that the value is valid --%>
          <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("vehicle_class") ) %>'>
            <%= ((String)pageContext.getAttribute("vehicle_class")).trim() %>
          </if:IfTrue>
        </td>
      </tr>
      <%-- Car Current Status Row --%>
      <tr bgcolor="#ffffff">
        <td>
          <b>Status</b>
        </td>
        <td>
          <%-- Check that the value is valid --%>
          <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("status_description") ) %>'>
            <%= ((String)pageContext.getAttribute("status_description")).trim() %>
          </if:IfTrue>
        </td>
      </tr>
      <%-- If the Abandoned Vehicle has not been stickered, show the user
           the sticker check box --%>
      <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("date_stickered") ) %>'>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>Add Sticker</b>
        </td>
        <td>
          <if:IfTrue cond='<%= avDetailsBean.getIs_stickered().equals("Y") %>'>
            <input type="checkbox" 
                   name="is_stickered" 
                   id="is_stickered"
                   value="Y"
                   checked="checked"
            />
          </if:IfTrue>
          <if:IfTrue cond='<%= !avDetailsBean.getIs_stickered().equals("Y") %>'>
            <input type="checkbox" 
                   name="is_stickered" 
                   id="is_stickered"
                   value="Y"
            />
          </if:IfTrue>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td>
          <b>Stickered Date</b>
        </td>
        <td>
          <select name="av_stick_day">
            <option value=""></option>
            <% int av_stick_day = 0; %>
            <if:IfTrue cond='<%= !avDetailsBean.getAv_stick_day().equals("") %>'>
              <% av_stick_day = new Integer(avDetailsBean.getAv_stick_day()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=1; i<32; i++) { %>
              <if:IfTrue cond="<%= i == av_stick_day %>">
                <option value="<%= i %>" selected="selected"><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != av_stick_day %>">
                <option value="<%= i %>"><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
          &nbsp;
          <select name="av_stick_month">
            <option value=""></option>
            <% int av_stick_month = 0; %>
            <if:IfTrue cond='<%= !avDetailsBean.getAv_stick_month().equals("") %>'>
              <% av_stick_month = new Integer(avDetailsBean.getAv_stick_month()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=1; i<13; i++) { %>
              <if:IfTrue cond="<%= i == av_stick_month %>">
                <option value="<%= i %>" selected="selected" ><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != av_stick_month %>">
                <option value="<%= i %>" ><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
          &nbsp;
          <select name="av_stick_year">
            <option value=""></option>
            <% int av_stick_year = 0; %>
            <if:IfTrue cond='<%= !avDetailsBean.getAv_stick_year().equals("") %>'>
              <% av_stick_year = new Integer(avDetailsBean.getAv_stick_year()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=(gregDate.get(gregDate.YEAR)-1), k=i+3; i <= k; i++) { %>
              <if:IfTrue cond="<%= i == av_stick_year %>">
                <option value="<%= i %>" selected="selected" ><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != av_stick_year %>">
                <option value="<%= i %>" ><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>Stickered Time</b>
        </td>
        <td>
          <input type="text" name="av_stick_time_h" size="2"
              value="<jsp:getProperty name="avDetailsBean" property="av_stick_time_h" />" />
          &nbsp;:&nbsp;
          <input type="text" name="av_stick_time_m" size="2"
              value="<jsp:getProperty name="avDetailsBean" property="av_stick_time_m" />" />
        </td>
      </tr>
      </if:IfTrue>
      <%-- Sticker Row, if the Abandoned Vehicle has been stickered --%>
      <%-- Displays the date and time the vehicle was stickered --%>
      <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("date_stickered") ) %>'>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>Stickered</b>
        </td>
        <td>
          <%= helperBean.dispDate( ((String)pageContext.getAttribute("date_stickered")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
          <%= ((String)pageContext.getAttribute("time_stickered_h")).trim() %>
          :
          <%= ((String)pageContext.getAttribute("time_stickered_m")).trim() %>
        </td>
      </tr>
      </if:IfTrue>
      <%-- Car Tax Row --%>
      <tr bgcolor="#ffffff">
        <td>
          <b>Tax</b>
        </td>
        <td>
          <%-- Check that the value is valid --%>
          <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("road_fund_flag") ) %>'>
            <%= ((String)pageContext.getAttribute("road_fund_flag")).trim() %>
          </if:IfTrue>
        </td>
      </tr>
      <%-- Car Tax Expiry Row --%>
      <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("date_taxed") ) %>'>
      <tr bgcolor="#ffffff">
        <td>
          <b>Tax Expiry</b>
        </td>
        <td>
          <%= helperBean.dispDate( ((String)pageContext.getAttribute("date_taxed")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
        </td>
      </tr>
      </if:IfTrue>
      <%-- Car VIN Row (vehicle registration) --%>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>VIN</b>
        </td>
        <td>
          <%-- Check that the value is valid --%>
          <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("vin") ) %>'>
            <%= ((String)pageContext.getAttribute("vin")).trim() %>
          </if:IfTrue>
        </td>
      </tr>
      <%-- Previous Text Notes Row--%>
      <%-- Display notes if they are valid --%> 
      <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("notes") ) %>'>
      <tr>
        <td colspan="2" bgcolor="#ffffff">
          <b>Previous Notes</b>
          <br/>
            <textarea rows="4" cols="28" name="previous_notes" readonly="readonly" ><%= 
              ((String)pageContext.getAttribute("notes")).trim() 
            %></textarea>
        </td>
      </tr>
      </if:IfTrue>
      <%-- Otherwise display 'None' --%> 
      <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("notes") ) %>'>
      <tr>
        <td bgcolor="#ffffff">
          <b>Previous Notes</b>
        </td>
        <td bgcolor="#ffffff">
          None
        </td>
      </tr>
      </if:IfTrue>
      <%-- Add Notes Row--%>
      <tr>
        <td colspan="2" bgcolor="#ecf5ff">
          <b>Notes</b>
          <br/>
            <textarea rows="4" cols="28" name="text"><jsp:getProperty 
                      name="avDetailsBean" property="text" /></textarea>
        </td>
      </tr>
    <%-- End Of Abandoned Vehicle Details --%>
    <br/>
    <%-- Create the Status drop down list. This list does not need to check --%>
    <%-- the AV_TYPE_PROMPT as we have already created the initial AV status. --%>
    <%-- We only need to check the AV_NEXT_STATUS key --%>
      <tr>
        <td bgcolor="#ffffff">
          <b>Status</b>
        </td>
        <td bgcolor="#ffffff">
          <select name="status_ref">
            <option value="" selected="selected" ></option>
              <%-- Check av_next_status = 'Y' display status's that are allowed from 'NONE' --%>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("av_next_status")).trim().equals("Y") %>'>
                <sql:query>
                  SELECT next_lookup_code
                    FROM allk_avstat_link
                   WHERE lookup_code = '<%= ((String)pageContext.getAttribute("status_ref")).trim() %>'
                </sql:query>
              </if:IfTrue>
              <%-- Check av_next_status = 'N', display all status's --%>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("av_next_status")).trim().equals("N") %>'>
                <sql:query>
                  SELECT status_ref
                    FROM av_status
                   ORDER BY status_ref
                </sql:query>
              </if:IfTrue>
              <%-- Depending on the system keys, display the allowed status's for creating a new AV Complaint--%>
              <sql:resultSet id="rset">              
                <sql:getColumn position="1" to="avStatus_ref" />
                <sql:wasNull>
                   <% pageContext.setAttribute("avStatus_ref", ""); %>
                </sql:wasNull>
                <if:IfTrue cond='<%= ((String)pageContext.getAttribute("avStatus_ref")).trim().equals(recordBean.getAv_status_ref()) %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="1" /></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= !(((String)pageContext.getAttribute("avStatus_ref")).trim().equals(recordBean.getAv_status_ref())) %>' >
                  <option value="<sql:getColumn position="1" />"><sql:getColumn position="1" /></option>
                </if:IfTrue>
              </sql:resultSet>               
          </select>
        </td>
      </tr>

      <tr><td>&nbsp;</td></tr>
      <tr>
        <td>
          <b><input type="submit" name="action" value="Add Another Status"
            style="font-weight:bold; width: 18em; font-size: 85%" /></b>
        </td>
      </tr>

    </table>
    <br/>
    <%-- Check to see if the AV module is switched on before offering further functionality --%>
    <if:IfTrue cond='<%= application.getInitParameter("use_av").equals("Y") %>' >
      <%-- If there is already a works order for this complaint, then do not allow the user to create a new one, --%>
      <%-- or if the system key 'AV_WO_USED is set to 'N' --%>
      <if:IfTrue cond='<%= ((String)pageContext.getAttribute("dest_suffix")).trim().equals("W") ||
                           (!((String)pageContext.getAttribute("av_wo_used")).trim().equals("Y"))  %>'>
        <jsp:include page="include/back_hist_finish_buttons.jsp" flush="true" />
      </if:IfTrue>
      <%-- If there is no suffix 'W' or and the System key 'AV_WO_USED' is set to 'Y'
           then allow the user to create a new Works Order --%>
      <if:IfTrue cond='<%= (!((String)pageContext.getAttribute("dest_suffix")).trim().equals("W")) &&
                             ((String)pageContext.getAttribute("av_wo_used")).trim().equals("Y") %>'>
        <jsp:include page="include/hist_wo_buttons.jsp" flush="true" />
        <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
      </if:IfTrue>
    </if:IfTrue>
    <%-- If the AV module is off, only show the back button from this page --%>
    <if:IfTrue cond='<%= application.getInitParameter("use_av").equals("N") %>' >
      <jsp:include page="include/back_button.jsp" flush="true" />
    </if:IfTrue>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="avDetails" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
  </sql:statement>
  <sql:closeConnection conn="con"/>
</body>
</html>
