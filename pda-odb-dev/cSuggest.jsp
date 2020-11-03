<%@ page import="java.io.*, com.utils.soundex.*, com.db.*" %>

<%-- Each suggest text box requires a bean that should be called for below: --%>
<jsp:useBean id="streetNamesBean"    scope="session" class="com.db.CSuggestBean" />
<jsp:useBean id="tradeSiteNamesBean" scope="session" class="com.db.CSuggestBean" />
<jsp:useBean id="surveyLocationBean" scope="session" class="com.db.CSuggestBean" />

<%
// Set the street names
// This needs to be done only once!!! At the beginning of the session
// streetNamesBean.setStreets();

// Soundex Matcher
Soundex soundex = new Soundex();

// Brute Force Matcher
BFMatch bfMatch = new BFMatch();

// Declare the results array
String[] results;

// Character Array for testing string validation
char[] queryCharArray;

//get the q parameter from URL
String queryString = request.getParameter("queryString");
queryString        = queryString.trim();
String textFieldID = request.getParameter("textFieldID");
queryCharArray     = queryString.toCharArray();
String[] hint = new String[5];

// Get the correct result set depending on the inputFieldID
// There should be a direct correlation between the if
// statments and the number of textField beans imported above!
if( ((String)application.getInitParameter("use_suggest")).equals("Y") ) {
  if( textFieldID.equals("wardenLoc") ){
    results = streetNamesBean.getResults();
    // Re-initialise the beans if they have been blanked
    if( results == null ) {
      streetNamesBean.setSelectQuery("SELECT location_name FROM locn");
      streetNamesBean.setColumnNumber(1);
      streetNamesBean.setResults("java:comp/env","jdbc/pda", application.getInitParameter("db_date_fmt"));
      results = streetNamesBean.getResults();
    }
  } else if( textFieldID.equals("businessName") ){
    results = tradeSiteNamesBean.getResults();
    if( results == null ) {
      tradeSiteNamesBean.setSelectQuery("SELECT ta_name FROM trade_site WHERE ta_name IS NOT NULL AND ta_name <> '' ");
      tradeSiteNamesBean.setColumnNumber(1);
      tradeSiteNamesBean.setResults("java:comp/env","jdbc/pda", application.getInitParameter("db_date_fmt"));
      results = tradeSiteNamesBean.getResults();
    } 
  } else if( textFieldID.equals("surveyLocation") ){
    results = surveyLocationBean.getResults();
    if( results == null ) {
      surveyLocationBean.setSelectQuery("SELECT location_name FROM locn");
      surveyLocationBean.setColumnNumber(1);
      surveyLocationBean.setResults("java:comp/env","jdbc/pda", application.getInitParameter("db_date_fmt"));
      results = surveyLocationBean.getResults();    
    }
  } else {
    results = new String[1];
    results[0] = "No Matches Found";
  }
  
  // Get the inputs length
  int inputLength = queryString.length();
  
  // Set the count to 0
  int count = 0;


  /**********************************************************
  *  Check if queryString is a valid string                 *
  *  VALIDATION BEGINS                                     */
  boolean isValidQ   = true;
  boolean isNumericQ = false;
  
  // Length is 0
  if( queryString.trim().length() == 0 ){
    isValidQ = false;
  }
  
  // No numbers should be present, or special characters
  if ( isValidQ ) {
    for( int j=0; j< queryCharArray.length; j++ ){
      // 13/07/2010  TW  Are numeric characters present?
      if( Character.isDigit( queryCharArray[j] ) ){
        isValidQ   = false;
        isNumericQ = true;
        // Exit the loop
        break;
      } else {
        if( Character.isWhitespace( queryCharArray[j]) ){
          // Skip to next character
        } else if( !Character.isUnicodeIdentifierStart(queryCharArray[j]) ){
          isValidQ = false;
        }
      }
    }
  }

  // Length is too short
  if ( isValidQ ) {
    if( inputLength <= 0 ){
      isValidQ = false;
    }
  }

  // Check that the results bean is still initialised
  if ( isValidQ ) {
    if( results == null ){
      isValidQ = false;
    }
  }
  
  // VALIDATION ENDS


  //While count is less than 5
  //lookup all hints from array if length of q > 0
  boolean exactMatch = false;
  String temp;
  if( isValidQ ){
    // convert the input string to a soundex string
    String soundexQ = soundex.soundex(queryString);
    // 12/07/2010  TW  Should be including first item from results set
    // for(int j=1; j < results.length; j++){
    for(int j=0; j < results.length; j++){
      //String temp;
      // Ensure that the value in results is not null
      if( results[j] != null ) {
        // Ensure that the length of string being matched is not longer than q      
        if( results[j].length() >= inputLength ){
          temp = results[j].substring(0,inputLength);
        } else {
          temp = results[j];
        }
        // Check for a soundex match
        if( soundexQ.equals(soundex.soundex(temp)) ){
          // If we have a soundex match, check for an exact match
          exactMatch = bfMatch.match(queryString,temp);
          // If both strings match put result string in array as a hint
          if( exactMatch ){
            hint[count] = results[j]; 
            count++;
          }
        }
      }        
      if( count == 5){
        break;
      }
    }
  } else if ( isNumericQ ){
    for(int j=0; j < results.length; j++){
      if( results[j] != null ) {
        // Ensure that the length of string being matched is not longer than q      
        if( results[j].length() >= inputLength ){
          temp = results[j].substring(0,inputLength);
        } else {
          temp = results[j];
        }
        exactMatch = bfMatch.match(queryString,temp);
        // If both strings match put result string in array as a hint
        if( exactMatch ){
          hint[count] = results[j]; 
          count++;
        }
      }
      if( count == 5){
        break;
      }
    }
  }
  
  
  // NEW OUTPUT FOR CONTENDER SUGGEST
  //Output "no suggestion" if no hint where found
  //or output the correct values
  
  // Output test for debugging
  /*
  for( int i=0; i<hint.length; i++){
    System.out.println("Hint " + i + ": " + hint[i]);
  }
  */
  
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
                                   "name='suggest" + i + "' " +
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
}
%>



