module Main (main) where

import JpgToExif (stdin2jpg2exif2dto2json2stdout)

main :: IO ()
main = stdin2jpg2exif2dto2json2stdout
