//
//  FormDataTableViewController.m
//  Keep
//
//  Created by Sean Patno on 5/31/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "FormDataTableViewController.h"

#import "DHNetworkUtilities.h"
#import "SVProgressHUD.h"

@interface FormDataTableViewController ()
{
    NSMutableArray * jsonData;
}
@end

@implementation FormDataTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString * downloadUrl = self.form.downloadURL;
    downloadUrl = [downloadUrl stringByReplacingOccurrencesOfString:@"repos" withString:@"data"];
    downloadUrl = [downloadUrl stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
    downloadUrl = [downloadUrl stringByReplacingOccurrencesOfString:@"xform" withString:@"json"];
    downloadUrl = [downloadUrl stringByAppendingString:@"&key=574219063edc6cec0681e2c34e38e1dc"];

    //NSString * serverName = self.form.serverName;
   // NSLog(@"servername: %@", serverName);
   // NSLog(@"downloadurl: %@", downloadUrl);

    self.title = self.form.name;

    [self getData:downloadUrl];
}

-(void) getData:(NSString*) downloadURL
{

    NSURL *url;
    if( self.pid ) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&data__Barcode1=%@", downloadURL,self.pid]];
    } else {
        url = [NSURL URLWithString:downloadURL];
    }

    [SVProgressHUD showWithStatus:@"Downloading" maskType:SVProgressHUDMaskTypeClear];

    [DHNetworkUtilities getJSONAt:[url absoluteString] success:^(id JSON) {
        jsonData = [[NSMutableArray alloc] initWithCapacity:4];
        if( self.pid ) {
            for( NSDictionary * dict in [JSON objectForKey:@"data"] ) {
                if( [[[dict objectForKey:@"data"] objectForKey:@"Barcode1"] isEqualToString:self.pid] ) {
                    [jsonData addObject:dict];
                }
            }
        } else {
            jsonData = [JSON objectForKey:@"data"];
        }

        [self.tableView reloadData];
        [self.tableView reloadData];

        [SVProgressHUD dismiss];
    } failure:^() {
        [SVProgressHUD dismiss];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if( jsonData ) {
        return [jsonData count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSDictionary * datajson = [[jsonData objectAtIndex:indexPath.row] objectForKey:@"data"];

    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = [self getNumItems:datajson];

        NSDictionary * datajson = [[jsonData objectAtIndex:indexPath.row] objectForKey:@"data"];
        NSMutableString * label = [[NSMutableString alloc] initWithCapacity:0];
        [self buildString:label forData:datajson];

        CGSize size = [label sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(260, 999.0f) lineBreakMode:NSLineBreakByWordWrapping];

        UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, cell.frame.size.width - 10, size.height + 20)];

        textView.tag = 35;
        textView.userInteractionEnabled = NO;
        textView.font = [UIFont systemFontOfSize:16.0];
        textView.clipsToBounds = NO;
        cell.contentView.clipsToBounds = NO;
        cell.clipsToBounds = NO;
        textView.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:textView];
    }

    NSMutableString * label = [[NSMutableString alloc] initWithCapacity:0];
    [self buildString:label forData:datajson];

    UITextView * textView = (UITextView*)[cell.contentView viewWithTag:35];

    textView.text = label;

    return cell;
}

-(int) getNumItems:(NSDictionary*) dict
{
    int total = 0;
    for( id value in [dict allValues] ) {
        if( [value isKindOfClass:[NSDictionary class]] ) {
            total += [self getNumItems:value];
        } else {
            total++;
        }
    }
    return total;
}

-(void) buildString:(NSMutableString*)string forData:(NSDictionary*)data
{
    for( id key in [data allKeys] ) {
        [string appendFormat:@"%@: ", key];

        id value = [data objectForKey:key];
        if( [value isKindOfClass:[NSDictionary class]] ) {
            [string appendString:@"\n"];
            [self buildString:string forData:value];
        } else {
            [string appendFormat:@"%@\n", value];
        }
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( jsonData ) {
        if( [jsonData count] > 0 ) {

            NSDictionary * datajson = [[jsonData objectAtIndex:indexPath.row] objectForKey:@"data"];
            NSMutableString * label = [[NSMutableString alloc] initWithCapacity:0];
            [self buildString:label forData:datajson];

            CGSize size = [label sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(270, 999.0f) lineBreakMode:NSLineBreakByWordWrapping];

            return size.height + 20;
        }
    }
    return 44.0;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
