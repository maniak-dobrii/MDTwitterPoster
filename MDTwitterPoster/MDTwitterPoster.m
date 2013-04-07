//
//  MDTwitterPoster.m
//
//  Created by MANIAK_dobrii on 10/5/12.
//  Copyright (c) 2012 MANIAK_dobrii. All rights reserved.
//

#import "MDTwitterPoster.h"
#import "MDTwitterPosterConnection.h"
#import "MDTwitterPosterIncludes.h"

@implementation MDTwitterPoster
@synthesize connections = _connections,
               delegate = _delegate;

// Due to this realisation, if you plan to subclass MDTwitterPoster
// and use several subclass singletones you should reimplement
// sharedInstance method (you may even copy paste this one to the subclass).
+ (id) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (void) cancelAllConnections {
    [[self sharedInstance] cancelAllConnections];
}

- (void) cancelAllConnections {
    if(![_connections count]) return;
    
    NSArray* connections = [NSArray arrayWithArray:_connections];
    for(MDTwitterPosterConnection* connection in connections)
    {
        [connection cancel];
        [_connections removeObject:connection];
    }
}

- (id) init {
    self = [super init];
    if(self)
    {
        _connections = [[NSMutableArray alloc] init];
    }
    return self;
}

// statuses/update.json
//
// status - new tweet's text
+ (void) twitWithAppKey: (NSString*)oauth_consumer_key
              appSecret: (NSString*)oauth_consumer_secret
                  token: (NSString*)oauth_token
            tokenSecret: (NSString*)oauth_token_secret
                message: (NSString*)status {
    
    if(!status)
    {
        if([[[MDTwitterPoster sharedInstance] delegate] respondsToSelector:@selector(mdTwitterPoster:didFailToUpdateStatus:withError:)])
        {
            NSError* error = [NSError errorWithDomain:@"Failed to twit due to status = nil" code:0 userInfo:nil];
            [[[MDTwitterPoster sharedInstance] delegate] mdTwitterPoster:[MDTwitterPoster sharedInstance] didFailToUpdateStatus:nil withError:error];
        }
        
        return;
    }
    
    if(!oauth_consumer_key || !oauth_consumer_secret || !oauth_token || !oauth_token_secret)
    {
        if([[[MDTwitterPoster sharedInstance] delegate] respondsToSelector:@selector(mdTwitterPoster:didFailToUpdateStatus:withError:)])
        {
            NSMutableString* error_str = [NSMutableString stringWithString:@"Failed to twit due to some arguments are nil ("];
            if(!oauth_consumer_key) [error_str appendString:@"oauth_consumer_key, "];
            if(!oauth_consumer_secret) [error_str appendString:@"oauth_consumer_secret, "];
            if(!oauth_token) [error_str appendString:@"oauth_token, "];
            if(!oauth_token_secret) [error_str appendString:@"oauth_token_secret, "];
            [error_str replaceOccurrencesOfString:@", " withString:@"" options:NSBackwardsSearch range:NSMakeRange([error_str length] - 3, 2)];
            [error_str appendString:@")"];
            
            NSError* error = [NSError errorWithDomain:error_str code:0 userInfo:nil];
            [[[MDTwitterPoster sharedInstance] delegate] mdTwitterPoster:[MDTwitterPoster sharedInstance] didFailToUpdateStatus:nil withError:error];
        }
        
        return;        
    }
    
    // checks
       
    NSString* oauth_signature_method = @"HMAC-SHA1";
    NSString* oauth_timestamp = [NSString stringWithFormat:@"%i", (NSInteger)[[NSDate date] timeIntervalSince1970]];
    NSString* oauth_version = @"1.0";
    NSString* oauth_nonce = [self generateNonce];
    NSString* httpMethod = @"POST";
    NSString* baseURL = @"https://api.twitter.com/1.1/statuses/update.json";
    
    
    
    // generate signature
    // fill parameters dictionary
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setObject:oauth_consumer_key forKey:@"oauth_consumer_key"];
    [parameters setObject:oauth_signature_method forKey:@"oauth_signature_method"];
    [parameters setObject:oauth_timestamp forKey:@"oauth_timestamp"];
    [parameters setObject:oauth_token forKey:@"oauth_token"];
    [parameters setObject:oauth_version forKey:@"oauth_version"];
    [parameters setObject:oauth_nonce forKey:@"oauth_nonce"];
    [parameters setObject:status forKey:@"status"];
    
    
    
    // escape keys and values
    NSEnumerator *enumerator = [parameters keyEnumerator];
    NSString* key;
    NSString* object;
    
    NSMutableDictionary* escapedParameters = [NSMutableDictionary dictionary];
    
    while ((key = (NSString*)[enumerator nextObject])) 
    {
        object = [parameters objectForKey:key];
        [escapedParameters setObject:[object urlEncodeUsingEncoding:NSUTF8StringEncoding]
                              forKey:[key urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    // sort keys
    NSArray* sortedKeys = [[escapedParameters allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableString* parameterString = [NSMutableString string];
    
    BOOL isLastKey = NO;
    for(NSString* key in sortedKeys)
    {
        isLastKey = (key == [sortedKeys lastObject]);
        
        [parameterString appendFormat:@"%@=%@%@", key, [escapedParameters objectForKey:key], (isLastKey)?@"":@"&"];
    }
    
    //
    // parameter string generated ----
    //
    
    
    // compiling signatureBaseString
    NSMutableString* signatureBaseString = [NSMutableString string];
    [signatureBaseString appendFormat:@"%@&", httpMethod];
    [signatureBaseString appendFormat:@"%@&", [baseURL urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    [signatureBaseString appendString:[parameterString urlEncodeUsingEncoding:NSUTF8StringEncoding]];
      
    //
    // signature base string generated ----
    //
    
    // generating signing key
    NSMutableString* signingKey = [NSMutableString string];
    [signingKey appendFormat:@"%@&", [oauth_consumer_secret urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    [signingKey appendString:[oauth_token_secret urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    
    //
    // signing key generated ----
    //
    
    NSString* oauth_signature = [signatureBaseString base64StringWithHMACSHA1Digest:signingKey];
    
    //
    // oauth signature generated ----
    //
    
    // generating authorisation header
    NSMutableDictionary* authorisationHeaderDic = [NSMutableDictionary dictionary];
    [authorisationHeaderDic setObject:oauth_consumer_key forKey:@"oauth_consumer_key"];
    [authorisationHeaderDic setObject:oauth_nonce forKey:@"oauth_nonce"];
    [authorisationHeaderDic setObject:oauth_signature forKey:@"oauth_signature"];
    [authorisationHeaderDic setObject:oauth_signature_method forKey:@"oauth_signature_method"];
    [authorisationHeaderDic setObject:oauth_timestamp forKey:@"oauth_timestamp"];
    [authorisationHeaderDic setObject:oauth_token forKey:@"oauth_token"];
    [authorisationHeaderDic setObject:oauth_version forKey:@"oauth_version"];
    
    // escape keys and values
    enumerator = [authorisationHeaderDic keyEnumerator];
    //NSString* key;
    //NSString* object;
    
    NSMutableDictionary* escapedauthorisationHeaderDic = [NSMutableDictionary dictionary];
    
    while ((key = (NSString*)[enumerator nextObject])) 
    {
        object = [authorisationHeaderDic objectForKey:key];
        [escapedauthorisationHeaderDic setObject:[object urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                          forKey:[key urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    NSMutableString* authorisationHeader = [NSMutableString string];
    [authorisationHeader appendString:@"OAuth "];
    
    enumerator = [escapedauthorisationHeaderDic keyEnumerator];
    NSInteger keysCounter = [escapedauthorisationHeaderDic count];
    while ((key = (NSString*)[enumerator nextObject]))
    {
        isLastKey = (BOOL)(--keysCounter == 0);
        [authorisationHeader appendFormat:@"%@=\"%@\"%@", key, [escapedauthorisationHeaderDic objectForKey:key], (isLastKey)?@"":@", "];
    }
    
    //
    // authorisation header generated ----
    //
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseURL]];
    [request setHTTPMethod:httpMethod];
    
    [request setValue:@"OAuth gem v0.4.4" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authorisationHeader forHTTPHeaderField:@"Authorization"];
    
    NSString* requestBody = [NSString stringWithFormat:@"status=%@", [status urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    NSData* body = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:body];
    
    MDTwitterPosterConnection* connection = [[[MDTwitterPosterConnection alloc] initWithRequest:request delegate:nil startImmediately:NO] autorelease];
    connection.type = TP_CONNECTION_TYPE_TWIT;
    connection.userInfo = [NSDictionary dictionaryWithObject:status forKey:MDTPC_STATUS_KEY];
    
    [connection start];
}

// users/show.json
//
// username - twitter user's screen name
+ (void) getUserInfoWithAppKey: (NSString*)oauth_consumer_key
                     appSecret: (NSString*)oauth_consumer_secret
                         token: (NSString*)oauth_token
                   tokenSecret: (NSString*)oauth_token_secret
                    screenName: (NSString*)username {
    
    if(!username)
    {
        if([[[MDTwitterPoster sharedInstance] delegate] respondsToSelector:@selector(mdTwitterPoster:didFailToGetUserInfoWithError:)])
        {
            NSError* error = [NSError errorWithDomain:@"Failed to get user info due to username = nil" code:0 userInfo:nil];
            [[[MDTwitterPoster sharedInstance] delegate] mdTwitterPoster:[MDTwitterPoster sharedInstance] didFailToGetUserInfoWithError:error];
        }
        
        return;
    }
    
    // trim unnecessary characters from username
    username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(!oauth_consumer_key || !oauth_consumer_secret || !oauth_token || !oauth_token_secret)
    {
        if([[[MDTwitterPoster sharedInstance] delegate] respondsToSelector:@selector(mdTwitterPoster:didFailToGetUserInfoWithError:)])
        {
            NSMutableString* error_str = [NSMutableString stringWithString:@"Failed to get user info due to some arguments are nil ("];
            if(!oauth_consumer_key) [error_str appendString:@"oauth_consumer_key, "];
            if(!oauth_consumer_secret) [error_str appendString:@"oauth_consumer_secret, "];
            if(!oauth_token) [error_str appendString:@"oauth_token, "];
            if(!oauth_token_secret) [error_str appendString:@"oauth_token_secret, "];
            [error_str replaceOccurrencesOfString:@", " withString:@"" options:NSBackwardsSearch range:NSMakeRange([error_str length] - 3, 2)];
            [error_str appendString:@")"];
            
            NSError* error = [NSError errorWithDomain:error_str code:0 userInfo:nil];
            [[[MDTwitterPoster sharedInstance] delegate] mdTwitterPoster:[MDTwitterPoster sharedInstance] didFailToGetUserInfoWithError:error];
        }
        
        return;        
    }
    
    NSString* oauth_signature_method = @"HMAC-SHA1";
    NSString* oauth_timestamp = [NSString stringWithFormat:@"%i", (NSInteger)[[NSDate date] timeIntervalSince1970]];
    NSString* oauth_version = @"1.0";
    NSString* oauth_nonce = [self generateNonce];
    NSString* httpMethod = @"GET";
    NSString* baseURL = @"https://api.twitter.com/1.1/users/show.json";
    NSString* include_entities = @"true";
    
    
    // generate signature
    // fill parameters dictionary
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setObject:oauth_consumer_key forKey:@"oauth_consumer_key"];
    [parameters setObject:oauth_signature_method forKey:@"oauth_signature_method"];
    [parameters setObject:oauth_timestamp forKey:@"oauth_timestamp"];
    [parameters setObject:oauth_token forKey:@"oauth_token"];
    [parameters setObject:oauth_version forKey:@"oauth_version"];
    [parameters setObject:oauth_nonce forKey:@"oauth_nonce"];
    [parameters setObject:include_entities forKey:@"include_entities"];
    [parameters setObject:username forKey:@"screen_name"];
    
    
    
    // escape keys and values
    NSEnumerator *enumerator = [parameters keyEnumerator];
    NSString* key;
    NSString* object;
    
    NSMutableDictionary* escapedParameters = [NSMutableDictionary dictionary];
    
    while ((key = (NSString*)[enumerator nextObject])) 
    {
        object = [parameters objectForKey:key];
        [escapedParameters setObject:[object urlEncodeUsingEncoding:NSUTF8StringEncoding]
                              forKey:[key urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    
    // sort keys
    NSArray* sortedKeys = [[escapedParameters allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableString* parameterString = [NSMutableString string];
    
    BOOL isLastKey = NO;
    for(NSString* key in sortedKeys)
    {
        isLastKey = (key == [sortedKeys lastObject]);
        
        [parameterString appendFormat:@"%@=%@%@", key, [escapedParameters objectForKey:key], (isLastKey)?@"":@"&"];
    }
    
    // ------------
    
    
    
    // compiling signatureBaseString
    NSMutableString* signatureBaseString = [NSMutableString string];
    [signatureBaseString appendFormat:@"%@&", httpMethod];
    [signatureBaseString appendFormat:@"%@&", [baseURL urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    [signatureBaseString appendString:[parameterString urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    
    // -------------
    
    
    // generating signing key
    NSMutableString* signingKey = [NSMutableString string];
    [signingKey appendFormat:@"%@&", [oauth_consumer_secret urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    [signingKey appendString:[oauth_token_secret urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    
    // -------------
    
    
    NSString* oauth_signature = [signatureBaseString base64StringWithHMACSHA1Digest:signingKey];

    // -------------
    
    
    // generating authorisation header
    NSMutableDictionary* authorisationHeaderDic = [NSMutableDictionary dictionary];
    [authorisationHeaderDic setObject:oauth_consumer_key forKey:@"oauth_consumer_key"];
    [authorisationHeaderDic setObject:oauth_nonce forKey:@"oauth_nonce"];
    [authorisationHeaderDic setObject:oauth_signature forKey:@"oauth_signature"];
    [authorisationHeaderDic setObject:oauth_signature_method forKey:@"oauth_signature_method"];
    [authorisationHeaderDic setObject:oauth_timestamp forKey:@"oauth_timestamp"];
    [authorisationHeaderDic setObject:oauth_token forKey:@"oauth_token"];
    [authorisationHeaderDic setObject:oauth_version forKey:@"oauth_version"];
    
    // escape keys and values
    enumerator = [authorisationHeaderDic keyEnumerator];
    //NSString* key;
    //NSString* object;
    
    NSMutableDictionary* escapedauthorisationHeaderDic = [NSMutableDictionary dictionary];
    
    while ((key = (NSString*)[enumerator nextObject])) 
    {
        object = [authorisationHeaderDic objectForKey:key];
        [escapedauthorisationHeaderDic setObject:[object urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                          forKey:[key urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    NSMutableString* authorisationHeader = [NSMutableString string];
    [authorisationHeader appendString:@"OAuth "];
    
    enumerator = [escapedauthorisationHeaderDic keyEnumerator];
    NSInteger keysCounter = [escapedauthorisationHeaderDic count];
    while ((key = (NSString*)[enumerator nextObject]))
    {
        isLastKey = (BOOL)(--keysCounter == 0);
        [authorisationHeader appendFormat:@"%@=\"%@\"%@", key, [escapedauthorisationHeaderDic objectForKey:key], (isLastKey)?@"":@", "];
    }
    
    
    // ---------
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[baseURL stringByAppendingFormat:@"?screen_name=%@&include_entities=%@", username, include_entities]]];
    [request setHTTPMethod:httpMethod];

#ifndef NO_CONNECTION_LOGS
    NSLog(@"get info request = %@", request);
#endif
    
    [request setValue:@"OAuth gem v0.4.4" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authorisationHeader forHTTPHeaderField:@"Authorization"];
    
    MDTwitterPosterConnection* connection = [[[MDTwitterPosterConnection alloc] initWithRequest:request delegate:nil startImmediately:NO] autorelease];
    connection.type = TP_CONNECITON_TYPE_GETINFO;    
    
    [connection start];
}

+ (NSString*) generateNonce {
    
    char buf[32];
    for (int i=0; i<32; i++)
    {
        buf[i] = arc4random() % 256;
    }
    
    NSData* data = [[[NSData alloc] initWithBytes:buf length:32] autorelease];
    return [[data base64EncodingWithLineLength:0] stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
}

- (void) dealloc {
    [_connections release]; _connections = nil;
    [_delegate release]; _delegate = nil;
    
    [super dealloc];
}

@end
