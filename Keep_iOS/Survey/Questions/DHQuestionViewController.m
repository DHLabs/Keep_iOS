//
//  DHQuestionViewController.m
//  Keep
//
//  Created by Sean Patno on 5/6/13.
//  Copyright (c) Sean Patno. All rights reserved.
//

#import "DHQuestionViewController.h"

@interface DHQuestionViewController ()

@end

@implementation DHQuestionViewController

-(void) loadView
{
    CGRect mainScreen = [UIScreen mainScreen].bounds;

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, mainScreen.size.width, mainScreen.size.height - 64.0)];
    } else {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 64.0, mainScreen.size.width, mainScreen.size.height - 64.0)];
    }

    //self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, mainScreen.size.width, mainScreen.size.height - 64.0)];
    self.view.backgroundColor = [UIColor clearColor];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.scrollView];
}

-(id) questionAnswer
{
    //implement in subclasses
    return nil;
}

-(void) saveAnswer:(NSDictionary *)answers
{
    id answer = [self questionAnswer];

    if( [answer isKindOfClass:[NSArray class]] ) {

    } else {
        NSString * questionPath = [self.question objectForKey:@"path"];
    }
}

-(void) resizeQuestionView
{
    CGFloat height = 0;

    for( UIView * view in self.scrollView.subviews ) {
        height += view.frame.size.height + 10.0;
    }

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
}

-(void) questionDidShow
{

}

-(void) questionWillDisappear
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    //TODO: build label from question

    self.labelController = [[DHSurveyLabelController alloc] init];
    self.labelController.label = self.label;

    [self.scrollView addSubview:self.labelController.view];

    [self resizeQuestionView];

}


@end
