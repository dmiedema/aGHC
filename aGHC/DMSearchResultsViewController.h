//
//  DMSearchResultsViewController.h
//  aGHC
//
//  Created by Daniel Miedema on 4/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMSearchResultsViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UITextField *searchField;

- (IBAction)runSearch:(id)sender;

@end
