<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.defaultDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="defaultDetailsBean" scope="session" class="com.vsb.defaultDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="defaultDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="defaultDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="defaultDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="defaultDetailsBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="defaultDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="inspList" >
  <jsp:setProperty name="defaultDetailsBean" property="action" value="" />
  <jsp:setProperty name="defaultDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="defaultDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Clear the textOut field --%>
<% defaultDetailsBean.setTextOut(""); %>

<%-- Retrieve the record values used in the view --%>
<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <%-- get the defaultDetails text --%>
  <%-- The text wil be split into 60 char lines, and there should be a --%>
  <%-- single record for each line. So will need to concatenate them all together --%>
  <sql:query>
    select txt, seq_no
    from defi_nb
    where default_no = '<%= recordBean.getDefault_no()%>'
    order by seq_no asc
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="text_line" />
    <% defaultDetailsBean.setTextOut(defaultDetailsBean.getTextOut() + pageContext.getAttribute("text_line") + "&#013;"); %>
  </sql:resultSet>
  
  <%-- get rid of double space characters --%>
  <%
    String tempTextOut = "";
    String lastChar = "";
    String nextChar = "";
    int textLength = defaultDetailsBean.getTextOut().length();
    if (textLength > 0) {
      int i=0;
      int j=1;
      do {
        nextChar = defaultDetailsBean.getTextOut().substring(i,j);
        if (!(lastChar.equals(" ") && nextChar.equals(" "))) {
          tempTextOut = tempTextOut + nextChar;
        }
        lastChar = nextChar;
        i++;
        j++;
      } while (i < textLength);
      defaultDetailsBean.setTextOut(tempTextOut);
    }
  %>
  
  <%-- Is a credit reason mandatory? --%>
  <sql:query>
    select c_field
    from keys
    where service_c = 'ALL'
    and   keyname = 'CREDIT_DEF_ID'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getColumn position="1" to="credit_def_id" />
    <% recordBean.setCredit_def_id((String)pageContext.getAttribute("credit_def_id")); %>
  </sql:resultSet>
</sql:statement>
<sql:closeConnection conn="con"/>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="defaultDetails" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= defaultDetailsBean.getAction().equals("Finish") %>' >
    <%-- get rid of newline and carriage return chars --%>
    <%
      String tempTextIn = defaultDetailsBean.getText();
      tempTextIn = tempTextIn.replace('\n',' ');
      tempTextIn = tempTextIn.replace('\r',' ');
      
      defaultDetailsBean.setText(tempTextIn);
    %>
    
    <%-- Set up the date variables --%>
    <%
      // Set the default time zone to where we are, as the time zone
      // returned from sco is GMT+00:00 which is fine but doesn't mentioned
      // BST. So the default timezone has to be set to "Europe/London".
      // Any objects which use the timezone (like SimpleDateFormat) will then
      // be using the correct timezone.
      TimeZone dtz = TimeZone.getTimeZone("Europe/London");
      TimeZone.setDefault(dtz);

      String date;
      String time;
      String time_h;
      String time_m;
      SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
      SimpleDateFormat formatTime = new SimpleDateFormat("HH:mm");
      SimpleDateFormat formatTime_h = new SimpleDateFormat("HH");
      SimpleDateFormat formatTime_m = new SimpleDateFormat("mm");
      
      Date currentDate = new java.util.Date();
      date = formatDate.format(currentDate);
      time = formatTime.format(currentDate);
      time_h = formatTime_h.format(currentDate);
      time_m = formatTime_m.format(currentDate);
    %>
    
    <%-- Invalid entry --%>
    <%-- make sure the user has selected an action to be performed --%>
    <if:IfTrue cond='<%= defaultDetailsBean.getActionTaken() == null || defaultDetailsBean.getActionTaken().equals("") %>' >
      <jsp:setProperty name="defaultDetailsBean" property="error"
        value="Please select an action to perform." />
      <jsp:forward page="defaultDetailsView.jsp" />
    </if:IfTrue>

    <%-- If text is blank make sure that the user does not have to supply it --%>
    <if:IfTrue cond='<%= defaultDetailsBean.getText().equals("") %>' >
      <%-- user has to supply text if just updating text --%>
      <if:IfTrue cond='<%= defaultDetailsBean.getActionTaken().equals("Update-Text") %>' >
        <jsp:setProperty name="defaultDetailsBean" property="error"
          value="Text must be added when updating text." />
        <jsp:forward page="defaultDetailsView.jsp" />
      </if:IfTrue>
      <%-- user has to supply text if the last default action was "U" (unjustified) and --%>
      <%-- the default is being re-defaulted or cleared. --%>
      <if:IfTrue cond='<%= ( defaultDetailsBean.getActionTaken().equals("Clear") || defaultDetailsBean.getActionTaken().equals("Re-" + application.getInitParameter("def_name_verb")) ) && recordBean.getDef_action().equals("U") %>' >
        <% String errorValue = "Text must be added as the last " + application.getInitParameter("def_name_noun").toLowerCase() + " action was 'Unjustified'."; %>
        <jsp:setProperty name="defaultDetailsBean" property="error"
          value="<%= errorValue %>" />
        <jsp:forward page="defaultDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <if:IfTrue cond='<%= defaultDetailsBean.getActionTaken().equals("Credit") || defaultDetailsBean.getActionTaken().equals("Credit-All") %>' >
      <if:IfTrue cond='<%= defaultDetailsBean.getActionTaken().equals("Credit") && recordBean.getDef_action_flag().equals("Z") %>' >
        <% String errorValue = "Cannot perform a credit. The last transaction for this " + application.getInitParameter("def_name_noun").toLowerCase() + " was a credit."; %>
        <jsp:setProperty name="defaultDetailsBean" property="error"
          value="<%= errorValue %>" />
        <jsp:forward page="defaultDetailsView.jsp" />
      </if:IfTrue>
      
      <if:IfTrue cond='<%= defaultDetailsBean.getText().equals("") && recordBean.getCredit_def_id().equals("Y") %>' >
        <jsp:setProperty name="defaultDetailsBean" property="error"
          value="Text must be added when crediting." />
        <jsp:forward page="defaultDetailsView.jsp" />
      </if:IfTrue>
      
    </if:IfTrue>
    
    <%-- Get additional info if Re-Defaulting -%>
    <%-- clearDefault is defined outside the invalid Re-Default section so that other sections --%>
    <%-- can use it. --%>
    <% boolean clearDefault = false; %>
    <if:IfTrue cond='<%= defaultDetailsBean.getActionTaken().equals("Re-" + application.getInitParameter("def_name_verb")) %>' >
      <%-- get all the required values and check that we can re-default with the --%>
      <%-- default_level and occurances for the new re-default --%>
      <%
        boolean algorithmFailed = false;
        boolean defaultLevelIncr = false;
        boolean reDefaultError = false;
        String reDefaultErrorMsg = ""; 
      %>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con1">
        <sql:query>
          select default_level, default_occ, action_flag, seq_no
          from deft
          where default_no = '<%= recordBean.getDefault_no() %>'
          and   seq_no = (
            select max(seq_no)
            from deft
            where default_no = '<%= recordBean.getDefault_no() %>'
          )
         </sql:query>
         <sql:resultSet id="rset">
           <sql:getColumn position="1" to="default_level" />
           <% recordBean.setDefault_level((String) pageContext.getAttribute("default_level")); %>
           <sql:getColumn position="2" to="default_occ" />
           <% recordBean.setDefault_occ((String) pageContext.getAttribute("default_occ")); %>
           <sql:getColumn position="3" to="action_flag" />
           <sql:getColumn position="4" to="max_seq_no" />
         </sql:resultSet>
         <% String action_flag = ((String) pageContext.getAttribute("action_flag")).trim(); %>
         <% int max_seq_no = Integer.parseInt((String)pageContext.getAttribute("max_seq_no")); %>
         <% int query_seq_no = 1; %>
         
         <%-- The action_flag is not a 'D' or an 'R' so we have to go through all the records to find 
         <%-- the actual default_level and default_occ. --%>
         <if:IfTrue cond='<%= ! action_flag.equals("D") && ! action_flag.equals("R") %>' >
           <%-- loop through all the records to work out the default level and occurancies. --%>
           <%-- The last record (max seq_no) will not be a 'D' or an 'R' as this situation --%>
           <%-- is taken care of above, and this section is only entered if the action_flag of --%>
           <%-- the last transaction is not a 'D' or an 'R'. --%>
           <% 
             int prev_default_level = 1;
             int prev_default_occ = 1;
             String prev_deft_action_flag = "";
             int saved_default_level = 1;
             int saved_default_occ = 1;
           %>
           <% do { %>
             <sql:query>
               select default_level, default_occ, action_flag
               from deft
               where seq_no = '<%= query_seq_no %>'
               and   default_no = '<%= recordBean.getDefault_no()%>'
             </sql:query>
             <sql:resultSet id="rset">
               <sql:getColumn position="1" to="default_level" />
               <sql:getColumn position="2" to="default_occ" />
               <sql:getColumn position="3" to="deft_action_flag" />
             </sql:resultSet>
             <% int default_level = Integer.parseInt((String)pageContext.getAttribute("default_level")); %>
             <% int default_occ = Integer.parseInt((String)pageContext.getAttribute("default_occ")); %>
             <% String deft_action_flag = ((String)pageContext.getAttribute("deft_action_flag")).trim(); %>
             
             <%-- check if the next transaction is a credit if this one is a default or re-default --%>
             <if:IfTrue cond='<%= deft_action_flag.equals("D") || deft_action_flag.equals("R") %>' >
               <if:IfTrue cond='<%= prev_deft_action_flag.equals("D") || prev_deft_action_flag.equals("R") %>' >
                 <% saved_default_level = prev_default_level; %>
                 <% saved_default_occ = prev_default_occ; %>
               </if:IfTrue>
               
               <% 
                 prev_default_level = default_level;
                 prev_default_occ = default_occ;
                 prev_deft_action_flag = deft_action_flag;
               %>
             </if:IfTrue>
             <if:IfTrue cond='<%= ! deft_action_flag.equals("D") && ! deft_action_flag.equals("R") %>' >
               <% prev_deft_action_flag = deft_action_flag; %>
             </if:IfTrue>
             
             <%-- increment the query seq_no to the next one --%> 
             <% query_seq_no = query_seq_no + 1; %>
           <% } while (query_seq_no <= max_seq_no); %>
           
           <%-- the saved values are the values which we require. --%>
           <% recordBean.setDefault_level( String.valueOf(saved_default_level) ); %>
           <% recordBean.setDefault_occ( String.valueOf(saved_default_occ) ); %>
         </if:IfTrue>
         
         <%-- set the default_level and default_occ to an int for comparisons later --%>
         <% int temp_default_level = Integer.parseInt(recordBean.getDefault_level()); %>
         <% int temp_default_occ = Integer.parseInt(recordBean.getDefault_occ()); %>
         
         <%-- get the algorithm --%>
         <sql:query>
          select default_algorithm, default_reason
          from defi
          where default_no = '<%= recordBean.getDefault_no() %>'
         </sql:query>
         <sql:resultSet id="rset">
           <sql:getColumn position="1" to="algorithm" />
           <% recordBean.setAlgorithm((String) pageContext.getAttribute("algorithm")); %>
           <sql:getColumn position="2" to="default_reason" />
           <% recordBean.setFault_code((String) pageContext.getAttribute("default_reason")); %>
         </sql:resultSet>
         
         <%-- get the notice_rep_no --%>
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
        
        <%-- work out what the new default_level and default_occ are. --%>
        <%-- get the algorithm values --%>
        <sql:query>
          select last_level, max_occ, next_action_id
          from defp1
          where algorithm = '<%= recordBean.getAlgorithm() %>'
          and   default_level = '<%= temp_default_level %>'
          and   item_type = '<%= recordBean.getItem_type() %>'
          and   contract_ref = '<%= recordBean.getContract_ref() %>'
          and   priority = '<%= recordBean.getPriority() %>'
        </sql:query>
        <sql:resultSet id="rset">
           <sql:getColumn position="1" to="last_level" />
           <sql:wasNull>
             <% pageContext.setAttribute("last_level", "N"); %>
           </sql:wasNull>
           <sql:getColumn position="2" to="max_occ" />
           <sql:getColumn position="3" to="next_action_id" />
        </sql:resultSet>
        <%
          String last_level = ((String) pageContext.getAttribute("last_level")).trim();
          int max_occ = Integer.parseInt(((String) pageContext.getAttribute("max_occ")).trim());
        %>
        
        <if:IfTrue cond='<%= ! last_level.equals("Y") && temp_default_occ >= max_occ %>' >
          <%
            temp_default_level = temp_default_level + 1;
            defaultLevelIncr = true;
            temp_default_occ = temp_default_occ + 1; 
          %>
        </if:IfTrue>
        <if:IfTrue cond='<%= temp_default_occ < max_occ %>' >
          <% temp_default_occ = temp_default_occ + 1; %>
        </if:IfTrue>
        <% recordBean.setDefault_level( String.valueOf(temp_default_level) ); %>
        <% recordBean.setDefault_occ( String.valueOf(temp_default_occ) ); %>
        
        <if:IfTrue cond='<%= defaultLevelIncr == true %>' >
          <%-- get the algorithm values again as a different algorithm is now being used --%>
          <sql:query>
            select last_level, max_occ, next_action_id
            from defp1
            where algorithm = '<%= recordBean.getAlgorithm() %>'
            and   default_level = '<%= recordBean.getDefault_level() %>'
            and   item_type = '<%= recordBean.getItem_type() %>'
            and   contract_ref = '<%= recordBean.getContract_ref() %>'
            and   priority = '<%= recordBean.getPriority() %>'
          </sql:query>
          <sql:resultSet id="rset">
             <sql:getColumn position="1" to="last_level" />
             <sql:wasNull>
               <% pageContext.setAttribute("last_level", "N"); %>
             </sql:wasNull>
             <sql:getColumn position="2" to="max_occ" />
             <sql:getColumn position="3" to="next_action_id" />
          </sql:resultSet>
          <sql:wasNotEmpty>
            <%
              last_level = ((String) pageContext.getAttribute("last_level")).trim();
              max_occ = Integer.parseInt(((String) pageContext.getAttribute("max_occ")).trim());
            %>
          </sql:wasNotEmpty>
          <sql:wasEmpty>
            <% algorithmFailed = true; %>
          </sql:wasEmpty>
        </if:IfTrue>
        
        <if:IfTrue cond='<%= algorithmFailed = false %>' >
          <%-- get the next action allowed --%>
          <sql:query>
            select na_redeft, and_redeft, na_clear, and_clear
            from defp2
            where next_action_id = '<%= ((String) pageContext.getAttribute("next_action_id")).trim() %>'
          </sql:query>
          <sql:resultSet id="rset">
             <sql:getColumn position="1" to="na_redeft" />
             <sql:getColumn position="2" to="and_redeft" />
             <sql:getColumn position="3" to="na_clear" />
             <sql:getColumn position="4" to="and_clear" />
          </sql:resultSet>
          <%
            String na_redeft = ((String) pageContext.getAttribute("na_redeft")).trim();
            String and_redeft = ((String) pageContext.getAttribute("and_redeft")).trim();
            String na_clear = ((String) pageContext.getAttribute("na_clear")).trim();
            String and_clear = ((String) pageContext.getAttribute("and_clear")).trim();
          %>
          
          <%-- check algorithm and see if the next action is allowed. --%>
          <%-- If the date_due is blank then next action is always allowed --%>
          <if:IfTrue cond='<%= ! recordBean.getDate_due().equals("") %>' >
            <if:IfTrue cond='<%= date.equals(recordBean.getDate_due()) %>' >
              <if:IfTrue cond='<%= and_redeft.equals("N") && and_clear.equals("N") %>' >
                <% algorithmFailed = true; %>
              </if:IfTrue>
            </if:IfTrue>
            <if:IfTrue cond='<%= ! date.equals(recordBean.getDate_due()) %>' >
              <if:IfTrue cond='<%= na_redeft.equals("N") && na_clear.equals("N") %>' >
                <% algorithmFailed = true; %>
              </if:IfTrue>
            </if:IfTrue>
          </if:IfTrue>
        
          <%-- check to see if the default should be cleared --%>
          <if:IfTrue cond='<%= algorithmFailed = false %>' >
            <if:IfTrue cond='<%= na_clear.equals("Y") || and_clear.equals("Y") %>' >
              <% clearDefault = true; %>
            </if:IfTrue>
          </if:IfTrue>
        </if:IfTrue>

        <%-- can we re-default? --%>
        <%-- are we allowed to do the next action? --%>
        <if:IfTrue cond='<%= algorithmFailed == true %>' >
          <% 
            reDefaultError = true;
            reDefaultErrorMsg = "Cannot re-" + application.getInitParameter("def_name_verb").toLowerCase() + " this item, the algorithm won't allow it.";
          %>
        </if:IfTrue>
        
        <%-- Have we reached the last allowable default level? --%>
        <if:IfTrue cond='<%= last_level.equals("Y") && Integer.parseInt(recordBean.getDefault_level()) >= max_occ %>' >
          <% 
            reDefaultError = true;
            reDefaultErrorMsg = "Cannot re-" + application.getInitParameter("def_name_verb").toLowerCase() + " this item on last level.";
          %>
        </if:IfTrue>
      </sql:statement>
      <sql:closeConnection conn="con1"/>
      
      <if:IfTrue cond='<%= reDefaultError == true %>' >
        <jsp:setProperty name="defaultDetailsBean" property="error"
          value='<%= reDefaultErrorMsg %>' />
        <jsp:forward page="defaultDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Update-Text --%>
    <if:IfTrue cond='<%= defaultDetailsBean.getActionTaken().equals("Update-Text") %>' >
      <%-- Indicate that we are updateing the text only. --%>
      <% recordBean.setUpdate_text("Y"); %>

      <%-- add text --%>
      <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
      <c:import url="addTextFunc.jsp" var="webPage" />
      <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

      <%-- run the veolia link if required --%>
      <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
      <c:import url="veoliaLinkFunc.jsp" var="webPage" />
      <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">defaultDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">updateStatus</sess:setAttribute>
      <c:redirect url="updateStatusScript.jsp" />
    </if:IfTrue>
    
    <%-- Crediting --%>
    <if:IfTrue cond='<%= defaultDetailsBean.getActionTaken().equals("Credit") || defaultDetailsBean.getActionTaken().equals("Credit-All") %>' >
      <%-- credit --%>
      <sess:setAttribute name="form">creditFunc</sess:setAttribute>
      <c:import url="creditFunc.jsp" var="webPage" />
      <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

      <%-- add text --%>
      <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
      <c:import url="addTextFunc.jsp" var="webPage" />
      <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

      <%-- run the veolia link if required --%>
      <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
      <c:import url="veoliaLinkFunc.jsp" var="webPage" />
      <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">defaultDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">updateStatus</sess:setAttribute>
      <c:redirect url="updateStatusScript.jsp" />
    </if:IfTrue>
    
    <%-- Clearing --%>
    <%-- if the user selected clear or the algorithm says that the next action is clear --%>
    <if:IfTrue cond='<%= defaultDetailsBean.getActionTaken().equals("Clear") || clearDefault == true %>' >
      <%-- clear --%>
      <sess:setAttribute name="form">clearDefaultFunc</sess:setAttribute>
      <c:import url="clearDefaultFunc.jsp" var="webPage" />
      <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

      <%-- add text --%>
      <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
      <c:import url="addTextFunc.jsp" var="webPage" />
      <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

      <%-- run the veolia link if required --%>
      <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
      <c:import url="veoliaLinkFunc.jsp" var="webPage" />
      <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">defaultDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">updateStatus</sess:setAttribute>
      <c:redirect url="updateStatusScript.jsp" />
    </if:IfTrue>
    
    <%-- Re-defaulting --%>
    <if:IfTrue cond='<%= defaultDetailsBean.getActionTaken().equals("Re-" + application.getInitParameter("def_name_verb")) %>' >
      <%-- indicate the route which will be taken to get to defaultAdditional --%>
      <% recordBean.setDefault_route("defaultDetails"); %>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">defaultDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">defaultDate</sess:setAttribute>
      <c:redirect url="defaultDateScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>
  
  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= defaultDetailsBean.getAction().equals("Customer") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">custDetails</sess:setAttribute>
    <c:redirect url="custDetailsScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= defaultDetailsBean.getAction().equals("Map") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">map</sess:setAttribute>
    <c:redirect url="mapScript.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= defaultDetailsBean.getAction().equals("Trade Details") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">tradeDetails</sess:setAttribute>
    <c:redirect url="tradeDetailsScript.jsp" />
  </if:IfTrue>

  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= defaultDetailsBean.getAction().equals("Tree") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">treeDetails</sess:setAttribute>
    <c:redirect url="treeDetailsScript.jsp" />
  </if:IfTrue>   
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= defaultDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= defaultDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= defaultDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= defaultDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${defaultDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="defaultDetailsView.jsp" />
