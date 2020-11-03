<%@ page import="com.vsb.incidentBean" %>
<%@ page import="com.vsb.surveyBean" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />
<jsp:useBean id="surveyBean" scope="session" class="com.vsb.surveyBean" />
<script>window.history.go(1);</script>
<html>
  <head>
    <meta http-equiv="Refresh" content="<app:initParameter name='refreshInterval' />" />
    <title><x:out select="$WAHeader//headers/element/web_type_desc"  /></title>
    <style type="text/css">@import url(publicaccess.css);</style>
  </head>
  <body class="<c:out value="${requiredPage}"/>">
<% int questionCount=0; %><x:forEach var="n" select="$survey_questions//questions/element"><% questionCount=questionCount+1; %></x:forEach>
<% int i=0; %>
<form action="publicaccess.jsp" method="post">
    <h2 class="PageTitle"><x:out select="$WAWorkFlow//services/element[service_code=$service_c]/paths/element[component_page = $requiredPage]/component_title" /></h2>
    <input type="hidden" name="input" value="<c:out value="${requiredPage}"/>" >
    <input type="hidden" name="webtype" value="<%= incidentBean.getWebType() %>" >
    <input type="hidden" name="numberofquestions" value="<%=questionCount %>" >
    <div class="UserInput">
        <table>
            <x:forEach var="n" select="$survey_questions//questions/element">
                <c:set var="question_ref"><x:out select="$n/question_ref"/></c:set>
                <c:set var="alist"><x:out select="$survey_answers//answers/element[question_ref = $question_ref]" /></c:set>
                <tr><td><label class="input-name"><x:out select="$n/question_text"/></label>
                <input type="hidden" name="Q<x:out select='$n/question_ref' />" value="<x:out select="$n/question_text"/>" ></td></tr>
                <if:IfTrue cond='<%= ((String)pageContext.getAttribute("alist")).equals("") %>' >
                    <tr><td><input class="input-field" name="A<x:out select='$n/question_ref' />" type="text" maxlength="100" size="50" value="<%= surveyBean.getAnswerByIndex(i) %>"/></td></tr>
                </if:IfTrue>
                <if:IfTrue cond='<%= !((String)pageContext.getAttribute("alist")).equals("") %>' >
                    <tr><td><select class="input-field" name="A<x:out select='$n/question_ref' />">
                    <x:forEach var="na" select="$survey_answers//answers/element[question_ref = $question_ref]">
                        <c:set var="answer_text"><x:out select="$na/answer_text"/></c:set>
                        <option value="<x:out select='$na/answer_text' />"
                        <% if(surveyBean.getAnswerByIndex(i).equals((String)pageContext.getAttribute("answer_text"))){
                            %> selected <%
                        }
                        %>
                        ><x:out select='$na/answer_text' /></option>
                    </x:forEach> 
                    </select></td></tr>
                </if:IfTrue>
                <% ++i; %>
            </x:forEach> 
        </table>
    </div>
    <div class="Controls">
        <div class="Back"><input class="control" type="submit" name="action" value="Back" /></div>
        <div class="Next"><input class="control" type="submit" name="action" value="Next" /></div>
    </div>
</form>
<div class="HelpText"><x:out select="$WAWorkFlow//services/element[service_code=$service_c]/paths/element[component_page = $requiredPage]/component_help" /></div>
<div class="error"><c:out value="${errorMessage}" /></div>
    <jsp:include page="include/footer.jsp" flush="true" />
  </body>
</html>
