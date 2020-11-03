package com.vsb;

import java.util.*;
import java.io.*;
import java.text.SimpleDateFormat;
import java.security.MessageDigest;

public class helperBean {
  // This method throws and Exception if the string passed in is not blank.
  // The Exception string is that supplied by the passed in string.
  public void throwException (String e) throws Exception {
    if (! e.trim().equals("")) {
      throw new Exception(e.trim());
    }
  }

  // This method throws and Exception if the second string passed in is not blank.
  // The Exception string is that supplied by the passed in string.
  public void throwException (String pre, String e) throws Exception {
    if (! e.trim().equals("")) {
      throw new Exception(pre.trim() + ": " + e.trim());
    }
  }

  // This method returns an occur_day format given a date. The format
  // of the occur_day string is "DDDDDDD" where "D" is
  // either "X" or "A" - "X" indicates a day of the week, "A" indicates
  // which day of the week the supplied due_date corresponds to.
  // The string returned represents a week (Monday to Sunday).
  public String getOccur_day (GregorianCalendar due_date) {
    String occurDay = "";
    // get the day of the week as an int from 1 to 7
    // 1 = Sunday, 7 = Saturday.
    int index = due_date.get(Calendar.DAY_OF_WEEK);
    // make the day of the week run from Monday to Sunday
    index = index - 1;
    if (index == 0) {
      index = 7;
    }
    // create the occur_day string Monday to Sunday
    for (int i=1; i <= 7; i++) {
      if (i == index) {
        occurDay = occurDay + "A";
      } else {
        occurDay = occurDay + "X";
      }
    }
    
    return occurDay;
  }
  
  // Return a Hex string of the MD5 for the value passed in.
  // NOTE: a linefeed (newline (\n)) character is appended to the
  // the end of passed in string.
  public String getPasswordMD5 (String password) throws Exception {
    MessageDigest md = MessageDigest.getInstance("MD5");
    
    // append a carriage return and newline (linefeed) character at the
    // end, as this is what will be in a file that the 
    // contender UTILS/putils.4gl:encrypt_string() function creates.
    // This will make sure that this java md5 hex hash will be the same as 
    // that outputted by the above contender function.
    String amessage = password + "\r\n";
  
    byte [] hash = md.digest(amessage.getBytes());
    //byte [] hash = md.digest(amessage.getBytes("UTF-8"));
  
    // Turns an array of bytes into a string representing each byte as
    // a two digit unsigned hex number.
    StringBuffer buf = new StringBuffer(hash.length * 2);
    for (int i=0; i<hash.length; i++){
      int intVal = hash[i] & 0xff;
      if (intVal < 0x10){
        // append a zero before a one digit hex
        // number to make it two digits.
        buf.append("0");
      }
      buf.append(Integer.toHexString(intVal));
    }

    return buf.toString();
  }

  // Check to see if a string is an integer, returns true if it
  // can, otherwise returns false.
  public boolean isStringInt (String num) {
    try {
      int test = Integer.parseInt(num);
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  // Check to see if a string is a double, returns true if it
  // can, otherwise returns false.
  public boolean isStringDouble (String num) {
    try {
      double test = (new Double(num)).doubleValue();
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  // This method returns the first part of a string where the words
  // in the string are seperated by white space
  public String firstName(String fullName) {
    StringTokenizer firstName = new StringTokenizer(fullName);
    String returnName = "";
    if (firstName.countTokens() >= 1) {
      returnName = firstName.nextToken();
    }
    return returnName;
  }
  
  
  // This method returns the second part of a string where the words
  // in the string are seperated by white space
  public String surname(String fullName) {
    StringTokenizer surname = new StringTokenizer(fullName);
    String returnName = "";
    if (surname.countTokens() >= 2) {
      surname.nextToken();
      returnName = surname.nextToken();
    }
    return returnName;
  }


  // This method returns a string restricted to a given length. If the string
  // is longer than the given length, then it will have the excess chopped off,
  // and the string "..." added to the end. The returned string will never be
  // longer than the length specified. Because the string "..." is added to a
  // string which is longer than the given length the given length cannot be
  // less than 4.
  public String restrict(String line, int len) {
    String retLine;
    // restricted length cannot be less than 4
    if (len < 4) {
      len = 4;
    }
    
    if (line.length() <= len) {
      retLine = line;
    } else {
      retLine = line.substring(0,len-3) + "...";
    } 
    return retLine;
  }

  // This method returns a string restricted to a given length. If the string
  // is longer than the given length, then it will have the excess chopped off,
  // the end of the string and the string "..." added to the begining. The 
  // returned string will never be longer than the length specified. Because 
  // the string "..." is added to a string which is longer than the given length
  // the given length cannot be less than 4.
  public String endRestrict(String line, int len) {
    String retLine;
    // restricted length cannot be less than 4
    if (len < 4) {
      len = 4;
    }
    
    if (line.length() <= len) {
      retLine = line;
    } else {
      retLine = "..." + line.substring(((line.length() - 4) - (len-3)));
    } 
    return retLine;
  }

  // This method takes two Strings and returns a String with the characters
  // that appear in both strings, discarding all others
  public String getMatchingChars( String first, String second ) {
    String matching  = "";
    char checkChar;
    // If the first string is longer than the second:
    if( first.length() >= second.length() ) {
      for( int i=0; i<first.length(); i++ ){
        checkChar = first.charAt(i);
	if( second.indexOf( checkChar ) >= 0 ) {		
          matching += (checkChar);
        }
      }
    // If the second string is longer than the first:      
    } else {
      for( int i=0; i<second.length(); i++ ){
        checkChar = second.charAt(i);
	if( first.indexOf( checkChar ) >= 0 ) {
          matching += (checkChar);
        }
      }          
    }
    return matching;
  }

  // Helper method to convert the before and after suffix
  // into a meaningful word, i.e. B => before
  public String getBefore_after( String before_after ) {
    String result = "";
    // Check for NULL!
    if( before_after==null ) { before_after = ""; }
    // Start converstion
    if( before_after.equals("B") || before_after.equals("b") ) {
      result = "before";
    }
    else if( before_after.equals("A") || before_after.equals("a") ) {
      result = "after";
    }
    else {
      result = "@";
    }
    return result;
  }
  
  // This method returns the full name of the day given a suffix
  // i.e. "MO" will return "MONDAY"
  public String getDay( String daySuffix ) {
    String day = "";
    if( daySuffix.equals("MO")) day = "MONDAY";
    else if( daySuffix.equals("TU")) day = "TUESDAY";
    else if( daySuffix.equals("WE")) day = "WEDNESDAY";
    else if( daySuffix.equals("TH")) day = "THURSDAY";
    else if( daySuffix.equals("FR")) day = "FRIDAY";
    else if( daySuffix.equals("SA")) day = "SATURDAY";
    else if( daySuffix.equals("SU")) day = "SUNDAY";
    else day = "";
    return day;
  }

  // This method returns the day number for a day suffix
  // i.e. "MO" will return "1"
  public String getDayNo( String daySuffix ) {
    String dayNo = "";
    if( daySuffix.equals("MO")) dayNo = "1";
    else if( daySuffix.equals("TU")) dayNo = "2";
    else if( daySuffix.equals("WE")) dayNo = "3";
    else if( daySuffix.equals("TH")) dayNo = "4";
    else if( daySuffix.equals("FR")) dayNo = "5";
    else if( daySuffix.equals("SA")) dayNo = "6";
    else if( daySuffix.equals("SU")) dayNo = "7";
    else dayNo = "";
    return dayNo;
  }

  // This method checks a given string to see if it is 
  // null or empty. Either case will return false. If
  // the string has a length, it will return true
  public boolean isValid( Object notValid ) {    
    boolean valid = false;
    String  temp  = (String)notValid;
    if( temp != null && !temp.trim().equals("") ){
      valid = true;
    }
    return valid;
  }

  // Opposite of the method above. Will return true
  // if the value is null or empty string, false if
  // the string has a length
  public boolean isNotValid( Object notValid ) {    
    boolean valid = true;
    String  temp  = (String)notValid;
    if( temp != null && !temp.trim().equals("") ){
      valid = false;
    }
    return valid;
  }
 
  // This method will take a string represented date of the form used in SimpleDateFormat  
  // and return true or false if it is a valid date for the represented SimpleDateFormat.
  public boolean isValidDateString(String dbDate, String db_date_fmt) {
    SimpleDateFormat dbFormatDate = new SimpleDateFormat(db_date_fmt);
    Date date = null;
    // Is the date in the right format
    try {
      // db date represented as a string (e.g. YYYY-MM-DD) to date
      date = dbFormatDate.parse(dbDate);
    } catch (Exception e) {
      return false;
    }

    // Is the date actually a valid date. SimpleDateFormat does not care it, just roles round values.
    // dateformat.parse will accept any date as long as it's in the format
    // you defined, it simply rolls dates over, for example, december 32
    // becomes jan 1 and december 0 becomes november 30
    // This statement will make sure that once the string
    // has been checked for proper formatting that the date is still the
    // date that was entered, if it's not, we assume that the date is invalid
    if(! dbFormatDate.format(date).equals(dbDate) ){
      return false;
    }

    // Yep this is a valid date
    return true;
  }


  public boolean isDateBeforeToday(String dbDate, String db_date_fmt) {
    SimpleDateFormat dbFormatDate = new SimpleDateFormat(db_date_fmt);
    Date date = null;
    // Is the date in the right format
    try {
      // db date represented as a string (e.g. YYYY-MM-DD) to date
      date = dbFormatDate.parse(dbDate);
    } catch (Exception e) {
      return true;
    }

    // Set the default time zone to where we are, as the time zone
    // returned from sco is GMT+00:00 which is fine but doesn't mentioned
    // BST. So the default timezone has to be set to "Europe/London".
    // Any objects which use the timezone (like SimpleDateFormat) will then
    // be using the correct timezone.
    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
    TimeZone.setDefault(dtz);
    Date currentDate = new java.util.Date();

    if (date.before(currentDate)) {
      return true;
    }

    return false;
  }


  public boolean isDateAfter(String dbDate, String db_date_fmt, int yearDelta) {
    SimpleDateFormat dbFormatDate = new SimpleDateFormat(db_date_fmt);
    Date date = null;
    // Is the date in the right format
    try {
      // db date represented as a string (e.g. YYYY-MM-DD) to date
      date = dbFormatDate.parse(dbDate);
    } catch (Exception e) {
      return true;
    }

    // Set the default time zone to where we are, as the time zone
    // returned from sco is GMT+00:00 which is fine but doesn't mentioned
    // BST. So the default timezone has to be set to "Europe/London".
    // Any objects which use the timezone (like SimpleDateFormat) will then
    // be using the correct timezone.
    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
    GregorianCalendar now = new GregorianCalendar(dtz);
    now.add(Calendar.YEAR, yearDelta);
    Date currentDate = now.getTime();

    if (date.after(currentDate)) {
      return true;
    }

    return false;
  }

 
  // This method returns a string with no blank spaces
  // i.e. "NLP 5XT" will return "NLP5XT"
  public String removeSpaces( String spacedString ) {
    String nextChar     = "";
    String outputString = "";
    int textLength = spacedString.length();
    if (textLength > 0) {
      int i=0;
      int j=1;
      do {
        nextChar = spacedString.substring(i,j);
        if (!nextChar.equals(" ")) {
          outputString = outputString + nextChar;
        }
        i++;
        j++;
      } while (i < textLength);
    }
    return outputString;
  }
  
  // This method will be used to display the dates returned from a database.
  // This method will take a string represented date of the form used in SimpleDateFormat  
  // and return it in a string represented date of the form used in SimpleDateFormat.
  // The db_date_fmt and view_date_fmt strings will probably be supplied as application
  // context parameters in the web.xml file.
  public String dispDate(String dbDate, String db_date_fmt, String view_date_fmt) {
    String dispDate;

    try {
      if (view_date_fmt.trim().equals("")) {
        // The view_date_fmt is not set so just use the the dbDate as the dispDate
        dispDate = dbDate;
      } else {
        // db date represented as a string (e.g. YYYY-MM-DD) to date
        SimpleDateFormat dbFormatDate = new SimpleDateFormat(db_date_fmt);
        Date date = dbFormatDate.parse(dbDate);
      
        // date to display representation string (e.g. DD/MM/YYY)
        SimpleDateFormat dispFormatDate = new SimpleDateFormat(view_date_fmt);
        dispDate = dispFormatDate.format(date);
      }
    } catch (java.text.ParseException pe) {
      dispDate = "";
    }

    // return reveresed date
    return dispDate.trim();
  }


  //
  // This replaces < and > with html safe &lt; and &gt;
  // to ensure data is displayed correctly in the pages.
  //
  // Used on a string when a value is retrieved from beans in the view, but
  // never in the bean itself or when setting a bean attribute as it will
  // result in incorrect values in the db. Be careful when using in
  // <input type=text /> etc as this may also result in the bean
  // holding the incorrect data. < > are displayed as literals in html
  // input controls, but not in <label>, <a>, <p>, etc.
  //
  public static String displayString (String fieldString)
  {
    if (fieldString == null)
    {
      fieldString = "";
    }

    String nextChar = "";
    String outputString = "";
    int textLength = fieldString.length();

    if (textLength > 0)
    {
      int i=0;
      int j=1;
      do
      {
        nextChar = fieldString.substring(i,j);
        if(nextChar.equals("<"))
        {
         	outputString = outputString + "&lt;";
        }
        else if(nextChar.equals(">"))
        {
         	outputString = outputString + "&gt;";
        }
        else
        {
          outputString = outputString + nextChar;
        }

        i++;
        j++;
      }

    	while (i < textLength);
  	}

    return outputString;
  }

  
  // This method runs the external command given to it. e.g.
  // String output[] = runCommand("ls -l");
  // will run the "ls -l" command and return the output.
  public String[] runCommand(String cmd) throws IOException {
    // set up list to capture command output lines
    ArrayList list = new ArrayList();

    // start command running
    Process proc = Runtime.getRuntime().exec(cmd);

    // get command's error output stream and
    // put a buffered reader input stream on it
    InputStream istr = proc.getErrorStream();
    BufferedReader br =
      new BufferedReader(new InputStreamReader(istr));

    // read output lines from command
    String str;
    while ((str = br.readLine()) != null)
      list.add(str);

    // wait for command to terminate
    try {
      proc.waitFor();
    }
    catch (InterruptedException e) {
      System.err.println("process was interrupted");
    }

    // check its exit value
    if (proc.exitValue() != 0)
      System.err.println("exit value was non-zero");

    // close stream
    br.close();

    // return list of strings to caller
    return (String[])list.toArray(new String[0]);
  }

  
  // This method runs the external command given to it along with an environment
  // supplied in a String array where each string has the form "name=value". e.g.
  //
  // //set up the environpment array with size 1
  // String[] envp;
  // envp = new String[1];
  // // get the current path
  // String output[] = helperBean.runCommand("echo $PATH");
  // //add /new/area to the front of the path
  // envp[0] = "PATH=/new/area:" + output[0];
  // //run the command with the new path variable.
  // String output[] = helperBean.runCommand("ls -l", envp);
  //
  // will run the "ls -l" command in the environment envp and return the output.
  public String[] runCommand(String cmd, String[] envp) throws IOException {
    // set up list to capture command output lines
    ArrayList list = new ArrayList();

    // start command running
    Process proc = Runtime.getRuntime().exec(cmd, envp);

    // get command's error output stream and
    // put a buffered reader input stream on it
    InputStream istr = proc.getErrorStream();
    BufferedReader br =
      new BufferedReader(new InputStreamReader(istr));

    // read output lines from command
    String str;
    while ((str = br.readLine()) != null)
      list.add(str);

    // wait for command to terminate
    try {
      proc.waitFor();
    }
    catch (InterruptedException e) {
      System.err.println("process was interrupted");
    }

    // check its exit value
    if (proc.exitValue() != 0)
      System.err.println("exit value was non-zero");

    // close stream
    br.close();

    // return list of strings to caller
    return (String[])list.toArray(new String[0]);
  }
  
  
  public static final double roundDouble(double d, int places) {
    return Math.round(d * Math.pow(10, (double) places)) / Math.pow(10,
          (double) places);
  }
  
  
  // This method returns the points for a default, using the defp3 algorithms.
  // The defp3 algorithms are given as arguments.
  public double getPoints(String defi_volume,
                          String si_i_volume, 
                          String task_unit_of_meas,
                          String defp3_std_pnts,
                          String defp3_fr_p_flag,
                          String defp3_d_u_o_m_flag,
                          String defp3_multip_p_flag,
                          String defp3_si_i_vol,
                          String defp3_fr_p,
                          String defp3_d_u_o_m,
                          String defp3_rounding,
                          String defp3_multip_p)
  {
    // setup the variables.
    double points = 0.00;
    double volume = 0.00;
    double unitOfMeasure = 0.00;
    
    // override the task unit of measure?
    if (defp3_d_u_o_m_flag.trim().equals("Y")) {
      unitOfMeasure = (new Double(defp3_d_u_o_m.trim())).doubleValue();
    } else {
      unitOfMeasure = (new Double(task_unit_of_meas.trim())).doubleValue();
    }
    
    // use the si_i volume instead of the defi default volume?
    if (defp3_si_i_vol.trim().equals("Y")) {
      volume = (new Double(si_i_volume.trim())).doubleValue();
    } else {
      volume = (new Double(defi_volume.trim())).doubleValue();
    }
    
    // go through each of the ways of calculating the points.
    if (defp3_std_pnts.trim().equals("Y")) {
      points = volume / unitOfMeasure;
    } else if (defp3_fr_p_flag.trim().equals("Y")) {
      points = (new Double(defp3_fr_p.trim())).doubleValue();
    } else {
      points = 0.00;
    }
    
    // use a multplier?
    if (defp3_multip_p_flag.trim().equals("Y")) {
      points = points * (new Double(defp3_multip_p.trim())).doubleValue();
    }
    
    return roundDouble(points, 2);
  }

  
  // This method returns the values for a default, using the defp3 algorithms.
  // The defp3 algorithms are given as arguments.
  public double getValue( String an_val_def_alg,
                          String db_date_fmt,
                          String start_date,
                          String priority,
                          String contract_value,
                          String defi_volume,
                          String si_i_volume, 
                          String ta_r_task_rate,
                          String task_unit_of_meas,
                          String defp3_std_cv,
                          String defp3_std_val,
                          String defp3_fr_v_flag,
                          String defp3_d_u_o_m_flag,
                          String defp3_d_ta_r_flag,
                          String defp3_multip_v_flag,
                          String defp3_si_i_vol,
                          String defp3_fr_v,
                          String defp3_d_u_o_m,
                          String defp3_d_ta_r,
                          String defp3_rounding,
                          String defp3_multip_v) throws java.text.ParseException
  {
    // setup the variables.
    double value = 0.00;
    double cont_value = (new Double(contract_value.trim())).doubleValue(); 
    double volume = 0.00;
    double taskRate = 0.00;
    double unitOfMeasure = 0.00;

    SimpleDateFormat dbFormatDate = new SimpleDateFormat(db_date_fmt);
    GregorianCalendar gregDate = new GregorianCalendar();
    Date date;
    int year;

    // override the task unit of measure?
    if (defp3_d_u_o_m_flag.trim().equals("Y")) {
      unitOfMeasure = (new Double(defp3_d_u_o_m.trim())).doubleValue();
    } else {
      unitOfMeasure = (new Double(task_unit_of_meas.trim())).doubleValue();
    }
    
    // override the task rate?
    if (defp3_d_ta_r_flag.trim().equals("Y")) {
      taskRate = (new Double(defp3_d_ta_r.trim())).doubleValue();
    } else {
      taskRate = (new Double(ta_r_task_rate.trim())).doubleValue();
    }
    
    // use the si_i volume instead of the defi default volume?
    if (defp3_si_i_vol.trim().equals("Y")) {
      volume = (new Double(si_i_volume.trim())).doubleValue();
    } else {
      volume = (new Double(defi_volume.trim())).doubleValue();
    }
    
    // go through each of the ways of calculating the value.
    if (an_val_def_alg.trim().equals("Y") && (priority.equals("A") || priority.equals("B"))) {
      // start date represented as a string (e.g. YYYY-MM-DD) to date, then get the year.
      date = dbFormatDate.parse(start_date);
      gregDate.setTime(date);
      year = gregDate.get(gregDate.YEAR);

      // Do the an_val_def_alg (Wandsworth) calculation
      value = cont_value / (new Double(365)).doubleValue();

    } else if (defp3_std_cv.trim().equals("Y")) {
      value = volume / taskRate;
    } else if (defp3_std_val.trim().equals("Y")) {
      value = volume / unitOfMeasure;
    } else if (defp3_fr_v_flag.trim().equals("Y")) {
      value = (new Double(defp3_fr_v.trim())).doubleValue();
    } else {
      value = 0.00;
    }
    
    // use a multplier?
    if (defp3_multip_v_flag.trim().equals("Y")) {
      // Don't use the multiplyer if we are using the an_val_def_alg (Wandsworth) calculation
      if (! an_val_def_alg.trim().equals("Y") ||
           (an_val_def_alg.trim().equals("Y") && ! priority.equals("A") && ! priority.equals("B")) ) {
        value = value * (new Double(defp3_multip_v.trim())).doubleValue();
      }
    }
    
    return roundDouble(value, 2);
  }
  
  
  // This method returns a list of short day of the week names e.g. Mon
  // when given a string in the si_i.occur_day format e.g. AXXBXXX where
  // any occurance of a letter other than "X" indicates that that day is
  // used, so in the example this would indicate Mon and Thu, so the 
  // method would output "Mon, Thu"
  public String occurDayNames(String occurDay) {
    int occurDayLength = occurDay.length() - 1;
    int dayOfWeek = 0;
    String[] dayOfWeekNames = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" };
    String dayNames = "";
    
    while (dayOfWeek <= occurDayLength) {
      if (occurDay.charAt(dayOfWeek) != 'X') {
        if (dayNames.equals("")) {
          dayNames = dayOfWeekNames[dayOfWeek];
        } else {
          dayNames = dayNames + ", " + dayOfWeekNames[dayOfWeek];
        }
      }
      dayOfWeek++;
    }
    
    return dayNames;
  }

  // Returns true if a string is a valid double
  public boolean isDouble( String s ) {
    boolean isDouble = false;
    try {
      double d = new Double(s).doubleValue();
      isDouble = true;
    } catch( NumberFormatException e ) {
      isDouble = false;
    }
    return isDouble;
  }

  // Returns an ArrayList containing the items that appear in the
  // comma separated string that is passed in.
  public ArrayList splitCommaList( String commaList ) {
    ArrayList splitList = new ArrayList();
    StringTokenizer st  = new StringTokenizer( commaList, "," );
    while (st.hasMoreTokens()) {
      String token = st.nextToken();
      // Check that the string is not blank
      if( token.trim() != "" ) {
        splitList.add( token.trim() );
      }
    }
    return splitList; 
  }


  // Returns an string containing the items that appear in the
  // comma separated string that is passed in, but surounded by quotes.
  public String quoteCommaList( String commaList ) {
    String quotedCommaList = "";
    StringTokenizer st  = new StringTokenizer( commaList, "," );
    while (st.hasMoreTokens()) {
      String token = st.nextToken();
      // Check that the string is not blank
      if( token.trim() != "" ) {
        if( quotedCommaList != "" ) {
          quotedCommaList = quotedCommaList + "," + "'" + token.trim() + "'";
        } else {
          quotedCommaList = "'" + token.trim() + "'";
        }
      }
    }
    return quotedCommaList; 
  }

}
