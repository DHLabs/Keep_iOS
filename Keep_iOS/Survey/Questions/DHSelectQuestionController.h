//
//  DHSelectQuestionController.h
//  Keep
//
//  Created by Sean Patno on 5/6/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DHQuestionViewController.h"

@interface DHSelectQuestionController : DHQuestionViewController

@property (nonatomic, assign) BOOL allowMultiple;
@property (nonatomic, retain) NSArray * selectLabels;
@property (nonatomic, retain) NSArray * selectAnswers;

@end
