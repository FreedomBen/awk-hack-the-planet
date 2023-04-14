#!/usr/bin/awk -f

{$1="";$2="";print(NR,substr($0,3))}

