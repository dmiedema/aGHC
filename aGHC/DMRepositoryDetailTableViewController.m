//
//  DMRepositoryDetailTableViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/19/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMRepositoryDetailTableViewController.h"
#import "M6ParallaxController.h"
//#import "MBProgressHUD.h"
#import "JSNotifier.h"

@interface DMRepositoryDetailTableViewController ()

- (IBAction)dismissMe:(id)sender;
- (void)loadDetailsOfRepository;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self loadDetailsOfRepository];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// parallax stuff
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.parallaxController tableViewControllerDidScroll:self];
}
// incase i need to dismiss
- (void)dismissMe:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// is this for the view controller? this seems more 'model' code...
- (void)loadDetailsOfRepository{
    UIFont *defaultFont = [UIFont fontWithName:@"Avenir" size:20.0f];
    
    // set up label/button fonts
    [[self username] setFont:defaultFont];
    [[self description] setFont:defaultFont];
    [[self forks] setFont:defaultFont];
    [[self stargazers] setFont:defaultFont];
    [[self openIssues] setFont:defaultFont];
    [[self size] setFont:defaultFont];
    [[self exploreCode] setFont:defaultFont];
    
    // put the crap in the labels
    [[self description] setText:[[self repo] objectForKey:@"description"]];
    [[self forks]       setText:[NSString stringWithFormat:@"Forks - %@", [[self repo] objectForKey:@"forks"]]];
    [[self stargazers]  setText:[NSString stringWithFormat:@"Stars - %@", [[self repo] objectForKey:@"watchers_count"]]];
    [[self openIssues]  setText:[NSString stringWithFormat:@"Current Issues - %@", [[self repo] objectForKey:@"open_issues_count"]]];
    [[self size]        setText:[NSString stringWithFormat:@"Size - %@", [[self repo] objectForKey:@"size"]]];
    [[self exploreCode] setText:@"Explore the Code"];
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
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) { // first section
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 54)];
        [headerLabel setText:[[self repo] objectForKey:@"name"]];
        [headerLabel setFont:[UIFont fontWithName:@"Avenir" size:24.0]];
        [headerView addSubview:headerLabel];
        return headerView;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        return 74.0f;
    }
    return 54.0f;
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

-(void)buttonPressed:(UIButton *)sender {
    NSLog(@"Button Press: %@", [sender currentTitle]);
}

@end
