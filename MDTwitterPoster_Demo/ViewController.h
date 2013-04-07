//
//  ViewController.h
//  MDTwitterPoster_Demo
//
//  Created by MANIAK_dobrii on 10/23/12.
//  Copyright (c) 2012 MANIAK_dobrii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDTwitterPoster.h"
#import "Settings.h"

@interface ViewController : UIViewController <MDTwitterPosterDelegate, UITextViewDelegate, UITextFieldDelegate>
{
    UITextView* _twitTextView;
    UITextView* _getUserInfoTextView;
    
    UIButton* _twitButton;
    UIButton* _getUserInfoButton;
    
    UITextField* _screenNameTextField;
    
    UIActivityIndicatorView* _twitActivityIndicator;
    UIActivityIndicatorView* _getUserInfoActivityIndicator;
    
    UIView* _whyUNoView;
    
    BOOL _twitTextViewHadText;
}
@property (nonatomic, retain) IBOutlet UITextView* twitTextView;
@property (nonatomic, retain) IBOutlet UITextView* getUserInfoTextView;

@property (nonatomic, retain) IBOutlet UIButton* twitButton;
@property (nonatomic, retain) IBOutlet UIButton* getUserInfoButton;

@property (nonatomic, retain) IBOutlet UITextField* screenNameTextField;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* twitActivityIndicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* getUserInfoActivityIndicator;

@property (nonatomic, retain) IBOutlet UIView* whyUNowView;

- (IBAction)onTwitButtonTapped:(id)sender;
- (IBAction)onGetUserInfoTapped:(id)sender;


#pragma mark MDTwitterPoster integration
- (void) twit: (NSString*)tweet;
- (void) getUserInfoForScreenName: (NSString*)screenName;

#pragma mark user input validation
- (BOOL) validateTwitText;
- (BOOL) validateScreenName;
- (BOOL) validateSettings;

#pragma mark UI
- (void) uiStartTwitAnimated: (BOOL)animated;
- (void) uiEndTwitAnimated: (BOOL)animated;

- (void) showTwitActivityIndicatorAnimated:(BOOL)animated;
- (void) hideTwitActivityIndicatorAnimated:(BOOL)animated;

- (void) uiStartGetUserInfoAnimated: (BOOL)animated;
- (void) uiEndGetUserInfoAnimated: (BOOL)animated;

- (void) showGetUserInfoActivityIndicatorAnimated:(BOOL)animated;
- (void) hideGetUserInfoActivityIndicatorAnimated:(BOOL)animated;


- (void) _releaseOutlets;

@end
