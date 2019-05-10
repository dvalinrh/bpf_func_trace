# bpf_func_trace
Is a simple shell script that generates a bpftrace script to track the time spent in a given kernel function. Usage 

./time_func.sh <function name> "<command to execute>"

./time_func.sh do_idle ./test_program

./time_func.sh do_idle "sleep 60"


