<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.propertyDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

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
</head>

<body onUnload="">
  <form action="propertyDetailsScript.jsp" method="post">
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
      <tr>
        <td colspan="2">
          <ul>
            <li><b>Summary</b></li>
            <ul>
              <li><b>Business Rates</b></li>
              <ul>
              <sql:statement id="stmtBR1" conn="con">
                <sql:query>
                  SELECT distinct vo_descrip
                  FROM business_rates
                  WHERE match_uprn = '<%= recordBean.getSite_ref() %>'
                </sql:query>
                <sql:resultSet id="rsetBR1">
                  <sql:getColumn position="1" to="vo_descrip" />
                  <% String vo_descrip = ((String)pageContext.getAttribute("vo_descrip")).trim(); %>
                  <li><i>Type of Premises: <%= vo_descrip %></i></li>
                  <ul>
                  <sql:statement id="stmtBR2" conn="con">
                    <sql:query>
                      SELECT distinct account_holder
                      FROM business_rates
                      WHERE match_uprn = '<%= recordBean.getSite_ref() %>'
                      AND   vo_descrip = '<%= vo_descrip %>'
                    </sql:query>
                    <sql:resultSet id="rsetBR2">
                      <sql:getColumn position="1" to="account_holder" />
                      <% String account_holder = ((String)pageContext.getAttribute("account_holder")).trim(); %>
                      <li><i>Account Holder: <%= account_holder %></i></li>
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
                          <sql:getColumn position="2" to="updated_date" />
                          <sql:wasNotNull>
                            <% updated_date = ((String)pageContext.getAttribute("updated_date")).trim(); %>
                          </sql:wasNotNull>

                          <li><b>Rateable Value:</b> <%= current_rv %></li>
                          <li>Updated Date: <%= helperBean.dispDate(updated_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></li>
                        <%-- BR3 --%>
                        </sql:resultSet>
                      </sql:statement>
                      </ul>
                    <%-- BR2 --%>
                    </sql:resultSet>
                  </sql:statement>
                  </ul>
                <%-- BR1 --%>
                </sql:resultSet>
                <sql:wasEmpty>
                  <li><i><b>None available</b></i></li>
                </sql:wasEmpty>
              </sql:statement>
              </ul>
            </ul>
            <ul>
              <li><b>Private Contracts</b></li>
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
                  <sql:getColumn position="1" to="last_updated" />
                  <% String last_updated = ((String)pageContext.getAttribute("last_updated")).trim(); %>
                  <li><i><%= helperBean.dispDate(last_updated, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></i></li>
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
                      <sql:getColumn position="1" to="origin" />
                      <% String origin = ((String)pageContext.getAttribute("origin")).trim(); %>
                      <li><i>Origin: <%= origin %></i></li>
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
                          <sql:getColumn position="1" to="business_name" />
                          <% String business_name = ((String)pageContext.getAttribute("business_name")).trim(); %>

                          <li><i>Business Name: <%= business_name %></i></li>
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
                              <sql:getColumn position="5" to="cwtn_start" />
                              <sql:wasNotNull>
                                <% cwtn_start = ((String)pageContext.getAttribute("cwtn_start")).trim(); %>
                              </sql:wasNotNull>
    
                              <% String cwtn_end = ""; %>
                              <sql:getColumn position="6" to="cwtn_end" />
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
                        <%-- PC3 --%>
                        </sql:resultSet>
                      </sql:statement>
                      </ul>
                    <%-- PC2 --%>
                    </sql:resultSet>
                  </sql:statement>
                  </ul>
                <%-- PC1 --%>
                </sql:resultSet>
                <sql:wasEmpty>
                  <li><i><b>None available</b></i></li>
                </sql:wasEmpty>
              </sql:statement>
              </ul>
            </ul>
            <ul>
              <li><b>Existing Contracts</b></li>
              <ul>
              <sql:statement id="stmtEC1" conn="con">
                <sql:query>
                  SELECT distinct start_date
                  FROM agreement
                  WHERE site_ref = '<%= recordBean.getSite_ref() %>'
                </sql:query>
                <sql:resultSet id="rsetEC1">
                  <sql:getColumn position="1" to="start_date" />
                  <% String start_date = ((String)pageContext.getAttribute("start_date")).trim(); %>
                  <li><i><%= helperBean.dispDate(start_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></i></li>
                  <ul>
                  <sql:statement id="stmtEC2" conn="con">
                    <sql:query>
                      SELECT distinct origin
                      FROM agreement
                      WHERE site_ref = '<%= recordBean.getSite_ref() %>'
                      AND   start_date = '<%= start_date %>'
                    </sql:query>
                    <sql:resultSet id="rsetEC2">
                      <sql:getColumn position="1" to="origin" />
                      <% String origin = ((String)pageContext.getAttribute("origin")).trim(); %>
                      <li><i>Origin: <%= origin %></i></li>
                      <ul>
                      <sql:statement id="stmtEC3" conn="con">
                        <sql:query>
                          SELECT distinct site.business_name 
                          FROM agreement, site
                          WHERE agreement.site_ref = '<%= recordBean.getSite_ref() %>'
                          AND   agreement.start_date = '<%= start_date %>'
                          AND   agreement.origin = '<%= origin %>'
                          AND   site.site_ref = agreement.site_ref
                        </sql:query>
                        <sql:resultSet id="rsetEC3">
                          <sql:getColumn position="1" to="business_name" />
                          <% String business_name = ((String)pageContext.getAttribute("business_name")).trim(); %>

                          <li><i>Business Name: <%= business_name %></i></li>
                          <ul>
                          <sql:statement id="stmtEC4" conn="con">
                            <sql:query>
                              SELECT distinct site.ta_name, agreement.waste_type, 
                                     agreement.contractor_ref, agreement.review_date,
                                     agreement.agreement_code, agreement.agreement_value
                              FROM agreement, site
                              WHERE agreement.site_ref = '<%= recordBean.getSite_ref() %>'
                              AND   agreement.start_date = '<%= start_date %>'
                              AND   agreement.origin = '<%= origin %>'
                              AND   site.site_ref = agreement.site_ref
                              AND   site.business_name = <%= business_name %>
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
                                  select contractor_name
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
                              <sql:getColumn position="4" to="review_date" />
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
                        <%-- EC3 --%>
                        </sql:resultSet>
                      </sql:statement>
                      </ul>
                    <%-- EC2 --%>
                    </sql:resultSet>
                  </sql:statement>
                  </ul>
                <%-- EC1 --%>
                </sql:resultSet>
                <sql:wasEmpty>
                  <li><i><b>None available</b></i></li>
                </sql:wasEmpty>
              </sql:statement>
              </ul>
            </ul>
            <ul>
              <li><b>Customer Care</b></li>
              <ul>
              <sql:statement id="stmtCC1" conn="con">
                <sql:query>
                  SELECT distinct date_entered
                  FROM comp
                  WHERE site_ref = '<%= recordBean.getSite_ref() %>'
                </sql:query>
                <sql:resultSet id="rsetCC1">
                  <sql:getColumn position="1" to="date_entered" />
                  <% String date_entered = ((String)pageContext.getAttribute("date_entered")).trim(); %>
                  <li><i><%= helperBean.dispDate(date_entered, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></i></li>
                  <ul>
                  <sql:statement id="stmtCC2" conn="con">
                    <sql:query>
                      SELECT distinct entered_by
                      FROM comp
                      WHERE site_ref = '<%= recordBean.getSite_ref() %>'
                      AND   date_entered = '<%= date_entered %>'
                    </sql:query>
                    <sql:resultSet id="rsetCC2">
                      <sql:getColumn position="1" to="entered_by" />
                      <% String entered_by = ((String)pageContext.getAttribute("entered_by")).trim(); %>
                      <li><i>Entered by: <%= entered_by %></i></li>
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
                          <sql:getColumn position="1" to="recvd_by" />
                          <% String recvd_by = ((String)pageContext.getAttribute("recvd_by")).trim(); %>
                          <li><i>Received by: <%= recvd_by %></i></li>
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
                              <sql:getColumn position="1" to="item_ref" />
                              <% String item_ref = ((String)pageContext.getAttribute("item_ref")).trim(); %>

                              <sql:getColumn position="2" to="item_desc" />
                              <% String item_desc = ((String)pageContext.getAttribute("item_desc")).trim(); %>

                              <li><i>Item: <%= item_desc %></i></li>
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
                                  <sql:getColumn position="1" to="comp_code" />
                                  <% String comp_code = ((String)pageContext.getAttribute("comp_code")).trim(); %>
                                  <li><i>Fault: <%= comp_code %></i></li>
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
                                      <sql:getColumn position="1" to="date_closed" />
                                      <sql:wasNotNull>
                                        <% date_closed = ((String)pageContext.getAttribute("date_closed")).trim(); %>
                                      </sql:wasNotNull>
    
                                      <sql:getColumn position="2" to="complaint_no" />
                                      <% String complaint_no = ((String)pageContext.getAttribute("complaint_no")).trim(); %>
    
                                      <sql:getColumn position="3" to="action_flag" />
                                      <% String action_flag = ((String)pageContext.getAttribute("action_flag")).trim(); %>
                                      
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
                                <%-- CC5 --%>
                                </sql:resultSet>
                              </sql:statement>
                              </ul>
                            <%-- CC4 --%>
                            </sql:resultSet>
                          </sql:statement>
                          </ul>
                        <%-- CC3 --%>
                        </sql:resultSet>
                      </sql:statement>
                      </ul>
                    <%-- CC2 --%>
                    </sql:resultSet>
                  </sql:statement>
                  </ul>
                <%-- CC1 --%>
                </sql:resultSet>
                <sql:wasEmpty>
                  <li><i><b>None available</b></i></li>
                </sql:wasEmpty>
              </sql:statement>
              </ul>
            </ul>
          </ul>
        </td>
      </tr>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>
    <app:equalsInitParameter name="use_com_waste" match="Y" >
      <jsp:include page="include/back_next_buttons.jsp" flush="true" />
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
</html>
