# archive_vines.sh

A shell script to archive all your Vines.

## Dependencies

* `curl` https://curl.haxx.se/
* `youtube-dl` https://rg3.github.io/youtube-dl/
* `jq` https://stedolan.github.io/jq/

## Usage

```
git clone https://github.com/dphiffer/archive_vines.git
cd archive_vines
./archive_vines.sh "user@example.com" "password"
```

## What does it archive?

The script will download one of the following for each vine you've ever uploaded.

* An MPEG-4 video
* A JPEG thumbnail image
* A JSON metadata file

## Vine has an API?

Vine never documented their API, so the script pretends to be the Vine app. Thanks to [Vino's API hints](https://github.com/starlock/vino/wiki/API-Reference) for making this possible.
