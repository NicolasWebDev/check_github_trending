#! /bin/bash

# Features:
# When passed a list of github repos, find out the ones I have never checked and the ones that I have checked in the past, but the last time was more than 3 months ago.
# Those are the ones that I should check, so I should open them in the browser.
# I should create/update them in buku and set their timestamp to today.
# Cases:
# - never checked -> insert them w/date to today, open in browser
# - already checked, less than 3 months ago -> nothing
# - already checked, more than 3 months ago -> update them w/date to today, open in browser

insert_all_repos () {
    for url in $(cat $repos_file)
    do
        buku --add "$url" github trending -c checked "$(today)" >&/dev/null
    done
}

update_and_open_stale_repo () {
    local url="$1"

    local buku_id=$(buku --json --sreg "^$url$" | jq --raw-output '.[0].index')
    buku --update $buku_id --comment checked $(today)
    open_repo $url
}

open_repo () {
    local url="$1"

    chromium $url >&/dev/null
}

is_description_format_wrong () {
    local description="$1"

    echo $description | grep -qv "^checked [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}$"
}

update_and_open_stale_repos () {
    for url in $(cat $repos_file)
    do
        local description=$(buku --json --sreg "^$url$" | jq --raw-output '.[0].description')
        local last_update_date=$(echo "$description" | cut -d' ' -f2)
        if [ "$last_update_date" == $(today) ]
        then
            open_repo "$url"
        elif is_description_format_wrong "$description" || [[ $last_update_date < $(three_months_ago) ]]
        then
            update_and_open_stale_repo "$url"
        fi
    done
}

check_github_trending_repos () {
    local repos_file="$1"

    insert_all_repos
    update_and_open_stale_repos
}

today () {
    date +"%Y-%m-%d"
}

three_months_ago () {
    date -d "-3 month" +"%Y-%m-%d"
}

check_github_trending_repos urls.txt
