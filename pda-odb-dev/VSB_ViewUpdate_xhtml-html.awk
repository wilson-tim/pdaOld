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

/<\?xml version="1\.0"\?>/ {
  skip = 1
}

/<%@ page contentType="application\/xhtml\+xml" %>/ {
  skip = 1
}

/<!DOCTYPE html PUBLIC "-\/\/W3C\/\/DTD XHTML 1\.0 Transitional\/\/EN" "http:\/\/www\.w3\.org\/TR\/xhtml1\/DTD\/xhtml1-transitional\.dtd">/ {
  print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">" > file2
  skip = 1
}

/<html xmlns="http:\/\/www\.w3\.org\/1999\/xhtml">/ {
  print "<html>" > file2
  skip = 1
}

/<meta http-equiv="Content-Type" content="application\/xhtml\+xml" \/>/ {
  skip = 1
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
