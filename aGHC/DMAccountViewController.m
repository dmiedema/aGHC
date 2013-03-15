//
//  DMAccountViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 3/10/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMAccountViewController.h"
#import <AFOAuth2Client.h>

@interface DMAccountViewController ()

@end

@implementation DMAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@""];
    AFOAuth2Client *oauthClient = [AFOAuth2Client clientWithBaseURL:url clientID:kClientID secret:kClientSecret];
    [oauthClient authenticateUsingOAuthWithPath:@"https://github.com/login/oauth/access_token"
                                       username:@""
                                       password:@""
                                          scope:kTokenScope
                                        success:^(AFOAuthCredential *credential) {
                                            NSLog(@"Creditial Recieved: %@", credential.accessToken);
                                            [AFOAuthCredential storeCredential:credential withIdentifier:oauthClient.serviceProviderIdentifier];
                                        }
                                        failure:^(NSError *error) {
                                            NSLog(@"Error %@", error);
                                            
                                        }];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
