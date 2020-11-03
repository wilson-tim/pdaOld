package com.utils;

import java.util.*;
import java.io.*;
import java.awt.image.*;
import java.awt.*;
import java.awt.geom.*;
import com.sun.jimi.core.*;

public class helperBean {

  // This method runs the external command given to it. e.g.
  // String output[] = runCommand("ls -l");
  // will run the "ls -l" command and return the output.
  public String runCommand(String cmd) {
    // set up list to capture command output lines
    ArrayList list = new ArrayList();
    String[] outputArray = new String[1];
    outputArray[0] = "";

    // Declare and initialise a null process
    Process proc = null;

    // Output string
    String output = "";
    
    try {
      // start command running
      proc = Runtime.getRuntime().exec(cmd);
  
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
        output = "process was interrupted";
      }
  
      // check its exit value
      if (proc.exitValue() != 0) {
        // turn the error output list as an array of strings
        outputArray = (String[])list.toArray(new String[0]);

        output = "exit value was non-zero";
      } else {
        // if no errors occur return an 'ok' string. The pda application
        // expects this string to know that no error occured.
        output = "ok";
      }
  
      // close stream
      br.close();
    }
    catch(IOException e){
      output = "IO Exception: " + e;
    }

    // return list of strings to caller
    // If there was an error than append the cmds output (outputArray)
    if (! output.equals("ok")) {
      output = output + "<br/><br/>";

      for (int i=0; i < outputArray.length; i++) {
        output = output + outputArray[i] + "<br/>";
      }
    }
     
    return output;   
  }

  
  // This method runs the external command given to it along with an environment
  // supplied in a String array where each string has the form "name=value". e.g.
  //
  // //set up the environpment array with size 1
  // String[] envp;
  // envp = new String[1];
  // // get the current path
  // String output = helperBean.runCommand("echo $PATH");
  // //add /new/area to the front of the path
  // envp[0] = "PATH=/new/area:" + output[0];
  // //run the command with the new path variable.
  // String output = helperBean.runCommand("ls -l", envp);
  //
  // will run the "ls -l" command in the environment envp and return the output.
  public String runCommand(String cmd, String[] envp) {
    // set up list to capture command output lines
    ArrayList list = new ArrayList();
    String[] outputArray = new String[1];
    outputArray[0] = "";

    // Declare and initialise a null process
    Process proc = null;

    // Output string
    String output = "";
    
    try {
      // start command running
      proc = Runtime.getRuntime().exec(cmd, envp);
  
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
        output = "process was interrupted";
      }
  
      // check its exit value
      if (proc.exitValue() != 0) {
        // turn the error output list as an array of strings
        outputArray = (String[])list.toArray(new String[0]);

        output = "exit value was non-zero";
      } else {
        // if no errors occur return an 'ok' string. The pda application
        // expects this string to know that no error occured.
        output = "ok";
      }
  
      // close stream
      br.close();
    }
    catch(IOException e){
      output = "IO Exception: " + e;
    }

    // return list of strings to caller
    // If there was an error than append the cmds output (outputArray)
    if (! output.equals("ok")) {
      output = output + "<br/><br/>";

      for (int i=0; i < outputArray.length; i++) {
        output = output + outputArray[i] + "<br/>";
      }
    }
     
    return output;   
  }

  // This method runs the external command given to it. e.g.
  // String output[] = runCommand(new String[] {"ls", "-l"});
  // will run the "ls -l" command and return the output.
  public String runCommand(String[] cmd) {
    // set up list to capture command output lines
    ArrayList list = new ArrayList();
    String[] outputArray = new String[1];
    outputArray[0] = "";

    // Declare and initialise a null process
    Process proc = null;

    // Output string
    String output = "";
    
    try {
      // start command running
      proc = Runtime.getRuntime().exec(cmd);
  
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
        output = "process was interrupted";
      }
  
      // check its exit value
      if (proc.exitValue() != 0) {
        // turn the error output list as an array of strings
        outputArray = (String[])list.toArray(new String[0]);

        output = "exit value was non-zero";
      } else {
        // if no errors occur return an 'ok' string. The pda application
        // expects this string to know that no error occured.
        output = "ok";
      }
  
      // close stream
      br.close();
    }
    catch(IOException e){
      output = "IO Exception: " + e;
    }

    // return list of strings to caller
    // If there was an error than append the cmds output (outputArray)
    if (! output.equals("ok")) {
      output = output + "<br/><br/>";

      for (int i=0; i < outputArray.length; i++) {
        output = output + outputArray[i] + "<br/>";
      }
    }
     
    return output;   
  }

  
  // This method runs the external command given to it along with an environment
  // supplied in a String array where each string has the form "name=value". e.g.
  //
  // //set up the environpment array with size 1
  // String[] envp;
  // envp = new String[1];
  // // get the current path
  // String output = helperBean.runCommand("echo $PATH");
  // //add /new/area to the front of the path
  // envp[0] = "PATH=/new/area:" + output[0];
  // //run the command with the new path variable.
  // String output = helperBean.runCommand(new String[] {"ls", "-l"}, envp);
  //
  // will run the "ls -l" command in the environment envp and return the output.
  public String runCommand(String[] cmd, String[] envp) {
    // set up list to capture command output lines
    ArrayList list = new ArrayList();
    String[] outputArray = new String[1];
    outputArray[0] = "";

    // Declare and initialise a null process
    Process proc = null;

    // Output string
    String output = "";
    
    try {
      // start command running
      proc = Runtime.getRuntime().exec(cmd, envp);
  
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
        output = "process was interrupted";
      }
  
      // check its exit value
      if (proc.exitValue() != 0) {
        // turn the error output list as an array of strings
        outputArray = (String[])list.toArray(new String[0]);

        output = "exit value was non-zero";
      } else {
        // if no errors occur return an 'ok' string. The pda application
        // expects this string to know that no error occured.
        output = "ok";
      }
  
      // close stream
      br.close();
    }
    catch(IOException e){
      output = "IO Exception: " + e;
    }

    // return list of strings to caller
    // If there was an error than append the cmds output (outputArray)
    if (! output.equals("ok")) {
      output = output + "<br/><br/>";

      for (int i=0; i < outputArray.length; i++) {
        output = output + outputArray[i] + "<br/>";
      }
    }
     
    return output;   
  }



  // This method runs the external command given to it along with an environment
  // supplied in a String array where each string has the form "name=value". e.g.
  //
  // //set up the environpment array with size 1
  // String[] envp;
  // envp = new String[1];
  // // get the current path
  // String output = helperBean.runCommand("echo $PATH");
  // //add /new/area to the front of the path
  // envp[0] = "PATH=/new/area:" + output[0];
  // //run the command with the new path variable.
  // String output = helperBean.runCommand(new String[] {"ls", "-l"}, envp);
  //
  // will run the "ls -l" command in the environment envp and return the output.
  public String runOutputCommand(String[] cmd, String[] envp) {
    // set up list to capture command output lines
    ArrayList errorList  = new ArrayList();
    ArrayList inputList  = new ArrayList();
    String[] outputArray = new String[1];
    outputArray[0] = "";
    boolean isError = false;

    // Declare and initialise a null process
    Process proc = null;

    // Output string
    String output = "";
    
    try {
      // start command running
      proc = Runtime.getRuntime().exec(cmd, envp);
  
      // get command's error stream and
      // put a buffered reader input stream on it
      InputStream errorStream = proc.getErrorStream();
      BufferedReader errorBR =
        new BufferedReader(new InputStreamReader(errorStream));

      // get command's standard output stream and
      // put a buffered reader input stream on it
      InputStream inputStream = proc.getInputStream();
      BufferedReader inputBR =
        new BufferedReader(new InputStreamReader(inputStream));
  
      // read error lines from command
      String errorString;
      while ((errorString = errorBR.readLine()) != null)
        errorList.add(errorString);
  
      // read input lines from command
      String intputString;
      while ((intputString = inputBR.readLine()) != null)
        inputList.add(intputString);
      
      // wait for command to terminate
      try {
        proc.waitFor();
      }
      catch (InterruptedException e) {
        output = "process was interrupted";
      }
  
      // check its exit value
      if (proc.exitValue() != 0) {
        // turn the error output list as an array of strings
        outputArray = (String[])errorList.toArray(new String[0]);
        isError = true;
        output = "exit value was non-zero";
      } else {
        // if no errors occur return an 'ok' string. The pda application
        // expects this string to know that no error occured.
        // turn the output list as an array of strings
        outputArray = (String[])inputList.toArray(new String[0]);
      }  
      // close stream
      errorBR.close();
      inputBR.close();
    }
    catch(IOException e){
      output = "IO Exception: " + e;
    }

    // return value of last output to caller if no error occured
    if( !isError ) {
      // Because windows sometimes adds a blank line after it's output, need to
      // take the last TWO lines and then concatenate them together and remove any
      // carriage returns and linefeeds.
      if( outputArray.length >= 2 ) {
        output = outputArray[outputArray.length-2] + outputArray[outputArray.length-1];
        output = output.replace('\n',' ');
        output = output.replace('\r',' ');
        output = output.trim();
      } else {
        output = outputArray[outputArray.length-1];
      }
    } else {
      for (int i=0; i < outputArray.length; i++) {
        output += outputArray[i] + "<br/>";
      }
    }
    return output;   
  }

  // This method draws a cross hair on the specified image. Take the image name,
  // size, cross-hair type and cross hair-color. The image is saved to the
  // specified file using the JIMI library, which does not ship with JAVA
  public void drawCrossHair( String imageFile, String width, String height ){
    // Set the awt headers to headless so they do not conflict with XWindows
    System.getProperties().setProperty("java.awt.headless", "true");
    // Get the image Object
    Image image = Toolkit.getDefaultToolkit().getImage(imageFile.toString());
    // Get the indexed color model of the image
    IndexColorModel colorModel = (IndexColorModel)getColorModel(image);
    // Setup the media tracker to track the image
    MediaTracker mediaTracker = new MediaTracker(new Panel());
    mediaTracker.addImage(image,0);
    try{
      mediaTracker.waitForID(0);
    }catch( InterruptedException e ){

    }
    // Get the center of the image
    int imgWidth  = new Integer(width).intValue();
    int imgHeight = new Integer(height).intValue();
    int crossX  = imgWidth/2;
    int crossY  = imgHeight/2;
    // Create the image buffer, where we can manipulate the image
    BufferedImage buffImage = new BufferedImage( imgWidth, 
                                                 imgHeight,
                                                 BufferedImage.TYPE_BYTE_INDEXED,
                                                 colorModel );
    // Get the graphics object so we may draw on the image
    Graphics2D g = buffImage.createGraphics();
    g.setRenderingHint( RenderingHints.KEY_INTERPOLATION,
                        RenderingHints.VALUE_INTERPOLATION_BILINEAR );
    // Draw the image
    g.drawImage( image, 0, 0, imgWidth, imgHeight, null );
    // Set the color to red
    g.setPaint(Color.RED);
    // Draw the cross-hairs      
    g.draw(new Line2D.Double(crossX-10,crossY,crossX+10,crossY ));
    g.draw(new Line2D.Double(crossX,crossY-10,crossX,crossY+10  ));
    g.dispose();
    // Save the image using the Jimi classes
    try{
      Jimi.putImage(buffImage, imageFile.toString() );
    }catch( JimiException e ){
      
    }
  }

  // This method draws a cross hair on the specified image. Take the image as a byte array,
  // size, cross-hair type and cross hair-color. The image is returned as a byteArray to the
  // using the JIMI library, which does not ship with JAVA
  public byte[] drawCrossHair( byte[] imageInBytes, String width, String height ){
    // Set the awt headers to headless so they do not conflict with XWindows
    System.getProperties().setProperty("java.awt.headless", "true");

    // Get the image Object
    ByteArrayInputStream in = new ByteArrayInputStream(imageInBytes);
    Image image = Jimi.getImage(in, "image/png");
    try {
      in.close();
    } catch (java.io.IOException e) {
    }

    // Get the indexed color model of the image
    IndexColorModel colorModel = (IndexColorModel)getColorModel(image);
    // Setup the media tracker to track the image
    MediaTracker mediaTracker = new MediaTracker(new Panel());
    mediaTracker.addImage(image,0);
    try{
      mediaTracker.waitForID(0);
    }catch( InterruptedException e ){

    }
    // Get the center of the image
    int imgWidth  = new Integer(width).intValue();
    int imgHeight = new Integer(height).intValue();
    int crossX  = imgWidth/2;
    int crossY  = imgHeight/2;
    // Create the image buffer, where we can manipulate the image
    BufferedImage buffImage = new BufferedImage( imgWidth, 
                                                 imgHeight,
                                                 BufferedImage.TYPE_BYTE_INDEXED,
                                                 colorModel );
    // Get the graphics object so we may draw on the image
    Graphics2D g = buffImage.createGraphics();
    g.setRenderingHint( RenderingHints.KEY_INTERPOLATION,
                        RenderingHints.VALUE_INTERPOLATION_BILINEAR );
    // Draw the image
    g.drawImage( image, 0, 0, imgWidth, imgHeight, null );
    // Set the color to red
    g.setPaint(Color.RED);
    // Draw the cross-hairs      
    g.draw(new Line2D.Double(crossX-10,crossY,crossX+10,crossY ));
    g.draw(new Line2D.Double(crossX,crossY-10,crossX,crossY+10  ));
    g.dispose();
    // Save the image using the Jimi classes
    byte[] newImageInBytes = null;
    try{
      // === Turn the image into a Byte array ===
      ByteArrayOutputStream bos = new ByteArrayOutputStream();
      Jimi.putImage("image/png", buffImage, bos);
      newImageInBytes = bos.toByteArray();
      bos.close();
    }catch( Exception e ){
      
    }

    return newImageInBytes;
  }

  // This method returns the color model of an image
  public static ColorModel getColorModel(Image image) {
    // If buffered image, the color model is readily available
    if (image instanceof BufferedImage) {
      BufferedImage bimage = (BufferedImage)image;
      return bimage.getColorModel();
    }
    // Use a pixel grabber to retrieve the image's color model;
    // grabbing a single pixel is usually sufficient
    PixelGrabber pg = new PixelGrabber(image, 0, 0, 1, 1, false);
    try {
      pg.grabPixels();
    } catch (InterruptedException e) {
     
    }
    ColorModel cm = pg.getColorModel();
    return cm;
  }
  
}
