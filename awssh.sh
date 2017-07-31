instance_named() {
	aws --output text ec2 describe-instances --filters "Name=tag:Name,Values=$1"
}

instance_url() {
	grep -m 1 "INSTANCES" | cut -f 14 
}

instance_keyname() {
	grep -m 1 "INSTANCES" | cut -f 10 
}

instance_id() {
	grep -m 1 "INSTANCES" | cut -f 8
}


instance_state() {
	grep -m 1 "STATE" | cut -f 3 
}

instance_sg() {
	grep -m 1 "SECURITYGROUPS" | cut -f 2
}

awssh() {
	OPTIND=1
	sg=0
	while getopts ":a" opt; do
	  case $opt in
	    a)
	      sg=1 
	      ;;
	    \?)
	      echo "Invalid option: -$OPTARG" >&2
	      ;;
	  esac
	done
	shift $((OPTIND-1))
	[ "$1" = "--" ] && shift

	local url
	local keyname
	name=$@
	echo $name | grep ".*\..*\..*" &> /dev/null
	if [ $? -eq 0 ]; then
		url=$name
		keyname="hyraxbio"
	else
		data=`instance_named "$name"`
		if [ $sg -eq 1 ]; then 
			myip=$(curl http://ipv4bot.whatismyipaddress.com/ 2> /dev/null)
			sgid=$(echo "$data" | instance_sg)
			echo "Authorizing $myip in $sgid"
			aws --region eu-west-1 ec2 authorize-security-group-ingress --group-id $sgid --protocol tcp --port 22 --cidr $myip/24
		fi
		if [ $(echo "$data" | instance_state) = "stopped" ]; then
			echo "Instance is stopped please wait."
			id=`echo "$data" | instance_id`
			aws ec2 start-instances --instance-ids $id &> /dev/null
			aws ec2 wait instance-status-ok --instance-ids $id
			data=`instance_named "$name"`	
		fi
		url=`echo "$data" | instance_url`
		keyname=`echo "$data" | instance_keyname`
	fi

	if [ ! -z $url ]; then
		echo "Logging in to $url"
		ssh -i ~/.ssh/$keyname.pem ec2-user@$url
		if [ $sg -eq 1 ]; then 
			echo "Revoking $myip in $sgid"
			aws ec2 --region eu-west-1 revoke-security-group-ingress --group-id $sgid --protocol tcp --port 22 --cidr $myip/24
		fi
	else
		echo "I don't know how to connect to: $name"
	fi
}


awscp() {
    local url
    local keyname
    echo $1 | grep ".*\..*\..*" &> /dev/null
    if [ $? -eq 0 ]; then
        url=$1
        keyname="hyraxbio"
    else
        data=`instance_named "$1"`
        if [ $(echo "$data" | instance_state) = "stopped" ]; then
            echo "Instance is stopped please wait."
            id=`echo "$data" | instance_id`
            aws ec2 start-instances --instance-ids $id &> /dev/null
            aws ec2 wait instance-status-ok --instance-ids $id
            data=`instance_named "$1"`    
        fi
        url=`echo "$data" | instance_url`
        keyname=`echo "$data" | instance_keyname`
    fi
    if [ ! -z $url ]; then
        scp -i ~/.ssh/$keyname.pem ec2-user@$url:$2 .
    else
        echo "I don't know how to connect to: $1"
    fi
}



awscpto() {
    local url
    local keyname
    echo $1 | grep ".*\..*\..*" &> /dev/null
    if [ $? -eq 0 ]; then
        url=$1
        keyname="hyraxbio"
    else
        data=`instance_named "$1"`
        if [ $(echo "$data" | instance_state) = "stopped" ]; then
            echo "Instance is stopped please wait."
            id=`echo "$data" | instance_id`
            aws ec2 start-instances --instance-ids $id &> /dev/null
            aws ec2 wait instance-status-ok --instance-ids $id
            data=`instance_named "$1"`    
        fi
        url=`echo "$data" | instance_url`
        keyname=`echo "$data" | instance_keyname`
    fi
    if [ ! -z $url ]; then
        scp -i ~/.ssh/$keyname.pem $2 ec2-user@$url:$3
    else
        echo "I don't know how to connect to: $1"
    fi
}

