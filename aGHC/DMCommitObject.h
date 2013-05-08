//
//  DMCommitObject.h
//  aGHC
//
//  Created by Daniel Miedema on 5/7/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMCommitObject : NSObject

@property (nonatomic, strong) NSDictionary *repoInformation;

+ (BOOL)commitFile:(NSString *)fileContents
            toRepo:(NSString *)repo
         withOwner:(NSString *)owner
    withParentTree:(NSString *)parentSHA
        andSHAHash:(NSString *)SHAHash
       withMessage:(NSString *)commitMessage;

+ (NSArray *)getAllCommitsForRepository:(NSString *)repo andOwner:(NSString *)owner;
+ (NSDictionary *)getSingleCommitForRepository:(NSString *)repo andOwner:(NSString *)owner withHash:(NSString *)SHAHash;

@end
