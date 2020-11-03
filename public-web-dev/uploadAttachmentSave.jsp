<!-- upload.jsp -->
<%@ page import="java.io.*" %>
<%@ page import="com.vsb.incidentBean" %>
<%@ page import="com.vsb.savedPublicDescriptionBean" %>

<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />
<jsp:useBean id="savedPublicDescriptionBean" scope="session" class="com.vsb.savedPublicDescriptionBean" />

<%
/* Clear error message */
session.setAttribute("errorMessage","");

/* Extract header info */
String contentType = request.getContentType();
if ((contentType != null) && (contentType.indexOf("multipart/form-data") >= 0)) {
DataInputStream in = new DataInputStream(request.getInputStream());
int formDataLength = request.getContentLength();

byte dataBytes[] = new byte[formDataLength];
int byteRead = 0;
int totalBytesRead = 0;
while (totalBytesRead < formDataLength) {
byteRead = in.read(dataBytes, totalBytesRead, formDataLength);
totalBytesRead += byteRead;
}

/* Extract file name from header */
String file = new String(dataBytes);
String saveFile = file.substring(file.indexOf("filename=\"") + 10);
saveFile = saveFile.substring(0, saveFile.indexOf("\n"));
saveFile = saveFile.substring(saveFile.lastIndexOf("\\") + 1,saveFile.indexOf("\""));
String RealName;
RealName=saveFile;
/* Extract action param from header */
String action = file.substring(file.indexOf("\"action\""));
action = action.substring(action.indexOf("\n"));
action = action.substring(3);
action = action.substring(0,action.indexOf("\n")-1);

/* If action param is Back (user requested to go back a page) then jump back a page */
if(action.equals("Back")){
%><jsp:forward page="publicaccess.jsp?input=none&action=Back" /><%
}
/* If no file was selected then move to the next page */
if(saveFile.equals("")){
%><jsp:forward page="publicaccess.jsp?input=none&action=Next" /><%
}

/* Get the ext from the file name by looking for the last dot */
while(saveFile.indexOf(".")>0){
    saveFile = saveFile.substring(saveFile.indexOf("."));
}
String ext=saveFile.substring(1);

/* Pull the config param from the session var, where they were stored in getPageLayout */
int maxattachmentsize=Integer.parseInt((String)session.getAttribute("maxattachmentsize"));
String allowedfiletypes=(String)session.getAttribute("allowedfiletypes");
String TempPath=(String)session.getAttribute("TempPath");

/* Check the size of the file and reject it if it's too large */
if((formDataLength-491)>maxattachmentsize){
    session.setAttribute("errorMessage","Sorry but that file is too large.");
%><jsp:forward page="publicaccess.jsp?input=none&action=Stay" /><%
}

/* Check the type of the file and reject it if it's not in the list of allowed file types */
if(((String)("|" + allowedfiletypes + "|")).toLowerCase().indexOf("|"+ext.toLowerCase()+"|")==-1){
    session.setAttribute("errorMessage","Sorry but that file is not a valid file type.");
%><jsp:forward page="publicaccess.jsp?input=none&action=Stay" /><%
}


/* Create a tmp file in the TempPath, this will be overwritten with the saved file */
File temp = File.createTempFile("paUL",saveFile,new File(TempPath));
saveFile=temp.toString();

/* Jump to the data part of the content */
int lastIndex = contentType.lastIndexOf("=");
String boundary = contentType.substring(lastIndex + 1,contentType.length());

int pos;
pos = file.indexOf("filename=\"");

pos = file.indexOf("\n", pos) + 1;

pos = file.indexOf("\n", pos) + 1;

pos = file.indexOf("\n", pos) + 1;


int boundaryLocation = file.indexOf(boundary, pos) - 4;
int startPos = ((file.substring(0, pos)).getBytes()).length;
int endPos = ((file.substring(0, boundaryLocation)).getBytes()).length;

/* Write the file from the post data */
FileOutputStream fileOut = new FileOutputStream(saveFile);
//fileOut.write(dataBytes);
fileOut.write(dataBytes, startPos, (endPos - startPos));
fileOut.flush();
fileOut.close();

/* Store the file name of the attachment in the incidentBean for later use when the incident is posted */
/* The attachments element of this bean is an array, so it can handle more than one attachment */
incidentBean.setAttachments(saveFile);
incidentBean.AttachmentsFilename.add(RealName);
session.setAttribute("errorMessage","Attachment has been saved");
String s;
s="" + incidentBean.AttachmentsFilename.size() + " Attachments";
savedPublicDescriptionBean.setPage("uploadAttachment",s );
}
%>
<jsp:forward page="publicaccess.jsp?input=none&action=Stay" />