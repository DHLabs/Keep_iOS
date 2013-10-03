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
#import "DHNetworkUtilities.h"
#import "XFormJSONConverter.h"

@interface FormDownloader ()
@end

@implementation FormDownloader


+(void) downloadXForm:(KeepForm *)form completion:(void (^)(void))completion failure:(void (^)(void)) failure
{
    [DHNetworkUtilities getStringAt:form.downloadURL success:^(NSString * string) {
        NSString  *mainPath = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:form.formID];
        [[NSFileManager defaultManager] createDirectoryAtPath:mainPath withIntermediateDirectories:YES attributes:nil error:nil];
        form.formPath = mainPath;

        form.questions = [[XFormJSONConverter JSONFormFromXMLString:string] objectForKey:@"children"];

        if( form.manifestURL && [form.manifestURL isKindOfClass:[NSString class]] ) {
            NSLog(@"download manifest: %@", form.manifestURL);
            [self downloadManifest:form completion:completion failure:failure];
        } else {
            NSLog(@"no manifest");
            [completion invoke];
        }
    } failure:^() {
        [SVProgressHUD dismiss];
    }];
}

+(void) downloadManifest:(KeepForm *) form completion:(void (^)(void))completion failure:(void (^)(void)) failure
{
    [DHNetworkUtilities getStringAt:form.manifestURL success:^(NSString * string) {
        NSError * error = nil;
        NSDictionary * dictionary = [XMLReader dictionaryForXMLString:string error:&error];

        if (error) {
            failure();
            NSLog(@"Error parsing manifest: %@", error);
        } else {
            NSArray * mediaFiles = [[dictionary objectForKey:@"manifest"] objectForKey:@"mediaFile"];

            if( [mediaFiles count] == 0 ) {
                [completion invoke];
            }

            int __block numDownloads = 0;

            for( NSDictionary * mediaDict in mediaFiles ) {

                NSString * download = [mediaDict objectForKey:@"downloadUrl"];
                NSString * filename = [mediaDict objectForKey:@"filename"];
                NSString* filePath=[form.formPath stringByAppendingPathComponent:filename];

                numDownloads++;
                //download the file
                [DHNetworkUtilities downloadFile:download to:filePath success:^(){
                    numDownloads--;

                    if( numDownloads == 0 ) {
                        [completion invoke];
                    }
                } failure:failure];
            }
        }
    } failure:^() {
        NSLog(@"download of manifest failed");
        [failure invoke];
    }];
}

@end
