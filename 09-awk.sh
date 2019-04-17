#!/usr/bin/env bash

awk '$1 !~ /FirstName/ { print $5 }' payroll.tsv  \
    | sort \
    | uniq \
    | awk 'END { print NR }'

