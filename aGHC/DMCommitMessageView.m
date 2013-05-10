//
//  DMCommitMessageView.m
//  aGHC
//
//  Created by Daniel Miedema on 5/9/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMCommitMessageView.h"

@implementation DMCommitMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
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

- (IBAction)buttonPressed:(UIButton *)sender {
    if ([[[sender titleLabel] text] isEqualToString:@"Cancel"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCommitCancelledNotification object:self];
    } else if ([[[sender titleLabel] text] isEqualToString:@"Post Commit"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCommitMessagePostedNotification object:[_commitMessageTextView text]];
    }
}
@end
