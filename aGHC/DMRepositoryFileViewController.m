//
//  DMRepositoryFileViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/28/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMRepositoryFileViewController.h"
#import "DMTextEditor.h"

@interface DMRepositoryFileViewController ()

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
    DMTextEditor *textEditor = [[DMTextEditor alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [textEditor setTextContent:[self fileContents]];
    [self setView:textEditor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
