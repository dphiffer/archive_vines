#!/bin/bash

# Usage:
#   archive_vines.sh "user@example.com" "password"

# Saves each of your Vine video, image, and metadata in a timeline folder.

function vine_auth() {

    user="$1"
    pass="$2"

    if [ ! -d cache ] ; then
        mkdir cache
    fi

    echo "Logging in ..."
    curl -s -XPOST \
         -H "user-agent: comcache.iphone/1.0.3 (unknown, iPhone OS 6.1.0, iPhone, Scale/2.000000)" \
         -H "accept-language: en, sv, fr, de, ja, nl, it, es, pt, pt-PT, da, fi, nb, ko, zh-Hans, zh-Hant, ru, pl, tr, uk, ar, hr, cs, el, he, ro, sk, th, id, ms, en-GB, ca, hu, vi, en-us;q=0.8" \
         -d "username=$user&password=$pass" \
         https://api.vineapp.com/users/authenticate \
         | jq . \
         > cache/auth.json
    success=`jq ".success" cache/auth.json`
    if [ "$success" == "false" ] ; then
        error=`jq -r ".error" cache/auth.json`
        rm cache/auth.json
        echo "$error"
    else
        download_timeline
    fi
}

function download_timeline() {

    if [ -z "$1" ] ; then
        page=1
    else
        page="$1"
    fi

    key=`jq -r ".data.key" cache/auth.json`
    user_id=`echo "$key" | cut -d'-' -f1`

    if [ ! -d cache ] ; then
        mkdir cache
    fi
    if [ ! -d timeline ] ; then
        mkdir timeline
    fi

    timeline_url="https://api.vineapp.com/timelines/users/$user_id?page=$page"

    echo "---------------------------------------"
    echo "Timeline page $page"

    if [ ! -f "cache/timeline$page.json" ] ; then
        curl -s \
             -H "user-agent: comcache.iphone/1.0.3 (unknown, iPhone OS 6.1.0, iPhone, Scale/2.000000)" \
             -H "vine-session-id: $key" \
             -H "accept-language: en, sv, fr, de, ja, nl, it, es, pt, pt-PT, da, fi, nb, ko, zh-Hans, zh-Hant, ru, pl, tr, uk, ar, hr, cs, el, he, ro, sk, th, id, ms, en-GB, ca, hu, vi, en-us;q=0.8" \
             $timeline_url \
             | jq . \
             > "cache/timeline$page.json"
    else
        echo "(Using Cached)"
    fi

    num_records=`jq ".data.records | length" "cache/timeline$page.json"`
    num_records="$(($num_records + 0))"
    for (( i=0; i<"$num_records"; i++ )) ; do
        download_vine $page $i
    done

    next_page=`jq ".data.nextPage" "cache/timeline$page.json"`
    if [[ "$next_page" != "null" && ! -z "$next_page" ]] ; then
        download_timeline $next_page
    else
        echo "---------------------------------------"
        echo "Done."
    fi
}

function download_vine() {
    page="$1"
    num="$2"
    post_id=`jq ".data.records[$num].postId" cache/timeline$page.json`
    created_date=`jq -r ".data.records[$num].created" cache/timeline$page.json | cut -c1-10`
    basename="timeline/$created_date-$post_id"
    jq ".data.records[$num]" "cache/timeline$page.json" > "$basename.json"
    description=`jq -r ".data.records[$num].description" "cache/timeline$page.json"`
    vine_url=`jq -r ".data.records[$num].permalinkUrl" "cache/timeline$page.json"`
    jpg_url=`jq -r ".data.records[$num].thumbnailUrl" "cache/timeline$page.json"`

    echo "---------------------------------------"
    echo "$created_date-$post_id"
    echo "$vine_url"
    echo "$description"

    if [ ! -f "$basename.mp4" ] ; then
        echo "Downloading video"
        youtube-dl -q -o "$basename.mp4" $vine_url
    else
        echo "(Video already downloaded)"
    fi

    if [ ! -f "$basename.jpg" ] ; then
        echo "Downloading image"
        curl -s -o "$basename.jpg" "$jpg_url"
    else
        echo "(Image already downloaded)"
    fi
}

# Ok, we are doing stuff now!

# Check dependencies
command -v youtube-dl >/dev/null 2>&1 || { echo >&2 "I require 'youtube-dl' but it's not installed."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "I require 'curl' but it's not installed."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "I require 'jq' but it's not installed."; exit 1; }

if [ ! -f cache/auth.json ] ; then

    echo "Vine does support Twitter OAuth, but I didn't implement it here. Sorry, we just"
    echo "gotta go with username/password. We cache this in 'cache/auth.json' so if you"
    echo "don't want to leave your credentials on disk, that's the file to clean up."
    echo

    read -p "Email address: " email
    read -s -p "Password: " password

    vine_auth $email $password

else

    # We alrady have a session key, so we're cool
    echo "Using your cached auth credentials..."
    download_timeline

fi
