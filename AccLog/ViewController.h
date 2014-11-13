//
//  ViewController.h
//  AccLog
//
//  Created by Tatsuya Aoyagi on 2014/11/12.
//  Copyright (c) 2014年 Tatsuya Aoyagi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController
{
    __weak IBOutlet UISwitch *loggingSwitch;
    __weak IBOutlet UILabel *loggingStatusLabel;
    __weak IBOutlet UITextView *messageOutput;
    CMMotionManager *motionManager;
    NSFileHandle *fileHandle;
}

@end

