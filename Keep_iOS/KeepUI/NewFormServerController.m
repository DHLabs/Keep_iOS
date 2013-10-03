//
//  NewFormServerController.m
//  iODK
//
//  Created by Sean Patno on 12/17/12.
//  Copyright (c) 2012 Sean Patno. All rights reserved.
//

#import "NewFormServerController.h"

#import "AFNetworking.h"
#import "DataManager.h"
#import "XMLReader.h"
#import "KeepForm.h"
#import "SVProgressHUD.h"
#import "BlockAlertView.h"

#define defaultServer @"http://keep.distributedhealth.org/bs/sean"//@"http://formhub.org/spatno"
//@"http://odk.distributedhealth.org/bs/sean"

@interface NewFormServerController () <UITextFieldDelegate>
{
    UITextField *serverNameField;
    UITextField *serverURLField;
}

+ (BOOL) validateUrl: (NSString *) candidate;

@end

@implementation NewFormServerController

-(void) submitServer
{
    //Validate fields

    NSString * serverName = serverNameField.text;
    if( (!serverName) || [serverName isEqualToString:@""] || [[serverName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] ) {

        [NewFormServerController showMessageOnlyAlert:@"Please write in a server name"];
        return;

    }

    KeepServer *server = [[KeepServer alloc] init];

    NSString * serverURL = [NSString stringWithFormat:@"%@/formList", serverURLField.text];
    NSString * otherServerURL;

    if( self.serverType == KeepServerType) {
        otherServerURL = [@"http://keep.distributedhealth.org/bs/" stringByAppendingString:serverURLField.text];
        server.isKeep = YES;
        serverURL = [@"http://keep.distributedhealth.org/bs/" stringByAppendingString:serverURL];
    } else if( self.serverType == FormHubServerType ) {
        otherServerURL = [@"https://formhub.org/" stringByAppendingString:serverURLField.text];
        serverURL = [@"https://formhub.org/" stringByAppendingString:serverURL];
    } else {
        otherServerURL = serverURLField.text;
    }

    for( KeepServer * theServer in [DataManager instance].servers  ) {
        if( [theServer.name isEqualToString:serverName] ) {
            [NewFormServerController showMessageOnlyAlert:@"That server name is already taken."];
            return;
        }

        if( [theServer.serverURL isEqualToString:otherServerURL] ) {
            [NewFormServerController showMessageOnlyAlert:@"That server URL is already is use."];
            return;
        }
    }

    NSLog(@"server url: %@", serverURL);

    if( ![NewFormServerController validateUrl:serverURL] ) {

        [NewFormServerController showMessageOnlyAlert:@"Please write in a valid server url"];        
        return;
    }
    
    server.serverURL = otherServerURL;
    server.name = serverName;

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[DataManager instance] addServer:server atIndex:-1 success:^() {

        [self dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD dismiss];
    } failure:^() {

        [NewFormServerController showMessage:nil withTitle:@"That is not a valid form server"];
        [SVProgressHUD dismiss];
    }];
    
}

+(void) showMessageOnlyAlert:(NSString *) message
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:nil message:message];

    [alert setDestructiveButtonWithTitle:@"OK" block:nil];

    [alert show];
}

+(void) showMessage:(NSString*)message withTitle:(NSString*)title
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:message];

    [alert setDestructiveButtonWithTitle:@"OK" block:nil];

    [alert show];
}

+ (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

-(void) cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) viewDidLoad
{
    [super viewDidLoad];

    self.title = @"New Server";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submitServer)];

    NSString * imageName = @"backgroundshort.png";
    if( [UIScreen mainScreen].bounds.size.height > 600 ) {
        NSLog(@"ipad");
        imageName = @"backgroundipad.png";
    } else if( [UIScreen mainScreen].bounds.size.height > 480 ) {
        NSLog(@"iphone 5");
        imageName = @"backgroundtall.png";
    } else {
        NSLog(@"iphone");
    }

    UIImage* image = [UIImage imageNamed:imageName];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView setFrame:self.view.frame];

    self.tableView.backgroundView = imageView;
    self.tableView.backgroundColor = [UIColor clearColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundiphone"]];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == serverNameField ) {
        [serverURLField becomeFirstResponder];
    } else {
        [self submitServer];
    }

    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(150, 10, 185, 30)];
        textField.adjustsFontSizeToFitWidth = YES;
        textField.textColor = [UIColor blackColor];
        if ([indexPath row] == 0) {
            textField.placeholder = @"My Server";
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.returnKeyType = UIReturnKeyNext;
            serverNameField = textField;
        }
        else {
            textField.placeholder = @"test_user";
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.returnKeyType = UIReturnKeyDone;
            serverURLField = textField;
        }
        textField.backgroundColor = [UIColor clearColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
        textField.textAlignment = NSTextAlignmentLeft;
        textField.tag = 0;
        textField.delegate = self;

        [textField setEnabled: YES];

        [cell addSubview:textField];

    }

    if ([indexPath row] == 0) {
        cell.textLabel.text = @"Server Name";
    }
    else {

        switch (self.serverType) {
            case KeepServerType:
                cell.textLabel.text = @"Account Name";
                break;
            case FormHubServerType:
                cell.textLabel.text = @"Account Name";
                break;
            default:
                cell.textLabel.text = @"Server URL";
                break;
        }

    }

    return cell;
}

@end
