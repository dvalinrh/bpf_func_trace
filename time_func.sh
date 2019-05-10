#!/bin/bash

#
# Shell scrpt that takes 2 arguments, a kernel function name, and
# command to run.  The script then builds a bpftrace script to track
# the time spent in the designated function.  It then runs the script
# with the designated command and arguments.  Usage
# 
# time_func.sh do_idle test_program
#
# time_func.sh do_idle "sleep 30"
#
printf "#%c/usr/local/bin/bpftrace\n" '!' > temp.bt
printf "kprobe:${1}\n" >> temp.bt
printf "{\n" >> temp.bt
printf "\t@track[tid] = 1;\n" >> temp.bt
printf "\t@start_time[tid] = nsecs;\n" >> temp.bt
printf "}\n\n" >> temp.bt

printf "kretprobe:${1}\n" >> temp.bt
printf "\t/ @track[tid] == 1 /\n" >> temp.bt
printf "{\n" >> temp.bt
printf "\t@timeing = hist(nsecs - @start_time[tid]);\n" >> temp.bt
printf "\tdelete(@track[tid]);\n" >> temp.bt
printf "\tdelete(@start_time[tid]);\n" >> temp.bt
printf "}\n\n" >> temp.bt

printf "END\n" >> temp.bt
printf "{\n" >> temp.bt
printf "\tdelete(@start_time);\n" >> temp.bt
printf "\tdelete(@track);\n" >> temp.bt
printf "}\n" >> temp.bt

chmod 755 temp.bt
bpftrace -c "${2}" ./temp.bt
