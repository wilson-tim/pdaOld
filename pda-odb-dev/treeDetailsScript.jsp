<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.treeDetailsBean, com.vsb.treesListBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="com.map.mappingUtils, java.text.SimpleDateFormat, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql"  %>

<jsp:useBean id="treeDetailsBean" scope="session" class="com.vsb.treeDetailsBean" />
<jsp:useBean id="treesListBean"   scope="session" class="com.vsb.treesListBean" />
<jsp:useBean id="recordBean"      scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"      scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="mappingUtils"    scope="session" class="com.map.mappingUtils" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="treeDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="treeDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="treeDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="treeDetailsBean" property="*" />

  </if:IfParameterEquals>
</req:existsParameter>
    
<%-- clear errors --%>
<jsp:setProperty name="treeDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="treesList" >
  <jsp:setProperty name="treeDetailsBean" property="action" value="" />
  <jsp:setProperty name="treeDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="treeDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <%-- Add the new values to the record --%>
  <jsp:setProperty name="recordBean" property="tree_ref" value='<%= treesListBean.getTree_ref() %>' />
</sess:equalsAttribute>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="treeDetails" value="false">
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
  <sql:statement id="stmt" conn="con">
    <% String trees_item = ""; %>
    <% String trees_feature = ""; %>
    <% String trees_contract = ""; %>

    <%-- Get the TREES item --%>
    <sql:query>
      SELECT c_field FROM keys WHERE keyname = 'TREES_ITEM'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="c_field" />
      <sql:wasNotNull>
        <% trees_item = ((String)pageContext.getAttribute("c_field")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>
    <%-- Get the TREES feature --%>
    <sql:query>
      SELECT c_field FROM keys WHERE keyname = 'TREES_FEATURE'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="c_field" />
      <sql:wasNotNull>
        <% trees_feature = ((String)pageContext.getAttribute("c_field")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>
    <%-- Get the TREES contract --%>
    <sql:query>
      SELECT c_field FROM keys WHERE keyname = 'TREES_CONTRACT'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="c_field" />
      <sql:wasNotNull>
        <% trees_contract = ((String)pageContext.getAttribute("c_field")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>
    <%-- Get the round_c --%>
    <sql:query>
      SELECT round_c, frequency, freq_basis, next_due
      FROM si_d 
      WHERE site_ref = '<%= recordBean.getSite_ref() %>'
      AND   detail_ref = <%= recordBean.getTree_ref() %>
      AND   item_ref = '<%= trees_item %>'
      AND   feature_ref = '<%= trees_feature %>'
      AND   contract_ref = '<%= trees_contract %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="round_c" />
      <sql:wasNotNull>
        <% treeDetailsBean.setRound_c( ((String)pageContext.getAttribute("round_c")).trim() ); %>
      </sql:wasNotNull>

      <% String frequency = ""; %>
      <% String freq_basis = ""; %>
      <% String ref = ""; %>
      <sql:getColumn position="2" to="frequency" />
      <sql:wasNotNull>
        <% frequency = ((String)pageContext.getAttribute("frequency")).trim(); %>
      </sql:wasNotNull>
      <sql:getColumn position="3" to="freq_basis" />
      <sql:wasNotNull>
        <% freq_basis = ((String)pageContext.getAttribute("freq_basis")).trim(); %>
      </sql:wasNotNull>
      <% ref = frequency + "|" + freq_basis; %>
      <% treeDetailsBean.setFrequency(ref); %>

      <sql:getDate position="4" to="next_due" format="<%= application.getInitParameter("db_date_fmt") %>" />
      <sql:wasNotNull>
        <% String db_next_due = ((String)pageContext.getAttribute("next_due")).trim(); %>
        <% treeDetailsBean.setNext_due( db_next_due ); %>
        <% treeDetailsBean.setView_next_due( helperBean.dispDate( db_next_due, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) ); %>
      </sql:wasNotNull>
    </sql:resultSet>

    <sql:query>
      SELECT tree_desc,
             tr_no,
             position,
             position_ref,
             species_ref,
             height_ref,
             age_ref,
             crown_ref,
             dbh_ref,
             condition_ref,
             vigour_ref,
             pavement_ref,
             boundary_ref,
             building_ref,
             osmapref,
             issue_ref,
             easting,
             northing
        FROM trees
       WHERE tree_ref = <%= recordBean.getTree_ref() %>
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="tree_desc" />
      <sql:wasNotNull>
        <% treeDetailsBean.setTree_desc( (String)pageContext.getAttribute("tree_desc") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="2" to="tr_no" />
      <sql:wasNotNull>
        <% treeDetailsBean.setTr_no( (String)pageContext.getAttribute("tr_no") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="3" to="position" />
      <sql:wasNotNull>
        <% treeDetailsBean.setPosition( (String)pageContext.getAttribute("position") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="4" to="position_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setPosition_ref( (String)pageContext.getAttribute("position_ref") ); %>
      </sql:wasNotNull>        
      <sql:getColumn position="5" to="species_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setSpecies_ref( (String)pageContext.getAttribute("species_ref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="6" to="height_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setHeight_ref( (String)pageContext.getAttribute("height_ref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="7" to="age_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setAge_ref( (String)pageContext.getAttribute("age_ref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="8" to="crown_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setCrown_ref( (String)pageContext.getAttribute("crown_ref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="9" to="dbh_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setDbh_ref( (String)pageContext.getAttribute("dbh_ref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="10" to="condition_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setCondition_ref( (String)pageContext.getAttribute("condition_ref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="11" to="vigour_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setVigour_ref( (String)pageContext.getAttribute("vigour_ref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="12" to="pavement_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setPavement_ref( (String)pageContext.getAttribute("pavement_ref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="13" to="boundary_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setBoundary_ref( (String)pageContext.getAttribute("boundary_ref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="14" to="building_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setBuilding_ref( (String)pageContext.getAttribute("building_ref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="15" to="osmapref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setOsmapref( (String)pageContext.getAttribute("osmapref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="16" to="issue_ref" />
      <sql:wasNotNull>
        <% treeDetailsBean.setIssue_ref( (String)pageContext.getAttribute("issue_ref") ); %>
      </sql:wasNotNull>
      <sql:getColumn position="17" to="easting" />
      <sql:wasNotNull>
        <% treeDetailsBean.setEasting( (String)pageContext.getAttribute("easting") ); %>          
      </sql:wasNotNull>
      <sql:getColumn position="18" to="northing" />
      <sql:wasNotNull>
        <% treeDetailsBean.setNorthing( (String)pageContext.getAttribute("northing") ); %>
      </sql:wasNotNull>
    </sql:resultSet>
  </sql:statement>
  <sql:closeConnection conn="con"/>    
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Clear the textOut field --%>
<% treeDetailsBean.setTextOut(""); %>

<%-- Retrieve the record values used in the view --%>
<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <%-- get the treeDetails text --%>
  <%-- The text wil be split into 60 char lines, and there should be a --%>
  <%-- single record for each line. So will need to concatenate them all together --%>
  <sql:query>
    select txt, seq
    from trees_text
    where tree_ref = '<%= recordBean.getTree_ref()%>'
    order by seq asc
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="text_line" />
    <sql:wasNotNull>
      <% treeDetailsBean.setTextOut(treeDetailsBean.getTextOut() + pageContext.getAttribute("text_line") + "&#013;"); %>
    </sql:wasNotNull>
  </sql:resultSet>
  
  <%-- get rid of double space characters --%>
  <%
    String tempTextOut = "";
    String lastChar = "";
    String nextChar = "";
    int textLength = treeDetailsBean.getTextOut().length();
    if (textLength > 0) {
      int i=0;
      int j=1;
      do {
        nextChar = treeDetailsBean.getTextOut().substring(i,j);
        if (!(lastChar.equals(" ") && nextChar.equals(" "))) {
          tempTextOut = tempTextOut + nextChar;
        }
        lastChar = nextChar;
        i++;
        j++;
      } while (i < textLength);
      treeDetailsBean.setTextOut(tempTextOut);
    }
  %>
</sql:statement>
<sql:closeConnection conn="con"/>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="treeDetails" >
  <%-- get rid of newline and carriage return chars --%>
  <%
    String tempTextIn = treeDetailsBean.getText();
    tempTextIn = tempTextIn.replace('\n',' ');
    tempTextIn = tempTextIn.replace('\r',' ');

    treeDetailsBean.setText(tempTextIn);
  %>

  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= treeDetailsBean.getAction().equals("Update") %>' >
    <% String trees_item = ""; %>
    <% String trees_feature = ""; %>
    <% String trees_contract = ""; %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <%-- Get the TREES item --%>
      <sql:query>
        SELECT c_field FROM keys WHERE keyname = 'TREES_ITEM'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
        <sql:wasNotNull>
          <% trees_item = ((String)pageContext.getAttribute("c_field")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>

      <%-- Get the TREES feature --%>
      <sql:query>
        SELECT c_field FROM keys WHERE keyname = 'TREES_FEATURE'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
        <sql:wasNotNull>
          <% trees_feature = ((String)pageContext.getAttribute("c_field")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>

      <%-- Get the TREES contract --%>
      <sql:query>
        SELECT c_field FROM keys WHERE keyname = 'TREES_CONTRACT'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
        <sql:wasNotNull>
          <% trees_contract = ((String)pageContext.getAttribute("c_field")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= helperBean.isNotValid(treeDetailsBean.getTr_no()) %>' >
      <jsp:setProperty name="treeDetailsBean" property="error"
        value="A Seq number must be supplied." />
      <jsp:forward page="treeDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isValid(treeDetailsBean.getTr_no()) && !helperBean.isStringInt(treeDetailsBean.getTr_no()) %>' >
      <jsp:setProperty name="treeDetailsBean" property="error"
        value="A Seq number must be an Integer." />
      <jsp:forward page="treeDetailsView.jsp" />
    </if:IfTrue>

    <% boolean seq_exists = false; %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select trees.tr_no
        from si_d, trees
        where si_d.site_ref = '<%= recordBean.getSite_ref() %>'
        and   si_d.item_ref = '<%= trees_item %>'
        and   si_d.feature_ref = '<%= trees_feature %>'
        and   si_d.contract_ref = '<%= trees_contract %>'
        and   si_d.detail_ref = trees.tree_ref
        and   trees.tree_ref <> <%= recordBean.getTree_ref() %>
        and   trees.tr_no = <%= treeDetailsBean.getTr_no() %>
      </sql:query>
      <sql:resultSet id="rset">
      </sql:resultSet>
      <sql:wasNotEmpty>
        <% seq_exists = true; %>
      </sql:wasNotEmpty>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- The seq/tr_no cannot already exist for a different tree. --%>
    <if:IfTrue cond='<%= seq_exists %>' >
      <jsp:setProperty name="treeDetailsBean" property="error"
        value="The supplied Seq number is already assigned to a tree on this road." />
      <jsp:forward page="treeDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isValid(treeDetailsBean.getPosition_ref()) && !helperBean.isStringInt(treeDetailsBean.getPosition_ref()) %>' >
      <jsp:setProperty name="treeDetailsBean" property="error"
        value="A Pos Ref number must be an Integer." />
      <jsp:forward page="treeDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isNotValid(treeDetailsBean.getFrequency()) %>' >
      <jsp:setProperty name="treeDetailsBean" property="error"
        value="A Frequency must be supplied." />
      <jsp:forward page="treeDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isValid(treeDetailsBean.getView_next_due()) && ! helperBean.isValidDateString(treeDetailsBean.getView_next_due(), application.getInitParameter("view_date_fmt")) %>' >
      <jsp:setProperty name="treeDetailsBean" property="error"
        value="The Next Due date is not a valid date." />
      <jsp:forward page="treeDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isValid(treeDetailsBean.getView_next_due()) && helperBean.isDateBeforeToday(treeDetailsBean.getView_next_due(), application.getInitParameter("view_date_fmt")) %>' >
      <jsp:setProperty name="treeDetailsBean" property="error"
        value="The Next Due date cannot be in the past." />
      <jsp:forward page="treeDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= helperBean.isValid(treeDetailsBean.getView_next_due()) && helperBean.isDateAfter(treeDetailsBean.getView_next_due(), application.getInitParameter("view_date_fmt"), 60) %>' >
      <jsp:setProperty name="treeDetailsBean" property="error"
        value="The Next Due date cannot be more than 60 years in the future." />
      <jsp:forward page="treeDetailsView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Translate the View_next_due date into the Next_due date format --%>
    <if:IfTrue cond='<%= helperBean.isValid(treeDetailsBean.getView_next_due()) %>' >
      <%
        TimeZone dtz = TimeZone.getTimeZone("Europe/London");
        TimeZone.setDefault(dtz);

        SimpleDateFormat formatViewDate = new SimpleDateFormat(application.getInitParameter("view_date_fmt"));
        SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));

        Date viewDate = formatViewDate.parse(treeDetailsBean.getView_next_due());
        treeDetailsBean.setNext_due(formatDbDate.format(viewDate));
      %>
    </if:IfTrue>
    <if:IfTrue cond='<%= helperBean.isNotValid(treeDetailsBean.getView_next_due()) %>' >
      <% treeDetailsBean.setNext_due(""); %>
    </if:IfTrue>

    <%-- update tree --%>
    <sess:setAttribute name="form">addUpdateTreeFunc</sess:setAttribute>
    <c:import url="addUpdateTreeFunc.jsp" var="webPage" />
    <% helperBean.throwException("addUpdateTreeFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Need to refresh the text so that the user sees any text they have just added in the --%>
    <%-- greyed out none editable section, and clear out the text that they just added. --%>

    <%-- Clear the textOut field --%>
    <% treeDetailsBean.setTextOut(""); %>

    <%-- Retrieve the record values used in the view --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- get the treeDetails text --%>
      <%-- The text wil be split into 60 char lines, and there should be a --%>
      <%-- single record for each line. So will need to concatenate them all together --%>
      <sql:query>
        select txt, seq
        from trees_text
        where tree_ref = '<%= recordBean.getTree_ref()%>'
        order by seq asc
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="text_line" />
        <sql:wasNotNull>
          <% treeDetailsBean.setTextOut(treeDetailsBean.getTextOut() + pageContext.getAttribute("text_line") + "&#013;"); %>
        </sql:wasNotNull>
      </sql:resultSet>
      
      <%-- get rid of double space characters --%>
      <%
        String tempTextOut = "";
        String lastChar = "";
        String nextChar = "";
        int textLength = treeDetailsBean.getTextOut().length();
        if (textLength > 0) {
          int i=0;
          int j=1;
          do {
            nextChar = treeDetailsBean.getTextOut().substring(i,j);
            if (!(lastChar.equals(" ") && nextChar.equals(" "))) {
              tempTextOut = tempTextOut + nextChar;
            }
            lastChar = nextChar;
            i++;
            j++;
          } while (i < textLength);
          treeDetailsBean.setTextOut(tempTextOut);
        }
      %>

      <%-- Get the tree_desc just incase it has changed --%>
      <sql:query>
        select tree_desc
        from trees
        where tree_ref = <%= recordBean.getTree_ref() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="tree_desc" />
        <sql:wasNotNull>
          <% treeDetailsBean.setTree_desc(((String)pageContext.getAttribute("tree_desc")).trim()); %>
        </sql:wasNotNull>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- Clear the text field --%>
    <% treeDetailsBean.setText(""); %>

    <%-- Give a message to indicate that the tree has been updated --%>
    <jsp:setProperty name="treeDetailsBean" property="error"
        value="The tree has been UPDATED." /> 

    <sess:setAttribute name="form">treeDetails</sess:setAttribute>
    <jsp:forward page="treeDetailsView.jsp" />
  </if:IfTrue>
  
  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= treeDetailsBean.getAction().equals("Item") %>' >
    <%-- Invalid entry --%>
    <%-- NONE --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treeDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">itemLookup</sess:setAttribute>
    <c:redirect url="itemLookupScript.jsp" />
  </if:IfTrue>
  
  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= treeDetailsBean.getAction().equals("Next") %>' >
    <%-- Invalid entry --%>
    <%-- NONE --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treesList</sess:setAttribute>
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input">treesList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">treeDetails</sess:setAttribute>
    
    <%-- Save current tree_ref --%>
    <% String lastTreeRef = recordBean.getTree_ref(); %>
    
    <%-- Loop flag --%>
    <% boolean foundFlag = false; %>

    <%-- Trees List --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <%-- Get the trees on the street from si_d --%>
      <sql:query>
        SELECT detail_ref
          FROM si_d
         WHERE site_ref = '<%= recordBean.getSite_ref() %>'
        ORDER BY detail_ref
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="detail_ref" />
        <% String detail_ref = ((String)pageContext.getAttribute("detail_ref")).trim(); %>
        <if:IfTrue cond='<%= foundFlag == true %>' >
          <% foundFlag = false; %>
          <% recordBean.setTree_ref(detail_ref); %>
          <% treesListBean.setTree_ref(detail_ref); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= detail_ref.equals(lastTreeRef) %>' >
          <% foundFlag = true; %>
        </if:IfTrue>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- Going back to this form as if coming from treesList form --%>
    <if:IfTrue cond='<%= recordBean.getTree_ref().equals(lastTreeRef) %>' >
      <%-- Display a message to indicate that the end of the list has been reached --%>
      <jsp:setProperty name="treeDetailsBean" property="error"
        value="This is the last record in the list." /> 
      <sess:setAttribute name="form">treeDetails</sess:setAttribute>
      <jsp:forward page="treeDetailsView.jsp" />
    </if:IfTrue>
    <if:IfTrue cond='<%= !recordBean.getTree_ref().equals(lastTreeRef) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">treesList</sess:setAttribute>
      <%-- Indicate which form we are in/just-come-from --%>
      <sess:setAttribute name="input">treesList</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">treeDetails</sess:setAttribute>
      <c:redirect url="treeDetailsScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>
  
  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= treeDetailsBean.getAction().equals("GPS") %>' >
    <%-- Invalid entry --%>
    <%-- NONE --%>

    <%-- Valid entry --%>
    <if:IfTrue cond='<%= ! treeDetailsBean.getGpsLat().trim().equals("") && ! treeDetailsBean.getGpsLng().trim().equals("") %>' >
      <%
        double lat = (new Double(treeDetailsBean.getGpsLat())).doubleValue();
        double lng = (new Double(treeDetailsBean.getGpsLng())).doubleValue();    

        String estNth = mappingUtils.LatLngToOSRef(lat, lng);

        StringTokenizer stEN = new StringTokenizer(estNth, ",");
        double newE = (new Double(stEN.nextToken())).doubleValue();
        newE = helperBean.roundDouble(newE, 2);
        double newN = (new Double(stEN.nextToken())).doubleValue();
        newN = helperBean.roundDouble(newN, 2);

        treeDetailsBean.setEasting(String.valueOf(newE));
        treeDetailsBean.setNorthing(String.valueOf(newN));
      %>
    </if:IfTrue>
   
    <jsp:forward page="treeDetailsView.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= treeDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treeDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= treeDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treeDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= treeDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">treeDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= treeDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${treeDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="treeDetailsView.jsp" />
