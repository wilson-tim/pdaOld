package com.utils.soundex;

/******************************************************************************
 * Class that implements a version of the Brute Force Algorithm. The          *
 * algorithm below will return true if the two strings are an exact match of  *
 * each other in their uppercase form. Both strings will be matched for the   *
 * same number of characters, as either string that is longer than the other  *
 * will be cropped.                                                           *
 *                                                                           */
public class BFMatch{

  private String q;      // Holds query string
  private String temp;   // Holds the string being matched
  
  private char qChar;    // Used for individual  character containers
  private char tempChar; // for the given input strings
  
  private boolean exactMatch; // Final value returned by algorithm
  
  private int k;            // Counter
  private int inputLength;  // The length of the query String
  
  // Constructor method initialises object
  public BFMatch(){
    q    = "";
    temp = "";
    k    = 0;
    inputLength = 0;
    exactMatch  = true;
  }

  /********************************************************
   *  Method that returns true if temp is an exact match  *
   *  of q. Note that this crop is one way, as the class  *
   *  is assuming that the other crop has been done       *
   *  already. In the future, both crops should be done   *
   *  in this class.                                      *
   *                                                     */
  public boolean match(String qMatch, String tempMatch){
    q     = qMatch.toUpperCase();
    temp  = tempMatch;
    k     = 0;    
    inputLength = q.length();     
    exactMatch  = true;
    // Ensure that the string we are matching is as long as q,
    // otherwise crop q
    if(temp.length() < inputLength ){
        exactMatch = false;
    }
    // Check for an exact match for the whole length of q
    while( exactMatch && (k < q.length()) ){ 
      qChar    = q.charAt(k);
      tempChar = temp.charAt(k);
      if( qChar != tempChar ){
        exactMatch = false;
      }
      k++;
    }
    return exactMatch;
  }
  
}
