#!/bin/sh -eu

awk 'NR>1{print $3}END{print int(NR/2) > "/tmp/foo" }' payroll.tsv | sort -n | head -n $(cat /tmp/foo) | tail -n 1
