//
//  DMGistExploreTableViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 5/20/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMGistExploreTableViewController.h"
#import "HMSegmentedControl.h"
#import "JSNotifier.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface DMGistExploreTableViewController ()

@property (nonatomic, strong) NSString *access_token;
@property (nonatomic, strong) NSString *token_type;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSArray *gists;

@property (nonatomic, strong) NIKFontAwesomeIconFactory *factory;

@end

@implementation DMGistExploreTableViewController

int selectedIndex;

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
    _access_token = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    _token_type = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
    _username = [[NSUserDefaults standardUserDefaults] objectForKey:kUsername];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    _factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    // [[self tabBarItem] setImage:[_factory createImageForIcon:NIKFontAwesomeIconEdit]];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    HMSegmentedControl *sender;
    [sender setSelectedSegmentIndex:0];
    [self reloadGists:sender];
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
    return [_gists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


- (void)dismissMe:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadGists:(id)sender {
    NSLog(@"Reload, selected index: %i", [sender selectedSegmentIndex]);
    selectedIndex = [sender selectedSegmentIndex];
    //TODO: Add loading indicator
    JSNotifier *notifier = [[JSNotifier alloc] initWithTitle:@"Loading..."];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    [notifier setAccessoryView: activityIndicator];
    [notifier show];
    //@"https://github.com/user/repos?access_token=&token_type=bearer";
    
    
    NSMutableURLRequest *request;
//    list, mine, all, starred
    if ([sender selectedSegmentIndex] == 0) { // list
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@/gists?access_token=%@&token_type=%@", kGitHubApiURL, _username, _access_token, _token_type]]];
    } else if ([sender selectedSegmentIndex] == 1) { // mine
        if (_token_type && _access_token) request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@gists?%@=%@&%@=%@", kGitHubApiURL, kAccessToken, _access_token, kTokenType, _token_type]]];
         else request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@gists", kGitHubApiURL]]];
    } else if ([sender selectedSegmentIndex] == 2) { // all
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@gists/public", kGitHubApiURL]]];
    } else { // starred
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@gists/starred?%@=%@&%@=%@", kGitHubApiURL, kAccessToken, _access_token, kTokenType, _token_type]]];
    }
    
    [request setValue:kResourceContentTypeDefault forHTTPHeaderField:@"Accept"];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *reponse, id JSON){
        NSLog(@"JSON: %@", JSON);
        NSLog(@"Repositories count: %i",[[self gists] count]);
        
        [self setGists:JSON];
        // Reload the table
        [[self tableView] reloadData];
        
        // Change the notifier
        [notifier setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyCheck"]]];
        [notifier setTitle:@"Complete" animated:YES];
        // Set notifier to hide.
        [notifier hideIn:2.0];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
        //        DDLogError(@"Error loading repositores!");
        NSLog(@"JSON: %@", JSON);
        
        // Change notifier to error
        [notifier setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyX"]]];
        [notifier setTitle:@"Error"];
        // Make it go away
        [notifier hideIn:2.0];
    }];
    
    [operation start];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"List", @"Mine", @"All", @"Starred"]];
    [segmentedControl setSelectedSegmentIndex:selectedIndex];
    [segmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]];
    [segmentedControl setFont:[UIFont fontWithName:kFontName size:16.0f]];
    [segmentedControl setSelectedTextColor:[UIColor blackColor]];
    [segmentedControl setTextColor:[UIColor grayColor]];
    [segmentedControl setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:1 alpha:0.5]];
    
    [segmentedControl addTarget:self action:@selector(reloadGists:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setFrame:CGRectMake(0, 10, 300, 54)];
    
    return segmentedControl;
    
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
