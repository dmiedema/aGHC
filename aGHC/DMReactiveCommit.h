//
//  DMReactiveCommit.h
//  aGHC
//
//  Created by Daniel Miedema on 5/12/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMReactiveCommit : NSObject

@property (nonatomic, strong) NSDictionary *fileInformation;

- (BOOL)createCommitForFile:(NSDictionary *)fileInformation;

- (BOOL)createCommitUsingAllPreviousCommitInformationAsHistoryForFile:(NSDictionary *)fileInformation;

@end
