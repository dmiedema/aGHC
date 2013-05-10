//
//  DMRepositoryFileViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 5/6/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMRepositoryFileViewController.h"
#import "DMCommitObject.h"
#import "RNBlurModalView.h"


@interface DMRepositoryFileViewController () <UITextViewDelegate>

@property BOOL keyboardVisible;
@property (nonatomic, strong) UIButton *dismisskeyboard;


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
    } else {
        // no text differences.
        NSLog(@"No change in text value");
    }
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)postCommit:(NSNotification *)notification {
    NSString *commitMessage = [notification object];
    NSDictionary *ownerData = [_fileDictionary objectForKey:@"owner"];
    BOOL commitPosted = [DMCommitObject withLatestsCommitTreeAndParentHashCommitFile:[_textView text] toRepo:[_fileDictionary objectForKey:@"repoName"] withOwner:[ownerData objectForKey:@"login"] withCommitMessage:commitMessage];
    if (commitPosted) {
        NSLog(@"Commit posted sucessfully.");
    }
}

@end
