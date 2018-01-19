#!/usr/bin/env bash

user=$1
password=$2

pass_hash=$(echo -n $password{$user} | sha256sum | awk '{print $1}')

echo $user:$password:$pass_hash > /opt/puppet_jenkins/out.txt

sed -i -E "s/<passwordHash>.+<\/passwordHash>/<passwordHash>$user:$pass_hash<\/passwordHash>/" \
    /var/lib/jenkins/users/$user/config.xml

