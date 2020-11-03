<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.treesListBean, com.vsb.recordBean" %>
<%@ page import="com.db.*, javax.sql.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql"  %>

<jsp:useBean id="treesListBean" scope="session" class="com.vsb.treesListBean" />
<jsp:useBean id="recordBean"    scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="treesListPageSet" scope="session" class="com.db.PageSet" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="treesList" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="treesList" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="treesListBean" property="all" value="clear" />
    <jsp:setProperty name="treesListBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="tree_ref" value='<%= treesListBean.getTree_ref() %>' />
  </if:IfParameterEquals>
</req:existsParameter>
    
<%-- clear errors --%>
<jsp:setProperty name="treesListBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="service" >
  <jsp:setProperty name="treesListBean" property="action" value="" />
  <jsp:setProperty name="treesListBean" property="all" value="clear" />
  <jsp:setProperty name="treesListBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="updateStatus" >
  <jsp:setProperty name="treesListBean" property="action" value="" />
  <jsp:setProperty name="treesListBean" property="all" value="clear" />
  <jsp:setProperty name="treesListBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- Set the page number to 1 the first time we are viewing the form --%>
<sess:equalsAttribute name="input" match="treesList" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("service") %>' >
    <jsp:setProperty name="treesListBean" property="page_number" value="1" />
  </if:IfTrue>
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("updateStatus") %>' >
    <jsp:setProperty name="treesListBean" property="page_number" value="1" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Populate the treesListPageSet for use in the VIEW, but only the first time through the SCRIPT --%>
<sess:equalsAttribute name="input" match="treesList" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- set the number of records per page --%>
    <% int recordsOnPage = new Integer(application.getInitParameter("records_on_trees_list")).intValue(); %>
    <% treesListPageSet.setRecordsOnPage( recordsOnPage ); %>

    <%-- Declare the query string variable --%>
    <% String queryString = ""; %>

    <%-- Declare the result set variable --%>
    <% java.sql.ResultSet rs = null; %>    
    
    <%-- Connect to the database using the context and datasource --%>
    <% DbSQL connection = new DbSQL(); %>
    <% connection.connect("java:comp/env", "jdbc/pda"); %>
    
    <%-- Build query --%>
    <%
      queryString = 
        "select tree_ref, " + 
               "tree_desc, " +
               "tr_no, " +
               "position, " +
               "position_ref, " +
               "species_ref, " +
               "(select species_desc from trees_species " + 
                  "where trees_species.species_ref = trees.species_ref) trees_species_desc, " +
               "updated " +
        "from trees " +
        "where tree_ref in " +
        "( select detail_ref from si_d " + 
          "where site_ref = '" + recordBean.getSite_ref() + "' ) " +
        "order by tr_no ";
    %>

    <%-- Run the query --%>
    <% rs = connection.query(queryString); %>
    <%-- populate the PageSet from the ResultSet --%>
    <% treesListPageSet.setPageSet(rs, "yyyy-MM-dd"); %>
 
    <%-- close the ResultSet and disconnect from the database --%>
    <% rs.close(); %>
    <% connection.disconnect(); %>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- set the current page number the user is on --%>
<% treesListPageSet.setCurrentPageNum( new Integer(treesListBean.getPage_number()).intValue() ); %>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="treesList" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= treesListBean.getAction().equals("Item") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=treesListBean.getTree_ref() == null || treesListBean.getTree_ref().equals("") %>' >
      <jsp:setProperty name="treesListBean" property="error"
        value="Please select a tree." />
      <jsp:forward page="treesListView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treesList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">itemLookup</sess:setAttribute>
    <c:redirect url="itemLookupScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= treesListBean.getAction().equals("Details") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=treesListBean.getTree_ref() == null || treesListBean.getTree_ref().equals("") %>' >
      <jsp:setProperty name="treesListBean" property="error"
        value="Please select a tree." />
      <jsp:forward page="treesListView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treesList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">treeDetails</sess:setAttribute>
    <c:redirect url="treeDetailsScript.jsp" />
  </if:IfTrue>
  
  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= treesListBean.getAction().equals("Add") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treesList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">treeAdd</sess:setAttribute>
    <c:redirect url="treeAddScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= treesListBean.getAction().equals("|<<") %>' >
    <% treesListPageSet.first(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="treesListView.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= treesListBean.getAction().equals(">>|") %>' >
    <% treesListPageSet.last(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="treesListView.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= treesListBean.getAction().equals(" < ") %>' >
    <% treesListPageSet.previous(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="treesListView.jsp" />
  </if:IfTrue>

  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= treesListBean.getAction().equals(" > ") %>' >
    <% treesListPageSet.next(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="treesListView.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= treesListBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treesList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= treesListBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treesList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= treesListBean.getAction().equals("Back") %>' >
    <% recordBean.setAction_flag(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treesList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= treesListBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${treesListBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="treesListView.jsp" />
