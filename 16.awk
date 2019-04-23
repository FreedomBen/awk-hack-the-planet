function getName(first, last) {
    #return sprintf("%s%s", first, last)
    return first last
}

BEGIN {
    count = 0
    marker = 9999
}

$1 !~ /FirstName/ {
    if (names[getName($1, $2)] == marker) {
        count += 1
    }
    names[getName($1, $2)] = marker
}

END {
    printf("There are %d people out of %d with identical first and last names\n", count, NR)
}
