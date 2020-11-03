<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.helperBean, com.dbb.SNoBean, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.vsb.recordBean, com.vsb.defectSizeBean, com.vsb.defectDetailsBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="defectSizeBean"     scope="session" class="com.vsb.defectSizeBean" />
<jsp:useBean id="defectDetailsBean"  scope="session" class="com.vsb.defectDetailsBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="updateDefectFunc" value="false">
  updateDefectFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="updateDefectFunc">

  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">

    <%-- Find out if a comp_measurement record already exists --%>
    <% String record_exists = "N"; %>
    <sql:query>
      select complaint_no
      from comp_measurement
      where complaint_no = <%= recordBean.getComplaint_no() %>
    </sql:query>
    <sql:resultSet id="rset">
      <% record_exists = "Y"; %>
    </sql:resultSet>
    <sql:wasEmpty>
      <% record_exists = "N"; %>
    </sql:wasEmpty>

    <if:IfTrue cond='<%= record_exists.equals("Y") %>' >
      <sql:query>
        update comp_measurement
        set x_value = <%= defectSizeBean.getX() %>,
            y_value = <%= defectSizeBean.getY() %>,
            linear_value = <%= defectDetailsBean.getLinear() %>,
            area_value = <%= defectDetailsBean.getArea() %>,
            priority = '<%= defectDetailsBean.getPriority() %>'
        where complaint_no = <%= recordBean.getComplaint_no() %> 
      </sql:query>
      <sql:execute />
    </if:IfTrue>
    <if:IfTrue cond='<%= ! record_exists.equals("Y") %>' >
      <sql:query>
        insert into comp_measurement(
          complaint_no,
          x_value,
          y_value,
          z_value,
          linear_value,
          area_value,
          priority
        ) values (
          <%= recordBean.getComplaint_no() %>,
          <%= defectSizeBean.getX() %>,
          <%= defectSizeBean.getY() %>,
          0,
          <%= defectDetailsBean.getLinear() %>,
          <%= defectDetailsBean.getArea() %>,
          '<%= defectDetailsBean.getPriority() %>'
        )
      </sql:query>
      <sql:execute />
    
    </if:IfTrue>

    <%-- update the active occurance of the complaint in the inspection --%>
    <%-- list table, to processed ('P'). --%>
    <sql:query>
      update insp_list set state = 'P'
      where complaint_no = '<%= recordBean.getComplaint_no() %>'
      and   state = 'A'
    </sql:query>
    <sql:execute/>

  </sql:statement>
  <sql:closeConnection conn="con1"/>    

  <%
    //ensure that the printing error status is set to "ok" as no printing occured above.
    recordBean.setPrinting_error("ok");
  %>
</sess:equalsAttribute>
