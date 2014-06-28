//
//  STImageViewController.h
//  XO
//
//  Created by Benjamin Shyong on 6/28/14.
//  Copyright (c) 2014 ShyongTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface STImageViewController : UIViewController

@property (strong, nonatomic)PFObject *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
