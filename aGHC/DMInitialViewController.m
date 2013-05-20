//
//  DMInitialViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/10/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMInitialViewController.h"

@interface DMInitialViewController ()

@end

@implementation DMInitialViewController

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
    UIStoryboard *storyboard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {}
    
    storyboard = [UIStoryboard storyboardWithName:@"InitialStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    
    [self setTopViewController:[storyboard instantiateViewControllerWithIdentifier:@"Home Screen"]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
