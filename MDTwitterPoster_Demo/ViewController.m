//
//  ViewController.m
//  MDTwitterPoster_Demo
//
//  Created by MANIAK_dobrii on 10/23/12.
//  Copyright (c) 2012 MANIAK_dobrii. All rights reserved.
//

#import "ViewController.h"
#define TWIT_PLACEHOLDER_TEXT @"Your tweet text here"
#define GET_USER_INFO_LOADING_TEXT @"Getting userInfo for you..."
#define GET_USER_INFO_ERROR_TEXT @"Nope, got error."
#define TWIT_TEXT_COLOR [UIColor colorWithWhite:0.0 alpha:1.0]
#define PLACEHOLDER_TEXT_COLOR [UIColor colorWithWhite:0.38 alpha:0.68]

@implementation ViewController
@synthesize     twitTextView = _twitTextView,
         getUserInfoTextView = _getUserInfoTextView,
                  twitButton = _twitButton,
           getUserInfoButton = _getUserInfoButton,
         screenNameTextField = _screenNameTextField,
       twitActivityIndicator = _twitActivityIndicator,
getUserInfoActivityIndicator = _getUserInfoActivityIndicator,
                 whyUNowView = _whyUNoView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - MDTwitterPoster integration
- (void) twit: (NSString*)tweet {
    // set delegate to receive callbacks via MDTwitterPosterDelegate protocol
    [[MDTwitterPoster sharedInstance] setDelegate:self];
    
    // note that all the data is already validated
    // so there should be no error due to empty values
    [MDTwitterPoster twitWithAppKey:OAUTH_CONSUMER_KEY 
                          appSecret:OAUTH_CONSUMER_SECRET
                              token:OAUTH_TOKEN 
                        tokenSecret:OAUTH_TOKEN_SECRET 
                            message:tweet];
}

- (void) getUserInfoForScreenName: (NSString*)screenName {
    // set delegate to receive callbacks via MDTwitterPosterDelegate protocol
    [[MDTwitterPoster sharedInstance] setDelegate:self];
    
    // note that all the data is already validated
    // so there should be no error due to empty values
    [MDTwitterPoster getUserInfoWithAppKey:OAUTH_CONSUMER_KEY
                                 appSecret:OAUTH_CONSUMER_SECRET
                                     token:OAUTH_TOKEN
                               tokenSecret:OAUTH_TOKEN_SECRET
                                screenName:screenName];    
}

#pragma mark MDTwitterPosterDelegate
// When MDTwitterPoster manages to update a status (= send twit)
- (void) mdTwitterPoster:(MDTwitterPoster*)mdTwitterPoster didUpdateStatus:(NSString*)newStatus {
    [self uiEndTwitAnimated:YES];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:@"Yepp, your tweet was succesfully sent via MDTwitterPoster"
                                                   delegate:nil
                                          cancelButtonTitle:@"Hell yeah!"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

// When MDTwitterPoster fails to update status (= send twit) for any reason
- (void) mdTwitterPoster:(MDTwitterPoster*)mdTwitterPoster didFailToUpdateStatus:(NSString *)newStatus withError:(NSError*)error {
    [self uiEndTwitAnimated:YES];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"Nope, got error while tweeting: %@", error.domain]
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

// When MDTwitterPoster manages to get userInfo
- (void) mdTwitterPoster:(MDTwitterPoster *)mdTwitterPoster gotUserInfo:(NSDictionary*)userInfo {
    [self uiEndGetUserInfoAnimated:YES];
    
    _getUserInfoTextView.textAlignment = NSTextAlignmentLeft;
    _getUserInfoTextView.text = [userInfo description]; // fill text view with obtained userInfo
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:@"Good news, you've received userInfo via MDTwitterPoster"
                                                   delegate:nil
                                          cancelButtonTitle:@"Hell yeah!"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

// When MDTwitterPoster manages to get userInfo
- (void) mdTwitterPoster:(MDTwitterPoster *)mdTwitterPoster didFailToGetUserInfoWithError:(NSError*)error {
    [self uiEndGetUserInfoAnimated:YES];
    
    _getUserInfoTextView.textAlignment = NSTextAlignmentCenter;
    _getUserInfoTextView.text = GET_USER_INFO_ERROR_TEXT;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"Nope, got error while getting userInfo: %@", error.domain]
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

// When connection for doing stuff with MDTwitterPoster get's cancelled
- (void) mdTwitterPoster:(MDTwitterPoster *)mdTwitterPoster gotConnectionCancelled:(MDTwitterPosterConnection*)connection {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Good for you"
                                                    message:@"You've managed to cancel a connection."
                                                   delegate:nil cancelButtonTitle:@"Yessir!"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

#pragma mark -


#pragma mark Actions
// When you tap on Twit button
- (IBAction)onTwitButtonTapped:(id)sender {
    if([self validateTwitText])
    {
        [_twitTextView becomeFirstResponder];
        return;
    }
    
    
    [self uiStartTwitAnimated:YES];
    [self twit:_twitTextView.text];
}

// When you tap on Get user info button
- (IBAction)onGetUserInfoTapped:(id)sender {
    if([self validateScreenName])
    {
        [_screenNameTextField becomeFirstResponder];
        return;
    }
    
    [self uiStartGetUserInfoAnimated:YES];
    [self getUserInfoForScreenName:_screenNameTextField.text];
}


#pragma mark - Nothing interesting below -
// ( . )( . ) <---- boobies for your attention
// (=^_^=) <----- kitty for your attention (if you're a girl)
//
// Really, nothing interesting below, only required UI/processing stuff,
// everything you'll need to use is described above.
// -------------------------------------------------------------------------------
//

#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if(!_twitTextViewHadText)
    {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if(!_twitTextViewHadText)
    {
        _twitTextView.text = TWIT_PLACEHOLDER_TEXT;
        _twitTextView.textColor = PLACEHOLDER_TEXT_COLOR;
    }
    else
    {
        _twitTextView.textColor = TWIT_TEXT_COLOR;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // handle return key
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        
        return NO;
    }
    
    textView.textColor = TWIT_TEXT_COLOR;
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if([[_twitTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0)
    {
        _twitTextViewHadText = YES;
    }
    else
    {
        _twitTextViewHadText = NO;
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark user input validation
- (BOOL) validateTwitText {
    if(!_twitTextViewHadText || [[_twitTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Empty tweets are not allowed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return YES;
    }
    return NO;
}

- (BOOL) validateScreenName {
    if([[_screenNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Empty screen name is not allowed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return YES;
    }
    return NO;    
}

- (BOOL) validateSettings {
    if(![OAUTH_CONSUMER_KEY length] || ![OAUTH_CONSUMER_SECRET length] || ![OAUTH_TOKEN length] || ![OAUTH_TOKEN_SECRET length])
    {
        // not ok
        return YES;
    }
    
    // ok
    return NO;
}

#pragma mark UI
- (void) uiStartTwitAnimated: (BOOL)animated {
    [self showTwitActivityIndicatorAnimated:animated];
    [_twitTextView resignFirstResponder];
    _twitTextView.editable = NO;
}

- (void) uiEndTwitAnimated: (BOOL)animated {
    [self hideTwitActivityIndicatorAnimated:animated];
    _twitTextView.editable = YES;
}

- (void) showTwitActivityIndicatorAnimated:(BOOL)animated {
    // it was hidden in the IB
    _twitActivityIndicator.hidden = NO;
    
    // move it to the right out of the screen
    CGRect Frame = _twitActivityIndicator.frame;
    Frame.origin.x = 320;
    _twitActivityIndicator.frame = Frame;
    
    // make it transparent
    _twitActivityIndicator.alpha = 0.0;
    
    if(animated)
    {
        [UIView beginAnimations:@"ToggleTwitAI" context:nil];
    }
    
    {
        // move activity indicator to the center of superview
        Frame.origin.x = _twitActivityIndicator.superview.frame.size.width / 2.0 - Frame.size.width / 2.0;
        _twitActivityIndicator.frame = Frame;
        
        // make activity indicator visible
        _twitActivityIndicator.alpha = 1.0;
        
        // make button transparent
        _twitButton.alpha = 0.0;
    }
    
    if(animated)
    {
        [UIView commitAnimations];
    }
}

- (void) hideTwitActivityIndicatorAnimated:(BOOL)animated {
    // move it to the right out of the screen
    CGRect Frame = _twitActivityIndicator.frame;
    
    if(animated)
    {
        [UIView beginAnimations:@"ToggleTwitAI" context:nil];
    }
    
    {
        // move activity indicator to the left out of the screen
        Frame.origin.x = - Frame.size.width / 2.0;
        _twitActivityIndicator.frame = Frame;
        
        // make activity indicator transparent
        _twitActivityIndicator.alpha = 0.0;
        
        // make button visible
        _twitButton.alpha = 1.0;
    }
    
    if(animated)
    {
        [UIView commitAnimations];
    }    
}

- (void) uiStartGetUserInfoAnimated: (BOOL)animated {
    _getUserInfoTextView.textAlignment = NSTextAlignmentCenter;
    _getUserInfoTextView.text = GET_USER_INFO_LOADING_TEXT;
    [self showGetUserInfoActivityIndicatorAnimated:animated];
}

- (void) uiEndGetUserInfoAnimated: (BOOL)animated {
    [self hideGetUserInfoActivityIndicatorAnimated:animated];
}

- (void) showGetUserInfoActivityIndicatorAnimated:(BOOL)animated {
    // it was hidden in the IB
    _getUserInfoActivityIndicator.hidden = NO;
    
    // move it to the right out of the screen
    CGRect Frame = _getUserInfoActivityIndicator.frame;
    Frame.origin.x = 320;
    _getUserInfoActivityIndicator.frame = Frame;
    
    // make it transparent
    _getUserInfoActivityIndicator.alpha = 0.0;
    
    if(animated)
    {
        [UIView beginAnimations:@"ToggleGetUserInfoAI" context:nil];
    }
    
    {
        // move activity indicator to the center of superview
        Frame.origin.x = _getUserInfoActivityIndicator.superview.frame.size.width / 2.0 - Frame.size.width / 2.0;
        _getUserInfoActivityIndicator.frame = Frame;
        
        // make activity indicator visible
        _getUserInfoActivityIndicator.alpha = 1.0;
        
        // make button transparent
        _getUserInfoButton.alpha = 0.0;
    }
    
    if(animated)
    {
        [UIView commitAnimations];
    }    
}

- (void) hideGetUserInfoActivityIndicatorAnimated:(BOOL)animated {
    // move it to the right out of the screen
    CGRect Frame = _getUserInfoActivityIndicator.frame;
    
    if(animated)
    {
        [UIView beginAnimations:@"ToggleGetUserInfoAI" context:nil];
    }
    
    {
        // move activity indicator to the left out of the screen
        Frame.origin.x = - Frame.size.width / 2.0;
        _getUserInfoActivityIndicator.frame = Frame;
        
        // make activity indicator transparent
        _getUserInfoActivityIndicator.alpha = 0.0;
        
        // make button visible
        _getUserInfoButton.alpha = 1.0;
    }
    
    if(animated)
    {
        [UIView commitAnimations];
    }        
}

- (void) showWhyUNoViewAnimated: (BOOL)animated {
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    if(!window)
    {
        window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    }
    
    [window addSubview:_whyUNoView];
    [window bringSubviewToFront:_whyUNoView];
    
    _whyUNoView.transform = CGAffineTransformMake(2.0, 0.0, 0.0, 2.0, 0.0, 0.0);
    _whyUNoView.alpha = 0.0;
    
    if(animated)
    {
        [UIView beginAnimations:@"showWhyUNoView" context:nil];
    }
    
    {
        _whyUNoView.transform = CGAffineTransformIdentity;
        _whyUNoView.alpha = 1.0;
    }
    
    if(animated)
    {
        [UIView commitAnimations];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self _releaseOutlets];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([self validateSettings])
    {
        [self showWhyUNoViewAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) _releaseOutlets {
    [_twitTextView release]; _twitTextView = nil;
    [_getUserInfoTextView release]; _getUserInfoTextView = nil;
    
    [_twitButton release]; _twitButton = nil;
    [_getUserInfoButton release]; _getUserInfoButton = nil;
    
    [_screenNameTextField release]; _screenNameTextField = nil;
    
    [_twitActivityIndicator release]; _twitActivityIndicator = nil;
    [_getUserInfoActivityIndicator release]; _getUserInfoActivityIndicator = nil;
    
    [_whyUNoView release]; _whyUNoView = nil;
}

- (void) dealloc {
    [self _releaseOutlets];
    
    [super dealloc];
}

@end
