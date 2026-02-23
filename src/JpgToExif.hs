module JpgToExif (
    stdin2bytes,
    ExifMap,
    ExifMapDTO,
    exif2dto,
    dto2bytes,
    dtoResultToJsonBytes,
    jpgBytesToExif,
    jpgBytesToExifDto,
    jpgBytesToExifJsonBytes,
    jsonBytesToStdout,
    stdin2jpg2exif,
    stdin2jpg2exif2dto2json2stdout,
    exif2stdout,
    result2dto,
    printResult,
    printJsonResult,
    stdin2jpg2exif2print,
) where

import Data.Map.Strict
import qualified Data.Map.Strict as MS

import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString.Lazy.Char8 as BSL

import System.IO (hPutStrLn, stderr)

import Data.Aeson (encode)

import Graphics.HsExif

stdin2bytes :: IO BL.ByteString
stdin2bytes = BL.getContents

type ExifMap = Map ExifTag ExifValue

type ExifMapDTO = Map String String

exif2dto :: ExifMap -> ExifMapDTO
exif2dto m = MS.map show (MS.mapKeys show m)

dto2bytes :: ExifMapDTO -> BL.ByteString
dto2bytes = encode

jpgBytesToExif :: BL.ByteString -> Either String ExifMap
jpgBytesToExif = parseExif

result2dto :: Either String ExifMap -> Either String ExifMapDTO
result2dto (Left emsg) = Left emsg
result2dto (Right emap) = Right (exif2dto emap)

dtoResultToJsonBytes :: Either String ExifMapDTO -> Either String BL.ByteString
dtoResultToJsonBytes (Left emsg) = Left emsg
dtoResultToJsonBytes (Right dto) = Right (dto2bytes dto)

jpgBytesToExifDto :: BL.ByteString -> Either String ExifMapDTO
jpgBytesToExifDto jbytes = do
    let emap :: Either String ExifMap = jpgBytesToExif jbytes
    let rdto :: Either String ExifMapDTO = result2dto emap
    rdto

jpgBytesToExifJsonBytes :: BL.ByteString -> Either String BL.ByteString
jpgBytesToExifJsonBytes jpgbytes = do
    let rdto :: Either String ExifMapDTO = jpgBytesToExifDto jpgbytes
    let jbytes :: Either String BL.ByteString = dtoResultToJsonBytes rdto
    jbytes

jsonBytesToStdout :: BL.ByteString -> IO ()
jsonBytesToStdout = BSL.putStrLn

printJsonResult :: Either String BL.ByteString -> IO ()
printJsonResult (Left emsg) = hPutStrLn stderr emsg
printJsonResult (Right jbytes) = jsonBytesToStdout jbytes

stdin2jpg2exif2dto2json2stdout :: IO ()
stdin2jpg2exif2dto2json2stdout = do
    jbytes :: BL.ByteString <- stdin2bytes
    let rjson :: Either String BL.ByteString = jpgBytesToExifJsonBytes jbytes
    printJsonResult rjson

stdin2jpg2exif :: IO (Either String ExifMap)
stdin2jpg2exif = do
    jbytes :: BL.ByteString <- stdin2bytes
    let emap :: Either String ExifMap = jpgBytesToExif jbytes
    return emap

exif2stdout :: ExifMap -> IO ()
exif2stdout = print

printResult :: Either String ExifMap -> IO ()
printResult (Left emsg) = hPutStrLn stderr emsg
printResult (Right emap) = print emap

stdin2jpg2exif2print :: IO ()
stdin2jpg2exif2print = do
    emap :: Either String ExifMap <- stdin2jpg2exif
    printResult emap
