{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE OverloadedLabels, TypeOperators, DataKinds, FlexibleContexts #-}

module Main (main) where

import           Data.ByteString (ByteString)
import           Labels.Explore

stat :: IO ()
stat =
  explore $ do
    httpSource "http://chrisdone.com/ontime.csv.zip" .|
      zipEntryConduit "ontime.csv" .>
      statSink

demo :: IO Double
demo =
  explore $
  fileSource "demo.csv" .| fromCsvConduit .|
  mapConduit (\(c :: ("ORIGIN" := String, "DISTANCE" := Double)) -> c) .>
  foldSink (\total c -> get $("DISTANCE") c + total) 0

foo :: IO Int
foo =
  explore $
  fileSource "demo.csv" .| vectorCsvConduit .>
  foldSink (\total _ -> total + 1) 0

dom =
  do count <- explore $ do
                fileSource "demo.csv" .| fromCsvConduit .|
                  filterConduit
                    (\(row :: ("ORIGIN" := ByteString)) -> get $("ORIGIN") row == "RKS") .>
                  countSink
     print count

main = dom