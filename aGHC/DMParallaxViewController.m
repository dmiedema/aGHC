//
//  DMParallaxViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/19/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMParallaxViewController.h"
#import "DMParallaxedViewController.h"
#import "DMRepositoryDetailTableViewController.h"

@interface DMParallaxViewController ()

@end

@implementation DMParallaxViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)awakeFromNib {
    DMParallaxedViewController *parallaxedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Parallaxed ViewController"];
    DMRepositoryDetailTableViewController *repositoryDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Repository Detail TableViewController"];
    
    [repositoryDetailViewController setRepo:[self repo]];
    
    [self setupWithViewController:parallaxedViewController height:100 tableViewController:repositoryDetailViewController];
    
    [self setDelegate:parallaxedViewController];
}

@end
