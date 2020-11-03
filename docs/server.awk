# usage:
# gawk -f server.awk server.xml > server.txt
#
# List docBase and path details from server.xml

BEGIN {
	FS = " ";
	active = "        ";
	print strftime();
	print ""
}

/<!--/ { active = "Inactive"}
/-->/  { active = "        "}

/<Context/ { printf "%1$-10s %2$-60s %3$-s\n", active, $8, $9 }

