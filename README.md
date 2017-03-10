# archive_vines.sh

A shell script to archive all your Vines.

__NOTE: THIS DOES NOT WORK ANY MORE, BECAUSE VINE'S API DOES NOT WORK__

## Dependencies

* `curl` https://curl.haxx.se/
* `youtube-dl` https://rg3.github.io/youtube-dl/
* `jq` https://stedolan.github.io/jq/

On a Mac, if you already have [Homebrew](http://brew.sh/) installed, you can  install dependencies like this (`curl` should already be installed):

```
brew install youtube-dl jq
```

## Usage

```
git clone https://github.com/dphiffer/archive_vines.git
cd archive_vines
./archive_vines.sh
```

## What does it archive?

The script will download one of the following for each vine you've ever uploaded.

* An MPEG-4 video
* A JPEG thumbnail image
* A JSON metadata file

## How is this different from the official Vine archiver?

I've heard that some people have had difficulties getting Vine's archive function to work properly, so this may be a useful alternative if that's the case for you.

It seems like you mostly get the same data in each case. One difference is that we store each Vine's metadata as an individual .json file whereas Vine's archive blobs all of it together inside a single .html file.

Another thing is you could potentially adapt this to use other API endpoints, for example to download all the stuff you've ever liked, or all your contacts' Vines. Feel free to offer up pull requests if you manage to do anything interesting.

## Vine has an API?

Vine never documented their API, so the script pretends to be the Vine app. Thanks to [Vino's API hints](https://github.com/starlock/vino/wiki/API-Reference) for making this possible. Since the app is getting discontinued, I expect this script will also stop working.

## Shouldn't this use OAuth?

In theory we could probably authenticate more safely using Twitter's OAuth API, but I'm not 100% sure how that works with Vine's own API. So for now we have to prompt for your email and password. The login itself isn't stored anywhere, but a session key does get cached in `cache/auth.json`.

## See also

* [Vine FAQ](https://vine.co/FAQ)
