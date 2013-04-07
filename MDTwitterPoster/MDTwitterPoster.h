//
//  MDTwitterPoster.h
//
//  Created by MANIAK_dobrii on 10/5/12.
//  Copyright (c) 2012 MANIAK_dobrii. All rights reserved.
//
/*
    Small lib for: 
        o posting twits,
        o getting user info for a screenName.
 
    iOS 4.1+, no ARC
    The pack contains stuff I didn't write, 3rd party code I used here is
    described in detail in MDTwitterPosterIncludes.h.
 

    o MDTwitterPoster is released under the MIT License by MANIAK_dobrii (Солодовниченко Михаил).
    o MDTwitterPoster uses v1.1 twitter API.
    o MDTwitterPoster does not include authentication routines, so you'll have
      to get authentication token and authentication token secret yourself.
    o MDTwitterPoster uses SBJSON to parse json.
 */

#import <Foundation/Foundation.h>

// uncomment to disable NSLogs from MDTwitterPosterConnection
// #define NO_CONNECTION_LOGS

#define TP_CONNECTION_TYPE_TWIT @"twit"
#define TP_CONNECITON_TYPE_GETINFO @"getInfo"

@class MDTwitterPoster, MDTwitterPosterConnection;
@protocol MDTwitterPosterDelegate <NSObject>
@optional
//////////////////////////////////////////
// Update status (= send a twit) /////////
//////////////////////////////////////////
// When MDTwitterPoster manages to update a status (= send twit)
- (void) mdTwitterPoster:(MDTwitterPoster*)mdTwitterPoster didUpdateStatus:(NSString*)newStatus;
// When MDTwitterPoster fails to update status (= send twit) for any reason
- (void) mdTwitterPoster:(MDTwitterPoster*)mdTwitterPoster didFailToUpdateStatus:(NSString *)newStatus withError:(NSError*)error;

//////////////////////////////////////////
// Get userInfo //////////////////////////
//////////////////////////////////////////
// When MDTwitterPoster manages to get userInfo
- (void) mdTwitterPoster:(MDTwitterPoster *)mdTwitterPoster gotUserInfo:(NSDictionary*)userInfo;
// When MDTwitterPoster manages to get userInfo
- (void) mdTwitterPoster:(MDTwitterPoster *)mdTwitterPoster didFailToGetUserInfoWithError:(NSError*)error;

//////////////////////////////////////////
// Other //////////////////////////
//////////////////////////////////////////
// When connection for doing stuff with MDTwitterPoster get's cancelled
- (void) mdTwitterPoster:(MDTwitterPoster *)mdTwitterPoster gotConnectionCancelled:(MDTwitterPosterConnection*)connection;
@end

@interface MDTwitterPoster : NSObject
{
    NSMutableArray* _connections;
    id<MDTwitterPosterDelegate> _delegate;
}

@property (nonatomic, readonly) NSMutableArray* connections;
@property (nonatomic, retain) id<MDTwitterPosterDelegate> delegate;

// you may use it as a singleton, but that's not required
+ (id) sharedInstance;

// cancell all underlying NSURLConnections
// this will produce mdTwitterPoster:gotConnectionCancelled: message sent
// to a delegate for each existing conneciton
+ (void) cancelAllConnections;
- (void) cancelAllConnections;

// update status (= send twit) to status
+ (void) twitWithAppKey: (NSString*)oauth_consumer_key
              appSecret: (NSString*)oauth_consumer_secret
                  token: (NSString*)oauth_token
            tokenSecret: (NSString*)oauth_token_secret
                message: (NSString*)status;

// get user info for screenName (f.e. MANIAK_dobrii is my screenName)
+ (void) getUserInfoWithAppKey: (NSString*)oauth_consumer_key
                     appSecret: (NSString*)oauth_consumer_secret
                         token: (NSString*)oauth_token
                   tokenSecret: (NSString*)oauth_token_secret
                    screenName: (NSString*)username;

+ (NSString*) generateNonce;

@end