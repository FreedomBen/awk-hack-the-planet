#!/usr/bin/awk -f

{
    for (i = 3; i <= NF; i++) {
        #printf FS$i
        printf "%s\t", $i
    }
    print NL
}

