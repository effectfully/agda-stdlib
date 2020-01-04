{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Changelog.Types where

import Control.Monad.State
import Data.Map.Strict (Map)

import Changelog.Configuration
import Changelog.Utils

type HIGHLIGHTS = [[String]]
type BUGFIXES = [[String]]
  -- Items

type DEPRECATED = Map String [(String,String)]
  -- ^ map of module name * renamings
type NEW = Map String [String]
  -- ^ map of module name * new definitions

data CHANGELOG = CHANGELOG
  { highlights :: HIGHLIGHTS
  , bugfixes   :: BUGFIXES
  , deprecated :: DEPRECATED
  , new        :: NEW
  }

data STATE = STATE
  { pullRequests :: [String]  -- one directory per PR
  }

newtype ChangeM a = ChangeM { runChangeM :: StateT STATE IO a }
  deriving (Functor, Applicative, Monad, MonadState STATE, MonadIO)

evalChangeM :: ChangeM a -> STATE -> IO a
evalChangeM = evalStateT . runChangeM

initSTATE :: IO STATE
initSTATE = do
  -- one directory per PR
  dirs <- getDirectories changesFP
  pure $ STATE dirs