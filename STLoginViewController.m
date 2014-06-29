//
//  STLoginViewController.m
//  XO
//
//  Created by Benjamin Shyong on 6/27/14.
//  Copyright (c) 2014 ShyongTech. All rights reserved.
//

#import "STLoginViewController.h"
#import <Parse/Parse.h>

@interface STLoginViewController ()

@end

@implementation STLoginViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  if ([UIScreen mainScreen].bounds.size.height == 568) {
    self.backgroundImageView.image = [UIImage imageNamed:@"loginBackground"];
  }
  
  // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  // hide the nav bar
  [self.navigationController.navigationBar setHidden:YES];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)login:(id)sender {
  
  NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  NSString *errorMessage = nil;

  if([username length] == 0) {
    errorMessage = @"Please enter a username!";
  }
  if ([password length] == 0) {
    errorMessage = @"Please enter a password!";
  }
  
  if(errorMessage){
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    errorMessage = nil;
  } else {
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
      if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
      } else {
        [self.navigationController popViewControllerAnimated:YES];
      }
    }];
  }
  
  
}


@end


