//
//  DMRepositoryFileViewController.h
//  aGHC
//
//  Created by Daniel Miedema on 5/6/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMTextView.h"

@interface DMRepositoryFileViewController : UIViewController // <UITextViewDelegate>

@property (nonatomic, strong) DMTextView *DMtextView;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSString *initialText;

@end
