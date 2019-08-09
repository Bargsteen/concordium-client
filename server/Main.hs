{-# LANGUAGE Rank2Types #-}

module Main where

import Control.Concurrent    (threadDelay)
import Control.Monad         (forever)
import Control.Monad.Managed (Managed, MonadIO, liftIO, runManaged)
import System.IO (hSetBuffering, hSetEncoding, BufferMode(..), stdout, utf8)

import Server
import qualified Api
import Concordium.Client.Commands as COM

main :: IO ()
main = manage $ do
  program $ do
    putStrLn $ "[server] Booting..."

    let backend = COM.GRPC { host = "127.0.0.1", port = 11118, target = Nothing }

    -- Boot the http server
    let middlewares = allowCsrf . corsified
    runHttp (Api.servantApp backend)  middlewares


-- | Wrapper for runManaged that than runs forever.
manage :: forall a . Managed a -> IO ()
manage things = runManaged $ do
  liftIO stdoutSetup
  _ <- things
  -- Wait until the the process is killed
  forever $ liftIO $ threadDelay 100000


-- | Wrapper for runManaged that than runs once.
once :: forall a . Managed a -> IO ()
once things = runManaged $ do
  liftIO stdoutSetup
  _ <- things
  pure ()


-- | Force LineBuffering for consistent output behavior
stdoutSetup :: IO ()
stdoutSetup = do
  hSetBuffering stdout LineBuffering
  hSetEncoding  stdout utf8


-- | TBC, for testing.
manageTest :: Managed () -> IO ()
manageTest = runManaged


program :: MonadIO m => IO a -> m a
program = liftIO
