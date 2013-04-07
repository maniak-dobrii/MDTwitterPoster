//
//  MDTwitterPosterConnection.h
//
//  Created by MANIAK_dobrii on 10/7/12.
//  Copyright (c) 2012 MANIAK_dobrii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDTwitterPoster.h"

#define MDTPC_STATUS_KEY @"status"

@interface MDTwitterPosterConnection : NSURLConnection {
    NSMutableData* _data;
    
    NSString* _type;
    NSDictionary* _userInfo;
}

@property (nonatomic, retain) NSMutableData* data;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSDictionary* userInfo;

@end
