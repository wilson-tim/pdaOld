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
  cmd1 = "rm " file1
  cmd2 = "mv " file2 " " file1
  system(cmd1)
  system(cmd2)

  file1 = FILENAME
}

FNR==1 && firstfile=="true" {
  file1 = FILENAME
  firstfile = "false"
}

# CHANGES SECTION START

/<%@ page errorPage="error\.jsp" %>/ {
  print "<?xml version=\"1.0\"?>" > file2
  print "<%@ page contentType=\"application/xhtml+xml\" %>" > file2
  print $0 > file2
  skip = 1
}

/<!DOCTYPE HTML PUBLIC "-\/\/W3C\/\/DTD HTML 4\.01 Transitional\/\/EN">/ {
  print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">" > file2
  skip = 1
}

/<html>/ {
  print "<html xmlns=\"http://www.w3.org/1999/xhtml\">" > file2
  skip = 1
}

/<title>/ {
  print "  <meta http-equiv=\"Content-Type\" content=\"application/xhtml+xml\" />" > file2
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
  cmd1 = "rm " file1
  cmd2 = "mv " file2 " " file1
  system(cmd1)
  system(cmd2)
}
