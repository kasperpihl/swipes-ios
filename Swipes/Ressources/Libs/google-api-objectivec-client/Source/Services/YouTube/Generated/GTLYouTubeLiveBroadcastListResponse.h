/* Copyright (c) 2013 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GTLYouTubeLiveBroadcastListResponse.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   YouTube Data API (youtube/v3)
// Description:
//   Programmatic access to YouTube features.
// Documentation:
//   https://developers.google.com/youtube/v3
// Classes:
//   GTLYouTubeLiveBroadcastListResponse (0 custom class methods, 9 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLYouTubeLiveBroadcast;
@class GTLYouTubePageInfo;
@class GTLYouTubeTokenPagination;

// ----------------------------------------------------------------------------
//
//   GTLYouTubeLiveBroadcastListResponse
//

// This class supports NSFastEnumeration over its "items" property. It also
// supports -itemAtIndex: to retrieve individual objects from "items".

@interface GTLYouTubeLiveBroadcastListResponse : GTLCollectionObject

// Etag of this resource.
@property (copy) NSString *ETag;

// Serialized EventId of the request which produced this response.
@property (copy) NSString *eventId;

// A list of broadcasts that match the request criteria.
@property (retain) NSArray *items;  // of GTLYouTubeLiveBroadcast

// Identifies what kind of resource this is. Value: the fixed string
// "youtube#liveBroadcastListResponse".
@property (copy) NSString *kind;

// The token that can be used as the value of the pageToken parameter to
// retrieve the next page in the result set.
@property (copy) NSString *nextPageToken;

@property (retain) GTLYouTubePageInfo *pageInfo;

// The token that can be used as the value of the pageToken parameter to
// retrieve the previous page in the result set.
@property (copy) NSString *prevPageToken;

@property (retain) GTLYouTubeTokenPagination *tokenPagination;

// The visitorId identifies the visitor.
@property (copy) NSString *visitorId;

@end
