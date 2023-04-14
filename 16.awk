#!/usr/bin/awk -f

NR>1 {S+=$3}
END {print S/(NR-1)}
