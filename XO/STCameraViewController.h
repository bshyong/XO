//
//  STCameraViewController.h
//  XO
//
//  Created by Benjamin Shyong on 6/27/14.
//  Copyright (c) 2014 ShyongTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface STCameraViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *videoFilePath;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) PFRelation *friendsRelation;
@property (strong, nonatomic) NSMutableArray *recipients;
- (IBAction)cancelSend:(id)sender;
@end



