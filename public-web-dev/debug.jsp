<%@ page import="com.vsb.incidentBean" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />
<html>
  <head>
    <meta http-equiv="Refresh" content="<app:initParameter name='refreshInterval' />" />
    <title><x:out select="$WAHeader//headers/element/web_type_desc"  /></title>
    <style type="text/css">@import url(publicaccess.css);</style>
    <script src="cSuggest.js"></script> 
    <link rel="stylesheet" type="text/css" href="cSuggest.css" /> 
  </head>
  <body>
        <table>
        <tr><td>Transaction_ref</td><td><input name="transaction_ref" value="<%=incidentBean.getTransaction_ref() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Transaction_source</td><td><input name="transaction_source" value="<%=incidentBean.getTransaction_source() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Transaction_type</td><td><input name="transaction_type" value="<%=incidentBean.getTransaction_type() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Transaction_date</td><td><input name="transaction_date" value="<%=incidentBean.getTransaction_date() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Incident_service</td><td><input name="incident_service" value="<%=incidentBean.getIncident_service() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Incident_ext_id</td><td><input name="incident_ext_id" value="<%=incidentBean.getIncident_ext_id() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Incident_parent_id</td><td><input name="incident_parent_id" value="<%=incidentBean.getIncident_parent_id() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Contender_id</td><td><input name="contender_id" value="<%=incidentBean.getContender_id() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Date_raised</td><td><input name="date_raised" value="<%=incidentBean.getDate_raised() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Username</td><td><input name="username" value="<%=incidentBean.getUsername() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Recvd_by</td><td><input name="recvd_by" value="<%=incidentBean.getRecvd_by() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Incidentuprn</td><td><input name="incidentuprn" value="<%=incidentBean.getIncidentuprn() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Incidentusrn</td><td><input name="incidentusrn" value="<%=incidentBean.getIncidentusrn() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Easting</td><td><input name="easting" value="<%=incidentBean.getEasting() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Northing</td><td><input name="northing" value="<%=incidentBean.getNorthing() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Easting_end</td><td><input name="easting_end" value="<%=incidentBean.getEasting_end() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Northing_end</td><td><input name="northing_end" value="<%=incidentBean.getNorthing_end() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Item_ref</td><td><input name="item_ref" value="<%=incidentBean.getItem_ref() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Feature_ref</td><td><input name="feature_ref" value="<%=incidentBean.getFeature_ref() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Contract_ref</td><td><input name="contract_ref" value="<%=incidentBean.getContract_ref() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Fault_code</td><td><input name="fault_code" value="<%=incidentBean.getFault_code() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Exact_location</td><td><input name="exact_location" value="<%=incidentBean.getExact_location() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Incident_notes</td><td><input name="incident_notes" value="<%=incidentBean.getIncident_notes() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Action_type</td><td><input name="action_type" value="<%=incidentBean.getAction_type() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Action_ref</td><td><input name="action_ref" value="<%=incidentBean.getAction_ref() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Default_algorithm</td><td><input name="default_algorithm" value="<%=incidentBean.getDefault_algorithm() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Algorithm_description</td><td><input name="algorithm_description" value="<%=incidentBean.getAlgorithm_description() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Points</td><td><input name="points" value="<%=incidentBean.getPoints() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Value</td><td><input name="value" value="<%=incidentBean.getValue() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Rectify_date</td><td><input name="rectify_date" value="<%=incidentBean.getRectify_date() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Rect_action_type</td><td><input name="rect_action_type" value="<%=incidentBean.getRect_action_type() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Rect_action_user</td><td><input name="rect_action_user" value="<%=incidentBean.getRect_action_user() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Rect_cont_type</td><td><input name="rect_cont_type" value="<%=incidentBean.getRect_cont_type() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Rect_cont_user</td><td><input name="rect_cont_user" value="<%=incidentBean.getRect_cont_user() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Rect_cont_date</td><td><input name="rect_cont_date" value="<%=incidentBean.getRect_cont_date() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Rect_cont_comp</td><td><input name="rect_cont_comp" value="<%=incidentBean.getRect_cont_comp() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Wo_suffix</td><td><input name="wo_suffix" value="<%=incidentBean.getWo_suffix() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Wo_type</td><td><input name="wo_type" value="<%=incidentBean.getWo_type() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Wo_status</td><td><input name="wo_status" value="<%=incidentBean.getWo_status() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Wo_date_due</td><td><input name="wo_date_due" value="<%=incidentBean.getWo_date_due() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Wo_date_compl</td><td><input name="wo_date_compl" value="<%=incidentBean.getWo_date_compl() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Allocation_ref</td><td><input name="allocation_ref" value="<%=incidentBean.getAllocation_ref() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Pay_method</td><td><input name="pay_method" value="<%=incidentBean.getPay_method() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Pay_amount</td><td><input name="pay_amount" value="<%=incidentBean.getPay_amount() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Pay_auth_code</td><td><input name="pay_auth_code" value="<%=incidentBean.getPay_auth_code() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Pay_date</td><td><input name="pay_date" value="<%=incidentBean.getPay_date() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Pay_budget_ref</td><td><input name="pay_budget_ref" value="<%=incidentBean.getPay_budget_ref() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Pay_recharge_ref</td><td><input name="pay_recharge_ref" value="<%=incidentBean.getPay_recharge_ref() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Pay_status</td><td><input name="pay_status" value="<%=incidentBean.getPay_status() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Pay_ref</td><td><input name="pay_ref" value="<%=incidentBean.getPay_ref() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Card_id</td><td><input name="card_id" value="<%=incidentBean.getCard_id() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Card_issue</td><td><input name="card_issue" value="<%=incidentBean.getCard_issue() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Card_expiry_month</td><td><input name="card_expiry_month" value="<%=incidentBean.getCard_expiry_month() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Card_expiry_year</td><td><input name="card_expiry_year" value="<%=incidentBean.getCard_expiry_year() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Card_valid_from_month</td><td><input name="card_valid_from_month" value="<%=incidentBean.getCard_valid_from_month() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Card_valid_from_year</td><td><input name="card_valid_from_year" value="<%=incidentBean.getCard_valid_from_year() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Card_holder</td><td><input name="card_holder" value="<%=incidentBean.getCard_holder() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Card_type</td><td><input name="card_type" value="<%=incidentBean.getCard_type() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Card_security_code</td><td><input name="card_security_code" value="<%=incidentBean.getCard_security_code() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Printer_name</td><td><input name="printer_name" value="<%=incidentBean.getPrinter_name() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Case_closed</td><td><input name="case_closed" value="<%=incidentBean.getCase_closed() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Vehicle_make</td><td><input name="vehicle_make" value="<%=incidentBean.getVehicle_make() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Vehicle_model</td><td><input name="vehicle_model" value="<%=incidentBean.getVehicle_model() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Vehicle_colour</td><td><input name="vehicle_colour" value="<%=incidentBean.getVehicle_colour() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Vehicle_class</td><td><input name="vehicle_class" value="<%=incidentBean.getVehicle_class() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Vehicle_condition</td><td><input name="vehicle_condition" value="<%=incidentBean.getVehicle_condition() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Vehicle_registration</td><td><input name="vehicle_registration" value="<%=incidentBean.getVehicle_registration() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Vin</td><td><input name="vin" value="<%=incidentBean.getVin() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Officer_id</td><td><input name="officer_id" value="<%=incidentBean.getOfficer_id() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Observed_number</td><td><input name="observed_number" value="<%=incidentBean.getObserved_number() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Observed_units</td><td><input name="observed_units" value="<%=incidentBean.getObserved_units() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Observed_since</td><td><input name="observed_since" value="<%=incidentBean.getObserved_since() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Road_fund_flag</td><td><input name="road_fund_flag" value="<%=incidentBean.getRoad_fund_flag() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Road_fund_valid</td><td><input name="road_fund_valid" value="<%=incidentBean.getRoad_fund_valid() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>How_long_there</td><td><input name="how_long_there" value="<%=incidentBean.getHow_long_there() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Date_stickered</td><td><input name="date_stickered" value="<%=incidentBean.getDate_stickered() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Time_stickered_h</td><td><input name="time_stickered_h" value="<%=incidentBean.getTime_stickered_h() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Time_stickered_m</td><td><input name="time_stickered_m" value="<%=incidentBean.getTime_stickered_m() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Av_status</td><td><input name="av_status" value="<%=incidentBean.getAv_status() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Av_status_desc</td><td><input name="av_status_desc" value="<%=incidentBean.getAv_status_desc() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Av_status_date</td><td><input name="av_status_date" value="<%=incidentBean.getAv_status_date() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Agreement_no</td><td><input name="agreement_no" value="<%=incidentBean.getAgreement_no() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Trade_details</td><td><input name="trade_details" value="<%=incidentBean.getTrade_details() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Tree_ref</td><td><input name="tree_ref" value="<%=incidentBean.getTree_ref() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Due_date</td><td><input name="due_date" value="<%=incidentBean.getDue_date() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Request_type</td><td><input name="request_type" value="<%=incidentBean.getRequest_type() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Request_quantity</td><td><input name="request_quantity" value="<%=incidentBean.getRequest_quantity() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Schedule_ref</td><td><input name="schedule_ref" value="<%=incidentBean.getSchedule_ref() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Reserve_date</td><td><input name="reserve_date" value="<%=incidentBean.getReserve_date() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        <tr><td>Force_flag</td><td><input name="force_flag" value="<%=incidentBean.getForce_flag() %>" /></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=getService">Change</a></td></tr>
        </table>
  </body>
</html>