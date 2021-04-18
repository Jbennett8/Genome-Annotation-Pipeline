#!/bin/bash
while IFS= read -r line; do
  pat='jobName=([A-Za-z0-9_.]+)'
  if [[ $line =~ $pat ]]; then
    printf '%-50s' "jobName=${BASH_REMATCH[1]}"
  fi
  pat2='Submitted batch job ([0-9]+).'
  if [[ $line =~ $pat2 ]]; then
    printf '%-20s\n' "jobID=${BASH_REMATCH[1]}"
  fi
done
