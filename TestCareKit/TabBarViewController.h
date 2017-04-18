//
//  TabBarViewController.h
//  TestCareKit
//
//  Created by jing on 4/8/17.
//  Copyright © 2017 jing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CareKit/CareKit.h>
#import <ResearchKit/ResearchKit.h>


@interface TabBarViewController : UITabBarController <OCKCarePlanStoreDelegate, OCKSymptomTrackerViewControllerDelegate, ORKTaskViewControllerDelegate>

@end
