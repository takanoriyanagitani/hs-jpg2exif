#!/bin/sh

bname=hs-jpg2exif
bin=$(cabal exec -- which "${bname}")

jinput=./input.jpg

test -f "${jinput}" || exec env jname="${jinput}" sh -c '
    echo input image file "${jname}" missing.
    echo you need to find the image with exif to run this demo.
    exit 1
'

input(){
    cat "${jinput}"
}

native(){
    input |
        "${bin}" |
        jq
}

wasi(){
    input |
        wasmtime run ./hs-jpg2exif.wasm |
        jq
}

#native
wasi
