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
/<head>/ {
  print $0 > file2
  print "  <!-- Set iPhone OS Safari attributes -->" > file2
  print "  <meta name = \"viewport\" content = \"width = device-width\">" > file2
  print "" > file2
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
