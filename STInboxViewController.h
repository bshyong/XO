//
//  STInboxViewController.h
//  XO
//
//  Created by Benjamin Shyong on 6/27/14.
//  Copyright (c) 2014 ShyongTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STInboxViewController : UITableViewController
- (IBAction)logout:(id)sender;
@property (strong, nonatomic)NSArray *messages;

@end
