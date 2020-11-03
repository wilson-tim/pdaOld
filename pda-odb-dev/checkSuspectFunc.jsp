<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.recordBean, com.db.DbUtils" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql"  %>

<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- 13/12/2010  TW  Markets module - check whether suspect record exists --%>

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="checkSuspectFunc" value="false">
  checkSuspectFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="checkSuspectFunc">
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <sql:query>
      select enf_company.company_ref, enf_company.company_name
      from enf_company, enf_suspect
      where enf_suspect.company_ref = enf_company.company_ref
      and enf_company.company_name = '<%= recordBean.getSus_company() %>'
      and enf_suspect.external_ref = '<%= recordBean.getTrader_ref() %>'
      and (enf_suspect.external_ref_type = 'T' or enf_suspect.external_ref_type = 'A')
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="suspect_ref" />
      <sql:getColumn position="2" to="enfcompany" />
    </sql:resultSet>
    <sql:wasNotEmpty>
      <% recordBean.setSuspect_ref(((String)pageContext.getAttribute("suspect_ref")).trim()); %>
      <% recordBean.setEnfcompany(((String)pageContext.getAttribute("enfcompany")).trim()); %>
      <% recordBean.setUpdate_flag("noupdate"); %>
      <% recordBean.setNew_suspect_flag("N"); %>
    </sql:wasNotEmpty>
    <sql:wasEmpty>
      <% recordBean.setSuspect_ref(""); %>
      <% recordBean.setEnfcompany("new"); %>
      <% recordBean.setNew_suspect_flag("Y"); %>
      <% recordBean.setSus_newco(recordBean.getSus_company()); %>
    </sql:wasEmpty>
  </sql:statement>
  <sql:closeConnection conn="con1"/>
</sess:equalsAttribute>
