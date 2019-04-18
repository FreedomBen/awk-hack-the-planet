BEGIN          { sum = 0 }
$5 ~ /Seattle/ { sum += $3 }
END            { printf("The Seattle office costs %.2f per hour\n", sum) }
