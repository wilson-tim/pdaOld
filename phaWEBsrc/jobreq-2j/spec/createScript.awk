# usage:
# awk -f createScript.awk form="#FORM#" previous_form="#PREVIOUS-FORM#" next_form="#NEXT-FORM#" #TEMPLATE#
#
# #FORM# is the name of the form the script is for.
# #PREVIOUS-FORM# is the name of the previous form the script was called from.
# #NEXT-FORM# is the name of the next form the script will call.
# #TEMPLATE# is the filename used as a template to create the script.
# The template contains #ATTRIBUTE# markers which are replaced by those given by the user.
#
# Eg.
# awk -f createScript.awk form="myList" previous_form="home" next_form="details" VSB_ScriptTemplate.txt
#
BEGIN {}

{
  gsub(/#FORM#/,form,$0)
  gsub(/#PREVIOUS-FORM#/,previous_form,$0)
  gsub(/#NEXT-FORM#/,next_form,$0)
  print $0
}

END {}