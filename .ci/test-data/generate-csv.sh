#!/usr/bin/env bash

# generates data (every single 'magic, the gathering' card) for loading into harper by converting
# json from https://mtgjson.com/downloads/all-files/ to csv. json files from mtgjson are HUGE,
# i am only including a small subset of fields here.
# decided not to just use bulk json import to harper as that would require fiddling with AWS keys.

# (this is not used in this demo workflow, but i am including for completeness.)

(
  echo "set,name,manaCost,colors,type,power,toughness,artist,keywords,originalText,flavorText"
  jq -r '
    .data | to_entries[] |
    .key as $set |
    .value.cards[]? |
    [
      $set,
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
  ' /Users/christopher/Downloads/AllPrintings.json
) > mtg-card-data.csv