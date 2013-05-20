//
//  DMRepositoryViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/15/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMRepositoryViewController.h"
#import "HMSegmentedControl.h"
#import "DMRepositoryTableViewCell.h"
#import "JSNotifier.h"

#import "DMRepositoryDetailViewController.h"

#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

//static NSString *const kResourceContentTypeDefault = @"application/json";

@interface DMRepositoryViewController ()

@property (nonatomic, strong) NSMutableArray *repositories;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *access_token;
@property (nonatomic, strong) NSString *token_type;

@property (nonatomic, strong) NIKFontAwesomeIconFactory *factory;
//- (void)reloadRepositories;
- (IBAction)reloadRepositories:(id)sender;

@end

@implementation DMRepositoryViewController

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
//    [[self navigationController] setTitle:@"Repositories"];
    _factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    NIKFontAwesomeIconFactory *barFactory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    
    UIBarButtonItem *homeButton = [UIBarButtonItem new];
    [homeButton setImage:[barFactory createImageForIcon:NIKFontAwesomeIconHome]];
    [homeButton setAction:@selector(dismissMe:)];
    [homeButton setTarget:self];
    [homeButton setEnabled:YES];
    [homeButton setStyle:UIBarButtonItemStyleBordered];
    
    [[self navigationItem] setLeftBarButtonItem:homeButton];
    
    [self setUsername:[[NSUserDefaults standardUserDefaults] stringForKey:kUsername]];
    [self setAccess_token:[[NSUserDefaults standardUserDefaults] stringForKey:kAccessToken]];
    [self setToken_type:[[NSUserDefaults standardUserDefaults] stringForKey:kTokenType]];
    
    selectedIndex = 0;    
    
//    [[self tableView] registerNib:[UINib nibWithNibName:@"RepositoryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Repository Cell"];
    
//    [self reloadRepositories:segmentedControl];
    // load some info into the tableview. Select that bitch.
    //[self performSelector:@selector(reloadRepositories:)];
    
    /* This is shitty but I want things to appear when the view loads
        Loading in the 'mine' repos on load. Copy/Pasta from (reloadRespositores:) */
    HMSegmentedControl *sender;
    [sender setSelectedSegmentIndex:0];
    [self reloadRepositories:sender];
    
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
    return [[self repositories] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    DMRepositoryTableViewCell *tableCellView = [[DMRepositoryTableViewCell alloc] init];
    [cell addSubview:[tableCellView createTableViewCellWithDictionary:[_repositories objectAtIndex:[indexPath row]]]];
    return cell;
}

- (void)dismissMe:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadRepositories:(id)sender {
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
    
    if ([sender selectedSegmentIndex] == 0) {
         request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@user/repos?access_token=%@&token_type=%@", kGitHubApiURL, [self access_token], [self token_type]]]];
    } else if ([sender selectedSegmentIndex] == 1) {
        // starred
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@/starred", kGitHubApiURL, [self username]]]];
    } else { // watching
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@/subscriptions", kGitHubApiURL, [self username]]]];
    }
    
    [request setValue:kResourceContentTypeDefault forHTTPHeaderField:@"Accept"];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *reponse, id JSON){
        NSLog(@"JSON: %@", JSON);
        NSLog(@"Repositories count: %i",[[self repositories] count]);
        
        [self setRepositories:JSON];
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
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Mine", @"Starred", @"Watching"]];
    [segmentedControl setSelectedSegmentIndex:selectedIndex];
    [segmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]];
    [segmentedControl setFont:[UIFont fontWithName:kFontName size:20.0f]];
    [segmentedControl setSelectedTextColor:[UIColor blackColor]];
    [segmentedControl setTextColor:[UIColor grayColor]];
    [segmentedControl setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:1 alpha:0.5]];
    
    [segmentedControl addTarget:self action:@selector(reloadRepositories:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setFrame:CGRectMake(0, 10, 300, 54)];
    
    return segmentedControl;

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    // lolololol
    
    NSDictionary *selectedRepo = [[self repositories] objectAtIndex:[indexPath row]];
    NSLog(@"Selected: %@", [selectedRepo objectForKey:@"name"]);
    NSLog(@"\nSelected Details: %@", selectedRepo);
    
    DMRepositoryDetailViewController *viewController = [[DMRepositoryDetailViewController alloc] init];
    [viewController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [viewController setRepo:selectedRepo];
    [viewController setTitle:@"Details"];
    [[self navigationController] pushViewController:viewController animated:YES];
    
}

@end
