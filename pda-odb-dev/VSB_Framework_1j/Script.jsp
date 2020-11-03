<%@ page errorPage="error.jsp" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<%-- We're here because the session has expired and the user has tried to --%>
<%-- go back and has been sent to the Script.jsp page as the --%>
<%-- #FORM#Bean.getSavedPreviousForm() is blank as it was stored in the --%>
<%-- expired session. --%>
<%-- Blank the previousForm session --%>
<sess:setAttribute name="previousForm"></sess:setAttribute>
<%-- Indicate which form we are going to next --%>
<sess:setAttribute name="form">index</sess:setAttribute>
<jsp:forward page="index.jsp" />
