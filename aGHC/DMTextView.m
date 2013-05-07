//
//  DMTextView.m
//  aGHC
//
//  Created by Daniel Miedema on 5/6/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMTextView.h"

@implementation DMTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextViewTextDidChangeNotification object:self];
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

- (void)textFieldTextDidChange:(id)sender {
    
}

@end
