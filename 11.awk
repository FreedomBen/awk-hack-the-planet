# Use variable to count each occurrence of mechanical engineer

BEGIN    { count = 0 }
$1 == $2 { count += 1 }
END      {
    printf("There are %d people with identical first and last names\n", (count > 0) ? count : "no")
}
