#!/bin/bash

# set default values
verbose="1"
user="none"
group="none"
log="none"
pswd="none"

while getopts "v:u:g:l:p:" flag
do 
case "${flag}" in
    v) verbose="${OPTARG}";;
    u) user="${OPTARG}";;
    g) group="${OPTARG}";;
    l) log="${OPTARG}";;
    p) pswd="${OPTARG}";;
esac
done

 ## 
if [ "$verbose" != "0" ]; then
# if verbosity is not 0  (1,2)show all users and all groups
 getent passwd {1000..60000}
 getent group

    if [ "$verbose" == "2" ]; then
    #if verbosity is 2 highest level also display all passwords and log info
        cat /var/secure/user_passwords.txt
        cat /var/log/user_management.log
    fi
 fi

 if [ "$group" != "none" ]; then
    echo "search $group in groups\n \n"
    cat /etc/group | grep "$group"
 fi
 
 if [ "$user" != "none" ]; then
    echo "search $user in  userss\n \n"
     getent passwd {1000..60000} | grep "$user"
 fi

if [ "$pswd" != "none" ]; then
cat /var/secure/user_passwords.txt
fi

if [ "$log" != "none" ]; then
cat /var/log/user_management.log
fi