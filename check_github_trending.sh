#! /bin/bash

# Features:
# When passed a list of github repos, find out the ones I have never checked and the ones that I have checked in the past, but the last time was more than N months ago.
# Those are the ones that I should check, so I should open them in the browser.
# I should create/update them in in the database and set their timestamp to today.
# Cases:
# - never checked -> insert them w/date to today, open in browser
# - already checked, less than N months ago -> nothing
# - already checked, more than N months ago -> update them w/date to today, open in browser

set -e

CURRENTLY_TRENDING_REPOS_FILE="currently_trending_repos.txt"
DB_FILE="$HOME/.check_github_trending.db.txt"
MONTHS_TO_CONSIDER_REPO_STALE=4

today() {
    date +"%Y-%m-%d"
}

months_ago() {
    date -d "-${1} month" +"%Y-%m-%d"
}

repo_was_never_reviewed() {
    local repo="$1"

    ! grep -q "$1$" "$DB_FILE"
}

find_last_review_date() {
    local repo="$1"

    grep "$1$" "$DB_FILE" | tail -1 | cut -d ' ' -f 1
}

repo_was_reviewed_a_long_time_ago() {
    local repo="$1"

    [[ "$(find_last_review_date "$repo")" < "$(months_ago "$MONTHS_TO_CONSIDER_REPO_STALE")" ]]
}

review_repo() {
    local repo="$1"

    mark_repo_as_reviewed "$repo"
    open_repo_in_browser "$repo"
}

open_repo_in_browser() {
    local repo="$1"

    $BROWSER "$repo" >&/dev/null
}

mark_repo_as_reviewed() {
    local repo="$1"

    echo "$(today) $repo" >>$DB_FILE
}

check() {
    local repo="$1"

    if repo_was_never_reviewed "$repo"; then
        echo "The repo $repo was never reviewed"
        review_repo "$repo"
    elif repo_was_reviewed_a_long_time_ago "$repo"; then
        echo "The repo $repo was reviewed a long time ago"
        review_repo "$repo"
    else
        echo "The repo $repo was already reviewed"
    fi
}

create_database_if_not_present() {
    if [[ ! -f "$DB_FILE" ]]; then
        echo "New database file created with path: $DB_FILE"
        touch "$DB_FILE"
    fi
}

check_github_trending_repos() {
    create_database_if_not_present

    while read -r currently_trending_repo; do
        check "$currently_trending_repo"
    done <"$CURRENTLY_TRENDING_REPOS_FILE"
}

check_github_trending_repos
