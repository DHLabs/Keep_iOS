//
//  KeepServer.m
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import "KeepServer.h"

@implementation KeepServer

-(id) init
{
    self = [super init];
    if( self != nil ) {
        self.forms = [[NSMutableArray alloc] initWithCapacity:1];
        self.storedForms = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if( self != 0 )
	{
        self.serverURL = [coder decodeObjectForKey:@"serverURL"];
        self.name = [coder decodeObjectForKey:@"serverName"];
        self.forms = [coder decodeObjectForKey:@"forms"];
        self.isKeep = [coder decodeBoolForKey:@"isKeep"];
        self.storedForms = [coder decodeObjectForKey:@"storedForms"];
        

        if(self.forms == nil) {
            self.forms = [[NSMutableArray alloc] initWithCapacity:1];
        }

        if(self.storedForms == nil) {
            self.storedForms = [[NSMutableArray alloc] initWithCapacity:1];
        }
	}

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.forms forKey:@"forms"];
	[coder encodeObject:self.name forKey:@"serverName"];
    [coder encodeObject:self.serverURL forKey:@"serverURL"];
    [coder encodeBool:self.isKeep forKey:@"isKeep"];
    [coder encodeObject:self.storedForms forKey:@"storedForms"];
}

@end
