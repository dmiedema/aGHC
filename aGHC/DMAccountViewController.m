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


@interface DMAccountViewController () <UIWebViewDelegate>

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
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&scope=%@", kGitHubAuthenticationURL, kClientID, kScope]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120]];
    [webView setOpaque:YES];
    self.view = webView;

    // TODO: Add forward/back buttons to WebView in case user navigates so they can get back to authorization page.
	////
    // Do any additional setup after loading the view.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    #if TESTING
        NSLog(@"Request Main URL: %@", [request mainDocumentURL]);
        NSLog(@"Request All HTTP Headers: %@", [request allHTTPHeaderFields]);
        NSLog(@"Request HTTP Method: %@", [request HTTPMethod]);
        NSLog(@"Request HTTP Body: %@", [request HTTPBody]);
    #endif
    
    NSString *mainURL = [[request mainDocumentURL] absoluteString];
    NSArray *components = [mainURL componentsSeparatedByString:@"?"];
    
    #if TESTING
        NSLog(@"\n----- Components: %@\n", components);
    #endif
    
    if ([[components objectAtIndex:0] isEqual:@"http://danielmiedema.com/"]) {
        NSArray *code = [[components objectAtIndex:1] componentsSeparatedByString:@"="];
        
        #if TESTING
            NSLog(@"redirected to danielmiedema.com");
            NSLog(@"Code: %@", [code objectAtIndex:1]);
        #endif
        
        NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/?code=%@&client_id=%@&client_secret=%@", kGitHubOAuthTokenURL, [code objectAtIndex:1], kClientID, kClientSecret]]];
        [newRequest setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Accept"];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:newRequest success:^(NSURLRequest *request, NSHTTPURLResponse *reponse, id JSON) {
            
            #if TESTING
                NSLog(@"Response: %@", reponse);
                NSLog(@"JSON: %@", JSON );
            #endif
            [self saveTokenInformation:JSON];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *reponse, NSError *error, id JSON) {

            #if TESTING
                NSLog(@"failure");
                NSLog(@"reponse: %@", reponse);
                NSLog(@"Error: %@", error);
                NSLog(@"JSON: %@", JSON);
            #endif
            
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
                                                                            kAccessToken, [tokenInfo valueForKey:kAccessToken],
                                                                            kTokenType, [tokenInfo valueForKey:kTokenType]]]];
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
    #if TESTING
        NSLog(@"saving to defaults");
        NSLog(@"Dictionary to save: %@", dict);
    #endif
    // Get current array of accounts
    NSMutableArray *accounts = [[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"];
    // Check to see if i already have this account in there.
    for (NSDictionary *account in accounts) {
        if ([[dict valueForKey:@"username"] isEqual:[accounts valueForKey:@"username"]]) {
            // If account is already in there, throw up a notifcation and return.
            #if TESTING
                NSLog(@"Account is already in NSUserDefaults");
            #endif
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserInformationAlreadyInDefaultsNotifcation object:self];
            return; }
    } // end fast enumeration
    
    // Account is new, add it to NSUserDefaults and save.
    [accounts addObject:dict];
    [[NSUserDefaults standardUserDefaults] setObject:accounts forKey:@"accounts"];
    //[[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:dict];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserInformationSavedToDefaultsNotifcation object:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
