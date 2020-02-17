/^FirstName/ {
    for (i=1; i<8; i++)
        printf "%d - %s\n", i, $i
}
