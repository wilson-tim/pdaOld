<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.avAddDetailsBean, com.vsb.recordBean" %>
<%@ page import="java.util.*, java.text.*, java.text.SimpleDateFormat" %>
<%@ page import="java.util.GregorianCalendar" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="avAddDetailsBean" scope="session" class="com.vsb.avAddDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="avAddDetails" value="false">
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
  <title>avAddDetails</title>
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
  <form onSubmit="return singleclick();" action="avAddDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>AV Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="avAddDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td align="center"><b><jsp:getProperty name="recordBean" property="site_name_1" /></b></td></tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
    </table>
    <br/>
    <table width="100%">
      <tr bgcolor="#ecf5ff">
        <td>
          <b>No Car ID</b>
        </td>
        <td>
          <if:IfTrue cond='<%= avAddDetailsBean.getNo_id().equals("NO PLATES") %>'>
            <input type="checkbox" name="no_id" id="no_id" value="NO PLATES" checked="checked" />
          </if:IfTrue>
          <if:IfTrue cond='<%= avAddDetailsBean.getNo_id().equals("") %>'>
            <input type="checkbox" name="no_id" id="no_id" value="NO PLATES" />
          </if:IfTrue>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td>
          <b>Car ID</b>
        </td>
        <td>
          <if:IfTrue cond='<%= avAddDetailsBean.getNo_id().equals("NO PLATES") && 
                               avAddDetailsBean.getCar_id().equals("") %>'>
            <input type="text" name="car_id" size="8" value="NO PLATES" />
          </if:IfTrue>
          <if:IfTrue cond='<%= !avAddDetailsBean.getNo_id().equals("NO PLATES") || 
                               !avAddDetailsBean.getCar_id().equals("") %>'>
            <input type="text" name="car_id" size="8" value="<%= avAddDetailsBean.getCar_id() %>" />
          </if:IfTrue>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>Make</b>
        </td>
        <td>
          <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
          <sql:statement id="stmt" conn="con">
            <sql:query>
              select make_desc
              from makes
              where make_ref = <%= recordBean.getAv_make_ref() %>
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="make_desc" />
              <%= ((String)pageContext.getAttribute("make_desc")).trim() %>
            </sql:resultSet>
          </sql:statement> 
          <sql:closeConnection conn="con"/>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td>
          <b><jsp:getProperty name="recordBean" property="make_desc" /> Model</b>
        </td>
        <td>
          <select name="model_ref">
            <option value="" selected="selected" ></option>
            <sql:query>
              select model_desc,
                     model_ref
              from models
              where make_ref = '<%= recordBean.getAv_make_ref() %>'
              order by model_desc
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="2" to="model_ref" />
              <% String model_ref = ((String)pageContext.getAttribute("model_ref")).trim(); %>
              <if:IfTrue cond='<%= model_ref != null && !model_ref.equals("") %>' >
                <if:IfTrue cond='<%= model_ref.equals(avAddDetailsBean.getModel_ref()) %>' >
                  <option value="<sql:getColumn position="2" />" selected="selected" ><sql:getColumn position="1" /></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= !model_ref.equals(avAddDetailsBean.getModel_ref()) %>' >
                  <option value="<sql:getColumn position="2" />"><sql:getColumn position="1" /></option>
                </if:IfTrue>
              </if:IfTrue>
            </sql:resultSet>
            <sql:wasEmpty>
              <option value="No Models Found" selected="selected" ></option>
            </sql:wasEmpty>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>Colour</b>
        </td>
        <td>
          <select name="colour_ref">
            <option value="" selected="selected" ></option>
            <sql:query>
              select colour_desc,
                     colour_ref
              from colour
              order by colour_desc
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="2" to="colour_ref" />
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("colour_ref")).trim().equals(avAddDetailsBean.getColour_ref()) %>' >
                <option value="<sql:getColumn position="2" />" selected="selected" ><sql:getColumn position="1" /></option>
              </if:IfTrue>
              <if:IfTrue cond='<%= !((String)pageContext.getAttribute("colour_ref")).trim().equals(avAddDetailsBean.getColour_ref()) %>' >
                <option value="<sql:getColumn position="2" />"><sql:getColumn position="1" /></option>
              </if:IfTrue>
             </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td>
          <b>Stickered</b>
        </td>
        <td>
          <if:IfTrue cond='<%= avAddDetailsBean.getIs_stickered().equals("Y") %>'>
            <input type="checkbox" 
                   name="is_stickered" 
                   id="is_stickered"
                   value="Y"
                   checked="checked"
            />
          </if:IfTrue>
          <if:IfTrue cond='<%= !avAddDetailsBean.getIs_stickered().equals("Y") %>'>
            <input type="checkbox" 
                   name="is_stickered" 
                   id="is_stickered"
                   value="Y"
            />
          </if:IfTrue>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>Stickered Date</b>
        </td>
        <td>
          <select name="av_stick_day">
            <option value=""></option>
            <% int av_stick_day = 0; %>
            <if:IfTrue cond='<%= !avAddDetailsBean.getAv_stick_day().equals("") %>'>
              <% av_stick_day = new Integer(avAddDetailsBean.getAv_stick_day()).intValue(); %>
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
            <if:IfTrue cond='<%= !avAddDetailsBean.getAv_stick_month().equals("") %>'>
              <% av_stick_month = new Integer(avAddDetailsBean.getAv_stick_month()).intValue(); %>
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
            <if:IfTrue cond='<%= !avAddDetailsBean.getAv_stick_year().equals("") %>'>
              <% av_stick_year = new Integer(avAddDetailsBean.getAv_stick_year()).intValue(); %>
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
      <tr bgcolor="#ffffff">
        <td>
          <b>Stickered Time</b>
        </td>
        <td>
          <input type="text" name="av_stick_time_h" size="2"
              value="<jsp:getProperty name="avAddDetailsBean" property="av_stick_time_h" />" />
          :
          <input type="text" name="av_stick_time_m" size="2"
              value="<jsp:getProperty name="avAddDetailsBean" property="av_stick_time_m" />" />
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>Tax Displayed</b>
        </td>
        <td>
          <if:IfTrue cond='<%= avAddDetailsBean.getIs_taxed().equals("Y") %>'>
            <input type="checkbox" 
                   name="is_taxed" 
                   id="is_taxed"
                   value="Y"
                   checked="checked"
            />
          </if:IfTrue>
          <if:IfTrue cond='<%= !avAddDetailsBean.getIs_taxed().equals("Y") %>'>
            <input type="checkbox" 
                   name="is_taxed" 
                   id="is_taxed"
                   value="Y"
            />
          </if:IfTrue>
        </td>
      </tr>
      <tr bgcolor="#ffffff">
        <td>
          <b>Tax Expiry Date</b>
        </td>
        <td>
          <select name="av_tax_day">
            <option value=""></option>
            <% int av_tax_day = 0; %>
            <if:IfTrue cond='<%= !avAddDetailsBean.getAv_tax_day().equals("") %>'>
              <% av_tax_day = new Integer(avAddDetailsBean.getAv_tax_day()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=28; i<32; i++) { %>
              <if:IfTrue cond="<%= i == av_tax_day %>">
                <option value="<%= i %>" selected="selected"><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != av_tax_day %>">
                <option value="<%= i %>"><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
          &nbsp;
          <select name="av_tax_month">
            <option value=""></option>
            <% int av_tax_month = 0; %>
            <if:IfTrue cond='<%= !avAddDetailsBean.getAv_tax_month().equals("") %>'>
              <% av_tax_month = new Integer(avAddDetailsBean.getAv_tax_month()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=1; i<13; i++) { %>
              <if:IfTrue cond="<%= i == av_tax_month %>">
                <option value="<%= i %>" selected="selected" ><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != av_tax_month %>">
                <option value="<%= i %>" ><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
          &nbsp;
          <select name="av_tax_year">
            <option value=""></option>
            <% int av_tax_year = 0; %>
            <if:IfTrue cond='<%= !avAddDetailsBean.getAv_tax_year().equals("") %>'>
              <% av_tax_year = new Integer(avAddDetailsBean.getAv_tax_year()).intValue(); %>
            </if:IfTrue>
            <%  for (int i=(gregDate.get(gregDate.YEAR)-1), k=i+3; i <= k; i++) { %>
              <if:IfTrue cond="<%= i == av_tax_year %>">
                <option value="<%= i %>" selected="selected" ><%= i %></option>
              </if:IfTrue>
              <if:IfTrue cond="<%= i != av_tax_year %>">
                <option value="<%= i %>" ><%= i %></option>
              </if:IfTrue>
            <%  } %>
          </select>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td>
          <b>VIN</b>
        </td>
        <td>
          <input type="text" name="vin" size="22" maxlength="28" value="<%= avAddDetailsBean.getVin() %>" />
        </td>
      </tr>
    </table>
    <br/>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
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
    </sql:statement> 
    <sql:closeConnection conn="con"/>
    <table>
      <app:equalsInitParameter name="module" match="pda-in" >
        <table> 
          <tr>
            <td colspan="2">
              <b>Action:</b>
              <select name="actionTaken">
                <option selected="selected" ></option>
                <option>Hold</option>
                <option>Inspect</option>
                <%-- Deliberately excluding Default / def_name_noun from the option list --%>
                <if:IfTrue cond='<%= ((String)pageContext.getAttribute("av_wo_used")).trim().equals("Y") %>'>
                  <option <%= "Works Order" %> >Works Order</option>
                </if:IfTrue>
                <option></option>
                <option>No Action</option>
              </select><br/><br/>
            </td>
          </tr>
        </table>
      </app:equalsInitParameter>
    </table>
    <br/>
    <jsp:include page="include/back_continue_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="avAddDetails" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
    <input type="hidden" name="av_stick_date" value="<%= avAddDetailsBean.getAv_stick_date() %>" />
    <input type="hidden" name="av_tax_date" value="<%= avAddDetailsBean.getAv_tax_date() %>" />
  </form>
  </sql:statement>
  <sql:closeConnection conn="con"/>
</body>
</html>
