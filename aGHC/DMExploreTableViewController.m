//
//  DMExploreTableViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMExploreTableViewController.h"
#import "DMRepositoryTableViewCell.h"
#import "JSNotifier.h"
#import "DMRepositoryDetailViewController.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface DMExploreTableViewController ()

@property (nonatomic, strong) NSMutableArray *repositories;

- (IBAction)dismissMe:(id)sender;

@end

@implementation DMExploreTableViewController

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
    
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    
    UIBarButtonItem *homeButton = [UIBarButtonItem new];
    [homeButton setImage:[factory createImageForIcon:NIKFontAwesomeIconHome]];
    [homeButton setAction:@selector(dismissMe:)];
    [homeButton setTarget:self];
    [homeButton setEnabled:YES];
    [homeButton setStyle:UIBarButtonItemStyleBordered];
    
    [[self navigationItem] setLeftBarButtonItem:homeButton];
    
    [[self tableView] registerNib:[UINib nibWithNibName:@"RepositoryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Repository Cell"];
    
    JSNotifier *notifier = [[JSNotifier alloc] initWithTitle:@"Loading..."];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    [notifier setAccessoryView: activityIndicator];
    [notifier show];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@repositories", kGitHubApiURL]]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissMe:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    
    // repo private?
    if ([[currentRepo objectForKey:@"private"] integerValue] == 1) {
        [[cell privateRepo] setImage:[UIImage imageNamed:@"lock"]];
    } else [[cell privateRepo] setImage:nil];
    // repo fork?
    if ([[currentRepo objectForKey:@"fork"] integerValue] == 1) {
        [[cell typeImage] setImage:[UIImage imageNamed:@"boxWithFork"]];
    } else [[cell typeImage] setImage:[UIImage imageNamed:@"Box"]];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSDictionary *selectedRepo = [[self repositories] objectAtIndex:[indexPath row]];
    
    DMRepositoryDetailViewController *viewController = [[DMRepositoryDetailViewController alloc] init];
    [viewController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [viewController setOwnerName:[selectedRepo objectForKey:@"owner"]];
    [viewController setRepoName:[selectedRepo objectForKey:@"name"]];
    
    [[self navigationController] pushViewController:viewController animated:YES];
}

@end
