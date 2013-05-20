//
//  DMHomeScreenViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/10/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMHomeScreenViewController.h"
#import "ECSlidingViewController.h"
#import "DMSettingsTableViewController.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface DMHomeScreenViewController ()

@property (nonatomic, strong) IBOutlet UINavigationItem *navbar;

@end

@implementation DMHomeScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius  = 10.0f;
    self.view.layer.shadowColor   = [UIColor blackColor].CGColor;
    
    if(![self.slidingViewController.underLeftViewController isKindOfClass:[DMSettingsTableViewController class]])
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissSettings:) name:@"DMSettingViewControllerDismissSettings" object:nil];
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

-(IBAction)revealSettings:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(IBAction)dismissSettings:(id)sender {
    [self.slidingViewController resetTopView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    [[_navbar leftBarButtonItem] setImage:[factory createImageForIcon:NIKFontAwesomeIconCog]];
    [[_navbar leftBarButtonItem] setTitle:@""];
//    UIBarButtonItem *leftItem = [UIBarButtonItem new];
//    leftItem.image = [factory createImageForIcon:NIKFontAwesomeIconCog];
//    leftItem.action = @selector(revealSettings:);
//    leftItem.target = self;
//    leftItem.enabled = YES;
//    leftItem.style = UIBarButtonItemStyleBordered;
//    [[self navigationItem] setLeftBarButtonItem:leftItem];

    NSLog(@"viewDidLoad HomeScreenVieController");
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
