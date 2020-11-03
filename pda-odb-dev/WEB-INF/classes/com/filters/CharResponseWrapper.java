package com.filters;

import java.io.PrintWriter;
import java.io.CharArrayWriter;
import javax.servlet.http.HttpServletResponseWrapper;
import javax.servlet.http.*;
import javax.servlet.*;

public class CharResponseWrapper extends HttpServletResponseWrapper {
  private CharArrayWriter output;

  public String toString() {
    return output.toString();
  }

  public CharResponseWrapper(HttpServletResponse response){
    super(response);
    output = new CharArrayWriter();
  }

  public PrintWriter getWriter() {
    return new PrintWriter(output);
  }
}
