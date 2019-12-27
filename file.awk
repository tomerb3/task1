BEGIN{
    FS = ","
    colors[3] = "red"
    colors[4] = "green"
    colors[5] = "blue"

    print "<HTML><BODY>"
    print "<TABLE border=\"1\">"
    print "<TR><TH>FirstName</TH><TH>LastName</TH><TH>Username</TH></TR>"
}
NR>1 {
    printf "<TR>"
    for (i=1; i<=NF; i++) {
        if ( (i == NF) && ($i in colors) ) {
            on  = "<font color=\"" colors[$i] "\">"
            off = "</font>"
        }
        else {
            on = off = ""
        }
        printf "<TD>%s%s%s</TD>", on, $i, off
    }
    print "</TR>"
}
END {
    print "</TABLE>"
    print "</BODY></HTML>"
}
