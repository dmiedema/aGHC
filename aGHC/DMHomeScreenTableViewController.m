//
//  DMHomeScreenTableViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/11/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMHomeScreenTableViewController.h"

@interface DMHomeScreenTableViewController ()
#define HOME_SCREEN_OPTIONS @[@"Notifications", @"Repositories", @"Explore", @"Gists", @"News Feed", @"Search"]
@end

@implementation DMHomeScreenTableViewController

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

#define HOME_LABEL_CELL_FRAME_X   20
#define HOME_LABEL_CELL_FRAME_Y   0
#define HOME_LABEL_CELL_WIDTH     280
#define HOME_LABEL_CELL_HEIGHT    64
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [HOME_SCREEN_OPTIONS count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *label = [[UILabel alloc] init];
    
    [label setFont:[UIFont fontWithName:@"Avenir" size:24.0]];
    [label setText:[NSString stringWithFormat:@"%@", [HOME_SCREEN_OPTIONS objectAtIndex:[indexPath row]]]];
    
    [label setFrame:CGRectMake(HOME_LABEL_CELL_FRAME_X, HOME_LABEL_CELL_FRAME_Y, HOME_LABEL_CELL_WIDTH, HOME_LABEL_CELL_HEIGHT)];
    
    [[cell contentView] addSubview:label];

    
    return cell;
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
    
    
    NSString *itemSelected = [HOME_SCREEN_OPTIONS objectAtIndex:[indexPath row]];
    
    if ([itemSelected isEqualToString:@"Notifications"]) {
        NSLog(@"Notifications Selected");
    } else if ([itemSelected isEqualToString:@"Repositories"]) {
        NSLog(@"Repositories Selected");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"RepositoryStoryboard_iPhone" bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [[UIViewController alloc] init];
        [viewController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [viewController setTitle:@"Repositories"];
        viewController = [storyboard instantiateInitialViewController];
        [self presentViewController:viewController animated:YES completion:nil];
    } else if ([itemSelected isEqualToString:@"Explore"]) {
        NSLog(@"Explore Selected");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ExploreStoryboard_iPhone" bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [[UIViewController alloc] init];
        [viewController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        viewController = [storyboard instantiateInitialViewController];
        [self presentViewController:viewController animated:YES completion:nil];
    } else if ([itemSelected isEqualToString:@"Gists"]) {
        NSLog(@"Gists Selected");
    } else if ([itemSelected isEqualToString:@"News Feed"]) {
        NSLog(@"News Feed Selected");
    } else if ([itemSelected isEqualToString:@"Search"]) {
        NSLog(@"Serach Selected");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SearchStoryboard_iPhone" bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [[UIViewController alloc] init];
        [viewController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        viewController = [storyboard instantiateInitialViewController];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        NSLog(@"Unknown Option Selected");
    }

}

@end
