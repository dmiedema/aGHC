//
//  DMCustomLabel.m
//  aGHC
//
//  Created by Daniel Miedema on 4/7/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMCustomLabel.h"

@implementation DMCustomLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
            // Ternarys FTW
        [self setFont:[UIFont fontWithName:([self fontName]) ? [self fontName] : @"Avenir"
                                      size:([self fontSize]) ? [self fontSize] : 12.0]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
