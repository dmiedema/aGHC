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
        NSLog(@"JSON %@", JSON);
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
    NSLog(@"contnets : %@", contents);
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
    NSLog(@"__repositoryNames : %@", repositoryNames);
    NSLog(@"__notificationDetails : %@", repositoryNotifications);
    
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

#define DEFAULT_LABEL_HEIGHT 20.0
#define PADDING (DEFAULT_LABEL_HEIGHT / 2)
#define DEFAULT_LABEL_WIDTH 280

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
    
    int y = PADDING; // starting off at 0 looks like doodoo.
    NSString *title = [dictionary objectForKey:@"title"];
    NSString *type  = [dictionary objectForKey:@"type"];
    
    UILabel *titleLabel = [UILabel new];
    UILabel *typeLabel  = [UILabel new];
    
    UIFont *font = [UIFont fontWithName:kFontName size:17.0];

    // setup title label
    [titleLabel setFont:font];
    [titleLabel setNumberOfLines:0];
    [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    CGSize constraintSize = CGSizeMake(DEFAULT_LABEL_WIDTH, MAXFLOAT);
    CGSize messageSize = [title sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    [titleLabel setText:title];
    [titleLabel setFrame:CGRectMake(PADDING * 2, y, messageSize.width, messageSize.height)];
    
    y += messageSize.height;
    
    // set up type label
    [typeLabel setAlpha:0.7];
    [typeLabel setTextColor:[UIColor darkGrayColor]];
    [typeLabel setFont:font];
    [typeLabel setText:[NSString stringWithFormat:@"Type - %@", type]];
    [typeLabel setBackgroundColor:[UIColor clearColor]];
    [typeLabel setFrame:CGRectMake(PADDING * 2, y, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT)];
    
    y += DEFAULT_LABEL_HEIGHT;
    
    [cell addSubview:titleLabel];
    [cell addSubview:typeLabel];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_repositoryNames objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentRepoSection = [_repositoryNames objectAtIndex:[indexPath section]];
    
    NSMutableArray *notificationsForCurrentSectionsRepo = [NSMutableArray new];
    for (NSDictionary *dictionary in _notificationDetails) {
        if ([[dictionary objectForKey:@"repoName"] isEqualToString:currentRepoSection] && ![notificationsForCurrentSectionsRepo containsObject:dictionary])
            [notificationsForCurrentSectionsRepo addObject:dictionary];
    }
    NSDictionary *dictionary = [notificationsForCurrentSectionsRepo objectAtIndex:[indexPath row]];
    
    CGSize textSize = [[dictionary objectForKey:@"title"] sizeWithFont:[UIFont fontWithName:kFontName size:17.0f] constrainedToSize:CGSizeMake(self.tableView.frame.size.width - PADDING * 4, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    return textSize.height + (PADDING * 4);
}

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
