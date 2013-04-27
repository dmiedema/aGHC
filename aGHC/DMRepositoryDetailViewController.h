//
//  DMRepositoryDetailViewController.h
//  aGHC
//
//  Created by Daniel Miedema on 4/19/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMRepositoryDetailViewController : UIViewController

@property (nonatomic, strong) NSDictionary *repo;
@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *repoName;

@end