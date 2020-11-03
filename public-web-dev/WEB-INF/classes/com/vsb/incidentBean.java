package com.vsb;

import com.db.DbUtils;
import java.util.StringTokenizer;
import java.util.ArrayList;

public class incidentBean extends formBean {

    private String Transaction_ref = "";
    private String Transaction_source = "";
    private String Transaction_type = "";
    private String Transaction_date = "";
    private String Incident_service = "";
    private String Incident_ext_id = "";
    private String Incident_parent_id = "";
    private String Contender_id = "";
    private String Date_raised = "";
    private String Username = "";
    private String Recvd_by = "";
    private String Incidentuprn = "";
    private String Incidentusrn = "";
    private String Easting = "";
    private String Northing = "";
    private String Easting_end = "";
    private String Northing_end = "";
    private String Item_ref = "";
    private String Feature_ref = "";
    private String Contract_ref = "";
    private String Fault_code = "";
    private String Exact_location = "";
    private String Incident_notes = "";
    private String Action_type = "";
    private String Action_ref = "";
    private String Default_algorithm = "";
    private String Algorithm_description = "";
    private String Points = "";
    private String Value = "";
    private String Rectify_date = "";
    private String Rect_action_type = "";
    private String Rect_action_user = "";
    private String Rect_cont_type = "";
    private String Rect_cont_user = "";
    private String Rect_cont_date = "";
    private String Rect_cont_comp = "";
    private String Wo_suffix = "";
    private String Wo_type = "";
    private String Wo_status = "";
    private String Wo_date_due = "";
    private String Wo_date_compl = "";
    private String Allocation_ref = "";
    private String Pay_method = "";
    private String Pay_amount = "";
    private String Pay_auth_code = "";
    private String Pay_date = "";
    private String Pay_budget_ref = "";
    private String Pay_recharge_ref = "";
    private String Pay_status = "";
    private String Pay_ref = "";
    private String Card_id = "";
    private String Card_issue = "";
    private String Card_expiry_month = "";
    private String Card_expiry_year = "";
    private String Card_valid_from_month = "";
    private String Card_valid_from_year = "";
    private String Card_holder = "";
    private String Card_type = "";
    private String Card_security_code = "";
    private String Printer_name = "";
    private String Case_closed = "";
    private String Vehicle_make = "";
    private String Vehicle_model = "";
    private String Vehicle_colour = "";
    private String Vehicle_class = "";
    private String Vehicle_condition = "";
    private String Vehicle_registration = "";
    private String Vin = "";
    private String Officer_id = "";
    private String Observed_number = "";
    private String Observed_units = "";
    private String Observed_since = "";
    private String Road_fund_flag = "";
    private String Road_fund_valid = "";
    private String How_long_there = "";
    private String Date_stickered = "";
    private String Time_stickered_h = "";
    private String Time_stickered_m = "";
    private String Av_status = "";
    private String Av_status_desc = "";
    private String Av_status_date = "";
    private String Agreement_no = "";
    private String Trade_details = "";
    private String Tree_ref = "";
    private String Due_date = "";
    private String Request_type = "";
    private String Request_quantity = "";
    private String Schedule_ref = "";
    private String Reserve_date = "";
    private String Force_flag = "";
    private String Customer_ext_id = "";
    private String Customer_no = "";
    private String Customer_business_name = "";
    private String Customer_title = "";
    private String Customer_first_name = "";
    private String Customer_last_name = "";
    private String CustomerUPRN = "";
    private String CustomerUSRN = "";
    private String Customer_address1 = "";
    private String Customer_address2 = "";
    private String Customer_address3 = "";
    private String Customer_address4 = "";
    private String Customer_address5 = "";
    private String Customer_postcode = "";
    private String Customer_homephone = "";
    private String Customer_workphone = "";
    private String Customer_mobilephone = "";
    private String Customer_fax = "";
    private String Customer_email = "";
    private String Account_ref = "";
    private String WebType = "";

    private String TradeTasksAgreeTaskNo[] = new String[0];
    private String TradeTasksCollectionDay[] = new String[0];
    private String TradeTasksCompCode[] = new String[0];

    private String WoTasksUprn[] = new String[0];
    private String WoTasksTask_ref[] = new String[0];
    private String WoTasksQuantity[] = new String[0];
    private String WoTasksUnitCost[] = new String[0];
    private String WoTasksDateDue[] = new String[0];
    
    private String UprnCode="";
    private String Item_combo="";
    public String site_address="";
    public ArrayList Attachments = new ArrayList();
    public ArrayList AttachmentsFilename = new ArrayList();

public String getWebType() {
    if(this.WebType.equals("")){
        return " "; 
    }else{
        return this.WebType; 
    }
} 

public void setWebType(String WebType) {
    this.WebType = DbUtils.cleanString(WebType);  
}

public void setAttachments(String Attachment){
    this.Attachments.add(Attachment);
}

public String getAttachments() {
    return ""; 
}

public int getAttachmentsCount(){
    return this.Attachments.size();
}

public String getAttachmentsByIndex(int index) {
    return ((String)this.Attachments.get(index));
}

public void clearAttachments(){
    this.Attachments = new ArrayList();
}

public void setUprnCode(String UprnCode){
    String[] elements=UprnCode.split("\\|",-1);
    if(elements.length>0){
        this.setIncidentuprn(elements[0]);
        this.setCustomerUPRN(elements[0]);
    }
    if(elements.length>1){
        this.setIncidentusrn(elements[1]);
        this.setCustomerUSRN(elements[1]);
    }
    if(elements.length>3){
        this.setCustomer_postcode(elements[2]);
    }

    String[] addr=elements[elements.length-1].split(",",-1);
    if(addr.length>0) this.setCustomer_address1(addr[0]);
    if(addr.length>1) this.setCustomer_address2(addr[1]);
    if(addr.length>2) this.setCustomer_address3(addr[2]);
    if(addr.length>3) this.setCustomer_address4(addr[3]);
    if(addr.length>4) this.setCustomer_address5(addr[4]);
}

public String getUprnCode() {
    return ""; 
} 

public void setItem_combo(String Item_combo){
    StringTokenizer view_key = new StringTokenizer(Item_combo, "|");
    if(view_key.hasMoreTokens()) this.setItem_ref(view_key.nextToken());
    if(view_key.hasMoreTokens()) this.setFeature_ref(view_key.nextToken());
    if(view_key.hasMoreTokens()) this.setContract_ref(view_key.nextToken());
}

public String getItem_combo() {
    return ""; 
} 

public String[] getTradeTasksAgreeTaskNo(){
    return TradeTasksAgreeTaskNo;
}
public void setTradeTasksAgreeTaskNo(String[] ia){
    this.TradeTasksAgreeTaskNo = ia;
}

public String[] getTradeTasksCollectionDay(){
    return TradeTasksCollectionDay;
}
public void setTradeTasksCollectionDay(String[] ia){
    this.TradeTasksCollectionDay = ia;
}

public String[] getTradeTasksCompCode(){
    return TradeTasksCompCode;
}
public void setTradeTasksCompCode(String[] ia){
    this.TradeTasksCompCode = ia;
}

public String[] getWoTasksUprn(){
    return WoTasksUprn;
}
public void setWoTasksUprn(String[] ia){
    this.WoTasksUprn = ia;
}

public String[] getWoTasksTask_ref(){
    return WoTasksTask_ref;
}
public void setWoTasksTask_ref(String[] ia){
    this.WoTasksTask_ref = ia;
}

public String[] getWoTasksQuantity(){
    return WoTasksQuantity;
}
public void setWoTasksQuantity(String[] ia){
    this.WoTasksQuantity = ia;
}

public String[] getWoTasksUnitCost(){
    return WoTasksUnitCost;
}
public void setWoTasksUnitCost(String[] ia){
    this.WoTasksUnitCost = ia;
}

public String[] getWoTasksDateDue(){
    return WoTasksDateDue;
}
public void setWoTasksDateDue(String[] ia){
    this.WoTasksDateDue = ia;
}

public String getTransaction_ref() {
    return Transaction_ref; 
} 

public void setTransaction_ref(String Transaction_ref) {
    this.Transaction_ref = DbUtils.cleanString(Transaction_ref);  
}

public String getTransaction_source() {
    return Transaction_source; 
} 

public void setTransaction_source(String Transaction_source) {
    this.Transaction_source = DbUtils.cleanString(Transaction_source);  
}

public String getTransaction_type() {
    return Transaction_type; 
} 

public void setTransaction_type(String Transaction_type) {
    this.Transaction_type = DbUtils.cleanString(Transaction_type);  
}

public String getTransaction_date() {
    return Transaction_date; 
} 

public void setTransaction_date(String Transaction_date) {
    this.Transaction_date = DbUtils.cleanString(Transaction_date);  
}

public String getIncident_service() {
    return Incident_service; 
} 

public void setIncident_service(String Incident_service) {
    this.Incident_service = DbUtils.cleanString(Incident_service);  
}

public String getIncident_ext_id() {
    return Incident_ext_id; 
} 

public void setIncident_ext_id(String Incident_ext_id) {
    this.Incident_ext_id = DbUtils.cleanString(Incident_ext_id);  
}

public String getIncident_parent_id() {
    return Incident_parent_id; 
} 

public void setIncident_parent_id(String Incident_parent_id) {
    this.Incident_parent_id = DbUtils.cleanString(Incident_parent_id);  
}

public String getContender_id() {
    return Contender_id; 
} 

public void setContender_id(String Contender_id) {
    this.Contender_id = DbUtils.cleanString(Contender_id);  
}

public String getDate_raised() {
    return Date_raised; 
} 

public void setDate_raised(String Date_raised) {
    this.Date_raised = DbUtils.cleanString(Date_raised);  
}

public String getUsername() {
    return Username; 
} 

public void setUsername(String Username) {
    this.Username = DbUtils.cleanString(Username);  
}

public String getRecvd_by() {
    return Recvd_by; 
} 

public void setRecvd_by(String Recvd_by) {
    this.Recvd_by = DbUtils.cleanString(Recvd_by);  
}

public String getIncidentuprn() {
    return Incidentuprn; 
} 

public void setIncidentuprn(String Incidentuprn) {
    this.Incidentuprn = DbUtils.cleanString(Incidentuprn);  
}

public String getIncidentusrn() {
    return Incidentusrn; 
} 

public void setIncidentusrn(String Incidentusrn) {
    this.Incidentusrn = DbUtils.cleanString(Incidentusrn);  
}

public String getEasting() {
    return Easting; 
} 

public void setEasting(String Easting) {
    this.Easting = DbUtils.cleanString(Easting);  
}

public String getNorthing() {
    return Northing; 
} 

public void setNorthing(String Northing) {
    this.Northing = DbUtils.cleanString(Northing);  
}

public String getEasting_end() {
    return Easting_end; 
} 

public void setEasting_end(String Easting_end) {
    this.Easting_end = DbUtils.cleanString(Easting_end);  
}

public String getNorthing_end() {
    return Northing_end; 
} 

public void setNorthing_end(String Northing_end) {
    this.Northing_end = DbUtils.cleanString(Northing_end);  
}

public String getItem_ref() {
    return Item_ref; 
} 

public void setItem_ref(String Item_ref) {
    this.Item_ref = DbUtils.cleanString(Item_ref);  
}

public String getFeature_ref() {
    return Feature_ref; 
} 

public void setFeature_ref(String Feature_ref) {
    this.Feature_ref = DbUtils.cleanString(Feature_ref);  
}

public String getContract_ref() {
    return Contract_ref; 
} 

public void setContract_ref(String Contract_ref) {
    this.Contract_ref = DbUtils.cleanString(Contract_ref);  
}

public String getFault_code() {
    return Fault_code; 
} 

public void setFault_code(String Fault_code) {
    this.Fault_code = DbUtils.cleanString(Fault_code);  
}

public String getExact_location() {
    return Exact_location; 
} 

public void setExact_location(String Exact_location) {
    this.Exact_location = DbUtils.cleanString(Exact_location);  
}

public String getIncident_notes() {
    return Incident_notes; 
} 

public void setIncident_notes(String Incident_notes) {
    this.Incident_notes = DbUtils.cleanString(Incident_notes);  
}

public String getAction_type() {
    return Action_type; 
} 

public void setAction_type(String Action_type) {
    this.Action_type = DbUtils.cleanString(Action_type);  
}

public String getAction_ref() {
    return Action_ref; 
} 

public void setAction_ref(String Action_ref) {
    this.Action_ref = DbUtils.cleanString(Action_ref);  
}

public String getDefault_algorithm() {
    return Default_algorithm; 
} 

public void setDefault_algorithm(String Default_algorithm) {
    this.Default_algorithm = DbUtils.cleanString(Default_algorithm);  
}

public String getAlgorithm_description() {
    return Algorithm_description; 
} 

public void setAlgorithm_description(String Algorithm_description) {
    this.Algorithm_description = DbUtils.cleanString(Algorithm_description);  
}

public String getPoints() {
    return Points; 
} 

public void setPoints(String Points) {
    this.Points = DbUtils.cleanString(Points);  
}

public String getValue() {
    return Value; 
} 

public void setValue(String Value) {
    this.Value = DbUtils.cleanString(Value);  
}

public String getRectify_date() {
    return Rectify_date; 
} 

public void setRectify_date(String Rectify_date) {
    this.Rectify_date = DbUtils.cleanString(Rectify_date);  
}

public String getRect_action_type() {
    return Rect_action_type; 
} 

public void setRect_action_type(String Rect_action_type) {
    this.Rect_action_type = DbUtils.cleanString(Rect_action_type);  
}

public String getRect_action_user() {
    return Rect_action_user; 
} 

public void setRect_action_user(String Rect_action_user) {
    this.Rect_action_user = DbUtils.cleanString(Rect_action_user);  
}

public String getRect_cont_type() {
    return Rect_cont_type; 
} 

public void setRect_cont_type(String Rect_cont_type) {
    this.Rect_cont_type = DbUtils.cleanString(Rect_cont_type);  
}

public String getRect_cont_user() {
    return Rect_cont_user; 
} 

public void setRect_cont_user(String Rect_cont_user) {
    this.Rect_cont_user = DbUtils.cleanString(Rect_cont_user);  
}

public String getRect_cont_date() {
    return Rect_cont_date; 
} 

public void setRect_cont_date(String Rect_cont_date) {
    this.Rect_cont_date = DbUtils.cleanString(Rect_cont_date);  
}

public String getRect_cont_comp() {
    return Rect_cont_comp; 
} 

public void setRect_cont_comp(String Rect_cont_comp) {
    this.Rect_cont_comp = DbUtils.cleanString(Rect_cont_comp);  
}

public String getWo_suffix() {
    return Wo_suffix; 
} 

public void setWo_suffix(String Wo_suffix) {
    this.Wo_suffix = DbUtils.cleanString(Wo_suffix);  
}

public String getWo_type() {
    return Wo_type; 
} 

public void setWo_type(String Wo_type) {
    this.Wo_type = DbUtils.cleanString(Wo_type);  
}

public String getWo_status() {
    return Wo_status; 
} 

public void setWo_status(String Wo_status) {
    this.Wo_status = DbUtils.cleanString(Wo_status);  
}

public String getWo_date_due() {
    return Wo_date_due; 
} 

public void setWo_date_due(String Wo_date_due) {
    this.Wo_date_due = DbUtils.cleanString(Wo_date_due);  
}

public String getWo_date_compl() {
    return Wo_date_compl; 
} 

public void setWo_date_compl(String Wo_date_compl) {
    this.Wo_date_compl = DbUtils.cleanString(Wo_date_compl);  
}

public String getAllocation_ref() {
    return Allocation_ref; 
} 

public void setAllocation_ref(String Allocation_ref) {
    this.Allocation_ref = DbUtils.cleanString(Allocation_ref);  
}

public String getPay_method() {
    return Pay_method; 
} 

public void setPay_method(String Pay_method) {
    this.Pay_method = DbUtils.cleanString(Pay_method);  
}

public String getPay_amount() {
    return Pay_amount; 
} 

public void setPay_amount(String Pay_amount) {
    this.Pay_amount = DbUtils.cleanString(Pay_amount);  
}

public String getPay_auth_code() {
    return Pay_auth_code; 
} 

public void setPay_auth_code(String Pay_auth_code) {
    this.Pay_auth_code = DbUtils.cleanString(Pay_auth_code);  
}

public String getPay_date() {
    return Pay_date; 
} 

public void setPay_date(String Pay_date) {
    this.Pay_date = DbUtils.cleanString(Pay_date);  
}

public String getPay_budget_ref() {
    return Pay_budget_ref; 
} 

public void setPay_budget_ref(String Pay_budget_ref) {
    this.Pay_budget_ref = DbUtils.cleanString(Pay_budget_ref);  
}

public String getPay_recharge_ref() {
    return Pay_recharge_ref; 
} 

public void setPay_recharge_ref(String Pay_recharge_ref) {
    this.Pay_recharge_ref = DbUtils.cleanString(Pay_recharge_ref);  
}

public String getPay_status() {
    return Pay_status; 
} 

public void setPay_status(String Pay_status) {
    this.Pay_status = DbUtils.cleanString(Pay_status);  
}

public String getPay_ref() {
    return Pay_ref; 
} 

public void setPay_ref(String Pay_ref) {
    this.Pay_ref = DbUtils.cleanString(Pay_ref);  
}

public String getCard_id() {
    return Card_id; 
} 

public void setCard_id(String Card_id) {
    this.Card_id = DbUtils.cleanString(Card_id);  
}

public String getCard_issue() {
    return Card_issue; 
} 

public void setCard_issue(String Card_issue) {
    this.Card_issue = DbUtils.cleanString(Card_issue);  
}

public String getCard_expiry_month() {
    return Card_expiry_month; 
} 

public void setCard_expiry_month(String Card_expiry_month) {
    this.Card_expiry_month = DbUtils.cleanString(Card_expiry_month);  
}

public String getCard_expiry_year() {
    return Card_expiry_year; 
} 

public void setCard_expiry_year(String Card_expiry_year) {
    this.Card_expiry_year = DbUtils.cleanString(Card_expiry_year);  
}

public String getCard_valid_from_month() {
    return Card_valid_from_month; 
} 

public void setCard_valid_from_month(String Card_valid_from_month) {
    this.Card_valid_from_month = DbUtils.cleanString(Card_valid_from_month);  
}

public String getCard_valid_from_year() {
    return Card_valid_from_year; 
} 

public void setCard_valid_from_year(String Card_valid_from_year) {
    this.Card_valid_from_year = DbUtils.cleanString(Card_valid_from_year);  
}

public String getCard_holder() {
    return Card_holder; 
} 

public void setCard_holder(String Card_holder) {
    this.Card_holder = DbUtils.cleanString(Card_holder);  
}

public String getCard_type() {
    return Card_type; 
} 

public void setCard_type(String Card_type) {
    this.Card_type = DbUtils.cleanString(Card_type);  
}

public String getCard_security_code() {
    return Card_security_code; 
} 

public void setCard_security_code(String Card_security_code) {
    this.Card_security_code = DbUtils.cleanString(Card_security_code);  
}

public String getPrinter_name() {
    return Printer_name; 
} 

public void setPrinter_name(String Printer_name) {
    this.Printer_name = DbUtils.cleanString(Printer_name);  
}

public String getCase_closed() {
    return Case_closed; 
} 

public void setCase_closed(String Case_closed) {
    this.Case_closed = DbUtils.cleanString(Case_closed);  
}

public String getVehicle_make() {
    return Vehicle_make; 
} 

public void setVehicle_make(String Vehicle_make) {
    this.Vehicle_make = DbUtils.cleanString(Vehicle_make);  
}

public String getVehicle_model() {
    return Vehicle_model; 
} 

public void setVehicle_model(String Vehicle_model) {
    this.Vehicle_model = DbUtils.cleanString(Vehicle_model);  
}

public String getVehicle_colour() {
    return Vehicle_colour; 
} 

public void setVehicle_colour(String Vehicle_colour) {
    this.Vehicle_colour = DbUtils.cleanString(Vehicle_colour);  
}

public String getVehicle_class() {
    return Vehicle_class; 
} 

public void setVehicle_class(String Vehicle_class) {
    this.Vehicle_class = DbUtils.cleanString(Vehicle_class);  
}

public String getVehicle_condition() {
    return Vehicle_condition; 
} 

public void setVehicle_condition(String Vehicle_condition) {
    this.Vehicle_condition = DbUtils.cleanString(Vehicle_condition);  
}

public String getVehicle_registration() {
    return Vehicle_registration; 
} 

public void setVehicle_registration(String Vehicle_registration) {
    this.Vehicle_registration = DbUtils.cleanString(Vehicle_registration);  
}

public String getVin() {
    return Vin; 
} 

public void setVin(String Vin) {
    this.Vin = DbUtils.cleanString(Vin);  
}

public String getOfficer_id() {
    return Officer_id; 
} 

public void setOfficer_id(String Officer_id) {
    this.Officer_id = DbUtils.cleanString(Officer_id);  
}

public String getObserved_number() {
    return Observed_number; 
} 

public void setObserved_number(String Observed_number) {
    this.Observed_number = DbUtils.cleanString(Observed_number);  
}

public String getObserved_units() {
    return Observed_units; 
} 

public void setObserved_units(String Observed_units) {
    this.Observed_units = DbUtils.cleanString(Observed_units);  
}

public String getObserved_since() {
    return Observed_since; 
} 

public void setObserved_since(String Observed_since) {
    this.Observed_since = DbUtils.cleanString(Observed_since);  
}

public String getRoad_fund_flag() {
    return Road_fund_flag; 
} 

public void setRoad_fund_flag(String Road_fund_flag) {
    this.Road_fund_flag = DbUtils.cleanString(Road_fund_flag);  
}

public String getRoad_fund_valid() {
    return Road_fund_valid; 
} 

public void setRoad_fund_valid(String Road_fund_valid) {
    this.Road_fund_valid = DbUtils.cleanString(Road_fund_valid);  
}

public String getHow_long_there() {
    return How_long_there; 
} 

public void setHow_long_there(String How_long_there) {
    this.How_long_there = DbUtils.cleanString(How_long_there);  
}

public String getDate_stickered() {
    return Date_stickered; 
} 

public void setDate_stickered(String Date_stickered) {
    this.Date_stickered = DbUtils.cleanString(Date_stickered);  
}

public String getTime_stickered_h() {
    return Time_stickered_h; 
} 

public void setTime_stickered_h(String Time_stickered_h) {
    this.Time_stickered_h = DbUtils.cleanString(Time_stickered_h);  
}

public String getTime_stickered_m() {
    return Time_stickered_m; 
} 

public void setTime_stickered_m(String Time_stickered_m) {
    this.Time_stickered_m = DbUtils.cleanString(Time_stickered_m);  
}

public String getAv_status() {
    return Av_status; 
} 

public void setAv_status(String Av_status) {
    this.Av_status = DbUtils.cleanString(Av_status);  
}

public String getAv_status_desc() {
    return Av_status_desc; 
} 

public void setAv_status_desc(String Av_status_desc) {
    this.Av_status_desc = DbUtils.cleanString(Av_status_desc);  
}

public String getAv_status_date() {
    return Av_status_date; 
} 

public void setAv_status_date(String Av_status_date) {
    this.Av_status_date = DbUtils.cleanString(Av_status_date);  
}

public String getAgreement_no() {
    return Agreement_no; 
} 

public void setAgreement_no(String Agreement_no) {
    this.Agreement_no = DbUtils.cleanString(Agreement_no);  
}

public String getTrade_details() {
    return Trade_details; 
} 

public void setTrade_details(String Trade_details) {
    this.Trade_details = DbUtils.cleanString(Trade_details);  
}

public String getTree_ref() {
    return Tree_ref; 
} 

public void setTree_ref(String Tree_ref) {
    this.Tree_ref = DbUtils.cleanString(Tree_ref);  
}

public String getDue_date() {
    return Due_date; 
} 

public void setDue_date(String Due_date) {
    this.Due_date = DbUtils.cleanString(Due_date);  
}

public String getRequest_type() {
    return Request_type; 
} 

public void setRequest_type(String Request_type) {
    this.Request_type = DbUtils.cleanString(Request_type);  
}

public String getRequest_quantity() {
    return Request_quantity; 
} 

public void setRequest_quantity(String Request_quantity) {
    this.Request_quantity = DbUtils.cleanString(Request_quantity);  
}

public String getSchedule_ref() {
    return Schedule_ref; 
} 

public void setSchedule_ref(String Schedule_ref) {
    this.Schedule_ref = DbUtils.cleanString(Schedule_ref);  
}

public String getReserve_date() {
    return Reserve_date; 
} 

public void setReserve_date(String Reserve_date) {
    this.Reserve_date = DbUtils.cleanString(Reserve_date);  
}

public String getForce_flag() {
    return Force_flag; 
} 

public void setForce_flag(String Force_flag) {
    this.Force_flag = DbUtils.cleanString(Force_flag);  
}

public String getCustomer_ext_id() {
    return Customer_ext_id; 
} 

public void setCustomer_ext_id(String Customer_ext_id) {
    this.Customer_ext_id = DbUtils.cleanString(Customer_ext_id);  
}

public String getCustomer_no() {
    return Customer_no; 
} 

public void setCustomer_no(String Customer_no) {
    this.Customer_no = DbUtils.cleanString(Customer_no);  
}

public String getCustomer_business_name() {
    return Customer_business_name; 
} 

public void setCustomer_business_name(String Customer_business_name) {
    this.Customer_business_name = DbUtils.cleanString(Customer_business_name);  
}

public String getCustomer_title() {
    return Customer_title; 
} 

public void setCustomer_title(String Customer_title) {
    this.Customer_title = DbUtils.cleanString(Customer_title);  
}

public String getCustomer_first_name() {
    return Customer_first_name; 
} 

public void setCustomer_first_name(String Customer_first_name) {
    this.Customer_first_name = DbUtils.cleanString(Customer_first_name);  
}

public String getCustomer_last_name() {
    return Customer_last_name; 
} 

public void setCustomer_last_name(String Customer_last_name) {
    this.Customer_last_name = DbUtils.cleanString(Customer_last_name);  
}

public String getCustomerUPRN() {
    return CustomerUPRN; 
} 

public void setCustomerUPRN(String CustomerUPRN) {
    this.CustomerUPRN = DbUtils.cleanString(CustomerUPRN);  
}

public String getCustomerUSRN() {
    return CustomerUSRN; 
} 

public void setCustomerUSRN(String CustomerUSRN) {
    this.CustomerUSRN = DbUtils.cleanString(CustomerUSRN);  
}

public String getCustomer_address1() {
    return Customer_address1; 
} 

public void setCustomer_address1(String Customer_address1) {
    this.Customer_address1 = DbUtils.cleanString(Customer_address1);  
}

public String getCustomer_address2() {
    return Customer_address2; 
} 

public void setCustomer_address2(String Customer_address2) {
    this.Customer_address2 = DbUtils.cleanString(Customer_address2);  
}

public String getCustomer_address3() {
    return Customer_address3; 
} 

public void setCustomer_address3(String Customer_address3) {
    this.Customer_address3 = DbUtils.cleanString(Customer_address3);  
}

public String getCustomer_address4() {
    return Customer_address4; 
} 

public void setCustomer_address4(String Customer_address4) {
    this.Customer_address4 = DbUtils.cleanString(Customer_address4);  
}

public String getCustomer_address5() {
    return Customer_address5; 
} 

public void setCustomer_address5(String Customer_address5) {
    this.Customer_address5 = DbUtils.cleanString(Customer_address5);  
}

public String getCustomer_postcode() {
    return Customer_postcode; 
} 

public void setCustomer_postcode(String Customer_postcode) {
    this.Customer_postcode = DbUtils.cleanString(Customer_postcode);  
}

public String getCustomer_homephone() {
    return Customer_homephone; 
} 

public void setCustomer_homephone(String Customer_homephone) {
    this.Customer_homephone = DbUtils.cleanString(Customer_homephone);  
}

public String getCustomer_workphone() {
    return Customer_workphone; 
} 

public void setCustomer_workphone(String Customer_workphone) {
    this.Customer_workphone = DbUtils.cleanString(Customer_workphone);  
}

public String getCustomer_mobilephone() {
    return Customer_mobilephone; 
} 

public void setCustomer_mobilephone(String Customer_mobilephone) {
    this.Customer_mobilephone = DbUtils.cleanString(Customer_mobilephone);  
}

public String getCustomer_fax() {
    return Customer_fax; 
} 

public void setCustomer_fax(String Customer_fax) {
    this.Customer_fax = DbUtils.cleanString(Customer_fax);  
}

public String getCustomer_email() {
    return Customer_email; 
} 

public void setCustomer_email(String Customer_email) {
    this.Customer_email = DbUtils.cleanString(Customer_email);  
}

public String getAccount_ref() {
    return Account_ref; 
} 

public void setAccount_ref(String Account_ref) {
    this.Account_ref = DbUtils.cleanString(Account_ref);  
}


    public void setAll(String all) {
        this.Transaction_ref = "";
        this.Transaction_source = "";
        this.Transaction_type = "";
        this.Transaction_date = "";
        this.Incident_service = "";
        this.Incident_ext_id = "";
        this.Incident_parent_id = "";
        this.Contender_id = "";
        this.Date_raised = "";
        this.Username = "";
        this.Recvd_by = "";
        this.Incidentuprn = "";
        this.Incidentusrn = "";
        this.Easting = "";
        this.Northing = "";
        this.Easting_end = "";
        this.Northing_end = "";
        this.Item_ref = "";
        this.Feature_ref = "";
        this.Contract_ref = "";
        this.Fault_code = "";
        this.Exact_location = "";
        this.Incident_notes = "";
        this.Action_type = "";
        this.Action_ref = "";
        this.Default_algorithm = "";
        this.Algorithm_description = "";
        this.Points = "";
        this.Value = "";
        this.Rectify_date = "";
        this.Rect_action_type = "";
        this.Rect_action_user = "";
        this.Rect_cont_type = "";
        this.Rect_cont_user = "";
        this.Rect_cont_date = "";
        this.Rect_cont_comp = "";
        this.Wo_suffix = "";
        this.Wo_type = "";
        this.Wo_status = "";
        this.Wo_date_due = "";
        this.Wo_date_compl = "";
        this.Allocation_ref = "";
        this.Pay_method = "";
        this.Pay_amount = "";
        this.Pay_auth_code = "";
        this.Pay_date = "";
        this.Pay_budget_ref = "";
        this.Pay_recharge_ref = "";
        this.Pay_status = "";
        this.Pay_ref = "";
        this.Card_id = "";
        this.Card_issue = "";
        this.Card_expiry_month = "";
        this.Card_expiry_year = "";
        this.Card_valid_from_month = "";
        this.Card_valid_from_year = "";
        this.Card_holder = "";
        this.Card_type = "";
        this.Card_security_code = "";
        this.Printer_name = "";
        this.Case_closed = "";
        this.Vehicle_make = "";
        this.Vehicle_model = "";
        this.Vehicle_colour = "";
        this.Vehicle_class = "";
        this.Vehicle_condition = "";
        this.Vehicle_registration = "";
        this.Vin = "";
        this.Officer_id = "";
        this.Observed_number = "";
        this.Observed_units = "";
        this.Observed_since = "";
        this.Road_fund_flag = "";
        this.Road_fund_valid = "";
        this.How_long_there = "";
        this.Date_stickered = "";
        this.Time_stickered_h = "";
        this.Time_stickered_m = "";
        this.Av_status = "";
        this.Av_status_desc = "";
        this.Av_status_date = "";
        this.Agreement_no = "";
        this.Trade_details = "";
        this.Tree_ref = "";
        this.Due_date = "";
        this.Request_type = "";
        this.Request_quantity = "";
        this.Schedule_ref = "";
        this.Reserve_date = "";
        this.Force_flag = "";
        this.Customer_ext_id = "";
        this.Customer_no = "";
        this.Customer_business_name = "";
        this.Customer_title = "";
        this.Customer_first_name = "";
        this.Customer_last_name = "";
        this.CustomerUPRN = "";
        this.CustomerUSRN = "";
        this.Customer_address1 = "";
        this.Customer_address2 = "";
        this.Customer_address3 = "";
        this.Customer_address4 = "";
        this.Customer_address5 = "";
        this.Customer_postcode = "";
        this.Customer_homephone = "";
        this.Customer_workphone = "";
        this.Customer_mobilephone = "";
        this.Customer_fax = "";
        this.Customer_email = "";
        this.Account_ref = "";
        this.TradeTasksAgreeTaskNo=null;
        this.TradeTasksCollectionDay=null;
        this.TradeTasksCompCode=null;
        this.WoTasksUprn=null;
        this.WoTasksTask_ref=null;
        this.WoTasksQuantity=null;
        this.WoTasksUnitCost=null;
        this.WoTasksDateDue=null;
        this.UprnCode="";
        this.Item_combo="";
        this.Attachments = new ArrayList();
        this.WebType="";
    }
}
