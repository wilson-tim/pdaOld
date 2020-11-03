package com.vsb;

import com.utils.compare.PipeComparator;
import com.db.DbUtils;
import java.util.ArrayList;
import java.util.Set;
import java.util.Iterator;
import java.util.TreeMap;

/**
 * This bean stores a representation of a survey, composed of blocks
 * of questions. Each question has a type, which effects the way it
 * is handled by the different methods in this class.
 *
 * Allowes types:
 *   YESNO   - 'Y'/'N' answer
 *   TEXT    - string answer
 *   NUMERIC - string with expected numeric representation. (Unchecked!)
 *   RADIO   - block of radio buttons
 *   CHECK   - checkbox block
 *
 * The main attribute of the class is the HashMap that stores pairs of
 * id's and questions
 *
 * Questions are represented by an ArrayList. Each member of the list
 * is a String[] that normally holds a single attribute of the question.
 * A question has the following attributes:
 *   ref       - the questions reference number within Contender
 *   text      - the actual question
 *   seq       - the questions sequence within the survey
 *   type      - the question type
 *   valid     - if the answer should be checked for basic validation
 *   answer    - the answer, or group of answers for the question
 *   comp_code - the fault code of the question
 *   dp        - the question this question depends upon. This has to be a
 *               yes/no type question
 *
 * Remember that all of these attributes are stored as String[] not String!
 * This is primarily to deal with the checkbox case where multiple values 
 * may be returned.
 */
public class recMonSurveyBean extends formBean {

  /**
   * HashMap that represents the survey as a group of ( question id,
   * question ) pairs. Having the question id allows you to get the
   * attributes and answers to a specific quesiton.
   */ 
  private PipeComparator pc = new PipeComparator();
  private TreeMap survey    = new TreeMap(pc);

  /**
   * Adds a question into the survey with all of its attributes.
   * The answer is initially set to blank.
   */
  public void addQuestion( String id,
                           String question_ref,
                           String question_text,
                           String question_seq,
                           String question_type,
                           String question_valid,
                           String question_comp_code,
                           String question_dp
                          ) {
     
     ArrayList question = new ArrayList(6);
     question.add(0, new String[]{ question_ref });
     question.add(1, new String[]{ question_text });
     question.add(2, new String[]{ question_seq });
     question.add(3, new String[]{ question_type });
     question.add(4, new String[]{ question_valid });
     question.add(5, new String[]{ question_comp_code });
     question.add(6, new String[]{ question_dp });
     question.add(7, new String[]{""});
     
     // Add the quesiton to the survey using the inputs id value
     // as the key
     survey.put( id, question );
  }

  /**
   * Returns the question including answer, in the form of an ArrayList
   * using the specific question id.
   */
  public ArrayList getQuestion( String id ){
    return (ArrayList)(survey.get( id ));
  }

  /**
   * Depricated by method below: Returns the set of keys in the survey
   */
  public Set getKeys(){
    return survey.keySet();
  }

  /**
   * Returns an Iterator of all the keys( i.e queston handles ) in
   * the survey.
   */
  public Iterator getKeyIterator(){
   return (survey.keySet()).iterator();
  }

  /**
  * Clear the answer for the specific quetsion
  */
  public void clearAnswer( String id ){
    ArrayList tempQ = (ArrayList)survey.get( id );
    String[] answer = new String[]{""};
    tempQ.add( 7, answer );
    survey.put( id, tempQ );
  }

  /**
  * Clear the answers for the whole survey
  */
  private void clearAnswers(){
    Iterator ids = getKeyIterator();
    while( ids.hasNext() ){
      String id = (String)ids.next();
      ArrayList tempQ = (ArrayList)survey.get( id );
      String[] answer = new String[]{""};
      tempQ.add( 7, answer );
      survey.put( id, tempQ );
    }
  }
  
  /**
   * Generic method that takes in a string array and stores it
   * in the specfic question specified by the id passed in. The
   * different sections are needed to treat the default answer
   * for each type of block in a different way. 
   * We are basically handling what happens when a null or blank
   * value is passed in as an answer.
   */
  public void addAnswer( String id, String[] answer ){
    ArrayList tempQ = (ArrayList)survey.get( id );
    // Assume null or blank is No, anything else set it to Yes
    if( getQuestion_type( id ).equals("YESNO") )
    {
      String tempAnswer = answer[0];
      if( tempAnswer == null || tempAnswer.equals("") ){
        answer[0] = "N";
      } else {
        answer[0] = "Y";
      }
    }
    // Assume that a null value is a blank string
    else if( getQuestion_type( id ).equals("TEXT") )
    {
      String tempAnswer = answer[0];
      if( tempAnswer == null ){
        answer[0] = "";
      }
    }
    // Assume that a null or blank value is 0
    else if( getQuestion_type( id ).equals("NUMBER") )
    {
      String tempAnswer = answer[0];
      if( tempAnswer == null || tempAnswer.equals("") ){
        answer[0] = "0";
      }
    }
    // Assume null value is blank string, no value selected
    // Example: This default will not pass validation if
    // validation is set to Y.
    else if( getQuestion_type( id ).equals("RADIO") ){
      String tempAnswer = answer[0];
      if( tempAnswer == null ){
        answer[0] = "";
      }
    }
    // Assume a null value, or array length of 0 means no
    // value was selected in the checkbox block
    else if( getQuestion_type( id ).equals("CHECK") ){
      if( answer == null || answer.length == 0 ){
        answer = new String[]{""};
      }
    }
    // Add the answer to the question. Overwrite the previous
    // answer
    tempQ.add( 7, answer );
    survey.put( id, tempQ );
  }

  /**
  * Returns the questions reference number given the question id
  */
  public String getQuestion_ref( String id ){
    ArrayList temp = (ArrayList)survey.get( id );
    String[] tempStringArray = (String[])temp.get(0);
    return tempStringArray[0];
  }
  /**
  * Returns the question given the question id
  */
  public String getQuestion_text( String id ){
    ArrayList temp = (ArrayList)survey.get( id );
    String[] tempStringArray = (String[])temp.get(1);
    return tempStringArray[0];
  }
  /**
  * Returns the questions sequence number given the question id
  */
  public String getQuestion_seq( String id ){
    ArrayList temp = (ArrayList)survey.get( id );
    String[] tempStringArray = (String[])temp.get(2);
    return tempStringArray[0];
  }
  /**
  * Returns the questions type given the question id
  */
  public String getQuestion_type( String id ){
    ArrayList temp = (ArrayList)survey.get( id );
    String[] tempStringArray = (String[])temp.get(3);
    return tempStringArray[0];
  }
  /**
  * Returns Y/N if the question should be validated
  */
  public String getQuestion_valid( String id ){
    ArrayList temp = (ArrayList)survey.get( id );
    String[] tempStringArray = (String[])temp.get(4);
    return tempStringArray[0];
  }
  /**
  * Returns the fault code of this question
  */
  public String getQuestion_comp_code( String id ){
    ArrayList temp = (ArrayList)survey.get( id );
    String[] tempStringArray = (String[])temp.get(5);
    return tempStringArray[0];
  }
  /**
  * Returns the number this question depends on
  */
  public String getQuestion_dp( String id ){
    ArrayList temp = (ArrayList)survey.get( id );
    String[] tempStringArray = (String[])temp.get(6);
    return tempStringArray[0];
  }
  /**
  * Returns the array of answers for this question id. The
  * array returned will normaly have a single entry, but a
  * checkbox may have several.
  */
  public String[] getAnswer( String id ){
    ArrayList temp = (ArrayList)survey.get( id );
    return (String[])(temp.get(7));
  }

  /**
  * Required by bean framework
  */
  public String getAll() {
    return "";
  }

  /**
  * Required by bean framework
  */
  public void setAll(String all) {
    if( all.equals("clear")){
      survey = new TreeMap(pc);
    }else if(all.equals("clear_answers")){
      clearAnswers();
    }
  }

  /**
  * Used for debugging. Prints out all the questions
  * and answers stored in this bean.
  */
  public void print(){
    System.out.println("Printing Questions . . .");
    Iterator i = getKeyIterator();
    while( i.hasNext() ){
      String id = (String)i.next();
      System.out.print("Q:" + id);
      System.out.print("|" + getQuestion_ref( id ) );
      System.out.print("|" + getQuestion_text( id ) );
      System.out.print("|" + getQuestion_seq( id ) );
      System.out.print("|" + getQuestion_type( id ) );
      System.out.print("|" + getQuestion_comp_code( id ) );
      System.out.print("|" + getQuestion_dp( id ) );
      System.out.println("|" + getQuestion_valid( id ) );
      String[] tempAnswers = getAnswer( id );
      System.out.print("A:");
      for( int j=0; j< tempAnswers.length; j++ ){
        System.out.print("|" + tempAnswers[j] );
      }
      System.out.println("| END");
    }
  }
  
  /**
   * Used for debugging. Prints out all the questions
   * and answers stored in this bean.
   */
  public void printQuestions(){
    System.out.println("Printing Questions . . .");
    Iterator i = getKeyIterator();
    while( i.hasNext() ){
      String id = (String)i.next();
      ArrayList question = (ArrayList)survey.get( id );
      System.out.print("| " + id );
      for( int j=0; j<question.size(); j++ ){
        String[] temp = (String[])question.get(j);
        for( int k=0; k<temp.length; k++ ){
          String tempString = temp[k];
          System.out.print(" | " + tempString );
        }
      }
      System.out.println(" | end of q!");
    }
  }

  /**
   * Runs a simple validation check based on the type of block
   * being validated, which is determined by the id passed in.
   * If the validation flag is set, then each block has its own
   * validation check that is run.
   */
  public boolean isValid( String id ){
    ArrayList question = (ArrayList)survey.get( id );
    boolean valid = false;
    if( getQuestion_valid( id ).equals("Y") ){
      /**
       * YESNO block is always valid as the answer can be either
       * yes or no.
       */
      if( getQuestion_type(id).equals("YESNO"))
      {
        valid = true;
      }
      /**
       * TEXT needs to have a value to return true i.e. blank and
       * null values are not valid. We know there are no nulls in
       * the answer by the way the answers are added to the array
       * see addAnswer() above!
       */
      else if( getQuestion_type(id).equals("TEXT"))
      {
        String[] answers = getAnswer( id );
        String answer = answers[0];
        if( answer.equals("") )
        {
          valid = false;
        }
        else
        {
          valid = true;
        }
      }
      /**
       * Same as the TEXT, NUMBER needs to have a value that is not
       * 0 to be valid.
       */
      else if( getQuestion_type(id).equals("NUMBER"))
      {
        String[] answers = getAnswer( id );
        String answer = answers[0];
        if( answer.equals("0") )
        {
          valid = false;
        }
        else
        {
          valid = true;
        }
      }
      /**
       * Needs to have a value selected, therefore the answer text
       * can not be null or blank.
       */
      else if( getQuestion_type(id).equals("RADIO"))
      {
        String[] answers = getAnswer( id );
        String answer = answers[0];
        if( answer.equals("") )
        {
          valid = false;
        }
        else
        {
          valid = true;
        }
      }
      /**
       * There needs to be atleast one checkbox ticked for the block
       * to be valid. We can check this by seeing that the first answer
       * in the question in not blank or null.
       */
      else if( getQuestion_type(id).equals("CHECK"))
      {
        String[] answers = getAnswer( id );
        String answer = answers[0];
        if( answer.equals("") )
        {
          valid = false;
        }
        else
        {
          valid = true;
        }
      }
    }
    else
    {
      //Validation is set to 'N' so return true
      valid = true;
    }
    return valid;
  }

  /**
   * Check to see if the question is dependent on any other
   * question, and if so make sure that the question is set
   * to yes.
   */
  public boolean checkDependancy( String id ){
    // Assume the dependancy check fails
    boolean isDependancyCheckOK = false;
    // Get the dependancy of the question being checked
    String dp = getQuestion_dp( id ).trim();
    // If there is a value in the dp field check if it is blank
    if( dp == null || dp.equals("") ){
      // If it is clear the dependancy check
      isDependancyCheckOK = true;
    }
    else
    {
      // Get the answer for the question this question is dependant on
      // Reconstruct the id of the question first
      String dp_id = getQuestion_comp_code( id ) + "|" + dp;
      // Get the answer of the dependant question
      String dp_answer = getSingleAnswer( dp_id );
      // If the answer is 'Y' then we can clear the dependancy check
      if( dp_answer.equals("Y") ){
        isDependancyCheckOK = true;
      }
      // Otherwise we should leave the value false and fail the 
      // dependancy check
    }    
    return isDependancyCheckOK;
  }

  /**
   * Method to check if there is an answer in the specific question
   */
  public boolean hasAnswer( String id ){
    boolean hasAnswer = false;
    String temp_answer = getSingleAnswer( id );
    if( temp_answer == null || temp_answer.equals("") || temp_answer.equals("0") || temp_answer.equals("N"))
    {
      hasAnswer = false;
    }
    else
    {
      hasAnswer = true;
    }
    return hasAnswer;
  }

  public boolean hasValidation( String id ){
    boolean hasValidation = false;
    String validFlag = getQuestion_valid( id );
    if( validFlag.equals("Y") ){
      hasValidation = true;
    }
    return hasValidation;    
  }

  /**
   * Used to re-populate the view. Returns true if a standalone
   * checkbox was checked i.e. 'Y' and false if it was set to
   * no ro unchecked.
   */
  public boolean isYesNoChecked( String id ){
    boolean valid = false;
    String[] temp = getAnswer( id );
    String answer = temp[0];
    if( answer.equals("Y") ){
      valid = true;
    }
    return valid;
  }

  /**
   * Used to re-populate both NUMBER and TEXT fields, as they
   * both work the same way. Return whatever value is in the
   * questions answer array.
   */
  public String getSingleAnswer( String id ){
    String[] temp = getAnswer( id );
    String answer = temp[0];
    return answer;
  }

  /**
   * Used to re-populate radio buttons in the view. If the
   * question does have an answer, that answer should be
   * checked in the view. Returns true if the string is
   * matched with the current answer
   */
  public boolean isRadioChecked( String id, String text ){
    boolean valid = false;
    String[] temp = getAnswer( id );
    String answer = temp[0];
    if( answer.equals(text) ){
      valid = true;
    }
    return valid;
  }
  
  /**
   *  Used to re-populate the view. Checks to see if a specific
   *  answer was selected in a checkbox list. If the string
   *  is in the answers, then the checkbox answer on the form
   *  should be checked. 
   */
  public boolean isChecked( String id, String text ){
    boolean valid = false;
    String[] temp = getAnswer( id );
    for( int i=0; i<temp.length; i++ ){
      String answer = temp[i];
      if( answer.equals(text) ){
        valid = true;
      }
    }
    return valid;
  }

  /**
   * Returns the number of questions in the survey
   */
  public int size(){
    return survey.size();
  }
  
}
