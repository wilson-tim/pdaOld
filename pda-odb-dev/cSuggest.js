/******************************************************************************
* CONTENDER SUGGEST:                                                          *
* Date: 27/10/2006                                                            *
* Javascript functions used to implement the CSuggest functionality.          *
* Copyright © 2006 DataPro Software Ltd. All rights Reserved                  *
*                                                                             *
* These functions are used to collect an input string from a text field in    *
* the page and send it to a jsp page for processing. The returned values from *
* the jsp are a group of suggestions gathered from the database, which will   *
* attempt to reduce the number of keystrokes the user needs to complete the   *
* field. The returned values are drawn below the input field the user is      *
* filling in, and can be select by clicking the mouse over a specific         *
* suggestion.                                                                */  
var xmlHttp;  // The xmlhttp request element 
             // that allows AJAX functionality

var currentTextFieldID;  // A variable to store which text field was the last
                         // to recieve an http response

/**********************************************************
* Main function that is called everytime a key is pressed.*
* Checks to see if the input field contains valid input,  *
* then calls the jsp page that will process the string    *
* and sets the function that will await the response.     *
*                                                        */
function showHint( queryString, textFieldID )
{
  if (queryString.length==0)
  { 
    document.getElementById( "cSuggest" ).innerHTML="";
    return;
  }
  xmlHttp=GetXmlHttpObject()
  if (xmlHttp==null)
  {
    alert ("Browser does not support HTTP Request");
    return;
  }
  // If the string is valid send the request
  if( isValidString( queryString ) ){
    currentTextFieldID = textFieldID; 
    var url="cSuggest.jsp";
    url=url+"?queryString="+queryString;
    url=url+"&textFieldID="+textFieldID;
    // url=url+"&sid="+Math.random();
    xmlHttp.onreadystatechange=stateChanged;
    xmlHttp.open("GET",url,true);
    xmlHttp.send(null);
  }
} 

/**********************************************************
* Function called when the xmlhttp request object returns *
* with the resulting suggestions. Checks for a succesful  *
* response and then draws the results on the page.        *
*                                                        */
function stateChanged() 
{
  if (xmlHttp.readyState==4 || xmlHttp.readyState=="complete")
  {
    var cSuggestBlock = document.getElementById("cSuggest");
    cSuggestBlock.innerHTML=xmlHttp.responseText;
    redraw();
  }
  return;
}

/**********************************************************
* Function used to redraw the suggestion table and spans  *
* in the correct location. This location is decided by    *
* finding the position of the input box, along with its   *
* height and width values, and using them to calculate a  *
* new location for the suggestion table.                  *
*                                                         */
function redraw() 
{ 
  // Get the element above the suggest bar so as to mirror
  // its width and height.
  var aboveBlock    = document.getElementById( currentTextFieldID );
  var arrayXY = new Array();
  arrayXY     = findPos(aboveBlock);

  // Store the above elements height/width
  var aboveBlockHeight = getElementHeight(aboveBlock);
  var aboveBlockWidth  = getElementWidth(aboveBlock);

  // Get the suggest bar
  var cSuggestBlock = document.getElementById("cSuggest");
  // Sets the top left corner of the suggest bar
  // The height is set to below the above input field - 1
  // so that that the borders of the two elements cross.
  cSuggestBlock.style.left   = arrayXY[0];
  cSuggestBlock.style.top    = (arrayXY[1] + aboveBlockHeight - 1);

  // Set the width of the suggestion table
  var suggestionTable = document.getElementById("suggestTable");
  suggestionTable.style.width = aboveBlockWidth;

  // Set the width of the span suggestion elements
  // Need to reduce the width of the span so as not to extend
  // the limits of the table
  var suggestionSpans = document.getElementsByTagName("span");
  for( x = 0; x < suggestionSpans.length; x++ ){
    // 12/07/2010  TW  Avoid affecting the footer which also uses the span tag
    if(suggestionSpans[x].className.equals("suggest")){
      suggestionSpans[x].style.width = (aboveBlockWidth -10);
    }
  }
  return;
}

/**********************************************************
* Function that returns the XmlHttp request object after  *
* chekcing to see whether or not it exists.               *
*                                                        */
function GetXmlHttpObject()
{ 
  var objXMLHttp=null
  if (window.XMLHttpRequest)
  {
    objXMLHttp=new XMLHttpRequest()
  }
  else if (window.ActiveXObject)
  {
    objXMLHttp=new ActiveXObject("Microsoft.XMLHTTP")
  }
  return objXMLHttp
}


/**********************************************************
* Function called when a suggestion span is clicked.      *
* Transfers the text within the span to the input field   *
* and then clears the suggestion table.                   *
*                                                        */
function selectMe( thisObject, textFieldID ){
  var obj        = document.getElementById( textFieldID );
  // 12/07/2010  TW  Returns text including HTML markup, etc.
  // http://geekswithblogs.net/timh/archive/2006/01/19/66383.aspx
  // obj.value      = thisObject.innerHTML;
  if(thisObject.innerText){
    // Internet Explorer
    obj.value = thisObject.innerText;
  } else {
    if (thisObject.textContent) {
      // Firefox
      obj.value = thisObject.textContent;
    } else {
        obj.value = "This function is not supported by your browser.";
    }
  }
  var textHint   = document.getElementById("cSuggest");
  textHint.innerHTML = ""; 
}

/**********************************************************
* Simple functions used to alter the class of an object   *
* to hover. This is important as it mimics the 'hover'    *
* functionality in FireFox not supported in IE.           *
*                                                        */
function changeClassIn(thisObject){
  thisObject.className += ' hover';
}
// This function removes the hover class definition
function changeClassOut(thisObject){
  thisObject.className = 
    thisObject.className.replace(new RegExp(' hover\\b'), '');
}

/**********************************************************
* Function used to retrieve the X/Y coordinates of an     *
* element. This is used to find out where the input field *
* is, so as to correctly position the suggestion table.   *
*                                                        */ 
function findPos(obj) {
	var curleft = curtop = 0;
	if (obj.offsetParent) {
		curleft = obj.offsetLeft
		curtop = obj.offsetTop
		while (obj = obj.offsetParent) {
			curleft += obj.offsetLeft
			curtop += obj.offsetTop
		}
	}
	return [curleft,curtop];
}

/**********************************************************
* Simple function used to retrieve and elements width and *
* height. This may need to be expanded to support other   *
* browser type, since at the moment it only uses one      *
* property.                                               *
*                                                        */
function getElementHeight( elem ){
  var height = elem.offsetHeight;
  return height;
}
function getElementWidth( elem ){
  var width = elem.offsetWidth;
  return width;
}

/**********************************************************
* Simple function that clears the suggestion table when   *
* called.                                                 *
*                                                        */
function clearSuggest(){
  document.getElementById("cSuggest").innerHTML="";
  return;
}

/**********************************************************
* Function used to clear the suggestion box and run the   *
* showHint function. This is intended to be used when a   *
* text field with a suggest bar has been brought back into*
* focus while it has text in it.                          *
*                                                        */
function clearAndShow( queryString, textFieldID ){
  clearSuggest();
  showHint( queryString, textFieldID );
}

/**********************************************************
* Checks for characters that would effect the GET request *
* i.e http://localhost/thispage.jsp?querystring=% ,will   *
* through an error                                        *
*                                                        */
function isValidString( queryString ){
  var valid = true;
  var regEx = /[%,#]/;
  valid = regEx.test( queryString );
  return !valid;
}
