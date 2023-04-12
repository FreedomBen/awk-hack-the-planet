#!/usr/bin/awk -f

{$1="";$2="";print(substr($0,3))}
