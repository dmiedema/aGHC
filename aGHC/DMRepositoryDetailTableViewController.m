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
    // Create spinner to show im working
    JSNotifier *notifier = [[JSNotifier alloc] initWithTitle:@"Loading..."];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    [notifier setAccessoryView:activityIndicator];
    [notifier setTitle:@"Loading..." animated:YES];
    [notifier show];
    NSLog(@"Selected Details : %@", [[self directoryContents] objectAtIndex:[indexPath row]]);
    DMRepositoryDetailTableViewController *subView = [[DMRepositoryDetailTableViewController alloc] init];
    NSDictionary *selected = [[self directoryContents] objectAtIndex:[indexPath row]];
    NSString *token     = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
    
    NSString *path = [[[self directoryContents] objectAtIndex:[indexPath row]] objectForKey:@"path"];
    // GET /repos/:owner/:repo/contents/:path

    NSString *requestURL;
    if (token && tokenType) {
        requestURL = [NSString stringWithFormat:@"%@?%@=%@&%@=%@", [selected objectForKey:@"url"], kAccessToken, token, kTokenType, tokenType];
    } else {
        requestURL = [selected objectForKey:@"url"]; }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    
    NSLog(@"Request URL %@", [request URL]);
    
    AFJSONRequestOperation *folderOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [subView setDirectoryContents:JSON];
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityIndicator stopAnimating];
            [notifier setTitle:@"Complete" animated:YES];
            [notifier setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyCheck"]]];
            [notifier hideIn:1.0];
            [[self navigationController] pushViewController:subView animated:YES];
        });
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error : %@", error);
    }];

    /*@property (nonatomic, strong) NSArray  *directoryContents;
     @property (nonatomic, strong) NSString *currentPath;
     
     @property (nonatomic, strong) NSString *owner;
     @property (nonatomic, strong) NSString *reponame;*/
    
    NSLog(@"%@", [[self directoryContents] objectAtIndex:[indexPath row]]);
    if ([[[[self directoryContents] objectAtIndex:[indexPath row]] valueForKey:@"type"] isEqualToString:@"dir"]) {
        [subView setTitle:path];
        [subView setOwner:[self owner]];
        [subView setReponame:[self reponame]];
        [folderOperation start];
    } else if ([[[[self directoryContents] objectAtIndex:[indexPath row]] valueForKey:@"type"] isEqualToString:@"file"]) {
        NSLog(@"File : %@", [selected objectForKey:@"name"]);
        NSLog(@"Selected File:  %@", selected);
        [notifier setTitle:@"Complete" animated:YES];
        [notifier setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyCheck"]]];
        [notifier hideIn:1.0];
    }
}


@end
