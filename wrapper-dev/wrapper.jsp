<%@ page errorPage="error.jsp" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<%
  // (1) wrapper --> remoteScript
  // (2) remoteScript (forwards to view) --> wrapper --> web browser
  // (3) web browser --> wrapper --> nextRemoteScript
  // (4) nextRemoteScript (forwards to view) --> wrapper --> web browser
  // etc..
  //
  // Each time the wrapper is called it changes the import statements url, using the input request parameter from
  // the web browser, to point to the real page. It then gets the real page and changes the real pages form tag url
  // to point back at the wrapper before sending it to the web browser, and the whole cycle starts again.
  // The wrapper needs to be initiated to get the first form by sending it the input parameter for the first page.
  // e.g. call like http://?.?.?.?/wrapper.jsp?input=index
  //
  // The params for the real url will need to be culled from the web browser request object when it is returned
  // and added to the new URL which will be imported.
%>

<% // Construct the real URL, including the request parameters, which will be called by the this wrapper JSP %>
<c:if test="${empty param.input}">
  <c:url value="http://${initParam.server}/${initParam.webapp}" var="pageUrl" >
    <% // For every String[] item of paramValues... %>
    <c:forEach var='parameter' items='${paramValues}'> 
      <% // Iterate over the values, a String[], associated with this request parameter %>
      <c:forEach var='value' items='${parameter.value}'>
        <% // Add the the parameter as a new parameter to the url %>
	      <c:param name="${parameter.key}" value="${value}" />
      </c:forEach>
    </c:forEach>
  </c:url>
</c:if>
<c:if test="${not empty param.input}">
  <c:url value="http://${initParam.server}/${initParam.webapp}/${param.input}Script.jsp;jsessionid=${param.jsessionid}" var="pageUrl" >
    <% // For every String[] item of paramValues... %>
    <c:forEach var='parameter' items='${paramValues}'> 
      <% // Iterate over the values, a String[], associated with this request parameter %>
      <c:forEach var='value' items='${parameter.value}'>
        <% // Add the the parameter as a new parameter to the url %>
	      <c:param name="${parameter.key}" value="${value}" />
      </c:forEach>
    </c:forEach>
  </c:url>
</c:if>

<% // doing it with a string %>
<% // This gets the web page and then shows it, after changing the <form ...> tag action to point to this wrapper JSP %>
<c:import url="${pageUrl}" var="webPage" />

<c:if test="${not empty webPage}">
  <% // replace the form tag url with 'wrapper.jsp' and also change xhtml to html %>
  <%
    String findString = "";
    int topIndex = 0;
    int bottomIndex = 0;
    String webPageTop = "";
    String webPageBottom = "";
    String webPage = (String)pageContext.getAttribute("webPage");
   
    // remove <?xml version="1.0"?>
    findString = "<?xml version=\"1.0\"?>";
    topIndex = webPage.indexOf(findString);
    if (topIndex != -1 ) {
      webPageTop = webPage.substring(0, topIndex);
      bottomIndex = topIndex + findString.length() + 1;
      webPageBottom = webPage.substring(bottomIndex);
      webPage = webPageTop + webPageBottom;
    }
  
    // replace the xhtml DOCTYPE with the html DOCTYPE
    findString = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">";
    topIndex = webPage.indexOf(findString);
    if (topIndex != -1 ) {
      webPageTop = webPage.substring(0, topIndex);
      bottomIndex = topIndex + findString.length() + 1;
      webPageBottom = webPage.substring(bottomIndex);
      webPage = webPageTop + "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">" + webPageBottom;
    }
  
    // remove the html tags name space
    findString = "<html xmlns=\"http://www.w3.org/1999/xhtml\">";
    topIndex = webPage.indexOf(findString);
    if (topIndex != -1 ) {
      webPageTop = webPage.substring(0, topIndex);
      bottomIndex = topIndex + findString.length() + 1;
      webPageBottom = webPage.substring(bottomIndex);
      webPage = webPageTop + "<html>" + webPageBottom;
    }
  
    // replace the xhtml content type with the html one
    findString = "<meta http-equiv=\"Content-Type\" content=\"application/xhtml+xml\" />";
    topIndex = webPage.indexOf(findString);
    if (topIndex != -1 ) {
      webPageTop = webPage.substring(0, topIndex);
      bottomIndex = topIndex + findString.length() + 1;
      webPageBottom = webPage.substring(bottomIndex);
      webPage = webPageTop + "<meta http-equiv=\"Content-Type\" content=\"text/html\" />" + webPageBottom;
    }
  
    // replace form tag url with 'wrapper.jsp'
    findString = "<form onSubmit=\"return singleclick();\" action=\"";
    topIndex = webPage.indexOf(findString) + findString.length();
    if (topIndex != (-1 + findString.length()) ) {
      webPageTop = webPage.substring(0, topIndex);
      bottomIndex = webPage.indexOf("\"", topIndex + 1);
      webPageBottom = webPage.substring(bottomIndex);
      webPage = webPageTop + "wrapper.jsp" + webPageBottom;
    }
  
    pageContext.setAttribute("webPage", webPage);
  %>
  
  <% // print out the resulting webPage ... %>
  <c:out value="${webPage}" escapeXml="false" />
</c:if>

<% // ---------------------------------------------------------------------- %>

<c:if test="${initParam.debug == 'Y'}">
  <% // DEBUG INFO %>
  
  <b>DEBUG INFO FROM PREVIOUS PAGE</b> <c:out value="${param.input}" />Script.jsp<br />
  <b>PARAMETER input</b> : <c:out value="${param.input}" /><br />
  <b>URL</b> : <c:out value="${pageUrl}" escapeXml="false" /><br />
  <b>ALL PARAMETERS</b> ... <br />
  <% // For every String[] item of paramValues... %>
  <c:forEach var='parameter' items='${paramValues}'> 
    <% // Iterate over the values, a String[], associated with this request parameter %>
    <c:forEach var='value' items='${parameter.value}'>
      <% // Add the the parameter as a new parameter to the url %>
  	  <b><c:out value="${parameter.key}" /></b> : <c:out value="${value}" /><br />
    </c:forEach>
  </c:forEach>
  
  <% // NOTES %>
  
  <%
    // There is a problem with sessions, i.e. they are not carried from page to page. To do this the imported web pages would
    // have to have the session id (jsessionid) as a hiddden html form field, this could then be used in the url (pageUrl)
    // to construct an url that tomcat could then match up with its sessions:
    // 
    // value="http://${initParam.server}/${initParam.webapp}/${param.input}Script.jsp;jsessionid=${param.session}"
    //
    // There may be other ways, but this is the first one that I could think of.
  %>
  
  <% 
    // Could use this to do the transformation of xhtml to html instead of doing it manually with the Reader object below.
    // <c:import url="${pageUrl}" var="xml" />
    // <c:import url="/WEB-INF/xslt/HTMLDisplay.xsl" var="xslt"/>
    // <x:transform source="${xml}" xslt="${xslt}"/>
    // process the xml string and point the form tag at this wrapper page
  %>
  
  <%
   // doing it with a reader
   // This gets the web page and then shows it, after changing the <form ...> tag url to point to this wrapper JSP 
   // <c:import url="${pageUrl}" varReader="webPage" >
   //   Process the webPage Reader object pointing the form tag at this wrapper page.
   //   e.g. replace '<form action="loginScript.jsp" method="post">' with
   //   '<form action="wrapper.jsp" method="post">'
   //   Print out the reader as you go. Also change xhtml to html as you go.
   // </c:import>
  %>
</c:if>
