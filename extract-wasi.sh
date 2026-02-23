#!/bin/bash

wtg=hs-jpg2exif-wasi:0.1.0.0

wnm=hs-jpg2exif.wasm

list() {
	container image save "${wtg}" |
		tar --list --verbose
}

index() {
	container image save "${wtg}" |
		tar x -O - index.json |
		jq .manifests |
		jq '.[]' |
		jq --raw-output .digest |
		cut -d: -f2
}

showix() {
	ix=$(index)
	container image save "${wtg}" |
		tar x -O - "blobs/sha256/${ix}" |
		jq
}

manifest() {
	ix=$(index)
	container image save "${wtg}" |
		tar x -O - "blobs/sha256/${ix}" |
		jq .manifests |
		jq '.[]' |
		jq --raw-output .digest |
		cut -d: -f2
}

showmanifest() {
	mf=$(manifest)
	container image save "${wtg}" |
		tar x -O - "blobs/sha256/${mf}" |
		jq
}

layer() {
	mf=$(manifest)
	container image save "${wtg}" |
		tar x -O - "blobs/sha256/${mf}" |
		jq .layers |
		jq '.[]' |
		jq --raw-output .digest |
		cut -d: -f2
}

showlayer() {
	ly=$(layer)
	container image save "${wtg}" |
		tar x -O - "blobs/sha256/${ly}" |
		zcat |
		tar --list --verbose
}

getwasm() {
	ly=$(layer)
	container image save "${wtg}" |
		tar x -O - "blobs/sha256/${ly}" |
		zcat |
		tar x -O - "${wnm}" |
		dd if=/dev/stdin of="${wnm}" bs=1048576
}

test -f "${wnm}" || getwasm
