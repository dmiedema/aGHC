//
//  DMRepositoryDetailTableViewController.h
//  aGHC
//
//  Created by Daniel Miedema on 4/19/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMRepositoryDetailTableViewController : UITableViewController

@property (nonatomic, strong) NSArray  *directoryContents;
@property (nonatomic, strong) NSString *currentPath;

@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *reponame;

@end
