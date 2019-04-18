BEGIN {
    highest = 0
    name = ""
}

$0 !~ /HourlyWage/ {
    if ($3 > highest) {
        highest = $3
        name = sprintf("%s %s", $1, $2)
    }
}

END {
    printf "Highest paid person is %s who makes $%.2f/hour\n", name, highest
}
