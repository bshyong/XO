//
//  STInboxViewController.h
//  XO
//
//  Created by Benjamin Shyong on 6/27/14.
//  Copyright (c) 2014 ShyongTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface STInboxViewController : UITableViewController
- (IBAction)logout:(id)sender;
@property (strong, nonatomic)NSArray *messages;
@property (strong, nonatomic)PFObject *selectedMessage;
@property (strong, nonatomic)MPMoviePlayerController *moviePlayer;
@end
