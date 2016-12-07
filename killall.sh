killall() {
    ps -e | grep $1 | cut -f 1 -d " " | xargs kill -9
}