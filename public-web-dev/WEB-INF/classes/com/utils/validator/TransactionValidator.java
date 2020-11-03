package com.utils.validator;

public class TransactionValidator{

  private String transactionNo;
  private String paymentAmount;
  
  private int[] transactionNumbers;
  private int[] paymentNumbers;
  private int[] weightTotals;
  private int divider;

  public TransactionValidator(){
    transactionNo = "";
    paymentAmount = "";
    transactionNumbers = new int[6];
    paymentNumbers     = new int[6];
    weightTotals       = new int[6];
  }

  public String getHex( String transNumbers, String payNumbers ){
    String calculatedHexValue = "";
    if( !transNumbers.equals("") && !payNumbers.equals("") ){
      int[] transactionNumbers  = setTransNumbers( transNumbers );
      int[] paymentNumbers      = setPaymentNumbers( payNumbers );
      int[] weights             = setWeights( transactionNumbers, paymentNumbers );
      int number                = getWeightsTotal( weights );
      calculatedHexValue = getHexValue( number );
    }
    return calculatedHexValue;
  }
  
  public boolean validate( String hexValue, String transNumbers, String payNumbers ){
    boolean validated = false;
    if( !hexValue.equals("") && !transNumbers.equals("") && !payNumbers.equals("") ){
      int[] transactionNumbers  = setTransNumbers( transNumbers );
      int[] paymentNumbers      = setPaymentNumbers( payNumbers );
      int[] weights             = setWeights( transactionNumbers, paymentNumbers );
      int number                = getWeightsTotal( weights );
      String calculatedHexValue = getHexValue( number );
      if( hexValue.equals( calculatedHexValue ) ){
       validated = true;
      }
    }
    return validated;
  }

  public int[] setTransNumbers( String transNo ){
    int[] tempNumbers = new int[6];
    for( int i=0; i<6; i++ ){
      int n = new Integer( transNo.substring( transNo.length()-(i+1) , transNo.length()-i ) ).intValue();
      tempNumbers[i] = n;
    }
    return tempNumbers;
  }

  public int[] setPaymentNumbers( String payment ){
    int[] tempNumbers = new int[6];
    int paymentLength = payment.length();
    boolean exceededLength = false;
    int count = 0;
    while( !exceededLength ){
      for( int i=0; i<paymentLength; i++ ){
        if( count < 6 ){
          String number = payment.substring( payment.length()-(i+1) , payment.length()-i );
          int n = new Integer( number ).intValue();
          tempNumbers[count] = n;
          count++;
        }else{
          exceededLength = true;
        }
      }
    }
    return tempNumbers;
  }

  public int[] setWeights( int[] transNumbers, int[] paymentNumbers ){
    int[] tempWeights = new int[6];
    for( int i=0; i<6; i++ ){
      tempWeights[i] = transNumbers[i] * paymentNumbers[i];
    }
    return tempWeights;
  }

  public int getWeightsTotal( int[] weights ){
    int total = 0;
    for(int i=0; i<6; i++){
      total += weights[i];
    }
    return total;
  }

  public String getHexValue( int weightsTotal ){
    int number  = weightsTotal%16;
    String hexValue = Integer.toHexString( number );
    hexValue = hexValue.toUpperCase();
    return hexValue;
  }
  
}
