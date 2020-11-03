package com.ws;

import javax.xml.soap.*;
import java.net.URL;
import org.w3c.dom.NodeList;
import com.ws.CartologyMessage;
import org.apache.axis.encoding.Base64;

public class CartologySOAP {
  private String endpoint = "";
  private String xmlNamespace = "";
  private String cookie = "";

  // Deal with a SOAPMessage response
  private String getSOAPResult(SOAPMessage soapResponse, String tagName) throws Exception {
    SOAPPart sp = soapResponse.getSOAPPart();
    SOAPEnvelope env = sp.getEnvelope();
    SOAPBody sb = env.getBody();
    // Retrieve the XML nodes (in a list (NodeList)) by name. Could just use the SOAPPart (e.g. sp)
    // to retrieve the XML nodes from but to be on the safe side it's best to use the SOAPBody (e.g. sb),
    // this reduces the chances of picking the wrong XML nodes, if the same TagName is used in the
    // SOAPPart or SOAPEnvelope.
    NodeList nl = sb.getElementsByTagName(tagName);
    // The NodeList items are indexed from 0, as there is only going to be one we don't have to use
    // a for loop to loop over them using the NodeList getLength() method, e.g. nl.getLength() as this
    // will always be 1 for the Login SOAP service.
    String result;
    if ( nl.getLength() >= 1 ) {
      SOAPElement n = (SOAPElement)nl.item(0);
      result  = n.getValue();
    } else {
      result = "";
    }

    return result;
  }

  private String[] getSOAPArrayResult(SOAPMessage soapResponse, String tagName) throws Exception {
    SOAPPart sp = soapResponse.getSOAPPart();
    SOAPEnvelope env = sp.getEnvelope();
    SOAPBody sb = env.getBody();
    // Retrieve the XML nodes (in a list (NodeList)) by name. Could just use the SOAPPart (e.g. sp)
    // to retrieve the XML nodes from but to be on the safe side it's best to use the SOAPBody (e.g. sb),
    // this reduces the chances of picking the wrong XML nodes, if the same TagName is used in the
    // SOAPPart or SOAPEnvelope.
    // Get the array.
    NodeList sbnl = sb.getElementsByTagName(tagName);
    // The NodeList items are indexed from 0, as there is only going to be one we don't have to use
    // a for loop to loop over them using the NodeList getLength() method, e.g. nl.getLength() as this
    // will always be 1 for the Login SOAP service.
    String[] result;
    if ( sbnl.getLength() >= 1 ) {
      // Get a node list of the array
      Node sbn = (Node)sbnl.item(0);
      NodeList cnl = sbn.getChildNodes();
      if ( cnl.getLength() >= 1 ) {
        // loop through the NodeList representation of the array getting each of the values
        result = new String[cnl.getLength()];
        SOAPElement cn = null;
        for(int i=0; i<result.length; i++) {
          cn = (SOAPElement)cnl.item(i);
          result[i]  = cn.getValue();
        }
      } else {
        result = null;
      }
    } else {
      result = null;
    }

    return result;
  }

  private String getSOAPCookie(SOAPMessage soapResponse) throws Exception {
    // get the Set-Cookie value from the HTTP header
    MimeHeaders hd = soapResponse.getMimeHeaders();
    String[] soapCookie = hd.getHeader("Set-Cookie");

    return soapCookie[0];
  }

  private void setSOAPCookie(SOAPMessage soapMessage, String cookie) throws Exception {
    // Add the Cookie to the HTTP header
    MimeHeaders hd = soapMessage.getMimeHeaders();
    hd.addHeader("Cookie", cookie);
  }

  // ==============
  // Public methods
  // ==============

  // get/set the endpoint for the SOAP service (the soap serrver URL)
  // e.g. "http://217.205.172.22/CNET42/wsCartologyViewer/wsCartologyViewer.asmx"
  public String getEndpoint() {
    return endpoint;
  }
  
  public void setEndpoint(String endpoint) {
    this.endpoint = endpoint;
  }

  // get/set the XML namespace for the SOAP service e.g. "http://berenice.it/"
  public String getXmlNamespace() {
    return xmlNamespace;
  }
  
  public void setXmlNamespace(String xmlNamespace) {
    this.xmlNamespace = xmlNamespace;
  }

  // ===================================
  // These are the SOAP services methods
  // ===================================

  //
  // ### Login ###
  //
  // The endpoint and xmlNamespace variables must be set before using.
  public boolean Login(String username, String password) throws Exception {
    // === CREATE THE MESSAGE ===
    CartologyMessage Cmessage = new CartologyMessage(this.xmlNamespace, this.endpoint, "Login");
   
    // === ADD THE PARAMETERS ===
    Cmessage.addParameter("Username", username);
    Cmessage.addParameter("Password", password);
   
    // === CREATE AND MAKE CONNECTION, SEND MESSAGE, RECEIVE RESPONSE AND CLOSE CONNECTION ===
    SOAPMessage soapResponse = Cmessage.sendSOAPMessage(this.endpoint);

    // === DEAL WITH RESPONSE ===
    String result = this.getSOAPResult(soapResponse, "LoginResult");

    // Get the cookie
    this.cookie = this.getSOAPCookie(soapResponse);

    // cast string result to boolean before returning
    return (new Boolean(result)).booleanValue();
  }

  //
  // ### IsAuthenticated ###
  //
  // The endpoint and xmlNamespace variables must be set before using.
  public boolean IsAuthenticated() throws Exception {
    // === CREATE THE MESSAGE WITH LOGIN COOKIE ===
    CartologyMessage Cmessage = new CartologyMessage(this.xmlNamespace, this.endpoint, "IsAuthenticated", this.cookie);
   
    // === ADD THE PARAMETERS ===
    // NONE

    // === CREATE AND MAKE CONNECTION, SEND MESSAGE, RECEIVE RESPONSE AND CLOSE CONNECTION ===
    SOAPMessage soapResponse = Cmessage.sendSOAPMessage(this.endpoint);

    // === DEAL WITH RESPONSE ===
    String result = this.getSOAPResult(soapResponse, "IsAuthenticatedResult");

    // cast string result to boolean before returning
    return (new Boolean(result)).booleanValue();
  }

  //
  // ### CreateCallContext ###
  //
  // The endpoint and xmlNamespace variables must be set before using.
  public byte[] CreateCallContext() throws Exception {
    // === CREATE THE MESSAGE WITH LOGIN COOKIE ===
    CartologyMessage Cmessage = new CartologyMessage(this.xmlNamespace, this.endpoint, "CreateCallContext", this.cookie);
   
    // === ADD THE PARAMETERS ===
    // NONE
  
    // === CREATE AND MAKE CONNECTION, SEND MESSAGE, RECEIVE RESPONSE AND CLOSE CONNECTION ===
    SOAPMessage soapResponse = Cmessage.sendSOAPMessage(this.endpoint);

    // === DEAL WITH RESPONSE ===
    String result = this.getSOAPResult(soapResponse, "CreateCallContextResult");

    // cast string result to a byte array before returning
    // can use Base64.encode(byte[] data) to encode the byte array back to a String 
    return Base64.decode(result);
  }

  //
  // ### GetImage ###
  //
  // The endpoint and xmlNamespace variables must be set before using.
  public byte[] GetImage(String callContext, String workspaceName, String imageWidth, String imageHeight, 
    String bitsPerPixel, String worldCenterX, String worldCenterY, String worldPerDeviceUnits, String imageType, 
    String imageQuality) throws Exception {

    // === CREATE THE MESSAGE WITH LOGIN COOKIE ===
    CartologyMessage Cmessage = new CartologyMessage(this.xmlNamespace, this.endpoint, "GetImage", this.cookie);
   
    // === ADD THE PARAMETERS ===
    if (callContext != null && !callContext.equals("") ) {
      Cmessage.addParameter("callContext", callContext);
    }
    Cmessage.addParameter("WorkspaceName", workspaceName);
    Cmessage.addParameter("MaxThemeMandatoryLevel", "Cosmetic");
    Cmessage.addParameter("ImageWidth", imageWidth);
    Cmessage.addParameter("ImageHeight", imageHeight);
    SOAPElement BackgroundColor = Cmessage.addElement("BackgroundColor");
      Cmessage.addParameter(BackgroundColor, "R", "255");
      Cmessage.addParameter(BackgroundColor, "G", "255");
      Cmessage.addParameter(BackgroundColor, "B", "255");
    Cmessage.addParameter("BitsPerPixel", bitsPerPixel);
    Cmessage.addParameter("WorldCenterX", worldCenterX);
    Cmessage.addParameter("WorldCenterY", worldCenterY);
    Cmessage.addParameter("WorldPerDeviceUnits", worldPerDeviceUnits);
    Cmessage.addParameter("PixelWidth", "0.3");
    Cmessage.addParameter("PixelHeight", "0.3");
    Cmessage.addParameter("ImageType", imageType);
    Cmessage.addParameter("ImageQuality", imageQuality);
    Cmessage.addParameter("IdProjectionType", "-1");
    Cmessage.addParameter("NotChangeSelectionColor", "false");
    Cmessage.addParameter("Thumbnail", "false");

    // === CREATE AND MAKE CONNECTION, SEND MESSAGE, RECEIVE RESPONSE AND CLOSE CONNECTION ===
    SOAPMessage soapResponse = Cmessage.sendSOAPMessage(this.endpoint);

    // === DEAL WITH RESPONSE ===
    String result = this.getSOAPResult(soapResponse, "GetImageResult");

    // cast string result to a byte array before returning
    // can use Base64.encode(byte[] data) to encode the byte array back to a String 
    return Base64.decode(result);
  }

  //
  // ### GetSelectableWorkspaceLayers ###
  //
  // The endpoint and xmlNamespace variables must be set before using.
  public String[] GetSelectableWorkspaceLayers(String callContext, String workspaceName) throws Exception {

    // === CREATE THE MESSAGE WITH LOGIN COOKIE ===
    CartologyMessage Cmessage = new CartologyMessage(this.xmlNamespace, this.endpoint, "GetSelectableWorkspaceLayers", this.cookie);
   
    // === ADD THE PARAMETERS ===
    if (callContext != null && !callContext.equals("") ) {
      Cmessage.addParameter("callContext", callContext);
    }
    Cmessage.addParameter("WorkspaceName", workspaceName);
    Cmessage.addParameter("IdLayerGroup", "-1");

    // === CREATE AND MAKE CONNECTION, SEND MESSAGE, RECEIVE RESPONSE AND CLOSE CONNECTION ===
    SOAPMessage soapResponse = Cmessage.sendSOAPMessage(this.endpoint);

    // === DEAL WITH RESPONSE ===
    String[] result = this.getSOAPArrayResult(soapResponse, "GetSelectableWorkspaceLayersResult");

    return result;
  }

  //
  // ### GetSelectableWorkspaceLayers ###
  //
  // The endpoint and xmlNamespace variables must be set before using.
  public String GetLayerName(String callContext, String layerId) throws Exception {

    // === CREATE THE MESSAGE WITH LOGIN COOKIE ===
    CartologyMessage Cmessage = new CartologyMessage(this.xmlNamespace, this.endpoint, "GetLayerName", this.cookie);
   
    // === ADD THE PARAMETERS ===
    if (callContext != null && !callContext.equals("") ) {
      Cmessage.addParameter("callContext", callContext);
    }
    Cmessage.addParameter("layerId", layerId);

    // === CREATE AND MAKE CONNECTION, SEND MESSAGE, RECEIVE RESPONSE AND CLOSE CONNECTION ===
    SOAPMessage soapResponse = Cmessage.sendSOAPMessage(this.endpoint);

    // === DEAL WITH RESPONSE ===
    String result = this.getSOAPResult(soapResponse, "GetLayerNameResult");

    return result;
  }
}
