//
//  STEditFriendsViewController.m
//  XO
//
//  Created by Benjamin Shyong on 6/27/14.
//  Copyright (c) 2014 ShyongTech. All rights reserved.
//

#import "STEditFriendsViewController.h"
#import "MSCellAccessory.h";

@interface STEditFriendsViewController ()

@end

@implementation STEditFriendsViewController

UIColor *disclosureColor;

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.currentUser = [PFUser currentUser];

  // queries all elements in table by default
  PFQuery *query = [PFUser query];
  [query orderByAscending:@"username"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      NSLog(@"Error: %@ %@", error, [error userInfo]);
    } else {
      self.allUsers = objects;
      [self.tableView reloadData];
    }
  }];
  
  disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
  
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [self.allUsers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    // display a checkmark if the user is a friend
    if ([self isFriend:user]) {
      UIColor *disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
      cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor];
    } else {
      cell.accessoryView = nil;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
  PFRelation *friendsRelation = [self.currentUser relationForKey:@"friendsRelation"];
  
  if ([self isFriend:user]) {
    cell.accessoryView = nil;
    // TODO fix to not use looping
    for (PFUser *friend in self.friends) {
      if ([friend.objectId isEqualToString:user.objectId]) {
        [self.friends removeObject:friend];
        break;
      }
    }
    [friendsRelation removeObject:user];
  } else {
    UIColor *disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor];
    [self.friends addObject:user];
    [friendsRelation addObject:user];
  }

  [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (error) {
      NSLog(@"Error: %@ %@",  error, [error userInfo]);
    }
  }];
}



# pragma mark - helper methods
// TODO this loops through all friends for each friend!
// fix to use efficient search
- (BOOL)isFriend:(PFUser *)user{
  for (PFUser *friend in self.friends) {
    if ([friend.objectId isEqualToString:user.objectId]) {
      return YES;
    }
  }
  return NO;
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
