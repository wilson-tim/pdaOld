<%@ page errorPage="error.jsp" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.vsb.propertyDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="propertyDetailsBean" scope="session" class="com.vsb.propertyDetailsBean" />
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
<sess:equalsAttribute name="form" match="propertyDetails" value="false">
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
  <title>propertyDetails</title>
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
  <form onSubmit="return singleclick();" action="propertyDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Property Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="propertyDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td align="center" colspan="2"><b><jsp:getProperty name="recordBean" property="site_name_1" /></b></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />

      <%-- Show the user where they are if using maps --%>
      <app:equalsInitParameter name="use_map" match="Y" >
        <% String xWorldCenter = ""; %>
        <% String yWorldCenter = ""; %>
        <sql:statement id="stmtEandN" conn="con">
          <sql:query>
            SELECT easting,
                   northing
              FROM site_detail
             WHERE site_ref = '<%= recordBean.getSite_ref() %>'
          </sql:query>
          <sql:resultSet id="rset5">
            <sql:getColumn position="1" to="easting" />
            <% xWorldCenter = ((String) pageContext.getAttribute("easting")); %>
            <sql:getColumn position="2" to="northing" />
            <% yWorldCenter = ((String) pageContext.getAttribute("northing")); %>
          </sql:resultSet>
        </sql:statement>
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
        <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      </app:equalsInitParameter>

      <%-- get the counts for the different sections --%>
      <% int br_count = 0; %>
      <% int pc_count = 0; %>
      <% int ec_count = 0; %>
      <% int cc_count = 0; %>
      <sql:statement id="stmtCount" conn="con">
        <sql:query>
          SELECT count(vo_descrip)
          FROM business_rates
          WHERE match_uprn = '<%= recordBean.getSite_ref() %>'
        </sql:query>
        <sql:resultSet id="rsetCount">
          <sql:getColumn position="1" to="br_count" />
          <sql:wasNotNull>
            <% br_count =  Integer.parseInt(((String)pageContext.getAttribute("br_count")).trim()); %>
          </sql:wasNotNull>
        </sql:resultSet>

        <sql:query>
          SELECT count(trading_org_log.last_updated)
          FROM trading_org, trading_org_log
          WHERE trading_org.site_ref = '<%= recordBean.getSite_ref() %>'
          AND   trading_org_log.trader_ref = trading_org.trader_ref
          AND   trading_org_log.seq_no = 1
        </sql:query>
        <sql:resultSet id="rsetCount">
          <sql:getColumn position="1" to="pc_count" />
          <sql:wasNotNull>
            <% pc_count =  Integer.parseInt(((String)pageContext.getAttribute("pc_count")).trim()); %>
          </sql:wasNotNull>
        </sql:resultSet>

        <sql:query>
          SELECT count(agreement.start_date)
          FROM agreement, trade_site
          WHERE trade_site.site_ref = '<%= recordBean.getSite_ref() %>'
          AND   agreement.site_ref = trade_site.site_no
        </sql:query>
        <sql:resultSet id="rsetCount">
          <sql:getColumn position="1" to="ec_count" />
          <sql:wasNotNull>
            <% ec_count =  Integer.parseInt(((String)pageContext.getAttribute("ec_count")).trim()); %>
          </sql:wasNotNull>
        </sql:resultSet>

        <sql:query>
          SELECT count(date_entered)
          FROM comp
          WHERE site_ref = '<%= recordBean.getSite_ref() %>'
        </sql:query>
        <sql:resultSet id="rsetCount">
          <sql:getColumn position="1" to="cc_count" />
          <sql:wasNotNull>
            <% cc_count =  Integer.parseInt(((String)pageContext.getAttribute("cc_count")).trim()); %>
          </sql:wasNotNull>
        </sql:resultSet>
      </sql:statement>
      <%-- Total of all records --%>
      <% int total_count = br_count + pc_count + ec_count + cc_count; %>
      <tr>
        <td colspan="2">
          <ul>
            <li>
              <input type="hidden" name="summary" 
                     value="<%= propertyDetailsBean.getSummary() %>" />
              <a name="Summary"></a>
              <input type="submit" name="action" value="Summary"
                     style="color: black; font-weight: bold; font-size: 85%" />
              <%= total_count %>
            </li>
            <if:IfTrue cond='<%= propertyDetailsBean.getSummary().equals("show") %>' >
            <ul>
              <li>
                <input type="hidden" name="business_rates" 
                       value="<%= propertyDetailsBean.getBusiness_rates() %>" />
                <a name="Business Rates"></a>
                <input type="submit" name="action" value="Business Rates"
                       style="color: black; font-weight: bold; font-size: 85%" />
                <%= br_count %>
              </li>
              <if:IfTrue cond='<%= propertyDetailsBean.getBusiness_rates().equals("show") %>' >
              <ul>
              <sql:statement id="stmtBR1" conn="con">
                <sql:query>
                  SELECT distinct vo_descrip
                  FROM business_rates
                  WHERE match_uprn = '<%= recordBean.getSite_ref() %>'
                </sql:query>
                <sql:resultSet id="rsetBR1">
                  <% String vo_descrip = ""; %>
                  <sql:getColumn position="1" to="vo_descrip" />
                  <sql:wasNotNull>
                    <% vo_descrip = ((String)pageContext.getAttribute("vo_descrip")).trim(); %>
                  </sql:wasNotNull>
                  <if:IfTrue cond='<%= vo_descrip.equals("") %>' >
                    <% vo_descrip = "*NONE*"; %>
                  </if:IfTrue>
                  <li>
                    <input type="hidden" name="br_vo_descrip" 
                           value="<%= propertyDetailsBean.getBr_vo_descrip() %>" />
                    <i>Type of Premises:</i>
                    <a name="<%= vo_descrip %>"></a>
                    <input type="submit" name="br_vo_descrip_action" value="<%= vo_descrip %>"
                           style="color: black; font-style: italic; font-size: 85%" />
                  </li>
                  <if:IfTrue cond='<%= propertyDetailsBean.getBr_vo_descrip().equals(vo_descrip) %>' >
                  <ul>
                  <sql:statement id="stmtBR2" conn="con">
                    <sql:query>
                      SELECT distinct account_holder
                      FROM business_rates
                      WHERE match_uprn = '<%= recordBean.getSite_ref() %>'
                      AND   vo_descrip = '<%= vo_descrip %>'
                    </sql:query>
                    <sql:resultSet id="rsetBR2">
                      <% String account_holder = ""; %>
                      <sql:getColumn position="1" to="account_holder" />
                      <sql:wasNotNull>
                        <% account_holder = ((String)pageContext.getAttribute("account_holder")).trim(); %>
                      </sql:wasNotNull>
                      <if:IfTrue cond='<%= account_holder.equals("") %>' >
                        <% account_holder = "*NONE*"; %>
                      </if:IfTrue>
                      <li>
                        <input type="hidden" name="br_account_holder" 
                               value="<%= propertyDetailsBean.getBr_account_holder() %>" />
                        <i>Account Holder:</i>
                        <a name="<%= account_holder %>"></a>
                        <input type="submit" name="br_account_holder_action" value="<%= account_holder %>"
                               style="color: black; font-style: italic; font-size: 85%" />
                      </li>
                      <if:IfTrue cond='<%= propertyDetailsBean.getBr_account_holder().equals(account_holder) %>' >
                      <ul>
                      <sql:statement id="stmtBR2" conn="con">
                        <sql:query>
                          SELECT current_rv, updated_date
                          FROM business_rates
                          WHERE match_uprn = '<%= recordBean.getSite_ref() %>'
                          AND   vo_descrip = '<%= vo_descrip %>'
                          AND   account_holder = '<%= account_holder %>'
                        </sql:query>
                        <sql:resultSet id="rsetBR2">
                          <% String current_rv = ""; %>
                          <sql:getColumn position="1" to="current_rv" />
                          <sql:wasNotNull>
                            <% current_rv = ((String)pageContext.getAttribute("current_rv")).trim(); %>
                          </sql:wasNotNull>
                          
                          <% String updated_date = ""; %>
                          <sql:getDate position="2" to="updated_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
                          <sql:wasNotNull>
                            <% updated_date = ((String)pageContext.getAttribute("updated_date")).trim(); %>
                          </sql:wasNotNull>

                          <li><b>Rateable Value:</b> <%= current_rv %></li>
                          <li>Updated Date: <%= helperBean.dispDate(updated_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></li>
                        <%-- BR3 --%>
                        </sql:resultSet>
                      </sql:statement>
                      </ul>
                      <%-- br_account_holder --%>
                      </if:IfTrue>
                    <%-- BR2 --%>
                    </sql:resultSet>
                  </sql:statement>
                  </ul>
                  <%-- br_vo_descrip --%>
                  </if:IfTrue>
                <%-- BR1 --%>
                </sql:resultSet>
                <sql:wasEmpty>
                  <li><i><b>None available</b></i></li>
                </sql:wasEmpty>
              </sql:statement>
              </ul>
              <%-- Business Rates --%>
              </if:IfTrue> 
            </ul>
            <ul>
              <li>
                <input type="hidden" name="private_contracts" 
                       value="<%= propertyDetailsBean.getPrivate_contracts() %>" />
                <a name="Private Contracts"></a>
                <input type="submit" name="action" value="Private Contracts"
                       style="color: black; font-weight: bold; font-size: 85%" />
                <%= pc_count %>
              </li>
              <if:IfTrue cond='<%= propertyDetailsBean.getPrivate_contracts().equals("show") %>' >
              <ul>
              <sql:statement id="stmtPC1" conn="con">
                <sql:query>
                  SELECT distinct trading_org_log.last_updated
                  FROM trading_org, trading_org_log
                  WHERE trading_org.site_ref = '<%= recordBean.getSite_ref() %>'
                  AND   trading_org_log.trader_ref = trading_org.trader_ref
                  AND   trading_org_log.seq_no = 1
                </sql:query>
                <sql:resultSet id="rsetPC1">
                  <% String last_updated = ""; %>
                  <sql:getDate position="1" to="last_updated" format="<%= application.getInitParameter("db_date_fmt") %>" />
                  <sql:wasNotNull>
                    <% last_updated = ((String)pageContext.getAttribute("last_updated")).trim(); %>
                  </sql:wasNotNull>
                  <if:IfTrue cond='<%= last_updated.equals("") %>' >
                    <% last_updated = "*NONE*"; %>
                  </if:IfTrue>
                  <li>
                    <input type="hidden" name="pc_last_updated" 
                           value="<%= propertyDetailsBean.getPc_last_updated() %>" />
                    <a name="<%= helperBean.dispDate(last_updated, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>"></a>
                    <input type="submit" name="pc_last_updated_action" value="<%= helperBean.dispDate(last_updated, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>"
                           style="color: black; font-style: italic; font-size: 85%" />
                  </li>
                  <if:IfTrue cond='<%= propertyDetailsBean.getPc_last_updated().equals(helperBean.dispDate(last_updated, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt"))) %>' >
                  <ul>
                  <sql:statement id="stmtPC2" conn="con">
                    <sql:query>
                      SELECT distinct trading_org.origin
                      FROM trading_org, trading_org_log
                      WHERE trading_org.site_ref = '<%= recordBean.getSite_ref() %>'
                      AND   trading_org_log.trader_ref = trading_org.trader_ref
                      AND   trading_org_log.seq_no = 1
                      AND   trading_org_log.last_updated = '<%= last_updated %>'
                    </sql:query>
                    <sql:resultSet id="rsetPC2">
                      <% String origin = ""; %>
                      <sql:getColumn position="1" to="origin" />
                      <sql:wasNotNull>
                        <% origin = ((String)pageContext.getAttribute("origin")).trim(); %>
                      </sql:wasNotNull>
                      <if:IfTrue cond='<%= origin.equals("") %>' >
                        <% origin = "*NONE*"; %>
                      </if:IfTrue>
                      <li>
                        <input type="hidden" name="pc_origin" 
                               value="<%= propertyDetailsBean.getPc_origin() %>" />
                        <i>Origin: </i>
                        <a name="<%= origin %>"></a>
                        <input type="submit" name="pc_origin_action" value="<%= origin %>"
                               style="color: black; font-style: italic; font-size: 85%" />
                      </li>
                      <if:IfTrue cond='<%= propertyDetailsBean.getPc_origin().equals(origin) %>' >
                      <ul>
                      <sql:statement id="stmtPC3" conn="con">
                        <sql:query>
                          SELECT distinct trading_org.business_name 
                          FROM trading_org, trading_org_log
                          WHERE trading_org.site_ref = '<%= recordBean.getSite_ref() %>'
                          AND   trading_org.origin = '<%= origin %>'
                          AND   trading_org_log.trader_ref = trading_org.trader_ref
                          AND   trading_org_log.seq_no = 1
                          AND   trading_org_log.last_updated = '<%= last_updated %>'
                        </sql:query>
                        <sql:resultSet id="rsetPC3">
                          <% String business_name = ""; %>
                          <sql:getColumn position="1" to="business_name" />
                          <sql:wasNotNull>
                            <% business_name = ((String)pageContext.getAttribute("business_name")).trim(); %>
                          </sql:wasNotNull>
                          <if:IfTrue cond='<%= business_name.equals("") %>' >
                            <% business_name = "*NONE*"; %>
                          </if:IfTrue>

                          <li>
                            <input type="hidden" name="pc_business_name" 
                                   value="<%= propertyDetailsBean.getPc_business_name() %>" />
                            <i>Business Name: </i>
                            <a name="<%= business_name %>"></a>
                            <input type="submit" name="pc_business_name_action" value="<%= business_name %>"
                                   style="color: black; font-style: italic; font-size: 85%" />
                          </li>
                          <if:IfTrue cond='<%= propertyDetailsBean.getPc_business_name().equals(business_name) %>' >
                          <ul>
                          <sql:statement id="stmtPC4" conn="con">
                            <sql:query>
                              SELECT distinct trading_org.trader_ref,
                                     trading_org.ta_name, trading_org.waste_type, 
                                     trading_org.disposer_ref, trading_org.cwtn_start,
                                     trading_org.cwtn_end, trading_org.contract_size
                              FROM trading_org, trading_org_log
                              WHERE trading_org.site_ref = '<%= recordBean.getSite_ref() %>'
                              AND   trading_org.origin = '<%= origin %>'
                              AND   trading_org.business_name = '<%= business_name %>'
                              AND   trading_org_log.trader_ref = trading_org.trader_ref
                              AND   trading_org_log.seq_no = 1
                              AND   trading_org_log.last_updated = '<%= last_updated %>'
                            </sql:query>
                            <sql:resultSet id="rsetPC4">
                              <% String trader_ref = ""; %>
                              <sql:getColumn position="1" to="trader_ref" />
                              <sql:wasNotNull>
                                <% trader_ref = ((String)pageContext.getAttribute("trader_ref")).trim(); %>
                              </sql:wasNotNull>

                              <% String ta_name = ""; %>
                              <sql:getColumn position="2" to="ta_name" />
                              <sql:wasNotNull>
                                <% ta_name = ((String)pageContext.getAttribute("ta_name")).trim(); %>
                              </sql:wasNotNull>
    
                              <% String waste_type = ""; %>
                              <sql:getColumn position="3" to="waste_type" />
                              <sql:wasNotNull>
                                <% waste_type = ((String)pageContext.getAttribute("waste_type")).trim(); %>
                              </sql:wasNotNull>

                              <% String waste_desc = ""; %>
                              <sql:statement id="stmtPC5" conn="con">
                                <sql:query>
                                  select waste_desc
                                  from waste_type
                                  where waste_type = '<%= waste_type %>'
                                </sql:query>
                                <sql:resultSet id="rsetPC5">
                                  <sql:getColumn position="1" to="waste_desc" />
                                  <sql:wasNotNull>
                                    <% waste_desc = ((String)pageContext.getAttribute("waste_desc")).trim(); %>
                                  </sql:wasNotNull>
                                <%-- PC5 --%>
                                </sql:resultSet>
                              </sql:statement>
               
                              <% String disposer_ref = ""; %>
                              <sql:getColumn position="4" to="disposer_ref" />
                              <sql:wasNotNull>
                                <% disposer_ref = ((String)pageContext.getAttribute("disposer_ref")).trim(); %>
                              </sql:wasNotNull>
    
                              <% String disposer_name = ""; %>
                              <sql:statement id="stmtPC5" conn="con">
                                <sql:query>
                                  select disposer_name
                                  from waste_disposer
                                  where disposer_ref = '<%= disposer_ref %>'
                                </sql:query>
                                <sql:resultSet id="rsetPC5">
                                  <sql:getColumn position="1" to="disposer_name" />
                                  <sql:wasNotNull>
                                    <% disposer_name = ((String)pageContext.getAttribute("disposer_name")).trim(); %>
                                  </sql:wasNotNull>
                                <%-- PC5 --%>
                                </sql:resultSet>
                              </sql:statement>
               
                              <% String cwtn_start = ""; %>
                              <sql:getDate position="5" to="cwtn_start" format="<%= application.getInitParameter("db_date_fmt") %>" />
                              <sql:wasNotNull>
                                <% cwtn_start = ((String)pageContext.getAttribute("cwtn_start")).trim(); %>
                              </sql:wasNotNull>
    
                              <% String cwtn_end = ""; %>
                              <sql:getDate position="6" to="cwtn_end" format="<%= application.getInitParameter("db_date_fmt") %>" />
                              <sql:wasNotNull>
                                <% cwtn_end = ((String)pageContext.getAttribute("cwtn_end")).trim(); %>
                              </sql:wasNotNull>
    
                              <% String contract_size = ""; %>
                              <sql:getColumn position="7" to="contract_size" />
                              <sql:wasNotNull>
                                <% contract_size = ((String)pageContext.getAttribute("contract_size")).trim(); %>
                              </sql:wasNotNull>

                              <li>
                                <input type="radio" name="trader_ref" id="<%= trader_ref %>"
                                  value="<%= trader_ref %>"
                                  <if:IfTrue cond='<%= trader_ref.equals(propertyDetailsBean.getTrader_ref()) %>' >
                                    checked="checked"
                                  </if:IfTrue>
                                />
                                <label for="<%= trader_ref %>">
                                  <b>Trading Name:</b> <%= ta_name %>
                                </label>
                              </li>
                              <li>Waste Type: <%= waste_desc %></li>
                              <li>Disposer: <%= disposer_name%></li>
                              <li>CWTN Start Date: <%= helperBean.dispDate(cwtn_start, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></li>
                              <li>CWTN End Date: <%= helperBean.dispDate(cwtn_end, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></li>
                              <li>Size: <%= contract_size %></li>
                            <%-- PC4 --%>
                            </sql:resultSet>
                          </sql:statement>
                          </ul>
                          <%-- pc_business_name --%>
                          </if:IfTrue>
                        <%-- PC3 --%>
                        </sql:resultSet>
                      </sql:statement>
                      </ul>
                      <%-- pc_origin --%>
                      </if:IfTrue>
                    <%-- PC2 --%>
                    </sql:resultSet>
                  </sql:statement>
                  </ul>
                  <%-- pc_last_updated --%>
                  </if:IfTrue>
                <%-- PC1 --%>
                </sql:resultSet>
                <sql:wasEmpty>
                  <li><i><b>None available</b></i></li>
                </sql:wasEmpty>
              </sql:statement>
              </ul>
              <%-- Private Contracts --%>
              </if:IfTrue> 
            </ul>
            <ul>
              <li>
                <input type="hidden" name="existing_contracts" 
                       value="<%= propertyDetailsBean.getExisting_contracts() %>" />
                <a name="Existing Contracts"></a>
                <input type="submit" name="action" value="Existing Contracts"
                       style="color: black; font-weight: bold; font-size: 85%" />
                <%= ec_count %>
              </li>
              <if:IfTrue cond='<%= propertyDetailsBean.getExisting_contracts().equals("show") %>' >
              <ul>
              <sql:statement id="stmtEC1" conn="con">
                <sql:query>
                  SELECT distinct agreement.start_date
                  FROM agreement, trade_site
                  WHERE trade_site.site_ref = '<%= recordBean.getSite_ref() %>'
                  AND   agreement.site_ref = trade_site.site_no
                </sql:query>
                <sql:resultSet id="rsetEC1">
                  <% String start_date = ""; %>
                  <sql:getDate position="1" to="start_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
                  <sql:wasNotNull>
                    <% start_date = ((String)pageContext.getAttribute("start_date")).trim(); %>
                  </sql:wasNotNull>
                  <if:IfTrue cond='<%= start_date.equals("") %>' >
                    <% start_date = "*NONE*"; %>
                  </if:IfTrue>
                  <li>
                    <input type="hidden" name="ec_start_date" 
                           value="<%= propertyDetailsBean.getEc_start_date() %>" />
                    <a name="<%= helperBean.dispDate(start_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>"></a>
                    <input type="submit" name="ec_start_date_action" value="<%= helperBean.dispDate(start_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>"
                           style="color: black; font-style: italic; font-size: 85%" />
                  </li>
                  <if:IfTrue cond='<%= propertyDetailsBean.getEc_start_date().equals(helperBean.dispDate(start_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt"))) %>' >
                  <ul>
                  <sql:statement id="stmtEC2" conn="con">
                    <sql:query>
                      SELECT distinct agreement.origin
                      FROM agreement, trade_site
                      WHERE trade_site.site_ref = '<%= recordBean.getSite_ref() %>'
                      AND   agreement.site_ref = trade_site.site_no
                      AND   agreement.start_date = '<%= start_date %>'
                    </sql:query>
                    <sql:resultSet id="rsetEC2">
                      <% String origin = ""; %>
                      <sql:getColumn position="1" to="origin" />
                      <sql:wasNotNull>
                        <% origin = ((String)pageContext.getAttribute("origin")).trim(); %>
                      </sql:wasNotNull>
                      <if:IfTrue cond='<%= origin.equals("") %>' >
                        <% origin = "*NONE*"; %>
                      </if:IfTrue>
                      <li>
                        <input type="hidden" name="ec_origin" 
                               value="<%= propertyDetailsBean.getEc_origin() %>" />
                        <i>Origin: </i>
                        <a name="<%= origin %>"></a>
                        <input type="submit" name="ec_origin_action" value="<%= origin %>"
                               style="color: black; font-style: italic; font-size: 85%" />
                      </li>
                      <if:IfTrue cond='<%= propertyDetailsBean.getEc_origin().equals(origin) %>' >
                      <ul>
                      <sql:statement id="stmtEC3" conn="con">
                        <sql:query>
                          SELECT distinct trade_site.site_name 
                          FROM agreement, trade_site
                          WHERE trade_site.site_ref = '<%= recordBean.getSite_ref() %>'
                          AND   agreement.site_ref = trade_site.site_no
                          AND   agreement.start_date = '<%= start_date %>'
                          <if:IfTrue cond='<%= origin.equals("*NONE*") %>' >
                            AND   ( agreement.origin = '' OR agreement.origin is null )
                          </if:IfTrue>
                          <if:IfTrue cond='<%= ! origin.equals("*NONE*") %>' >
                            AND   agreement.origin = '<%= origin %>'
                          </if:IfTrue>
                        </sql:query>
                        <sql:resultSet id="rsetEC3">
                          <% String business_name = ""; %>
                          <sql:getColumn position="1" to="business_name" />
                          <sql:wasNotNull>
                            <% business_name = ((String)pageContext.getAttribute("business_name")).trim(); %>
                          </sql:wasNotNull>
                          <if:IfTrue cond='<%= business_name.equals("") %>' >
                            <% business_name = "*NONE*"; %>
                          </if:IfTrue>
                          <li>
                            <input type="hidden" name="ec_business_name" 
                                   value="<%= propertyDetailsBean.getEc_business_name() %>" />
                            <i>Business Name: </i>
                            <a name="<%= business_name %>"></a>
                            <input type="submit" name="ec_business_name_action" value="<%= business_name %>"
                                   style="color: black; font-style: italic; font-size: 85%" />
                          </li>
                          <if:IfTrue cond='<%= propertyDetailsBean.getEc_business_name().equals(business_name) %>' >
                          <ul>
                          <sql:statement id="stmtEC4" conn="con">
                            <sql:query>
                              SELECT distinct trade_site.ta_name, agreement.waste_type, 
                                     agreement.contractor_ref, agreement.review_date,
                                     agreement.agreement_code, agreement.agreement_value
                              FROM agreement, trade_site
                              WHERE trade_site.site_ref = '<%= recordBean.getSite_ref() %>'
                              AND   agreement.site_ref = trade_site.site_no
                              AND   agreement.start_date = '<%= start_date %>'
                              <if:IfTrue cond='<%= origin.equals("*NONE*") %>' >
                                AND   ( agreement.origin = '' OR agreement.origin is null )
                              </if:IfTrue>
                              <if:IfTrue cond='<%= ! origin.equals("*NONE*") %>' >
                                AND   agreement.origin = '<%= origin %>'
                              </if:IfTrue>
                              AND   trade_site.site_name = '<%= business_name %>'
                            </sql:query>
                            <sql:resultSet id="rsetEC4">
                              <% String ta_name = ""; %>
                              <sql:getColumn position="1" to="ta_name" />
                              <sql:wasNotNull>
                                <% ta_name = ((String)pageContext.getAttribute("ta_name")).trim(); %>
                              </sql:wasNotNull>
    
                              <% String waste_type = ""; %>
                              <sql:getColumn position="2" to="waste_type" />
                              <sql:wasNotNull>
                                <% waste_type = ((String)pageContext.getAttribute("waste_type")).trim(); %>
                              </sql:wasNotNull>

                              <% String waste_desc = ""; %>
                              <sql:statement id="stmtEC5" conn="con">
                                <sql:query>
                                  select waste_desc
                                  from waste_type
                                  where waste_type = '<%= waste_type %>'
                                </sql:query>
                                <sql:resultSet id="rsetEC5">
                                  <sql:getColumn position="1" to="waste_desc" />
                                  <sql:wasNotNull>
                                    <% waste_desc = ((String)pageContext.getAttribute("waste_desc")).trim(); %>
                                  </sql:wasNotNull>
                                <%-- EC5 --%>
                                </sql:resultSet>
                              </sql:statement>
               
                              <% String contractor_ref = ""; %>
                              <sql:getColumn position="3" to="contractor_ref" />
                              <sql:wasNotNull>
                                <% contractor_ref = ((String)pageContext.getAttribute("contractor_ref")).trim(); %>
                              </sql:wasNotNull>
    
                              <% String contractor_name = ""; %>
                              <sql:statement id="stmtEC5" conn="con">
                                <sql:query>
                                  select contr_name
                                  from cntr
                                  where contractor_ref = '<%= contractor_ref %>'
                                </sql:query>
                                <sql:resultSet id="rsetEC5">
                                  <sql:getColumn position="1" to="contractor_name" />
                                  <sql:wasNotNull>
                                    <% contractor_name = ((String)pageContext.getAttribute("contractor_name")).trim(); %>
                                  </sql:wasNotNull>
                                <%-- EC5 --%>
                                </sql:resultSet>
                              </sql:statement>
               
                              <% String review_date = ""; %>
                              <sql:getDate position="4" to="review_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
                              <sql:wasNotNull>
                                <% review_date = ((String)pageContext.getAttribute("review_date")).trim(); %>
                              </sql:wasNotNull>
    
                              <% String agreement_code = ""; %>
                              <sql:getColumn position="5" to="agreement_code" />
                              <sql:wasNotNull>
                                <% agreement_code = ((String)pageContext.getAttribute("agreement_code")).trim(); %>
                              </sql:wasNotNull>
    
                              <% String agreement_value = ""; %>
                              <sql:getColumn position="6" to="agreement_value" />
                              <sql:wasNotNull>
                                <% agreement_value = ((String)pageContext.getAttribute("agreement_value")).trim(); %>
                              </sql:wasNotNull>

                              <li><b>Trading Name:</b> <%= ta_name %></li>
                              <li>Waste Type: <%= waste_desc %></li>
                              <li>Contractor: <%= contractor_name %></li>
                              <li>Value: <%= agreement_value %></li>
                              <li>Contract No.: <%= agreement_code %></li>
                              <li>Review Date: <%= helperBean.dispDate(review_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></li>
                            <%-- EC4 --%>
                            </sql:resultSet>
                          </sql:statement>
                          </ul>
                          <%-- ec_business_name --%>
                          </if:IfTrue>
                        <%-- EC3 --%>
                        </sql:resultSet>
                      </sql:statement>
                      </ul>
                      <%-- ec_origin --%>
                      </if:IfTrue>
                    <%-- EC2 --%>
                    </sql:resultSet>
                  </sql:statement>
                  </ul>
                  <%-- ec_start_date --%>
                  </if:IfTrue>
                <%-- EC1 --%>
                </sql:resultSet>
                <sql:wasEmpty>
                  <li><i><b>None available</b></i></li>
                </sql:wasEmpty>
              </sql:statement>
              </ul>
              <%-- Existing Contracts --%>
              </if:IfTrue> 
            </ul>
            <ul>
              <li>
                <input type="hidden" name="customer_care" 
                       value="<%= propertyDetailsBean.getCustomer_care() %>" />
                <a name="Customer Care"></a>
                <input type="submit" name="action" value="Customer Care"
                       style="color: black; font-weight: bold; font-size: 85%" />
                <%= cc_count %>
              </li>
              <if:IfTrue cond='<%= propertyDetailsBean.getCustomer_care().equals("show") %>' >
              <ul>
              <sql:statement id="stmtCC1" conn="con">
                <sql:query>
                  SELECT distinct date_entered
                  FROM comp
                  WHERE site_ref = '<%= recordBean.getSite_ref() %>'
                </sql:query>
                <sql:resultSet id="rsetCC1">
                  <% String date_entered = ""; %>
                  <sql:getDate position="1" to="date_entered" format="<%= application.getInitParameter("db_date_fmt") %>" />
                  <sql:wasNotNull>
                    <% date_entered = ((String)pageContext.getAttribute("date_entered")).trim(); %>
                  </sql:wasNotNull>
                  <if:IfTrue cond='<%= date_entered.equals("") %>' >
                    <% date_entered = "*NONE*"; %>
                  </if:IfTrue>
                  <li>
                    <input type="hidden" name="cc_date_entered" 
                           value="<%= propertyDetailsBean.getCc_date_entered() %>" />
                    <a name="<%= helperBean.dispDate(date_entered, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>"></a>
                    <input type="submit" name="cc_date_entered_action" value="<%= helperBean.dispDate(date_entered, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>"
                           style="color: black; font-style: italic; font-size: 85%" />
                  </li>
                  <if:IfTrue cond='<%= propertyDetailsBean.getCc_date_entered().equals(helperBean.dispDate(date_entered, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt"))) %>' >
                  <ul>
                  <sql:statement id="stmtCC2" conn="con">
                    <sql:query>
                      SELECT distinct entered_by
                      FROM comp
                      WHERE site_ref = '<%= recordBean.getSite_ref() %>'
                      AND   date_entered = '<%= date_entered %>'
                    </sql:query>
                    <sql:resultSet id="rsetCC2">
                      <% String entered_by = ""; %>
                      <sql:getColumn position="1" to="entered_by" />
                      <sql:wasNotNull>
                        <% entered_by = ((String)pageContext.getAttribute("entered_by")).trim(); %>
                      </sql:wasNotNull>
                      <if:IfTrue cond='<%= entered_by.equals("") %>' >
                        <% entered_by = "*NONE*"; %>
                      </if:IfTrue>
                      <li>
                        <input type="hidden" name="cc_entered_by" 
                               value="<%= propertyDetailsBean.getCc_entered_by() %>" />
                        <i>Entered by: </i>
                        <a name="<%= entered_by %>"></a>
                        <input type="submit" name="cc_entered_by_action" value="<%= entered_by %>"
                               style="color: black; font-style: italic; font-size: 85%" />
                      </li>
                      <if:IfTrue cond='<%= propertyDetailsBean.getCc_entered_by().equals(entered_by) %>' >
                      <ul>
                      <sql:statement id="stmtCCR3" conn="con">
                        <sql:query>
                          SELECT distinct recvd_by
                          FROM comp
                          WHERE site_ref = '<%= recordBean.getSite_ref() %>'
                          AND   date_entered = '<%= date_entered %>'
                          AND   entered_by = '<%= entered_by %>'
                        </sql:query>
                        <sql:resultSet id="rsetCC3">
                          <% String recvd_by = ""; %>
                          <sql:getColumn position="1" to="recvd_by" />
                          <sql:wasNotNull>
                            <% recvd_by = ((String)pageContext.getAttribute("recvd_by")).trim(); %>
                          </sql:wasNotNull>
                          <if:IfTrue cond='<%= recvd_by.equals("") %>' >
                            <% recvd_by = "*NONE*"; %>
                          </if:IfTrue>
                          <li>
                            <input type="hidden" name="cc_received_by" 
                                   value="<%= propertyDetailsBean.getCc_received_by() %>" />
                            <i>Received by: </i>
                            <a name="<%= recvd_by %>"></a>
                            <input type="submit" name="cc_received_by_action" value="<%= recvd_by %>"
                                   style="color: black; font-style: italic; font-size: 85%" />
                          </li>
                          <if:IfTrue cond='<%= propertyDetailsBean.getCc_received_by().equals(recvd_by) %>' >
                          <ul>
                          <sql:statement id="stmtCCR4" conn="con">
                            <sql:query>
                              SELECT distinct comp.item_ref, item.item_desc
                              FROM comp, item
                              WHERE comp.site_ref = '<%= recordBean.getSite_ref() %>'
                              AND   comp.date_entered = '<%= date_entered %>'
                              AND   comp.entered_by = '<%= entered_by %>'
                              AND   comp.recvd_by = '<%= recvd_by %>'
                              AND   item.item_ref = comp.item_ref
                              AND   item.contract_ref = comp.contract_ref
                            </sql:query>
                            <sql:resultSet id="rsetCC4">
                              <% String item_ref = ""; %>
                              <sql:getColumn position="1" to="item_ref" />
                              <sql:wasNotNull>
                                <% item_ref = ((String)pageContext.getAttribute("item_ref")).trim(); %>
                              </sql:wasNotNull>

                              <% String item_desc = ""; %>
                              <sql:getColumn position="2" to="item_desc" />
                              <sql:wasNotNull>
                                <% item_desc = ((String)pageContext.getAttribute("item_desc")).trim(); %>
                              </sql:wasNotNull>
                              <if:IfTrue cond='<%= item_desc.equals("") %>' >
                                <% item_desc = "*NONE*"; %>
                              </if:IfTrue>
                              <li>
                                <input type="hidden" name="cc_item" 
                                       value="<%= propertyDetailsBean.getCc_item() %>" />
                                <i>Item: </i>
                                <a name="<%= item_desc %>"></a>
                                <input type="submit" name="cc_item_action" value="<%= item_desc %>"
                                       style="color: black; font-style: italic; font-size: 85%" />
                              </li>
                              <if:IfTrue cond='<%= propertyDetailsBean.getCc_item().equals(item_desc) %>' >
                              <ul>
                              <sql:statement id="stmtCC5" conn="con">
                                <sql:query>
                                  SELECT distinct comp_code
                                  FROM comp
                                  WHERE site_ref = '<%= recordBean.getSite_ref() %>'
                                  AND   date_entered = '<%= date_entered %>'
                                  AND   entered_by = '<%= entered_by %>'
                                  AND   recvd_by = '<%= recvd_by %>'
                                  AND   item_ref = '<%= item_ref %>'
                                </sql:query>
                                <sql:resultSet id="rsetCC5">
                                  <% String comp_code = ""; %>
                                  <sql:getColumn position="1" to="comp_code" />
                                  <sql:wasNotNull>
                                    <% comp_code = ((String)pageContext.getAttribute("comp_code")).trim(); %>
                                  </sql:wasNotNull>
                                  <if:IfTrue cond='<%= comp_code.equals("") %>' >
                                    <% comp_code = "*NONE*"; %>
                                  </if:IfTrue>
                                  <li>
                                    <input type="hidden" name="cc_fault" 
                                           value="<%= propertyDetailsBean.getCc_fault() %>" />
                                    <i>Fault: </i>
                                    <a name="<%= comp_code %>"></a>
                                    <input type="submit" name="cc_fault_action" value="<%= comp_code %>"
                                           style="color: black; font-style: italic; font-size: 85%" />
                                  </li>
                                  <if:IfTrue cond='<%= propertyDetailsBean.getCc_fault().equals(comp_code) %>' >
                                  <ul>
                                  <sql:statement id="stmtCC6" conn="con">
                                    <sql:query>
                                      SELECT date_closed, complaint_no, action_flag, dest_ref
                                      FROM comp
                                      WHERE site_ref = '<%= recordBean.getSite_ref() %>'
                                      AND   date_entered = '<%= date_entered %>'
                                      AND   entered_by = '<%= entered_by %>'
                                      AND   recvd_by = '<%= recvd_by %>'
                                      AND   item_ref = '<%= item_ref %>'
                                      AND   comp_code = '<%= comp_code %>'
                                    </sql:query>
                                    <sql:resultSet id="rsetCC6">
                                      <% String date_closed = ""; %>
                                      <sql:getDate position="1" to="date_closed" format="<%= application.getInitParameter("db_date_fmt") %>" />
                                      <sql:wasNotNull>
                                        <% date_closed = ((String)pageContext.getAttribute("date_closed")).trim(); %>
                                      </sql:wasNotNull>
    
                                      <% String complaint_no = ""; %>
                                      <sql:getColumn position="2" to="complaint_no" />
                                      <sql:wasNotNull>
                                        <% complaint_no = ((String)pageContext.getAttribute("complaint_no")).trim(); %>
                                      </sql:wasNotNull>
    
                                      <% String action_flag = ""; %>
                                      <sql:getColumn position="3" to="action_flag" />
                                      <sql:wasNotNull>
                                        <% action_flag = ((String)pageContext.getAttribute("action_flag")).trim(); %>
                                      </sql:wasNotNull>
                                      
                                      <% String dest_ref = ""; %>
                                      <sql:getColumn position="4" to="dest_ref" />
                                      <sql:wasNotNull>
                                        <% dest_ref = ((String)pageContext.getAttribute("dest_ref")).trim(); %>
                                      </sql:wasNotNull>
                                      <li><b>Closed Date:</b> <%= helperBean.dispDate(date_closed, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></li>
                                      <li>Complaint No.: <%= complaint_no %></li>
                                      <li>Dest. Flag: <%= action_flag %></li>
                                      <li>Dest. Ref.: <%= dest_ref %></li>
                                    <%-- CC6 --%>
                                    </sql:resultSet>
                                  </sql:statement>
                                  </ul>
                                  <%-- cc_fault --%>
                                  </if:IfTrue>
                                <%-- CC5 --%>
                                </sql:resultSet>
                              </sql:statement>
                              </ul>
                              <%-- cc_item --%>
                              </if:IfTrue>
                            <%-- CC4 --%>
                            </sql:resultSet>
                          </sql:statement>
                          </ul>
                          <%-- cc_received_by --%>
                          </if:IfTrue>
                        <%-- CC3 --%>
                        </sql:resultSet>
                      </sql:statement>
                      </ul>
                      <%-- cc_entered_by --%>
                      </if:IfTrue>
                    <%-- CC2 --%>
                    </sql:resultSet>
                  </sql:statement>
                  </ul>
                  <%-- cc_date_entered --%>
                  </if:IfTrue>
                <%-- CC1 --%>
                </sql:resultSet>
                <sql:wasEmpty>
                  <li><i><b>None available</b></i></li>
                </sql:wasEmpty>
              </sql:statement>
              </ul>
              <%-- Customer Care --%>
              </if:IfTrue> 
            </ul>
            <%-- Summary --%>
            </if:IfTrue> 
          </ul>
        </td>
      </tr>
      <sql:closeConnection conn="con"/>
    </table>
    <app:equalsInitParameter name="use_com_waste" match="Y" >
      <jsp:include page="include/back_privcon_buttons.jsp" flush="true" />
    </app:equalsInitParameter>
    <app:equalsInitParameter name="use_com_waste" match="Y" value="false" >
      <jsp:include page="include/back_button.jsp" flush="true" />
    </app:equalsInitParameter>

    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="propertyDetails" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
<c:if test="${param.anchor ne null}">
  <script type="text/javascript">
    document.location = "#<c:out value="${param.anchor}"/>";
  </script>
</c:if>
</html>
