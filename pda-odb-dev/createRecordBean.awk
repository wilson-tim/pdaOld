# usage:
# awk -f createRecordBean.awk #FILENAME#
#
# #FILENAME# is the filename to check for field names in. Format of the file is
# #TYPE# #FIELD-NAME#
# Eg.
# String customer
#
# Eg.
# awk -f createRecordBean.awk fieldList.txt
# gawk -f createRecordBean.awk fieldList.txt
#

#FUNCTIONS
function capital(_string, __first_letter) {
  __first_letter = toupper(substr(_string, 1, 1))
  return __first_letter substr(_string, 2)
}

BEGIN {}

# Get the name and type of the field
{
  if(!($2 in props)){
    props[$2]=$1
  }
}

# Output the bean
END {
print "package com.vsb;"
print ""
print "import com.db.DbUtils;"
print ""
print "public class recordBean {"
for(item in props) {
print "  private " props[item] " " item " = \"\";"
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
