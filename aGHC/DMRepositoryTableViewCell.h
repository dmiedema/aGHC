//
//  DMRepositoryTableViewCell.h
//  JSONTesting
//
//  Created by Daniel Miedema on 2/18/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMRepositoryTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *repositoryName;
@property (nonatomic, weak) IBOutlet UILabel *repositoryDetailInfo;

@property (nonatomic, weak) IBOutlet UIImageView *typeImage;
@property (nonatomic, weak) IBOutlet UIImageView *privateRepo;


@end
