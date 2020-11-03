<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.loginBean, com.vsb.recordBean, com.vsb.helperBean, com.vsb.systemKeysBean" %>
<%@ page import="org.apache.axis.encoding.Base64, java.util.*" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="login" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="loginBean" property="all" value="clear" />
    <jsp:setProperty name="loginBean" property="*" />

    <%-- Clear the previous record --%>
    <jsp:setProperty name="recordBean" property="all" value="clear" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="loginBean" property="error" value="" />

<%-- clear form fields if coming from any previous form --%>
<%-- but as this is the first, form don't update savedPreviousForm as there isn't one. --%>
<sess:equalsAttribute name="input" match="login" value="false" >
  <jsp:setProperty name="loginBean" property="action" value="" />
  <jsp:setProperty name="loginBean" property="all" value="clear" />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- If ISA server authentication is being used then gte the --%>
<%-- user name and redirect to the next page --%>
<app:equalsInitParameter name="isa_authorization" match="Y" >
  <%-- make sure the appropriate HTTP header element is there before --%>
  <%-- processing the isa_authorization --%>
  <req:existsHeader name="authorization">
    <%
      // The header will be of the form
      // Basic username:password 
      // where the username:password part is base64 encoded
      String headerAuth = request.getHeader("authorization");

      // get the base64 part from the header from the header string
      // which should be in the form of:
      // Basic username:password 
      StringTokenizer tokenAuth = new StringTokenizer(headerAuth);
      String stringAuth = "";
      if (tokenAuth.countTokens() >= 2) {
        tokenAuth.nextToken();
        stringAuth = tokenAuth.nextToken();
      }
     
      // convert the base64 string into a byte array
      byte[] byteAuth = Base64.decode(stringAuth);

      // convert the byte array into a normal string
      String decodeAuth = new String(byteAuth);
      
      // the decoded string will be in the form of:
      // username:password
      // so get the username only
      StringTokenizer tokenString = new StringTokenizer(decodeAuth, ":");
      String username = "";
      if (tokenString.countTokens() >= 1) {
        username = tokenString.nextToken();
      }
      
      // 08/09/2010  TW  Revision for Camden to strip off domain information from username
      int index = username.lastIndexOf("\\");
      if(index >= 0) {
        username = username.substring(index + 1);
      }
      
      // put the username into the loginBean
      loginBean.setUser_name(username.toLowerCase());
    %>
    
    <%-- The user has been prevalidated by the ISA server, we just need to --%>
    <%-- see if the user exists in the database --%>
    <% boolean loginError = false; %>
    <% boolean absent = false; %>

    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- The module is inspectors --%>
      <app:equalsInitParameter name="module" match="pda-in" >
        <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'PDA_INSPECTOR_ROLE'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="pda_role" />
          <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
        </sql:resultSet>
      </app:equalsInitParameter>

      <%-- The module is town warden --%>
      <app:equalsInitParameter name="module" match="pda-tw" >
        <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'PDA_WARDEN_ROLE'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="pda_role" />
          <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
        </sql:resultSet>
      </app:equalsInitParameter>

      <%-- Find out what version of contender is being run against the database --%>
      <%-- 10/05/2010  TW  Next String declaration not used --%>
      <%--                 Additional code, to match Next View section below --%>
      <%-- String contender_version = "v7"; --%>
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'CONTENDER_VERSION'
      </sql:query>
      <sql:resultSet id="rset1">
        <sql:getColumn position="1" to="c_field" />
        <sql:wasNotNull>
          <% systemKeysBean.setContender_version( ((String) pageContext.getAttribute("c_field")).trim().toLowerCase() ); %>
          <% recordBean.setContender_version( systemKeysBean.getContender_version() ); %>
        </sql:wasNotNull>
        <sql:wasNull>
          <% systemKeysBean.setContender_version("v7"); %>
          <% recordBean.setContender_version("v7"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% systemKeysBean.setContender_version("v7"); %>
        <% recordBean.setContender_version("v7"); %>
      </sql:wasEmpty>

      <%-- 10/05/2010  TW  Additional code, to match Next View section below --%>
      <%-- Get the GENERATE_SUPERSITES system key --%>
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'GENERATE_SUPERSITES'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
        <sql:wasNotNull>
          <% systemKeysBean.setGenerate_supersites((String) pageContext.getAttribute("c_field")); %>
        </sql:wasNotNull>
        <sql:wasNull>
          <% systemKeysBean.setGenerate_supersites("Y"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% systemKeysBean.setGenerate_supersites("Y"); %>
      </sql:wasEmpty>

      <%-- 05/07/2010  TW  New system key --%>
      <sql:query>
        select n_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'ENF_DEFAULT_SUSPECT'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="n_field" />
        <sql:wasNotNull>
          <% systemKeysBean.setDefault_suspect_ref((String) pageContext.getAttribute("n_field")); %>
        </sql:wasNotNull>
        <sql:wasNull>
          <% systemKeysBean.setDefault_suspect_ref(""); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% systemKeysBean.setDefault_suspect_ref(""); %>
      </sql:wasEmpty>

      <%-- Only active users who are allowed to use the module can login --%>
      <sql:query>
        select user_name
        from pda_user_role
        where user_name = '<%= loginBean.getUser_name().toLowerCase() %>'
        and   role_name = '<%= recordBean.getPda_role() %>'
      </sql:query>
      <sql:resultSet id="rset">
      </sql:resultSet>
      <sql:wasEmpty>
        <% loginError = true; %>
      </sql:wasEmpty>
      <sql:wasNotEmpty>
        <% loginError = false; %>
      </sql:wasNotEmpty>
      
      <%-- Check to see if the user is absent --%>
      <sql:query>
        select user_name
        from pda_cover_list
        where user_name = '<%= loginBean.getUser_name().toLowerCase() %>'
        and   absent = 'Y'
      </sql:query>
      <sql:resultSet id="rset">
      </sql:resultSet>
      <sql:wasEmpty>
        <% absent = false; %>
      </sql:wasEmpty>
      <sql:wasNotEmpty>
        <% absent = true; %>
      </sql:wasNotEmpty>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= loginError %>' >
      <jsp:setProperty name="loginBean" property="error"
        value="The username you entered is invalid. Please try again.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="loginView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= absent %>' >
      <jsp:setProperty name="loginBean" property="error"
        value="The username you entered is flagged as absent. Please try again.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="loginView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- The module is town warden --%>
    <app:equalsInitParameter name="module" match="pda-tw" >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">login</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
      <c:redirect url="schedOrCompScript.jsp" />
    </app:equalsInitParameter>

    <%-- The module is inspectors --%>
    <app:equalsInitParameter name="module" match="pda-in" >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">login</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">mainMenu</sess:setAttribute>
      <c:redirect url="mainMenuScript.jsp" />
    </app:equalsInitParameter>
    
  </req:existsHeader>
</app:equalsInitParameter>


<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="login" >
  <% boolean loginError = false; %>
  <% boolean absent = false; %>

  <%-- Next view --%>
  <if:IfTrue cond='<%= loginBean.getAction().equals("Login") %>' >
    <%-- Check user and password against database --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- The module is inspectors --%>
      <app:equalsInitParameter name="module" match="pda-in" >
        <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'PDA_INSPECTOR_ROLE'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="pda_role" />
          <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
        </sql:resultSet>
      </app:equalsInitParameter>

      <%-- The module is town warden --%>
      <app:equalsInitParameter name="module" match="pda-tw" >
        <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'PDA_WARDEN_ROLE'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="pda_role" />
          <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
        </sql:resultSet>
      </app:equalsInitParameter>

      <%-- Only active users who are allowed to use the module, and have --%>
      <%-- given the correct password can login. --%>
      <sql:query>
        select user_name, user_pass
        from pda_user
        where user_name = '<%= loginBean.getUser_name().toLowerCase() %>'
        and   user_pass = '<%= helperBean.getPasswordMD5(loginBean.getUser_pass().toLowerCase()).toUpperCase() %>'
        and   user_name IN (
          select user_name
          from pda_user_role
          where user_name = '<%= loginBean.getUser_name().toLowerCase() %>'
          and   role_name = '<%= recordBean.getPda_role() %>'
        )
      </sql:query>
      <sql:resultSet id="rset">
      </sql:resultSet>
      <sql:wasEmpty>
        <% loginError = true; %>
      </sql:wasEmpty>
      <sql:wasNotEmpty>
        <% loginError = false; %>
      </sql:wasNotEmpty>
      
      <%-- Check to see if the user is absent --%>
      <sql:query>
        select user_name
        from pda_cover_list
        where user_name = '<%= loginBean.getUser_name().toLowerCase() %>'
        and   absent = 'Y'
      </sql:query>
      <sql:resultSet id="rset">
      </sql:resultSet>
      <sql:wasEmpty>
        <% absent = false; %>
      </sql:wasEmpty>
      <sql:wasNotEmpty>
        <% absent = true; %>
      </sql:wasNotEmpty>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= loginError %>' >
      <jsp:setProperty name="loginBean" property="error"
        value="You have entered an invalid username/password. Please try again.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="loginView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= absent %>' >
      <jsp:setProperty name="loginBean" property="error"
        value="The username you entered is flagged as absent. Please try again.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="loginView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- Get the CONTENDER_VERSION system key --%>
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'CONTENDER_VERSION'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
        <sql:wasNotNull>
          <% systemKeysBean.setContender_version(((String) pageContext.getAttribute("c_field")).toLowerCase()); %>
          <% recordBean.setContender_version( systemKeysBean.getContender_version() ); %>
      </sql:wasNotNull>
        <sql:wasNull>
          <% systemKeysBean.setContender_version("v7"); %>
          <% recordBean.setContender_version("v7"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% systemKeysBean.setContender_version("v7"); %>
        <% recordBean.setContender_version("v7"); %>
      </sql:wasEmpty>
      
      <%-- Get the GENERATE_SUPERSITES system key --%>
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'GENERATE_SUPERSITES'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
        <sql:wasNotNull>
          <% systemKeysBean.setGenerate_supersites((String) pageContext.getAttribute("c_field")); %>
        </sql:wasNotNull>
        <sql:wasNull>
          <% systemKeysBean.setGenerate_supersites("Y"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% systemKeysBean.setGenerate_supersites("Y"); %>
      </sql:wasEmpty>

      <%-- 05/07/2010  TW  New system key --%>
      <sql:query>
        select n_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'ENF_DEFAULT_SUSPECT'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="n_field" />
        <sql:wasNotNull>
          <% String default_suspect = (String) pageContext.getAttribute("n_field"); %>
          <if:IfTrue cond='<%= default_suspect.startsWith("0.") %>' >
            <% systemKeysBean.setDefault_suspect_ref(""); %>
          </if:IfTrue>
          <if:IfTrue cond='<%= !default_suspect.startsWith("0.") %>' >
            <% systemKeysBean.setDefault_suspect_ref((String) pageContext.getAttribute("n_field")); %>
          </if:IfTrue>
        </sql:wasNotNull>
        <sql:wasNull>
          <% systemKeysBean.setDefault_suspect_ref(""); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% systemKeysBean.setDefault_suspect_ref(""); %>
      </sql:wasEmpty>

    </sql:statement>
    <sql:closeConnection conn="con"/>
   
    <%-- The module is town warden --%>
    <app:equalsInitParameter name="module" match="pda-tw" >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">login</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
      <c:redirect url="schedOrCompScript.jsp" />
    </app:equalsInitParameter>

    <%-- The module is inspectors --%>
    <app:equalsInitParameter name="module" match="pda-in" >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">login</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">mainMenu</sess:setAttribute>
      <c:redirect url="mainMenuScript.jsp" />
    </app:equalsInitParameter>
  </if:IfTrue>

  <%-- Previous view --%>
  <%-- NON --%>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="loginView.jsp" />