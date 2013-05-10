//
//  DMCommitMessageView.h
//  aGHC
//
//  Created by Daniel Miedema on 5/9/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMCommitMessageView : UIView

@property (strong, nonatomic) IBOutlet UITextView *commitMessageTextView;

@property (strong, nonatomic) IBOutlet UIButton *cancelCommitButton;
@property (strong, nonatomic) IBOutlet UIButton *postCommitButton;

- (IBAction)buttonPressed:(UIButton *)sender;
@end
