//
//  DMCommitObject.m
//  aGHC
//
//  Created by Daniel Miedema on 5/7/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMCommitObject.h"

@implementation DMCommitObject

+ (BOOL)commitFile:(NSString *)fileContents
            toRepo:(NSString *)repo
         withOwner:(NSString *)owner
    withParentTree:(NSString *)parentSHA
  andParentSHAHash:(NSString *)SHAHash
 withCommitMessage:(NSString *)commitMessage {
    
    __block BOOL successful;
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];

    // POST /repos/:owner/:repo/git/commits
    // message(string) -> tree(string) -> parents(array)
    NSString *requestURL = [NSString stringWithFormat:@"%@repos/%@/%@/git/commits", kGitHubApiURL, owner, repo];
    NSString *postData = [NSString stringWithFormat:@"%@=%@&%@=%@&message=%@&tree=%@&parents=%@",
                          kAccessToken, token, kTokenType, tokenType, commitMessage, parentSHA, SHAHash];
    
    NSMutableURLRequest *request =[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"aGHC-Commit-Posted-Successful" object:self];
        successful = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"aGHC-Commit-Posted-Failure" object:self];
        successful = NO;
    }];
    [operation start];
    
    return successful;
}

+ (BOOL)withLatestsCommitTreeAndParentHashCommitFile:(NSString *)fileContents
                                              toRepo:(NSString *)repo
                                           withOwner:(NSString *)owner
                                   withCommitMessage:(NSString *)commitMessage {
    __block BOOL success = NO;
    __block NSArray *commitsForRepo;
    __block NSDictionary *repoInformation;
    __block NSDictionary *commitPostInformation;
    __block NSError *blockError;
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
    NSString *urlRequest;
    
    if (token && token)
        urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/commits?%@=%@&%@=%@", kGitHubApiURL, owner, repo, kAccessToken, token, kTokenType, tokenType];
    else return NO;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    
    AFJSONRequestOperation *commitsOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        commitsForRepo = JSON;
        NSLog(@"Commit information recieved successfully %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        success = NO;
        blockError = error;
        NSLog(@"error getting commit information %@", error);
    }];
    // start getting commits
    [commitsOperation start];
    
    NSDictionary *latestCommmit = [commitsForRepo objectAtIndex:0];
    
    NSString *shaForLatestCommit = [latestCommmit objectForKey:@"sha"];
    NSString *treeSHAForLatestCommit = [[latestCommmit objectForKey:@"tree"] objectForKey:@"sha"];
    
    // reset urlRequest to get a single commit object
//    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/commits/%@?%@=%@&%@=%@", kGitHubApiURL, owner, repo, shaForLatestCommit, kAccessToken, token, kTokenType, tokenType];
//    
//    [request setURL:[NSURL URLWithString:urlRequest]];
//    
//    AFJSONRequestOperation *singleCommitOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        repoInformation = JSON;
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//        success = NO;
//        error = error;
//    }];
    
    // reset urlRequest to POST the commit
    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/commits?%@=%@&%@=%@", kGitHubApiURL, owner, repo, kAccessToken, token, kTokenType, tokenType];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    
    [request setHTTPMethod:@"POST"];
    NSString *postBody = [NSString stringWithFormat:@"message=%@&tree=%@&parents=%@", commitMessage, treeSHAForLatestCommit, shaForLatestCommit];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *postCommitOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        commitPostInformation = JSON;
        NSLog(@"Commit posted successfully %@", JSON);
        success = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        blockError = error;
        success = NO;
        NSLog(@"error posting commit %@", error);
    }];
    
    [postCommitOperation addDependency:commitsOperation];
    [postCommitOperation start];
    
    return success;
}

+ (NSArray *)getAllCommitsForRepository:(NSString *)repo andOwner:(NSString *)owner {
    __block NSArray *commitsForRepo;
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
    // GET /repos/:owner/:repo/commits
    NSString *urlRequest;
    
    if (token && tokenType) {
        urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/commits?%@=%@&%@=%@", kGitHubApiURL, owner, repo, kAccessToken, token, kTokenType, tokenType];
    } else
        urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/commits", kGitHubApiURL, owner, repo];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        commitsForRepo = JSON;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        commitsForRepo = JSON;
    }];
    [operation start];
    
    return commitsForRepo;
}

+ (NSDictionary *)getSingleCommitForRepository:(NSString *)repo andOwner:(NSString *)owner withHash:(NSString *)SHAHash {
    __block NSDictionary *repoInformation;
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
    // GET /repos/:owner/:repo/commits/:sha
    NSString *urlRequest;
    
    if (token && tokenType) {
        urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/commits?%@=%@&%@=%@", kGitHubApiURL, owner, repo, kAccessToken, token, kTokenType, tokenType];
    } else
        urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/commits", kGitHubApiURL, owner, repo];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        repoInformation = JSON;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        repoInformation = JSON;
    }];
    [operation start];
    
    return repoInformation;
}

@end
