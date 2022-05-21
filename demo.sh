set -x

cwd=$(pwd)
cwd_escaped=$(echo $cwd | awk '{ gsub("/", "%") ; print $0 }')

cache_dir=$HOME/.cache/pr_history/$cwd_escaped
history_file=$cache_dir/history.txt

mkdir -p $cache_dir
touch $history_file

fswatch . | while read file; do
	if [[ $file != $cwd/.git* ]]; then
		date >>$history_file
		git --no-pager diff --no-color $file >>$history_file
	fi
done
