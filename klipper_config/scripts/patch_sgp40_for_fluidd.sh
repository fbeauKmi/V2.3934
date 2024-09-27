#!/bin/env bash

# patch index of fluidd to recognize SGP40

search_dir="${HOME}/fluidd/assets/"

echo "Stop Nginx"
service nginx stop

# Find files named index*.js and replace the expression
find "$search_dir" -type f -name 'index*.js' -print0 | while IFS= read -r -d '' file; do
    # Replace the expression using sed
    sed -i 's/,"nevermoresensor"/,"sgp40"/g' "$file"
    echo "Replaced in $file"
done

echo "Replacement completed."
service nginx start
echo "Nginx server restarted."
