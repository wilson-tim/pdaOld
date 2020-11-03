package com.ws;

import javax.xml.soap.*;
import java.net.URL;
import org.w3c.dom.NodeList;

public class CartologyMessage {
  private SOAPMessage message = null;
  private SOAPBodyElement bodyElement = null;

  public CartologyMessage(String xmlNamespace, String endpoint, String SOAPMethodName) throws Exception {
    // Create a message using a MessageFactory object.
    MessageFactory factory = MessageFactory.newInstance();
    this.message = factory.createMessage(); 
   
    // Add the SOAPAction to the HTTP header
    MimeHeaders hd = this.message.getMimeHeaders();
    hd.addHeader("SOAPAction", xmlNamespace + SOAPMethodName);

    // Access message parts so that content can be added.
    // The SOAPMessage object message contains a SOAPPart object,
    // so you use message to retrieve it. 
    SOAPPart soapPart = this.message.getSOAPPart();
    
    //Use soapPart to retrieve the SOAPEnvelope object that it contains. 
    SOAPEnvelope envelope = soapPart.getEnvelope();

    //Use envelope to retrieve the empty SOAPHeader object. 
    SOAPHeader header = envelope.getHeader();

    // Standalone client does not use a SOAP header, so you can delete it.
    // Because all SOAPElement objects, including SOAPHeader objects, are
    // derived from the Node interface, you use the method Node.detachNode
    // to delete header.
    // It works just as well if not detached, and left blank, but just to be
    // on the safe side it is best to delete it.
    header.detachNode();

    //Use envelope to retrieve the empty SOAPBody object. 
    SOAPBody body = envelope.getBody();
    
    // Create a Name object for the element to be added, and add a new
    // SOAPBodyElement object to body.
    Name bodyName = envelope.createName(SOAPMethodName, "", xmlNamespace);
    this.bodyElement = body.addBodyElement(bodyName);
  }

  public CartologyMessage(String xmlNamespace, String endpoint, String SOAPMethodName, String cookie) throws Exception {
    this(xmlNamespace, endpoint, SOAPMethodName);
    
    // Add the Cookie to the HTTP header
    MimeHeaders hd = this.message.getMimeHeaders();
    hd.addHeader("Cookie", cookie);
  }
  
  // Create and make connection, send message, receive response and close connection
  public SOAPMessage sendSOAPMessage(String stringEndpoint) throws Exception {
    SOAPConnectionFactory scFactory = SOAPConnectionFactory.newInstance();
    SOAPConnection con = scFactory.createConnection();

    java.net.URL endpoint = new URL(stringEndpoint);
    SOAPMessage soapResponse = con.call(this.message, endpoint);
    con.close();

    return soapResponse;
  }
  
  public SOAPMessage getSOAPMessage() {
    return this.message;
  }

  // Add a SOAPElement called elementName to the SOAPBodyElement
  public SOAPElement addElement(String elementName) throws Exception {
    SOAPElement soapElement = this.bodyElement.addChildElement(elementName);

    return soapElement;
  }

  // Add a SOAPElement called elementName to the SOAPElement passed in
  public SOAPElement addElement(SOAPElement soapElement, String elementName) throws Exception {
    SOAPElement soapChildElement = soapElement.addChildElement(elementName);

    return soapChildElement;
  }

  // Add a SOAPElement (parameter) called parameterName, to the SOAPBodyElement, with a value of parameterValue
  public void addParameter(String parameterName, String parameterValue) throws Exception {
    // The SOAPBody contains a SOAPBodyElement object identified by a Name object,
    // need to create a child element for the symbol using the method addChildElement.
    // Give it a value using the method addTextNode. The Name object for the new SOAPElement
    // object symbol is initialized with only a local name, which is allowed for child elements.
    SOAPElement parameter = this.bodyElement.addChildElement(parameterName);
    parameter.addTextNode(parameterValue);
  }

  // Add a SOAPElement (parameter) called parameterName, to the SOAPElement passed in, with a value of parameterValue
  public void addParameter(SOAPElement soapElement, String parameterName, String parameterValue) throws Exception {
    // The SOAPBody contains a SOAPBodyElement object identified by a Name object,
    // and the SOAPBodyElement can have many SOAPElements, and each of these SOAPElements
    // can have SOAPElements added to them etc...
    // Need to create a child element for the symbol using the method addChildElement.
    // Give it a value using the method addTextNode. The Name object for the new SOAPElement
    // object symbol is initialized with only a local name, which is allowed for child elements.
    SOAPElement parameter = soapElement.addChildElement(parameterName);
    parameter.addTextNode(parameterValue);
  }
}
