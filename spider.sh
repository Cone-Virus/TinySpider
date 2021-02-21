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
        echo "Usage: ./spider.sh <Option>

--Options--
-H <Target URL>                  : Spiders Target URL
-X <Target URL with sitemap.xml> : Spiders sitemap
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
                        sitemapcheck=$(cat $robot | grep "sitemap.xml" | cut -d " " -f 2)
                        if ! [[ -z "$sitemapcheck" ]]
                        then
                                sitemapspider $sitemapcheck
                        else
                                echo "Sitemap not found"
                        fi
                fi
        fi
        rm $robot
}

#Parse Sitemap
function sitemapspider()
{
        sitemap=$(mktemp SITE-XXXXX)
        curl -s -o "$sitemap" "$1"
        results=$(cat $sitemap | sed -n 's/<loc>\(.*\)<\/loc>/\1/p')
        for i in $results
        do
                echo "Sitemap results for $i"
                if [[ "$i" == *".xml" ]]
                then
                        curl -s -o "$sitemap" "$i"
                        currentsitemap=$(cat $sitemap | sed -n 's/<loc>\(.*\)<\/loc>/\1/p')
                        for a in $currentsitemap
                        do
                                echo $a
                        done
                fi
        done
        rm $sitemap
}


#Options
if [[ $# == 0 ]]
then
        help_menu
elif [[ "$1" == "-H" ]]
then
        simplespider $2
        robotspider $2
elif [[ "$1" == "-X" ]]
then
        sitemapspider $2
else
        help_menu
fi

