package com.utils.compare;

import java.util.Comparator;

public class PipeComparator implements Comparator{
  
  public int compare( Object o1, Object o2 ){
    int sequenceNumber1 = getSequenceNumber(o1);
    int sequenceNumber2 = getSequenceNumber(o2);
    int difference = sequenceNumber1 - sequenceNumber2;
    return difference;
  }

  public boolean equals( Object o1 ){
    boolean value = false;
    if( this == o1 ){ 
      value = true; 
    }
    return value;    
  }

  private int getSequenceNumber( Object s ){
    String id = (String)s;
    int startIndex = id.indexOf("|");
    String sequenceNo = id.substring( startIndex + 1 );
    Integer number = new Integer( sequenceNo );
    return number.intValue();
  }
}
