//
//  DataManager.m
//  Keep
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import "DataManager.h"

#import "XMLReader.h"
#import "KeepForm.h"
#import "AFNetworking.h"

@implementation DataManager

static DataManager* theManager;
@synthesize servers;
@synthesize storedForms;

+(DataManager*)instance
{
    if( theManager == nil )
    {
        theManager = [[DataManager alloc] init];
    }
    return theManager;
}

-(id) init
{
    self = [super init];
    if( self != nil ) {
        self.servers = [[NSMutableArray alloc] initWithCapacity:5];
        self.storedForms = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

-(void)saveDataToFilesystem
{
	NSDate *startTime = [NSDate date];
	BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:self.databasePath];
	if( success == NO )
	{
		NSLog(@"Failed to save the data.");
	}
	else
	{
		NSLog(@"Database saved.");
	}
	NSLog(@"Time to save database:%f seconds", -[startTime timeIntervalSinceNow] );
}

-(void) addServer:(KeepServer *)server atIndex:(NSInteger)index success:(void (^)(void))success failure:(void (^)(void))failure
{
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/formList", server.serverURL]];

    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSError * error;

        //need to escape & characters for dictionary conversion
        NSString * xml = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];

        NSDictionary * dict = [XMLReader dictionaryForXMLString:xml error:&error];

        if( error ) {

            [failure invoke];
            return;
        }

        server.forms = [[NSMutableArray alloc] init];

        NSDictionary * xformsDict = [dict objectForKey:@"xforms"];

        if( !xformsDict || [xformsDict isEqual:[NSNull null]] ) {
            //not a proper xforms server
            [failure invoke];

        } else {
            id xforms = [xformsDict objectForKey:@"xform"];

            if( [xforms isKindOfClass:[NSDictionary class]] ) {
                KeepForm * form = [[KeepForm alloc] init];
                form.description = [xforms objectForKey:@"descriptionText"];
                form.downloadURL = [xforms objectForKey:@"downloadUrl"];
                form.manifestURL = [xforms objectForKey:@"manifestUrl"];
                form.name = [xforms objectForKey:@"name"];
                form.formID = [xforms objectForKey:@"formID"];
                form.formType = [xforms objectForKey:@"type"];
                form.serverName = [NSString stringWithString:server.serverURL];

                [server.forms addObject:form];
            } else {
                for( NSDictionary * xform in xforms ) {

                    //NSLog(@"formL %@", xform);

                    KeepForm * form = [[KeepForm alloc] init];
                    form.description = [xform objectForKey:@"descriptionText"];
                    form.downloadURL = [xform objectForKey:@"downloadUrl"];
                    form.manifestURL = [xform objectForKey:@"manifestUrl"];
                    form.name = [xform objectForKey:@"name"];
                    form.formID = [xform objectForKey:@"formID"];
                    form.formType = [xform objectForKey:@"type"];
                    form.serverName = [NSString stringWithString:server.serverURL];

                    [server.forms addObject:form];
                }
            }
            
            if( index > 0 && index < [self.servers count] ) {
                [self.servers insertObject:server atIndex:index];
            } else {
                [self.servers addObject:server];
            }
            
            [success invoke];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError * error) {
        NSLog(@"failure to download: %@, %@", operation.responseString, error);

    }];

}


/*-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    NSError * error;

    //need to escape & characters for dictionary conversion
    xml = [xml stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];

    NSDictionary * dict = [XMLReader dictionaryForXMLString:xml error:&error];

    if( error ) {

        [addFailure invoke];
        return;
    }

    newServer.forms = [[NSMutableArray alloc] init];

    NSDictionary * xformsDict = [dict objectForKey:@"xforms"];

    if( !xformsDict || [xformsDict isEqual:[NSNull null]] ) {
        //not a proper xforms server
        [addFailure invoke];

    } else {
        id xforms = [xformsDict objectForKey:@"xform"];

        if( [xforms isKindOfClass:[NSDictionary class]] ) {
            KeepForm * form = [[ODKForm alloc] init];
            form.description = [xforms objectForKey:@"descriptionText"];
            form.downloadURL = [xforms objectForKey:@"downloadUrl"];
            form.manifestURL = [xforms objectForKey:@"manifestUrl"];
            form.name = [xforms objectForKey:@"name"];
            form.formID = [xforms objectForKey:@"formID"];
            form.formType = [xforms objectForKey:@"type"];
            form.serverName = [NSString stringWithString:newServer.serverURL];

            [newServer.forms addObject:form];
        } else {
            for( NSDictionary * xform in xforms ) {

                //NSLog(@"formL %@", xform);

                ODKForm * form = [[ODKForm alloc] init];
                form.description = [xform objectForKey:@"descriptionText"];
                form.downloadURL = [xform objectForKey:@"downloadUrl"];
                form.manifestURL = [xform objectForKey:@"manifestUrl"];
                form.name = [xform objectForKey:@"name"];
                form.formID = [xform objectForKey:@"formID"];
                form.formType = [xform objectForKey:@"type"];
                form.serverName = [NSString stringWithString:newServer.serverURL];

                [newServer.forms addObject:form];
            }
        }

        if( indexToAdd > 0 && indexToAdd < [self.servers count] ) {
            [self.servers insertObject:newServer atIndex:indexToAdd];
        } else {
            [self.servers addObject:newServer];
        }
        
        [addSuccess invoke];
    }
}*/

- (NSString *)databasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    return [documentsDirectory stringByAppendingPathComponent:@"ServerForms.db"];
}

-(void)loadDataFromFilesystem
{
	NSString *dbPath = [self databasePath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath])
    {
		//The file wasn't found.
    }
    else
    {
		NSDate *startTime = [NSDate date];

		DataManager *dataManager = [NSKeyedUnarchiver unarchiveObjectWithFile:dbPath];
		if( dataManager != nil )
		{
			self.servers = dataManager->servers;
            self.storedForms = dataManager->storedForms;
            if(self.servers == nil) {
                self.servers = [[NSMutableArray alloc] initWithCapacity:1];
            }

            if(self.storedForms == nil) {
                self.storedForms = [[NSMutableArray alloc] initWithCapacity:1];
            }
		}
		else
		{
			NSLog(@"failed to load data");
		}

		NSLog(@"Time to load database:%f seconds", -[startTime timeIntervalSinceNow] );
    }

}

-(KeepServer*) serverForName:(NSString *)serverName
{
    for( KeepServer * server in self.servers ) {
        if( [server.serverURL isEqualToString:serverName] ) {
            return server;
        }
    }
    return nil;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self.servers = [coder decodeObjectForKey:@"servers"];
    self.storedForms = [coder decodeObjectForKey:@"storedForms"];
   
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.servers forKey:@"servers"];
    [coder encodeObject:self.storedForms forKey:@"storedForm"];
}

@end
