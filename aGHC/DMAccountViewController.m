//
//  DMAccountViewController.m
//  aGHC
//
//  Hi.
//
//  Created by Daniel Miedema on 3/10/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMAccountViewController.h"
#import <AFOAuth2Client/AFOAuth2Client.h>
#import <NXOAuth2Client/NXOAuth2.h>


@interface DMAccountViewController () <UIWebViewDelegate>

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSDictionary *token;
@property (nonatomic, copy) NSString *username;

- (void) saveTokenInformation:(NSDictionary *) tokenInfo;
- (void)saveToDefaults:(NSDictionary *)dict;

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
    UIWebView *webView = [[UIWebView alloc] init];
    [webView setDelegate:self];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&scope=%@", kGitHubAuthenticationURL, kClientID, kScope]]]];
    [webView setOpaque:YES];
    self.view = webView;

	// Do any additional setup after loading the view.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Request Main URL: %@", [request mainDocumentURL]);
    NSLog(@"Request All HTTP Headers: %@", [request allHTTPHeaderFields]);
    NSLog(@"Request HTTP Method: %@", [request HTTPMethod]);
    NSLog(@"Request HTTP Body: %@", [request HTTPBody]);
    
    NSString *mainURL = [[request mainDocumentURL] absoluteString];
    NSArray *components = [mainURL componentsSeparatedByString:@"?"];
    NSLog(@"\n----- Components: %@\n", components);
    
    if ([[components objectAtIndex:0] isEqual:@"http://danielmiedema.com/"]) {
        NSLog(@"redirected to danielmiedema.com");
        NSArray *code = [[components objectAtIndex:1] componentsSeparatedByString:@"="];
        NSLog(@"Code: %@", [code objectAtIndex:1]);
        
        NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/?code=%@&client_id=%@&client_secret=%@", kGitHubOAuthTokenURL, [code objectAtIndex:1], kClientID, kClientSecret]]];
        [newRequest setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Accept"];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:newRequest success:^(NSURLRequest *request, NSHTTPURLResponse *reponse, id JSON) {
            NSLog(@"Response: %@", reponse);
            NSLog(@"JSON: %@", JSON );

            [self saveTokenInformation:JSON];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *reponse, NSError *error, id JSON) {
            NSLog(@"failure");
            NSLog(@"reponse: %@", reponse);
            NSLog(@"Error: %@", error);
            NSLog(@"JSON: %@", JSON);
        }];
        [operation start];
        return NO;
        // We'll go back here. somehow.
    }
    return YES;
}

- (void)saveTokenInformation:(NSDictionary *)tokenInfo {
    [[self token] setValuesForKeysWithDictionary:tokenInfo];
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:
                                                                           [NSString stringWithFormat:@"%@%@?%@=%@&%@=%@",
                                                                            kGitHubApiURL, @"user",
                                                                            kAccess_Token, [tokenInfo valueForKey:kAccess_Token],
                                                                            kToken_Type, [tokenInfo valueForKey:kToken_Type]]]];
    AFJSONRequestOperation *getUserName = [AFJSONRequestOperation JSONRequestOperationWithRequest:newRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"JSON: %@", JSON);
        self.username = [JSON objectForKey:@"login"];
        NSMutableDictionary *allUserInfo = [NSMutableDictionary dictionaryWithDictionary:tokenInfo];
        [allUserInfo addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[JSON objectForKey:@"login"] forKey:@"username"]];
        [self saveToDefaults:allUserInfo];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error : %@", error);
    }];
    [getUserName start];
}

- (void)saveToDefaults:(NSDictionary *)dict {
    NSLog(@"saving to defaults");
    NSLog(@"Dictionary to save: %@", dict);
    [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:dict];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserInformationSavedToDefaults object:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
