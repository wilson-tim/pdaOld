<%@ page import="com.vsb.incidentBean" %>
<%@ page import="com.vsb.locationSearchBean" %>
<%@ page import="com.vsb.savedPublicDescriptionBean" %>
<%@ page import="com.vsb.surveyBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />
<jsp:useBean id="locationSearchBean" scope="session" class="com.vsb.locationSearchBean" />
<jsp:useBean id="savedPublicDescriptionBean" scope="session" class="com.vsb.savedPublicDescriptionBean" />
<jsp:useBean id="surveyBean" scope="session" class="com.vsb.surveyBean" />

<c:set var="previousForm" scope="session" value="getService" />

<sess:isNew value="true">
    <c:set var="backingup" scope="session" value="false" />
    <c:set var="service_c" value="" scope="session"/>
    <c:set var="requiredPage" scope="session" value="getService" />
    <% 
        savedPublicDescriptionBean.clear(); 
        surveyBean.clear();
    %>
    <jsp:include page="getPageLayout.jsp" />
    <req:existsParameter name="webtype" value="true">
        <% incidentBean.setWebType((String)request.getParameter("webtype")); %>
    </req:existsParameter>
    <req:existsParameter name="input" value="true">
        <jsp:forward page="getServiceScript.jsp" />
    </req:existsParameter>
    <req:existsParameter name="input" value="false">
        <jsp:forward page="publicAccessScript.jsp" />
    </req:existsParameter>
</sess:isNew> 

<%-- check for input paramiter, it it's missing then act as a new form --%>
<req:existsParameter name="input" value="false">
    <c:set var="backingup" scope="session" value="false" />
    <c:set var="service_c" value="" scope="session"/>
    <c:set var="requiredPage" scope="session" value="getService" />
    <% 
        savedPublicDescriptionBean.clear(); 
        surveyBean.clear();
    %>
    <jsp:include page="getPageLayout.jsp" />
    <req:existsParameter name="webtype" value="true">
        <% incidentBean.setWebType((String)request.getParameter("webtype")); %>
    </req:existsParameter>
    <jsp:forward page="publicAccessScript.jsp" />
</req:existsParameter>

<%-- check for input paramiter to store user input --%>
<req:existsParameter name="input" value="true">
    <if:IfParameterEquals name="action" value="JumpTo" >
        <c:set var="requiredPage" scope="session"><req:parameter name="page" /></c:set>
        <c:redirect url="${requiredPage}Script.jsp" />
    </if:IfParameterEquals>
    <if:IfParameterEquals name="action" value="Back" >
        <c:set var="backingup" scope="session" value="true" />
        <c:set var="requiredPage" scope="session"><x:out select="$WAWorkFlow//services/element[service_code=$service_c]/paths/element[component_page=$requiredPage]/preceding-sibling::*/component_page" /></c:set>
        <c:redirect url="${requiredPage}Script.jsp" />
    </if:IfParameterEquals>
    <if:IfParameterNotEquals name="action" value="Stay" >
        <c:set var="errorMessage" scope="session" value="" />
    </if:IfParameterNotEquals>
    
    <if:IfParameterEquals name="action" value="Next" >
        <jsp:setProperty name="incidentBean" property="*" />
        <req:existsParameter name="webtype" value="true">
            <% incidentBean.setWebType((String)request.getParameter("webtype")); %>
        </req:existsParameter>

        <if:IfParameterEquals name="input" value="getService" >
            <% savedPublicDescriptionBean.clear(); %>
            <c:set var="service_c" scope="session"><%= incidentBean.getIncident_service() %></c:set>
            <if:IfTrue cond='<%= ((String)session.getAttribute("service_c")).trim().equals("") %>' >
                <c:set var="errorMessage" scope="session" value="You must select a service" />
            </if:IfTrue>
            <if:IfTrue cond='<%= !((String)session.getAttribute("service_c")).trim().equals("") %>' >
                <c:set var="desc"><x:out select="$serviceList//services/element[service_code=$service_c]/public_description" /></c:set>
                <% savedPublicDescriptionBean.setPage("getService",(String)pageContext.getAttribute("desc")); %>
            </if:IfTrue>
        </if:IfParameterEquals>

        <if:IfParameterEquals name="input" value="getCustomerName" >
            <%
            String s=(incidentBean.getCustomer_title().trim() + " " +
                incidentBean.getCustomer_first_name().trim() + " " +
                incidentBean.getCustomer_last_name().trim()).trim();
            if(s.equals("")) s="No name given";
            savedPublicDescriptionBean.setPage("getCustomerName",s); %>
        </if:IfParameterEquals>

        <if:IfParameterEquals name="input" value="getAddressInfo" >
            <jsp:setProperty name="locationSearchBean" property="houseno" value=""/>
            <jsp:setProperty name="locationSearchBean" property="*" />
            <if:IfTrue cond='<%= locationSearchBean.getPostcode().trim().equals("") && locationSearchBean.getStreetname().trim().equals("") %>' >
                <c:set var="errorMessage" scope="session" value="You must provide a least a postcode or street name" />
            </if:IfTrue>
        </if:IfParameterEquals>
        
        <if:IfParameterEquals name="input" value="getAddress" >
            <req:existsParameter name="uprnCode" value="false">
                <c:set var="errorMessage" scope="session" value="Please select an address" />
            </req:existsParameter>
            <req:existsParameter name="uprnCode" value="true">
                <% savedPublicDescriptionBean.setPage("getAddressInfo",incidentBean.site_address); %>
            </req:existsParameter>
        </if:IfParameterEquals>

        <if:IfParameterEquals name="input" value="getSiteItems" >
            <req:existsParameter name="item_combo" value="false">
                <c:set var="errorMessage" scope="session" value="Please select an element" />
            </req:existsParameter>
            <req:existsParameter name="item_combo" value="true">
                <c:set var="item_ref"><%=incidentBean.getItem_ref() %></c:set>
                <c:set var="desc"><x:out select="$SiteItems//items/element[item_ref=$item_ref]/public_desc" /></c:set>
                <% savedPublicDescriptionBean.setPage("getSiteItems",(String)pageContext.getAttribute("desc")); %>
            </req:existsParameter>
        </if:IfParameterEquals>

        <if:IfParameterEquals name="input" value="getCompCode" >
            <req:existsParameter name="fault_code" value="false">
                <c:set var="errorMessage" scope="session" value="Please select a fault code" />
            </req:existsParameter>
            <req:existsParameter name="fault_code" value="true">
                <c:set var="fault_code"><req:parameter name="fault_code" /></c:set>
                <c:set var="desc"><x:out select="$ItemCompCode//codes/element[comp_code=$fault_code]/comp_code_desc" /></c:set>
                <% savedPublicDescriptionBean.setPage("getCompCode",(String)pageContext.getAttribute("desc")); %>
                <c:set var="action_type"><x:out select="$ItemCompCode//codes/element[comp_code=$fault_code]/action_flag" /></c:set>
                <% incidentBean.setAction_type((String)pageContext.getAttribute("action_type")); %>
            </req:existsParameter>
        </if:IfParameterEquals>

        <if:IfParameterEquals name="input" value="getCustomerPhone" >
        <%
          String s;
          if((incidentBean.getCustomer_homephone().trim()+
              incidentBean.getCustomer_workphone().trim()+
              incidentBean.getCustomer_mobilephone().trim()+
              incidentBean.getCustomer_email().trim()+
              incidentBean.getCustomer_fax().trim()).equals("")){
            s="No contact details given.";
          }else{
            s="<table>";
            if(!incidentBean.getCustomer_homephone().equals(""))   s=s + "<tr><td>Home Phone</td><td>" + incidentBean.getCustomer_homephone() + "</td></tr>";
            if(!incidentBean.getCustomer_workphone().equals(""))   s=s + "<tr><td>Work Phone</td><td>" + incidentBean.getCustomer_workphone() + "</td></tr>";
            if(!incidentBean.getCustomer_mobilephone().equals("")) s=s + "<tr><td>Mobile Phone</td><td>" + incidentBean.getCustomer_mobilephone() + "</td></tr>";
            if(!incidentBean.getCustomer_email().equals(""))       s=s + "<tr><td>Email</td><td>" + incidentBean.getCustomer_email() + "</td></tr>";
            if(!incidentBean.getCustomer_fax().equals(""))         s=s + "<tr><td>Fax Number</td><td>" + incidentBean.getCustomer_fax() + "</td></tr>";
            s=s+"</table>";
          }
          savedPublicDescriptionBean.setPage("getCustomerPhone",s);
        %>
        </if:IfParameterEquals>

        <if:IfParameterEquals name="input" value="getExactLocation" >
            <req:existsParameter name="exact_location" value="true">
                <% savedPublicDescriptionBean.setPage("getExactLocation",(String)request.getParameter("exact_location")); %>
            </req:existsParameter>
        </if:IfParameterEquals>

        <if:IfParameterEquals name="input" value="getIncidentNotes" >
            <req:existsParameter name="incident_notes" value="true">
                <% savedPublicDescriptionBean.setPage("getIncidentNotes",(String)request.getParameter("incident_notes")); %>
            </req:existsParameter>
        </if:IfParameterEquals>

        <if:IfParameterEquals name="input" value="getAvMake" >
            <req:existsParameter name="vehicle_make" value="true">
                <% savedPublicDescriptionBean.setPage("getAvMake",(String)request.getParameter("vehicle_make")); %>
            </req:existsParameter>
        </if:IfParameterEquals>

        <if:IfParameterEquals name="input" value="getAvModel" >
            <req:existsParameter name="vehicle_model" value="true">
                <% savedPublicDescriptionBean.setPage("getAvModel",(String)request.getParameter("vehicle_model")); %>
            </req:existsParameter>
        </if:IfParameterEquals>

        <if:IfParameterEquals name="input" value="getAvReg" >
            <% 
                String s="<table>";
                if(!incidentBean.getVehicle_registration().equals("")) s=s + "<tr><td>Vehicle Registration</td><td>" + incidentBean.getVehicle_registration() + "</td><tr>";
                if(!incidentBean.getVin().equals(""))                  s=s + "<tr><td>Vin Number</td><td>" + incidentBean.getVin() + "</td><tr>";
                if(!incidentBean.getVehicle_condition().equals(""))    s=s + "<tr><td>Vehicle Condition</td><td>" + incidentBean.getVehicle_condition() + "</td><tr>";
                if(!incidentBean.getVehicle_colour().equals(""))       s=s + "<tr><td>Vehicle Colour</td><td>" + incidentBean.getVehicle_colour() + "</td><tr>";
                if(!incidentBean.getRoad_fund_flag().equals(""))       s=s + "<tr><td>Road Fund Shown</td><td>" + incidentBean.getRoad_fund_flag() + "</td><tr>";
                if(!incidentBean.getRoad_fund_valid().equals(""))      s=s + "<tr><td>Road Fund Valid</td><td>" + incidentBean.getRoad_fund_valid() + "</td><tr>";
                if(!incidentBean.getHow_long_there().equals(""))       s=s + "<tr><td>How long there</td><td>" + incidentBean.getHow_long_there() + "</td><tr>";
                s=s+"</table>";
                savedPublicDescriptionBean.setPage("getAvReg",s); 
            %>
        </if:IfParameterEquals>

        <if:IfParameterEquals name="input" value="takeSurvey" >
            <% 
                surveyBean.clear();
                int numberofquestions=Integer.parseInt((String)request.getParameter("numberofquestions"));
                for(int i=1;i<=numberofquestions;++i){
                    String question=(String)request.getParameter("Q" + Integer.toString(i));
                    String answer=(String)request.getParameter("A" + Integer.toString(i));
                    surveyBean.add(question,answer);
                }
                savedPublicDescriptionBean.setPage("takeSurvey","Survey"); 
            %>
        </if:IfParameterEquals>

        <c:set var="backingup" scope="session" value="false" />
        <if:IfTrue cond='<%= ((String)session.getAttribute("errorMessage")).trim().equals("") %>' >
            <c:set var="requiredPage" scope="session"><x:out select="$WAWorkFlow//services/element[service_code=$service_c]/paths/element[component_page=$requiredPage]/following-sibling::*/component_page" /></c:set>
            <c:redirect url="${requiredPage}Script.jsp" />
        </if:IfTrue>
        <if:IfTrue cond='<%= !((String)session.getAttribute("errorMessage")).trim().equals("") %>' >
            <c:redirect url="${requiredPage}Script.jsp" />
        </if:IfTrue>
    </if:IfParameterEquals>
    <if:IfParameterEquals name="action" value="Stay" >
        <c:redirect url="${requiredPage}Script.jsp" />
    </if:IfParameterEquals>
</req:existsParameter>
