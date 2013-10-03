//
//  Registrant.m
//  Keep
//
//  Created by Sean Patno on 8/8/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "Registrant.h"

#import "KeepForm.h"
#import "DHNetworkUtilities.h"

@implementation Registrant

-(id) init
{
    self = [super init];
    if( self != nil ) {
        self.registrantFormDatas = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if( self != 0 )
	{
        self.registrantData = [coder decodeObjectForKey:@"registrantData"];
        self.registrantFormDatas = [coder decodeObjectForKey:@"registrantFormDatas"];
        if( !self.registrantFormDatas ) {
            self.registrantFormDatas = [[NSMutableDictionary alloc] init];
        }
	}

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.registrantData forKey:@"registrantData"];
	[coder encodeObject:self.registrantFormDatas forKey:@"registrantFormDatas"];
}

-(void) downloadUserData:(NSArray *)forms completion:(void (^)(void))completionBlock
{
    int __block numDownloads = 0;
    for( KeepForm * form in forms ) {
        
        NSString * downloadUrl = [form.downloadURL stringByReplacingOccurrencesOfString:@"repos" withString:@"data"];
        downloadUrl = [downloadUrl stringByReplacingOccurrencesOfString:@"xform" withString:@"json"];
        downloadUrl = [downloadUrl stringByAppendingString:@"&key=574219063edc6cec0681e2c34e38e1dc"];
        downloadUrl = [downloadUrl stringByAppendingString:@"&data__Barcode1="];
        NSString * barcode = [self.registrantData objectForKey:@"Barcode1"];
        if( barcode ) {
            downloadUrl = [downloadUrl stringByAppendingString:[self.registrantData objectForKey:@"Barcode1"]];
        }

        [DHNetworkUtilities getJSONAt:downloadUrl success:^(id JSON) {
            NSMutableArray * retrievedData = [[NSMutableArray alloc] init];

            NSArray * jsonData = [JSON objectForKey:@"data"];
            for( NSDictionary * dict in jsonData ) {
                NSDictionary * data = [dict objectForKey:@"data"];
                if( [[data objectForKey:@"Barcode1"] isEqualToString:[self.registrantData objectForKey:@"Barcode1"]] ) {
                    [retrievedData addObject:data];
                }
            }
            [self.registrantFormDatas setObject:retrievedData forKey:form.name];

            numDownloads--;
            if( numDownloads == 0 ) {
                [completionBlock invoke];
            }
        } failure:^() {
            numDownloads--;
            if( numDownloads == 0 ) {
                [completionBlock invoke];
            }
        }];

        numDownloads++;
        
    }
}

@end
