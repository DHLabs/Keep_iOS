//
//  DHNetworkUtilities.m
//  Keep
//
//  Created by Sean Patno on 5/15/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "DHNetworkUtilities.h"

#import "AFHTTPRequestOperation.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@implementation DHNetworkUtilities

+(void) getJSONAt:(NSString *)url success:(void (^)(id))success failure:(void (^)(void))failure
{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        success(responseObject);

    } failure:^(AFHTTPRequestOperation *operation, NSError * error) {
        NSLog(@"failure to download: %@, %@", operation.responseString, error);
        [SVProgressHUD dismiss];
    }];
}

+(void) getStringAt:(NSString *)url success:(void (^)(NSString*))success failure:(void (^)(void))failure
{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString * string = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        success( string );

    } failure:^(AFHTTPRequestOperation *operation, NSError * error) {
        NSLog(@"failure to download: %@, %@", operation.responseString, error);
        [failure invoke];
    }];
}

//TODO: These likely need redoing possibly to account for AFNetworking 2.0

+(void) downloadXML:(NSString*)url to:(NSString*)filepath success:(void(^)(void))success failure:(void(^)(void)) failure
{
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSLog(@"request: %@ url: %@",req, req.URL);
    [req addValue:@"text/xml" forHTTPHeaderField:@"Accept"];

    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];

    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filepath append:NO];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [success invoke];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [failure invoke];
    }];

    [operation start];
}

+(void) downloadFile:(NSString*)url to:(NSString*)filepath success:(void(^)(void))success failure:(void(^)(void)) failure
{
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation * manifestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:req];

    manifestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:filepath append:NO];

    [manifestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [success invoke];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [failure invoke];
    }];
    
    [manifestOperation start];
}

@end
