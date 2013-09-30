//
//  KeepForm.m
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import "KeepForm.h"

#import "AFHTTPRequestOperation.h"

@implementation KeepForm

-(id) init
{
    self = [super init];
    if( self != 0 ) {
        self.registrants = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if( self != 0 )
	{
        self.downloadURL = [coder decodeObjectForKey:@"downloadURL"];
        self.name = [coder decodeObjectForKey:@"formName"];
        self.manifestURL = [coder decodeObjectForKey:@"manifestURL"];
        self.formID = [coder decodeObjectForKey:@"formID"];
        self.description = [coder decodeObjectForKey:@"description"];
        self.formPath = [coder decodeObjectForKey:@"formPath"];
        self.progress = [coder decodeObjectForKey:@"progress"];
        self.serverName = [coder decodeObjectForKey:@"serverName"];
        self.formType = [coder decodeObjectForKey:@"formType"];
        self.questions = [coder decodeObjectForKey:@"questions"];
        self.registrants = [coder decodeObjectForKey:@"registrants"];
        if( !self.registrants ) {
            self.registrants = [[NSMutableArray alloc] init];
        }
	}

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.manifestURL forKey:@"manifestURL"];
	[coder encodeObject:self.name forKey:@"formName"];
    [coder encodeObject:self.downloadURL forKey:@"downloadURL"];
    [coder encodeObject:self.formID forKey:@"formID"];
    [coder encodeObject:self.description forKey:@"description"];
    [coder encodeObject:self.formPath forKey:@"formPath"];
    [coder encodeObject:self.progress forKey:@"progress"];
    [coder encodeObject:self.serverName forKey:@"serverName"];
    [coder encodeObject:self.formType forKey:@"formType"];
    [coder encodeObject:self.questions forKey:@"questions"];
    [coder encodeObject:self.registrants forKey:@"registrants"];
}

@end
