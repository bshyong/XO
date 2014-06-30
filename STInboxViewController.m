//
//  STInboxViewController.m
//  XO
//
//  Created by Benjamin Shyong on 6/27/14.
//  Copyright (c) 2014 ShyongTech. All rights reserved.
//

#import "STInboxViewController.h"
#import "STImageViewController.h"
#import "MSCellAccessory.h"

@interface STInboxViewController ()

@end

@implementation STInboxViewController


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.moviePlayer = [[MPMoviePlayerController alloc] init];
  
  PFUser *currentUser = [PFUser currentUser];
  if (currentUser) {
    
  } else {
    [self performSegueWithIdentifier:@"showLogin" sender:self];
  }
  
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self action:@selector(retrieveMessages) forControlEvents:UIControlEventValueChanged];
  
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  // show the nav bar
  [self.navigationController.navigationBar setHidden:NO];

  [self retrieveMessages];
}

- (void)retrieveMessages {
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

    if (self.refreshControl.isRefreshing) {
      [self.refreshControl endRefreshing];
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
  
    UIColor *disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:disclosureColor];
  
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
      // file type is image
      [self performSegueWithIdentifier:@"showImage" sender:self];
    } else {
      // file type is video
      PFFile *videoFile = [self.selectedMessage objectForKey:@"file"];
      NSURL *fileURL = [NSURL URLWithString:videoFile.url];
      self.moviePlayer.contentURL = fileURL;
      [self.moviePlayer prepareToPlay];

      // show thumbnail instead of black screen before playing
      UIImage *thumbnail = [self thumbnailFromVideoAtURL:self.moviePlayer.contentURL];
      UIImageView *imageView = [[UIImageView alloc] initWithImage:thumbnail];
      [self.moviePlayer.backgroundView addSubview:imageView];
      
      // add movie player subview to current view
      [self.view addSubview:self.moviePlayer.view];
      [self.moviePlayer setFullscreen:YES animated:YES];
    }
  
  NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];
  if ([recipientIds count] == 1) {
    [self.selectedMessage deleteInBackground];
  } else {
    [recipientIds removeObject:[[PFUser currentUser] objectId]];
    [self.selectedMessage setObject:recipientIds forKey:@"recipientIds"];
    [self.selectedMessage saveInBackground];
  }
  
}

- (UIImage *)thumbnailFromVideoAtURL:(NSURL *)url
{
  AVAsset *asset = [AVAsset assetWithURL:url];
  
  //  Get thumbnail at the very start of the video
  CMTime thumbnailTime = [asset duration];
  thumbnailTime.value = 0;
  
  //  Get image from the video at the given time
  AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
  imageGenerator.appliesPreferredTrackTransform = YES;
  
  CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:NULL];
  UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  
  return thumbnail;
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
