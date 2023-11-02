cwd=$(pwd)
cwd_escaped=$(echo $cwd | awk '{ gsub("/", "%") ; print $0 }')

cache_dir=$HOME/.cache/pr_history/$cwd_escaped
history_file=$cache_dir/history.txt
temp_dir=$cache_dir/temp_files

mkdir -p $cache_dir
mkdir -p $temp_dir
touch $history_file

fswatch -o . | while read num; do
	# Create a list of current files and directories
	current_files=$(find . -type f -not -path '*/\.*' -not -path "$temp_dir/*" -print)

	# Loop through each file to check its status
	for file in $current_files; do
		# Ignore files in .git directory or specified by .gitignore
		if ! git check-ignore "$file" >/dev/null 2>&1 && [[ $file != ./.git* ]]; then
			relative_file=${file#./}
			temp_file="$temp_dir/$relative_file"

			# File creation
			if [ ! -f "$temp_file" ]; then
				echo "File created: $relative_file" >>$history_file
				date >>$history_file
				# Copy the new file to temp location
				mkdir -p "$(dirname "$temp_file")"
				cp "$file" "$temp_file"
			elif ! cmp -s "$temp_file" "$file"; then
				# File modification
				echo "File modified: $relative_file" >>$history_file
				date >>$history_file
				diff -u "$temp_file" "$file" >>$history_file
				cp "$file" "$temp_file"
			fi
		fi
	done

	# Check for file deletions
	for temp_file in $(find "$temp_dir" -type f); do
		relative_file=${temp_file#$temp_dir/}
		original_file="./$relative_file"

		if [ ! -f "$original_file" ]; then
			echo "File deleted: $relative_file" >>$history_file
			date >>$history_file
			# Remove the temp file
			rm "$temp_file"
		fi
	done
done
