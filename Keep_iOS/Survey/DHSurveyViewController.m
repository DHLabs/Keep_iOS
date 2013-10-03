//
//  DHSurveyViewController.m
//  Keep
//
//  Created by Sean Patno on 5/6/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "DHSurveyViewController.h"

#import "DHxFormTool.h"
#import "DHFormUtilities.h"
#import "ODKForm.h"
#import "DHQuestionViewController.h"
#import "DHTriggerQuestionController.h"
#import "DHSelectQuestionController.h"
#import "DHTextQuestionController.h"
#import "BlockAlertView.h"
#import "StoredForm.h"
#import "SVProgressHUD.h"
#import "DataManager.h"
#import "DHMediaQuestionController.h"
#import "DHDateTimeQuestionControllerViewController.h"
//#import "DHBarcodeQuestionController.h"

@interface DHSurveyViewController ()<CLLocationManagerDelegate, QuestionViewDelegate>
{
    NSString * currentQuestionName;
    NSDictionary * currentQuestionDict;

    int currentQuestion;
    UIView * currentQuestionView;
    DHQuestionViewController * currentQuestionController;
    DHxFormTool * tool;
    BOOL hasTranslations;
    NSMutableDictionary * answers;
    UIBarButtonItem * leftBarButton;
    UIBarButtonItem * rightBarButton;
    
    NSString * translation;
    CLLocationManager * locationManager;
}

-(void) presentPreviousQuestion;
-(void) presentNextQuestion;
-(void) finishSurvey;
-(void) cancelSurvey;
-(BOOL) questionNeedsDisplay:(NSDictionary*) question;
-(DHSurveyLabel*) buildLabelForQuestion:(int)questionNum;
-(void) getPreviousRelevantQuestion;
-(void) handleEndMetadata;
-(void) handleStartMetadata;
-(NSDictionary*) questionForName:(NSString*) questionName;

@end

@implementation DHSurveyViewController

-(NSDictionary*) nextQuestion:(NSArray*) questionList
{
    NSArray * flatList = [DHFormUtilities flatQuestionList:questionList];

    int index = [flatList indexOfObject:currentQuestionDict];

    if( index < ([flatList count] - 1) ) {
        index++;
        return [flatList objectAtIndex:index];
    }
    
    return nil;
}

-(NSDictionary*) previousQuestion:(NSArray*) questionList
{
    NSArray * flatList = [DHFormUtilities flatQuestionList:questionList];

    int index = [flatList indexOfObject:currentQuestionDict];

    if( index < [flatList count] && index > 0 ) {
        index--;
        return [flatList objectAtIndex:index];
    }

    return nil;
}

-(NSArray*) flatQuestionList
{
    return [DHFormUtilities flatQuestionList:self.form.questions];
}

-(NSDictionary*) questionForName:(NSString*) questionName
{
    return [self questionForName:questionName inQuestionList:self.form.questions];
}

-(NSDictionary*) questionForName:(NSString*) questionName inQuestionList:(NSArray *)questionList
{
    for( NSDictionary * question in questionList ) {

        if( [[question objectForKey:@"name"] isEqualToString:questionName] ) {
            return question;
        }
        if( [[question objectForKey:@"type"] isEqualToString:@"group"] ) {
            NSDictionary * quest = [self questionForName:questionName inQuestionList:[question objectForKey:@"children"]];

            if( quest ) {
                return quest;
            }
        }
    }
    return nil;
}

-(void) dismissSurvey
{
    if( self.delegate ) {
        [self.delegate surveyDidCancel];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) saveAndDismiss
{
    StoredForm * storedForm = [[StoredForm alloc] init];
    storedForm.formData = answers;
    storedForm.xform = self.form;
    storedForm.isFinished = NO;
    [[[DataManager instance] serverForName:self.form.serverName].storedForms addObject:storedForm];
    [self dismissSurvey];
}

-(void) cancelSurvey
{
    //self.form.progress = answers;

    if( self.storedForm ) {
        self.storedForm.formData = answers;
        [self dismissSurvey];
    } else {        
        BlockAlertView * alert = [[BlockAlertView alloc] initWithTitle:nil message:@"Do you want to save this form?"];
        
        [alert setDestructiveButtonWithTitle:@"No" block:^() {
            [self dismissSurvey];
        }];

        [alert addButtonWithTitle:@"Yes" block:^() {
            [self saveAndDismiss];
        }];

        [alert show];
    }        
}

-(void) handleEndMetadata
{
    //TODO: handle metadata at end like phone id and End time

    for( NSDictionary * question in tool.questionList ) {
        NSString * meta = [question objectForKey:@"metadata"];
        if( meta ) {

            NSDateFormatter * format = [[NSDateFormatter alloc] init];
            format.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ";

            if( [meta isEqualToString:@"end"] ) {
                [answers setObject:[format stringFromDate:[NSDate date]] forKey:[question objectForKey:@"path"]];
            } else if( [meta isEqualToString:@"today"] ) {
                [answers setObject:[format stringFromDate:[NSDate date]] forKey:[question objectForKey:@"path"]];
            } else if( [meta isEqualToString:@"deviceid"] ) {
                //TODO: fixme
            }

            //today

            //deviceid

            //imei

            //phonenumber

        }
    }
}

-(void) handleStartMetadata
{
    for( NSDictionary * question in tool.questionList ) {
        NSString * meta = [question objectForKey:@"metadata"];
        if( meta && [meta isEqualToString:@"start"] ) {

            [answers setObject:[NSDate date] forKey:[question objectForKey:@"path"]];
        }
    }
}

-(void) finishSurvey
{

    [self handleEndMetadata];

    self.form.progress = nil;

    [DHFormUtilities submitForm:self.form withData:answers tool:tool completion:^(void) {
        [SVProgressHUD showSuccessWithStatus:@"Done"];

        if( self.storedForm ) {
            [[[DataManager instance] serverForName:self.form.serverName].storedForms removeObject:self.storedForm];
        }

        if( self.delegate ) {
            //[self.delegate for];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(){

        //save form for later upload
        if( self.storedForm ) {
            self.storedForm.isFinished = YES;
            self.storedForm.formData = answers;
        } else {
            StoredForm * storedForm = [[StoredForm alloc] init];
            storedForm.formData = answers;
            storedForm.xform = self.form;
            storedForm.isFinished = YES;
            [[[DataManager instance] serverForName:self.form.serverName].storedForms addObject:storedForm];
        }

        [SVProgressHUD showSuccessWithStatus:@"Done"];

        if( self.delegate ) {
            //formSubmitted = YES;
            //[formDelegate formWasSubmitted];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }

    } useProgress:YES];

    if( self.delegate ) {
        [self.delegate survey:self.form didFinishWithAnswers:answers];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL) questionNeedsDisplay:(NSDictionary *)question
{
    NSString * questionType = [question objectForKey:@"type"];

    if( [DHFormUtilities isQuestionRelevant:question forAnswers:answers isGroup:NO tool:tool] ) {

        if( [questionType isEqualToString:@"geopoint"] ) {

            if([CLLocationManager locationServicesEnabled]) {

                if( !locationManager ) {
                    locationManager = [[CLLocationManager alloc] init];
                    locationManager.delegate = self;
                    locationManager.distanceFilter = kCLDistanceFilterNone;
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                }

                [locationManager startUpdatingLocation];
            }
            return NO;
        }

        //is it's groups are relevant
        NSArray * groups = [question objectForKey:@"groups"];

        if( !groups ) {
            return YES;
        }
        NSString * groupPath = [NSString stringWithFormat:@"/%@", [question objectForKey:@"path_root"]];
        for( NSString * group in groups ) {
            groupPath = [groupPath stringByAppendingFormat:@"/%@", group];
            //get question for group
            for( NSDictionary * quest in tool.questionList ) {
                if( [[quest objectForKey:@"path"] isEqualToString:groupPath] ) {
                    if( ![DHFormUtilities isQuestionRelevant:quest forAnswers:answers isGroup:YES tool:tool] ) {
                        return NO;
                    }
                    break;
                }
            }
        }

        return YES;

    } else {
        return NO;
    }
}

-(DHSurveyLabel*) getLabelForDict:(id)label
{
    DHSurveyLabel * surveyLabel = [[DHSurveyLabel alloc] init];
    surveyLabel.labelString = @"";
    if( [label isKindOfClass:[NSString class]] ) {
        surveyLabel.labelString = label;
    } else {
        NSString * ref = [label objectForKey:@"ref"];
        if( ref ) {
            //itext stuff
            NSString * iTextPath = [ref stringByReplacingOccurrencesOfString:@"jr:itext(" withString:@""];
            iTextPath = [iTextPath stringByReplacingOccurrencesOfString:@"'" withString:@""];
            iTextPath = [iTextPath stringByReplacingOccurrencesOfString:@")" withString:@""];

            NSDictionary * itext = [[tool.translateDictionary objectForKey:translation] objectForKey:iTextPath];

            //NSLog(@"itext: %@", itext);

            id string = [itext objectForKey:@"string"];
            if( [string isKindOfClass:[NSString class]] ) {
                surveyLabel.labelString = string;
            } else if( [string isKindOfClass:[NSArray class]] ) {
                surveyLabel.labelString = @"";
                for( NSDictionary * dict in string ) {
                    surveyLabel.labelString = [surveyLabel.labelString stringByAppendingString:[self getStringForDict:dict]];
                }
            }else {
                NSDictionary *output = [string objectForKey:@"output"];
                if( output ) {
                    NSString *startText = [output objectForKey:@"text"];
                    NSString *valueString = [answers objectForKey:[output objectForKey:@"value"]];
                    if( !valueString ) {
                        valueString = @"";
                    }
                    surveyLabel.labelString = [NSString stringWithFormat:@"%@ %@",startText, valueString];
                }
                
                if( [string objectForKey:@"text"] ) {
                    surveyLabel.labelString = [surveyLabel.labelString stringByAppendingString:[string objectForKey:@"text"]];
                }                
            }

            surveyLabel.imagePath = [itext objectForKey:@"image"];
            if( surveyLabel.imagePath ) {
                surveyLabel.imagePath = [self.form.formPath stringByAppendingPathComponent:surveyLabel.imagePath];
            }

            surveyLabel.audioPath = [itext objectForKey:@"audio"];
            if( surveyLabel.audioPath ) {
                surveyLabel.audioPath = [self.form.formPath stringByAppendingPathComponent:surveyLabel.audioPath];
            }

            //NSLog(@"label string: %@ class:%@", surveyLabel.labelString, [surveyLabel.labelString class]);

        } else {
            NSDictionary *output = [label objectForKey:@"output"];
            if( output ) {
                NSString *startText = [output objectForKey:@"text"];
                NSString *valueString = [answers objectForKey:[output objectForKey:@"value"]];
                if( !valueString ) {
                    valueString = @"";
                }
                surveyLabel.labelString = [NSString stringWithFormat:@"%@ %@",startText, valueString];
            }

            if( [label objectForKey:@"text"] ) {
                surveyLabel.labelString = [surveyLabel.labelString stringByAppendingString:[label objectForKey:@"text"]];
            }
        }
    }
    return surveyLabel;
}

-(NSString*) getStringForDict:(NSDictionary *)dict
{
    NSString * stringTOReturn = @"";

    NSDictionary *output = [dict objectForKey:@"output"];
    if( output ) {
        NSString *startText = [output objectForKey:@"text"];
        NSString *valueString = [answers objectForKey:[output objectForKey:@"value"]];
        if( !valueString ) {
            valueString = @"";
        }
        stringTOReturn = [NSString stringWithFormat:@"%@ %@",startText, valueString];
    }

    if( [dict objectForKey:@"text"] ) {
        stringTOReturn = [stringTOReturn stringByAppendingString:[dict objectForKey:@"text"]];
    }

    return stringTOReturn;
}

-(DHSurveyLabel*) buildLabelForQuestion:(int)questionNum
{
    id label = [[tool.questionList objectAtIndex:questionNum] objectForKey:@"label"];

    return [self getLabelForDict:label];
}

-(void) answerDidChange:(id)answer
{
    NSDictionary * question = [tool.questionList objectAtIndex:currentQuestion];
    [answers setObject:answer forKey:[question objectForKey:@"path"]];
}

-(void) presentNextQuestion
{
    NSLog(@"present next question");

    if( currentQuestion == [tool.questionList count] ) {
        return;
    }

    if( currentQuestion > -1 ) {
        id questionAnswer = [currentQuestionController questionAnswer];
        NSDictionary * question = [tool.questionList objectAtIndex:currentQuestion];

        if( questionAnswer ) {
            //check question constraint
            [answers setObject:questionAnswer forKey:[question objectForKey:@"path"]];

            if( ![DHFormUtilities doesQuestionPassConstraint:question forAnswers:answers] ) {

                NSLog(@"doesn't pass constraint");

                NSString * constraintMessage = [question objectForKey:@"constraint_message"];
                if( !constraintMessage ) {
                    constraintMessage = @"That answer is invalid.";
                }

                BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Sorry" message:constraintMessage];
                [alert setDestructiveButtonWithTitle:@"OK" block:nil];
                [alert show];
                
                return;
            }
        } else {
            if( [DHFormUtilities isQuestionRequired:question] ) {
                BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Sorry" message:@"This question is required"];
                [alert setDestructiveButtonWithTitle:@"OK" block:nil];
                [alert show];
                NSLog(@"question is required");
                return;
            }
        }
    } else {
        if( hasTranslations ) {

            if( currentQuestionController.questionAnswer ) {
                translation = currentQuestionController.questionAnswer;
            } else {
                BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Sorry" message:@"This question is required"];
                [alert setDestructiveButtonWithTitle:@"OK" block:nil];
                [alert show];
                return;
            }
        }
    }

    //iterate through until you find next relevant question
    currentQuestion++;
    if( currentQuestion < [tool.questionList count] ) {
        while (![self questionNeedsDisplay:[tool.questionList objectAtIndex:currentQuestion]]) {
            currentQuestion++;
            if( currentQuestion == [tool.questionList count] ) {
                break;
            }
        }
    }

    NSLog(@"presenting question: %d", currentQuestion);

    if( currentQuestion == [tool.questionList count] ) {
        //survey complete: show submission page

        //TODO: fixme
        UIView * nextQuestionView = [[UIView alloc] initWithFrame:[self nextQuestionRect]];
        nextQuestionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:nextQuestionView];

        CGFloat offsetY = 0;

        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {

        } else {
            offsetY = 60;
        }

        UIButton * submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        submitButton.frame = CGRectMake(self.view.frame.size.width / 2 - 140, 20.0 + offsetY, 280.0, 60.0);
        submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
        submitButton.titleLabel.text = @"Submit Form";
        [submitButton setTitle:@"Submit Survey" forState:UIControlStateNormal];
        [submitButton addTarget:self action:@selector(finishSurvey) forControlEvents:UIControlEventTouchUpInside];
        [nextQuestionView addSubview:submitButton];

        UIButton * saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        saveButton.frame = CGRectMake(self.view.frame.size.width / 2 - 140, 120.0 + offsetY, 280.0, 60.0);
        saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
        saveButton.titleLabel.text = @"Save and Quit";
        [saveButton setTitle:@"Save and Quit" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveAndDismiss) forControlEvents:UIControlEventTouchUpInside];
        [nextQuestionView addSubview:saveButton];

        [self disableButtons];

        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^(){

                             nextQuestionView.frame = [self currentQuestionRect];
                             currentQuestionView.frame = [self prevQuestionRect];

                         }completion:^(BOOL finished){

                             [currentQuestionView removeFromSuperview];

                             currentQuestionView = nextQuestionView;
                             currentQuestionController = nil;
                             self.navigationItem.rightBarButtonItem = nil;
                             [self enableButtons];
                             
                         }];
        
    } else {
        UIView * nextQuestionView = [[UIView alloc] initWithFrame:[self nextQuestionRect]];
        nextQuestionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:nextQuestionView];
        DHQuestionViewController * nextQuestionController = [self getViewForQuestion:currentQuestion];
        nextQuestionController.defaultValue = [answers objectForKey:[[tool.questionList objectAtIndex:currentQuestion] objectForKey:@"path"]];
        [nextQuestionView addSubview:nextQuestionController.view];

        [currentQuestionController questionWillDisappear];
        [self disableButtons];

        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^(){

                             nextQuestionView.frame = [self currentQuestionRect];
                             currentQuestionView.frame = [self prevQuestionRect];

                         }completion:^(BOOL finished){

                             [currentQuestionView removeFromSuperview];

                             currentQuestionView = nextQuestionView;
                             currentQuestionController = nextQuestionController;

                             if( currentQuestion > 0 ) {
                                 [leftBarButton setAction:@selector(presentPreviousQuestion)];
                                 leftBarButton.title = @"Back";
                             }

                             [self enableButtons];
                             [currentQuestionController questionDidShow];
                             
                         }];
    }
    
}

-(void)getPreviousRelevantQuestion
{
    currentQuestion--;
    if( currentQuestion < 0 || currentQuestion > ([tool.questionList count] - 1) ) {
        return;
    }

    while( ![self questionNeedsDisplay:[tool.questionList objectAtIndex:currentQuestion]] ) {
        currentQuestion--;
        if( currentQuestion < 0 || currentQuestion > ([tool.questionList count] - 1) ) {
            return;
        }
    }
}

-(void) presentPreviousQuestion
{
    
    if( currentQuestion > [tool.questionList count] - 1 ) {
        self.navigationItem.rightBarButtonItem = rightBarButton;
    } else {
        id questionAnswer = [currentQuestionController questionAnswer];
        NSDictionary * question = [tool.questionList objectAtIndex:currentQuestion];

        if( questionAnswer ) {
            [answers setObject:questionAnswer forKey:[question objectForKey:@"path"]];
        }
    }

    [self getPreviousRelevantQuestion];
    if( currentQuestion < 0 || currentQuestion > ([tool.questionList count] - 1) ) {
        [self cancelSurvey];
        return;
    }

    UIView * prevQuestionView = [[UIView alloc] initWithFrame:[self prevQuestionRect]];
    prevQuestionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:prevQuestionView];
    DHQuestionViewController * prevQuestionController = [self getViewForQuestion:currentQuestion];
    prevQuestionController.defaultValue = [answers objectForKey:[[tool.questionList objectAtIndex:currentQuestion] objectForKey:@"path"]];
    [prevQuestionView addSubview:prevQuestionController.view];

    [self disableButtons];
    [currentQuestionController questionWillDisappear];

    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^(){

                         prevQuestionView.frame = [self currentQuestionRect];
                         currentQuestionView.frame = [self nextQuestionRect];

                     }completion:^(BOOL finished){

                         [currentQuestionView removeFromSuperview];

                         currentQuestionView = prevQuestionView;
                         currentQuestionController = prevQuestionController;

                         if( currentQuestion == 0 ) {
                             [leftBarButton setAction:@selector(cancelSurvey)];
                             leftBarButton.title = @"Cancel";
                         } else if( currentQuestion == ( [tool.questionList count] -1 ) ) {
                             self.navigationItem.rightBarButtonItem = rightBarButton;
                         }

                         [self enableButtons];
                         [currentQuestionController questionDidShow];

                     }];
}

-(DHQuestionViewController*) getViewForQuestion:(int) questionNum
{
    DHQuestionViewController * questionController;
    NSDictionary * question = [tool.questionList objectAtIndex:questionNum];
    NSString* typeString = [question objectForKey:@"type"];

    ///NSLog(@"getting view for question: %@", question);

    //NSLog(@"type: %@", typeString);

    if( !typeString ) {

        //acknowledge does not have a type string, do any others?

        //TODO: acknowledge, fixme

    } else if ([typeString isEqualToString:@"int"]) {

        NSLog(@"int question");
        questionController = [[DHTextQuestionController alloc] init];
        ((DHTextQuestionController*)questionController).afterDecimal = 0;
        ((DHTextQuestionController*)questionController).keyboardType = UIKeyboardTypeNumberPad;
        ((DHTextQuestionController*)questionController).isNumeric = YES;
        
    } else if ([typeString isEqualToString:@"text"]) {

        NSLog(@"test question");
        questionController = [[DHTextQuestionController alloc] init];
        
    } else if ([typeString isEqualToString:@"string"]) {

        NSLog(@"note question");
        //check if readonly
        BOOL readOnly = NO;
        if([[question allKeys] containsObject:@"readonly"])
        {
            //readOnly = [self readOnlyFromString:[question objectForKey:@"readonly"]];
            readOnly = YES;
        }

        if( readOnly ) {
            questionController = [[DHQuestionViewController alloc] init];
        } else {
            questionController = [[DHTextQuestionController alloc] init];
        }

    } else if ([typeString isEqualToString:@"decimal"]) {

        NSLog(@"decimal question");
        questionController = [[DHTextQuestionController alloc] init];
        ((DHTextQuestionController*)questionController).afterDecimal = 4;
        ((DHTextQuestionController*)questionController).keyboardType = UIKeyboardTypeDecimalPad;
        ((DHTextQuestionController*)questionController).isNumeric = YES;

    } else if ([typeString isEqualToString:@"select1"] || [typeString isEqualToString:@"select"]) {

        NSLog(@"select question");
        NSMutableArray * optionArray = [NSMutableArray array];
        NSMutableArray * answerArray = [NSMutableArray array];
        for( NSDictionary * dict in [question objectForKey:@"options"] ) {

            [answerArray addObject:[dict objectForKey:@"value"]];

            DHSurveyLabel * optionLabel = [[DHSurveyLabel alloc] init];
            optionLabel =  [self getLabelForDict:[dict objectForKey:@"label"]];
            [optionArray addObject:optionLabel];
        }

        questionController = [[DHSelectQuestionController alloc] init];
        ((DHSelectQuestionController*)questionController).selectAnswers = answerArray;
        ((DHSelectQuestionController*)questionController).selectLabels = optionArray;

        if (![typeString isEqualToString:@"select1"] ) {
            ((DHSelectQuestionController*)questionController).allowMultiple = YES;
        }
    } else if ([typeString isEqualToString:@"binary"]) {

        questionController = [[DHMediaQuestionController alloc] init];
        ((DHMediaQuestionController*)questionController).path = self.form.formPath;
        ((DHMediaQuestionController*)questionController).controller = self;
        NSString * mediaType = [question objectForKey:@"mediatype"];

        if( [mediaType isEqualToString:@"image/*"] ) {
            ((DHMediaQuestionController*)questionController).mediaType = 1;
        } else if( [mediaType isEqualToString:@"video/*"] )  {
            ((DHMediaQuestionController*)questionController).mediaType = 2;
        } else if( [mediaType isEqualToString:@"audio/*"] )  {
            ((DHMediaQuestionController*)questionController).mediaType = 3;
        } else {
            NSLog(@"no media Type!!!: %@", mediaType);
        }

    } else if ([typeString isEqualToString:@"barcode"]) {

        questionController = [[DHBarcodeQuestionController alloc] init];

    } else if ([typeString isEqualToString:@"date"]) {
        questionController = [[DHDateTimeQuestionControllerViewController alloc] init];
        ((DHDateTimeQuestionControllerViewController*) questionController).pickerMode = UIDatePickerModeDate;
    } else if ([typeString isEqualToString:@"dateTime"]) {
        questionController = [[DHDateTimeQuestionControllerViewController alloc] init];
        ((DHDateTimeQuestionControllerViewController*) questionController).pickerMode = UIDatePickerModeDateAndTime;
    } else if ([typeString isEqualToString:@"time"]) {
        questionController = [[DHDateTimeQuestionControllerViewController alloc] init];
        ((DHDateTimeQuestionControllerViewController*) questionController).pickerMode = UIDatePickerModeTime;
    } else if( [typeString isEqualToString:@"trigger"] ) {
        NSLog(@"trigger: do something sean");
        questionController = [[DHTriggerQuestionController alloc] init];
    }

    //set the question label
    questionController.label = [self buildLabelForQuestion:questionNum];
    questionController.questionDelegate = self;

    //NSLog(@"label string: %@ class: %@", questionController.label.labelString, [questionController.label.labelString class]);

    return questionController;
}

-(void) disableButtons
{
    leftBarButton.enabled = NO;
    rightBarButton.enabled = NO;
}

-(void) enableButtons
{
    leftBarButton.enabled = YES;
    rightBarButton.enabled = YES;
}

-(void) loadView
{
    CGRect mainScreen = [UIScreen mainScreen].bounds;

    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 64.0, mainScreen.size.width, mainScreen.size.height - 64.0)];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundiphone"]];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

-(CGRect) prevQuestionRect
{
    return CGRectMake(self.view.frame.origin.x - self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(CGRect) nextQuestionRect
{
    return CGRectMake(self.view.frame.origin.x + self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(CGRect) currentQuestionRect
{
    return CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    if( self.form.progress ) {
        answers = [[NSMutableDictionary alloc] initWithDictionary:self.form.progress];
    } else {
        answers = [[NSMutableDictionary alloc] init];
    }    

    leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSurvey)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(presentNextQuestion)];
    self.navigationItem.rightBarButtonItem = rightBarButton;

    tool = [[DHxFormTool alloc] init];
    NSString* filePath=[self.form.formPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml", self.form.formID]];
    [tool loadWithPath:filePath];
    [tool parseBindOrder];
    [tool parseInstanceDictionary];
    [tool parseBody];

    //NSLog(@"question list: %@", tool.questionList);

    self.title = tool.xformTitleString;

    UISwipeGestureRecognizer * leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(presentNextQuestion)];
    leftSwipeGesture.numberOfTouchesRequired = 1;
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeGesture];

    UISwipeGestureRecognizer * rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(presentPreviousQuestion)];
    rightSwipeGesture.numberOfTouchesRequired = 1;
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGesture];

    currentQuestionView = [[UIView alloc] initWithFrame:[self currentQuestionRect]];
    currentQuestionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:currentQuestionView];

    currentQuestion = -1;

    //use extra negative question for translation choosing
    if( [[tool.translateDictionary allKeys] count] > 1 ) {

        NSMutableArray * optionArray = [NSMutableArray array];
        NSMutableArray * answerArray = [NSMutableArray array];
        for( NSString * key in [tool.translateDictionary allKeys] ) {

            [answerArray addObject:key];

            DHSurveyLabel * optionLabel = [[DHSurveyLabel alloc] init];
            optionLabel.labelString = key;
            [optionArray addObject:optionLabel];
        }

        DHSelectQuestionController * questionController = [[DHSelectQuestionController alloc] init];
        questionController.selectAnswers = answerArray;
        questionController.selectLabels = optionArray;

        DHSurveyLabel * translateLabel = [[DHSurveyLabel alloc] init];
        translateLabel.labelString = @"Please select a language";
        questionController.label = translateLabel;

        UIView * nextQuestionView = [[UIView alloc] initWithFrame:[self nextQuestionRect]];
        nextQuestionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:nextQuestionView];
        [nextQuestionView addSubview:questionController.view];
        [self disableButtons];

        hasTranslations = YES;

        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^(){
                             nextQuestionView.frame = [self currentQuestionRect];
                             currentQuestionView.frame = [self prevQuestionRect];
                         }completion:^(BOOL finished){
                             [currentQuestionView removeFromSuperview];
                             currentQuestionView = nextQuestionView;
                             currentQuestionController = questionController;
                             [self enableButtons];
                         }];
    } else {
        if([[tool.translateDictionary allKeys] count] == 1){
            translation = [[tool.translateDictionary allKeys] objectAtIndex:0];
        }
        
        [self presentNextQuestion];
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
