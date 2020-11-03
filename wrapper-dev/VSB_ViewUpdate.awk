# This will take one or more files as input and run the changes
# in the changes section on each file.
# 
# call like:
#
# awk -f VSB_ViewUpdate.awk <file/s>
#
# eg. awk -f VSB_ViewUpdate.awk *.jsp
#

BEGIN {
  file2 = "temp"
  firstfile = "true"
}

FNR==1 && firstfile=="false" {
  close(file2)
  cmd1 = "del " file1
  cmd2 = "ren " file2 " " file1
  system(cmd1)
  system(cmd2)

  file1 = FILENAME
}

FNR==1 && firstfile=="true" {
  file1 = FILENAME
  firstfile = "false"
}

# CHANGES SECTION START

/<%@ taglib uri="http:\/\/jakarta.apache.org\/taglibs\/session-1.0\" prefix=\"sess\" %>/ {
  print "<%@ taglib prefix=\"c\" uri=\"http://java.sun.com/jstl/core\" %>" > file2
}

/<% response.sendRedirect\(\"/ {
  match($0, /".*"/)
  form = substr($0, RSTART, RLENGTH)
  match($0, /^[ \t]*/)
  white_space = substr($0, RSTART, RLENGTH)
  print white_space "<c:redirect url=" form " />" > file2
  skip = 2
}

# CHANGES SECTION END

{
  if (skip == 0) {
    print > file2
  } else {
    skip--
  }
}

END {
  close(file2)
  cmd1 = "del " file1
  cmd2 = "ren " file2 " " file1
  system(cmd1)
  system(cmd2)
}
