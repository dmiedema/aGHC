//
//  DMParallaxedViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/19/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMParallaxedViewController.h"

@interface DMParallaxedViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;

- (IBAction)loadUser:(id)sender;

@end

@implementation DMParallaxedViewController

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
    [[self imageView] setUserInteractionEnabled:YES];
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadUser:)];
    [tapGestureRecognizer setDelegate:self];
    [[self imageView] addGestureRecognizer:tapGestureRecognizer];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUser:(id)sender {
    NSLog(@"Image tapped");
}

#pragma mark - Parallax Controller Delegate

- (void)parallaxController:(M6ParallaxController *)parallaxController willChangeHeightOfViewController:(UIViewController *)viewController fromHeight:(CGFloat)oldHeight toHeight:(CGFloat)newHeight {
    
    if (newHeight >= parallaxController.parallaxedViewControllerStandartHeight) {
        [[self imageView] setAlpha:1.0];
        [[self usernameLabel] setAlpha:1.0];
    } else {
        float alpha = newHeight /parallaxController.parallaxedViewControllerStandartHeight;
        [[self imageView] setAlpha:alpha];
        [[self usernameLabel] setAlpha:alpha];
    }
}

@end
