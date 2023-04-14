NR>1 && ($4 > highest) {
    highest = $4
    name = sprintf("%s %s", $1, $2)
}

END {
    print name, "worked the most hours at ", highest
}
