file_or_string() {
	if [ -f $1 ]
		then
		cat $1
	else
		echo $1
	fi
}


by4() {
	file_or_string $1 | awk '{print ($1/4)}'
}

by2() {
	file_or_string $1 | awk '{print ($1/2)}'
}

total() {
	file_or_string $1 | awk '{s+=$1} END {print s}'
}

month_hours() {
	file_or_string $1 | awk '{print ($1 * 24 * 30)}'
}
