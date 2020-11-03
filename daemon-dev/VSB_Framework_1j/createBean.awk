# usage:
# awk -f createBean.awk form="#FORM#" #FILENAME#
#
# #FORM# is the name of the form the bean is for.
# #FILENAME# is the filename to check for request parameters in.
# Usually #FORM#View.jsp
#
# Eg.
# awk -f createBean.awk form="home" homeView.jsp
#

#FUNCTIONS
function capital(_string, __first_letter) {
  __first_letter = toupper(substr(_string, 1, 1))
  return __first_letter substr(_string, 2)
}

BEGIN {
  searching = "false"
}

# Find select box
/<[ \t]*(select|SELECT)[ \t]/ {
  searching = "true"
}

# Find input field
/<[ \t]*(input|INPUT)[ \t]/ {
  searching = "true"
}

# Find textarea
/<[ \t]*(textarea|TEXTAREA)[ \t]/ {
  searching = "true"
}

# Get the name of the request field
searching == "true" && /name=[0-9a-zA-Z_]*|name="[0-9a-zA-Z_]*"/ {
  match($0,/name=[0-9a-zA-Z_]*|name="[0-9a-zA-Z_]*"/)
  name=substr($0,RSTART,RLENGTH)
  gsub(/"/,"",name)
  sub(/name=/,"",name)
  if(name!="input" && name!="action"){
    if(!(name in props)){
      props[name]=name
    }
  }
  searching = "false"
}

# Output the bean
END {
print "package com.vsb;"
print ""
print "import com.db.DbUtils;"
print ""
print "public class " form "Bean extends formBean {"
for(item in props) {
print "  private String " item " = \"\";"
}
for(item in props) {
print ""
print "  public String get" capital(item) "() {"
print "    return " item ";"
print "  }"
print "" 
print "  public void set" capital(item) "(String " item ") {"
print "    this." item " = DbUtils.cleanString(" item ");"
print "  }"
}
print ""
print "  public String getAll() {"
print "    return \"\";"
print "  }"
print ""
print "  public void setAll(String all) {"
for(item in props) {
print "    this." item " = \"\";"
}
print "  }"
print "}"
}
