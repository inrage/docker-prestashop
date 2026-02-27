#!/usr/bin/env bash
set -e

for phpVersion in $(jq -r '.phpVersions[]' versions.json); do
  php=$(jq -r ".versions[\"${phpVersion}\"].php" versions.json)
  apache=$(jq -r ".versions[\"${phpVersion}\"].apache" versions.json)
  latest=$(jq -r '.latest' versions.json)

  if [[ "${phpVersion}" == "${latest}" ]]; then
    sed -i "s/| \`${phpVersion}\`.* |/| \`${phpVersion}\`, \`latest\` | PHP ${php} | Apache ${apache} | Debian Bookworm |/" README.md
  else
    sed -i "s/| \`${phpVersion}\`.* |/| \`${phpVersion}\` | PHP ${php} | Apache ${apache} | Debian Bookworm |/" README.md
  fi
done
