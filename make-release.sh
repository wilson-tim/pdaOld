################################################################################
# make-release.sh <webapps dir> <webapp> <version>
# use like:
#   make-release.sh $CATALINA_HOME/webapps web 1b
#
################################################################################
WEBAPPSDIR=$1
WEBAPP=$2
WEBAPPDEV=$WEBAPPSDIR/$WEBAPP-dev
WEBAPPREL=$WEBAPPSDIR/$WEBAPP-rel
VERSION=$3

echo "This script will now create a new release using the following data:"
echo "  webapp  : $WEBAPPSDIR/$WEBAPP-dev"
echo "  version : $VERSION"
echo -n "Do you want to continue? (Y/N) "
read CONTINUE
CONTINUE=`echo $CONTINUE | awk '{gsub(/ /,""); print toupper($0)}'`

if test "$CONTINUE" = "N"
then
  exit
fi

if test ! -d $WEBAPPSDIR/$WEBAPP-dev
then
  echo
  echo "ERROR: $WEBAPPSDIR/$WEBAPP-dev does not exist."
  exit
fi

# Shutdown tomcat before doing anything
echo
echo "Shutting down tomcat ..."
$CATALINA_HOME/bin/shutdown.sh

echo
echo "Creating the new release directory from the current development one ..."

# if a release already exists then remove it, ready for the new one. 
if test -d $WEBAPPREL 
then
  rm -r $WEBAPPREL
fi

# make the release direcory by copying the current development directory
cp -r $WEBAPPDEV $WEBAPPREL

# now remove all the stuff that is not supposed to be in the release directory
rm $WEBAPPREL/*.txt
rm $WEBAPPREL/*.awk
rm $WEBAPPREL/test.jsp

if test -d $WEBAPPREL/VSB_Framework_*
then
  rm -r $WEBAPPREL/VSB_Framework_*
fi

if test -d $WEBAPPREL/spec
then
  rm -r $WEBAPPREL/spec
fi

# move the index.jsp to index.bak so that it is not precompiled
mv $WEBAPPREL/index.jsp $WEBAPPREL/index.bak

echo
echo "Now doing the precompilation of the release ..."

# now do the precompilation
$CATALINA_HOME/bin/precompile.sh $WEBAPPREL/WEB-INF/classes $WEBAPPREL/WEB-INF/auto-web-tmp.xml $WEBAPPREL $VERSION

# Do the tidy up after the precompilation
# remove all the JSP files
rm $WEBAPPREL/*.jsp

if test -d $WEBAPPREL/include 
then
  rm -r $WEBAPPREL/include
fi

# move the index back to a JSP file
mv $WEBAPPREL/index.bak $WEBAPPREL/index.jsp

# remove all the java source files
find $WEBAPPREL/WEB-INF/classes -name "*.java" -print | xargs rm

echo
echo "Now setting up the web.xml for the release ..."

# edit the auto-web.xml file
awk '
BEGIN {}

/<\/web-app>/ {
  exit
}

NR > 11 {
  gsub(/\t/,"  ", $0)
  print $0
}

END {}' $WEBAPPREL/WEB-INF/auto-web-tmp.xml > $WEBAPPREL/WEB-INF/auto-web-tmp2.xml
rm $WEBAPPREL/WEB-INF/auto-web-tmp.xml

# edit the auto-web.xml file removing the fpn_print_pages references
awk '
BEGIN {
  in_fpn_print_pages = "false"
}

/fpn_print_pages/ {
  in_fpn_print_pages = "true"
  next
}

in_fpn_print_pages == "true" && /<servlet>/ {
  in_fpn_print_pages = "false"
  next
}

in_fpn_print_pages == "true" && /<servlet-mapping>/ {
  in_fpn_print_pages = "false"
  next
}

NR > 1 && in_fpn_print_pages == "false" {
  print line
}

in_fpn_print_pages == "false" {
  # Store each line
  line=$0
  next
}

END {
  print line
}' $WEBAPPREL/WEB-INF/auto-web-tmp2.xml > $WEBAPPREL/WEB-INF/auto-web.xml
rm $WEBAPPREL/WEB-INF/auto-web-tmp2.xml

# copy the auto-web.xml file into the web.xml file at the right point
cp $WEBAPPREL/WEB-INF/web.xml $WEBAPPREL/WEB-INF/web-tmp.xml
awk '
BEGIN{
  copied="false"
  get_auto_web="true"
}

get_auto_web == "true" {
  # store $0 for later use
  store_line = $0

  # read webapprel/WEB-INF/auto-web.xml into an array, with a line number index
  auto_web_file = webapprel "/WEB-INF/auto-web.xml"
  line_no=0
  while ( (getline < auto_web_file) > 0) {
    # increment line counter
    line_no++

    # set up an array
    auto_web_xml[line_no] = $0
  }
  close(auto_web_file)

  line_count=line_no
  
  get_auto_web="false"

  # Put the stored $0 back to $0
  $0 = store_line
}

/<servlet-mapping>/ && copied == "false" {
  for(i=1; i<=line_count; i++) {
    print auto_web_xml[i]
  }
  copied="true"
}

/<session-config>/ && copied == "false" {
  for(i=1; i<=line_count; i++) {
    print auto_web_xml[i]
  }
  copied="true"
}

{ print $0 }

END {}' webapprel=$WEBAPPREL $WEBAPPREL/WEB-INF/web-tmp.xml > $WEBAPPREL/WEB-INF/web.xml
rm $WEBAPPREL/WEB-INF/web-tmp.xml

echo
echo "Now creating the release jar file ..."

cd $WEBAPPSDIR
jar cvfM $WEBAPP-$VERSION.jar $WEBAPP-rel

echo 
echo "DONE."
