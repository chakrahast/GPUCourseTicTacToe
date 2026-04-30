#!/bin/bash

RUNS=50
N_VALUES="2 3 4 5 6"
OUTPUT_FILE="table.txt"

echo "Building project..."
make clean
make build

# Header
echo "Benchmark Results (Each averaged over $RUNS runs)" > $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE
printf "%-10s %-15s\n" "N" "Avg_Time(sec)" >> $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE

for N in $N_VALUES
do
    echo "Running for N=$N"

    # start time (seconds)
    start=$(date +%s)

    for i in $(seq 1 $RUNS)
    do
        ./game.exe $N > /dev/null 2>&1
    done

    # end time
    end=$(date +%s)

    total=$((end - start))

    # compute average per run
    avg=$(awk -v t="$total" -v r="$RUNS" 'BEGIN {printf "%.6f", t / r}')

    printf "%-10s %-15s\n" "$N" "$avg" >> $OUTPUT_FILE
done

echo "-----------------------------------------" >> $OUTPUT_FILE

echo "Done. Results saved to $OUTPUT_FILE"