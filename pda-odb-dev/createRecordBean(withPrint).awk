# usage:
# awk -f createRecordBean(withPrint).awk #FILENAME#
#
# #FILENAME# is the filename to check for field names in. Format of the file is
# #TYPE# #FIELD-NAME#
# Eg.
# String customer
#
# Eg.
# awk -f createRecordBean(withPrint).awk fieldList.txt
# gawk -f createRecordBean(withPrint).awk fieldList.txt
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
print "import java.io.*;"
print "import java.util.*;"
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
print ""
print "  public void print() {"
print "    try {"
print "      BufferedWriter out1 = new BufferedWriter(new FileWriter(\"c:\\\\temp\\\\recordBean.txt\"));"
for(item in props) {
print "      out1.write( \""item" \" + get" capital(item) "() );"
print "      out1.newLine();"
}
print "      out1.close();"
print "    } catch (IOException e) {"
print "      // e.printStackTrace();"
print "      // System.out.println(\"Exception\");"
print "      System.out.println(stack2string(e));"
print "    }"
print "  }"
print ""
print "  public static String stack2string(Exception e) {"
print "    try {"
print "      StringWriter sw = new StringWriter();"
print "      PrintWriter pw = new PrintWriter(sw);"
print "      e.printStackTrace(pw);"
print "      return \"------\\r\\n\" + sw.toString() + \"------\\r\\n\";"
print "    } catch(Exception e2) {"
print "      return \"An exception has occurred in stack2string\";"
print "    }"
print "  }"
print "}"
}
