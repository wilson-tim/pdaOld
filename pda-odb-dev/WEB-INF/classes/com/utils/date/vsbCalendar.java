package com.utils.date;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.TimeZone;
import java.util.Calendar;
import java.text.ParseException;

public class vsbCalendar extends GregorianCalendar {
  
  private String dateString;
  private String format;
  private SimpleDateFormat dateFormat;
  private SimpleDateFormat hourFormat;
  private SimpleDateFormat minsFormat;
  private TimeZone dtz;
  private Date date;
  
  /**
   * Create a new Gregorian Calendar initialised to the given date.
   * The date will be formatted using the format provided in the 
   * format string.
   */
  public vsbCalendar( String dateString, String format ) throws ParseException {
    super();
    this.dateString = dateString;
    this.format     = format;
    dateFormat      = new SimpleDateFormat( format );
    hourFormat      = new SimpleDateFormat( "HH" );
    minsFormat      = new SimpleDateFormat( "mm" );
    dtz = TimeZone.getTimeZone("Europe/London");
    TimeZone.setDefault(dtz);
    try {
      date = dateFormat.parse( dateString );
    } catch ( ParseException msg ) {
      throw msg;
    }
    this.setTime( date );
  }

  /**
   * Create a new Gregorian Calendar initialised to the given date.
   * The date will be formatted using the format provided in the 
   * format string.
   */
  public vsbCalendar( String format ) {
    super();
    this.dateString = dateString;
    this.format     = format;
    dateFormat      = new SimpleDateFormat( format );
    hourFormat      = new SimpleDateFormat( "HH" );
    minsFormat      = new SimpleDateFormat( "mm" );
    dtz = TimeZone.getTimeZone("Europe/London");
    TimeZone.setDefault(dtz);
    date = new Date();
    this.setTime( date );
  }

  /**
   * Return the day of the month
   */
  public String getDay() {
    return new Integer( this.get( this.DAY_OF_MONTH ) ).toString();
  }

  /**
   * Return the month
   */
  public String getMonth() {
    return new Integer( ((new Integer( this.get( this.MONTH ) )).intValue() + 1)).toString();
  }

  /**
   * Return the year
   */
  public String getYear() {
    return new Integer( this.get( this.YEAR ) ).toString();
  }
 
  /**
   * Return the hours
   */
  public String getHours() {
    return hourFormat.format(this.getTime());
  }

  /**
   * Return the minutes
   */
  public String getMinutes() {
    return minsFormat.format(this.getTime());
  }

  /**
   * Return the date
   */
  public Date getDate() {
    return this.getTime();
  }

  /**
   * Return the date as a String
   */
  public String getDateString() {
    return dateFormat.format(this.getTime());
  }

  /**
   * Add some days to the date
   */
  public void addDays(int days) {
    this.add( Calendar.DATE, days);
  }
}
