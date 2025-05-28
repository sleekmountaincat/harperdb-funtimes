#!/usr/bin/env bash

# generates data ('magic, the gathering' cards) for loading into harper
# by converting json from https://mtgjson.com/downloads/all-sets/ to csv.
# json files from mtgjson are HUGE, only including a small subset of fields here.
# decided not to just use bulk json import to harper as that would require fiddling with AWS keys.

# (this is not used in this demo workflow, but i am including for completeness.)

(
  echo "name,manaCost,colors,type,power,toughness,artist,keywords,originalText,flavorText"
  jq -r '
    .data.cards[]? |
    [
      .name // "",
      .manaCost // "",
      (.colors // [] | join(",")),
      .type // "",
      .power // "",
      .toughness // "",
      .artist // "",
      (.keywords // [] | join(",")),
      (.originalText // "" | gsub("\n"; "\\n")),
      (.flavorText // "" | gsub("\n"; "\\n"))
    ] | @csv
  ' *.json
) > mtg-card-data.csv
