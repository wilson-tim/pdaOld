<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.helperBean, com.dbb.SNoBean, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="veoliaLinkFunc" value="false">
  veoliaLinkFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="veoliaLinkFunc">

  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- Initialise the variables --%>
    <% String ws_ext_integration = "N"; %>
    <% String pda_ext_integration = "N"; %>

    <%-- Get the violia integration flag --%>
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'WS_EXT_INTEGRATION'
    </sql:query>
    <sql:resultSet id="rset1">
      <sql:getColumn position="1" to="c_field" />
      <sql:wasNotNull>
        <% ws_ext_integration = ((String) pageContext.getAttribute("c_field")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>

    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'PDA_EXT_INTEGRATION'
    </sql:query>
    <sql:resultSet id="rset1">
      <sql:getColumn position="1" to="c_field" />
      <sql:wasNotNull>
        <% pda_ext_integration = ((String) pageContext.getAttribute("c_field")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>

    <%-- run the veolia link if required --%>
    <if:IfTrue cond='<%= ws_ext_integration.equals("Y") || pda_ext_integration.equals("Y") %>' >
      <%-- First we need to get the number for this survey --%>
      <% SNoBean sNoBean  = new SNoBean( "java:comp/env", "jdbc/pda", "comp_external" ); %>
      <% String serial_no = sNoBean.getSerial_noAsString();     %>

      <%-- adding a comp_external record --%>
      <sql:query>
        insert into comp_external (
          seq_no,
          complaint_no
        ) values (
          <%= serial_no %>,
          <%= recordBean.getComplaint_no() %>
        )
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  </sql:statement>
  <sql:closeConnection conn="con1"/>    

</sess:equalsAttribute>
