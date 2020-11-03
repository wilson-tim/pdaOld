package com.dbb;

import com.db.DbQueryHandler;

public class SNoBean{

  private DbQueryHandler dbHandle;         // Database handle
  private         String query;            // Query string
  private        boolean usedContract_ref; // Switch to check if query is ok
  private        boolean isSerial_noSet;   // Is there a sn_func in the s_no table
  private         String intContext;       // Initial DB Context
  private         String context;          // DB Context

  private String sn_func;
  private String contract_ref;
  private int serial_no;

  /**
  * Constructor method that takes in the sn_func and assumes
  * that the contract_ref is blank.
  */
  public SNoBean( String intContext, String context, String sn_func ) throws Exception{
    setQuery( sn_func );
    this.sn_func     = sn_func;
    this.context     = context;
    this.intContext  = intContext;
    contract_ref     = "";
    isSerial_noSet   = false;
    usedContract_ref = false;    
    try
    {
      setSerial_no();
    }
    catch( Exception e )
    {
      throw new Exception("Unable to initialise SNoBean:- " + e );
    }
  }

  /**
  * Constructor method that takes in the sn_func and contract_ref
  */
  public SNoBean( String intContext, String context, String sn_func, String contract_ref ) throws Exception{
    setQuery( sn_func, contract_ref );
    this.sn_func       = sn_func;
    this.context       = context;
    this.intContext    = intContext;
    this.contract_ref  = contract_ref;
    isSerial_noSet     = false;
    usedContract_ref   = true;
    try
    {
      setSerial_no();
    }
    catch( Exception e )
    {
      throw new Exception("Unable to initialise SNoBean:- " + e );
    }
  }

  /**
  * Create the query to get the serail number for the specific sn_func
  * '', '*' and 'ALL' are all used as default contract_ref's so we need
  * to search for all of them here. We also need to make sure there are
  * no actual NULL values either!
  */
  private void setQuery( String sn_func ){
    query =  "SELECT serial_no FROM s_no WHERE sn_func = '" + sn_func + 
             "' AND ( contract_ref IN ('','*','ALL') OR contract_ref IS NULL )" ;
  }

  /** 
  * Create a query to get the serial number for the specific sn_func 
  * and contrac_ref
  */
  private void setQuery( String sn_func, String contract_ref ){
    query =  "SELECT serial_no FROM s_no WHERE sn_func = '" + sn_func + 
             "' AND contract_ref ='" + contract_ref + "'";
  }

  /**
  * This method runs the actual query against the database. If there is no row returned
  * from the query then we assume that there is no row in the s_no table for this sn_func,
  * so we insert a new row for the sn_func and contract_ref provided.
  *
  * If a result is returned then we must check to see if the result is not null or empty.
  * If this is the case then we must update the specific row and reset the serial_no field
  * to the value of 1.
  *
  * If the result returned is not null or empty then we assume the value is correct and 
  * use this value as the serial_no
  */ 
  private void setSerial_no() throws Exception {  
    // Try and create a new handle to the database
    try
    {
      dbHandle = new DbQueryHandler();
      // Must explicitly connect and disconnect the handle
      dbHandle.connect( intContext, context );
    }
    catch( Exception e )
    {
      throw new Exception("Error creating handle to databasa in SNoBean getSerial_no() | " + e );
    }    
    // Try to run query for retrieveing the s_no row
    try
    {
      dbHandle.query( query, "yyyyMMdd" );
    }
    catch( Exception e )
    {
      throw new Exception("Error getting new serial number for "+ sn_func +" in SNoBean | " + e );
    }
    // If there is no value returned for the above query then we can assume
    // that we need to create a new serial_no and sn_func in the s_no table
    if( dbHandle.isEmpty() )
    {
      try{
        // Create and run the query, if succesful set the serial_no to the default value 1
        query = "INSERT INTO s_no ( serial_no, sn_func, contract_ref ) VALUES ( " +
                1 + ", '" + sn_func + "', '" + contract_ref + "' )";
        dbHandle.update( query );
        serial_no = 1;
      }
      catch( Exception e )
      {
        throw new Exception("Error creating new sn_func " + sn_func + " in SNoBean | " + e );
      }
    }
    // Otherwise we need to check if there is a valid value in the serial_no field
    // and if there isn't then we need to reset it to 1, if there is we set the 
    // serial_no to that value 
    else
    {
      try
      {
        // Get the value returned from the query
        serial_no = dbHandle.getInt( 1 );
      }
      catch( Exception e )
      {
        throw new Exception("Unable to retrieve serial_no in SNoBean | " + e );
      }
      if( dbHandle.wasIntNull() || serial_no == 0 )        
      {
        // Update the s_no table with the initial value
        query = "UPDATE s_no SET serial_no = 1 WHERE sn_func = '" + sn_func +
                "' AND contract_ref = '" + contract_ref + "'";
        try
        {
          // Run the above query and set the default serial_no value of 1
          dbHandle.update( query );
          serial_no = 1;
        }
        catch( Exception e )
        {
          throw new Exception("Unable to set initial value for sn_func " + sn_func + " in SNoBean | " + e );
        }          
      }    
    }
    // If we reach here we have successfuly created the serial number one way or another
    // So we now need to update the serial number.
    int new_serial_no = serial_no + 1;
    // Set the query depending on how the contract_ref was used i.e. persumed blank or not
    if( usedContract_ref )
    {
      query = "UPDATE s_no SET serial_no = " + new_serial_no + 
              " WHERE sn_func = '" + sn_func + "' " +
              " AND contract_ref = '" + contract_ref + "'"; 
    }
    else
    {
      query = "UPDATE s_no SET serial_no = " + new_serial_no +
              " WHERE sn_func = '" + sn_func + "' " +
              " AND ( contract_ref IN ('','*','ALL') " +
              " OR contract_ref IS NULL )";
    }
    // Update the s_no table rows
    try
    {
      dbHandle.update( query );
    }
    catch( Exception e )
    {
      throw new Exception("Unable to update to new serial_no for sn_func " + sn_func + " | " + e );
    }      

    // Disconnect the handle
    try
    {
      // Must explicitly connect and disconnect the handle
      dbHandle.disconnect();
    }
    catch( Exception e )
    {
      throw new Exception("Error disconnecting handle to databasa in SNoBean getSerial_no() | " + e );
    }    

    // Allow the bean to know that this method has been completed
    isSerial_noSet = true;  
  }  
  
  /**
  * Public method to retrieve the serial number as a String. Throws exception if the 
  * setSerial_no() method has not been run before this method is called. This is done
  * by checking the isSerial_noSet field.
  */ 
  public String getSerial_noAsString() throws Exception{
    String temp_serial_no = "";
    if( isSerial_noSet )
    {
      temp_serial_no = String.valueOf( serial_no );
    }
    else
    {
      throw new Exception("Attempting to getSerial_no when setSerial_no method has not been run. ");
    } 
    return temp_serial_no;
  }

  /**
  * Public method to retrieve the serial number. Throws exception if the setSerial_no() method
  * has not been run before this method is called. This is done by checking the isSerial_noSet
  * field.
  */ 
  public int getSerial_no() throws Exception{
    if( isSerial_noSet )
    {
      return serial_no;
    }
    else
    {
      throw new Exception("Attempting to getSerial_no when setSerial_no method has not been run. ");
    } 
  }
    
}
