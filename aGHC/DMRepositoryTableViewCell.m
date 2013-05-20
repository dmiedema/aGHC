//
//  DMRepositoryTableViewCell.m
//  aGHC
//
//  Created by Daniel Miedema on 5/20/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMRepositoryTableViewCell.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface DMRepositoryTableViewCell()

@property (nonatomic, strong) NIKFontAwesomeIconFactory *factory;

@end

@implementation DMRepositoryTableViewCell

- (id)init {
    self = [super init];
    if (self) {
        _factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    }
    return self;
}

- (UIView *)createTableViewCellWithDictionary: (NSDictionary *)currentRepo {
    //    static NSString *CellIdentifier = @"Repository Cell";
    // custom cell, gotta love that custom cell
    //    DMRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    //    x 20 y 1  w 300 h 39
    UILabel *repositoryNameLabel = [[UILabel alloc] init];
    [repositoryNameLabel setFont:[UIFont fontWithName:kFontName size:23]];
    [repositoryNameLabel setBackgroundColor:[UIColor clearColor]];
    [repositoryNameLabel setText:[currentRepo objectForKey:@"name"]];
    [repositoryNameLabel setFrame:CGRectMake(20, 1, 300, 39)];
    
    //    x 42 y 38 w 278 h 21
    UILabel *repositoryDetailLabel = [[UILabel alloc] init];
    [repositoryDetailLabel setFont:[UIFont fontWithName:kFontName size:15]];
    [repositoryDetailLabel setBackgroundColor:[UIColor clearColor]];
    [repositoryDetailLabel setText:[NSString stringWithFormat:@"Forks: %@ - Issues: %@ - Watchers: %@",
                                    [currentRepo objectForKey:@"forks_count"],
                                    [currentRepo objectForKey:@"open_issues_count"],
                                    [currentRepo objectForKey:@"watchers"]]];
    [repositoryDetailLabel setTextColor:[UIColor darkGrayColor]];
    [repositoryDetailLabel setFrame:CGRectMake(42, 38, 278, 21)];
    
    
    
    [_factory setColors:@[[NIKColor lightGrayColor]]];
    
    UIImageView *private = [[UIImageView alloc] initWithImage:[_factory createImageForIcon:NIKFontAwesomeIconLock]];
    [private setFrame:CGRectMake(280, 0, 18, 29)];
    
    UIImageView *fork = [[UIImageView alloc] initWithImage:[_factory createImageForIcon:NIKFontAwesomeIconCodeFork]];
    [fork setFrame:CGRectMake(0, 0, 32, 57)];
    
    UIImageView *normalRepo = [[UIImageView alloc] initWithImage:[_factory createImageForIcon:NIKFontAwesomeIconFolderOpen]];
    [normalRepo setFrame:CGRectMake(0, 0, 60, 57)];
    
    if ([[currentRepo objectForKey:@"private"] integerValue] == 1) {
        [cellView addSubview:private];
    } //else [[cell privateRepo] setImage:nil];
      // repo fork?
    if ([[currentRepo objectForKey:@"fork"] integerValue] == 1) {
        [cellView addSubview:fork];
    } else [cellView addSubview:normalRepo];
    
    [cellView addSubview:repositoryNameLabel];
    [cellView addSubview:repositoryDetailLabel];
    
    return cellView;
}

@end
