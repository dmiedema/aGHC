//
//  DMRepositoryCommitsTableViewController.h
//  aGHC
//
//  Created by Daniel Miedema on 5/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMRepositoryCommitsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *commits;

/* Not needed */
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *repoName;

@end
