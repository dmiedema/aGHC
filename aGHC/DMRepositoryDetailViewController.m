//
//  DMRepositoryDetailViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 4/19/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMRepositoryDetailViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import "MMMarkdown.h"
#import "MF_Base64Additions.h"

@interface DMRepositoryDetailViewController ()
@property (nonatomic, strong) NSString *rawHTML;

//@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *repositoryNameLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *forksLabel;
@property (nonatomic, strong) UILabel *watchersLabel;
@property (nonatomic, strong) UILabel *issuesLabel;

@property (nonatomic,strong) UIWebView *readmeView;

@end

@implementation DMRepositoryDetailViewController

//TODO: Handle not getting all repo information, load information in async and update UI.
// might have to set everyhting to reference self and set up a bunch of properties. oh yay.

#define LABEL_WIDTH  280
#define LABEL_HEIGHT 54

#define BUTTON_WIDTH  73
#define BUTTON_HEIGHT 44

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLabelInformation:) name:@"aGHC-RepoDetailsLoaded" object:nil];
    
    if (![self repo] && [self repoName] && [self ownerName]) {
        // perform operation to get shit
        NSLog(@"no repo, repoName and ownerName");
        NSString *token     = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
        NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
        NSString *requestString;
        // repos/:user/:repo
        if (!token || !tokenType) requestString = [NSString stringWithFormat:@"%@repos/%@/%@", kGitHubApiURL, [self ownerName], [self repoName]];
        else requestString = [NSString stringWithFormat:[NSString stringWithFormat:@"%@repos/%@/%@?%@=%@&%@=%@", kGitHubApiURL, [self ownerName], [self repoName], kAccessToken, token, kTokenType, tokenType]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
        [request setValue:kResourceContentTypeDefault forHTTPHeaderField:@"Accept"];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [self setRepo:JSON];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"aGHC-RepoDetailsLoaded" object:self];
            NSLog(@"Operation to get information run");
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Failure to load details - %@", error);
        }];
        [operation start];
    }
	// Do any additional setup after loading the view.
    // TODO: Add a dismissal button/titlebar thing.
    NSLog(@"\n\nInformation to load: %@", [self repo]);
    NSDictionary *owner = [[self repo] objectForKey:@"owner"];
    // Custom initialization
    // create scroll view
    float x = 20.0;
    float y = 0.0;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIFont *defaultFont = [UIFont fontWithName:@"Avenir" size:20.0];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, 320, 320)];
    [[self imageView] setFrame:CGRectMake(0, y, 320, 320)];
    [[self imageView ] setImageWithURL:[NSURL URLWithString:[owner objectForKey:@"avatar_url"]] placeholderImage:[UIImage imageNamed:@"sL7cyZ5Oa7-2-1"]];
//    [imageView setImage:[UIImage imageNamed:@"sL7cyZ5Oa7-2-1"]];
    // set up dismiss button
    UIButton *dismissButton = [[UIButton alloc] init];
    [dismissButton setBackgroundColor:[UIColor colorWithRed:235 green:235 blue:235 alpha:0.7]];
//    [dismissButton setImage:[UIImage imageNamed:@"NotifyX"] forState:UIControlStateNormal];
    [dismissButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dismissButton setTitle:@"X" forState:UIControlStateNormal];
    [dismissButton setTitle:@":(" forState:UIControlStateHighlighted];
    [dismissButton setTag:0];
    [dismissButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [dismissButton setFrame:CGRectMake(10, 10, 44, 44)];
    
    // currently 320 down after image
    y+=320;
    NSLog(@"%f", y);
    
    // set up repository name label
//    UILabel *repositoryNameLabel = [[UILabel alloc] init];
    // set it a glow
    [[[self repositoryNameLabel] layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[[self repositoryNameLabel] layer] setShadowRadius:1.0f];
    [[[self repositoryNameLabel] layer] setShadowOpacity:1];
    [[[self repositoryNameLabel] layer] setShadowOffset:CGSizeZero];
    [[[self repositoryNameLabel] layer] setMasksToBounds:NO];
    // set it up
    [[self repositoryNameLabel] setFont:[UIFont fontWithName:@"Avenir" size:32.0]];
    [[self repositoryNameLabel] setAdjustsFontSizeToFitWidth:YES];
    [[self repositoryNameLabel] setMinimumScaleFactor:.1];
    [[self repositoryNameLabel] setNumberOfLines:1];
    [[self repositoryNameLabel] setAdjustsFontSizeToFitWidth:YES];
    [[self repositoryNameLabel] setText:[[self repo] objectForKey:@"name"]];
    [[self repositoryNameLabel] setBackgroundColor:[UIColor clearColor]];
    [[self repositoryNameLabel] setTextColor:[UIColor whiteColor]];
    [[self repositoryNameLabel] setFrame:CGRectMake((self.view.frame.size.width / 2)-45, 220, LABEL_WIDTH-75, LABEL_HEIGHT)];
    
    // set up description label
//    UILabel *descriptionLabel = [[UILabel alloc] init];
    [[self descriptionLabel] setFont:defaultFont];
    [[self descriptionLabel ] setLineBreakMode:NSLineBreakByWordWrapping];
    [[self descriptionLabel ] setNumberOfLines:0];
    [[self descriptionLabel ] setBackgroundColor:[UIColor clearColor]];
    [[self descriptionLabel ] setTextColor:[UIColor darkGrayColor]];
    NSString *descrption = [[self repo] objectForKey:@"description"];
    CGSize constraintSize = CGSizeMake(LABEL_WIDTH, MAXFLOAT);
    CGSize labelSize = [descrption sizeWithFont:defaultFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    [[self descriptionLabel ] setFrame:CGRectMake(x, y, labelSize.width, labelSize.height)];
    [[self descriptionLabel ] setText:descrption];
    //
    y += labelSize.height;
    NSLog(@"%f", y);
    // set up username label
    
//    UILabel *usernameLabel = [[UILabel alloc] init];
    [[self usernameLabel ] setFont:defaultFont];
    if ([[[self repo] objectForKey:@"fork"] integerValue] == NO)
        [[self usernameLabel ] setText:[NSString stringWithFormat:@"Created by - %@", [owner objectForKey:@"login"]]];
    else [[self usernameLabel ] setText:[NSString stringWithFormat:@"Forked by - %@", [owner objectForKey:@"login"]]];
    [[self usernameLabel ] setBackgroundColor:[UIColor clearColor]];
    [[self usernameLabel ] setFrame:CGRectMake(x, y, LABEL_WIDTH, LABEL_HEIGHT)];
    //
    y += LABEL_HEIGHT;
    NSLog(@"%f", y);
    // set up forks button
    UIButton *forksButton = [[UIButton alloc] init];
    [forksButton setTitle:@"Fork" forState:UIControlStateNormal];
    [forksButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [forksButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [forksButton setFrame:CGRectMake(x+10, y, BUTTON_WIDTH, BUTTON_HEIGHT)];
    // Set up watch button
    UIButton *watchButton = [[UIButton alloc] init];
    [watchButton setTitle:@"Watch" forState:UIControlStateNormal];
    [watchButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [watchButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [watchButton setFrame:CGRectMake((x+(10*3)) + BUTTON_WIDTH, y, BUTTON_WIDTH, BUTTON_HEIGHT)];
    // set up star button
    UIButton *starButton = [[UIButton alloc] init];
    [starButton setTitle:@"Star" forState:UIControlStateNormal];
    [starButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [starButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [starButton setFrame:CGRectMake((x+(10*5)) + (BUTTON_WIDTH * 2), y, BUTTON_WIDTH, BUTTON_HEIGHT)];
    //
    y += BUTTON_HEIGHT;
    NSLog(@"%f", y);
    // set up labels below buttons
//    UILabel *forksLabel = [[UILabel alloc] init];
    [[self forksLabel ] setFont:defaultFont];
    [[self forksLabel ] setText:[NSString stringWithFormat:@"Forks - %@",[[self repo] objectForKey:@"forks_count"]]];
    [[self forksLabel ] setBackgroundColor:[UIColor clearColor]];
    [[self forksLabel ] setFrame:CGRectMake(x, y, LABEL_WIDTH/2, LABEL_HEIGHT)];
    // set up watchers label below buttons
//    UILabel *watchersLabel = [[UILabel alloc] init];
    [[self watchersLabel ] setFont:defaultFont];
    [[self watchersLabel ] setText:[NSString stringWithFormat:@"Watchers - %@", [[self repo] objectForKey:@"watchers_count"]]];
    [[self watchersLabel ] setBackgroundColor:[UIColor clearColor]];
    [[self watchersLabel ] setFrame:CGRectMake((LABEL_WIDTH+x) / 2, y, LABEL_WIDTH/2, LABEL_HEIGHT)];
    //
    y += LABEL_HEIGHT;
    NSLog(@"%f", y);
    // issues label
//    UILabel *issuesLabel = [[UILabel alloc] init];
    [[self issuesLabel ] setFont:defaultFont];
    [[self issuesLabel ] setText:[NSString stringWithFormat:@"Open Issues - %@",[[self repo] objectForKey:@"open_issues_count"]]];
    [[self issuesLabel ] setBackgroundColor:[UIColor clearColor]];
    [[self issuesLabel ] setFrame:CGRectMake(x, y, LABEL_WIDTH, LABEL_HEIGHT)];
    //
    y += LABEL_HEIGHT;
    NSLog(@"%f", y);
    // explore code button
    UIButton *exploreCode = [[UIButton alloc] init];
    [exploreCode setTitle:@"Explore Code" forState:UIControlStateNormal];
    [exploreCode setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [exploreCode addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [exploreCode setFrame:CGRectMake(x, y, LABEL_WIDTH, BUTTON_HEIGHT)];
    y += BUTTON_HEIGHT;
    NSLog(@"%f", y);
    
    // create readme markdown view
//    UIWebView *readmeView = [[UIWebView alloc] init];
    // Accept Header
    // application/vnd.github.v3.html+json
    // on https://api.github.com/repos/dmiedema/dropboxcollection/readme
    // or kGitHubApiURL /repos/:user/:repo/readme
    // and render output to webview
    NSString *requestString;
    NSString *token     = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
    NSString *login     = [owner objectForKey:@"login"];
    NSString *reponame  = [[self repo] objectForKey:@"name"];
    
    if (token || tokenType == NULL)
        requestString = [NSString stringWithFormat:@"%@repos/%@/%@/readme", kGitHubApiURL, login, reponame];
    else
        requestString = [NSString stringWithFormat:@"%@repos/%@/%@/readme?%@=%@&%@=%@", kGitHubApiURL, login, reponame, kAccessToken, token, kTokenType, tokenType];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@repos/%@/%@/readme", kGitHubApiURL, [owner objectForKey:@"login"], [[self repo] objectForKey:@"name" ]]]];
    NSLog(@"Request - %@", request);
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //[request setValue:@"application/vnd.github.v3.html+json" forHTTPHeaderField:@"Accept"];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Response - %@", [NSString stringWithContentsOfURL:[request URL] encoding:NSStringEncodingConversionAllowLossy error:nil]);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error - %@", error);
//    }];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Response -- %@", JSON);
        NSLog(@"Content - %@", [JSON objectForKey:@"content"]);
        NSLog(@"Decoded - %@", [NSString stringFromBase64String:[JSON objectForKey:@"content"]]);
        [self setRawHTML:[NSString stringFromBase64String:[JSON objectForKey:@"content"]]];

        NSLog(@"HTML - %@", [MMMarkdown HTMLStringWithMarkdown:[NSString stringFromBase64String:[JSON objectForKey:@"content"]] error:nil]);
        
        [[self readmeView ] loadHTMLString:[MMMarkdown HTMLStringWithMarkdown:[self rawHTML] error:nil] baseURL:nil];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"HTML -- %@", JSON);
        NSLog(@"Error - %@", error);
        NSLog(@"Error loading README");
    }];
    [operation start];
    [[self readmeView ] setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];

    [[self readmeView ] setFrame:CGRectMake(0, y, self.view.frame.size.width, [[[self readmeView] stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue])];
    [[self readmeView ] sizeToFit];
    y += self.readmeView.frame.size.height;
    
//    CGRectMake(x, y, LABEL_WIDTH, <#CGFloat height#>)
//    [descriptionLabel setFont:defaultFont];
//    [descriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
//    [descriptionLabel setNumberOfLines:0];
//    [descriptionLabel setBackgroundColor:[UIColor clearColor]];
//    [descriptionLabel setTextColor:[UIColor darkGrayColor]];
    //NSString *descrption = [[self repo] objectForKey:@"description"];
    //CGSize constraintSize = CGSizeMake(LABEL_WIDTH, MAXFLOAT);
//    //CGSize labelSize = [descrption sizeWithFont:defaultFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
//    [descriptionLabel setFrame:CGRectMake(x, y, labelSize.width, labelSize.height)];
//    [descriptionLabel setText:descrption];
    
    // add subviews to scroll view. And there are a lot of them holy fuck.
    [scrollView addSubview:[self imageView]];
    [scrollView addSubview:[self repositoryNameLabel ]];
    [scrollView addSubview:[self descriptionLabel ]];
    [scrollView addSubview:[self usernameLabel ]];
    [scrollView addSubview:forksButton];
    [scrollView addSubview:watchButton];
    [scrollView addSubview:starButton];
    [scrollView addSubview:[self forksLabel ]];
    [scrollView addSubview:[self watchersLabel ]];
    [scrollView addSubview:[self issuesLabel ]];
    [scrollView addSubview:exploreCode];
    [scrollView addSubview:dismissButton];
    [scrollView addSubview:[self readmeView ]];
    
    // add the scroll view into the view
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, y)];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [[self view] addSubview:scrollView];
    
    NSLog(@"current y : %f", y);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLabelInformation:(id)sender {
    // set up ALL the labels. oh yay...
//    @property (nonatomic, strong) UIImageView *imageView;
//    
//    @property (nonatomic, strong) UILabel *repositoryNameLabel;
//    @property (nonatomic, strong) UILabel *descriptionLabel;
//    @property (nonatomic, strong) UILabel *usernameLabel;
//    @property (nonatomic, strong) UILabel *forksLabel;
//    @property (nonatomic, strong) UILabel *watchersLabel;
//    @property (nonatomic, strong) UILabel *issuesLabel;
//    
//    @property (nonatomic,strong) UIWebView *readmeView;
    NSLog(@"setLabelInformation");
    NSDictionary *owner = [[self repo] objectForKey:@"owner"];

    [[self imageView] setImageWithURL:[NSURL URLWithString:[owner objectForKey:@"avatar_url"]] placeholderImage:[UIImage imageNamed:@"sL7cyZ5Oa7-2-1"]];
    
    [[self repositoryNameLabel] setText:[[self repo] objectForKey:@"name"]];
    //    [[self descriptionLabel] setText:[[self repo] objectForKey:@""]] //shit dynamic size.
       if ([[self repo] objectForKey:@"fork"])
        [[self usernameLabel] setText:[NSString stringWithFormat:@"Forked by - %@", [owner objectForKey:@"login"]]];
    else [[self usernameLabel] setText:[NSString stringWithFormat:@"Created by - %@", [owner objectForKey:@"login"]]];
    [[self forksLabel] setText:[NSString stringWithFormat:@"Forks - %@", [[self repo] objectForKey:@"forks_count"]]];
    [[self watchersLabel] setText:[NSString stringWithFormat:@"Watchers - %@", [[self repo] objectForKey:@"watchers_count"]]];
    [[self issuesLabel] setText:[NSString stringWithFormat:@"Open Issues - %@", [[self repo] objectForKey:@"open_issues_count"]]];
}

- (void)buttonPressed:(UIButton *)sender {
    NSLog(@"sender: %@", [[sender titleLabel] text]);
    if ([[[sender titleLabel] text] isEqualToString:@"X"] || [[[sender titleLabel] text] isEqualToString:@":("]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if ([[[sender titleLabel] text] isEqualToString:@"Explore Code"]) {
        
    }
}
@end
