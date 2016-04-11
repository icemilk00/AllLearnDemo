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
    CFRunLoopObserverRef observer;
    NSTimer *repeatTimer;
    
    NSRunLoop *secondRunLoop;
    CFRunLoopSourceRef secondSource;
}
@end

@implementation RunLoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self seeCurrentLoop];      //查看runloop结构
//    [self addRunLoopObserveWithRunLoop:[NSRunLoop currentRunLoop]];   //runloop观察者测试代码
    [self runRunLoop];          //runloop运行代码
    
    
}

-(void)seeCurrentLoop
{
    NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
    NSLog(@"currentLoop = %@", currentLoop);
}

/*
 *  在当前线程创建一个runLoop观察者，并观察runloop的所有活动状态，看runloop运行顺序及一些源的运行
 */
-(void)addRunLoopObserveWithRunLoop:(NSRunLoop *)currentRunLoop
{
    CFRunLoopObserverCallBack runLoopObserverCallBack = myRunLoopObserverCallBack;
    CFRunLoopObserverContext observerContext = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, runLoopObserverCallBack, &observerContext);
    
    if (observer) {
        CFRunLoopRef cf_loop = [currentRunLoop getCFRunLoop];
        CFRunLoopAddObserver(cf_loop, observer, kCFRunLoopDefaultMode);
    }
}

/*
 *  启动一个runLoop并保持，主要是在非主线程
 */
-(void)runRunLoop
{
    NSThread *secondThread = [[NSThread alloc] initWithTarget:self selector:@selector(secondThreadAction) object:nil];
    [secondThread start];
    
    repeatTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(repeatTest:) userInfo:secondThread repeats:YES];
    
}

-(void)secondThreadAction
{
    NSLog(@"CurrentThread = %@", [NSThread currentThread]);
    @autoreleasepool {
        secondRunLoop = [NSRunLoop currentRunLoop];
        CFRunLoopSourceContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        secondSource =  CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
        CFRunLoopAddSource([secondRunLoop getCFRunLoop], secondSource, kCFRunLoopDefaultMode);
        [secondRunLoop run];
    }
}

-(void)repeatTest:(NSTimer *)timer
{
    [self performSelector:@selector(testAction) onThread:timer.userInfo withObject:nil waitUntilDone:nil modes:@[NSDefaultRunLoopMode]];
}

-(void)testAction
{
    NSLog(@"This is test");
}

void myRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    NSLog(@"myRunLoopObserverCallBack's status = %lu", activity);
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (repeatTimer && repeatTimer.isValid) {
        [repeatTimer invalidate];
    }
    
    CFRunLoopRemoveSource([secondRunLoop getCFRunLoop], secondSource, kCFRunLoopDefaultMode);
    CFRelease(secondSource);
    //CFRunLoopStop() 是需要把 runloop中的源清掉的，否则在stop之后会重新wake up起runloop，所以主线程的runloop调用这个方法没有用，系统会把一些系统的源重新加进去并wake up
    CFRunLoopStop([secondRunLoop getCFRunLoop]);
}

-(void)dealloc
{
    CFRunLoopRemoveObserver([[NSRunLoop currentRunLoop] getCFRunLoop], observer, kCFRunLoopDefaultMode);
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
