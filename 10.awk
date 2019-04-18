# Use variable to count each occurrence of mechanical engineer

BEGIN            { count = 0 }
$2 == "Portwood" { count += 1 }
END              { print count }
