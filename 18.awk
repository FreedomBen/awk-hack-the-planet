function getName(first, last) {
    return sprintf("%s %s", $1, $2)
}

BEGIN {
    lowestYear = 9999
    lowestMonth = 99
    lowestDay = 99
    name = ""
}

$0 !~ /HourlyWage/ {
    split($7, date, "/")
    if (date[1] < lowestYear) {
        lowestYear = date[1]
        lowestMonth = date[2]
        lowestDay = date[3]
        name = getName($1, $2)
    }
    if (date[1] == lowestYear && date[2] < lowestMonth) {
        lowestMonth = date[2]
        lowestDay = date[3]
        name = getName($1, $2)
    }
    if (date[1] == lowestYear && date[2] == lowestMonth && date[3] < lowestDay) {
        lowestDay = date[3]
        name = getName($1, $2)
    }
}

END {
    printf "%s was the first employee hired on %d/%d/%d\n", name, lowestYear, lowestMonth, lowestDay
}
