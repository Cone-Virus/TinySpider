#!/bin/bash

echo "
▀█▀ █ █▄░█ █▄█   █▀ █▀█ █ █▀▄ █▀▀ █▀█
░█░ █ █░▀█ ░█░   ▄█ █▀▀ █ █▄▀ ██▄ █▀▄
Created by: @Cone_Virus     |
                            |
                           3oƐ 
"

function help_menu()
{
        echo "Usage: ./spider.sh <Target URL> 
        "
        exit 0
}

#Catch URL's on given webpage
function simplespider()
{
        result=$(curl -s $1)
        hrefresult=$(echo "$result" | sed -n 's/.*href="\([^"]*\).*/\1/p')
        srcresult=$(echo "$result" | sed -n 's/.*src="\([^"]*\).*/\1/p')
        for i in $hrefresult
        do
                if [[ "$i" == *"s3"* || "$i" == *"amazon"* ]]
                then
                        echo "Amazon Resource: $i"
                elif [[ "$i" == *"wp"* || "$i" == *"wordpress"* ]]
                then
                        echo "Wordpress: $i"
                else
                        if [[ "$i" == /* ]]
                        then
                                echo "Other: $1$i"
                        elif [[ "$i" == *"$1"* ]]
                        then
                                echo "Other: $i"
                        fi
                fi
        done
        for i in $srcresult
        do
                if [[ "$i" == *".js" ]]
                then
                        echo "Javascript: $i"
                else
                        echo "Other: $i"
                fi
        done
}

#Check Sitemap and robots file on surface level
function robotspider()
{
        ##Temp Files
        robot=$(mktemp ROBOT-XXXXX)
        #Robots
        result=$(curl -s -o /dev/null -w "%{http_code}" "$1/robots.txt")
        if [[ "$result" == "404"  || "$result" == "503" ]]
        then
                echo "Robots.txt not found."
        else
                curl -s -o "$robot" "$1/robots.txt" 
                check=$(cat $robot | grep User-agent)
                if [[ -z "$check" ]]
                then
                        echo "Robots.txt not found"
                else
                        echo "Robots.txt found"
                        echo "User Agents:"
                        cat $robot | grep "User-agent"
                        echo "Comments:"
                        cat $robot | grep "#"
                        echo "Resources:"
                        cat $robot | grep ".*: " | grep -v "User-agent" | grep -v "sitemap.xml" | cut -d " " -f2-
                        echo "Sitemap:"
                        sitemap=$(cat $robot | grep "sitemap.xml" | cut -d " " -f 2)
                        echo $sitemap
                fi
        fi
        rm $robot
}

if [[ $# == 0 ]]
then
        help_menu
else
        simplespider $1 
        robotspider $1
fi
