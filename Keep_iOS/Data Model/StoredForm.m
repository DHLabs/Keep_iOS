//
//  StoredForm.m
//  Keep
//
//  Created by Sean Patno on 4/29/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "StoredForm.h"

@implementation StoredForm

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if( self != 0 )
	{
        self.formData = [coder decodeObjectForKey:@"formData"];
        self.xform = [coder decodeObjectForKey:@"xform"];
        self.isFinished = [coder decodeObjectForKey:@"isFinished"];
	}

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.formData forKey:@"formData"];
	[coder encodeObject:self.xform forKey:@"xform"];
    [coder encodeBool:self.isFinished forKey:@"isFinished"];
}

@end
