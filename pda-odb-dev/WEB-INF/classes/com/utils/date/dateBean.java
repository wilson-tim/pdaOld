package com.utils.date;

import java.util.Date;
import java.util.TimeZone;
import java.text.SimpleDateFormat;

public class dateBean{

  String date;
  String time;
  String time_h;
  String time_m;
  
  public dateBean( String db_date_fmt ){
    // Set the default time zone to where we are, as the time zone
    // returned from sco is GMT+00:00 which is fine but doesn't mentioned
    // BST. So the default timezone has to be set to "Europe/London".
    // Any objects which use the timezone (like SimpleDateFormat) will then
    // be using the correct timezone.
    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
    TimeZone.setDefault(dtz);
    SimpleDateFormat formatDate = new SimpleDateFormat( db_date_fmt );
    SimpleDateFormat formatTime = new SimpleDateFormat("HH:mm");
    SimpleDateFormat formatTime_h = new SimpleDateFormat("HH");
    SimpleDateFormat formatTime_m = new SimpleDateFormat("mm");
    Date currentDate = new java.util.Date();
    date = formatDate.format(currentDate);
    time = formatTime.format(currentDate);
    time_h = formatTime_h.format(currentDate);
    time_m = formatTime_m.format(currentDate);
  }

  public String getDate(){
    return date;
  }

  public String getTime_h(){
    return time_h;
  }

  public String getTime_m(){
    return time_m;
  }

}
