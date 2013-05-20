//
//  DMSettingsTableViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/10/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMSettingsTableViewController.h"
#import "DMAccountViewController.h"
#import "DMLicensingViewController.h"
#import "DMAboutViewController.h"
#import <MessageUI/MessageUI.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>

@interface DMSettingsTableViewController () <MFMailComposeViewControllerDelegate>
#define SETTINGS_OPTIONS_ARRAY @[@"About", @"Account", @"Acknowledgements", @"Follow on Twitter", @"Contact Support", @"Done"]

- (void)deleteCookies;
@end

@implementation DMSettingsTableViewController

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
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    // ditch them cookies
    [self deleteCookies];
    
}

-(void)deleteCookies {    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

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
    return [SETTINGS_OPTIONS_ARRAY count];
}


#define SETTINGS_LABEL_CELL_FRAME_X   20
#define SETTINGS_LABEL_CELL_FRAME_Y   0
#define SETTINGS_LABEL_CELL_WIDTH     280
#define SETTINGS_LABEL_CELL_HEIGHT    64
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *label = [[UILabel alloc] init];
    
    [label setFont:[UIFont fontWithName:kFontName size:24.0]];
    [label setText:[NSString stringWithFormat:@"%@", [SETTINGS_OPTIONS_ARRAY objectAtIndex:[indexPath row]]]];
    
    [label setFrame:CGRectMake(SETTINGS_LABEL_CELL_FRAME_X, SETTINGS_LABEL_CELL_FRAME_Y, SETTINGS_LABEL_CELL_WIDTH, SETTINGS_LABEL_CELL_HEIGHT)];
    
    [[cell contentView] addSubview:label];
    
    return cell;
}
/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 ) {
        UIImage *image = [UIImage imageNamed:@"sL7cyZ5Oa7-2-1.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        return imageView;
    }
//    UIView *view = [[UIView alloc] init];
//    [view addSubview:imageView];
//    return view;
    return nil;
}
 */

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
    NSLog(@"Item Selected: %@", [SETTINGS_OPTIONS_ARRAY objectAtIndex:[indexPath row]]);
    
    NSString *selected = [SETTINGS_OPTIONS_ARRAY objectAtIndex:[indexPath row]];
    
    // about
    // licensing
    // follow on twitter
    // contact support
    // done
    
    switch ([indexPath row]) {
        case 0: { // about
            NSLog(@"index 0");
        }
        break;
        
        case 1: { // account
            NSLog(@"index 1");
            UIViewController *viewController = [[UIViewController alloc] init];
            [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
            [viewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            viewController = [[DMAccountViewController alloc] init];
            [self presentViewController:viewController animated:YES completion:nil];
        }
        break;
        
        case 2: {// acknowledgements
            NSLog(@"index 2");
            DMLicensingViewController *acknowledgeView = [[DMLicensingViewController alloc] init];
            [acknowledgeView setModalPresentationStyle:UIModalPresentationCurrentContext];
            [acknowledgeView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [self presentViewController:acknowledgeView animated:YES completion:nil];
        }
        break;
        
        case 3: {// follow on twitter
            NSLog(@"index 3");
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                    
                    if ([accountsArray count] > 0) {
                        ACAccount *account = [accountsArray objectAtIndex:0];
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                        [dict setValue:@"somewhores" forKey:@"screen_name"];
                        [dict setValue:@"true" forKey:@"follow"];
                        
                        SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"] parameters:dict];
                        [postRequest setAccount:account];
                        [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                            NSLog(@"\n --- Request Handler ---\n Response: %@\nurlResponse: %ld\nError: %ld\n",
                                  responseData, (long)[urlResponse statusCode], (long)error.code);
                        }]; // end postRequest completion block.  
                    } // end if theres an account
                } // end if granted
            }]; // end completion block
        }
        break;
        
        case 4: {// contact support
            NSLog(@"index 4");
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                [mailer setMailComposeDelegate:self];
                NSArray *recipients = [NSArray arrayWithObjects:@"daniel@danielmiedema.com", nil];
                [mailer setToRecipients:recipients];
                [mailer setSubject:@"aGHC - Question/Bug Report/Feedback"];
//                [mailer setMessageBody:@"I have a question/bug to report" isHTML:NO];
                [self presentViewController:mailer animated:YES completion:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Looks like you can't send an email this way." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }
        break;
        
        case 5: {// done
            NSLog(@"index 5");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DMSettingViewControllerDismissSettings" object:self];
        }
            break;
        
        default: // le nope
            NSLog(@"unknown option");
            break;
    }
}


#pragma mark MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved for later");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
