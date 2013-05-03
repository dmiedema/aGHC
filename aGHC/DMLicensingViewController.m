//
//  DMLicensingViewController.m
//  aGHC
//
//  Created by Daniel Miedema on 5/3/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMLicensingViewController.h"
#import "MMMarkdown.h"

@interface DMLicensingViewController ()

- (void)dismissMe;

@end


#define stylestring @"<style>*{margin:0;padding:0;}body {font:13.34px helvetica,arial,freesans,clean,sans-serif;color:black;	line-height:1.4em;background-color: #F8F8F8;padding: 0.7em;}p {margin:1em 0;	line-height:1.5em;}table {	font-size:inherit;font:100%margin:1em;}table th{border-bottom:1px solid #bbb;padding:.2em 1em;}table td{border-bottom:1px solid #ddd;padding:.2em 1em;}input[type=text],input[type=password],input[type=image],textarea{font:99% helvetica,arial,freesans,sans-serif;}select,option{padding:0 .25em;}optgroup{margin-top:.5em;}pre,code{font:12px Monaco,'Courier New','DejaVu Sans Mono','Bitstream Vera Sans Mono',monospace;}pre {margin:1em 0;	font-size:12px;	background-color:#eee;border:1px solid #ddd;padding:5px;line-height:1.5em;color:#444;overflow:auto;-webkit-box-shadow:rgba(0,0,0,0.07) 0 1px 2px inset;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;}pre code {padding:0;font-size:12px;background-color:#eee;border:none;}code {font-size:12px;background-color:#f8f8ff;color:#444;padding:0 .2em;border:1px solid #dedede;}img{border:0;max-width:100%;}abbr{border-bottom:none;}a{color:#4183c4;text-decoration:none;}a:hover{text-decoration:underline;}a code,a:link code,a:visited code{color:#4183c4;}h2,h3{margin:1em 0;}h1,h2,h3,h4,h5,h6{border:0;}h1{font-size:170%;border-top:4px solid #aaa;padding-top:.5em;margin-top:1.5em;}h1:first-child{margin-top:0;padding-top:.25em;border-top:none;}h2{font-size:150%;margin-top:1.5em;border-top:4px solid #e0e0e0;padding-top:.5em;}h3{margin-top:1em;}hr{border:1px solid #ddd;}ul{margin:1em 0 1em 2em;}ol{margin:1em 0 1em 2em;}ul li,ol li{margin-top:.5em;margin-bottom:.5em;}ul ul,ul ol,ol ol,ol ul{margin-top:0;margin-bottom:0;}blockquote{margin:1em 0;border-left:5px solid #ddd;padding-left:.6em;color:#555;}dt{font-weight:bold;margin-left:1em;}dd{margin-left:2em;margin-bottom:1em;}@media screen and (min-width: 768px) {body {width: 748px;margin:10px auto;}}</style>"



@implementation DMLicensingViewController

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
    // copy/pasta ftw
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"Pods-Acknowledgements" ofType:@"markdown"];
    NSString *rawhtml =[NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    NSString *html = [NSString stringWithFormat:@"%@%@", stylestring, rawhtml];
	// Do any additional setup after loading the view.
    UIWebView *acknowledgements = [[UIWebView alloc] init];
    [acknowledgements setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [acknowledgements loadHTMLString:[MMMarkdown HTMLStringWithMarkdown:html error:nil] baseURL:nil];
    
    UIButton *dismiss = [[UIButton alloc] init];
    [dismiss setFrame:CGRectMake(20, 10, 44, 44)];
    [dismiss setTitle:@"X" forState:UIControlStateNormal];
    [dismiss setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [dismiss addTarget:self action:@selector(dismissMe) forControlEvents:UIControlEventTouchUpInside];
 
    [[self view] addSubview:acknowledgements];
    [[self view] addSubview:dismiss];
}

- (void)dismissMe {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
