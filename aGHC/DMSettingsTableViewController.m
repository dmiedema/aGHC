//
//  DMSettingsTableViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 3/9/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMSettingsTableViewController.h"
#import "AFOAuth2Client.h"

@interface DMSettingsTableViewController ()

@property (strong, nonatomic) NSArray *settingsOptions;

@end


@implementation DMSettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //_settingsOptions = [NSArray arrayWithObjects:@"About", @"Follow the Developer", @"Follow the Designer", @"Licensing Information", @"Other Settings", @"Done", nil];
            }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"DMSettingsTableViewController viewDidLoad");

    _settingsOptions = @[@"About", @"Follow the Developer", @"Follow the Designer", @"Licensing Information", @"Other Settings", @"Done", @"SUPER LONG TEST! SUPER LONG TEST! SUPER LONG TEST! SUPER LONG TEST! SUPER LONG TEST! "];
    NSLog(@"settingsOptions: %@", _settingsOptions);
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
//    NSLog(@"count: %i", [_settingsOptions count]);
    return [_settingsOptions count];
}
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define FONT_NAME @"AvenirNext-Regular"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    // Configure the cell...
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    label.minimumScaleFactor = FONT_SIZE;
    [label setNumberOfLines:0];
    [label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
    [label setTag:1];
    
    [[cell contentView] addSubview:label];
    
    NSString *text = [_settingsOptions objectAtIndex:[indexPath row]];
//    NSLog(@"Text: %@", text);
//    NSLog(@"Cell: %@", cell);
//    NSLog(@"Label:  %@", label);
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 2000.0f);
    

    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    if(!label) {
        label = (UILabel *) [cell viewWithTag:1];
        
        [label setText:text];
        [label setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_WIDTH * 2), MAX(size.height, 50.0f))];
    }
    
//    [cell setAutoresizesSubviews:YES];
//    cell.textLabel.text = [[self settingsOptions] objectAtIndex:[indexPath row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [_settingsOptions objectAtIndex:[indexPath row]];
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN *2), 2000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];

    CGFloat height = MAX(size.height, 50.0f);
    
    return height + (CELL_CONTENT_MARGIN * 2);
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
