<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.graffDetailsBean, com.vsb.recordBean, com.vsb.surveyGradingBean" %>
<%@ page import="java.util.*, java.text.*, java.text.SimpleDateFormat" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="graffDetailsBean" scope="session" class="com.vsb.graffDetailsBean" />
<jsp:useBean id="surveyGradingBean" scope="session" class="com.vsb.surveyGradingBean" />
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
<sess:equalsAttribute name="form" match="graffDetails" value="false">
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
  Date today = new Date();
  GregorianCalendar gregDateToday = new GregorianCalendar();
  // Create a greg cal object for today
  gregDateToday.setTime(today);
  SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
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
  <title>graffDetails</title>
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
  <form onSubmit="return singleclick();" action="graffDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Graffiti Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="graffDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>

    <% String color="#ffffff"; %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
    <table cellpadding="2" cellspacing="0" width="100%">
      <tr>
        <td colspan="4" bgcolor="#ff6600" align="center">
          <h4><b>DETAILS OF WORK</b></h4>
        </td>
      </tr>

      <%-- Select Volume --%>
      <tr>
        <td colspan="4">
          <b>Amount of graffiti reported:</b>
        </td>
      </tr>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTVOL'
           AND status_yn = 'Y'
           ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>
        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="vol_code" />
            <% String vol_code = ((String)pageContext.getAttribute("vol_code")).trim(); %>
            <input type="radio" 
                   name="volume_ref" 
                   id="ERTVOL|<sql:getColumn position="1" />" 
                   value="<sql:getColumn position="1" />"
                   <if:IfTrue cond='<%= vol_code.equals(graffDetailsBean.getVolume_ref()) %>' >
                     checked="checked" 
                   </if:IfTrue>
            />
          </td>
          <td valign="top">
            <label for="ERTVOL|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTVOL|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="4">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Now select Material --%>
      <% color="#ffffff"; %>
      <%-- Get the material --%>
      <% String[] ref_ertsur = graffDetailsBean.getRef_ertsur(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_ref_ertsur = new HashMap(); %>
      <%
        if (ref_ertsur != null) {
          for(int i=0; i < ref_ertsur.length; i++) {
            // check for a none null quantity
            if (ref_ertsur[i] != null) {
              hash_ref_ertsur.put(ref_ertsur[i], ref_ertsur[i]);
            }
          }
        }
      %>
      
      <tr>
        <td colspan="4">
          <b>Surface graffiti is on:</b>
        </td>
      </tr>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTSUR'
           AND status_yn = 'Y'
           ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>
        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="lookup_code" />
            <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
            <if:IfTrue cond='<%= ref_ertsur != null %>' >
              <input type="checkbox" 
                     name="ref_ertsur" 
                     id="ERTSUR|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" 
                     <if:IfTrue cond='<%= hash_ref_ertsur.containsKey(lookup_code) %>' >
                       checked="checked" 
                     </if:IfTrue>
              />
            </if:IfTrue>
            <if:IfTrue cond='<%= ref_ertsur == null %>' >
              <input type="checkbox" 
                     name="ref_ertsur" 
                     id="ERTSUR|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="ERTSUR|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTSUR|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="4">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
      
      <%-- Now select Material --%>
      <% color="#ffffff"; %>
      <%-- Get the material --%>
      <% String[] ref_ertmat = graffDetailsBean.getRef_ertmat(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_ref_ertmat = new HashMap(); %>
      <%
        if (ref_ertmat != null) {
          for(int i=0; i < ref_ertmat.length; i++) {
            // check for a none null quantity
            if (ref_ertmat[i] != null) {
              hash_ref_ertmat.put(ref_ertmat[i], ref_ertmat[i]);
            }
          }
        }
      %>
      
      <tr>
        <td colspan="4">
          <b>Material used to graffiti:</b>
        </td>
      </tr>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTMAT'
           AND status_yn = 'Y'
           ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>
        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="lookup_code" />
            <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
            <if:IfTrue cond='<%= ref_ertmat != null %>' >
              <input type="checkbox" 
                     name="ref_ertmat" 
                     id="ERTMAT|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" 
                     <if:IfTrue cond='<%= hash_ref_ertmat.containsKey(lookup_code) %>' >
                       checked="checked" 
                     </if:IfTrue>
              />
            </if:IfTrue>
            <if:IfTrue cond='<%= ref_ertmat == null %>' >
              <input type="checkbox" 
                     name="ref_ertmat" 
                     id="ERTMAT|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="ERTMAT|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTMAT|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="4">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Now decide if graffiti is Offensive --%>
      <%-- only show the section if there are values to use --%>
      <% boolean showOffensiveSection = false; %>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTOFF'
           AND status_yn = 'Y'
      ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
      </sql:resultSet>
      <sql:wasNotEmpty>
        <% showOffensiveSection = true; %>
      </sql:wasNotEmpty>
      <if:IfTrue cond='<%= showOffensiveSection == true %>' >
        <tr>
          <td colspan="4" valign="top">
            <input type="checkbox" 
                   name="tag_offensive" 
                   id="tag_offensive" 
                   value="Y" 
                   <if:IfTrue cond='<%= graffDetailsBean.getTag_offensive().equals("Y") %>' >
                     checked="checked"
                   </if:IfTrue>
            />
            <label for="tag_offensive">
              <b>Tag is offensive</b>
            </label>
          </td>
        </tr>
        <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
      </if:IfTrue>

      <%-- Now select nature of Offensive Graffiti --%>
      <% color="#ffffff"; %>
      <% String font_color="black"; %>
      <%-- Get nature of Offensive Graffiti --%>
      <% String[] ref_ertoff = graffDetailsBean.getRef_ertoff(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_ref_ertoff = new HashMap(); %>
      <%
        if (ref_ertoff != null) {
          for(int i=0; i < ref_ertoff.length; i++) {
            // check for a none null quantity
            if (ref_ertoff[i] != null) {
              hash_ref_ertoff.put(ref_ertoff[i], ref_ertoff[i]);
            }
          }
        }
      %>
      
      <if:IfTrue cond='<%= showOffensiveSection == true %>' >
        <tr>
          <td colspan="4">
            <b>If yes, in what way is it offensive?</b>
          </td>
        </tr>
      </if:IfTrue>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTOFF'
           AND status_yn = 'Y'
      ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>
        
        <%-- Flag any selected offensive items red with white font colour --%>
        <sql:getColumn position="1" to="lookup_code" />
        <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
        <if:IfTrue cond='<%= ref_ertoff != null %>' >
          <if:IfTrue cond='<%= hash_ref_ertoff.containsKey(lookup_code) %>' >
            <tr bgcolor="#ff6565" >
            <% font_color="white"; %>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! hash_ref_ertoff.containsKey(lookup_code) %>' >
            <tr bgcolor="<%= color %>" >
            <% font_color="black"; %>
          </if:IfTrue>
        </if:IfTrue>
        <if:IfTrue cond='<%= ref_ertoff == null %>' >
          <tr bgcolor="<%= color %>" >
          <% font_color="black"; %>
        </if:IfTrue>
        
          <td valign="top" width="10">
            <if:IfTrue cond='<%= ref_ertoff != null %>' >
              <input type="checkbox" 
                     name="ref_ertoff" 
                     id="ERTOFF|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>"
                     <if:IfTrue cond='<%= hash_ref_ertoff.containsKey(lookup_code) %>' >
                       checked="checked" 
                     </if:IfTrue>
              />
            </if:IfTrue>
            <if:IfTrue cond='<%= ref_ertoff == null %>' >
              <input type="checkbox" 
                     name="ref_ertoff" 
                     id="ERTOFF|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="ERTOFF|<sql:getColumn position="1" />">
              <font color="<%= font_color %>"><b><sql:getColumn position="1" /></b></font>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTOFF|<sql:getColumn position="1" />">
              <font color="<%= font_color %>"><sql:getColumn position="2" /></font>
            </label>
          </td>
        </tr>
      </sql:resultSet>
      <if:IfTrue cond='<%= showOffensiveSection == true %>' >
        <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
      </if:IfTrue>

      <%-- Now decide if it is Visible to public highway --%>
      <tr>
        <td colspan="4" valign="top">
          <input type="checkbox" 
                 name="tag_visible" 
                 id="tag_visible" 
                 value="Y"
                 <if:IfTrue cond='<%= graffDetailsBean.getTag_visible().equals("Y") %>' >
                   checked="checked" 
                 </if:IfTrue>
          />
          <label for="tag_visible">
            <b>Tag is visible to the public highway</b>
          </label>
        </td>
      </tr>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>      

      <%-- Select Level --%>
      <tr>
        <td colspan="4">
          <b>Level of graffiti reported:</b>
        </td>
      </tr>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTLEV'
           AND status_yn = 'Y'
           ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>
        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="lookup_code" />
            <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
            <input type="radio" 
                   name="graffiti_level_ref" 
                   id="ERTLEV|<sql:getColumn position="1" />" 
                   value="<sql:getColumn position="1" />"
                   <if:IfTrue cond='<%= lookup_code.equals(graffDetailsBean.getGraffiti_level_ref()) %>' >
                     checked="checked" 
                   </if:IfTrue>
            />
          </td>
          <td valign="top">
            <label for="ERTLEV|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTLEV|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>      

      <%-- Now select Ownership --%>
      <% color="#ffffff"; %>
      <%-- Get the ownership --%>
      <% String[] ref_ertown = graffDetailsBean.getRef_ertown(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_ref_ertown = new HashMap(); %>
      <%
        if (ref_ertown != null) {
          for(int i=0; i < ref_ertown.length; i++) {
            // check for a none null quantity
            if (ref_ertown[i] != null) {
              hash_ref_ertown.put(ref_ertown[i], ref_ertown[i]);
            }
          }
        }
      %>
      
      <tr>
        <td colspan="4">
          <b>Ownership of graffitied item:</b>
        </td>
      </tr>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTOWN'
           AND status_yn = 'Y'
           ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>
        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="lookup_code" />
            <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
            <if:IfTrue cond='<%= ref_ertown != null %>' >
              <input type="checkbox" 
                     name="ref_ertown" 
                     id="ERTOWN|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" 
                     <if:IfTrue cond='<%= hash_ref_ertown.containsKey(lookup_code) %>' >
                       checked="checked" 
                     </if:IfTrue>
              />
            </if:IfTrue>
            <if:IfTrue cond='<%= ref_ertown == null %>' >
              <input type="checkbox" 
                     name="ref_ertown" 
                     id="ERTOWN|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="ERTOWN|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTOWN|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="4">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Now select Operation --%>
      <% color="#ffffff"; %>
      <%-- Get the operation --%>
      <% String[] ref_ertopp = graffDetailsBean.getRef_ertopp(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_ref_ertopp = new HashMap(); %>
      <%
        if (ref_ertopp != null) {
          for(int i=0; i < ref_ertopp.length; i++) {
            // check for a none null quantity
            if (ref_ertopp[i] != null) {
              hash_ref_ertopp.put(ref_ertopp[i], ref_ertopp[i]);
            }
          }
        }
      %>
      
      <tr>
        <td colspan="4">
          <b>Graffiti operation:</b>
        </td>
      </tr>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTOPP'
           AND status_yn = 'Y'
           ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>
        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="lookup_code" />
            <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
            <if:IfTrue cond='<%= ref_ertopp != null %>' >
              <input type="checkbox" 
                     name="ref_ertopp" 
                     id="ERTOPP|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" 
                     <if:IfTrue cond='<%= hash_ref_ertopp.containsKey(lookup_code) %>' >
                       checked="checked" 
                     </if:IfTrue>
              />
            </if:IfTrue>
            <if:IfTrue cond='<%= ref_ertopp == null %>' >
              <input type="checkbox" 
                     name="ref_ertopp" 
                     id="ERTOPP|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="ERTOPP|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTOPP|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="4">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Now select Item --%>
      <% color="#ffffff"; %>
      <%-- Get the item --%>
      <% String[] ref_ertitm = graffDetailsBean.getRef_ertitm(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_ref_ertitm = new HashMap(); %>
      <%
        if (ref_ertitm != null) {
          for(int i=0; i < ref_ertitm.length; i++) {
            // check for a none null quantity
            if (ref_ertitm[i] != null) {
              hash_ref_ertitm.put(ref_ertitm[i], ref_ertitm[i]);
            }
          }
        }
      %>
      
      <tr>
        <td colspan="4">
          <b>Item graffiti is on:</b>
        </td>
      </tr>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTITM'
           AND status_yn = 'Y'
           ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>
        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="lookup_code" />
            <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
            <if:IfTrue cond='<%= ref_ertitm != null %>' >
              <input type="checkbox" 
                     name="ref_ertitm" 
                     id="ERTITM|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" 
                     <if:IfTrue cond='<%= hash_ref_ertitm.containsKey(lookup_code) %>' >
                       checked="checked" 
                     </if:IfTrue>
              />
            </if:IfTrue>
            <if:IfTrue cond='<%= ref_ertitm == null %>' >
              <input type="checkbox" 
                     name="ref_ertitm" 
                     id="ERTITM|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="ERTITM|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTITM|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="4">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>
      <tr><td colspan="4">&nbsp;</td></tr>     
      
      <tr>
        <td colspan="4" bgcolor="#ff6600" align="center">
          <h4><b>DETAILS OF OFFENDER</b></h4>
        </td>
      </tr>

      <%-- Now decide if it the tag is recognisable --%>
      <tr><td colspan="4">&nbsp;</td></tr>
      <tr>
        <td colspan="4" valign="top">
          
          <input type="checkbox" 
                 name="tag_recognisable" 
                 id="tag_recognisable" 
                 value="Y" 
                 <if:IfTrue cond='<%= graffDetailsBean.getTag_recognisable().equals("Y") %>' >
                   checked="checked"
                 </if:IfTrue>
          />
          <label for="tag_recognisable">
            <b>Tag is recognisable</b>
          </label>
        </td>
      </tr>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Now get the tag id --%>
      <tr>
        <td colspan="4">
          <b>If yes, what is the tag id?</b>
        </td>
      </tr>
      <tr>
        <td colspan="4">
          <input type="text" 
                 name="tag" 
                 size="15" 
                 maxlength="15"
                 value="<%= graffDetailsBean.getTag() %>"
          />
        </td>
      </tr>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Now decide if the offender is known --%>
      <tr>
        <td colspan="4" valign="top">         
          <input type="checkbox" 
                 name="tag_known_offender" 
                 id="tag_known_offender" 
                 value="Y" 
                 <if:IfTrue cond='<%= graffDetailsBean.getTag_known_offender().equals("Y") %>' >
                   checked="checked"
                 </if:IfTrue>
          />
          <label for="tag_known_offender">
            <b>The offender is known</b>
          </label>
        </td>
      </tr>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Now get the offender details --%>
      <tr>
        <td colspan="4">
          <b>If yes, please enter offender details?</b>
        </td>
      </tr>
      <tr>
        <td colspan="4">
          <input type="text" 
                 name="tag_offender_info" 
                 maxlength="80" 
                 size="24"
                 value="<%= graffDetailsBean.getTag_offender_info() %>"
          />
        </td>
      </tr>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Now decide if this is a repeat offence --%>
      <tr>
        <td colspan="4" valign="top">          
          <input type="checkbox" 
                 name="tag_repeat_offence" 
                 id="tag_repeat_offence" 
                 value="Y"
                 <if:IfTrue cond='<%= graffDetailsBean.getTag_repeat_offence().equals("Y") %>' >
                   checked="checked" 
                 </if:IfTrue>
          />
          <label for="tag_repeat_offence">
            <b>This is a repeat offence</b>
          </label>
        </td>
      </tr>
      <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Now select number of repeat offences --%>
      <% color="#ffffff"; %>
      <tr>
        <td colspan="4">
          <b>If yes, how many times?</b>
        </td>
      </tr>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTNOO'
           AND status_yn = 'Y'
        ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>

        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="noo_code" />
            <% String noo_code = ((String)pageContext.getAttribute("noo_code")).trim(); %>            
            <input type="radio" 
                   name="tag_offences_ref" 
                   id="ERTNOO|<sql:getColumn position="1" />" 
                   value="<sql:getColumn position="1" />" 
                   <if:IfTrue cond='<%= noo_code.equals(graffDetailsBean.getTag_offences_ref()) %>' >
                     checked="checked"
                   </if:IfTrue>
            />
          </td>
          <td valign="top">
            <label for="ERTNOO|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTNOO|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="4">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>

      <%-- only show the header section if there are values to use --%>
      <sql:query>
        SELECT lookup_code,
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTACT'
           AND status_yn = 'Y'
        ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
      </sql:resultSet>
      <sql:wasNotEmpty>
        <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
        <tr>
          <td colspan="4">
            <b>Preventative action taken:</b>
          </td>
        </tr>
      </sql:wasNotEmpty>

      <%-- Now select preventative action taken --%>
      <% color="#ffffff"; %>
      <%-- Get the action --%>
      <% String[] ref_ertact = graffDetailsBean.getRef_ertact(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_ref_ertact = new HashMap(); %>
      <%
        if (ref_ertact != null) {
          for(int i=0; i < ref_ertact.length; i++) {
            // check for a none null quantity
            if (ref_ertact[i] != null) {
              hash_ref_ertact.put(ref_ertact[i], ref_ertact[i]);
            }
          }
        }
      %>
      
      <sql:query>
        SELECT lookup_code,
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTACT'
           AND status_yn = 'Y'
        ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>

        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="lookup_code" />
            <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
            <if:IfTrue cond='<%= ref_ertact != null %>' >
              <input type="checkbox" 
                     name="ref_ertact" 
                     id="ERTACT|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" 
                     <if:IfTrue cond='<%= hash_ref_ertact.containsKey(lookup_code) %>' >
                       checked="checked" 
                     </if:IfTrue>
              />
            </if:IfTrue>
            <if:IfTrue cond='<%= ref_ertact == null %>' >
              <input type="checkbox" 
                     name="ref_ertact" 
                     id="ERTACT|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="ERTACT|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTACT|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>

      <%-- only show the header section if there are values to use --%>
      <sql:query>
        SELECT lookup_code,
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTABU'
           AND status_yn = 'Y'
        ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
      </sql:resultSet>
      <sql:wasNotEmpty>
        <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
        <tr>
          <td colspan="4">
            <b>Abusive behaviour encountered:</b>
          </td>
        </tr>
      </sql:wasNotEmpty>

      <%-- Now select abusive behaviour encountered --%>
      <% color="#ffffff"; %>
      <%-- Get the abusive behaviour --%>
      <% String[] ref_abuse = graffDetailsBean.getRef_abuse(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_ref_abuse = new HashMap(); %>
      <%
        if (ref_abuse != null) {
          for(int i=0; i < ref_abuse.length; i++) {
            // check for a none null quantity
            if (ref_abuse[i] != null) {
              hash_ref_abuse.put(ref_abuse[i], ref_abuse[i]);
            }
          }
        }
      %>

      <sql:query>
        SELECT lookup_code,
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTABU'
           AND status_yn = 'Y'
        ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>

        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="lookup_code" />
            <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
            <if:IfTrue cond='<%= ref_abuse != null %>' >
              <input type="checkbox" 
                     name="ref_abuse" 
                     id="ERTABU|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>"
                     <if:IfTrue cond='<%= hash_ref_abuse.containsKey(lookup_code) %>' >
                       checked="checked"
                    </if:IfTrue>
              />
            </if:IfTrue>
            <if:IfTrue cond='<%= ref_abuse == null %>' >
              <input type="checkbox" 
                     name="ref_abuse" 
                     id="ERTABU|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" 
              />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="ERTABU|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTABU|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
      
      <tr><td colspan="4">&nbsp;</td></tr>

      <tr>
        <td colspan="4" bgcolor="#ff6600" align="center">
          <h4><b>DETAILS OF REMOVAL</b></h4>
        </td>
      </tr>

      <%-- Select number of people involved in the removal --%>
      <% color="#ffffff"; %>
      <%-- only show the header section if there are values to use --%>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTWOR'
           AND status_yn = 'Y'
        ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
      </sql:resultSet>
      <sql:wasNotEmpty>
        <tr>
          <td colspan="4">
            <b>Number of people involved in the removal:</b>
          </td>
        </tr>
      </sql:wasNotEmpty>

      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTWOR'
           AND status_yn = 'Y'
        ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>

        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="wor_code" />
            <% String wor_code = ((String)pageContext.getAttribute("wor_code")).trim(); %>
            <input type="radio" 
                   name="rem_workforce_ref" 
                   id="ERTWOR|<sql:getColumn position="1" />" 
                   value="<sql:getColumn position="1" />"
                   <if:IfTrue cond='<%= wor_code.equals(graffDetailsBean.getRem_workforce_ref()) %>' >
                     checked="checked"
                   </if:IfTrue>
            />
          </td>
          <td valign="top">
            <label for="ERTWOR|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTWOR|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasNotEmpty>
        <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
      </sql:wasNotEmpty>

      <%-- Select method of removal used --%>
      <% color="#ffffff"; %>
      <%-- Get the method of removal --%>
      <% String[] ref_ertmet = graffDetailsBean.getRef_ertmet(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_ref_ertmet = new HashMap(); %>
      <%
        if (ref_ertmet != null) {
          for(int i=0; i < ref_ertmet.length; i++) {
            // check for a none null quantity
            if (ref_ertmet[i] != null) {
              hash_ref_ertmet.put(ref_ertmet[i], ref_ertmet[i]);
            }
          }
        }
      %>
      
      <tr>
        <td colspan="4">
          <b>Method of removal used:</b>
        </td>
      </tr>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTMET'
           AND status_yn = 'Y'
        ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>

        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="lookup_code" />
            <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
            <if:IfTrue cond='<%= ref_ertmet != null %>' >
              <input type="checkbox" 
                     name="ref_ertmet" 
                     id="ERTMET|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" 
                     <if:IfTrue cond='<%= hash_ref_ertmet.containsKey(lookup_code) %>' >
                       checked="checked"
                     </if:IfTrue>
              />
            </if:IfTrue>
            <if:IfTrue cond='<%= ref_ertmet == null %>' >
              <input type="checkbox" 
                     name="ref_ertmet" 
                     id="ERTMET|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="ERTMET|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTMET|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="4">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>

      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTEQU'
           AND status_yn = 'Y'
        ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
      </sql:resultSet>
      <sql:wasNotEmpty>
        <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
        <tr>
          <td colspan="4">
            <b>Equipment and material used for removal:</b>
          </td>
        </tr>
      </sql:wasNotEmpty>

      <%-- Select equipment and material used for removal --%>
      <% color="#ffffff"; %>
      <%-- Get the equipment and material used for removal --%>
      <% String[] ref_ertequ = graffDetailsBean.getRef_ertequ(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_ref_ertequ = new HashMap(); %>
      <%
        if (ref_ertequ != null) {
          for(int i=0; i < ref_ertequ.length; i++) {
            // check for a none null quantity
            if (ref_ertequ[i] != null) {
              hash_ref_ertequ.put(ref_ertequ[i], ref_ertequ[i]);
            }
          }
        }
      %>

      <%-- only show the header section if there are values to use --%>
      <sql:query>
        SELECT lookup_code, 
               lookup_text
          FROM allk
         WHERE lookup_func = 'ERTEQU'
           AND status_yn = 'Y'
        ORDER BY lookup_code
      </sql:query>
      <sql:resultSet id="rsetlist">
        <% 
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>

        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
            <sql:getColumn position="1" to="lookup_code" />
            <% String lookup_code = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
            <if:IfTrue cond='<%= ref_ertequ != null %>' >
              <input type="checkbox" 
                     name="ref_ertequ" 
                     id="ERTEQU|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>"
                     <if:IfTrue cond='<%= hash_ref_ertequ.containsKey(lookup_code) %>' >
                       checked="checked"
                     </if:IfTrue>
              />
            </if:IfTrue>
            <if:IfTrue cond='<%= ref_ertequ == null %>' >
              <input type="checkbox" 
                     name="ref_ertequ" 
                     id="ERTEQU|<sql:getColumn position="1" />"
                     value="<%= lookup_code %>"
              />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="ERTEQU|<sql:getColumn position="1" />">
              <b><sql:getColumn position="1" /></b>
            </label>
          </td>
          <td colspan="2" valign="top">
            <label for="ERTEQU|<sql:getColumn position="1" />">
              <sql:getColumn position="2" />
            </label>
          </td>
        </tr>
      </sql:resultSet>
    
      <tr><td colspan="4">&nbsp;</td></tr>
     
      <%-- Check the system key to see if we should display the  terms and conditions form --%>
      <% String use_graff_tc = ""; %>
      <sql:query>
        SELECT c_field
          FROM keys
         WHERE keyname = 'ERT_T_AND_C_INFO'
           AND service_c = 'ALL'
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="use_graff_tc" />
        <sql:wasNotNull>
          <% use_graff_tc = ((String)pageContext.getAttribute("use_graff_tc")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>

      <if:IfTrue cond='<%= use_graff_tc.equals("Y") %>'>
        <tr>
          <td colspan="4" bgcolor="#ff6600" align="center">
            <h4><b>TERMS AND CONDITIONS</b></h4>
          </td>
        </tr>
  
        <%-- Has the customer agreed to the terms and conditions --%>
        <tr><td colspan="4">&nbsp;</td></tr>
        <tr>
          <td colspan="4" valign="top">
            
            <input type="checkbox" 
                   name="indemnity_response" 
                   id="indemnity_response" 
                   value="Y" 
                   <if:IfTrue cond='<%= graffDetailsBean.getIndemnity_response().equals("Y") %>' >
                     checked="checked"
                   </if:IfTrue>
            />
            <label for="indemnity_response">
              <b>Customer agrees with T&C?</b>
            </label>
          </td>
        </tr>
        <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
        <tr>
          <td colspan="4" valign="top">
            <label>
              <b>T&C Date:</b>
            </label>
          </td>
        </tr>
        <tr bgcolor="#ecf5ff">
          <td colspan="4">
            <table width="100%">
              <tr>
                <td width="33%" align="right"><b>Day</b></td>
                <td width="33%" align="center"><b>Month</b></td>
                <td width="33%" align="left"><b>Year</b></td>
              </tr>
              <tr>
                <td align="right">
                  <select name="indemnity_day">
                  <if:IfTrue cond='<%= graffDetailsBean.getIndemnity_day().equals("") %>'>
                    <option value='<%= "" %>' selected="selected" ></option>
                    <% for (int i=1; i<32; i++) { %>
                      <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <% }   %>
                  </if:IfTrue>
                  <if:IfTrue cond='<%= !graffDetailsBean.getIndemnity_day().equals("") %>'>
                    <option value='<%= "" %>'></option>
                    <% for (int i=1; i<32; i++) { %>
                    <%   if (i == Integer.parseInt(graffDetailsBean.getIndemnity_day())) { %>
                            <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                    <%   } else { %>
                            <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <%   } %>
                    <% }   %>
                  </if:IfTrue>
                  </select>
                </td>
                <td align="center">
                  <select name="indemnity_month">
                  <%-- Create the blank values for the month --%>
                  <if:IfTrue cond='<%= graffDetailsBean.getIndemnity_month().equals("") %>'>
                    <option value='<%= "" %>' selected="selected" ></option>
                    <%  for (int i=1; i<13; i++) { %>
                      <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <%  } %>
                  </if:IfTrue>
                  <if:IfTrue cond='<%= !graffDetailsBean.getIndemnity_month().equals("") %>'>
                    <option value='<%= "" %>'></option>
                    <%  for (int i=1; i<13; i++) {
                          if (i == Integer.parseInt(graffDetailsBean.getIndemnity_month())) { %>
                             <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                    <%    } else { %>
                             <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <%   } %>
                    <% }   %>
                  </if:IfTrue>
                  </select>
                </td>
                <td align="left">
                  <select name="indemnity_year">
                  <%-- Create the blank values for the year --%>
                  <if:IfTrue cond='<%= graffDetailsBean.getIndemnity_year().equals("") %>'>
                    <option value='<%= "" %>' selected="selected" ></option>
                    <%  for (int i=gregDateToday.get(gregDateToday.YEAR)-1, k=i+3; i <= k; i++) { %>
                      <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <% }   %>
                  </if:IfTrue>
                  <if:IfTrue cond='<%= !graffDetailsBean.getIndemnity_year().equals("") %>'>
                    <option value='<%= "" %>'></option>
                    <%  for (int i=gregDateToday.get(gregDateToday.YEAR)-1, k=i+3; i <= k; i++) {
                          if (i == Integer.parseInt(graffDetailsBean.getIndemnity_year())) { %>
                             <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                    <%    } else { %>
                            <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <%    } %> 
                    <%  }   %>
                  </if:IfTrue>
                  </select>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td colspan="4">
            <table width="100%">
              <tr>
                <td><b>T&C Time:</b></td>
                <td>
                  <input type="text" name="indemnity_time_h" size="2"
                      value="<jsp:getProperty name="graffDetailsBean" property="indemnity_time_h" />" />
                  :
                  <input type="text" name="indemnity_time_m" size="2"
                      value="<jsp:getProperty name="graffDetailsBean" property="indemnity_time_m" />" />
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
        <%-- Is the customer responsible for the property --%>
        <tr>
          <td colspan="4" valign="top">          
            <input type="checkbox" 
                   name="cust_responsible" 
                   id="cust_responsible" 
                   value="Y" 
                   <if:IfTrue cond='<%= graffDetailsBean.getCust_responsible().equals("Y") %>' >
                     checked="checked"
                   </if:IfTrue>
            />
            <label for="cust_responsible">
              <b>Customer responsible?</b>
            </label>
          </td>
        </tr>
        <tr><td colspan="4"><hr size="1" noshade="noshade" /></td></tr>
        <tr>
          <td colspan="4" valign="top">
            <label>
              <b>Landlord permission form sent:</b>
            </label>
          </td>
        </tr>
        <tr bgcolor="#ecf5ff">
          <td colspan="4">
            <table width="100%">
              <tr>
                <td width="33%" align="right"><b>Day</b></td>
                <td width="33%" align="center"><b>Month</b></td>
                <td width="33%" align="left"><b>Year</b></td>
              </tr>
              <tr>
                <td align="right">
                  <select name="landlord_perm_day">
                  <%-- Create the blank values for the day --%>
                  <if:IfTrue cond='<%= graffDetailsBean.getLandlord_perm_day().equals("") %>'>
                    <option value='<%= "" %>' selected="selected" ></option>
                    <%  for (int i=1; i<32; i++) { %>
                      <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <% }     %>
                  </if:IfTrue>
                  <if:IfTrue cond='<%= !graffDetailsBean.getLandlord_perm_day().equals("") %>'>
                    <option value='<%= "" %>'></option>
                    <%  for (int i=1; i<32; i++) { 
                          if (i == Integer.parseInt(graffDetailsBean.getLandlord_perm_day())) { %>
                             <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                    <%    } else { %>
                             <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <%   }   %>
                    <% }     %>
                  </if:IfTrue>
                  </select>
                </td>
                <td align="center">
                  <select name="landlord_perm_month">
                  <%-- Create the blank values for the month --%>
                  <if:IfTrue cond='<%= graffDetailsBean.getLandlord_perm_month().equals("") %>'>
                    <option value='<%= "" %>' selected="selected" ></option>
                    <%  for (int i=1; i<13; i++) { %>
                      <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <%  }  %>
                  </if:IfTrue>
                  <if:IfTrue cond='<%= !graffDetailsBean.getLandlord_perm_month().equals("") %>'>
                    <option value='<%= "" %>'></option>
                    <%  for (int i=1; i<13; i++) {
                          if (i == Integer.parseInt(graffDetailsBean.getLandlord_perm_month())) { %>
                             <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                    <%    } else { %>
                             <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <%    }  %>
                    <%  }    %>
                  </if:IfTrue>
                  </select>
                </td>
                <td align="left">
                  <select name="landlord_perm_year">
                  <%-- Create the blank values for the year --%>
                  <if:IfTrue cond='<%= graffDetailsBean.getLandlord_perm_year().equals("") %>'>
                    <option value='<%= "" %>' selected="selected" ></option>
                    <%  for (int i=gregDateToday.get(gregDateToday.YEAR)-1, k=i+3; i <= k; i++) { %>
                      <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <%  }    %>
                  </if:IfTrue>
                  <if:IfTrue cond='<%= !graffDetailsBean.getLandlord_perm_year().equals("") %>'>
                    <option value='<%= "" %>'></option>
                    <%  for (int i=gregDateToday.get(gregDateToday.YEAR)-1, k=i+3; i <= k; i++) {
                          if (i == Integer.parseInt(graffDetailsBean.getLandlord_perm_year())) { %>
                             <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                    <%    } else { %>
                            <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                    <%    }  %>
                    <%  }    %>
                  </if:IfTrue>
                  </select>
                </td>
              </tr>            
            </table>
          </td>
        </tr>
        <tr><td colspan="4">&nbsp;</td></tr>
      </if:IfTrue>   
    </table>
 
    <%-- Allow the user to add the Estimated Cost section. --%>
    <app:equalsInitParameter name="use_graff_est_cost" match="Y">
      <table cellpadding="2" cellspacing="0" width="100%">
        <tr><td><hr size="1" noshade="noshade" /></td></tr>
        <tr>
          <td>
            <b>Estimated Cost Of Above Work If Chargeable:</b>
          </td>
        </tr>
        <tr>
          <td>
            <input type="text" name="wo_est_cost" size="10" maxlength="10"
              value="<%= graffDetailsBean.getWo_est_cost() %>" />
          </td>
        </tr>
        <tr><td><hr size="1" noshade="noshade" /></td></tr>
        <tr>
          <td>
            <b>Duration Of Above Work If Chargeable:</b>
          </td>
        </tr>
        <tr>
          <td>
            <b>Hrs</b>
            <input type="text" name="est_duration_h" size="2" maxlength="2"
                   value="<%= graffDetailsBean.getEst_duration_h() %>" />
            &nbsp;
            <b>Mins</b>
            <input type="text" name="est_duration_m" size="2" maxlength="2"
                   value="<%= graffDetailsBean.getEst_duration_m() %>" />
          </td>
        </tr>
        <tr><td><hr size="1" noshade="noshade" /></td></tr>
        <tr>
          <td valign="top">
            <input type="checkbox" name="refuse_pay" id="refuse_pay" value="Y" 
                   <if:IfTrue cond='<%= graffDetailsBean.getRefuse_pay().equals("Y") %>' >
                     checked="checked"
                   </if:IfTrue>
            />
            <label for="refuse_pay">
              <b>Refuse to Pay, No Further Action</b>
            </label>
          </td>
        </tr>
      </table>
    </app:equalsInitParameter>
    
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- we are coming from the Inspection route and we are not going via a BV199 auto default --%> 
    <if:IfTrue cond='<%= recordBean.getComingFromInspList().equals("Y") && ! recordBean.getBv_default_flag().equals("Y") %>'>
        <%-- Using graffiti estimated costs so not using works orders --%>
        <app:equalsInitParameter name="use_graff_est_cost" match="Y">
          <jsp:include page="include/back_default_finish_buttons.jsp" flush="true" />
        </app:equalsInitParameter>
        <%-- Not using graffiti estimated costs so using works orders instead --%>
        <app:equalsInitParameter name="use_graff_est_cost" match="Y" value="false">
          <jsp:include page="include/back_wo_default_finish_buttons.jsp" flush="true" />
        </app:equalsInitParameter>
    </if:IfTrue>
    <%-- we are not coming from the Inspection route or we are but are going via a BV199 auto default --%> 
    <if:IfTrue cond='<%= !recordBean.getComingFromInspList().equals("Y") || recordBean.getBv_default_flag().equals("Y") %>'>
      <%-- 01/07/2010  TW  New conditional buttons - check whether definitely coming via Sched/Comp route --%>
      <if:IfTrue cond='<%= recordBean.getDart_graff_flag().equals("Y") %>'>
        <%-- Works Order --%>
        <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") %>'>
          <jsp:include page="include/back_wo_buttons.jsp" flush="true" />
        </if:IfTrue>
        <%-- Not a Works Order --%>
        <if:IfTrue cond='<%= !recordBean.getAction_flag().equals("W") %>'>
          <jsp:include page="include/back_text_buttons.jsp" flush="true" />
        </if:IfTrue>
      </if:IfTrue>
      <if:IfTrue cond='<%= !recordBean.getDart_graff_flag().equals("Y") %>'>
        <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- If we have already defaulted a BV199 item do not allow the user to exit --%>
    <if:IfTrue cond='<%= !surveyGradingBean.isAnyFlagDefaulted() %>'>
      <%@ include file="include/insp_sched_buttons.jsp" %>
    </if:IfTrue>

    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="graffDetails" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
