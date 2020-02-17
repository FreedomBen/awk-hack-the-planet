function getName(first, last) {
    return sprintf("%s %s", $1, $2)
}

BEGIN {
    sum = 0
    count = 0
}

$0 !~ /HourlyWage/ {
    sum += $3
    count += 1
}

END {
    printf("The average wage is %.2f per hour\n", sum / count)
}
