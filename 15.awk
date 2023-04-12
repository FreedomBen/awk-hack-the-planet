#!/usr/bin/awk -f

NR>1 {A[$5]+=1}
END {print length(A)}

