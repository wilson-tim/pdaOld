<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<script>window.history.go(1);</script>
<html>
  <head>
    <meta http-equiv="Refresh" content="<app:initParameter name='refreshInterval' />" />
    <title><x:out select="$WAHeader//headers/element/web_type_desc"  /></title>
    <style type="text/css">@import url(publicaccess.css);</style>
  </head>
  <body class="<c:out value="${requiredPage}"/>">
    <div class="Banner">
        <img class="logo" src="<x:out select="$WAHeader//headers/element/logo_path" />"/><label class="Title"><x:out select="$WAHeader//headers/element/web_type_desc" /></label>
    </div>
    <div class="HotLinks">
        <h4><x:out select="$WAHeader//headers/element/links_title" /></h4>
        <ul>
        <x:forEach var="n" select="$PALinks//links/element">
            <li><a href="<x:out select="$n/link_url" />" target="ServiceWindow"><x:out select="$n/link_title" /></a></li>
        </x:forEach> 
        </ul>
    </div>
    <c:set var="requiredPage" value="getService" scope="session"/>
    <iframe class="ServiceWindow" name="ServiceWindow" src="publicaccess.jsp?input=none&action=JumpTo&page=getService"/>
  </body>
</html>
