hi() {
	osascript -e 'display notification "Execution complete." with title "Done."'
}

alert() {
	osascript -e "display notification \"$1\" with title \"Alert.\""
}
