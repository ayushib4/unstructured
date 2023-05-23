#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DOCS_FOLDER="$SCRIPT_DIR/docs"


SLOW_FILES=("book-war-and-peace.txt")
NUM_ITERATIONS=${NUM_ITERATIONS:-2}
INSTANCE_TYPE=${INSTANCE_TYPE:-"unspecified"}


# docker exec -it <container_name> "$SCRIPT_DIR/get-stats-name.sh"

function process_file() {
    filepath=$1
    python3.8 -c 'from unstructured.partition.auto import partition; partition("'"$filepath"'")[3]'
}

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
CSV_FILE="$SCRIPT_DIR/results/${DATE}_benchmark_results_${INSTANCE_TYPE}_$("$SCRIPT_DIR/get-stats-name.sh").csv"
echo "Test File,Iterations,Execution Time (s)" > "$CSV_FILE"

for file in "$TEST_DOCS_FOLDER"/*; do
    echo "Testing file: $(basename "$file")"

    if [[ " ${SLOW_FILES[@]} " =~ " $(basename "$file") " ]]; then
        echo "File found in slow files list. Running once..."
        num_iterations=1
    else
        num_iterations=$NUM_ITERATIONS
    fi

    total_execution_time=0
    for ((i = 1; i <= num_iterations; i++)); do
        echo "Iteration $i"
        time_response=$( { time process_file "$file"; } 2>&1 )
        if [ $? -ne 0 ]; then
            echo "$time_response" # time_response is the error message
            exit 1
        fi
        total_execution_time=$(echo "$total_execution_time + $time_response" | bc)
    done
    average_time_seconds=$(echo "scale=3; $total_execution_time / $num_iterations" | bc)
    echo "$(basename "$file"),$num_iterations,$average_time_seconds" >> "$CSV_FILE"
done

echo "Benchmarking completed. Results saved to $CSV_FILE"

