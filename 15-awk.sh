#!/usr/bin/env bash

# How many different office locations does the company have?

awk '$1 !~ /FirstName/ { print $5 }' payroll.tsv  \
    | sort \
    | uniq \
    | awk 'END { print NR }'

