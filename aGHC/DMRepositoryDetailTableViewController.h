//
//  DMRepositoryDetailTableViewController.h
//  aGHC
//
//  Created by Daniel Miedema on 4/19/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMRepositoryDetailTableViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *repo;

// @property (nonatomic, strong) IBOutlet UILabel *repositoryName;

// labels
@property (nonatomic, strong) IBOutlet UILabel *username;
@property (nonatomic, strong) IBOutlet UILabel *description;
@property (nonatomic, strong) IBOutlet UILabel *forks;
@property (nonatomic, strong) IBOutlet UILabel *stargazers;
@property (nonatomic, strong) IBOutlet UILabel *openIssues;
@property (nonatomic, strong) IBOutlet UILabel *downloads;
@property (nonatomic, strong) IBOutlet UILabel *size;
@property (nonatomic, strong) IBOutlet UILabel *exploreCode;

@property (nonatomic, strong) IBOutlet UIButton *forkButton;
@property (nonatomic, strong) IBOutlet UIButton *watchButton;
@property (nonatomic, strong) IBOutlet UIButton *starButton;

@end
