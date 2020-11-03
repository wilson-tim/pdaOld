package com.utils.validator;

public class FormValidator{

  public FormValidator(){
  }

  public boolean isNumber( String numberString ){
    boolean isNumber = false;
    try{
      long number = new Long( numberString ).longValue();
      isNumber = true;
    }catch(NumberFormatException e){
      isNumber = false;
    }
    return isNumber;
  }
  
}
