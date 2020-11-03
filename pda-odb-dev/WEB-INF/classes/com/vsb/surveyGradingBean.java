package com.vsb;

import com.db.DbUtils;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;
import java.util.Iterator;
import java.util.StringTokenizer;
import java.util.Collection;

public class surveyGradingBean extends formBean {

  // The flags to indicate if a default should be raised
  // for a given item on the BV199 survey
  private HashMap gradingFlags  = new HashMap();
  // Grades translation map
  private HashMap grades        = new HashMap();
  // Codes translation map
  private HashMap codes         = new HashMap();
  // List of all the grades that should raise a default for Litter
  private ArrayList litter_list = new ArrayList();
  // List of all the grades that should raise a default for Detritus
  private ArrayList detrit_list = new ArrayList();
  // List of all the grades that should raise a default for Graffiti
  private ArrayList grafft_list = new ArrayList();
  // List of all the grades that should raise a default for Fly posting
  private ArrayList flypos_list = new ArrayList();
        
	private String litter_grade = "";
	private String detritus_grade = "";
	private String graffiti_grade = "";
	private String flyposting_grade = "";
	private String litter_text = "";
	private String detritus_text = "";
	private String graffiti_text = "";
	private String flyposting_text = "";

  // Printout method for debugging
  public void print(){
    System.out.println("#######--Start Grading Bean Debug--######");
    Set keys = gradingFlags.keySet();
    Iterator keysI = keys.iterator();
    System.out.println("#######---KEYS---#######");
    while( keysI.hasNext() ){
     String key = (String)keysI.next();
     System.out.println( key );
    }
    Collection values = gradingFlags.values();
    Iterator valuesI = values.iterator();
    System.out.println("#######---VALUES---#######");
    while( valuesI.hasNext() ){
      String value = (String)valuesI.next();
      System.out.println( value );
    }
    System.out.println("Is Any Flag Set: " + isAnyFlagSet() + ".");
    System.out.println("Last Set Item: " + getLastSetItem() + ".");
    System.out.println("Litter List:");
    for( int i=0; i<litter_list.size(); i++ ){
      System.out.println( litter_list.get(i) );
    }
    System.out.println("Detritus List:");
    for( int i=0; i<detrit_list.size(); i++ ){
      System.out.println( detrit_list.get(i) );
    }
    System.out.println("Graffiti List:");
    for( int i=0; i<grafft_list.size(); i++ ){
      System.out.println( grafft_list.get(i) );
    }
    System.out.println("Fly Posting List:");
    for( int i=0; i<flypos_list.size(); i++ ){
      System.out.println( flypos_list.get(i) );
    }
    System.out.println("#######--End Grading Bean Debug--######");
  }
  
  // Adds a grade translation to the map
  public void addGrade( String lookup_text, String lookup_code ){
    grades.put( lookup_text, lookup_code );
  }

  // Adds a code translation to the map
  public void addCode( String lookup_text, String lookup_code ){
    codes.put( lookup_code, lookup_text );
  }

  // Generic method to set the array list from a string of comma seperated grades
  public void setList( ArrayList arrayList, String list ){
    // Tokenise the string using a ',' delimeter and add items to the arraylist
    StringTokenizer st = new StringTokenizer( list, "," );
    while( st.hasMoreTokens() ){
      String gradeLetter = st.nextToken().trim();
      String gradeCode = (String)grades.get( gradeLetter ); 
      arrayList.add( gradeCode );
    }
  }

  // Method to return true if any of the flags are set to 'Y'
  public boolean isAnyFlagSet(){
    return gradingFlags.containsValue("Y");
  }

  // Method to return true if any of the flags are set to 'A'
  // i.e. they have already been defaulted
  public boolean isAnyFlagDefaulted(){
    return gradingFlags.containsValue("A");
  }  

  // Method to set a flag using the key only
  public void setFlag( String key, String flag ){
    gradingFlags.put( key, flag );
  }

  // Methods returns the last key that has a flag set to 'Y'
  public String getLastSetItem(){
    Set keySet    = gradingFlags.keySet();
    Iterator i    = keySet.iterator();
    String setKey = "";
    while( i.hasNext() ){
      String key  = (String)i.next();
      String flag = (String)gradingFlags.get( key );
      if( flag.equals("Y") ){
        setKey = key;
      }
    }
    return setKey;
  }

  // Getter/Setter methods for the flags of each item in the BV199
  // Also added an 'is' method to return a boolean depending on 
  // the flag being set to Y/N
  // LITTER
  public void setLitter_flag( String flag ){
    gradingFlags.put("LITTER", flag);
  }
  public String getLitter_flag(){
    return (String)gradingFlags.get("LITTER");
  }
  public String getLitter_code(){
    return (String)codes.get( litter_grade );
  }
  public boolean isLitter_flag(){
    boolean flag = false;
    if( ((String)gradingFlags.get("LITTER")).trim().equals("Y") ){
      flag = true;
    }
    return flag;
  }
  public boolean isLitter_defaulted(){
    boolean flag = false;
    if( ((String)gradingFlags.get("LITTER")).trim().equals("A") ){
      flag = true;
    }
    return flag;
  }
  // DETRITUS
  public void setDetrit_flag( String flag ){
    gradingFlags.put("DETRIT", flag);
  }
  public String getDetrit_flag(){
    return (String)gradingFlags.get("DETRIT");
  }
  public String getDetrit_code(){
    return (String)codes.get( detritus_grade );
  }
  public boolean isDetrit_flag(){
    boolean flag = false;
    if( ((String)gradingFlags.get("DETRIT")).trim().equals("Y") ){
      flag = true;
    }
    return flag;
  }
  public boolean isDetrit_defaulted(){
    boolean flag = false;
    if( ((String)gradingFlags.get("DETRIT")).trim().equals("A") ){
      flag = true;
    }
    return flag;
  }
  // GRAFFITI
  public void setGrafft_flag( String flag ){
    gradingFlags.put("GRAFF", flag);
  }
  public String getGrafft_flag(){
    return (String)gradingFlags.get("GRAFF");
  }
  public String getGrafft_code(){
    return (String)codes.get( graffiti_grade );
  }
  public boolean isGrafft_flag(){
    boolean flag = false;
    if( ((String)gradingFlags.get("GRAFF")).trim().equals("Y") ){
      flag = true;
    }
    return flag;
  }
  public boolean isGrafft_defaulted(){
    boolean flag = false;
    if( ((String)gradingFlags.get("GRAFF")).trim().equals("A") ){
      flag = true;
    }
    return flag;
  }
  // FLY POSTING
  public void setFlypos_flag( String flag ){
    gradingFlags.put("FLYPOS", flag);
  }
  public String getFlypos_flag(){
    return (String)gradingFlags.get("FLYPOS");
  }
  public String getFlypos_code(){
    return (String)codes.get( flyposting_grade );
  }
  public boolean isFlypos_flag(){
    boolean flag = false;
    if( ((String)gradingFlags.get("FLYPOS")).trim().equals("Y") ){
      flag = true;
    }
    return flag;
  }
  public boolean isFlypos_defaulted(){
    boolean flag = false;
    if( ((String)gradingFlags.get("FLYPOS")).trim().equals("A") ){
      flag = true;
    }
    return flag;
  }
  
  // Methods to set the grading lists for each of the items in the BV199
  // and then given a grade will return a boolean depending on whether 
  // the grade is in the list of grades or not
  // LITTER
  public void setLitter_list( String list ){
    setList( litter_list, list );
  }
  public boolean isGrade_in_litter_list( String grade ){
    return litter_list.contains( grade );
  }
  // DETRITUS
  public void setDetrit_list( String list ){
    setList( detrit_list, list );
  }
  public boolean isGrade_in_detrit_list( String grade ){
    return detrit_list.contains( grade );
  }
  // GRAFFITI
  public void setGrafft_list( String list ){
    setList( grafft_list, list );
  }
  public boolean isGrade_in_grafft_list( String grade ){
    return grafft_list.contains( grade );
  }
  // FLY POSTING
  public void setFlypos_list( String list ){
    setList( flypos_list, list );
  }
  public boolean isGrade_in_flypos_list( String grade ){
    return flypos_list.contains( grade );
  }  
  
  public String getLitter_grade() {
    return litter_grade;
  }
  public void setLitter_grade(String litter_grade) {
    this.litter_grade = DbUtils.cleanString(litter_grade);
  }
    public String getLitter_text() {
    return litter_text;
  }
  public void setLitter_text(String litter_text) {
    this.litter_text = DbUtils.cleanString(litter_text);
  }

    public String getDetritus_grade() {
    return detritus_grade;
  }
  public void setDetritus_grade(String detritus_grade) {
    this.detritus_grade = DbUtils.cleanString(detritus_grade);
  }
    public String getDetritus_text() {
    return detritus_text;
  }
  public void setDetritus_text(String detritus_text) {
    this.detritus_text = DbUtils.cleanString(detritus_text);
  }

    public String getGraffiti_grade() {
    return graffiti_grade;
  }
  public void setGraffiti_grade(String graffiti_grade) {
    this.graffiti_grade = DbUtils.cleanString(graffiti_grade);
  }
    public String getGraffiti_text() {
    return graffiti_text;
  }
  public void setGraffiti_text(String graffiti_text) {
    this.graffiti_text = DbUtils.cleanString(graffiti_text);
  }

    public String getFlyposting_grade() {
    return flyposting_grade;
  }
  public void setFlyposting_grade(String flyposting_grade) {
    this.flyposting_grade = DbUtils.cleanString(flyposting_grade);
  }
    public String getFlyposting_text() {
    return flyposting_text;
  }
  public void setFlyposting_text(String flyposting_text) {
    this.flyposting_text = DbUtils.cleanString(flyposting_text);
  }

  public String getAll() {
    return "";
  }


  // Clear all lists and set all flags to 'N'
  public void setAll(String all) {
    // Clear the whole bean
    if( all.equals("bean") ){
      grades       = new HashMap();
      codes        = new HashMap();
      litter_list  = new ArrayList();
      detrit_list  = new ArrayList();
      grafft_list  = new ArrayList();
      flypos_list  = new ArrayList();
      gradingFlags = new HashMap();
      gradingFlags.put("LITTER", "N" );
      gradingFlags.put("DETRIT", "N" );
      gradingFlags.put("GRAFF", "N" );
      gradingFlags.put("FLYPOS", "N" );
      litter_grade     = "";
      detritus_grade   = "";
      graffiti_grade   = "";
      flyposting_grade = "";
      litter_text      = "";
      detritus_text    = "";
      graffiti_text    = "";
      flyposting_text  = "";
    }
    // Clear the form variables
    if( all.equals("clear") ){
      litter_grade     = "";
      detritus_grade   = "";
      graffiti_grade   = "";
      flyposting_grade = "";
      litter_text      = "";
      detritus_text    = "";
      graffiti_text    = "";
      flyposting_text  = "";
    }
  }
  
}
