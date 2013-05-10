//
//  DMRepositoryDetailTableViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/19/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMRepositoryDetailTableViewController.h"
#import "DMRepositoryDetailTableViewCell.h"
#import "DMRepositoryFileViewController.h"
//#import "MBProgressHUD.h"
#import "JSNotifier.h"
#import <QuickLook/QuickLook.h>
#import "MF_Base64Additions.h"

@interface DMRepositoryDetailTableViewController () <QLPreviewControllerDataSource>

@property (nonatomic, strong) NSURL *urlOfFile;
@property (nonatomic, strong) NSData *itemToLoad;

- (void)loadFile:(NSDictionary *)contentsToLoad;

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
    NSString *selectedType = [[[self directoryContents] objectAtIndex:[indexPath row]] valueForKey:@"type"];
    
    NSString *url = [selected objectForKey:@"url"];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
    NSLog(@"url : %@", url);
    // GET /repos/:owner/:repo/contents/:path

    NSString *requestURL;
    if (token && tokenType) {
        requestURL = [NSString stringWithFormat:@"%@&%@=%@&%@=%@", url, kAccessToken, token, kTokenType, tokenType];
    } else {
        requestURL = url; }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    
    NSLog(@"Request URL %@", [request URL]);
    // its a folder
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
        [notifier setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyX"]]];
        [notifier setTitle:@"Error" animated:YES];
        [notifier hideIn:1.0];
    }];
    // Its a file
    AFJSONRequestOperation *fileOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self loadFile:JSON];
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityIndicator stopAnimating];
            [notifier setTitle:@"Complete" animated:YES];
            [notifier setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyCheck"]]];
            [notifier hideIn:1.0];
        });
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
        [notifier setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyX"]]];
        [notifier setTitle:@"Error" animated:YES];
        [notifier hideIn:1.0];
    }];

    /*@property (nonatomic, strong) NSArray  *directoryContents;
     @property (nonatomic, strong) NSString *currentPath;
     
     @property (nonatomic, strong) NSString *owner;
     @property (nonatomic, strong) NSString *reponame;*/
    
    NSLog(@"%@", [[self directoryContents] objectAtIndex:[indexPath row]]);

    // Directory?
    if ([selectedType isEqualToString:@"dir"]) {
        [subView setTitle:path];
        [subView setOwner:[self owner]];
        [subView setReponame:[self reponame]];
        [folderOperation start];
    }
    // File?
    else if ([selectedType isEqualToString:@"file"]) {
        // This is all that's needed actually, it does the magic of loading files.
        [fileOperation start];
    }
    // Invalid - ESSPLODE-O
    else {
    } 
}


#pragma mark - QuicklookPreviewControllerDataSource Methods

- (NSInteger) numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    // ~this is a bad idea.~
    // Create an NSAray with the contents of urlOfDropboxFile and just return the count.
    return [[NSArray arrayWithContentsOfURL:_urlOfFile] count];
}
- (id<QLPreviewItem>) previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return _urlOfFile;
}

# pragma mark loadFile

-(void)loadFile:(NSDictionary *)contentsToLoad {
    NSLog(@"File : %@", [contentsToLoad objectForKey:@"name"]);
    NSLog(@"Selected File:  %@", contentsToLoad);
    
    // get the file extension
    NSString *fileName = [contentsToLoad objectForKey:@"name"];
    NSRange range = [fileName rangeOfString:@"." options:NSBackwardsSearch];
    NSString *extension = [fileName substringFromIndex:range.location];
    NSLog(@"Range: %i", range.location);
    NSLog(@"Extension : %@", extension);
    
    // get item from url
    NSData *itemToLoad = [NSData dataWithBase64String:[contentsToLoad objectForKey:@"content"]];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    [path stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
    NSLog(@"Path : %@", path);
    NSURL *urlToLoad = [NSURL fileURLWithPath:path];  //:[NSString stringWithFormat:@"file://%@", path]];
    NSError *error = nil;
    
    NSLog(@"urlToLoad : %@", [urlToLoad absoluteString]);
    
    BOOL success = [itemToLoad writeToURL:urlToLoad options:NSAtomicWrite error:&error];
    if (success) {
        _urlOfFile = urlToLoad;
        NSLog(@"SUCCESS :)");
    } else {
        NSLog(@"ERROR :( -- : %@", error);
    }
    // array of image extensions.
    NSArray *imageExtensions = [NSArray arrayWithObjects:@".png", @".jpg", @".jpeg", @".bmp", nil];
    
    // you an image?
    if ([imageExtensions containsObject:extension]) {
        NSLog(@"url of fuel %@", _urlOfFile);
        
        QLPreviewController *quickLook = [[QLPreviewController alloc] init];
        [quickLook setDataSource:self];
        [quickLook setModalPresentationStyle:UIModalPresentationPageSheet];
        [quickLook setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [[self navigationController] pushViewController:quickLook animated:YES];
    }
    // Nope, must be code
    else {
        NSLog(@"Not an image, big surprise");
        NSString *decodedString = [NSString stringFromBase64String:[contentsToLoad objectForKey:@"content"]];
        NSLog(@"Striiing : %@", decodedString);
        NSLog(@"Base64 Striiiing: %@", [contentsToLoad objectForKey:@"content"]);
                
        DMRepositoryFileViewController *fileViewController = [[DMRepositoryFileViewController alloc] init];
        [fileViewController setInitialText:decodedString];
        NSMutableDictionary *fileDictionary = [NSMutableDictionary dictionaryWithDictionary:contentsToLoad];
        [fileDictionary setValue:_reponame forKeyPath:@"repoName"];
        [fileDictionary setValue:_owner forKeyPath:@"owner"];
        [fileViewController setFileDictionary:fileDictionary];
        [[self navigationController] pushViewController:fileViewController animated:YES];
        
    }

}

@end
