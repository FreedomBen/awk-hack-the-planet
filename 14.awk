#!/usr/bin/awk -f

{
    printf "%s:\t", NR
    for (i = 3; i <= NF; i++) {
        #printf FS$i
        printf "%s\t", $i
    }
    print NL # New line
}

