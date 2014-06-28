//
//  STInboxViewController.m
//  XO
//
//  Created by Benjamin Shyong on 6/27/14.
//  Copyright (c) 2014 ShyongTech. All rights reserved.
//

#import "STInboxViewController.h"
#import "STImageViewController.h"

@interface STInboxViewController ()

@end

@implementation STInboxViewController


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  PFUser *currentUser = [PFUser currentUser];
  if (currentUser) {
    
  } else {
    [self performSegueWithIdentifier:@"showLogin" sender:self];
  }
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
  [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser] objectId]];
  [query orderByDescending:@"createdAt"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      NSLog(@"Error: %@ %@", error, [error userInfo]);
    } else {
      self.messages = objects;
      [self.tableView reloadData];
    }
  }];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    cell.textLabel.text = [message objectForKey:@"senderName"];
    NSString *fileType = [message objectForKey:@"fileType"];
    if([fileType isEqualToString:@"image"]){
      cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    } else {
      cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
  
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];
    if([fileType isEqualToString:@"image"]){
      [self performSegueWithIdentifier:@"showImage" sender:self];
    } else {

    }
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

- (IBAction)logout:(id)sender {
  [PFUser logOut];
  [self performSegueWithIdentifier:@"showLogin" sender:self];
}

// hide bottom bar on destination view controller before it is pushed onto the stack
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier isEqualToString:@"showLogin"]) {
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
  }
  else if ([segue.identifier isEqualToString:@"showImage"]) {
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    STImageViewController *imageViewController = (STImageViewController *)segue.destinationViewController;
    imageViewController.message = self.selectedMessage;
  }
}

@end
