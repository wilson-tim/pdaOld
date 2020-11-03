<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="java.lang.Runtime" %>
<%@ page import="com.vsb.incidentBean" %>
<%@ page import="com.vsb.surveyBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag" prefix="do" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>

<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />
<jsp:useBean id="surveyBean" scope="session" class="com.vsb.surveyBean" />
<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="incident" id="xmltext">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_system_keys>
         <service_code></service_code>
      </dat:get_system_keys>
   </soapenv:Body>
</soapenv:Envelope>
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="systemkeys" scope="session"/>
<c:set var="WS_DATE_FORMAT"><x:out select="$systemkeys//element[keyname='WS_DATE_FORMAT']/c_field" /></c:set>
<%
    // Set the time zone
    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
    TimeZone.setDefault(dtz);   
 
    //SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
    String Java_Date_format="";
    String WS_DATE_FORMAT=(String)pageContext.getAttribute("WS_DATE_FORMAT");
    if(WS_DATE_FORMAT.equals("DMY4/")) Java_Date_format="dd/MM/yyyy";
    if(WS_DATE_FORMAT.equals("DMY2/")) Java_Date_format="dd/MM/yy";
    if(WS_DATE_FORMAT.equals("MDY4/")) Java_Date_format="MM/dd/yyyy";
    if(WS_DATE_FORMAT.equals("MDY2/")) Java_Date_format="MM/dd/yy";
    if(WS_DATE_FORMAT.equals("Y4MD/")) Java_Date_format="yyyy/MM/dd";
    if(WS_DATE_FORMAT.equals("Y2MD/")) Java_Date_format="yy/MM/dd";
    if(WS_DATE_FORMAT.equals("DMY4-")) Java_Date_format="dd-MM-yyyy";
    if(WS_DATE_FORMAT.equals("DMY2-")) Java_Date_format="dd-MM-yy";
    if(WS_DATE_FORMAT.equals("MDY4-")) Java_Date_format="MM-dd-yyyy";
    if(WS_DATE_FORMAT.equals("MDY2-")) Java_Date_format="MM-dd-yy";
    if(WS_DATE_FORMAT.equals("Y4MD-")) Java_Date_format="yyyy-MM-dd";
    if(WS_DATE_FORMAT.equals("Y2MD-")) Java_Date_format="yy-MM-dd";

    SimpleDateFormat formatDate = new SimpleDateFormat(Java_Date_format);
 
    Date todaysDate = new java.util.Date();
    String date = formatDate.format(todaysDate);

    incidentBean.setTransaction_date(date);
    incidentBean.setDate_raised(date);

    incidentBean.setTransaction_source("E");
    incidentBean.setTransaction_type("I");
    incidentBean.setUsername("PUBLIC");
    incidentBean.setRecvd_by("PUBLIC");
    /*incidentBean.setAction_type((String)pageContext.getAttribute("default_status"));*/

    if(surveyBean.size()>0){
        String s=incidentBean.getIncident_notes();
        for(int i=0;i<surveyBean.size();++i){
            s=s + "|" + surveyBean.getQuestionByIndex(i) + ":" + surveyBean.getAnswerByIndex(i);
        }
        surveyBean.clear();
        incidentBean.setIncident_notes(s);
    }
%>
<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="incident" id="xmltext">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:incident>
         <transaction_ref  ><%= incidentBean.getTransaction_ref() %></transaction_ref>
         <transaction_source  ><%= incidentBean.getTransaction_source() %></transaction_source>
         <transaction_type  ><%= incidentBean.getTransaction_type() %></transaction_type>
         <transaction_date  ><%= incidentBean.getTransaction_date() %></transaction_date>
         <incident_service  ><%= incidentBean.getIncident_service() %></incident_service>
         <incident_ext_id  ><%= incidentBean.getIncident_ext_id() %></incident_ext_id>
         <incident_parent_id  ><%= incidentBean.getIncident_parent_id() %></incident_parent_id>
         <contender_id  ><%= incidentBean.getContender_id() %></contender_id>
         <date_raised  ><%= incidentBean.getDate_raised() %></date_raised>
         <username  ><%= incidentBean.getUsername() %></username>
         <recvd_by  ><%= incidentBean.getRecvd_by() %></recvd_by>
         <incidentuprn  ><%= incidentBean.getIncidentuprn() %></incidentuprn>
         <incidentusrn  ><%= incidentBean.getIncidentusrn() %></incidentusrn>
         <easting  ><%= incidentBean.getEasting() %></easting>
         <northing  ><%= incidentBean.getNorthing() %></northing>
         <easting_end  ><%= incidentBean.getEasting_end() %></easting_end>
         <northing_end  ><%= incidentBean.getNorthing_end() %></northing_end>
         <item_ref  ><%= incidentBean.getItem_ref() %></item_ref>
         <feature_ref  ><%= incidentBean.getFeature_ref() %></feature_ref>
         <contract_ref  ><%= incidentBean.getContract_ref() %></contract_ref>
         <fault_code  ><%= incidentBean.getFault_code() %></fault_code>
         <exact_location  ><%= incidentBean.getExact_location() %></exact_location>
         <incident_notes  ><%= incidentBean.getIncident_notes() %></incident_notes>
         <action_type  ><%= incidentBean.getAction_type() %></action_type>
         <action_ref  ><%= incidentBean.getAction_ref() %></action_ref>
         <default_algorithm  ><%= incidentBean.getDefault_algorithm() %></default_algorithm>
         <algorithm_description  ><%= incidentBean.getAlgorithm_description() %></algorithm_description>
         <points  ><%= incidentBean.getPoints() %></points>
         <value  ><%= incidentBean.getValue() %></value>
         <rectify_date  ><%= incidentBean.getRectify_date() %></rectify_date>
         <rect_action_type  ><%= incidentBean.getRect_action_type() %></rect_action_type>
         <rect_action_user  ><%= incidentBean.getRect_action_user() %></rect_action_user>
         <rect_cont_type  ><%= incidentBean.getRect_cont_type() %></rect_cont_type>
         <rect_cont_user  ><%= incidentBean.getRect_cont_user() %></rect_cont_user>
         <rect_cont_date  ><%= incidentBean.getRect_cont_date() %></rect_cont_date>
         <rect_cont_comp  ><%= incidentBean.getRect_cont_comp() %></rect_cont_comp>
         <wo_suffix  ><%= incidentBean.getWo_suffix() %></wo_suffix>
         <wo_type  ><%= incidentBean.getWo_type() %></wo_type>
         <wo_status  ><%= incidentBean.getWo_status() %></wo_status>
         <wo_date_due  ><%= incidentBean.getWo_date_due() %></wo_date_due>
         <wo_date_compl  ><%= incidentBean.getWo_date_compl() %></wo_date_compl>
<% if(incidentBean.getWoTasksUprn().length==0){ %>         
         <wo_tasks >
            <element>
               <uprn></uprn>
               <task_ref></task_ref>
               <quantity></quantity>
               <unit_cost></unit_cost>
               <date_due></date_due>
            </element>
         </wo_tasks >
<% }else{ %>
         <wo_tasks>
<% for (int i=0;i<incidentBean.getWoTasksUprn().length; i++){ %>
           <element >
               <uprn ><%=incidentBean.getWoTasksUprn()[i] %></uprn>
               <task_ref ><%=incidentBean.getWoTasksTask_ref()[i] %></task_ref>
               <quantity ><%=incidentBean.getWoTasksQuantity()[i] %></quantity>
               <unit_cost ><%=incidentBean.getWoTasksUnitCost()[i] %></unit_cost>
               <date_due ><%=incidentBean.getWoTasksDateDue()[i] %></date_due>
            </element>
<% } %>
         </wo_tasks >
<% } %>         
         <allocation_ref  ><%= incidentBean.getAllocation_ref() %></allocation_ref>
         <pay_method  ><%= incidentBean.getPay_method() %></pay_method>
         <pay_amount  ><%= incidentBean.getPay_amount() %></pay_amount>
         <pay_auth_code  ><%= incidentBean.getPay_auth_code() %></pay_auth_code>
         <pay_date  ><%= incidentBean.getPay_date() %></pay_date>
         <pay_budget_ref  ><%= incidentBean.getPay_budget_ref() %></pay_budget_ref>
         <pay_recharge_ref  ><%= incidentBean.getPay_recharge_ref() %></pay_recharge_ref>
         <pay_status  ><%= incidentBean.getPay_status() %></pay_status>
         <pay_ref  ><%= incidentBean.getPay_ref() %></pay_ref>
         <card_id  ><%= incidentBean.getCard_id() %></card_id>
         <card_issue  ><%= incidentBean.getCard_issue() %></card_issue>
         <card_expiry_month  ><%= incidentBean.getCard_expiry_month() %></card_expiry_month>
         <card_expiry_year  ><%= incidentBean.getCard_expiry_year() %></card_expiry_year>
         <card_valid_from_month  ><%= incidentBean.getCard_valid_from_month() %></card_valid_from_month>
         <card_valid_from_year  ><%= incidentBean.getCard_valid_from_year() %></card_valid_from_year>
         <card_holder  ><%= incidentBean.getCard_holder() %></card_holder>
         <card_type  ><%= incidentBean.getCard_type() %></card_type>
         <card_security_code  ><%= incidentBean.getCard_security_code() %></card_security_code>
         <printer_name  ><%= incidentBean.getPrinter_name() %></printer_name>
         <case_closed  ><%= incidentBean.getCase_closed() %></case_closed>
         <vehicle_make  ><%= incidentBean.getVehicle_make() %></vehicle_make>
         <vehicle_model  ><%= incidentBean.getVehicle_model() %></vehicle_model>
         <vehicle_colour  ><%= incidentBean.getVehicle_colour() %></vehicle_colour>
         <vehicle_class  ><%= incidentBean.getVehicle_class() %></vehicle_class>
         <vehicle_condition  ><%= incidentBean.getVehicle_condition() %></vehicle_condition>
         <vehicle_registration  ><%= incidentBean.getVehicle_registration() %></vehicle_registration>
         <vin  ><%= incidentBean.getVin() %></vin>
         <officer_id  ><%= incidentBean.getOfficer_id() %></officer_id>
         <observed_number  ><%= incidentBean.getObserved_number() %></observed_number>
         <observed_units  ><%= incidentBean.getObserved_units() %></observed_units>
         <observed_since  ><%= incidentBean.getObserved_since() %></observed_since>
         <road_fund_flag  ><%= incidentBean.getRoad_fund_flag() %></road_fund_flag>
         <road_fund_valid  ><%= incidentBean.getRoad_fund_valid() %></road_fund_valid>
         <how_long_there  ><%= incidentBean.getHow_long_there() %></how_long_there>
         <date_stickered  ><%= incidentBean.getDate_stickered() %></date_stickered>
         <time_stickered_h  ><%= incidentBean.getTime_stickered_h() %></time_stickered_h>
         <time_stickered_m  ><%= incidentBean.getTime_stickered_m() %></time_stickered_m>
         <av_status  ><%= incidentBean.getAv_status() %></av_status>
         <av_status_desc  ><%= incidentBean.getAv_status_desc() %></av_status_desc>
         <av_status_date  ><%= incidentBean.getAv_status_date() %></av_status_date>
         <agreement_no  ><%= incidentBean.getAgreement_no() %></agreement_no>
         <trade_details  ><%= incidentBean.getTrade_details() %></trade_details>
<% if(incidentBean.getTradeTasksAgreeTaskNo().length==0){ %>         
         <trade_tasks>
            <element>
               <agree_task_no></agree_task_no>
               <collection_day></collection_day>
               <comp_code></comp_code>
            </element>
         </trade_tasks>
<% }else{ %>
             <trade_tasks >
<% for (int i=0;i<incidentBean.getTradeTasksAgreeTaskNo().length; i++){ %>
                <element >
                   <agree_task_no ><%=incidentBean.getTradeTasksAgreeTaskNo()[i] %></agree_task_no>
                   <collection_day ><%=incidentBean.getTradeTasksCollectionDay()[i] %></collection_day>
                   <comp_code ><%=incidentBean.getTradeTasksCompCode()[i] %></comp_code>
                </element>
<% } %>
             </trade_tasks>
<% } %>
         <tree_ref  ><%= incidentBean.getTree_ref() %></tree_ref>
         <due_date  ><%= incidentBean.getDue_date() %></due_date>
         <request_type  ><%= incidentBean.getRequest_type() %></request_type>
         <request_quantity  ><%= incidentBean.getRequest_quantity() %></request_quantity>
         <schedule_ref  ><%= incidentBean.getSchedule_ref() %></schedule_ref>
         <reserve_date  ><%= incidentBean.getReserve_date() %></reserve_date>
         <force_flag  ><%= incidentBean.getForce_flag() %></force_flag>
         <items>
            <element>
               <collection_item_ref></collection_item_ref>
               <item_quantity></item_quantity>
            </element>
         </items>
         <customers >
            <element>
               <customer_ext_id ><%= incidentBean.getCustomer_ext_id() %></customer_ext_id>
               <customer_no ><%= incidentBean.getCustomer_no() %></customer_no>
               <customer_business_name ><%= incidentBean.getCustomer_business_name() %></customer_business_name>
               <customer_title ><%= incidentBean.getCustomer_title() %></customer_title>
               <customer_first_name ><%= incidentBean.getCustomer_first_name() %></customer_first_name>
               <customer_last_name ><%= incidentBean.getCustomer_last_name() %></customer_last_name>
               <customeruprn ><%= incidentBean.getCustomerUPRN() %></customeruprn>
               <customerusrn ><%= incidentBean.getCustomerUSRN() %></customerusrn>
               <customer_address1 ><%= incidentBean.getCustomer_address1() %></customer_address1>
               <customer_address2 ><%= incidentBean.getCustomer_address2() %></customer_address2>
               <customer_address3 ><%= incidentBean.getCustomer_address3() %></customer_address3>
               <customer_address4 ><%= incidentBean.getCustomer_address4() %></customer_address4>
               <customer_address5 ><%= incidentBean.getCustomer_address5() %></customer_address5>
               <customer_postcode ><%= incidentBean.getCustomer_postcode() %></customer_postcode>
               <customer_homephone ><%= incidentBean.getCustomer_homephone() %></customer_homephone>
               <customer_workphone ><%= incidentBean.getCustomer_workphone() %></customer_workphone>
               <customer_mobilephone ><%= incidentBean.getCustomer_mobilephone() %></customer_mobilephone>
               <customer_fax ><%= incidentBean.getCustomer_fax() %></customer_fax>
               <customer_email ><%= incidentBean.getCustomer_email() %></customer_email>
            </element>
         </customers>
         <account_ref ><%= incidentBean.getAccount_ref() %></account_ref>
          <attachments>
<%
if(incidentBean.getAttachmentsCount()>0){
    for(int i=0;i<incidentBean.getAttachmentsCount();++i){
        String s=incidentBean.getAttachmentsByIndex(i);
%>
            <element>
              <filename><%=s %></filename>
            </element>
<%
    }
}else{
%>
            <element>
              <filename></filename>
            </element>
<%    
}
%>
         </attachments>
     </dat:incident>
   </soapenv:Body>
</soapenv:Envelope>
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<% System.out.println("XML:text |" + (String)pageContext.getAttribute("xmltext") + "|" );%>
<x:parse xml="${xmltext}" var="incidentResult" scope="session"/>
<x:if select="$incidentResult//.[status_flag='Y']">
<c:set var="contender_id"><x:out select="$incidentResult//contender_id" /></c:set>
<%
incidentBean.setIncident_notes("");
if(incidentBean.getAttachmentsCount()>0){
    for(int i=0;i<incidentBean.getAttachmentsCount();++i){
        String s=incidentBean.getAttachmentsByIndex(i);
        s=getServletContext().getRealPath("sendAttachments.bat") + " " + s + " " + pageContext.getAttribute("contender_id");
        Runtime.getRuntime().exec(new String[]{"cmd.exe", "/c", s}); 
    }
}
%>
</x:if>
<jsp:forward page="postIncidentView.jsp" />
