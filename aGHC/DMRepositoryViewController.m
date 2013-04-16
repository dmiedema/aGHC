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

@interface DMRepositoryViewController ()

@property (nonatomic, strong) NSMutableArray *repositories;

//- (void)reloadRepositories;
- (IBAction)reloadRepositories:(id)sender;

@end

@implementation DMRepositoryViewController

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
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissMe:)];
 
    self.navigationItem.leftBarButtonItem = homeButton;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Mine", @"Starred", @"Watching"]];
    [segmentedControl setSelectedSegmentIndex:0];
//    [segmentedControl setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]];
    [segmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]];
    [segmentedControl setFont:[UIFont fontWithName:@"Avenir" size:20.0f]];
    [segmentedControl setSelectedTextColor:[UIColor blackColor]];
    [segmentedControl setTextColor:[UIColor grayColor]];
    
    [segmentedControl addTarget:self action:@selector(reloadRepositories:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setFrame:CGRectMake(0, 10, 300, 54)];
    [[self view] addSubview:segmentedControl];
    
    
    [[self tableView] registerNib:[UINib nibWithNibName:@"RepositoryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Repository Cell"];
    
    [self reloadRepositories:segmentedControl];
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
    DMRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *currentRepo = [[self repositories] objectAtIndex:[indexPath row]];
    cell.repositoryName.text = [currentRepo objectForKey:@"name"];
    cell.repositoryDetailInfo.text = [NSString stringWithFormat:@"Forks: %@ - Issues: %@ - Watchers: %@",
                                      [currentRepo objectForKey:@"forks_count"],
                                      [currentRepo objectForKey:@"open_issues_count"],
                                      [currentRepo objectForKey:@"watchers"]];
    
    return cell;
}

- (void)dismissMe:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadRepositories:(id)sender {
    NSLog(@"Reload, selected index: %i", [sender selectedSegmentIndex]);
    
    
    //@"https://github.com/user/repos?access_token=&token_type=bearer";
    
    NSString *username     = [[NSUserDefaults standardUserDefaults] stringForKey:kUsername];
    NSString *access_token = [[NSUserDefaults standardUserDefaults] stringForKey:kAccessToken];
    NSString *token_type   = [[NSUserDefaults standardUserDefaults] stringForKey:kTokenType];
    NSMutableURLRequest *request;
    
    if ([sender selectedSegmentIndex] == 0) {
         request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@user/repos?access_token=%@&token_type=%@", kGitHubApiURL, access_token, token_type]]];
    } else if ([sender selectedSegmentIndex] == 1) {
        // starred
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@/starred", kGitHubApiURL, username]]];
    } else { // watching
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@/subscriptions", kGitHubApiURL, username]]];

    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *reponse, id JSON){
        NSLog(@"JSON: %@", JSON);
        [self setRepositories:JSON];
        //        for (NSDictionary *jsonDictionary in JSON) {
        //            [[self repositories] addObject:jsonDictionary];
        //        }
        NSLog(@"Repositories count: %i",[[self repositories] count]);
        [[self tableView] reloadData];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
        NSLog(@"JSON: %@", JSON);
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
