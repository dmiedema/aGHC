//
//  DMRepositoryCommitsTableViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 5/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMRepositoryCommitsTableViewController.h"

@interface DMRepositoryCommitsTableViewController ()

//@property (nonatomic, weak) NSDateFormatter *dateFormatter;

@end

@implementation DMRepositoryCommitsTableViewController

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
//    _dateFormatter = [[NSDateFormatter alloc] init];
//    [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    
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
    return [_commits count];
}

#define DEFAULT_LABEL_HEIGHT 20.0
#define PADDING  (DEFAULT_LABEL_HEIGHT / 2)
#define DEFAULT_LABEL_WIDTH 280

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int y = PADDING; // start off NOT at 0 because thats ugly.
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    // Configure the cell...
    NSDictionary *currentItem = [_commits objectAtIndex:[indexPath row]];
    
    
    // Get strings
    NSString *date = [[[currentItem objectForKey:@"commit"] objectForKey:@"committer"] objectForKey:@"date"];
    NSString *committer = [[currentItem objectForKey:@"author"] objectForKey:@"login"];
    NSString *commitMessage = [[currentItem objectForKey:@"commit"] objectForKey:@"message"];
    // Create labels
    UILabel *dateLabel = [[UILabel alloc] init];
    UILabel *committerLabel = [[UILabel alloc] init];
    UILabel *commitMessageLabel = [[UILabel alloc] init];
    // Break up date string
    NSRange range = [date rangeOfString:@"T"];
    NSString *dateString = [date substringToIndex:range.location];
    // setup default font to use
    UIFont *font = [UIFont fontWithName:@"Avenir" size:17.0];
    
    // setup committer label
    [committerLabel setAlpha:0.7];
    [committerLabel setFont:font];
    [committerLabel setText:committer];
    [committerLabel setBackgroundColor:[UIColor clearColor]];
    [committerLabel setFrame:CGRectMake(PADDING * 2, y, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT)];
    // increase y
    y += DEFAULT_LABEL_HEIGHT + PADDING;
    // setup message label
    [commitMessageLabel setFont:font];
    [commitMessageLabel setNumberOfLines:0];
    [commitMessageLabel setLineBreakMode:NSLineBreakByWordWrapping];
    CGSize constraintSize = CGSizeMake(DEFAULT_LABEL_WIDTH, MAXFLOAT);
    CGSize messageSize = [commitMessage sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    [commitMessageLabel setText:commitMessage];
    [commitMessageLabel setFrame:CGRectMake(PADDING * 2, y, messageSize.width, messageSize.height)];
    // increase y, again.
    y += messageSize.height + PADDING * 2;
    // setup date label
    [dateLabel setAlpha:0.7];
    [dateLabel setFont:font];
    [dateLabel setText:dateString];
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    [dateLabel setFrame:CGRectMake(PADDING * 2, y, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT)];
    
    // add labels to cell view
    [cell addSubview:committerLabel];
    [cell addSubview:commitMessageLabel];
    [cell addSubview:dateLabel];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *message = [[[_commits objectAtIndex:[indexPath row]] objectForKey:@"commit"] objectForKey:@"message"];
    CGSize textSize = [message sizeWithFont:[UIFont fontWithName:@"Avenir" size:17.0f] constrainedToSize:CGSizeMake(self.tableView.frame.size.width - PADDING * 4, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    return textSize.height + ((DEFAULT_LABEL_HEIGHT * 2) + (PADDING * 4));
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
}

@end
