//
//  DMRepositoryFileViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 5/6/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMRepositoryFileViewController.h"
#import "RNBlurModalView.h"
#import "DMCommitMessageView.h"
#import "DerpKit.h"

@interface DMRepositoryFileViewController () <UITextViewDelegate, UIAlertViewDelegate>

@property BOOL keyboardVisible;
@property (nonatomic, strong) UIButton *dismisskeyboard;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy) NSString *httpHeaderTokenString;
@property BOOL success;


- (void)userIsDoneEditing:(id)sender;

@end

@implementation DMRepositoryFileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set up NSNotificationCenter Listening
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postCommit:) name:kCommitMessagePostedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kickoff:) name:@"PostCommit" object:nil];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
    _httpHeaderTokenString = [NSString stringWithFormat:@"%@=%@&%@=%@", kAccessToken, token, kTokenType, tokenType];
    
     NSLog(@"File Contents %@", _fileDictionary);
     
	// Do any additional setup after loading the view.
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(userIsDoneEditing:)]];
    _textView = [[UITextView alloc] init];
    [_textView setText:[self initialText]];
    [_textView setBackgroundColor:[UIColor grayColor]];
    [_textView setFont:[UIFont fontWithName:@"Courier New" size:16.0f]];
    [_textView setTextColor:[UIColor whiteColor]];
    [_textView setFrame:[[self view] bounds]];
    [self setView:_textView];
    
//    _dismisskeyboard = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-54, self.view.frame.size.height-44, 44, 44)];
//    [_dismisskeyboard setTitle:@"V" forState:UIControlStateNormal];
//    [_dismisskeyboard addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
//    [_dismisskeyboard setBackgroundColor:[UIColor colorWithRed:250 green:250 blue:250 alpha:0.7]];
//    [_dismisskeyboard setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [[self view] addSubview:_dismisskeyboard];
//    [_dismisskeyboard setHidden:![self keyboardVisible]];
//    [[self view] addSubview:[self textView]];
    
    UIBarButtonItem *hideKeyboard = [[UIBarButtonItem alloc] initWithTitle:@"toggle keyboard" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleKeyboard)];
    NSMutableArray *rightItems = [NSMutableArray arrayWithArray:[[self navigationItem] rightBarButtonItems]];
    [rightItems addObject:hideKeyboard];
    self.navigationItem.rightBarButtonItems = rightItems;
    
    
    
     NSLog(@"Registering for keyboard events");
     
     // Register for the events
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
     // Setup content size
//     scrollview.contentSize = CGSizeMake(SCROLLVIEW_CONTENT_WIDTH, SCROLLVIEW_CONTENT_HEIGHT);
    
     //Initially the keyboard is hidden
     _keyboardVisible = NO;
     
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// #pragma mark UITextView Delegate

- (void)keyboardDidShow:(NSNotification *)notification {
    NSLog(@"Keyboard did SHOW notification");
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - keyboardSize.height);
    // add button to dismiss keyboard
    NSLog(@"button state %c", _dismisskeyboard.hidden);
    NSLog(@"Buttttttton %@", _dismisskeyboard);
    
}
- (void)keyboardDidHide:(NSNotification *)notification {
    NSLog(@"Keyboard did hide notification");
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + keyboardSize.height);
}

- (void)toggleKeyboard {
    if ([[self textView] isFirstResponder]) // keyboard is visible.
        [[self textView] resignFirstResponder];
    else [[self textView] becomeFirstResponder];
}

- (void)userIsDoneEditing:(id)sender {
    NSLog(@"\n -- Differences Found --\n");
    
    //    NSString *currentSHA = [_fileDictionary objectForKey:@"sha"];
    
    // Create new object, get latest commit, pull SHA from latest commit to use tree SHA and parent SHA.
    // if the files are different, then POST a commit back with the tree and previous commit SHA for references.
    if (![[_textView text] isEqualToString:_initialText]) {
        // text change. lets commit
        NSLog(@"Change occured in text;");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"aGHC-ChangesMadeToFile" object:self];
//        DMCommitMessageView *commitMessageView = [[DMCommitMessageView alloc] init];
//        RNBlurModalView *commitMessageModalView = [[RNBlurModalView alloc] initWithView:commitMessageView];
//        RNBlurModalView *secondaryView = [[RNBlurModalView alloc] initWithTitle:@"Whoa test it" message:@"Super test, Messages and things and what nots"];
//        [commitMessageModalView show];
//        [secondaryView show];
        
        // udpate _fileDictionary with new_content
        NSMutableDictionary *newFileDirectory = [_fileDictionary mutableCopy];
        [newFileDirectory setValue:_textView.text forKey:@"new_content"];
        _fileDictionary = newFileDirectory;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Commit Message"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Post Commit",nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alertView show];
    } else {
        // no text differences.
        NSLog(@"No change in text value");
        [[self navigationController] popViewControllerAnimated:YES];
    }
    
//    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)postCommit:(NSNotification *)notification {
    NSString *commitMessage = [notification object];
    NSDictionary *ownerData = [_fileDictionary objectForKey:@"owner"];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Har har button pressed durr");
    NSLog(@"Button presssed %ld", (long)buttonIndex);
    if (buttonIndex == 1 && ![[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
        NSMutableDictionary *mutableFileDirectionary = [_fileDictionary mutableCopy];
        [mutableFileDirectionary setValue:[[alertView textFieldAtIndex:0] text] forKey:@"commit_message"];
        _fileDictionary = mutableFileDirectionary;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PostCommit" object:mutableFileDirectionary];
//        [self kickoffcommitcreation:mutableFileDirectionary];
        
//        NSString *commitMessage = [[alertView textFieldAtIndex:0] text];
//        BOOL commitPosted = [DMCommitObject withLatestsCommitTreeAndParentHashCommitFile:[_fileDictionary objectForKey:@"path"] withContents:commitMessage toRepo:[_fileDictionary objectForKey:@"repoName"] withOwner:[ownerData objectForKey:@"login"] withCommitMessage:commitMessage];
        
//        if ([commit success]) {
//            NSLog(@"Commit posted successfully");
//            [[self navigationController] popViewControllerAnimated:YES];
//        }
    }
}

- (void)kickoff:(NSNotification *)notification {
    NSLog(@"notification : %@", notification);
    [self kickoffcommitcreation:_fileDictionary];
}

- (void)kickoffcommitcreation:(NSDictionary *)fileDictionary {    
    [self createCommitForFile:fileDictionary];
}
/*****/
#pragma mark HolyCrap
- (void)createCommitForFile:(NSDictionary *)info {
    
    NSLog(@"\n\nInfo : \n%@\n\n", info);
    
//    [self getAllCommitsForRepo:info];
    
    /* Get All Commits */
    NSMutableURLRequest *allCommitDataRequest = [[NSMutableURLRequest alloc] init];
    NSDictionary *ownerData = [info objectForKey:@"owner"];
    NSString *allCommitDataUrlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/commits?%@",
                            kGitHubApiURL, [ownerData objectForKey:@"login"], [info objectForKey:@"repoName"], _httpHeaderTokenString];
    
    [allCommitDataRequest setURL:[NSURL URLWithString:allCommitDataUrlRequest]];
    [allCommitDataRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLResponse *allCommitDataUrlResponse = nil;
    NSError *allCommitDataErr = nil;
    NSData *allCommitData = [NSURLConnection sendSynchronousRequest:allCommitDataRequest returningResponse:&allCommitDataUrlResponse error:&allCommitDataErr];
    NSLog(@"Commits recieved");
    NSLog(@"Data : %@", allCommitData);
    // Parse response Array
    NSArray *commitsJSON = [NSJSONSerialization JSONObjectWithData:allCommitData options:NSJSONReadingAllowFragments error:&allCommitDataErr];
    NSLog(@"commitsJSON %@", commitsJSON);
    NSDictionary *latestCommitDictionary = [commitsJSON objectAtIndex:0];
    NSLog(@"latestCommit : %@", latestCommitDictionary);
    NSString *lastCommitSHA = [latestCommitDictionary objectForKey:@"sha"];
//    NSString *parentOfLastCommitSHA = [[latestCommitDictionary objectForKey:@"parents"] objectForKey:@"sha"];
    NSString *parentTreeSHA = [[[latestCommitDictionary objectForKey:@"commit"] objectForKey:@"tree"] objectForKey:@"sha"];
    
    NSLog(@"Data String: %@", commitsJSON);
    NSLog(@"Last commit SHA : %@", lastCommitSHA);
    NSLog(@"response : %@", allCommitDataUrlResponse);
    NSLog(@"Error : %@", allCommitDataErr);
    
    /* Create New Blob */
    NSMutableURLRequest *createNewBlobRequest = [[NSMutableURLRequest alloc] init];
    NSString *createNewBlobUrlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/blobs?%@",
                                         kGitHubApiURL, [ownerData objectForKey:@"login"], [_fileDictionary objectForKey:@"repoName"], _httpHeaderTokenString];
    
    NSMutableDictionary *newBlobPostInformation = [[NSMutableDictionary alloc] init];
    [newBlobPostInformation setValue:[_fileDictionary objectForKey:@"new_content"] forKey:@"content"];
    [newBlobPostInformation setValue:@"utf-8" forKey:@"encoding"];
    NSData *newBlobPostData = [NSJSONSerialization dataWithJSONObject:newBlobPostInformation options:kNilOptions error:nil];
    
    [createNewBlobRequest setURL:[NSURL URLWithString:createNewBlobUrlRequest]];
    [createNewBlobRequest setHTTPMethod:@"POST"];
    [createNewBlobRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [createNewBlobRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [createNewBlobRequest setValue:[NSString stringWithFormat:@"%d", [newBlobPostData length]] forHTTPHeaderField:@"Content-Length"];
    [createNewBlobRequest setHTTPBody:newBlobPostData];
    
    NSURLResponse *newBlobUrlResponse = nil;
    NSError *newBlobErr = nil;
    NSData *newBlobData = [NSURLConnection sendSynchronousRequest:createNewBlobRequest returningResponse:&newBlobUrlResponse error:&newBlobErr];
    NSLog(@"new blob created");
    // Parse response Dictionary
    NSDictionary *newBlobJSON = [NSJSONSerialization JSONObjectWithData:newBlobData options:NSJSONReadingAllowFragments error:&newBlobErr];
    NSString *newBlobSHA = [newBlobJSON objectForKey:@"sha"];
    
    /* Create New Tree */
    NSMutableURLRequest *createNewTreeRequest = [[NSMutableURLRequest alloc] init];
    NSString *createNewTreeUrlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/trees?%@",
                                         kGitHubApiURL, [ownerData objectForKey:@"login"], [_fileDictionary objectForKey:@"repoName"], _httpHeaderTokenString];
    // because look at that selection, fuck that. Get it as a string.
    
    NSMutableDictionary *newTreePostInformation = [[NSMutableDictionary alloc] init];
    [newTreePostInformation setValue:parentTreeSHA forKey:@"base_tree"];
    [newTreePostInformation setValue:[NSArray arrayWithObjects:
                                      [NSDictionary dictionaryWithObjectsAndKeys:[_fileDictionary objectForKey:@"path"], @"path", @"100644", @"mode", @"blob", @"type", newBlobSHA, @"sha", nil], nil]
                              forKey:@"tree"];
    
    NSLog(@"tree post info %@", newTreePostInformation);
    
    NSData *newTreePostData = [NSJSONSerialization dataWithJSONObject:newTreePostInformation options:kNilOptions error:nil];
    
    [createNewTreeRequest setURL:[NSURL URLWithString:createNewTreeUrlRequest]];
    [createNewTreeRequest setHTTPMethod:@"POST"];
    [createNewTreeRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [createNewTreeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [createNewTreeRequest setValue:[NSString stringWithFormat:@"%d", [newTreePostData length]] forHTTPHeaderField:@"Content-Length"];
    [createNewTreeRequest setHTTPBody:newTreePostData];
    
    NSURLResponse *newTreeUrlResponse = nil;
    NSError *newTreeErr = nil;
    NSData *newTreeData = [NSURLConnection sendSynchronousRequest:createNewTreeRequest returningResponse:&newTreeUrlResponse error:&newTreeErr];
    // Parse response Dictionary
    NSDictionary *newTreeJSON = [NSJSONSerialization JSONObjectWithData:newTreeData options:NSJSONReadingAllowFragments error:&newTreeErr];
    NSLog(@"new tree JSON : %@", newTreeJSON);
    NSString *newTreeSHA = [newTreeJSON objectForKey:@"sha"];
    NSLog(@"Tree data : %@", [newTreeJSON objectForKey:@"tree"]);

    /* Create New Commit */
    NSMutableURLRequest *newCommitRequest = [[NSMutableURLRequest alloc] init];
    NSString *createNewCommitUrlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/commits?%@",
                                           kGitHubApiURL, [ownerData objectForKey:@"login"], [_fileDictionary objectForKey:@"repoName"], _httpHeaderTokenString];
    
    NSMutableDictionary *newCommitPostInformation = [[NSMutableDictionary alloc] init];
    [newCommitPostInformation setValue:[_fileDictionary objectForKey:@"commit_message"] forKey:@"message"];
    [newCommitPostInformation setValue:newTreeSHA forKey:@"tree"];
    [newCommitPostInformation setValue:[NSArray arrayWithObjects:lastCommitSHA, nil] forKey:@"parents"];
    // convert dictionary to data
    NSData *newCommitPostData = [NSJSONSerialization dataWithJSONObject:newCommitPostInformation options:kNilOptions error:nil];
    
    [newCommitRequest setURL:[NSURL URLWithString:createNewCommitUrlRequest]];
    [newCommitRequest setHTTPMethod:@"POST"];
    [newCommitRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [newCommitRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [newCommitRequest setValue:[NSString stringWithFormat:@"%d", [newCommitPostData length]] forHTTPHeaderField:@"Content-Length"];
    [newCommitRequest setHTTPBody:newCommitPostData];

    NSURLResponse *newCommitUrlResponse = nil;
    NSError *newCommitErr = nil;
    NSData *newCommitData = [NSURLConnection sendSynchronousRequest:newCommitRequest returningResponse:&newCommitUrlResponse error:&newCommitErr];
    // Parse response Dictionary
    NSDictionary *newCommitJSON = [NSJSONSerialization JSONObjectWithData:newCommitData options:NSJSONReadingAllowFragments error:&newCommitErr];
    NSString *newCommitSHA = [newCommitJSON objectForKey:@"sha"];
    
    /* Update Ref */
    NSMutableURLRequest *updateRefRequest = [[NSMutableURLRequest alloc] init];
    // get current file branch
    NSString *fullurl = [_fileDictionary objectForKey:@"url"];
    NSRange range = [fullurl rangeOfString:@"?ref=" options:NSBackwardsSearch];
    NSString *branch = [fullurl substringFromIndex:range.location + 5]; // offset '?ref=' value and just get branch name
    NSString *ref = [NSString stringWithFormat:@"refs/heads/%@", branch];
    
    NSString *updateRefUrlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/%@?%@", kGitHubApiURL, [ownerData valueForKey:@"login"], [_fileDictionary valueForKey:@"repoName"], ref, _httpHeaderTokenString];
    
    NSMutableDictionary *updateRefPostInformation = [[NSMutableDictionary alloc] init];
    [updateRefPostInformation setValue:newCommitSHA forKey:@"sha"];
    [updateRefPostInformation setValue:@"false" forKey:@"force"];
    
    NSData *updateRefPostData = [NSJSONSerialization dataWithJSONObject:updateRefPostInformation options:kNilOptions error:nil];
    
    [updateRefRequest setURL:[NSURL URLWithString:updateRefUrlRequest]];
    [updateRefRequest setHTTPMethod:@"PATCH"];
    [updateRefRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [updateRefRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [updateRefRequest setValue:[NSString stringWithFormat:@"%d", [updateRefPostData length]] forHTTPHeaderField:@"Content-Length"];
    [updateRefRequest setHTTPBody:updateRefPostData];

    
    NSURLResponse *updateRefUrlResponse = nil;
    NSError *updateRefErr = nil;
    NSData *updateRefData = [NSURLConnection sendSynchronousRequest:updateRefRequest returningResponse:&updateRefUrlResponse error:&updateRefErr];
    
    NSDictionary *updateRefJSON = [NSJSONSerialization JSONObjectWithData:updateRefData options:NSJSONReadingAllowFragments error:&updateRefErr];
    NSLog(@"Update Ref JSON : %@", updateRefJSON);
}


- (void)getAllCommitsForRepo:(NSDictionary *)repo {
    NSLog(@"Getting Commits");
    NSMutableDictionary *jsonInformation = [NSMutableDictionary dictionaryWithDictionary:repo];
    NSMutableURLRequest *request;
    NSDictionary *ownerData = [repo objectForKey:@"owner"];
    NSString *urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/commits?%@",
                            kGitHubApiURL, [ownerData objectForKey:@"login"], [repo objectForKey:@"repoName"], _httpHeaderTokenString];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [jsonInformation setValue:[JSON objectAtIndex:0] forKey:@"latest_commit"];
        NSLog(@"Commits recieved %@", JSON);
        [self createBlobForFile:jsonInformation];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        _error = error;
        NSLog(@"Recieve commits failed %@", error);
    }];
    [operation start];
    NSLog(@"Starting Operation");
}

- (void)createBlobForFile:(NSDictionary *)fileDictionary {
    NSLog(@"Creating Blob");
    NSMutableDictionary *jsonInformation = [NSMutableDictionary dictionaryWithDictionary:fileDictionary];
    NSMutableURLRequest *request;
    NSDictionary *ownerData = [fileDictionary objectForKey:@"owner"];
    NSString *urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/blobs?%@",
                            kGitHubApiURL, [ownerData objectForKey:@"login"], [fileDictionary objectForKey:@"repoName"], _httpHeaderTokenString];
    
    NSMutableDictionary *postInformation;
    [postInformation setValue:[fileDictionary objectForKey:@"newfilecontent"] forKey:@"content"];
    [postInformation setValue:@"utf-8" forKey:@"encoding"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:postInformation] options:0 error:nil]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [jsonInformation setValue:[JSON objectForKey:@"sha"] forKey:@"new_blob"];
        NSLog(@"Created Blob: %@", JSON);
        [self createTreeWithInfo:jsonInformation];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        _error = error;
        NSLog(@"Error creating blob %@", error);
    }];
    [operation start];
}

- (void)createTreeWithInfo:(NSDictionary *)info {
    NSLog(@"Creating tree");
    NSMutableDictionary *jsonInformation = [NSMutableDictionary dictionaryWithDictionary:info];
    NSMutableURLRequest *request;
    NSDictionary *ownerData = [info objectForKey:@"owner"];
    NSString *urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/trees?%@",
                            kGitHubApiURL, [ownerData objectForKey:@"login"], [info objectForKey:@"repoName"], _httpHeaderTokenString];
    // because look at that selection, fuck that. Get it as a string.
    NSString *treeSHAForLatestCommit = [[[info objectForKey:@"lastest_commit"] objectForKey:@"tree"] objectForKey:@"sha"];
    
    NSMutableDictionary *postInformation;
    [postInformation setValue:treeSHAForLatestCommit forKey:@"base_tree"];
    [postInformation setValue:[NSDictionary dictionaryWithObjectsAndKeys:[info objectForKey:@"path"], @"path", @"100644", @"mode",@"blob", @"type", [info objectForKey:@"new_blob"], @"blob", nil] forKey:@"tree"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:postInformation] options:0 error:nil]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [jsonInformation setValue:JSON forKey:@"new_tree"];
        NSLog(@"Tree Created %@", JSON);
        [self createTreeWithInfo:jsonInformation];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        _error = error;
        NSLog(@"Failed creating tree %@", error);
    }];
    [operation start];
}

- (void)createCommitWithInfo:(NSDictionary *)info {
    NSLog(@"Creating Commit");
    NSMutableDictionary *jsonInformation = [NSMutableDictionary dictionaryWithDictionary:info];
    NSMutableURLRequest *request;
    NSDictionary *ownerData = [info objectForKey:@"owner"];
    NSString *urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/commits?%@",
                            kGitHubApiURL, [ownerData objectForKey:@"login"], [info objectForKey:@"repoName"], _httpHeaderTokenString];
    NSMutableDictionary *postInformation;
    [postInformation setValue:[info objectForKey:@"commit_message"] forKey:@"message"];
    [postInformation setValue:[[info objectForKey:@"new_tree"] objectForKey:@"sha"] forKey:@"tree"];
    [postInformation setValue:[NSArray arrayWithObjects:[[info objectForKey:@"last_commit"] objectForKey:@"sha"], nil] forKey:@"parents"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:postInformation] options:0 error:nil]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [jsonInformation setValue:JSON forKey:@"new_commit"];
        NSLog(@"Commit created %@", JSON);
        [self updateReferenceWithInfo:jsonInformation];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        _error = error;
        NSLog(@"Error creating commit %@", error);
    }];
    [operation start];
}

- (void)updateReferenceWithInfo:(NSDictionary *)info {
    NSLog(@"Updating reference");
    NSMutableDictionary *jsonInformation = [NSMutableDictionary dictionaryWithDictionary:info];
    NSMutableURLRequest *request;
    NSDictionary *ownerData = [info objectForKey:@"owner"];
    
    NSString *fullurl = [info objectForKey:@"url"];
    NSRange range = [fullurl rangeOfString:@"?ref=" options:NSBackwardsSearch];
    NSString *branch = [fullurl substringFromIndex:range.location + 5]; // offset '?ref=' value and just get branch name
    NSString *ref = [NSString stringWithFormat:@"/refs/heads/%@", branch];
    
    NSString *urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/%@?%@", kGitHubApiURL, [ownerData valueForKey:@"login"], [info valueForKey:@"repoName"], ref, _httpHeaderTokenString];
    
    NSMutableDictionary *postInformation;
    [postInformation setValue:[[info objectForKey:@"new_commit"] valueForKey:@"sha"] forKey:@"sha"];
    [postInformation setValue:@"false" forKey:@"force"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"PATCH"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:postInformation] options:0 error:nil]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [jsonInformation setValue:JSON forKey:@"updated_ref"];
        NSLog(@"Reference Updated %@", JSON);
        _success = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        _error = error;
        NSLog(@"Error updated ref %@", error);
        _success = NO;
    }];
    [operation start];
    /* TODO : this.
     // Update refs
     //    PATCH /repos/:owner/:repo/git/refs/:ref
     NSString *ref = @"refs/heads/master";
     urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/%@?%@", kGitHubApiURL, owner, repo, ref, httpHeaderTokenString]; // master branch, for now.
     
     JSONObjectToPass = nil;
     [JSONObjectToPass setValue:[createdCommit objectForKey:@"sha"] forKey:@"sha"];
     [JSONObjectToPass setValue:@"false" forKey:@"force"];
     
     [request setURL:[NSURL URLWithString:urlRequest]];
     [request setHTTPMethod:@"POST"];
     [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:JSONObjectToPass] options:0 error:nil]];
     
     AFJSONRequestOperation *referenceUpdateOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
     referenceUpdate = JSON;
     NSLog(@"Reference successfully updated %@", JSON);
     success = YES;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
     error = error;
     NSLog(@"Reference update failed %@", JSON);
     success = NO;
     }];
     
     //    [referenceUpdateOperation addDependency:createCommitOperation];
     [referenceUpdateOperation start];*/
}


/*****/
@end
