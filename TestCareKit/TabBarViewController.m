//
//  TabBarViewController.m
//  TestCareKit
//
//  Created by jing on 4/8/17.
//  Copyright © 2017 jing. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController (){
    OCKCarePlanStore *carePlanStore;
    
    OCKCareCardViewController *careCardVC;
    OCKSymptomTrackerViewController *symptomTrackerVC;
    OCKInsightsViewController *insightVC;
}


@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commandInitStore];
    [self commandAddActvity];
    [self commandAddAssessmentActivity];
    [self commandReadData];
    
    
    
    //CareCard
    careCardVC = [[OCKCareCardViewController alloc]initWithCarePlanStore:carePlanStore];
    careCardVC.title = @"CareCard";
    careCardVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:careCardVC.title image:[UIImage imageNamed:@"carecard"] selectedImage:[UIImage imageNamed:@"carecard-filled"]];
    UINavigationController *navCareCard = [[UINavigationController alloc]initWithRootViewController:careCardVC];
    
    
    //SymptomTracker
    symptomTrackerVC = [[OCKSymptomTrackerViewController alloc]initWithCarePlanStore:carePlanStore];
    symptomTrackerVC.delegate = self;
    symptomTrackerVC.title = @"Symptoms";
    symptomTrackerVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:symptomTrackerVC.title image:[UIImage imageNamed:@"symptoms"] selectedImage:[UIImage imageNamed:@"symptoms-filled"]];
    UINavigationController *navSymptomTracker = [[UINavigationController alloc]initWithRootViewController:symptomTrackerVC];
    
    
    //Insights
    OCKMessageItem *message = [[OCKMessageItem alloc]initWithTitle:@"Medication Adherence" text:@"Your medication adherence was 100% last week." tintColor:[UIColor purpleColor] messageType:OCKMessageItemTypeTip];
    OCKBarSeries *barPainSeries = [[OCKBarSeries alloc]initWithTitle:@"Pain" values:@[@1,@2,@4,@6,@3,@1,@1] valueLabels:@[@"1",@"2",@"4",@"6",@"3",@"1",@"1"] tintColor:[UIColor brownColor]];
    OCKBarSeries *barMedicationSeries = [[OCKBarSeries alloc]initWithTitle:@"Medication" values:@[@5,@2,@4,@1,@3,@1,@1] valueLabels:@[@"5",@"2",@"4",@"1",@"3",@"1",@"1"] tintColor:[UIColor blueColor]];
    OCKBarChart *barChart = [[OCKBarChart alloc]initWithTitle:@"Back Pain" text:nil tintColor:[UIColor blueColor] axisTitles:@[@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun"] axisSubtitles:@[@"4/1",@"4/2",@"4/3",@"4/4",@"4/5",@"4/6",@"4/7"] dataSeries:@[barPainSeries, barMedicationSeries]];
    insightVC = [[OCKInsightsViewController alloc]initWithInsightItems:@[message, barChart] headerTitle:@"Weekly Chart" headerSubtitle:nil];
    insightVC.title = @"Insights";
    insightVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:insightVC.title image:[UIImage imageNamed:@"insights"] selectedImage:[UIImage imageNamed:@"insights-filled"]];
    UINavigationController *navInsights = [[UINavigationController alloc]initWithRootViewController:insightVC];
    
    
    
    //Contact
    OCKContact *contact = [[OCKContact alloc]initWithContactType:OCKContactTypePersonal name:@"zhang" relation:@"wife" contactInfoItems:[NSArray array] tintColor:nil monogram:@"" image:nil];
    OCKConnectViewController *connectVC = [[OCKConnectViewController alloc]initWithContacts:[NSArray arrayWithObjects:contact, nil]];
    connectVC.title = @"Contact";
    connectVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:connectVC.title image:[UIImage imageNamed:@"connect"] selectedImage:[UIImage imageNamed:@"connect-filled"]];
    UINavigationController *navConnet = [[UINavigationController alloc]initWithRootViewController:connectVC];
    
    
    
    [self setViewControllers:[NSArray arrayWithObjects:navCareCard, navSymptomTracker, navInsights, navConnet, nil]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (void)commandInitStore {
    NSURL *storeUrl;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    if (dirArray.count) {
        NSURL *documentDir = [dirArray firstObject];
        storeUrl = [documentDir URLByAppendingPathComponent:@"CareKit_Store"];
        if (![fileManager fileExistsAtPath:storeUrl.path]) {
            NSError *err;
            [fileManager createDirectoryAtPath:storeUrl.path withIntermediateDirectories:true attributes:nil error:&err];
            if (err) {
                NSLog(@"create dir error:%@",err);
            }
        }
    }
    
    carePlanStore = [[OCKCarePlanStore alloc]initWithPersistenceDirectoryURL:storeUrl];
    carePlanStore.delegate = self;
}


- (void)commandAddActvity {
    NSString *activityID = @"TakeMedication-Code";
    [carePlanStore activityForIdentifier:activityID completion:^(BOOL success, OCKCarePlanActivity * _Nullable activity, NSError * _Nullable error) {
        if (error) {
            NSLog(@"activity error:%@",error);
            return;
        }
        if (activity) {
            NSLog(@"Activity already exist");
//            [carePlanStore removeActivity:activity completion:^(BOOL success, NSError * _Nullable error) {
//                NSDateComponents *dateComponent = [[NSDateComponents alloc]initWithYear:2017 month:4 day:1];
//                OCKCareSchedule *careSchedule = [OCKCareSchedule dailyScheduleWithStartDate:dateComponent occurrencesPerDay:2];
//                
//                OCKCarePlanActivity *carePlanActivity = [OCKCarePlanActivity interventionWithIdentifier:activityID groupIdentifier:nil title:@"Take medication" text:@"Code..Code..Code..Please take medication.." tintColor:nil instructions:@"Take twice daily with food. May cause drowsiness. It is not recommended to drive with this medication. For any severe side effects, please contact your physician." imageURL:nil schedule:careSchedule userInfo:nil];
//                
//                [carePlanStore addActivity:carePlanActivity completion:^(BOOL success, NSError * _Nullable error) {
//                    if (error) {
//                        NSLog(@"add activity error:%@",error);
//                        return;
//                    }
//                }];
//            }];
            
        } else {
            NSDateComponents *dateComponent = [[NSDateComponents alloc]initWithYear:2017 month:4 day:7];
            OCKCareSchedule *careSchedule = [OCKCareSchedule dailyScheduleWithStartDate:dateComponent occurrencesPerDay:2];
            
            OCKCarePlanActivity *carePlanActivity = [OCKCarePlanActivity interventionWithIdentifier:activityID groupIdentifier:nil title:@"Take medication" text:@"Code..Code..Code..Please take medication.." tintColor:nil instructions:@"Take twice daily with food. May cause drowsiness. It is not recommended to drive with this medication. For any severe side effects, please contact your physician." imageURL:nil schedule:careSchedule userInfo:nil];
            
            [carePlanStore addActivity:carePlanActivity completion:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"add activity error:%@",error);
                    return;
                }
            }];
        }
    }];
}

- (void)commandAddAssessmentActivity {
    NSString *assessmentActivityID = @"Emotional";
    [carePlanStore activityForIdentifier:assessmentActivityID completion:^(BOOL success, OCKCarePlanActivity * _Nullable activity, NSError * _Nullable error) {
        if (error) {
            NSLog(@"add assessment error:%@",error);
            return;
        }
        if (activity) {
            NSLog(@"Activity already exist");
        } else {
            NSDateComponents *dateCompent = [[NSDateComponents alloc]initWithYear:2017 month:4 day:5];
            OCKCareSchedule *careSchedule = [OCKCareSchedule dailyScheduleWithStartDate:dateCompent occurrencesPerDay:1];
            
            OCKCarePlanActivity *carePlanActivity = [[OCKCarePlanActivity alloc]initWithIdentifier:assessmentActivityID groupIdentifier:nil type:OCKCarePlanActivityTypeAssessment title:@"Daily Pain Survey" text:@"How are you feeling today?" tintColor:nil instructions:nil imageURL:nil schedule:careSchedule resultResettable:false userInfo:nil];
            
            [carePlanStore addActivity:carePlanActivity completion:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"add assessment activity error:%@",error);
                    return;
                }
            }];
        }
    }];
}

- (void)commandReadData {
    [carePlanStore activitiesWithType:OCKCarePlanActivityTypeIntervention completion:^(BOOL success, NSArray<OCKCarePlanActivity *> * _Nonnull activities, NSError * _Nullable error) {
        if (error) {
            NSLog(@"read data error");
            return;
        }
        for(OCKCarePlanActivity *activity in activities) {
//            NSLog(@"ActivityTypeIntervention:%@, %@",activity.identifier,activity.schedule.description);
            NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *dateComponet = [calendar componentsInTimeZone:[NSTimeZone defaultTimeZone] fromDate:[NSDate date]];
            [carePlanStore eventsForActivity:activity date:dateComponet completion:^(NSArray<OCKCarePlanEvent *> * _Nonnull events, NSError * _Nullable error) {
                if(error) {
                    NSLog(@"OCKCarePlanEvent error:%@", error);
                    return;
                }
//                for (OCKCarePlanEvent *event in events) {
//                    NSLog(@"event:%@", event.debugDescription);
//                }
            }];
        }
    }];
    
//    [carePlanStore activitiesWithType:OCKCarePlanActivityTypeAssessment completion:^(BOOL success, NSArray<OCKCarePlanActivity *> * _Nonnull activities, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"read data error");
//            return;
//        }
//        for(OCKCarePlanActivity *activity in activities) {
//            NSLog(@"ActivityTypeAssessment:%@, %@",activity.identifier,activity.schedule.description);
//        }
//    }];
    
}


#pragma mark OCKCarePlanStoreDelegate

/**
 Called when an event receives an update.
 
 @param store   The care plan store.
 @param event   The event that has been updated.
 */
- (void)carePlanStore:(OCKCarePlanStore *)store didReceiveUpdateOfEvent:(OCKCarePlanEvent *)event{
    NSLog(@"carePlanStore:%@-%@",store,event);
}

/**
 Called when an activity is added to or removed from the store.
 
 @param store   The care plan store.
 */
- (void)carePlanStoreActivityListDidChange:(OCKCarePlanStore *)store{
    NSLog(@"carePlanStoreActivityListDidChange:%@",store);
}



#pragma mark OCKSymptomTrackerViewControllerDelegate


/**
 Tells the delegate when the user selected an assessment event.
 
 @param viewController      The view controller providing the callback.
 @param assessmentEvent     The assessment event that the user selected.
 */
- (void)symptomTrackerViewController:(OCKSymptomTrackerViewController *)viewController didSelectRowWithAssessmentEvent:(OCKCarePlanEvent *)assessmentEvent{
    NSLog(@"didSelectRowWithAssessmentEvent");
    
    ORKOrderedTask *task = [self getTask];
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc]initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;
    [viewController presentViewController:taskViewController animated:YES completion:^{
        
    }];
}

- (ORKOrderedTask *)getTask {
    ORKScaleAnswerFormat *scaleAnswerFormat = [[ORKScaleAnswerFormat alloc]initWithMaximumValue:10 minimumValue:1 defaultValue:5 step:1 vertical:false maximumValueDescription:@"Good" minimumValueDescription:@"Bad"];
    ORKQuestionStep *questionStep = [ORKQuestionStep questionStepWithIdentifier:@"questionStepWithID" title:@"How was your pain today?"  answer:scaleAnswerFormat];
    
    ORKOrderedTask *orderTask = [[ORKOrderedTask alloc]initWithIdentifier:@"ORKOrderedTaskID" steps:[NSArray arrayWithObjects:questionStep, nil]];
    
    return orderTask;
}

/**
 Tells the delegate when a new set of events is fetched from the care plan store.
 
 This is invoked when the date changes or when the care plan store's `carePlanStoreActivityListDidChange` delegate method is called.
 This provides a good opportunity to update the store such as fetching data from HealthKit.
 
 @param viewController      The view controller providing the callback.
 @param events              An array containing the fetched set of assessment events grouped by activity.
 @param dateComponents      ThscaleAnswere date components for which the events will be displayed.
 */
- (void)symptomTrackerViewController:(OCKSymptomTrackerViewController *)viewController willDisplayEvents:(NSArray<NSArray<OCKCarePlanEvent*>*>*)events dateComponents:(NSDateComponents *)dateComponents{
    NSLog(@"willDisplayEvents");
    
    
}

#pragma mark ORKTaskViewControllerDelegate <NSObject>

/**
 Tells the delegate that the task has finished.
 
 The task view controller calls this method when an unrecoverable error occurs,
 when the user has canceled the task (with or without saving), or when the user
 completes the last step in the task.
 
 In most circumstances, the receiver should dismiss the task view controller
 in response to this method, and may also need to collect and process the results
 of the task.
 
 @param taskViewController  The `ORKTaskViewController `instance that is returning the result.
 @param reason              An `ORKTaskViewControllerFinishReason` value indicating how the user chose to complete the task.
 @param error               If failure occurred, an `NSError` object indicating the reason for the failure. The value of this parameter is `nil` if `result` does not indicate failure.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)error{
    NSLog(@"didFinishWithReason");
    [taskViewController dismissViewControllerAnimated:YES completion:^{
        ORKStepResult *result = (ORKStepResult *)taskViewController.result.firstResult;
        ORKScaleQuestionResult *quesResult = (ORKScaleQuestionResult *)result.results.firstObject;
        OCKCarePlanEventResult *carePlanEventResult = [[OCKCarePlanEventResult alloc]initWithValueString:quesResult.scaleAnswer.description unitString:@"out of 10" userInfo:nil];
        
        [carePlanStore updateEvent:symptomTrackerVC.lastSelectedAssessmentEvent withResult:carePlanEventResult state:OCKCarePlanEventStateCompleted completion:^(BOOL success, OCKCarePlanEvent * _Nullable event, NSError * _Nullable error) {
            if (error) {
                NSLog(@"updateEvent error:%@",error);
                return;
            }
            NSLog(@"updateEvent success");
        }];
    }];
}

@end
