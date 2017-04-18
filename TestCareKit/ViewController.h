//
//  ViewController.h
//  TestCareKit
//
//  Created by jing on 4/6/17.
//  Copyright © 2017 jing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CareKit/CareKit.h>

@interface ViewController : UIViewController <OCKCarePlanStoreDelegate>

- (IBAction)careCardButtonPressed:(id)sender;

@end

