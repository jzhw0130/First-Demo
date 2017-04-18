//
//  ViewController.m
//  TestCareKit
//
//  Created by jing on 4/6/17.
//  Copyright © 2017 jing. All rights reserved.
//

#import "ViewController.h"
#import <CareKit/CareKit.h>

@interface ViewController (){
    OCKCarePlanStore *carePlanStore;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self commandInitStore];
    [self commandAddActvity];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)careCardButtonPressed:(id)sender {

    OCKCareCardViewController *careCardVC = [[OCKCareCardViewController alloc]initWithCarePlanStore:carePlanStore];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:careCardVC];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}


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
            [carePlanStore removeActivity:activity completion:^(BOOL success, NSError * _Nullable error) {
                NSDateComponents *dateComponent = [[NSDateComponents alloc]initWithYear:2017 month:4 day:1];
                OCKCareSchedule *careSchedule = [OCKCareSchedule dailyScheduleWithStartDate:dateComponent occurrencesPerDay:2];
                
                OCKCarePlanActivity *carePlanActivity = [OCKCarePlanActivity interventionWithIdentifier:activityID groupIdentifier:nil title:@"Take medication" text:@"Code..Code..Code..Please take medication.." tintColor:nil instructions:@"Take twice daily with food. May cause drowsiness. It is not recommended to drive with this medication. For any severe side effects, please contact your physician." imageURL:nil schedule:careSchedule userInfo:nil];
                
                [carePlanStore addActivity:carePlanActivity completion:^(BOOL success, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"add activity error:%@",error);
                        return;
                    }
                }];
            }];
            
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



@end
