instance_named() {
	aws --output text ec2 describe-instances --filters "Name=tag:Name,Values=$1"
}

instance_url() {
	grep -m 1 "INSTANCES" | cut -f 14 
}

instance_keyname() {
	grep -m 1 "INSTANCES" | cut -f 10 
}

awssh() {
	local url
	local keyname
	echo $1 | grep ".*\..*\..*" &> /dev/null
	if [ $? -eq 0 ]; then
		url=$1
		keyname="hyraxbio"
	else
		data=`instance_named "$1"`
		url=`echo "$data" | instance_url`
		keyname=`echo "$data" | instance_keyname`
	fi

	if [ ! -z $url ]; then
		ssh -i ~/.ssh/$keyname.pem ec2-user@$url
	else
		echo "I don't know how to connect to: $1"
	fi
}
