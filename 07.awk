BEGIN    { count = 0 }
$1 == $2 { count += 1 }
END      {
    printf("There are %s people with identical first and last names\n", (count > 0) ? count : "no")
}
