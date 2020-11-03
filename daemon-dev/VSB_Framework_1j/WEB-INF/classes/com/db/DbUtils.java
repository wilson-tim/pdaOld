package com.db;

public class DbUtils {
  //
  // Checks a string for illegal characters, which the database will not
  // except. It returns 'boolean true' if it finds any illegal characters,
  // otherwise returns false.
  //
  public static boolean checkString (String fieldString) {
    // flag |~*\ illegal chars
    if (fieldString == null) {
      fieldString = "";
    }
    String nextChar = "";
    int textLength = fieldString.length();
    if (textLength > 0) {
      int i=0;
      int j=1;
      do {
        nextChar = fieldString.substring(i,j);
        if (nextChar.equals("|") || 
            nextChar.equals("~") || 
            nextChar.equals("*") ||
            nextChar.equals("\\")) {
          return true;
        } 
        i++;
        j++;
      } while (i < textLength);
    }

    return false;
  }
  
  //
  // This replaces any single quote ' in a string with two single quotes ''
  // e.g. 'it's over there' becomes 'it''s over there', it does not replace
  // two consecutive single quotes e.g 'it''s over there' stays 'it''s over there'
  // after cleaning.
  // It returns the ammended string if changes were made otherwise
  // returns the original string unchanged.
  //
  public static String cleanString (String fieldString) {
    // replace each single quote ' with two single quotes ''
    if (fieldString == null) {
      fieldString = "";
    }
    int quoteCount = 0;
    String nextChar = "";
    String outputString = "";
    int textLength = fieldString.length();
    if (textLength > 0) {
      int i=0;
      int j=1;
      do {
        nextChar = fieldString.substring(i,j);
        if (nextChar.equals("'")) {
          outputString = outputString + nextChar;
          quoteCount++;
        } else {
          if (quoteCount == 1) {
            outputString = outputString + "'" + nextChar;
          } else {
            outputString = outputString + nextChar;
          }
          quoteCount = 0;
        }
        i++;
        j++;
      } while (i < textLength);
    }
    
    return outputString.trim();   
  }
}
