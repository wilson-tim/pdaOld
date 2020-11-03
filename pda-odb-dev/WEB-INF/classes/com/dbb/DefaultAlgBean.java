package com.dbb;

import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Calendar;
import java.util.TimeZone;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import com.db.DbQueryHandler;


public class DefaultAlgBean {

  private DbQueryHandler dbHandle;
  private String db_date_fmt;
  
  // Blank constructor
  public DefaultAlgBean() {
    dbHandle     = null;
    db_date_fmt  = "";
  }

  public GregorianCalendar get_correct_by_dates(String defp4_time_delay,
                                                       String defp4_report_by_hrs1,
                                                       String defp4_report_by_mins1,
                                                       String defp4_report_by_hrs2,
                                                       String defp4_report_by_mins2,
                                                       String defp4_report_by_hrs3,
                                                       String defp4_report_by_mins3,
                                                       String defp4_correct_by_hrs1,
                                                       String defp4_correct_by_mins1,
                                                       String defp4_correct_by_hrs2,
                                                       String defp4_correct_by_mins2,
                                                       String defp4_correct_by_hrs3,
                                                       String defp4_correct_by_mins3,
                                                       String defp4_working_week,
                                                       String defp4_clock_start_hrs,
                                                       String defp4_clock_start_mins,
                                                       String defp4_clock_stop_hrs,
                                                       String defp4_clock_stop_mins,
                                                       String defp4_cut_off_hrs,
                                                       String defp4_cut_off_mins,
                                                       String db_date_fmt,
                                                       DbQueryHandler dbHandle) throws Exception
  {

    // Initialise the Database Connection
    this.dbHandle    = dbHandle;
    this.db_date_fmt = db_date_fmt;
    // There are three methods by which a user may specify the way they
    // wish to calculate the time for a default's rectify date.
  
    //
    // METHOD 1:
    // only defp4_time_delay used
    //
    if ( (defp4_report_by_hrs1.trim().equals("")  ||
          defp4_report_by_mins1.trim().equals("") ||
          defp4_correct_by_hrs1.trim().equals("") ||
          defp4_correct_by_mins1.trim().equals(""))
      &&
      (defp4_clock_start_hrs.trim().equals("")  ||
       defp4_clock_start_mins.trim().equals("") ||
       defp4_clock_stop_hrs.trim().equals("")   ||
       defp4_clock_stop_mins.trim().equals("")) )
    {
      // setup the date that the default was raised
      TimeZone dtz = TimeZone.getTimeZone("Europe/London");
      GregorianCalendar rectify_date = new GregorianCalendar(dtz);

      // OLD SECTION TO BE REINSTATED WHEN CONTENDER FIXED
      // defp4_time_delay is a string of hours in decimal
      // e.g. 1.50 = 1hr 30 mins
      // get the time delay in minutes
      //Double dtemp = new Double(defp4_time_delay);
      //int time_delay_mins = (int)(dtemp.doubleValue() * 60);

      // NEW SECTION TO BE USED UNTIL CONTENDER IS FIXED
      // defp4_time_delay is a string of hours followed by mins
      // e.g. 1.50 = 1hr 50 mins, the mins section can go up to 99 mins
      // get the time delay in minutes
      int len = defp4_time_delay.length();
      // get the mins section of the string
      String tempMins = defp4_time_delay.substring(len - 2);
      int itempMins = Integer.parseInt(tempMins.trim());
      // get the hours section of the string
      String tempHours = defp4_time_delay.substring(0, len - 3);
      int itempHours = Integer.parseInt(tempHours.trim());
      int time_delay_mins = (itempHours * 60) + itempMins;
      // Check if today is an exclusion day, and if it is zero the time
      if(is_exclusion_day( rectify_date )) {
        rectify_date.set(rectify_date.HOUR_OF_DAY, 0);
        rectify_date.set(rectify_date.MINUTE, 0);
      }
      int rem;
      
      // loop through the time delay a minute or hour at a time
      while (time_delay_mins > 0) {
        rem = (int) Math.IEEEremainder(time_delay_mins, 60);
        if (rem == 0 ) {
          // looping by hour
          time_delay_mins = time_delay_mins - 60;
          rectify_date.add(Calendar.HOUR_OF_DAY, 1);
        } else {
          // looping by minute
          time_delay_mins = time_delay_mins - 1;
          rectify_date.add(Calendar.MINUTE, 1);
        }
        
        // Check to see if the day is a working day or not
        if (!is_working_day(rectify_date, defp4_working_week))
        {
          // jump a day (24hrs) forward as the current day is not a working day
          
          // add back what we just took off, as we are now adding a day.
          if (rem == 0 ) {
            // looping by hour
            rectify_date.add(Calendar.HOUR_OF_DAY, -1);
            time_delay_mins = time_delay_mins + 60;
          } else {
            // looping by minute
            rectify_date.add(Calendar.MINUTE, -1);
            time_delay_mins = time_delay_mins + 1;
          }

          rectify_date.add(Calendar.DATE, 1);
        }
      }
      
      return rectify_date;
    }
    
    
    
    //
    // METHOD 2:
    // defp4_time_delay, defp4_clock_start/stop, defp4_cut_off used
    //
    if ( (defp4_report_by_hrs1.trim().equals("")  ||
          defp4_report_by_mins1.trim().equals("") ||
          defp4_correct_by_hrs1.trim().equals("") ||
          defp4_correct_by_mins1.trim().equals(""))
      &&
      ( !defp4_clock_start_hrs.trim().equals("")  &&
        !defp4_clock_start_mins.trim().equals("") &&
        !defp4_clock_stop_hrs.trim().equals("")   &&
        !defp4_clock_stop_mins.trim().equals("")) )
    {
      // setup the date that the default was raised
      TimeZone dtz = TimeZone.getTimeZone("Europe/London");
      GregorianCalendar rectify_date = new GregorianCalendar(dtz);

      // OLD SECTION TO BE REINSTATED WHEN CONTENDER FIXED
      // defp4_time_delay is a string of hours in decimal
      // e.g. 1.50 = 1hr 30 mins
      // get the time delay in minutes
      //Double dtemp = new Double(defp4_time_delay);
      //int time_delay_mins = (int)(dtemp.doubleValue() * 60);

      // NEW SECTION TO BE USED UNTIL CONTENDER IS FIXED
      // defp4_time_delay is a string of hours followed by mins
      // e.g. 1.50 = 1hr 50 mins, the mins section can go up to 99 mins
      // get the time delay in minutes
      int len = defp4_time_delay.length();
      // get the mins section of the string
      String tempMins = defp4_time_delay.substring(len - 2);
      int itempMins = Integer.parseInt(tempMins.trim());
      // get the hours section of the string
      String tempHours = defp4_time_delay.substring(0, len - 3);
      int itempHours = Integer.parseInt(tempHours.trim());
      int time_delay_mins = (itempHours * 60) + itempMins;
      // remember the defp4_time_delay (in mins) for the cutoff time calculation
      int defp4_time_delay_in_mins = time_delay_mins;
      // Check if today is an exclusion day, and if it is set to the start time
      if(is_exclusion_day( rectify_date )) {
        rectify_date.set(rectify_date.HOUR_OF_DAY, Integer.parseInt(defp4_clock_start_hrs));
        rectify_date.set(rectify_date.MINUTE, Integer.parseInt(defp4_clock_start_mins));
      }      
      int rem;
      
      //
      // defp4_time_delay, defp4_clock_start/stop used
      //
    
      // loop through the time delay a minute or hour at a time
      while (time_delay_mins > 0) {
        SimpleDateFormat formatRecDate = new SimpleDateFormat("dd-MM-yyyy HH:mm");    
        Date tmpDate  = rectify_date.getTime();
        String recDate = formatRecDate.format( tmpDate );
        rem = (int) Math.IEEEremainder(time_delay_mins, 60);
        if (rem == 0 ) {
          // looping by hour
          time_delay_mins = time_delay_mins - 60;
          rectify_date.add(Calendar.HOUR_OF_DAY, 1);
        } else {
          // looping by minute
          time_delay_mins = time_delay_mins - 1;
          rectify_date.add(Calendar.MINUTE, 1);
        }
        
        // Check to see if the day is a working day or not
        if (!is_working_day(rectify_date, defp4_working_week))
        {
          // jump a day (24hrs) forward as the current day is not a working day
          
          // add back what we just took off, as we are now adding a day.
          if (rem == 0 ) {
            // looping by hour
            rectify_date.add(Calendar.HOUR_OF_DAY, -1);
            time_delay_mins = time_delay_mins + 60;
          } else {
            // looping by minute
            rectify_date.add(Calendar.MINUTE, -1);
            time_delay_mins = time_delay_mins + 1;
          }            

          rectify_date.add(Calendar.DATE, 1);
        }
        else if ( after(rectify_date, defp4_clock_stop_hrs, defp4_clock_stop_mins) )
        {
          // jump forward to the defp4_clock_start time as the current time is after
          // the defp4_clock_stop time and before the defp4_clock_start time
          
          // add back what we just took off, as we are now jumping to the clock_start time.
          if (rem == 0 ) {
            // looping by hour
            rectify_date.add(Calendar.HOUR_OF_DAY, -1);
            time_delay_mins = time_delay_mins + 60;
            int remainingMinutes = rectify_date.get(Calendar.MINUTE) - Integer.parseInt(defp4_clock_stop_mins);
            if( remainingMinutes > 0 ){
              time_delay_mins = time_delay_mins - remainingMinutes;
            }
          } else {
            // looping by minute
            rectify_date.add(Calendar.MINUTE, -1);
            time_delay_mins = time_delay_mins + 1;
          } 
          
          // add a day to the rectify_date as the clock_start time is in the next day
          rectify_date.add(Calendar.DATE, 1);
          rectify_date.set(Calendar.HOUR_OF_DAY, Integer.parseInt(defp4_clock_start_hrs));
          rectify_date.set(Calendar.MINUTE, Integer.parseInt(defp4_clock_start_mins));
        }
        else if ( before(rectify_date, defp4_clock_start_hrs, defp4_clock_start_mins) )
        {
          // jump forward to the defp4_clock_start time as the current time is after
          // the defp4_clock_stop time and before the defp4_clock_start time
          
          // add back what we just took off, as we are now jumping to the clock_start time.
          if (rem == 0 ) {
            // looping by hour
            rectify_date.add(Calendar.HOUR_OF_DAY, -1);
            time_delay_mins = time_delay_mins + 60;
          } else {
            // looping by minute
            rectify_date.add(Calendar.MINUTE, -1);
            time_delay_mins = time_delay_mins + 1;
          } 
          
          rectify_date.set(Calendar.HOUR_OF_DAY, Integer.parseInt(defp4_clock_start_hrs));
          rectify_date.set(Calendar.MINUTE, Integer.parseInt(defp4_clock_start_mins));
        }
      }

      //
      // defp4_cut_off used
      //
      if (!defp4_cut_off_hrs.trim().equals("")  &&
          !defp4_cut_off_mins.trim().equals("")) {
        if ( timediff( rectify_date.get(Calendar.HOUR_OF_DAY), 
                       rectify_date.get(Calendar.MINUTE),
                       Integer.parseInt(defp4_cut_off_hrs),
                       Integer.parseInt(defp4_cut_off_mins) ) < defp4_time_delay_in_mins ) {
          if ( after(rectify_date, defp4_cut_off_hrs, defp4_cut_off_mins) ) {
            // defp4_cut_off  being used
            rectify_date.set(Calendar.HOUR_OF_DAY, Integer.parseInt(defp4_cut_off_hrs));
            rectify_date.set(Calendar.MINUTE, Integer.parseInt(defp4_cut_off_mins));
          }
        }
      }

      return rectify_date;
    }
    
    
    
    //
    // METHOD 3:
    // defp4_report_by/correct_by used
    //
    if (!defp4_report_by_hrs1.trim().equals("")  &&
        !defp4_report_by_mins1.trim().equals("") &&
        !defp4_correct_by_hrs1.trim().equals("") &&
        !defp4_correct_by_mins1.trim().equals(""))
    {
      // setup the date that the default was raised
      TimeZone dtz = TimeZone.getTimeZone("Europe/London");
      GregorianCalendar rectify_date = new GregorianCalendar(dtz);
      // Check if today is an exclusion day, and if it is zero the time
      if(is_exclusion_day( rectify_date )) {
        rectify_date.set(rectify_date.HOUR_OF_DAY, 0);
        rectify_date.set(rectify_date.MINUTE, 0);
      }
  
      // find the correct report_by time to use
      if (!defp4_report_by_hrs2.trim().equals("")   &&
          !defp4_report_by_mins2.trim().equals("")  &&
          !defp4_correct_by_hrs2.trim().equals("")  &&
          !defp4_correct_by_mins2.trim().equals("") &&
          after(rectify_date, defp4_report_by_hrs1, defp4_report_by_mins1) &&
          before(rectify_date, defp4_report_by_hrs2, defp4_report_by_mins2) )
      {
        if ( sbefore(defp4_correct_by_hrs2, defp4_correct_by_mins2, defp4_report_by_hrs2, defp4_report_by_mins2) )
        {
          // add a day to the rectify_date as the correct by time is in the next day
          rectify_date.add(Calendar.DATE, 1);
        }
        
        // set the rectify_date time to the defp4_correct_by2 time
        rectify_date.set(Calendar.HOUR_OF_DAY, Integer.parseInt(defp4_correct_by_hrs2));
        rectify_date.set(Calendar.MINUTE, Integer.parseInt(defp4_correct_by_mins2));
      }
      else if (!defp4_report_by_hrs3.trim().equals("") &&
        !defp4_report_by_mins3.trim().equals("") &&
        !defp4_correct_by_hrs3.trim().equals("") &&
        !defp4_correct_by_mins3.trim().equals("") &&
        after(rectify_date, defp4_report_by_hrs2, defp4_report_by_mins2) &&
        before(rectify_date, defp4_report_by_hrs3, defp4_report_by_mins3) )
      {
        if ( sbefore(defp4_correct_by_hrs3, defp4_correct_by_mins3, defp4_report_by_hrs3, defp4_report_by_mins3) )
        {
          // add a day to the rectify_date as the correct by time is in the next day
          rectify_date.add(Calendar.DATE, 1);
        }
        
        // set the rectify_date time to the defp4_correct_by3 time
        rectify_date.set(Calendar.HOUR_OF_DAY, Integer.parseInt(defp4_correct_by_hrs3));
        rectify_date.set(Calendar.MINUTE, Integer.parseInt(defp4_correct_by_mins3));
      }
      else
      {
        // the time is before report_by1 but after report_by3 so we're using the report_by1 time 
        if ( sbefore(defp4_correct_by_hrs1, defp4_correct_by_mins1, defp4_report_by_hrs1, defp4_report_by_mins1) )
        {
          // add a day to the rectify_date as the correct by time is in the next day
          rectify_date.add(Calendar.DATE, 1);
        }
        
        // set the rectify_date time to the defp4_correct_by1 time
        rectify_date.set(Calendar.HOUR_OF_DAY, Integer.parseInt(defp4_correct_by_hrs1));
        rectify_date.set(Calendar.MINUTE, Integer.parseInt(defp4_correct_by_mins1));
      }
        
      // loop through the days skipping any non work days until we find a work day
      while (true) {
        // Check to see if the day is a working day or not
        if (!is_working_day(rectify_date, defp4_working_week))
        {
          // jump a day (24hrs) forward as the current day is not a working day
          rectify_date.add(Calendar.DATE, 1);
        } 
        else
        {
          // this is a working day so use this one
          break;
        }
      }
      
      return rectify_date;
    }
    
    // This is to get over an error about having no return at the end of the method!
    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
    GregorianCalendar temp = new GregorianCalendar(dtz);
    return temp;
  }
  
  
  // This method returns true if the date supplied is a working week
  // specified by the working_week string - format of working_week
  // string is "DDDDDDD" where "D" is either "Y" or "N" and represents
  // a day of the week (Monday to Sunday)
  private boolean is_working_day (GregorianCalendar rectify_date,
                                         String working_week) throws Exception
  {
    boolean isWorkingDay = false;
    // get the day of the week as an int from 1 to 7
    // 1 = Sunday, 7 = Saturday.
    int index = rectify_date.get(Calendar.DAY_OF_WEEK);
    // make the day of the week run from Monday to Sunday
    index = index - 1;
    if (index == 0) {
      index = 7;
    }
    String work_day = working_week.substring(index-1, index);
    boolean isExclusionDay = is_exclusion_day( rectify_date );
    if(work_day.equals("Y") && !isExclusionDay) {
      isWorkingDay = true;
    } else {
      isWorkingDay = false;
    }
    return isWorkingDay;
  }


  // Check to see if the date provided is an exclusion date
  private boolean is_exclusion_day( GregorianCalendar rectify_date ) throws Exception {
    boolean isExclusionDay = false;
    // Setup the database date to be checked in the whiteboard 
    SimpleDateFormat formatDbDate = new SimpleDateFormat(db_date_fmt);    
    Date tmpDate  = rectify_date.getTime();
    String dbDate = formatDbDate.format( tmpDate );
    String query  = "SELECT DISTINCT exclusion_yn FROM whiteboard_dtl WHERE calendar_date = '" + 
                    dbDate + "' AND exclusion_yn = 'Y'";
    // Query the database. If a result is returned then this date is an exclusion date.
    try {
      dbHandle.query( query, db_date_fmt );
      if( !dbHandle.isEmpty() ) {
        String exclusion_day_yn = dbHandle.getString(1);
        if( exclusion_day_yn.equals("Y") || exclusion_day_yn.equals("y") ) {
          isExclusionDay = true;
        }
      }
    } catch ( Exception e ) {
      throw new Exception( "isExclusionDay: Unable to query whiteboard for exclusion dates. " + e );
    }
    return isExclusionDay;
  }


  // This method returns true if the time within the date supplied is before
  // the time specified by the hour and minute strings.
  // before means greater than 00:00 but lessthan hrs:mins
  private static boolean before (GregorianCalendar rectify_date,
                                 String hrs,
                                 String mins)
  {
    if (rectify_date.get(Calendar.HOUR_OF_DAY) < Integer.parseInt(hrs) ||
          (rectify_date.get(Calendar.HOUR_OF_DAY) == Integer.parseInt(hrs) && 
           rectify_date.get(Calendar.MINUTE) < Integer.parseInt(mins) )
       ) {
      return true;
    } else {
      return false;
    }
  }
  
  
  // This method returns true if the time specified by the first hour
  // and minute strings is before the time specified by the second hour
  // and minute strings.
  // before means greater than 00:00 but lessthan hrs:mins
  private static boolean sbefore (String hrs1,
                                  String mins1,
                                  String hrs2,
                                  String mins2)
  {
    if (Integer.parseInt(hrs1) < Integer.parseInt(hrs2) &&
        Integer.parseInt(mins1) < Integer.parseInt(mins2) )
    {
      return true;
    } else {
      return false;
    }
  }
  
  
  // This method returns true if the time within the date supplied is after
  // the time specified by the hour and minute strings.
  // after means greater than hrs:mins
  private static boolean after (GregorianCalendar rectify_date,
                                String hrs,
                                String mins)
  {
    if (rectify_date.get(Calendar.HOUR_OF_DAY) > Integer.parseInt(hrs) ||
          (rectify_date.get(Calendar.HOUR_OF_DAY) == Integer.parseInt(hrs) &&
           rectify_date.get(Calendar.MINUTE) > Integer.parseInt(mins) )
       ) {
      return true;
    } else {
      return false;
    }
  }
  
  
  // This method returns true if the time within the date supplied is the
  // same as the time specified by the hour and minute strings.
  private static boolean equals (GregorianCalendar rectify_date,
                                 String hrs,
                                 String mins)
  {
    if (rectify_date.get(Calendar.HOUR_OF_DAY) == Integer.parseInt(hrs) &&
        rectify_date.get(Calendar.MINUTE) == Integer.parseInt(mins) ) {
      return true;
    } else {
      return false;
    }
  }
  
  
  // This method returns true if the time within the date supplied is not
  // the same as the time specified by the hour and minute strings.
  private static boolean notequals (GregorianCalendar rectify_date,
                                    String hrs,
                                    String mins)
  {
    if (rectify_date.get(Calendar.HOUR_OF_DAY) == Integer.parseInt(hrs) &&
        rectify_date.get(Calendar.MINUTE) == Integer.parseInt(mins) ) {
      return false;
    } else {
      return true;
    }
  }


  // This method returns the subtraction (in mins) of the two times,
  // (hrs1:mins1 - hrs2:mins2). A negative value can be returned if 
  // the hrs1:mins1 is less than hrs2:mins2.
  private static int timediff (int hrs1,
                               int mins1,
                               int hrs2,
                               int mins2)
  {
    return ( ((hrs1 - hrs2)*60) + (mins1 - mins2) );
  }
                                    
}
