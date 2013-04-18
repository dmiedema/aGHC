//
//  DMSearchResultsViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMSearchResultsViewController.h"
#import "DMRepositoryTableViewCell.h"
#import "JSNotifier.h"

@interface DMSearchResultsViewController ()

@end

@implementation DMSearchResultsViewController

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
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissMe:)];
    self.navigationItem.leftBarButtonItem = homeButton;

}

- (IBAction)runSearch:(id)sender {
    NSString *searchString = [[self searchField] text];
    
    
    JSNotifier *notifier = [[JSNotifier alloc] initWithTitle:@"Loading..."];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    [notifier setAccessoryView: activityIndicator];
    [notifier show];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@ /legacy/repos/search/%@", kGitHubApiURL, searchString]]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *reponse, id JSON){
        NSLog(@"JSON: %@", JSON);
//        NSLog(@"Repositories count: %i",[[self repositories] count]);
        
//        [self setRepositories:JSON];
        // Reload the table
//        [[self tableView] reloadData];
        
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

@end
