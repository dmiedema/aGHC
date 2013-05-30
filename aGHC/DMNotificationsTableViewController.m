//
//  DMNotificationsTableViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 5/20/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMNotificationsTableViewController.h"
#import "DerpKit.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "MBProgressHUD.h"
#import "JSNotifier.h"

@interface DMNotificationsTableViewController ()

@property (nonatomic, strong) NSArray *repositoryNames;
@property (nonatomic, strong) NSArray *notificationDetails;

- (void)markAllNotificationsAsRead;

@end

@implementation DMNotificationsTableViewController

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

    [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
    NSString *baseURL = [NSString stringWithFormat:@"%@notifications", kGitHubApiURL];
    NSString *urlString;
    
    if (token && tokenType)
        urlString = [NSString stringWithFormat:@"%@?%@=%@&%@=%@", baseURL, kAccessToken, token, kTokenType, tokenType];
    else // errrrrr
        urlString = baseURL;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self loadTableContents:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [MBProgressHUD hideAllHUDsForView:[self view] animated:YES];
    }];
    [operation start];
    
    
    //// Nav Bar Icons
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];

    UIBarButtonItem *markAllAsRead = [UIBarButtonItem new];
    [markAllAsRead setImage:[factory createImageForIcon:NIKFontAwesomeIconOk]];
    [markAllAsRead setAction:@selector(markAllNotificationsAsRead)];
    [markAllAsRead setTarget:self];
    [markAllAsRead setEnabled:YES];
    [markAllAsRead setStyle:UIBarButtonItemStyleDone];
    
    UIBarButtonItem *homeButton = [UIBarButtonItem new];
    [homeButton setImage:[factory createImageForIcon:NIKFontAwesomeIconHome]];
    [homeButton setAction:@selector(dismissMe:)];
    [homeButton setTarget:self];
    [homeButton setEnabled:YES];
    [homeButton setStyle:UIBarButtonItemStyleBordered];
    
    [[self navigationItem] setLeftBarButtonItem:homeButton];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = markAllAsRead;
    
}

- (void)loadTableContents:(NSArray *)contents {
    NSMutableArray *repositoryNotifications = [NSMutableArray new];
    NSMutableArray *repositoryNames = [NSMutableArray new];
    for (NSDictionary *dictionary in contents) {
        NSString *id = [dictionary objectForKey:@"id"];
        NSString *repoName = [[dictionary objectForKey:@"repository"] objectForKey:@"name"];
        NSString *type = [[dictionary objectForKey:@"subject"] objectForKey:@"type"];
        NSString *title = [[dictionary objectForKey:@"subject"] objectForKey:@"title"];
        
        if (![repositoryNames containsObject:repoName])
            [repositoryNames addObject:repoName];
        
        NSDictionary *customDict = @{@"id" : id,
                                     @"repoName" : repoName,
                                     @"type" : type,
                                     @"title" : title };
        
        [repositoryNotifications addObject:customDict];
//        [repositoryNotifications addObject:dictionary];
    }
    
    _repositoryNames = repositoryNames;
    _notificationDetails = repositoryNotifications;
    
    [[self tableView] reloadData];
    [MBProgressHUD hideAllHUDsForView:[self view] animated:YES];
}

- (void)markAllNotificationsAsRead {
    
}
- (void)dismissMe:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_repositoryNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *repoNameAtIndex = [_repositoryNames objectAtIndex:section];
    int i = 0;
//    NSMutableArray *notificationsForRepo = [NSMutableArray new];
    for (NSDictionary *dict in _notificationDetails) {
        if ( [[dict objectForKey:@"repoName"] isEqualToString:repoNameAtIndex] ) {
            i++;
        }
    }
    return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    // Configure the cell...
    NSString *currentRepoSection = [_repositoryNames objectAtIndex:[indexPath section]];
    
    NSMutableArray *notificationsForCurrentSectionsRepo = [NSMutableArray new];
    for (NSDictionary *dictionary in _notificationDetails) {
        if ([[dictionary objectForKey:@"repoName"] isEqualToString:currentRepoSection] && ![notificationsForCurrentSectionsRepo containsObject:dictionary])
            [notificationsForCurrentSectionsRepo addObject:dictionary];
    }
    NSDictionary *dictionary = [notificationsForCurrentSectionsRepo objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [dictionary objectForKey:@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Type: %@", [dictionary objectForKey:@"type"]];
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_repositoryNames objectAtIndex:section];
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
