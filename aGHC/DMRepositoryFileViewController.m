//
//  DMRepositoryFileViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 5/6/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMRepositoryFileViewController.h"


@interface DMRepositoryFileViewController () <UITextViewDelegate>

@property BOOL keyboardVisible;

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
	// Do any additional setup after loading the view.
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(userIsDoneEditing:)]];
    _textView = [[UITextView alloc] init];
    [_textView setText:[self initialText]];
    [_textView setBackgroundColor:[UIColor grayColor]];
    [_textView setFont:[UIFont fontWithName:@"Courier New" size:16.0f]];
    [_textView setTextColor:[UIColor whiteColor]];
    [_textView setFrame:[[self view] bounds]];
    [self setView:_textView];
//    [[self view] addSubview:[self textView]];
    
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
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - keyboardSize.height);
}
- (void)keyboardDidHide:(NSNotification *)notification {
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
                                                 
- (void)userIsDoneEditing:(id)sender {
    NSLog(@"Differences --");
    if (![[_textView text] isEqualToString:_initialText]) {
        // text change. lets commit
        NSLog(@"Change occured in text;");
    } else {
        // no text differences.
        NSLog(@"No change in text value");
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Completion block, dismissing DMRepositoryFileViewController");
        
    }];
}




/*

 
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:_textView];
- (void)textViewTextDidChange:(id)sender;
- (void)textViewTextDidChange:(id)sender{}
 */

@end
