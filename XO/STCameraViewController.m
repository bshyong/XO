//
//  STCameraViewController.m
//  XO
//
//  Created by Benjamin Shyong on 6/27/14.
//  Copyright (c) 2014 ShyongTech. All rights reserved.
//

#import "STCameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MSCellAccessory.h"

@interface STCameraViewController ()

@end

@implementation STCameraViewController

UIColor *disclosureColor;

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.recipients = [[NSMutableArray alloc] init];
  disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // load the friends relation each time view appears
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      if (error) {
        NSLog(@"Error: %@ %@", error, [error userInfo]);
      } else {
        self.friends = objects;
        [self.tableView reloadData];
      }
    }];
  
  if (self.image == nil && [self.videoFilePath length] == 0) {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = NO;
    // set maximum duration of videos to 10s
    self.imagePicker.videoMaximumDuration = 10;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
      self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
      self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
    
    [self presentViewController:self.imagePicker animated:NO completion:nil];
  }
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
    return [self.friends count];
}

#pragma mark - ImagePickerController delegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
  NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
  if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
      UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
    }
  } else {
    // a video was selected
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    self.videoFilePath = [videoURL path];
    if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
      if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
        UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
      }
    }
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
  
    if ([self.recipients containsObject:user.objectId]) {
      UIColor *disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
      cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor];
    } else {
      cell.accessoryView = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  PFUser *user = [self.friends objectAtIndex:indexPath.row];
  
  if (cell.accessoryView == nil) {
    UIColor *disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor];
    [self.recipients addObject:user.objectId];
  } else {
    cell.accessoryView = nil;
    [self.recipients removeObject:user.objectId];
  }
}


#pragma mark - IBActions



- (IBAction)cancelSend:(id)sender {
  [self reset];
  [self.tabBarController setSelectedIndex:0];
}

- (IBAction)sendMessage:(id)sender {
  if (self.image == nil && [self.videoFilePath length] == 0) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please capture a photo or video" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [self presentViewController:self.imagePicker animated:NO completion:nil];
  } else {
    [self uploadMessage];
    [self.tabBarController setSelectedIndex:0];
  }
}


# pragma mark - Helper Methods

- (void)reset {
  self.image = nil;
  self.videoFilePath = nil;
  [self.recipients removeAllObjects];
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height{
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resizedImage;
}

-(void)uploadMessage{
  NSData *fileData;
  NSString *fileName;
  NSString *fileType;
  
  if (self.image != nil) {
    UIImage *newImage = [self resizeImage:self.image toWidth:320.0f andHeight:480.0f];
    fileData = UIImagePNGRepresentation(newImage);
    fileName = @"image.png";
    fileType = @"image";
    
  } else {
    fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
    fileName = @"video.mov";
    fileType = @"video";
  }
  
  PFFile *file = [PFFile fileWithName:fileName data:fileData];

  [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (error) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please try sending your message again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    } else {
      // these asynchronous calls are chained—message sending only occurs if the image file was saved successfully
      PFObject *message = [PFObject objectWithClassName:@"Messages"];
      [message setObject:file forKey:@"file"];
      [message setObject:fileType forKey:@"fileType"];
      [message setObject:self.recipients forKey:@"recipientIds"];
      [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
      [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
      [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please try sending your message again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
          [alert show];
        } else {
          // send was successful
          // reset everything
          [self reset];
        }
      }];
    }
  }];

}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
