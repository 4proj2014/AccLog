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
    CMMotionManager *motionManager;
    NSFileHandle *fileHandle;
}

@end

