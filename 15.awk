# Use variable to count each occurrence of any engineer

BEGIN           { count = 0 }
$6 ~ /Engineer/ { count += 1 }
END             { print count }
