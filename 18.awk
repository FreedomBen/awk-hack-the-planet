#!/usr/bin/awk -f

BEGIN {d="9999/99/99"}
NR>1&&$NF<d {r=$1" "$2": "$NF;d=$NF}
END {print r}
