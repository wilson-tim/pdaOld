<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.changeItemLookupBean, com.vsb.recordBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="changeItemLookupBean" scope="session" class="com.vsb.changeItemLookupBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="changeItemLookup" value="false">
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
  <title>changeItemLookup</title>
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
  <form onSubmit="return singleclick();" action="changeItemLookupScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Change Item</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="changeItemLookupBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select distinct si_i.item_ref, item.item_desc, si_i.feature_ref, si_i.contract_ref
          from si_i, item
          where si_i.site_ref = '<%= recordBean.getSite_ref() %>'
          and   item.item_ref = si_i.item_ref
          and   item.item_ref NOT IN (
                  select perm_items.item_ref
                  from perm_items, user_info, pda_user, patr
                  where pda_user.user_name = '<%= loginBean.getUser_name() %>'
                  and   patr.po_code = pda_user.po_code
                  and   user_info.username = patr.po_login
                  and   perm_items.ugroup = user_info.ugroup
                )
          and   item.customer_care_yn = 'Y'
          and   item.service_c = '<%= recordBean.getService_c() %>'
          order by si_i.item_ref
         </sql:query>
        <sql:resultSet id="rset">
          <tr>
            <td valign="top" width="10">
              <sql:getColumn position="1" to="item_ref" />
              <sql:getColumn position="3" to="feature_ref" />
              <sql:getColumn position="4" to="contract_ref" />
              <% 
                String item_ref = ((String)pageContext.getAttribute("item_ref")).trim();
                String feature_ref = ((String)pageContext.getAttribute("feature_ref")).trim(); 
                String contract_ref = ((String)pageContext.getAttribute("contract_ref")).trim(); 
                boolean current_item = false;

                // Set up the view key
                String view_key = item_ref + "|" + feature_ref + "|" + contract_ref; 

                // Is this the current item
                if (recordBean.getItem_ref().equals(item_ref) && recordBean.getFeature_ref().equals(feature_ref) && recordBean.getContract_ref().equals(contract_ref)) {
                  current_item = true;
                }
              %>
              <%-- Select the current item if nothing else has been selected --%>
              <if:IfTrue cond='<%= changeItemLookupBean.getView_key().equals("") %>' >
                <if:IfTrue cond='<%= current_item == true %>' >
                  <input type="radio" name="view_key" id="<%= view_key %>" value="<%= view_key %>"  checked="checked" />
                </if:IfTrue>
                <if:IfTrue cond='<%= current_item == false %>' >
                  <input type="radio" name="view_key" id="<%= view_key %>" value="<%= view_key %>" />
                </if:IfTrue>
              </if:IfTrue>

              <%-- only do if something has been selected --%>
              <if:IfTrue cond='<%= !changeItemLookupBean.getView_key().equals("") %>' >
                <if:IfTrue cond='<%= view_key.equals(changeItemLookupBean.getView_key()) %>' >
                  <input type="radio" name="view_key" id="<%= view_key %>" value="<%= view_key %>"  checked="checked" />
                </if:IfTrue>
                <if:IfTrue cond='<%= !view_key.equals(changeItemLookupBean.getView_key()) %>' >
                  <input type="radio" name="view_key" id="<%= view_key %>" value="<%= view_key %>" />
                </if:IfTrue>
              </if:IfTrue>
            </td>
            <td valign="top" width="100%">
             <label for="<%= view_key %>"><b><sql:getColumn position="1" /></b></label>
            </td>
          </tr>
          <tr>
            <td colspan="2">
             <label for="<%= view_key %>"><sql:getColumn position="2" /></label>
            </td>
          </tr>
          <%-- Show the feature and contract for each item --%>
          <tr>
            <td colspan="2">
              <table width="100%">
                <if:IfTrue cond='<%= recordBean.getSi_i_param_feature().equals("Y") %>' >
                  <tr bgcolor="#ecf5ff">
                    <td>
                      <label for="<%= view_key %>"><b>Feature</b></label>
                    </td>
                    <td>
                      <label for="<%= view_key %>"><sql:getColumn position="3" /></label>
                    </td>
                  </tr>
                </if:IfTrue>
                <if:IfTrue cond='<%= recordBean.getSi_i_param_contract().equals("Y") %>' >
                  <tr bgcolor="#ecf5ff">
                    <td>
                      <label for="<%= view_key %>"><b>Contract</b></label>
                    </td>
                    <td>
                      <label for="<%= view_key %>"><sql:getColumn position="4" /></label>
                    </td>
                  </tr>
                </if:IfTrue>
              </table>
            </td>
          </tr>
          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
        </sql:resultSet>
        <sql:wasEmpty>
          <tr>
             <td colspan="2">
               <b>No items available</b>
             </td>
           </tr>
        </sql:wasEmpty>
        <sql:wasNotEmpty>
          <tr>
            <td colspan="2">
              <span class="subscript"><sql:rowCount /> codes</span>
            </td>
          </tr>
        </sql:wasNotEmpty>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>

  	<jsp:include page="include/back_fault_buttons.jsp" flush="true" />

    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="changeItemLookup" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
