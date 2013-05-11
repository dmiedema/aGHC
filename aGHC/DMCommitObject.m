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

+ (BOOL)withLatestsCommitTreeAndParentHashCommitFile:(NSString *)fileName
                                        withContents:(NSString *)fileContents
                                              toRepo:(NSString *)repo
                                           withOwner:(NSString *)owner
                                   withCommitMessage:(NSString *)commitMessage {
    __block BOOL success = NO;
    __block NSArray *commitsForRepo;
//    __block NSDictionary *repoInformation;
    __block NSDictionary *commitPostInformation;
    __block NSDictionary *createdTree;
    __block NSString *createdBlobSHA;
    __block NSDictionary *referenceUpdate;
    __block NSDictionary *createdCommit;
    __block NSError *blockError;
    NSLog(@"Attempting to post commit");
    NSLog(@"Data: \nfile: %@\nrepo: %@\nowner: %@\nmessage: %@", fileContents, repo, owner, commitMessage);

#if TESTING
    NSLog(@"Attempting to post commit");
    NSLog(@"Data: \nfile: %@\nrepo: %@\nowner: %@\nmessage: %@", fileContents, repo, owner, commitMessage);
#endif
    
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
    
    // Create blob
    //    POST /repos/:owner/:repo/git/blobs
    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/blobs", kGitHubApiURL, owner, repo];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    NSString *postBody = [NSString stringWithFormat:@"content=%@&encoding=%@", fileContents, @"utf-8"];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *createBlobOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        createdBlobSHA = [JSON objectForKey:@"sha"];
        NSLog(@"Blob created successfully = %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        error = error;
        NSLog(@"Error created blob %@", error);
    }];
    [createBlobOperation start];
    
    
    // Create tree
    //    POST /repos/:owner/:repo/git/trees
    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/trees", kGitHubApiURL, owner, repo];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    postBody = [NSString stringWithFormat:@"base_tree=%@&tree.path=%@&tree.mode=100644&tree.type=blob&tree.sha=%@", treeSHAForLatestCommit, fileName, createdBlobSHA];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *createTreeOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        createdTree = JSON;
        NSLog(@"Tree created %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        error = error;
        NSLog(@"Error creating Tree %@", error);
    }];
    [createTreeOperation addDependency:createBlobOperation];
    [createBlobOperation start];
    
    // Create commit
    //    POST /repos/:owner/:repo/git/commits
    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/commits", kGitHubApiURL, owner, repo];

    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    postBody = [NSString stringWithFormat:@"message=%@&tree=%@&parents=%@", commitMessage, [createdTree objectForKey:@"sha"], shaForLatestCommit];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *createCommitOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        createdCommit = JSON;
        NSLog(@"Commit created successfully %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        error = error;
        NSLog(@"ERror creating commit %@", error);
    }];
    [createCommitOperation addDependency:createTreeOperation];
    [createCommitOperation start];
    
    // Update refs
    //    PATCH /repos/:owner/:repo/git/refs/:ref
    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/refs/%@", kGitHubApiURL, owner, repo, @"refs/heads/master"]; // master branch, for now. 
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    postBody = [NSString stringWithFormat:@"sha=%@&force=false", [createdCommit objectForKey:@"sha"]];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *referenceUpdateOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        referenceUpdate = JSON;
        NSLog(@"Reference successfully updated %@", JSON);
        success = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        error = error;
        NSLog(@"Reference update failed %@", JSON);
        success = NO;
    }];
    [referenceUpdateOperation addDependency:createCommitOperation];
    [referenceUpdateOperation start];
    
    // reset urlRequest to POST the commit
//    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/commits?%@=%@&%@=%@", kGitHubApiURL, owner, repo, kAccessToken, token, kTokenType, tokenType];
//    
//    [request setURL:[NSURL URLWithString:urlRequest]];
//    
//    [request setHTTPMethod:@"POST"];
//    postBody = [NSString stringWithFormat:@"message=%@&tree=%@&parents=%@", commitMessage, treeSHAForLatestCommit, shaForLatestCommit];
//    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    AFJSONRequestOperation *postCommitOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        commitPostInformation = JSON;
//        NSLog(@"Commit posted successfully %@", JSON);
//        success = YES;
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//        blockError = error;
//        success = NO;
//        NSLog(@"error posting commit %@", error);
//    }];
//    
//    [postCommitOperation addDependency:commitsOperation];
//    [postCommitOperation start];
    
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
