//
//  FormDownloader.m
//  Keep
//
//  Created by Sean Patno on 7/29/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "FormDownloader.h"

#import "XMLReader.h"
#import "SVProgressHUD.h"
#import "AFHTTPRequestOperation.h"
#import "XFormJSONConverter.h"

@interface FormDownloader ()
{
    //void (^comletion)(void);
    //ODKForm * theForm;
   // int numDownloads;
}

@end

@implementation FormDownloader

+(void) downloadForm:(KeepForm *)form completion:(void (^)(void))completion failure:(void (^)(NSError * error)) failure
{
    NSMutableURLRequest* rq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:form.downloadURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:rq];

    //theForm = form;

    NSString  *mainPath = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:form.formID];

    [[NSFileManager defaultManager] createDirectoryAtPath:mainPath withIntermediateDirectories:YES attributes:nil error:nil];

    NSString* filePath=[mainPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml", form.formID]];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];

    //[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        //NSLog(@"%@", [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);

        form.formPath = mainPath;

        form.questions = [[XFormJSONConverter JSONFormFromXMLPath:filePath] objectForKey:@"children"];

        //[SVProgressHUD dismiss];

        if( form.manifestURL && [form.manifestURL isKindOfClass:[NSString class]] ) {
            NSLog(@"download manifest: %@", form.manifestURL);
            [self downloadManifest:form completion:completion failure:failure];
        } else {
            NSLog(@"no manifest");
            //[DHMiscUtilities showForm:form];
            [completion invoke];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"download of xform failed %@, %@", operation, error);

        //[SVProgressHUD showErrorWithStatus:@"Error"];
        failure( error );

    }];

    [operation start];
}

+(void) downloadManifest:(KeepForm *) form completion:(void (^)(void))completion failure:(void (^)(NSError * error)) failure
{
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:form.manifestURL]];
    NSLog(@"request: %@ url: %@",req, req.URL);
    //NSMutableDictionary * headers = []
    [req addValue:@"text/xml" forHTTPHeaderField:@"Accept"];

    AFHTTPRequestOperation * manifestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:req];

    NSString* filePath=[form.formPath stringByAppendingPathComponent:[NSString stringWithFormat:@"manifest.xml"]];
    manifestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];

    //[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];

    [manifestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        //NSLog(@"manifest: %@", [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);

        //parse manifest
        NSError * error = nil;
        NSDictionary * dictionary = [XMLReader dictionaryForXMLString: [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] error:&error];

        if (error) {
            failure( error );
            NSLog(@"Error parsing manifest: %@", error);
        } else {
            NSArray * mediaFiles = [[dictionary objectForKey:@"manifest"] objectForKey:@"mediaFile"];

            if( [mediaFiles count] == 0 ) {
                //[DHMiscUtilities showForm:form];
                [completion invoke];
            }

            int __block numDownloads = 0;

            for( NSDictionary * mediaDict in mediaFiles ) {

                NSString * download = [mediaDict objectForKey:@"downloadUrl"];
                NSString * filename = [mediaDict objectForKey:@"filename"];

                numDownloads++;
                //download the file
                [FormDownloader downloadFile:filename atUrl:download toPath:form.formPath completion:^() {

                    numDownloads--;
                    //[SVProgressHUD dismiss];

                    if( numDownloads == 0 ) {
                        //[SVProgressHUD dismiss];
                        //[DHMiscUtilities showForm:formToShow];
                        [completion invoke];
                    }
                 } failure:failure ];

            }
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"download of manifest failed");
        //[SVProgressHUD showErrorWithStatus:@"Error"];
        failure( error );
    }];

    [manifestOperation start];
}

+(void) downloadFile:(NSString*) filename atUrl:(NSString*)url toPath:(NSString*)path completion:(void (^)(void))completion failure:(void (^)(NSError * error)) failure
{
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation * manifestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:req];

    NSString* filePath=[path stringByAppendingPathComponent:filename];
    manifestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];

    [manifestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"download of media file: %@ was successful", filename);

        [completion invoke];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"download of media file:%@ failed", filename);

        [completion invoke];
    }];
    
    [manifestOperation start];
}

@end
