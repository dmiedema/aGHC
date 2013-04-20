//
//  DMParallaxedViewController.h
//  aGHC
//
//  Created by Daniel Miedema on 4/19/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M6ParallaxController.h"

@interface DMParallaxedViewController : UIViewController <M6ParallaxMasterViewControllerDelegate>

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *repoName;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *repoNameLabel;

- (IBAction)loadUser:(id)sender;

@end
