//
//  RunLoopViewController.m
//  AllLearnDemo
//
//  Created by hp on 16/3/14.
//  Copyright © 2016年 hxp. All rights reserved.
//

#import "RunLoopViewController.h"


@interface RunLoopViewController () <UIScrollViewDelegate>
{
    CFRunLoopObserverRef observer;  //runloop观察者
    
    NSThread *secondThread;
    NSTimer *repeatTimer;           //测试定时器
    
    CFRunLoopRef thirdRunLoop;
    CFRunLoopSourceRef thirdSource;
    BOOL shouldStopThirdRunLoop;
}
@property (weak, nonatomic) IBOutlet UIButton *sourceEventButton;
@end

@implementation RunLoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self seeCurrentLoop];                  //查看runloop结构
    [self addRunLoopObserve];               //runloop观察者测试代码
    [self runRunLoop];                      //第二线程runloop运行代码
    [self configMySource];

    
}

#pragma mark - 查看runLoop结构
-(void)seeCurrentLoop
{
    NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
    NSLog(@"currentLoop = %@", currentLoop);
}

#pragma mark - 添加runLoop观察者，实时查看runloop状态变化
/*
 *  在当前线程创建一个runLoop观察者，并观察runloop的所有活动状态，看runloop运行顺序及一些源的运行
 */
-(void)addRunLoopObserve
{
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    CFRunLoopObserverCallBack runLoopObserverCallBack = myRunLoopObserverCallBack;
    CFRunLoopObserverContext observerContext = {0, (__bridge void *)(currentRunLoop), NULL, NULL, NULL};
    
    observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, runLoopObserverCallBack, &observerContext);
    
    if (observer) {
        CFRunLoopRef cf_loop = [currentRunLoop getCFRunLoop];
        CFRunLoopAddObserver(cf_loop, observer, kCFRunLoopDefaultMode);
    }
}

void myRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    NSLog(@"myRunLoopObserverCallBack's status = %lu", activity);
//    NSLog(@"runloop = %@", info);
}

#pragma mark - 用runloop保持子线程不退出
/*
 * 主线程与第二线程通信，通过定时器发送消息，需要第二线程保持不退出
 * 在第二启动一个runLoop并添加source/port源，添加源主要为保持线程不退出，以响应主线程发送的消息来响应
 * 这里需要注意的是，第二个线程如果写成成员变量，会因为runloop保持而无法退出，导致所属类无法释放
 * 线程在被 performSelector:onThread: 这种事件时会自动创建 回调为 __NSThreadPerformPerform 的source0
 */
-(void)runRunLoop
{
    repeatTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(repeatTest:) userInfo:nil repeats:YES];
}

//这里创建的为永久存在的，可认为单例
+ (NSThread *)secondhread {
    static NSThread *thread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(secondThreadAction) object:nil];
        [thread start];
    });
    
    return thread;
}

+ (void)secondThreadAction {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"RunLoopSecondThread"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        
    /*
    *  打开可以观察到 线程在被 performSelector:onThread: 这种事件时会自动创建 回调为 __NSThreadPerformPerform 的source0
    *  如果需要强制退出runloop，需要调用CFRunLoopStop(<#CFRunLoopRef rl#>),但是必须先清除掉内部的源，否则依然会被重启，但是又没有方法去清除系统给runloop创建的源，这就导致，runloop有时候并不能被手动stop，因为我们最多只能清除掉自己给runloop添加的源，runloop源码有方法清除所有源 static void __CFRunLoopRemoveAllSources(CFRunLoopRef rl, CFStringRef modeName) ，但是没有对外开放
         
        CFRunLoopObserverCallBack runLoopObserverCallBack = myRunLoopObserverCallBack;
        CFRunLoopObserverContext observerContext = {0, (__bridge void *)(runLoop), NULL, NULL, NULL};
        
        CFRunLoopObserverRef secondObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, runLoopObserverCallBack, &observerContext);
        
        if (secondObserver) {
            CFRunLoopRef cf_loop = [runLoop getCFRunLoop];
            CFRunLoopAddObserver(cf_loop, secondObserver, kCFRunLoopDefaultMode);
        }
    *
    */

        [runLoop run];
        
    }
}

-(void)repeatTest:(NSTimer *)timer
{
    [self performSelector:@selector(testAction) onThread:[[self class] secondhread] withObject:nil waitUntilDone:nil modes:@[NSRunLoopCommonModes]];
}

-(void)testAction
{
    NSLog(@"This is test");
}

#pragma mark - 为runloop添加自定义源

/*
 *  在子线程创建runloop并启动，设置runloop运行循环周期是10秒，添加自定义源来观察源的状态
 *  由按钮事件来控制runloop的是否退出，点击事件后设置标志，在runloop一个运行周期完后结束runloop，结束线程
 */

-(void)configMySource
{
    NSThread *thirdThread = [[NSThread alloc] initWithTarget:self selector:@selector(configSourceForThirdThead) object:nil];
    [thirdThread start];

}

-(void)configSourceForThirdThead
{
    
    thirdRunLoop = CFRunLoopGetCurrent();
    
    CFRunLoopSourceContext myContext = {
        0,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        &mySourceSchedule,      //source被添加的时候回调
        &mySourceCancel,        //source被取消的时候回调
        &mySourcePerform        //source被执行的时候回调
    };
    
    thirdSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &myContext);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), thirdSource, kCFRunLoopDefaultMode);
    
    while (!shouldStopThirdRunLoop) {
        NSLog(@"开始运行thirdRunLoop -------");
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, NO);
        NSLog(@"停止运行thirdRunLoop -------");
    }
    
}

void mySourceSchedule(void *info, CFRunLoopRef rl, CFStringRef mode)
{
    NSLog(@"mySourceSchedule");
}

void mySourceCancel(void *info, CFRunLoopRef rl, CFStringRef mode)
{
    NSLog(@"mySourceCancel");
}

void mySourcePerform(void *info)
{
    NSLog(@"mySourcePerform");
}

- (IBAction)sourceEventAction:(id)sender {
    
    if(!thirdRunLoop) return;
    
    if (CFRunLoopIsWaiting(thirdRunLoop)) {
        NSLog(@"睡眠状态");
        CFRunLoopSourceSignal(thirdSource);
        CFRunLoopWakeUp(thirdRunLoop);
    }
    else
    {
        CFRunLoopSourceSignal(thirdSource);
    }
}
- (IBAction)stopThirdRunLoop:(id)sender {
    shouldStopThirdRunLoop = YES;
}

#pragma mark - 其他
-(void)viewWillDisappear:(BOOL)animated
{
    if (repeatTimer && repeatTimer.isValid) {
        [repeatTimer invalidate], repeatTimer = nil;
    }
}


-(void)dealloc
{
    if (observer) {
        CFRunLoopRemoveObserver([[NSRunLoop currentRunLoop] getCFRunLoop], observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    }
    
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

@end
