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
#import "DMParallaxViewController.h"

#import "DMRepositoryDetailViewController.h"

@interface DMRepositoryViewController ()

@property (nonatomic, strong) NSMutableArray *repositories;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *access_token;
@property (nonatomic, strong) NSString *token_type;

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
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissMe:)]; 
    self.navigationItem.leftBarButtonItem = homeButton;
    
    [self setUsername:[[NSUserDefaults standardUserDefaults] stringForKey:kUsername]];
    [self setAccess_token:[[NSUserDefaults standardUserDefaults] stringForKey:kAccessToken]];
    [self setToken_type:[[NSUserDefaults standardUserDefaults] stringForKey:kTokenType]];
    
    selectedIndex = 0;
    
//    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Mine", @"Starred", @"Watching"]];
//    [segmentedControl setSelectedSegmentIndex:0];
//    [segmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]];
//    [segmentedControl setFont:[UIFont fontWithName:@"Avenir" size:20.0f]];
//    [segmentedControl setSelectedTextColor:[UIColor blackColor]];
//    [segmentedControl setTextColor:[UIColor grayColor]];
//    
//    [segmentedControl addTarget:self action:@selector(reloadRepositories:) forControlEvents:UIControlEventValueChanged];
//    [segmentedControl setFrame:CGRectMake(0, 10, 300, 54)];
//    [[self view] addSubview:segmentedControl];
    
    
    [[self tableView] registerNib:[UINib nibWithNibName:@"RepositoryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Repository Cell"];
    
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
    static NSString *CellIdentifier = @"Repository Cell";
    // custom cell, gotta love that custom cell
    DMRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *currentRepo = [[self repositories] objectAtIndex:[indexPath row]];
    cell.repositoryName.text = [currentRepo objectForKey:@"name"];
    cell.repositoryDetailInfo.text = [NSString stringWithFormat:@"Forks: %@ - Issues: %@ - Watchers: %@",
                                      [currentRepo objectForKey:@"forks_count"],
                                      [currentRepo objectForKey:@"open_issues_count"],
                                      [currentRepo objectForKey:@"watchers"]];

    
    // repo private?
    if ([[currentRepo objectForKey:@"private"] integerValue] == 1) {
        [[cell privateRepo] setImage:[UIImage imageNamed:@"lock"]];
    } else [[cell privateRepo] setImage:nil];
    // repo fork?
    if ([[currentRepo objectForKey:@"fork"] integerValue] == 1) {
        [[cell typeImage] setImage:[UIImage imageNamed:@"boxWithFork"]];
    } else [[cell typeImage] setImage:[UIImage imageNamed:@"Box"]];
    
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
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
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
        DDLogError(@"Error loading repositores!");
        NSLog(@"JSON: %@", JSON);
        
        // Change notifier to error
        [notifier setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyX"]]];
        [notifier setTitle:@"Error"];
        // Make it go away
        [notifier hideIn:2.0];
    }];
    
    [operation start];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Mine", @"Starred", @"Watching"]];
    [segmentedControl setSelectedSegmentIndex:selectedIndex];
    [segmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]];
    [segmentedControl setFont:[UIFont fontWithName:@"Avenir" size:20.0f]];
    [segmentedControl setSelectedTextColor:[UIColor blackColor]];
    [segmentedControl setTextColor:[UIColor grayColor]];
    
    [segmentedControl addTarget:self action:@selector(reloadRepositories:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setFrame:CGRectMake(0, 10, 300, 54)];
    
    return segmentedControl;

}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 54)];
//}

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
    // lolololol
    
    NSDictionary *selectedRepo = [[self repositories] objectAtIndex:[indexPath row]];
    NSLog(@"Selected: %@", [selectedRepo objectForKey:@"name"]);
    NSLog(@"\nSelected Details: %@", selectedRepo);
    
    DMRepositoryDetailViewController *viewController = [[DMRepositoryDetailViewController alloc] init];
    [viewController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [viewController setRepo:selectedRepo];
    [self presentViewController:viewController animated:YES completion:nil];
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"RepositoryViewStoryboard_iPhone" bundle:[NSBundle mainBundle]];
//    DMParallaxViewController *viewController = [[DMParallaxViewController alloc] init];
//    [viewController setModalPresentationStyle:UIModalPresentationCurrentContext];
//    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//    viewController = [storyboard instantiateInitialViewController];
//    [viewController setRepo:selectedRepo];
//    [self presentViewController:viewController animated:YES completion:nil];
    
}

@end
