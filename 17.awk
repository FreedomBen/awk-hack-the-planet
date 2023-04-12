#!/usr/bin/awk -f

++A[$1$2]==2 {T++}
END {print T}
