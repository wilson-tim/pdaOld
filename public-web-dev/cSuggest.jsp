<%@ page import="java.util.ArrayList" %>
<%@ page import="java.io.*, com.utils.soundex.*, com.db.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag" prefix="do" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%
Soundex soundex = new Soundex();

// Brute Force Matcher
BFMatch bfMatch = new BFMatch();

// Declare the results array
ArrayList results = new ArrayList();

// Character Array for testing string validation
char[] queryCharArray;
%><x:forEach var="n" select="$cSurggestResults//streets/element"><c:set var="result"><x:out select="$n/street_name" /></c:set>
<%    results.add((String)pageContext.getAttribute("result")); %></x:forEach>
<%
String queryString = request.getParameter("queryString");
queryString = queryString.trim();
String textFieldID = request.getParameter("textFieldID");
queryCharArray     = queryString.toCharArray();
String[] hint = new String[5];
boolean isValidQ = true;
// Get the inputs length
int inputLength = queryString.length();

// Set the count to 0
int count = 0;

if( queryString.trim().length() == 0 ){
  isValidQ = false;
}
// No numbers should be present, or special characters
for( int j=0; j< queryCharArray.length; j++ ){
  if( Character.isWhitespace( queryCharArray[j]) ){
    break;
  } else if( !Character.isUnicodeIdentifierStart(queryCharArray[j]) ){
    isValidQ = false;
  }
}
// Length is to short
if( inputLength <= 0 ){
  isValidQ = false;
}
// VALIDATION ENDS

if( isValidQ ){
  // convert the input string to a soundex string
  String soundexQ = soundex.soundex(queryString);
  for(int j=1; j < results.size(); j++){
    String temp;
    // Ensure that the length of string being matched is not longer than q
    if( ((String)results.get(j)).length() >= inputLength ){
      temp = ((String)results.get(j)).substring(0,inputLength);
    } else {
      temp = ((String)results.get(j));
    }
    // Check for a soundex match
    if( soundexQ.equals(soundex.soundex(temp)) ){
      // If we have a soundex match, check for an exact match
      boolean exactMatch = false;
      exactMatch = bfMatch.match(queryString,temp);
      // If both strings match put temp string in array as a hint
      if( exactMatch ){
        hint[count] = ((String)results.get(j));
        count++;
      }
    }
    if( count == 5){
      break;
    }
  }
}
PrintWriter printwriter = response.getWriter();
// If we have a suggestion
if(hint[0] != null){
  //printwriter.println("<tr><td></td><td>");        
  printwriter.println("<table class='suggest' id='suggestTable'>");
  // Print a row for each suggestion
  for(int i=0; i<hint.length; i++){
    if(hint[i] != null){
      String htmlOutput = "<tr> " +
                            "<td> " +  
                             "<span id='suggest"+ i + "' " + 
                                 "name='suggestSpan' " +
                                 "class='suggest' " +
                                 "onmouseover='changeClassIn(this);' " +
                                 "onmouseout='changeClassOut(this);' " +
                                 "onclick='selectMe(this, \""+ textFieldID +"\");'>" + hint[i] + "</span> " +
                            "</td> " +
                          "</tr>";
      printwriter.println(htmlOutput);
    }
  }
  printwriter.println("</table>");
}
%>
