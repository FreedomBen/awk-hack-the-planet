BEGIN {
    highest = 0
    name = ""
}

$0 !~ /HourlyWage/ {
    if ($4 > highest) {
        highest = $4
        name = sprintf("%s %s", $1, $2)
    }
}

END {
    printf "%s worked the most hours at %d\n", name, highest
}
