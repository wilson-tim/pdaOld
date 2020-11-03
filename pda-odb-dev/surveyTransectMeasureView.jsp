<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.recordBean, com.vsb.surveyTransectMeasureBean, com.vsb.surveyTransectMethodBean, com.vsb.surveySiteLookupBean, com.vsb.systemKeysBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="surveyTransectMeasureBean" scope="session" class="com.vsb.surveyTransectMeasureBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="surveyTransectMethodBean" scope="session" class="com.vsb.surveyTransectMethodBean" />
<jsp:useBean id="surveySiteLookupBean" scope="session" class="com.vsb.surveySiteLookupBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveyTransectMeasure" value="false">
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
  <title>surveyTransectMeasure</title>
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
  <form onSubmit="return singleclick();" action="surveyTransectMeasureScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Define Transect</b></font></h2>
        </td>
      </tr>
     	<if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("01") %>' >
				<tr>
					<td bgcolor="#eeeeee" align="center">
						<b>By Street Furniture</b>
					</td>
				</tr>
			</if:IfTrue>
			<if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("02") %>' >
				<tr>
					<td bgcolor="#eeeeee" align="center">
						<b>By House Number</b>
					</td>
				</tr>
			</if:IfTrue>
			<if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("03") %>' >
				<tr>
					<td bgcolor="#eeeeee" align="center">
						<b>By Text</b>
					</td>
				</tr>
			</if:IfTrue>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="surveyTransectMeasureBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>

    <%-- Check for usage of supersites --%>    
    <% boolean use_supersites = true; %>
    <%
      if (systemKeysBean.getContender_version().equals("v7")) {
        use_supersites = true;
      } else if (systemKeysBean.getContender_version().equals("v8")) {
      	if (systemKeysBean.getGenerate_supersites().equals("Y")) {
          use_supersites = true;
      	} else if (systemKeysBean.getGenerate_supersites().equals("N")) {
      		use_supersites = false;
      	}
      }
    %>
    
    <table width="100%">
      <tr>
      	<td>
      		<table width="100%">
						<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
							<sql:statement id="stmt" conn="con">
								<if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("01") %>' >
									<tr>
										<td>
											<if:IfTrue cond='<%= surveyTransectMeasureBean.getSl_switch().equals("Y")%>' >
												<sql:query>
													select
																	sl_sf_id,
																	sl_furniture.furniture_desc
													from
																	sl_sf,
																	sl_furniture
													where
																	sl_sf.furniture_type = sl_furniture.furniture_type
													and
																	site_ref = '<%= recordBean.getBv_site_ref() %>'
													order by
																	sl_sf_id
												</sql:query>
												<table width="100%">
													<tr>
														<td align="right">
															<b>Start:</b>
														</td>
														<td>
															<select name="start_post">
																<option value="">Choose:</option>
																	<sql:resultSet id="rset">
																	<sql:getColumn position="1" to="start_post" />
																		<if:IfTrue cond='<%= ((String)pageContext.getAttribute("start_post")).trim().equals(surveyTransectMeasureBean.getStart_post()) %>' >
																			<option value="<sql:getColumn position="1" />"  selected="selected" >
																				<sql:getColumn position="1" />::<sql:getColumn position="2" />
																			</option>
																		</if:IfTrue>
																		<if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("start_post")).trim().equals(surveyTransectMeasureBean.getStart_post()) %>' >
																			<option value="<sql:getColumn position="1" />">
																				<sql:getColumn position="1" />::<sql:getColumn position="2" />
																			</option>
																		</if:IfTrue>
																	</sql:resultSet>
															</select>
														</td>
													</tr>
													<tr>
														<td align="right">
															<b>End:</b>
														</td>
														<td>
															<select name="end_post">
																<option value="">Choose:</option>
																<sql:resultSet id="rset">
																<sql:getColumn position="1" to="end_post" />
																	<if:IfTrue cond='<%= ((String)pageContext.getAttribute("end_post")).trim().equals(surveyTransectMeasureBean.getEnd_post()) %>' >
																		<option value="<sql:getColumn position="1" />"  selected="selected" >
																			<sql:getColumn position="1" />::<sql:getColumn position="2" />
																		</option>
																	</if:IfTrue>
																	<if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("end_post")).trim().equals(surveyTransectMeasureBean.getEnd_post()) %>' >
																		<option value="<sql:getColumn position="1" />">
																			<sql:getColumn position="1" />::<sql:getColumn position="2" />
																		</option>
																	</if:IfTrue>
																</sql:resultSet>
															</select>
														</td>
													</tr>
												</table>
											</if:IfTrue>
											<if:IfTrue cond='<%= surveyTransectMeasureBean.getSl_switch().equals("N")%>' >
												<table border="0" width="100%">
													<tr>
														<td align="right">
															<b>Start:</b>
														</td>
														<td>
															<input type="text" name="start_post" size="6" value="<%=surveyTransectMeasureBean.getStart_post()%>" />
														</td>
													</tr>
													<tr>
														<td align="right">
															<b>End:</b>
														</td>
														<td>
															<input type="text" name="end_post" size="6" value="<%=surveyTransectMeasureBean.getEnd_post()%>" />
														</td>
													</tr>
												</table>
											</if:IfTrue>
										</td>
									</tr>
								</if:IfTrue>

								<if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("02") %>' >
									<if:IfTrue cond='<%= ! surveyTransectMeasureBean.getHn_count().equals("0") %>'>
										<tr>
											<td>
												<table border="0" width="100%">
												<sql:query>
													select  distinct
																	build_no
													from
																	site
													where
																	location_c IN
																	(
																		select
																						location_c
																		from
																						site
																		where
																						site_ref = '<%= recordBean.getBv_site_ref() %>'
																	)
                                                    <if:IfTrue cond='<%= use_supersites == true %>' >
                                                      and
                                                        site_ref not like '%S'
                                                      and
                                                        site_ref not like '%G'
                                                    </if:IfTrue>
                                                    <if:IfTrue cond='<%= use_supersites == false %>' >
                                                      and
                                                        site_c = 'P'
                                                    </if:IfTrue>
													and
																	build_no is not null
													order by
																	build_no
												</sql:query>
												<tr>
													<td align="right">
														<b>Start:</b>
													</td>
													<td>
														<select name="start_house">
															<option value="">Choose:</option>
															<sql:resultSet id="rset">
																<sql:getColumn position="1" to="start_house" />
																<if:IfTrue cond='<%= ((String)pageContext.getAttribute("start_house")).trim().equals(surveyTransectMeasureBean.getStart_house()) %>' >
																	<option value="<sql:getColumn position="1" />"  selected="selected" >
																		<sql:getColumn position="1" />
																	</option>
																</if:IfTrue>
																<if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("start_house")).trim().equals(surveyTransectMeasureBean.getStart_house()) %>' >
																	<option value="<sql:getColumn position="1" />">
																		<sql:getColumn position="1" />
																	</option>
																</if:IfTrue>
															</sql:resultSet>
														</select>
													</td>
												</tr>
												<tr>
													<td align="right">
														<b>End:</b>
													</td>
													<td>
														<select name="end_house">
															<option value="">Choose:</option>
															<sql:resultSet id="rset">
																<sql:getColumn position="1" to="end_house" />
																<if:IfTrue cond='<%= ((String)pageContext.getAttribute("end_house")).trim().equals(surveyTransectMeasureBean.getEnd_house()) %>' >
																	<option value="<sql:getColumn position="1" />"  selected="selected" >
																		<sql:getColumn position="1" />
																	</option>
																</if:IfTrue>
																<if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("end_house")).trim().equals(surveyTransectMeasureBean.getEnd_house()) %>' >
																	<option value="<sql:getColumn position="1" />">
																		<sql:getColumn position="1" />
																	</option>
																</if:IfTrue>
															</sql:resultSet>
														</select>
													</td>
												</tr>
											</table>
										</td>
									</tr>
								</if:IfTrue>

								<if:IfTrue cond='<%= surveyTransectMeasureBean.getHn_count().equals("0") %>'>
									<tr>
										<td>
											<table width="100%">
												<tr>
													<td align="right">
														<b>Start:</b>
													</td>
													<td>
														<input type="text" name="start_house" size="6" value="<%=surveyTransectMeasureBean.getStart_house()%>" />
													</td>
												</tr>
												<tr>
													<td align="right">
														<b>End:</b>
													</td>
													<td>
														<input type="text" name="end_house" size="6" value="<%=surveyTransectMeasureBean.getEnd_house()%>" />
													</td>
												</tr>
											</table>
										</td>
									</tr>
								</if:IfTrue>
							</if:IfTrue>

							<if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("03") %>' >
								<tr>
									<td>
										<table width="100%">
											<tr>
												<td>
													<textarea name="transect_desc" cols="18"><%=surveyTransectMeasureBean.getTransect_desc()%></textarea>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</if:IfTrue>
						</sql:statement>
						<sql:closeConnection conn="con"/>
					</table>
				</td>
			</tr>
		</table>

    <jsp:include page="include/back_continue_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="surveyTransectMeasure" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
