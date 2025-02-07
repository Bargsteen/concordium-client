{-# LANGUAGE Rank2Types #-}

module Main where

import Control.Concurrent (threadDelay)
import Control.Monad (forever)
import System.IO (hSetBuffering, hSetEncoding, BufferMode(..), stdout, utf8)

import Server

main :: IO ()
main = do
  stdoutSetup
  putStrLn "[server] Booting..."

    -- Boot the http server
  let middlewares = allowCsrf . corsified
  runHttp middlewares
  forever $ threadDelay 100000

-- | Force LineBuffering for consistent output behavior
stdoutSetup :: IO ()
stdoutSetup = do
  hSetBuffering stdout LineBuffering
  hSetEncoding  stdout utf8
