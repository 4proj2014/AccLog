//
//  ViewController.m
//  AccLog
//
//  Created by Tatsuya Aoyagi on 2014/11/12.
//  Copyright (c) 2014年 Tatsuya Aoyagi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    NSLog(@"viewDidLoad");
    CGRect f = messageOutput.frame;
    NSLog(@"%f,%f,%f,%f",f.origin.x,f.origin.y,f.size.width,f.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSLog(@"viewWillAppear");
    CGRect rect = CGRectMake(16, 94, 300, 300);
    messageOutput.frame = rect;
    CGRect f = messageOutput.frame;
    NSLog(@"%f,%f,%f,%f",f.origin.x,f.origin.y,f.size.width,f.size.height);

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    NSLog(@"viewDidDisappear");

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logStartStop:(id)sender {
    if (loggingSwitch.on) {
        [self printlnMessage:@"logging started"];
        loggingStatusLabel.text = @"Logging";
        [self openFile];
        [self openAccelerometer];
        NSLog(@"on");
    } else {
        loggingStatusLabel.text = @"No logging";
        [self printlnMessage:@"logging stopped"];
        [self closeAccelerometer];
        [self closeFile];
        NSLog(@"off");
    }
}

- (void)openFile
{
    //if (fileHandle) return;

    //NSString *homeDir = NSHomeDirectory();
    
    /*
    // filepath = "Documents/data.txt"
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocumentsDirPath = [paths objectAtIndex:0];
    NSString *filePath = [DocumentsDirPath stringByAppendingPathComponent:@"data.txt"];
    */
    
    NSString *filePath = [self makeFilePathName];
    NSLog(filePath);
    [self printlnMessage:filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
 
    // ファイルが存在しなければ空のファイルを作成
    if (![fileManager fileExistsAtPath:filePath]) {
        BOOL result = [fileManager createFileAtPath:filePath
                                       contents:[NSData data] attributes:nil];
        if (!result) {
            NSLog(@"ファイルの作成に失敗");
            return;
        }
    }
 
    // ファイルハンドルを作成する
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!fileHandle) {
        NSLog(@"ファイルハンドルの作成に失敗");
        return;
    }
    // 書き込み位置をファイルの最後にして追加書き込みする
    [fileHandle seekToEndOfFile];
}

- (NSString*)makeFilePathName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocumentsDirPath = [paths objectAtIndex:0];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd_HH-mm-ss-SSS";
    NSString *nowStr = [dateFormatter stringFromDate:now];
    NSString *fileName = [NSString stringWithFormat:@"data_%@.csv", nowStr];
    NSString *filePath = [DocumentsDirPath stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)writeData:(CMAccelerometerData*)data error:(NSError*)error
{
    double now = [self nowInUnixTime];
    double x = data.acceleration.x;
    double y = data.acceleration.y;
    double z = data.acceleration.z;
    NSLog(@"%f,%f,%f,%f",now,x,y,z);
    NSString *line = [NSString stringWithFormat:@"%f,%f,%f,%f\n", now, x, y, z];
    NSData *linedata = [NSData dataWithBytes:line.UTF8String
                               length:line.length];
    [fileHandle writeData:linedata];
    [fileHandle synchronizeFile];
    [self printlnMessage:line];
}

- (double)nowInUnixTime
{
    double unixtime = [[NSDate date] timeIntervalSince1970];
    return unixtime;
}

- (void)closeFile
{
    if (fileHandle) {
        [fileHandle closeFile];
        fileHandle = nil;
    }
}

- (void)openAccelerometer
{
    motionManager = [[CMMotionManager alloc] init];

    if (motionManager.accelerometerAvailable) {
        // センサーの更新間隔の指定 1秒に1回
//        _motionManager.accelerometerUpdateInterval = 1 / 10;  // 10Hz
        motionManager.accelerometerUpdateInterval = 1 / 1;  // 1Hz

        // ハンドラを指定
        CMAccelerometerHandler handler =
            ^(CMAccelerometerData *data, NSError *error) {
                [self writeData:data error:error];
            };

        // 加速度の取得開始
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
    }
}

- (void)closeAccelerometer
{
    // 加速度の取得停止
    if (motionManager.accelerometerActive) {
        [motionManager stopAccelerometerUpdates];
    }
}

- (void)printlnMessage:(NSString *)message
{
    [messageOutput insertText:message];
    [messageOutput insertText:@"\n"];
}

- (void)printMessage:(NSString *)message
{
    [messageOutput insertText:message];
}

@end
