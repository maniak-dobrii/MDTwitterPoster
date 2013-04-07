MDTwitterPoster
===============

Small iOS Twitter lib for `posting twits` and `getting user info for a screenName`. No authentication included. Could be a real savior if you have to support older iOS versions and still need some basic Twitter integration.

# Requirements
iOS 4.1+, no ARC.
Authentication tokens from anything which could authenticate with Twitter's OAuth 1.0A (for example MGTwitterEngine).

# Installation
1. Drag MDTwitterPoster, Base64, SBJSON folders and MDTwitterPosterIncludes.h to XCode project.
2. Add #import "MDTwitterPoster.h" to file, where you need to access MDTwitterPoster from.
3. That's all, if you need to disable NSLog's from MDTwitterPoster, comment #define NO_CONNECTION_LOGS line in MDTwitterPoster.h.

# Usage
This will post a twit:

    [MDTwitterPoster twitWithAppKey:OAUTH_CONSUMER_KEY 
                          appSecret:OAUTH_CONSUMER_SECRET
                              token:OAUTH_TOKEN 
                        tokenSecret:OAUTH_TOKEN_SECRET 
                            message:@"Your message"];

This will get userInfo for MANIAK_dobrii:

    [MDTwitterPoster getUserInfoWithAppKey:OAUTH_CONSUMER_KEY
                                 appSecret:OAUTH_CONSUMER_SECRET
                                     token:OAUTH_TOKEN
                               tokenSecret:OAUTH_TOKEN_SECRET
                                screenName:@"MANIAK_dobrii"]; 
                                
To get callbacks just check MDTwitterPosterDelegate in MDTwitterPoster.h, as easy as:

    - (void) mdTwitterPoster:(MDTwitterPoster*)mdTwitterPoster didUpdateStatus:(NSString*)newStatus {
      // all good, posted twit succesfully
    }

    - (void) mdTwitterPoster:(MDTwitterPoster*)mdTwitterPoster didFailToUpdateStatus:(NSString *)newStatus withError:(NSError*)error {
      // failed to twit
    }

# Licence
MDTwitterPoster is released under the MIT License by MANIAK_dobrii (Солодовниченко Михаил).
