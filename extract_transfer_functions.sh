#!/bin/bash

# Create output file
echo ";; All transfer functions from fungible token contracts" > all_transfer_functions.clar
echo ";; Found $(wc -l < fungible_token_files.txt) fungible token contracts" >> all_transfer_functions.clar
echo "" >> all_transfer_functions.clar

# Counter for progress
counter=0
total=$(wc -l < fungible_token_files.txt)

# Process each file
while IFS= read -r file; do
    ((counter++))
    echo "Processing $counter/$total: $file"
    
    # Add contract header
    echo ";; ===== $file =====" >> all_transfer_functions.clar
    
    # Extract transfer function using awk
    awk '
    /^\(define-public \(transfer\s+\(/ {
        in_function = 1
        paren_count = 0
        function_text = $0
        for (i = 1; i <= length($0); i++) {
            char = substr($0, i, 1)
            if (char == "(") paren_count++
            if (char == ")") paren_count--
        }
        if (paren_count == 0) {
            print function_text
            in_function = 0
        }
        next
    }
    
    in_function == 1 {
        function_text = function_text "\n" $0
        for (i = 1; i <= length($0); i++) {
            char = substr($0, i, 1)
            if (char == "(") paren_count++
            if (char == ")") paren_count--
        }
        if (paren_count == 0) {
            print function_text
            in_function = 0
        }
    }
    ' "$file" >> all_transfer_functions.clar
    
    echo "" >> all_transfer_functions.clar
    
done < fungible_token_files.txt

echo "Done! Transfer functions saved to all_transfer_functions.clar"
