package com.utils.compare;

import java.util.Comparator;

public class StringComparator implements Comparator{
  
  public int compare( Object o1, Object o2 ){
    String string1 = (String)o1;
    String string2 = (String)o2;
    int difference = string1.compareTo( string2 );
    return difference;
  }

  public boolean equals( Object o1 ){
    boolean value = false;
    if( this == o1 ){ 
      value = true; 
    }
    return value;    
  }
}
