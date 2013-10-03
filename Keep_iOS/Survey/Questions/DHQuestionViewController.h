//
//  DHQuestionViewController.h
//  Keep
//
//  Created by Sean Patno on 5/6/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DHSurveyLabelController.h"

@protocol QuestionViewDelegate <NSObject>

@optional
-(void) answerDidChange:(id)answer;

@end

@interface DHQuestionViewController : UIViewController
{

}

@property (nonatomic, strong) NSDictionary * question;
@property (nonatomic, strong) DHSurveyLabel * label;
@property (nonatomic, strong) DHSurveyLabelController * labelController;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, assign) id defaultValue;
@property (nonatomic, assign) id<QuestionViewDelegate> questionDelegate;

-(id) questionAnswer;
-(void) resizeQuestionView;
-(void) questionDidShow;
-(void) questionWillDisappear;
-(void) saveAnswer:(NSDictionary*) answers;

@end
