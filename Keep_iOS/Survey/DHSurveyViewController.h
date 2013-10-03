//
//  DHSurveyViewController.h
//  Keep
//
//  Created by Sean Patno on 5/6/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ODKForm.h"
#import "StoredForm.h"

@protocol DHSurveyDelegate <NSObject>

-(void) surveyDidCancel;
-(void) survey:(ODKForm*) survey didFinishWithAnswers:(NSDictionary*)answers;

@end

@interface DHSurveyViewController : UIViewController

@property (nonatomic, strong) ODKForm * form;
@property (nonatomic, strong) StoredForm * storedForm;
@property (nonatomic, assign) id<DHSurveyDelegate> delegate;

@end
