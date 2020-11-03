<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.dartDetailsBean, com.vsb.recordBean" %>
<%@ page import="java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="dartDetailsBean" scope="session" class="com.vsb.dartDetailsBean" />
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
<sess:equalsAttribute name="form" match="dartDetails" value="false">
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
  <title>dartDetails</title>
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
  <form onSubmit="return singleclick();" action="dartDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Dart Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="dartDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>

    <% String color="#ffffff"; %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
    <table cellpadding="2" cellspacing="0" width="100%">
      <tr>
        <td colspan="2" bgcolor="#ff6600" align="center">
          <h4><b>REPORTED WASTE</b></h4>
        </td>
      </tr>

      <%-- Get the needle, crack pipe and condom quantities --%>
      <tr>
        <td valign="top">
          <b>Needle Quantity</b>
        </td>
        <td valign="top">
          <input type="text" name="rep_needle_qty" size="4" maxlength="4"
            value="<%= dartDetailsBean.getRep_needle_qty() %>" />
        </td>
      </tr>
      <tr>
        <td valign="top">
          <b>Crack Pipe Quantity</b>
        </td>
        <td valign="top">
          <input type="text" name="rep_crack_pipe_qty" size="4" maxlength="4"
            value="<%= dartDetailsBean.getRep_crack_pipe_qty() %>" />
        </td>
      </tr>
      <tr>
        <td valign="top">
          <b>Condom Quantity</b>
        </td>
        <td valign="top">
          <input type="text" name="rep_condom_qty" size="4" maxlength="4"
            value="<%= dartDetailsBean.getRep_condom_qty() %>" />
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Reported Categories --%>
      <% color="#ffffff"; %>
      <%-- Get the reported categories --%>
      <% String[] rep_cats = dartDetailsBean.getRep_cats(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_rep_cats = new HashMap(); %>
      <%
        if (rep_cats != null) {
          for(int i=0; i < rep_cats.length; i++) {
            // check for a none null quantity
            if (rep_cats[i] != null) {
              hash_rep_cats.put(rep_cats[i], rep_cats[i]);
            }
          }
        }
      %>

      <% String DRTREP_desc = "Reported Categories"; %>
      <sql:query>
        select lookup_desc
        from alds
        where lookup_func = 'DRTREP'
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_desc" />
        <sql:wasNotNull>
          <% DRTREP_desc = ((String)pageContext.getAttribute("lookup_desc")).trim(); %>
        </sql:wasNotNull> 
      </sql:resultSet>
      <tr>
        <td colspan="2" valign="top">
          <b><%= DRTREP_desc %>:</b>
        </td>
      </tr>
      <sql:query>
        select lookup_code, lookup_text
        from allk
        where lookup_func = 'DRTREP'
        and status_yn = 'Y'
        order by lookup_code
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
            <if:IfTrue cond='<%= rep_cats != null %>' >
              <if:IfTrue cond='<%= hash_rep_cats.containsKey(((String)pageContext.getAttribute("lookup_code")).trim()) %>' >
                <input type="checkbox" name="rep_cats" id="DRTREP|<sql:getColumn position="1" />"
                  value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! hash_rep_cats.containsKey(((String)pageContext.getAttribute("lookup_code")).trim()) %>' >
                <input type="checkbox" name="rep_cats" id="DRTREP|<sql:getColumn position="1" />"
                  value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" />
              </if:IfTrue>
            </if:IfTrue>
            <if:IfTrue cond='<%= rep_cats == null %>' >
              <input type="checkbox" name="rep_cats" id="DRTREP|<sql:getColumn position="1" />"
                value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="DRTREP|<sql:getColumn position="1" />"><sql:getColumn position="2" /></label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="2">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>

      <tr>
        <td colspan="2" bgcolor="#ff6600" align="center">
          <h4><b>DETAILS OF WASTE COLLECTED</b></h4>
        </td>
      </tr>

      <%-- Get the needle, crack pipe and condom quantities --%>
      <tr>
        <td valign="top">
          <b>Needle Quantity</b>
        </td>
        <td valign="top">
          <input type="text" name="col_needle_qty" size="4" maxlength="4"
            value="<%= dartDetailsBean.getCol_needle_qty() %>" />
        </td>
      </tr>
      <tr>
        <td valign="top">
          <b>Crack Pipe Quantity</b>
        </td>
        <td valign="top">
          <input type="text" name="col_crack_pipe_qty" size="4" maxlength="4"
            value="<%= dartDetailsBean.getCol_crack_pipe_qty() %>" />
        </td>
      </tr>
      <tr>
        <td valign="top">
          <b>Condom Quantity</b>
        </td>
        <td valign="top">
          <input type="text" name="col_condom_qty" size="4" maxlength="4"
            value="<%= dartDetailsBean.getCol_condom_qty() %>" />
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Drug Paraphernalia --%>
      <% color="#ffffff"; %>
      <%-- Get the drug paraphernalia --%>
      <% String[] drug_para = dartDetailsBean.getDrug_para(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_drug_para = new HashMap(); %>
      <%
        if (drug_para != null) {
          for(int i=0; i < drug_para.length; i++) {
            // check for a none null quantity
            if (drug_para[i] != null) {
              hash_drug_para.put(drug_para[i], drug_para[i]);
            }
          }
        }
      %>
      
      <% String DRTPAR_desc = "Drug Paraphernalia"; %>
      <sql:query>
        select lookup_desc
        from alds
        where lookup_func = 'DRTPAR'
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_desc" />
        <sql:wasNotNull>
          <% DRTPAR_desc = ((String)pageContext.getAttribute("lookup_desc")).trim(); %>
        </sql:wasNotNull> 
      </sql:resultSet>
      <tr>
        <td colspan="2" valign="top">
          <b><%= DRTPAR_desc %>:</b>
        </td>
      </tr>
      <sql:query>
        select lookup_code, lookup_text
        from allk
        where lookup_func = 'DRTPAR'
        and status_yn = 'Y'
        order by lookup_code
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
            <if:IfTrue cond='<%= drug_para != null %>' >
              <if:IfTrue cond='<%= hash_drug_para.containsKey(((String)pageContext.getAttribute("lookup_code")).trim()) %>' >
                <input type="checkbox" name="drug_para" id="DRTPAR|<sql:getColumn position="1" />"
                  value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! hash_drug_para.containsKey(((String)pageContext.getAttribute("lookup_code")).trim()) %>' >
                <input type="checkbox" name="drug_para" id="DRTPAR|<sql:getColumn position="1" />"
                  value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" />
              </if:IfTrue>
            </if:IfTrue>
            <if:IfTrue cond='<%= drug_para == null %>' >
              <input type="checkbox" name="drug_para" id="DRTPAR|<sql:getColumn position="1" />"
                value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="DRTPAR|<sql:getColumn position="1" />"><sql:getColumn position="2" /></label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="2">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>

      <%-- Anti-social waste washdown --%>
      <% color="#ffffff"; %>
      <%-- Get the anti-social waste washdown --%>
      <% String[] asww_cats = dartDetailsBean.getAsww_cats(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_asww_cats = new HashMap(); %>
      <%
        if (asww_cats != null) {
          for(int i=0; i < asww_cats.length; i++) {
            // check for a none null quantity
            if (asww_cats[i] != null) {
              hash_asww_cats.put(asww_cats[i], asww_cats[i]);
            }
          }
        }
      %>
      
      <% String DRTASW_desc = "Anti-Social Waste Washdown"; %>
      <sql:query>
        select lookup_desc
        from alds
        where lookup_func = 'DRTASW'
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_desc" />
        <sql:wasNotNull>
          <% DRTASW_desc = ((String)pageContext.getAttribute("lookup_desc")).trim(); %>
        </sql:wasNotNull> 
      </sql:resultSet>
      <tr>
        <td colspan="2" valign="top">
          <b><%= DRTASW_desc %>:</b>
        </td>
      </tr>
      <sql:query>
        select lookup_code, lookup_text
        from allk
        where lookup_func = 'DRTASW'
        and status_yn = 'Y'
        order by lookup_code
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
            <if:IfTrue cond='<%= asww_cats != null %>' >
              <if:IfTrue cond='<%= hash_asww_cats.containsKey(((String)pageContext.getAttribute("lookup_code")).trim()) %>' >
                <input type="checkbox" name="asww_cats" id="DRTASW|<sql:getColumn position="1" />"
                  value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! hash_asww_cats.containsKey(((String)pageContext.getAttribute("lookup_code")).trim()) %>' >
                <input type="checkbox" name="asww_cats" id="DRTASW|<sql:getColumn position="1" />"
                  value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" />
              </if:IfTrue>
            </if:IfTrue>
            <if:IfTrue cond='<%= asww_cats == null %>' >
              <input type="checkbox" name="asww_cats" id="DRTASW|<sql:getColumn position="1" />"
                value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="DRTASW|<sql:getColumn position="1" />"><sql:getColumn position="2" /></label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="2">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      
      <%-- Abusive behaviour encountered --%>
      <% color="#ffffff"; %>
      <%-- Get the abusive behaviour encountered --%>
      <% String[] abuse_cats = dartDetailsBean.getAbuse_cats(); %>
      <%-- add values to a hash map for quick checking --%>
      <% HashMap hash_abuse_cats = new HashMap(); %>
      <%
        if (abuse_cats != null) {
          for(int i=0; i < abuse_cats.length; i++) {
            // check for a none null quantity
            if (abuse_cats[i] != null) {
              hash_abuse_cats.put(abuse_cats[i], abuse_cats[i]);
            }
          }
        }
      %>
      
      <% String ABUSE_desc = "Abusive behaviour encountered"; %>
      <sql:query>
        select lookup_desc
        from alds
        where lookup_func = 'ABUSE'
      </sql:query>
      <sql:resultSet id="rsetlist">
        <sql:getColumn position="1" to="lookup_desc" />
        <sql:wasNotNull>
          <% ABUSE_desc = ((String)pageContext.getAttribute("lookup_desc")).trim(); %>
        </sql:wasNotNull> 
      </sql:resultSet>
      <tr>
        <td colspan="2" valign="top">
          <b><%= ABUSE_desc %>:</b>
        </td>
      </tr>
      <sql:query>
        select lookup_code, lookup_text
        from allk
        where lookup_func = 'ABUSE'
        and status_yn = 'Y'        
        order by lookup_code
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
            <if:IfTrue cond='<%= abuse_cats != null %>' >
              <if:IfTrue cond='<%= hash_abuse_cats.containsKey(((String)pageContext.getAttribute("lookup_code")).trim()) %>' >
                <input type="checkbox" name="abuse_cats" id="ABUSE|<sql:getColumn position="1" />"
                  value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! hash_abuse_cats.containsKey(((String)pageContext.getAttribute("lookup_code")).trim()) %>' >
                <input type="checkbox" name="abuse_cats" id="ABUSE|<sql:getColumn position="1" />"
                  value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" />
              </if:IfTrue>
            </if:IfTrue>
            <if:IfTrue cond='<%= abuse_cats == null %>' >
              <input type="checkbox" name="abuse_cats" id="ABUSE|<sql:getColumn position="1" />"
                value="<%= ((String)pageContext.getAttribute("lookup_code")).trim() %>" />
            </if:IfTrue>
          </td>
          <td valign="top">
            <label for="ABUSE|<sql:getColumn position="1" />"><sql:getColumn position="2" /></label>
          </td>
        </tr>
      </sql:resultSet>
      <sql:wasEmpty>
        <tr>
          <td colspan="2">
            <b>No codes available</b>
          </td>
        </tr>
      </sql:wasEmpty>
    </table>

    <%-- If we are just inspecting a complaint allow the user to add an estimated --%>
    <%-- works order cost, and a refuse to pay tickbox --%>
    <if:IfTrue cond='<%= !recordBean.getDart_graff_flag().equals("Y") %>' >
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
              value="<%= dartDetailsBean.getWo_est_cost() %>" />
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
              value="<%= dartDetailsBean.getEst_duration_h() %>" />
            &nbsp;
            <b>Mins</b>
            <input type="text" name="est_duration_m" size="2" maxlength="2"
              value="<%= dartDetailsBean.getEst_duration_m() %>" />
          </td>
        </tr>
        <tr><td><hr size="1" noshade="noshade" /></td></tr>
        <tr>
          <td valign="top">
            <if:IfTrue cond='<%= dartDetailsBean.getRefuse_pay().equals("Y") %>' >
              <input type="checkbox" name="refuse_pay" id="refuse_pay" value="Y" checked="checked" />
            </if:IfTrue>
            <if:IfTrue cond='<%= ! dartDetailsBean.getRefuse_pay().equals("Y") %>' >
              <input type="checkbox" name="refuse_pay" id="refuse_pay" value="Y" />
            </if:IfTrue>
            <label for="refuse_pay"><b>Refuse to Pay, No Further Action</b></label>
          </td>
        </tr>
      </table>
    </if:IfTrue>

    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- If we are adding a complaint allow the user to also add the --%>
    <%-- works order details via the chargeable button --%>
    <if:IfTrue cond='<%= recordBean.getDart_graff_flag().equals("Y") %>' >
      <jsp:include page="include/back_charge_text_buttons.jsp" flush="true" />
    </if:IfTrue>

    <%-- If we are just inspecting a complaint only allow the user to finish --%>
    <if:IfTrue cond='<%= !recordBean.getDart_graff_flag().equals("Y") %>' >
      <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
    </if:IfTrue>

    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="dartDetails" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
