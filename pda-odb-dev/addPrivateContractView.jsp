<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.addPrivateContractBean, com.vsb.recordBean" %>
<%@ page import="java.util.*, java.text.*, java.text.SimpleDateFormat" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="addPrivateContractBean" scope="session" class="com.vsb.addPrivateContractBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

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
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="addPrivateContract" value="false">
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
  <title>addPrivateContract</title>
  <style type="text/css">
    @import URL("global.css");
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
  <form onSubmit="return singleclick();" action="addPrivateContractScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Add Private Contract</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="addPrivateContractBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>

    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">

    <%-- set up variables --%>
    <% String color="#ffffff"; %>

    <table width="100%">
      <tr>
        <td align="center" colspan="3"><b><jsp:getProperty name="recordBean" property="site_name_1" /></b></td>
      </tr>
      <tr><td colspan="3">&nbsp;</td></tr>
      <tr>
        <td colspan="3" bgcolor="#ff6600" align="center">
          <h4><b>CONTRACT DETAILS</b></h4>
        </td>
      </tr>

      <%-- Status field --%>
      <tr>
        <td colspan="3">
          <if:IfTrue cond='<%= addPrivateContractBean.getStatus().equals("") %>' >
            <b>Status:</b>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! addPrivateContractBean.getStatus().equals("") %>' >
            <b>Status:</b><br/>
            (Scroll to selected <b><%= addPrivateContractBean.getStatus() %></b>)
          </if:IfTrue>
        </td>
      </tr>
      <tr>
        <td colspan="3">
          <div class="scroll_area_half">
            <table cellpadding="2" cellspacing="0" width="100%">
            <sql:query>
              select status_ref, status_desc
              from status_codes
              order by status_ref
            </sql:query>
            <sql:resultSet id="rset">
              <% 
                if(color=="#ffffff") {
                  color = "#ecf5ff";
                } else if (color=="#ecf5ff") {
                  color = "#ffffff";
                }
              %>
              <tr bgcolor="<%= color %>" >
                <td valign="top" width="10">
                  <sql:getColumn position="1" to="status_ref" />
                  <% String status_ref = ((String)pageContext.getAttribute("status_ref")).trim(); %>
                  <sql:getColumn position="2" to="status_desc" />
                  <% String status_desc = ((String)pageContext.getAttribute("status_desc")).trim(); %> 
      
                  <input type="radio" name="status" 
                    id="STATUS|<%= status_ref %>" 
                    value="<%= status_ref %>"
                    <if:IfTrue cond='<%= status_ref.equals(addPrivateContractBean.getStatus()) %>' >
                      checked="checked" 
                    </if:IfTrue>
                  />
                </td>
                <td valign="top">
                  <label for="STATUS|<%= status_ref %>">
                    <b><%= status_ref %></b>
                  </label>
                </td>
              </tr>
              <tr bgcolor="<%= color %>" >
                <td valign="top" width="10">&nbsp;</td>
                <td valign="top">
                  <label for="STATUS|<%= status_ref %>">
                    <%= status_desc %>
                  </label>
                </td>
              </tr>
            </sql:resultSet>
            </table>
          </div>
        </td>
      </tr>
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>
      <tr>
        <td colspan="2">
          <b>Business Name</b>
        </td>
        <td>
          <input type="text" name="business_name" size="15" maxlength="60"
            value="<%= addPrivateContractBean.getBusiness_name() %>" />
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <b>Trading Name</b>
        </td>
        <td>
          <input type="text" name="ta_name" size="15" maxlength="60"
            value="<%= addPrivateContractBean.getTa_name() %>" />
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <b>Contact Name</b>
        </td>
        <td>
          <input type="text" name="contact_name" size="15" maxlength="40"
            value="<%= addPrivateContractBean.getContact_name() %>" />
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <b>Contact Title</b>
        </td>
        <td>
          <input type="text" name="contact_title" size="15" maxlength="40"
            value="<%= addPrivateContractBean.getContact_title() %>" />
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <b>Email Address</b>
        </td>
        <td>
          <input type="text" name="contact_email" size="15" maxlength="40"
            value="<%= addPrivateContractBean.getContact_email() %>" />
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <b>Telephone No.</b>
        </td>
        <td>
          <input type="text" name="contact_tel" size="15" maxlength="20"
            value="<%= addPrivateContractBean.getContact_tel() %>" />
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <b>Mobile No.</b>
        </td>
        <td>
          <input type="text" name="contact_mobile" size="15" maxlength="20"
            value="<%= addPrivateContractBean.getContact_mobile() %>" />
        </td>
      </tr>
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>

      <%-- recvd_by field --%>
      <tr>
        <td colspan="3">
          <if:IfTrue cond='<%= addPrivateContractBean.getRecvd_by().equals("") %>' >
            <b>Contact Method:</b>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! addPrivateContractBean.getRecvd_by().equals("") %>' >
            <b>Contact Method:</b><br/>
            (Scroll to selected <b><%= addPrivateContractBean.getRecvd_by() %></b>)
          </if:IfTrue>
        </td>
      </tr>
      <tr>
        <td colspan="3">
          <div class="scroll_area_full">
            <table cellpadding="2" cellspacing="0" width="100%">
            <sql:query>
              select lookup_code, lookup_text
              from allk
              where lookup_func = 'CTSRC' 
              order by lookup_code
            </sql:query>
            <sql:resultSet id="rset">
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
                  <sql:getColumn position="2" to="lookup_text" />
                  <% String lookup_text = ((String)pageContext.getAttribute("lookup_text")).trim(); %> 
      
                  <input type="radio" name="recvd_by" 
                    id="CTSRC|<%= lookup_code %>" 
                    value="<%= lookup_code %>"
                    <if:IfTrue cond='<%= lookup_code.equals(addPrivateContractBean.getRecvd_by()) %>' >
                      checked="checked" 
                    </if:IfTrue>
                  />
                </td>
                <td valign="top">
                  <label for="CTSRC|<%= lookup_code %>">
                    <b><%= lookup_code %></b>
                  </label>
                </td>
              </tr>
              <tr bgcolor="<%= color %>" >
                <td valign="top" width="10">&nbsp;</td>
                <td valign="top">
                  <label for="CTSRC|<%= lookup_code %>">
                    <%= lookup_text %>
                  </label>
                </td>
              </tr>
            </sql:resultSet>
            </table>
          </div>
        </td>
      </tr>

      <tr><td colspan="3">&nbsp;</td></tr>
      <tr>
        <td colspan="3" bgcolor="#ff6600" align="center">
          <h4><b>DISPOSAL REQUIREMENTS</b></h4>
        </td>
      </tr>

      <%-- origin field --%>
      <tr>
        <td colspan="3">
          <if:IfTrue cond='<%= addPrivateContractBean.getOrigin().equals("") %>' >
            <b>Officer Ref:</b>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! addPrivateContractBean.getOrigin().equals("") %>' >
            <b>Officer Ref:</b><br/>
            (Scroll to selected <b><%= addPrivateContractBean.getOrigin() %></b>)
          </if:IfTrue>
        </td>
      </tr>
      <tr>
        <td colspan="3">
          <div class="scroll_area_half">
            <table cellpadding="2" cellspacing="0" width="100%">
            <sql:query>
              select lookup_code, lookup_text
              from allk
              where lookup_func = 'TRORIG' 
              order by lookup_code
            </sql:query>
            <sql:resultSet id="rset">
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
                  <sql:getColumn position="2" to="lookup_text" />
                  <% String lookup_text = ((String)pageContext.getAttribute("lookup_text")).trim(); %> 
      
                  <input type="radio" name="origin" 
                    id="TRORIG|<%= lookup_code %>" 
                    value="<%= lookup_code %>"
                    <if:IfTrue cond='<%= lookup_code.equals(addPrivateContractBean.getOrigin()) %>' >
                      checked="checked" 
                    </if:IfTrue>
                  />
                </td>
                <td valign="top">
                  <label for="TRORIG|<%= lookup_code %>">
                    <b><%= lookup_code %></b>
                  </label>
                </td>
              </tr>
              <tr bgcolor="<%= color %>" >
                <td valign="top" width="10">&nbsp;</td>
                <td valign="top">
                  <label for="TRORIG|<%= lookup_code %>">
                    <%= lookup_text %>
                  </label>
                </td>
              </tr>
            </sql:resultSet>
            </table>
          </div>
        </td>
      </tr>
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>
      <tr>
        <td colspan="2">
          <b>Contract Size</b>
        </td>
        <td>
          <input type="text" name="contract_size" size="15" maxlength="20"
            value="<%= addPrivateContractBean.getContract_size() %>" />
        </td>
      </tr>
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>
      <tr>
        <td colspan="3" valign="top">
          <label>
            <b>CWTN Start:</b>
          </label>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td colspan="3">
          <table width="100%">
            <tr>
              <td width="33%" align="right"><b>Day</b></td>
              <td width="33%" align="center"><b>Month</b></td>
              <td width="33%" align="left"><b>Year</b></td>
            </tr>
            <tr>
              <td align="right">
                <select name="cwtn_start_day">
                <%-- Create the blank values for the day --%>
                <if:IfTrue cond='<%= addPrivateContractBean.getCwtn_start_day().equals("") %>'>
                  <option value='<%= "" %>' selected="selected" ></option>
                  <%  for (int i=1; i<32; i++) { %>
                    <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                  <% }     %>
                </if:IfTrue>
                <if:IfTrue cond='<%= !addPrivateContractBean.getCwtn_start_day().equals("") %>'>
                  <option value='<%= "" %>'></option>
                  <%  for (int i=1; i<32; i++) { 
                        if (i == Integer.parseInt(addPrivateContractBean.getCwtn_start_day())) { %>
                           <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                  <%    } else { %>
                           <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                  <%   }   %>
                  <% }     %>
                </if:IfTrue>
                </select>
              </td>
              <td align="center">
                <select name="cwtn_start_month">
                <%-- Create the blank values for the month --%>
                <if:IfTrue cond='<%= addPrivateContractBean.getCwtn_start_month().equals("") %>'>
                  <option value='<%= "" %>' selected="selected" ></option>
                  <%  for (int i=1; i<13; i++) { %>
                    <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                  <%  }  %>
                </if:IfTrue>
                <if:IfTrue cond='<%= !addPrivateContractBean.getCwtn_start_month().equals("") %>'>
                  <option value='<%= "" %>'></option>
                  <%  for (int i=1; i<13; i++) {
                        if (i == Integer.parseInt(addPrivateContractBean.getCwtn_start_month())) { %>
                           <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                  <%    } else { %>
                           <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                  <%    }  %>
                  <%  }    %>
                </if:IfTrue>
                </select>
              </td>
              <td align="left">
                <select name="cwtn_start_year">
                <%-- Create the blank values for the year --%>
                <if:IfTrue cond='<%= addPrivateContractBean.getCwtn_start_year().equals("") %>'>
                  <option value='<%= "" %>' selected="selected" ></option>
                  <%  for (int i=gregDateToday.get(gregDateToday.YEAR)-3, k=i+6; i <= k; i++) { %>
                    <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                  <%  }    %>
                </if:IfTrue>
                <if:IfTrue cond='<%= !addPrivateContractBean.getCwtn_start_year().equals("") %>'>
                  <option value='<%= "" %>'></option>
                  <%  for (int i=gregDateToday.get(gregDateToday.YEAR)-3, k=i+6; i <= k; i++) {
                        if (i == Integer.parseInt(addPrivateContractBean.getCwtn_start_year())) { %>
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
      <tr>
        <td colspan="3" valign="top">
          <label>
            <b>End:</b>
          </label>
        </td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td colspan="3">
          <table width="100%">
            <tr>
              <td width="33%" align="right"><b>Day</b></td>
              <td width="33%" align="center"><b>Month</b></td>
              <td width="33%" align="left"><b>Year</b></td>
            </tr>
            <tr>
              <td align="right">
                <select name="cwtn_end_day">
                <%-- Create the blank values for the day --%>
                <if:IfTrue cond='<%= addPrivateContractBean.getCwtn_end_day().equals("") %>'>
                  <option value='<%= "" %>' selected="selected" ></option>
                  <%  for (int i=1; i<32; i++) { %>
                    <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                  <% }     %>
                </if:IfTrue>
                <if:IfTrue cond='<%= !addPrivateContractBean.getCwtn_end_day().equals("") %>'>
                  <option value='<%= "" %>'></option>
                  <%  for (int i=1; i<32; i++) { 
                        if (i == Integer.parseInt(addPrivateContractBean.getCwtn_end_day())) { %>
                           <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                  <%    } else { %>
                           <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                  <%   }   %>
                  <% }     %>
                </if:IfTrue>
                </select>
              </td>
              <td align="center">
                <select name="cwtn_end_month">
                <%-- Create the blank values for the month --%>
                <if:IfTrue cond='<%= addPrivateContractBean.getCwtn_end_month().equals("") %>'>
                  <option value='<%= "" %>' selected="selected" ></option>
                  <%  for (int i=1; i<13; i++) { %>
                    <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                  <%  }  %>
                </if:IfTrue>
                <if:IfTrue cond='<%= !addPrivateContractBean.getCwtn_end_month().equals("") %>'>
                  <option value='<%= "" %>'></option>
                  <%  for (int i=1; i<13; i++) {
                        if (i == Integer.parseInt(addPrivateContractBean.getCwtn_end_month())) { %>
                           <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                  <%    } else { %>
                           <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                  <%    }  %>
                  <%  }    %>
                </if:IfTrue>
                </select>
              </td>
              <td align="left">
                <select name="cwtn_end_year">
                <%-- Create the blank values for the year --%>
                <if:IfTrue cond='<%= addPrivateContractBean.getCwtn_end_year().equals("") %>'>
                  <option value='<%= "" %>' selected="selected" ></option>
                  <%  for (int i=gregDateToday.get(gregDateToday.YEAR)-3, k=i+6; i <= k; i++) { %>
                    <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                  <%  }    %>
                </if:IfTrue>
                <if:IfTrue cond='<%= !addPrivateContractBean.getCwtn_end_year().equals("") %>'>
                  <option value='<%= "" %>'></option>
                  <%  for (int i=gregDateToday.get(gregDateToday.YEAR)-3, k=i+6; i <= k; i++) {
                        if (i == Integer.parseInt(addPrivateContractBean.getCwtn_end_year())) { %>
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
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>

      <%-- bus_category field --%>
      <tr>
        <td colspan="3">
          <if:IfTrue cond='<%= addPrivateContractBean.getBusiness_cat().equals("") %>' >
            <b>Business Cat.:</b>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! addPrivateContractBean.getBusiness_cat().equals("") %>' >
            <b>Business Cat.:</b><br/>
            (Scroll to selected <b><%= addPrivateContractBean.getBusiness_cat() %></b>)
          </if:IfTrue>
        </td>
      </tr>
      <tr>
        <td colspan="3">
          <div class="scroll_area_full">
            <table cellpadding="2" cellspacing="0" width="100%">
            <sql:query>
              select bus_category, cate_desc 
              from bus_categories
              order by bus_category
            </sql:query>
            <sql:resultSet id="rset">
              <% 
                if(color=="#ffffff") {
                  color = "#ecf5ff";
                } else if (color=="#ecf5ff") {
                  color = "#ffffff";
                }
              %>
              <tr bgcolor="<%= color %>" >
                <td valign="top" width="10">
                  <sql:getColumn position="1" to="bus_category" />
                  <% String bus_category = ((String)pageContext.getAttribute("bus_category")).trim(); %>
                  <sql:getColumn position="2" to="cate_desc" />
                  <% String cate_desc = ((String)pageContext.getAttribute("cate_desc")).trim(); %> 
      
                  <input type="radio" name="business_cat" 
                    id="BUSINESS_CAT|<%= bus_category %>" 
                    value="<%= bus_category %>"
                    <if:IfTrue cond='<%= bus_category.equals(addPrivateContractBean.getBusiness_cat()) %>' >
                      checked="checked" 
                    </if:IfTrue>
                  />
                </td>
                <td valign="top">
                  <label for="BUSINESS_CAT|<%= bus_category %>">
                    <b><%= bus_category %></b>
                  </label>
                </td>
              <tr>
              <tr bgcolor="<%= color %>" >
                <td valign="top" width="10">&nbsp;</td>
                <td valign="top">
                  <label for="BUSINESS_CAT|<%= bus_category %>">
                    <%= cate_desc %>
                  </label>
                </td>
              </tr>
            </sql:resultSet>
            </table>
          </div>
        </td>
      </tr>
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>
      <tr>
        <td colspan="2">
          <b>Disposal Meth.</b>
        </td>
        <td>
          <input type="text" name="disposal_method" size="15" maxlength="40"
            value="<%= addPrivateContractBean.getDisposal_method() %>" />
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <b>Exact Location</b>
        </td>
        <td>
          <input type="text" name="exact_location" size="15" maxlength="70"
            value="<%= addPrivateContractBean.getExact_location() %>" />
        </td>
      </tr>
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>

      <%-- disposer_ref field --%>
      <tr>
        <td colspan="3">
          <if:IfTrue cond='<%= addPrivateContractBean.getDisposer_ref().equals("") %>' >
            <b>Waste Disposer:</b>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! addPrivateContractBean.getDisposer_ref().equals("") %>' >
            <b>Waste Disposer:</b><br/>
            (Scroll to selected <b><%= addPrivateContractBean.getDisposer_ref() %></b>)
          </if:IfTrue>
        </td>
      </tr>
      <tr>
        <td colspan="3">
          <div class="scroll_area_full">
            <table cellpadding="2" cellspacing="0" width="100%">
            <sql:query>
              select disposer_ref, disposer_name
              from waste_disposer
              order by disposer_ref
            </sql:query>
            <sql:resultSet id="rset">
              <% 
                if(color=="#ffffff") {
                  color = "#ecf5ff";
                } else if (color=="#ecf5ff") {
                  color = "#ffffff";
                }
              %>
              <tr bgcolor="<%= color %>" >
                <td valign="top" width="10">
                  <sql:getColumn position="1" to="disposer_ref" />
                  <% String disposer_ref = ((String)pageContext.getAttribute("disposer_ref")).trim(); %>
                  <sql:getColumn position="2" to="disposer_name" />
                  <% String disposer_name = ((String)pageContext.getAttribute("disposer_name")).trim(); %> 
      
                  <input type="radio" name="disposer_ref" 
                    id="WASTE_DISPOSER|<%= disposer_ref %>" 
                    value="<%= disposer_ref %>"
                    <if:IfTrue cond='<%= disposer_ref.equals(addPrivateContractBean.getDisposer_ref()) %>' >
                      checked="checked" 
                    </if:IfTrue>
                  />
                </td>
                <td valign="top">
                  <label for="WASTE_DISPOSER|<%= disposer_ref %>">
                    <b><%= disposer_ref %></b>
                  </label>
                </td>
              <tr>
              <tr bgcolor="<%= color %>" >
                <td valign="top" width="10">&nbsp;</td>
                <td valign="top">
                  <label for="WASTE_DISPOSER|<%= disposer_ref %>">
                    <%= disposer_name %>
                  </label>
                </td>
              </tr>
            </sql:resultSet>
            </table>
          </div>
        </td>
      </tr>
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>

      <%-- waste_type field --%>
      <tr>
        <td colspan="3">
          <if:IfTrue cond='<%= addPrivateContractBean.getWaste_type().equals("") %>' >
            <b>Waste Type:</b>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! addPrivateContractBean.getWaste_type().equals("") %>' >
            <b>Waste Type:</b><br/>
            (Scroll to selected <b><%= addPrivateContractBean.getWaste_type() %></b>)
          </if:IfTrue>
        </td>
      </tr>
      <tr>
        <td colspan="3">
          <div class="scroll_area_full">
            <table cellpadding="2" cellspacing="0" width="100%">
            <sql:query>
              select waste_type, waste_desc
              from waste_type
              order by waste_type
            </sql:query>
            <sql:resultSet id="rset">
              <% 
                if(color=="#ffffff") {
                  color = "#ecf5ff";
                } else if (color=="#ecf5ff") {
                  color = "#ffffff";
                }
              %>
              <tr bgcolor="<%= color %>" >
                <td valign="top" width="10">
                  <sql:getColumn position="1" to="waste_type" />
                  <% String waste_type = ((String)pageContext.getAttribute("waste_type")).trim(); %>
                  <sql:getColumn position="2" to="waste_desc" />
                  <% String waste_desc = ((String)pageContext.getAttribute("waste_desc")).trim(); %> 
      
                  <input type="radio" name="waste_type" 
                    id="WASTE_TYPE|<%= waste_type %>" 
                    value="<%= waste_type %>"
                    <if:IfTrue cond='<%= waste_type.equals(addPrivateContractBean.getWaste_type()) %>' >
                      checked="checked" 
                    </if:IfTrue>
                  />
                </td>
                <td valign="top">
                  <label for="WASTE_TYPE|<%= waste_type %>">
                    <b><%= waste_type %></b>
                  </label>
                </td>
              <tr>
              <tr bgcolor="<%= color %>" >
                <td valign="top" width="10">&nbsp;</td>
                <td valign="top">
                  <label for="WASTE_TYPE|<%= waste_type %>">
                    <%= waste_desc %>
                  </label>
                </td>
              </tr>
            </sql:resultSet>
            </table>
          </div>
        </td>
      </tr>
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>

      <%-- pa_area field --%>
      <tr>
        <td colspan="3">
          <if:IfTrue cond='<%= addPrivateContractBean.getPa_area().equals("") %>' >
            <b>Patrol Area:</b>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! addPrivateContractBean.getPa_area().equals("") %>' >
            <b>Patrol Area:</b><br/>
            (Scroll to selected <b><%= addPrivateContractBean.getPa_area() %></b>)
          </if:IfTrue>
        </td>
      </tr>
      <tr>
        <td colspan="3">
          <div class="scroll_area_full">
            <table cellpadding="2" cellspacing="0" width="100%">
            <sql:query>
              select lookup_code, lookup_text
              from allk
              where lookup_func = 'PATRL' 
              order by lookup_code
            </sql:query>
            <sql:resultSet id="rset">
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
                  <sql:getColumn position="2" to="lookup_text" />
                  <% String lookup_text = ((String)pageContext.getAttribute("lookup_text")).trim(); %> 
      
                  <input type="radio" name="pa_area" 
                    id="PATRL|<%= lookup_code %>" 
                    value="<%= lookup_code %>"
                    <if:IfTrue cond='<%= lookup_code.equals(addPrivateContractBean.getPa_area()) %>' >
                      checked="checked" 
                    </if:IfTrue>
                  />
                </td>
                <td valign="top">
                  <label for="PATRL|<%= lookup_code %>">
                    <b><%= lookup_code %></b>
                  </label>
                </td>
              </tr>
              <tr bgcolor="<%= color %>" >
                <td valign="top" width="10">&nbsp;</td>
                <td valign="top">
                  <label for="PATRL|<%= lookup_code %>">
                    <%= lookup_text %>
                  </label>
                </td>
              </tr>
            </sql:resultSet>
            </table>
          </div>
        </td>
      </tr>
      <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>

      <%-- notes field --%>
      <tr>
        <td colspan="3">
          <b>Notes</b><br/>
          <textarea rows="4" cols="28" name="notes" ><jsp:getProperty name="addPrivateContractBean" property="notes" /></textarea>
        </td>
      </tr>
      <tr><td colspan="3">&nbsp;</td></tr>
    </table>
    </sql:statement> 
    <sql:closeConnection conn="con"/>

    <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="addPrivateContract" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
