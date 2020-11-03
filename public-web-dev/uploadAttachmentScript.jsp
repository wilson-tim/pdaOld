<%@ page import="java.io.FileInputStream" %>
<%@ page import="com.vsb.incidentBean" %>
<%@ page import="com.vsb.savedPublicDescriptionBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag" prefix="do" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>

<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />
<jsp:useBean id="savedPublicDescriptionBean" scope="session" class="com.vsb.savedPublicDescriptionBean" />
<if:IfParameterEquals name="action" value="Back" >
    <jsp:forward page="publicaccess.jsp?input=none&action=Back" />
</if:IfParameterEquals>
<if:IfParameterEquals name="action" value="RemoveAttachment" >
<%
    int ref=Integer.parseInt((String)request.getParameter("ref"));
    incidentBean.Attachments.remove(ref);
    incidentBean.AttachmentsFilename.remove(ref);
    String s;
    s="" + incidentBean.AttachmentsFilename.size() + " Attachments";
    savedPublicDescriptionBean.setPage("uploadAttachment",s );
%>
    <jsp:forward page="uploadAttachmentView.jsp" />
</if:IfParameterEquals>
<jsp:forward page="uploadAttachmentView.jsp" />
