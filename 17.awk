function getName(first, last) {
    #return sprintf("%s%s", first, last)
    return first last
}

BEGIN {
    count = 0
    DUPLICATE_THRESHOLD = 2
}

$1 !~ /FirstName/ {
    name = getName($1, $2)

    names[name]++
    if (names[name] == DUPLICATE_THRESHOLD) {
        count += 1
    }
}

END {
    printf("There are %d people out of %d with identical first and last names\n", count, (NR - 1))
}
