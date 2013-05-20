//
//  DMRepositoryTableViewCell.h
//  aGHC
//
//  Created by Daniel Miedema on 5/20/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMRepositoryTableViewCell : NSObject

- (UIView *)createTableViewCellWithDictionary: (NSDictionary *)currentRepo;

@end
