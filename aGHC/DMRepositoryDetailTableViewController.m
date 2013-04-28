//
//  DMRepositoryDetailTableViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/19/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMRepositoryDetailTableViewController.h"
#import "DMRepositoryDetailTableViewCell.h"
//#import "MBProgressHUD.h"
#import "JSNotifier.h"

@interface DMRepositoryDetailTableViewController ()

@end

@implementation DMRepositoryDetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] registerNib:
     [UINib nibWithNibName:@"DMRepositoryDetailTableViewCell" bundle:[NSBundle mainBundle]]
           forCellReuseIdentifier:@"cell"];

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
    return [[self directoryContents] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    DMRepositoryDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        DMRepositoryDetailTableViewCell *cell = [[DMRepositoryDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    // Configure the cell...
    NSDictionary *currentItem = [[self directoryContents] objectAtIndex:[indexPath row]];
    NSLog(@"currentItem: %@", currentItem);
    
    [[cell largeLabel] setText:[currentItem objectForKey:@"name"]];
    NSString *type = [currentItem objectForKey:@"type"];
    if ([type isEqualToString:@"dir"]) 
        [[cell smallLabel] setText:@"Directory"];
    else 
        [[cell smallLabel] setText:@"File"];
//    [[cell LargeLabel ][currentItem objectForKey:@"name"]];
//    [[cell SmallLabel ][currentItem objectForKey:@"type"]];
    
    return cell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section == 0) { // first section
//        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
//        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 54)];
//        [headerLabel setText:[self currentPath]];
//        [headerLabel setFont:[UIFont fontWithName:@"Avenir" size:24.0]];
//        [headerView addSubview:headerLabel];
//        return headerView;
//    }
//    return nil;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 54.0f;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    NSLog(@"Selected Item: %@", @"string");
//    int row = [indexPath row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@", [selectedCell textLabel]);
}


@end
