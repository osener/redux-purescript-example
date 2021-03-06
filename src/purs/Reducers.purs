module Reducers (rootReducer) where

import Prelude

import Data.Maybe (fromMaybe)
import Data.StrMap as StrMap
import Data.Time (Milliseconds(Milliseconds))

import Redux.Reducer (reducer, combineReducers)

import Actions

selectedSubreddit = reducer r "reactjs"
  where r (SelectSubreddit sub) state = sub
        r _ state = state

posts (InvalidateSubreddit _) state =
  state {didInvalidate = true}
posts (RequestPosts _) state =
  state {isFetching = true
        ,didInvalidate = false}
posts (ReceivePosts _ xs receivedAt) state =
  state {isFetching = false
        ,didInvalidate = false
        ,items = xs
        ,lastUpdated = receivedAt}

postsBySubreddit = reducer r StrMap.empty
  where r a@(InvalidateSubreddit sub) state = updatePosts sub a state
        r a@(ReceivePosts sub _ _) state = updatePosts sub a state
        r a@(RequestPosts sub) state = updatePosts sub a state

updatePosts sub action state = StrMap.insert sub (posts action xs) state
  where xs = fromMaybe defaultPosts (StrMap.lookup sub state)
        defaultPosts =
          {isFetching: false
          ,didInvalidate: false
          ,items: []
          ,lastUpdated: Milliseconds 0.0}

rootReducer =
  combineReducers {postsBySubreddit
                  ,selectedSubreddit}
