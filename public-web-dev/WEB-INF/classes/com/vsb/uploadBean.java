package com.vsb;

import java.io.*;
import javax.servlet.http.HttpServletRequest;
import java.net.URLConnection;

public class uploadBean{
    private String Content="";
    private int formDataLength=491;
    private byte dataBytes[];
    private URLConnection request;

    public boolean getContent(URLConnection request){
        this.request=request;
        String contentType = request.getContentType();
        if((contentType != null) && (contentType.indexOf("multipart/form-data") >= 0)){
            try{
                DataInputStream in = new DataInputStream(request.getInputStream());
                formDataLength = request.getContentLength();

                dataBytes = new byte[formDataLength];
                int byteRead = 0;
                int totalBytesRead = 0;
                while (totalBytesRead < formDataLength){
                    byteRead = in.read(dataBytes, totalBytesRead, formDataLength);
                    totalBytesRead += byteRead;
                }
            } catch (IOException e) {return false;}
            Content = new String(dataBytes);
            return true;
        }else{
            return false;
        }
    }
    
    public String getFilename(){
        String file = Content;
        String saveFile = file.substring(file.indexOf("filename=\"") + 10);
        saveFile = saveFile.substring(0, saveFile.indexOf("\n"));
        saveFile = saveFile.substring(saveFile.lastIndexOf("\\") + 1,saveFile.indexOf("\""));
        return saveFile;
    }
    
    public String getParam(String Param){
        String file = Content;
        String action = file.substring(file.indexOf("\"" + Param + "\""));
        action = action.substring(action.indexOf("\n"));
        action = action.substring(3);
        action = action.substring(0,action.indexOf("\n")-1);
        return action;
    }
    
    public String getExt(){
        String saveFile = getFilename();
        while(saveFile.indexOf(".")>0){
            saveFile = saveFile.substring(saveFile.indexOf("."));
        }
        String ext=saveFile.substring(1);
        return ext;
    }
    
    public int getFileSize(){
        return formDataLength-491;
    }

    public String makeTempFile(String prefix, String tempPath){
        try{
            File temp = File.createTempFile(prefix,this.getExt(),new File(tempPath));
            return temp.toString();
        } catch (IOException e) { return ""; }
    }
    
    public void saveFile(String saveFile){
        String contentType = this.request.getContentType();
        int lastIndex = contentType.lastIndexOf("=");
        String boundary = contentType.substring(lastIndex + 1,contentType.length());

        int pos;
        pos = Content.indexOf("filename=\"");
        pos = Content.indexOf("\n", pos) + 1;
        pos = Content.indexOf("\n", pos) + 1;
        pos = Content.indexOf("\n", pos) + 1;


        int boundaryLocation = Content.indexOf(boundary, pos) - 4;
        int startPos = ((Content.substring(0, pos)).getBytes()).length;
        int endPos = ((Content.substring(0, boundaryLocation)).getBytes()).length;

        /* Write the file from the post data */
        try{
            FileOutputStream fileOut= new FileOutputStream(saveFile);
            //fileOut.write(dataBytes);
            fileOut.write(dataBytes, startPos, (endPos - startPos));
            fileOut.flush();
            fileOut.close();
        } catch (IOException e) {}
    }
}