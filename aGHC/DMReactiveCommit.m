//
//  DMReactiveCommit.m
//  aGHC
//
//  Created by Daniel Miedema on 5/12/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMReactiveCommit.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface DMReactiveCommit () // private

@property (nonatomic, strong) NSArray *allCommits;
@property (nonatomic, strong) NSDictionary *latestCommit;
@property (nonatomic, strong) NSDictionary *createdBlob;
@property (nonatomic, strong) NSDictionary *createdTree;
@property (nonatomic, strong) NSDictionary *createdCommit;
@property (nonatomic, strong) NSDictionary *referenceUpdate;

@property (nonatomic, strong) NSError *error;

@property (nonatomic, copy) NSString *httpHeaderTokenString;
@property (nonatomic, copy) NSString *urlRequest;

@property BOOL success;

@end

@implementation DMReactiveCommit

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
    
    if (token && token)
        _httpHeaderTokenString = [NSString stringWithFormat:@"%@=%@&%@=%@", kAccessToken, token, kTokenType, tokenType];
    
    return self;
}
    
- (void)dealloc {
    
}

- (BOOL)createCommitUsingAllPreviousCommitInformationAsHistoryForFile:(NSDictionary *)fileInformation {
    
//    RACSignal *createCommit = [self.fileInformation rac_sig]
    return NO;
}


- (BOOL)createCommitForFile:(NSDictionary *)fileInformation {
    return NO;
}





/*********************************************************************************************************************/







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
    
    NSMutableDictionary *JSONObjectToPass;
    NSMutableURLRequest *request;
    
#if TESTING
    NSLog(@"Attempting to post commit");
    NSLog(@"Data: \nfile: %@\ncontents: %@\nrepo: %@\nowner: %@\nmessage: %@", fileName, fileContents, repo, owner, commitMessage);
#endif
    
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
    NSString *urlRequest;
    
    NSString *httpHeaderTokenString;
    
    if (token && token) {
        httpHeaderTokenString = [NSString stringWithFormat:@"%@=%@&%@=%@", kAccessToken, token, kTokenType, tokenType];
    } else return NO;
    
    
    NSDictionary *latestCommmit = [commitsForRepo objectAtIndex:0];
    
    NSString *shaForLatestCommit = [latestCommmit objectForKey:@"sha"];
    NSString *treeSHAForLatestCommit = [[latestCommmit objectForKey:@"tree"] objectForKey:@"sha"];
    
    // Update refs
    //    PATCH /repos/:owner/:repo/git/refs/:ref
    NSString *ref = @"refs/heads/master";
    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/%@?%@", kGitHubApiURL, owner, repo, ref, httpHeaderTokenString]; // master branch, for now.
    
    JSONObjectToPass = nil;
    [JSONObjectToPass setValue:[createdCommit objectForKey:@"sha"] forKey:@"sha"];
    [JSONObjectToPass setValue:@"false" forKey:@"force"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:JSONObjectToPass] options:0 error:nil]];
    
    AFJSONRequestOperation *referenceUpdateOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        referenceUpdate = JSON;
        NSLog(@"Reference successfully updated %@", JSON);
        success = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        error = error;
        NSLog(@"Reference update failed %@", JSON);
        success = NO;
    }];
    
//    [referenceUpdateOperation addDependency:createCommitOperation];
    [referenceUpdateOperation start];

    // Create commit
    //    POST /repos/:owner/:repo/git/commits
    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/commits?%@", kGitHubApiURL, owner, repo, httpHeaderTokenString];
    
    JSONObjectToPass = nil;
    [JSONObjectToPass setValue:commitMessage forKey:@"message"];
    [JSONObjectToPass setValue:[createdTree objectForKey:@"sha"] forKey:@"tree"];
    [JSONObjectToPass setValue:[NSArray arrayWithObjects:shaForLatestCommit, nil] forKey:@"parents"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:JSONObjectToPass] options:0 error:nil]];
    
    AFJSONRequestOperation *createCommitOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        createdCommit = JSON;
        NSLog(@"Commit created successfully %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        error = error;
        NSLog(@"ERror creating commit %@", error);
    }];
//    [createCommitOperation addDependency:createTreeOperation];
    [createCommitOperation start];
        
    
    // Create tree
    //    POST /repos/:owner/:repo/git/trees
    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/trees?%@", kGitHubApiURL, owner, repo, httpHeaderTokenString];
    
    JSONObjectToPass = nil;
    [JSONObjectToPass setValue:treeSHAForLatestCommit forKey:@"base_tree"];
    [JSONObjectToPass setValue:[NSDictionary dictionaryWithObjectsAndKeys:fileName, @"path", @"100644", @"mode",@"blob", @"type", createdBlobSHA, @"blob", nil] forKey:@"tree"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:JSONObjectToPass] options:0 error:nil]];
    
    
    AFJSONRequestOperation *createTreeOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        createdTree = JSON;
        NSLog(@"Tree created %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        error = error;
        NSLog(@"Error creating Tree %@", error);
    }];
//    [createTreeOperation addDependency:createBlobOperation];
    [createTreeOperation start];
    
    
    
    // Create blob
    //    POST /repos/:owner/:repo/git/blobs
    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/blobs?%@", kGitHubApiURL, owner, repo, httpHeaderTokenString];
    
    JSONObjectToPass = nil;
    [JSONObjectToPass setValue:fileContents forKey:@"content"];
    [JSONObjectToPass setValue:@"utf-8" forKey:@"encoding"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:JSONObjectToPass] options:0 error:nil]];
    
    AFJSONRequestOperation *createBlobOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        createdBlobSHA = [JSON objectForKey:@"sha"];
        NSLog(@"Blob created successfully = %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        error = error;
        NSLog(@"Error created blob %@", error);
    }];
//    [createBlobOperation addDependency:commitsOperation];
    [createBlobOperation start];
    
    
    NSLog(@"Token & TokenType recieved.\nHeaderTokenString : %@", httpHeaderTokenString);
    
    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/commits?%@", kGitHubApiURL, owner, repo, httpHeaderTokenString];
    
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    
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


    
    
    return success;
}


- (void)getAllCommitsForRepo:(NSDictionary *)repo {
    NSMutableDictionary *jsonInformation = [NSMutableDictionary dictionaryWithDictionary:repo];
    NSMutableURLRequest *request;
    NSDictionary *ownerData = [repo objectForKey:@"owner"];
    NSString *urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/commits?%@",
                            kGitHubApiURL, [ownerData objectForKey:@"login"], [repo objectForKey:@"repoName"], _httpHeaderTokenString];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [jsonInformation setValue:[JSON objectAtIndex:0] forKey:@"latest_commit"];
        [self createBlobForFile:jsonInformation];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        _error = error;
    }];
    [operation start];
}

- (void)createBlobForFile:(NSDictionary *)fileDictionary {
    NSMutableDictionary *jsonInformation = [NSMutableDictionary dictionaryWithDictionary:fileDictionary];
    NSMutableURLRequest *request;
    NSDictionary *ownerData = [fileDictionary objectForKey:@"owner"];
    NSString *urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/blobs?%@",
                            kGitHubApiURL, [ownerData objectForKey:@"login"], [fileDictionary objectForKey:@"repoName"], _httpHeaderTokenString];
    
    NSMutableDictionary *postInformation;
    [postInformation setValue:[fileDictionary objectForKey:@"newfilecontent"] forKey:@"content"];
    [postInformation setValue:@"utf-8" forKey:@"encoding"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:postInformation] options:0 error:nil]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [jsonInformation setValue:[JSON objectForKey:@"sha"] forKey:@"new_blob"];
        [self createTreeWithInfo:jsonInformation];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        _error = error;
    }];
    [operation start];
}

- (void)createTreeWithInfo:(NSDictionary *)info {
    NSMutableDictionary *jsonInformation = [NSMutableDictionary dictionaryWithDictionary:info];
    NSMutableURLRequest *request;
    NSDictionary *ownerData = [info objectForKey:@"owner"];
    NSString *urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/trees?%@",
                            kGitHubApiURL, [ownerData objectForKey:@"login"], [info objectForKey:@"repoName"], _httpHeaderTokenString];
    // because look at that selection, fuck that. Get it as a string.
    NSString *treeSHAForLatestCommit = [[[info objectForKey:@"lastest_commit"] objectForKey:@"tree"] objectForKey:@"sha"];
    
    NSMutableDictionary *postInformation;
    [postInformation setValue:treeSHAForLatestCommit forKey:@"base_tree"];
    [postInformation setValue:[NSDictionary dictionaryWithObjectsAndKeys:[info objectForKey:@"path"], @"path", @"100644", @"mode",@"blob", @"type", [info objectForKey:@"new_blob"], @"blob", nil] forKey:@"tree"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:postInformation] options:0 error:nil]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [jsonInformation setValue:JSON forKey:@"new_tree"];
        [self createTreeWithInfo:jsonInformation];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        _error = error;
    }];
    [operation start];
}

- (void)createCommitWithInfo:(NSDictionary *)info {
    NSMutableDictionary *jsonInformation = [NSMutableDictionary dictionaryWithDictionary:info];
    NSMutableURLRequest *request;
    NSDictionary *ownerData = [info objectForKey:@"owner"];
    NSString *urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/commits?%@",
                            kGitHubApiURL, [ownerData objectForKey:@"login"], [info objectForKey:@"repoName"], _httpHeaderTokenString];
    NSMutableDictionary *postInformation;
    [postInformation setValue:[info objectForKey:@"commit_message"] forKey:@"message"];
    [postInformation setValue:[[info objectForKey:@"new_tree"] objectForKey:@"sha"] forKey:@"tree"];
    [postInformation setValue:[NSArray arrayWithObjects:[[info objectForKey:@"last_commit"] objectForKey:@"sha"], nil] forKey:@"parents"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:postInformation] options:0 error:nil]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [jsonInformation setValue:JSON forKey:@"new_commit"];
        [self updateReferenceWithInfo:jsonInformation];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        _error = error;
    }];
    [operation start];
}

- (void)updateReferenceWithInfo:(NSDictionary *)info {
    NSMutableDictionary *jsonInformation = [NSMutableDictionary dictionaryWithDictionary:info];
    NSMutableURLRequest *request;
    NSDictionary *ownerData = [info objectForKey:@"owner"];
    NSString *urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/commits?%@",
                            kGitHubApiURL, [ownerData objectForKey:@"login"], [info objectForKey:@"repoName"], _httpHeaderTokenString];
    NSMutableDictionary *postInformation;
    [postInformation setValue:[info objectForKey:@"commit_message"] forKey:@"message"];
    [postInformation setValue:[[info objectForKey:@"new_tree"] objectForKey:@"sha"] forKey:@"tree"];
    [postInformation setValue:[NSArray arrayWithObjects:[[info objectForKey:@"last_commit"] objectForKey:@"sha"], nil] forKey:@"parents"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"PATCH"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:postInformation] options:0 error:nil]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [jsonInformation setValue:JSON forKey:@"new_commit"];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        _error = error;
    }];
    [operation start];
    /* TODO : this.
    // Update refs
    //    PATCH /repos/:owner/:repo/git/refs/:ref
    NSString *ref = @"refs/heads/master";
    urlRequest = [NSString stringWithFormat:@"%@repos/%@/%@/git/%@?%@", kGitHubApiURL, owner, repo, ref, httpHeaderTokenString]; // master branch, for now.
    
    JSONObjectToPass = nil;
    [JSONObjectToPass setValue:[createdCommit objectForKey:@"sha"] forKey:@"sha"];
    [JSONObjectToPass setValue:@"false" forKey:@"force"];
    
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization JSONObjectWithData:[NSDictionary dictionaryWithDictionary:JSONObjectToPass] options:0 error:nil]];
    
    AFJSONRequestOperation *referenceUpdateOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        referenceUpdate = JSON;
        NSLog(@"Reference successfully updated %@", JSON);
        success = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        error = error;
        NSLog(@"Reference update failed %@", JSON);
        success = NO;
    }];
    
    //    [referenceUpdateOperation addDependency:createCommitOperation];
    [referenceUpdateOperation start];*/
}






















/**********************************************************************************************/
@end
