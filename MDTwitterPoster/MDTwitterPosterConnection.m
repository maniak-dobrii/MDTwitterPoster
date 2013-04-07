//
//  MDTwitterPosterConnection.m
//
//  Created by MANIAK_dobrii on 10/7/12.
//  Copyright (c) 2012 MANIAK_dobrii. All rights reserved.
//

#import "MDTwitterPosterConnection.h"
#import "MDTwitterPoster.h"
#import "JSON.h"

@implementation MDTwitterPosterConnection
@synthesize data = _data,
            type = _type,
        userInfo = _userInfo;

- (id) initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
    self = [super initWithRequest:request delegate:self startImmediately:startImmediately];
    if(self)
    {
        _data = [[NSMutableData alloc] init];
        [[[MDTwitterPoster sharedInstance] connections] addObject:self];
    }
    return self;
}

#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString* responce_string = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
#ifndef NO_CONNECTION_LOGS
    NSLog(@"MDTwitterPoster: conneciton finished: %@", responce_string);    
#endif
    [_data release]; _data = nil;
    
    [[[MDTwitterPoster sharedInstance] connections] removeObject:self];
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* responce = [parser objectWithString:responce_string];
    [parser release];
    
    MDTwitterPoster* mdTwitterPoster = (MDTwitterPoster*)[MDTwitterPoster sharedInstance];
    id mdTwitterPosterDelegate = [(MDTwitterPoster*)[MDTwitterPoster sharedInstance] delegate];
    
    
    if([_type isEqualToString:TP_CONNECTION_TYPE_TWIT]) // update status (send twit) connection
    {
        if([responce objectForKey:@"id"])
        {
            // sent ok
            if([mdTwitterPosterDelegate respondsToSelector:@selector(mdTwitterPoster:didUpdateStatus:)])
            {
                [mdTwitterPosterDelegate mdTwitterPoster:mdTwitterPoster didUpdateStatus:[_userInfo objectForKey:MDTPC_STATUS_KEY]];
            }
        }
        else
        {
            //failure
            // failed to post
            NSError* error = [NSError errorWithDomain:@"Bad responce JSON" code:0 userInfo:responce];
            
            if([mdTwitterPosterDelegate respondsToSelector:@selector(mdTwitterPoster:didFailToUpdateStatus:withError:)])
            {
                [mdTwitterPosterDelegate mdTwitterPoster:mdTwitterPoster didFailToUpdateStatus:[_userInfo objectForKey:MDTPC_STATUS_KEY] withError:error];
            }
        }
    }
    else if([_type isEqualToString:TP_CONNECITON_TYPE_GETINFO])
    {
        if([responce objectForKey:@"id"])
        {
            // sent ok
            if([mdTwitterPosterDelegate respondsToSelector:@selector(mdTwitterPoster:gotUserInfo:)])
            {
                [mdTwitterPosterDelegate mdTwitterPoster:mdTwitterPoster gotUserInfo:responce];
            }
        }
        else
        {
            // failure
            NSError* error = [NSError errorWithDomain:@"Bad responce JSON" code:0 userInfo:responce];
            if([mdTwitterPosterDelegate respondsToSelector:@selector(mdTwitterPoster:didFailToGetUserInfoWithError:)])
            {
                [mdTwitterPosterDelegate mdTwitterPoster:mdTwitterPoster didFailToGetUserInfoWithError:error];
            }
        }
    }
}

- (void)connection:(NSURLConnection*)connection didFailWithError: (NSError*)error {
#ifndef NO_CONNECTION_LOGS
    NSLog(@"connection failed: %@", error);
#endif
    
    [[[MDTwitterPoster sharedInstance] connections] removeObject:self];
    
    MDTwitterPoster* mdTwitterPoster = (MDTwitterPoster*)[MDTwitterPoster sharedInstance];
    id mdTwitterPosterDelegate = [(MDTwitterPoster*)[MDTwitterPoster sharedInstance] delegate];
    
    if([_type isEqualToString:TP_CONNECTION_TYPE_TWIT])
    {
        // failed to post
        if([mdTwitterPosterDelegate respondsToSelector:@selector(mdTwitterPoster:didFailToUpdateStatus:withError:)])
        {
            [mdTwitterPosterDelegate mdTwitterPoster:mdTwitterPoster didFailToUpdateStatus:[_userInfo objectForKey:MDTPC_STATUS_KEY] withError:error];
        }
    }
    else if([_type isEqualToString:TP_CONNECITON_TYPE_GETINFO])
    {
        if([mdTwitterPosterDelegate respondsToSelector:@selector(mdTwitterPoster:didFailToGetUserInfoWithError:)])
        {
            [mdTwitterPosterDelegate mdTwitterPoster:mdTwitterPoster didFailToGetUserInfoWithError:error];
        }
    }
}

- (void)cancel {
#ifndef NO_CONNECTION_LOGS
    NSLog(@"MDTwitterPoster: connection was cancelled");
#endif
    
    [self retain];
    [super cancel];

    MDTwitterPoster* mdTwitterPoster = (MDTwitterPoster*)[MDTwitterPoster sharedInstance];
    id mdTwitterPosterDelegate = [(MDTwitterPoster*)[MDTwitterPoster sharedInstance] delegate];
    
    if([mdTwitterPosterDelegate respondsToSelector:@selector(mdTwitterPoster:gotConnectionCancelled:)])
    {
        [mdTwitterPosterDelegate mdTwitterPoster:mdTwitterPoster gotConnectionCancelled:self];
    }
    
    [self release];
    [[[MDTwitterPoster sharedInstance] connections] removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
	return;
}


- (void) dealloc {
    [_data release]; _data = nil;
    [_type release]; _type = nil;
    [_userInfo release]; _userInfo = nil;
    
    [super dealloc];
}

@end
