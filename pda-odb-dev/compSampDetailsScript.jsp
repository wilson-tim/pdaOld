<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.vsb.compSampDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="compSampDetailsBean" scope="session" class="com.vsb.compSampDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="compSampDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="compSampDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="compSampDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="compSampDetailsBean" property="*" />

    <%-- Setup recordBean --%>
    <% recordBean.setExact_location(compSampDetailsBean.getExact_location()); %>
    
    <%-- See if this is a Fly Capture record --%>
    <% int complaint_no = Integer.parseInt(recordBean.getComplaint_no()); %>
    <% boolean isFlyCap = false; %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- Get the fault codes that are allowed to have defects applied to them --%>
      <sql:query>
        SELECT complaint_no
          FROM comp_flycap
         WHERE complaint_no = <%= complaint_no %>
      </sql:query>
      <sql:resultSet id="rset">
        <%-- do nothing --%>
      </sql:resultSet>
      <sql:wasNotEmpty>
        <% isFlyCap = true; %>
      </sql:wasNotEmpty>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- If the service is dart or graffiti, or the complaint is a flycapture then need to set the fault code variables. --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getGraffiti_service()) || recordBean.getService_c().equals(recordBean.getDart_service()) || isFlyCap == true %>' >
      <%-- set the fault_code to the comp_code already got. --%>
      <% recordBean.setFault_code(recordBean.getComp_code()); %>

      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select lookup_text, lookup_num
          from allk
          where lookup_func = 'DEFRN'
          and   lookup_code = '<%= recordBean.getFault_code() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="lookup_text" />
          <% recordBean.setFault_desc((String) pageContext.getAttribute("lookup_text")); %>
          <sql:getColumn position="2" to="lookup_num" />
          <% recordBean.setNotice_no((String) pageContext.getAttribute("lookup_num")); %>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </if:IfTrue>
   
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="compSampDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="inspList" >
  <jsp:setProperty name="compSampDetailsBean" property="action" value="" />
  <jsp:setProperty name="compSampDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="compSampDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
    <%-- get the compSampDetails remarks --%>
    <%-- The text wil be split into 70 char lines, and there should be a --%>
    <%-- single record for each line. So will need to concatenate them all together --%>
    <%-- Blank first to stop doubling up when going back to this page --%>
    <%-- The Remarks are stored in the database rather than the Bean for the Remarks so blanking --%>
    <%-- the compSampDetails remarks will be fine. --%>
    <% compSampDetailsBean.setRemarks(""); %>
    <sql:query>
      select details_1, details_2, details_3
      from comp
      where complaint_no = '<%= recordBean.getComplaint_no()%>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="text_line1" />
      <sql:wasNotNull>
        <% compSampDetailsBean.setRemarks(compSampDetailsBean.getRemarks() + pageContext.getAttribute("text_line1") + " "); %>
      </sql:wasNotNull>
      <sql:getColumn position="2" to="text_line2" />
      <sql:wasNotNull>
        <% compSampDetailsBean.setRemarks(compSampDetailsBean.getRemarks() + pageContext.getAttribute("text_line2") + " "); %>
      </sql:wasNotNull>
      <sql:getColumn position="3" to="text_line3" />
      <sql:wasNotNull>
        <% compSampDetailsBean.setRemarks(compSampDetailsBean.getRemarks() + pageContext.getAttribute("text_line3")); %>
      </sql:wasNotNull>
    </sql:resultSet>
    
    <%-- get rid of double space characters --%>
    <%
      String tempTextOut = "";
      String lastChar = "";
      String nextChar = "";
      int textLength = compSampDetailsBean.getRemarks().length();
      if (textLength > 0) {
        int i=0;
        int j=1;
        do {
          nextChar = compSampDetailsBean.getRemarks().substring(i,j);
          if (!(lastChar.equals(" ") && nextChar.equals(" "))) {
            tempTextOut = tempTextOut + nextChar;
          }
          lastChar = nextChar;
          i++;
          j++;
        } while (i < textLength);
        compSampDetailsBean.setRemarks(tempTextOut);
      }
    %>
  </sql:statement>
  <sql:closeConnection conn="con"/>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="compSampDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>


<%-- Clear the textOut field --%>
<% compSampDetailsBean.setTextOut(""); %>

<%-- Retrieve the record values used in the view --%>
<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <%-- get the compSampDetails text --%>
  <%-- The text wil be split into 60 char lines, and there should be a --%>
  <%-- single record for each line. So will need to concatenate them all together --%>
  <sql:query>
    select txt, seq
    from comp_text
    where complaint_no = '<%= recordBean.getComplaint_no()%>'
    order by seq asc
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="text_line" />
    <sql:wasNotNull>
      <% compSampDetailsBean.setTextOut(compSampDetailsBean.getTextOut() + pageContext.getAttribute("text_line") + "&#013;"); %>
    </sql:wasNotNull>
  </sql:resultSet>
  
  <%-- get rid of double space characters --%>
  <%
    String tempTextOut = "";
    String lastChar = "";
    String nextChar = "";
    int textLength = compSampDetailsBean.getTextOut().length();
    if (textLength > 0) {
      int i=0;
      int j=1;
      do {
        nextChar = compSampDetailsBean.getTextOut().substring(i,j);
        if (!(lastChar.equals(" ") && nextChar.equals(" "))) {
          tempTextOut = tempTextOut + nextChar;
        }
        lastChar = nextChar;
        i++;
        j++;
      } while (i < textLength);
      compSampDetailsBean.setTextOut(tempTextOut);
    }
  %>

  <sql:query>
    select x_value, y_value, linear_value, area_value, priority
    from comp_measurement
    where complaint_no = '<%= recordBean.getComplaint_no()%>'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="x_value" />
    <sql:wasNotNull>
      <% recordBean.setDefect_view_x((String)pageContext.getAttribute("x_value")); %>
    </sql:wasNotNull>

    <sql:getColumn position="2" to="y_value" />
    <sql:wasNotNull>
      <% recordBean.setDefect_view_y((String)pageContext.getAttribute("y_value")); %>
    </sql:wasNotNull>

    <sql:getColumn position="3" to="linear_value" />
    <sql:wasNotNull>
      <% recordBean.setDefect_view_linear((String)pageContext.getAttribute("linear_value")); %>
    </sql:wasNotNull>

    <sql:getColumn position="4" to="area_value" />
    <sql:wasNotNull>
      <% recordBean.setDefect_view_area((String)pageContext.getAttribute("area_value")); %>
    </sql:wasNotNull>

    <sql:getColumn position="5" to="priority" />
    <sql:wasNotNull>
      <% recordBean.setDefect_view_priority((String)pageContext.getAttribute("priority")); %>
    </sql:wasNotNull>
  </sql:resultSet>

</sql:statement>
<sql:closeConnection conn="con"/>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <%-- get rid of newline and carriage return chars --%>
  <%
    String tempTextIn = compSampDetailsBean.getText();
    tempTextIn = tempTextIn.replace('\n',' ');
    tempTextIn = tempTextIn.replace('\r',' ');
    
    compSampDetailsBean.setText(tempTextIn);
  %>
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Update Text") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= compSampDetailsBean.getText().equals("") %>' >
      <jsp:setProperty name="compSampDetailsBean" property="error"
        value="Please supply additional text." />
      <jsp:forward page="compSampDetailsView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Indicate that we are updateing the text only. --%>
    <% recordBean.setUpdate_text("Y"); %>

    <%-- update position and remarks text --%>
    <sess:setAttribute name="form">updatePositionRemarksFunc</sess:setAttribute>
    <c:import url="updatePositionRemarksFunc.jsp" var="webPage" />
    <% helperBean.throwException("updatePositionRemarksFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- add complaint text --%>
    <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
    <c:import url="addTextFunc.jsp" var="webPage" />
    <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>
  
  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Action") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
   
    <%-- See if this is a Fly Capture record --%>
    <% int complaint_no = Integer.parseInt(recordBean.getComplaint_no()); %>
    <% boolean isFlyCap = false; %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- Get the fault codes that are allowed to have defects applied to them --%>
      <sql:query>
        SELECT complaint_no
          FROM comp_flycap
         WHERE complaint_no = <%= complaint_no %>
      </sql:query>
      <sql:resultSet id="rset">
        <%-- do nothing --%>
      </sql:resultSet>
      <sql:wasNotEmpty>
        <% isFlyCap = true; %>
      </sql:wasNotEmpty>
    </sql:statement>
    <sql:closeConnection conn="con"/>
 
    <%-- update position and remarks text --%>
    <sess:setAttribute name="form">updatePositionRemarksFunc</sess:setAttribute>
    <c:import url="updatePositionRemarksFunc.jsp" var="webPage" />
    <% helperBean.throwException("updatePositionRemarksFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Valid entry --%>
    <%-- graffiti service takes this route. --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getGraffiti_service()) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">graffDetails</sess:setAttribute>
      <c:redirect url="graffDetailsScript.jsp" />
    </if:IfTrue>

    <%-- dart service takes this route. --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getDart_service()) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">dartDetails</sess:setAttribute>
      <c:redirect url="dartDetailsScript.jsp" />
    </if:IfTrue>

    <%-- av service takes this route. --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getAv_service()) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">avDetails</sess:setAttribute>
      <c:redirect url="avDetailsScript.jsp" />
    </if:IfTrue>

    <%-- fly capture takes this route. --%>
    <if:IfTrue cond='<%= isFlyCap == true %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">flyCapUpdate</sess:setAttribute>
      <c:redirect url="flyCapUpdateScript.jsp" />
    </if:IfTrue>

    <%-- Hway service Defect takes this route. --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getHway_service()) %>' >
      <%-- set the fault_code to the comp_code already got. --%>
      <% recordBean.setFault_code(recordBean.getComp_code()); %>

      <% String defect_fault_codes_string = ""; %>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <%-- Get the fault codes that are allowed to have defects applied to them --%>
        <sql:query>
          SELECT c_field
            FROM keys
           WHERE keyname = 'MS_FAULT_CODES'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="c_field" />
          <sql:wasNotNull>
            <% defect_fault_codes_string = ((String)pageContext.getAttribute("c_field")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con"/>

      <%-- Create an arraylist of individual fault codes from the comma separated list --%>
      <% ArrayList defect_fault_codes = helperBean.splitCommaList( defect_fault_codes_string ); %>
      <if:IfTrue cond='<%= defect_fault_codes.contains( recordBean.getFault_code() ) %>'>
        <%-- This is a HWAY and a defect, so the standard 'Action' is Defect Update --%>
        <%-- The fault code is in the list of defect fault codes --%>
        <% recordBean.setDefect_flag("A"); %>
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">defectSize</sess:setAttribute>
        <c:redirect url="defectSizeScript.jsp" />
      </if:IfTrue>

      <%-- This is a HWAY but not a defect, so the standard 'Action' is Works Order --%>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">contract</sess:setAttribute>
      <c:redirect url="contractScript.jsp" />
    </if:IfTrue>

    <%-- All other services take this route. I.e. the standard 'Action' is Default. --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">pickFault1</sess:setAttribute>
    <c:redirect url="pickFault1Script.jsp" />
  </if:IfTrue>
  
  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Add Works Order") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- update position and remarks text --%>
    <sess:setAttribute name="form">updatePositionRemarksFunc</sess:setAttribute>
    <c:import url="updatePositionRemarksFunc.jsp" var="webPage" />
    <% helperBean.throwException("updatePositionRemarksFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">contract</sess:setAttribute>
    <c:redirect url="contractScript.jsp" />
  </if:IfTrue>
  
  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("No Further Action") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- update position and remarks text --%>
    <sess:setAttribute name="form">updatePositionRemarksFunc</sess:setAttribute>
    <c:import url="updatePositionRemarksFunc.jsp" var="webPage" />
    <% helperBean.throwException("updatePositionRemarksFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- do the no further action --%>
    <sess:setAttribute name="form">noFurtherActFunc</sess:setAttribute>
    <c:import url="noFurtherActFunc.jsp" var="webPage" />
    <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

    <%-- add complaint text --%>
    <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
    <c:import url="addTextFunc.jsp" var="webPage" />
    <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>
  
  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Not Checked") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- update position and remarks text --%>
    <sess:setAttribute name="form">updatePositionRemarksFunc</sess:setAttribute>
    <c:import url="updatePositionRemarksFunc.jsp" var="webPage" />
    <% helperBean.throwException("updatePositionRemarksFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">pickFault2</sess:setAttribute>
    <c:redirect url="pickFault2Script.jsp" />
  </if:IfTrue>
  
  <%-- Next view 6 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Place on Hold") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- update position and remarks text --%>
    <sess:setAttribute name="form">updatePositionRemarksFunc</sess:setAttribute>
    <c:import url="updatePositionRemarksFunc.jsp" var="webPage" />
    <% helperBean.throwException("updatePositionRemarksFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- do the place on hold action --%>
    <sess:setAttribute name="form">placeOnHoldFunc</sess:setAttribute>
    <c:import url="placeOnHoldFunc.jsp" var="webPage" />
    <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

    <%-- add complaint text --%>
    <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
    <c:import url="addTextFunc.jsp" var="webPage" />
    <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>
  
  <%-- Next view 7 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Customer") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%> 
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">custDetails</sess:setAttribute>
    <c:redirect url="custDetailsScript.jsp" />
  </if:IfTrue>

  <%-- Next view 8 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Map") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">map</sess:setAttribute>
    <c:redirect url="mapScript.jsp" />
  </if:IfTrue>

  <%-- Next view 9 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Trade Details") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">tradeDetails</sess:setAttribute>
    <c:redirect url="tradeDetailsScript.jsp" />
  </if:IfTrue>

  <%-- Next view 10 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Tree") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">compTreeDetails</sess:setAttribute>
    <c:redirect url="compTreeDetailsScript.jsp" />
  </if:IfTrue> 
  
  <%-- Next view 11 --%>
  <%-- 11/05/2010  TW  Allow for conditional text --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Change Item/Fault") || compSampDetailsBean.getAction().equals("Change Item/Fault/Insp. Date") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- update position and remarks text --%>
    <sess:setAttribute name="form">updatePositionRemarksFunc</sess:setAttribute>
    <c:import url="updatePositionRemarksFunc.jsp" var="webPage" />
    <% helperBean.throwException("updatePositionRemarksFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">changeItemLookup</sess:setAttribute>
    <c:redirect url="changeItemLookupScript.jsp" />
  </if:IfTrue> 
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">compSampDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= compSampDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${compSampDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="compSampDetailsView.jsp" />
