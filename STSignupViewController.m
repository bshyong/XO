//
//  STSignupViewController.m
//  XO
//
//  Created by Benjamin Shyong on 6/27/14.
//  Copyright (c) 2014 ShyongTech. All rights reserved.
//

#import "STSignupViewController.h"
#import <Parse/Parse.h>

@interface STSignupViewController ()

@end

@implementation STSignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)signup:(id)sender {

  NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

  NSString *errorMessage = nil;
  if ([email length] == 0) {
    errorMessage = @"Please enter your email address!";
  }
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
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    newUser.email = email;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
