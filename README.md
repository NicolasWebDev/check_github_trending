# Check Github Trending

The idea is to know which trending repos I have already checked, to avoid
having to check them again in the future.

The list of reviewed trending repos is kept in a lightweight text-only
database, that consists of the reviewed repos with a timestamp of the last
revision date. If the revision date is greater than N months, the repo is
marked once more for review. New repos and stale repos are opened in the
browser.

## Instructions

1. Open the tabs of all the trending repos from github.
2. Export all the tabs using the Chrome extension "Export Tabs" (it doesn't
   matter if there are other tabs).
3. Clean the exported file to keep only the newly opened github urls.
4. Move the exported and cleaned file to this repo, replacing the previous
   urls.
5. Run the program.
