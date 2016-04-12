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
    NSRunLoop *secondRunLoop;       //第二线程的runloop
    CFRunLoopSourceRef secondSource;//第二线程的source
}
@end

@implementation RunLoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self seeCurrentLoop];                  //查看runloop结构
//    [self addRunLoopObserve];               //runloop观察者测试代码
    [self runRunLoop];                      //第二线程runloop运行代码

    
}

-(void)seeCurrentLoop
{
    NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
    NSLog(@"currentLoop = %@", currentLoop);
}

/*
 *  在当前线程创建一个runLoop观察者，并观察runloop的所有活动状态，看runloop运行顺序及一些源的运行
 */
-(void)addRunLoopObserve
{
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    CFRunLoopObserverCallBack runLoopObserverCallBack = myRunLoopObserverCallBack;
    CFRunLoopObserverContext observerContext = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, runLoopObserverCallBack, &observerContext);
    
    if (observer) {
        CFRunLoopRef cf_loop = [currentRunLoop getCFRunLoop];
        CFRunLoopAddObserver(cf_loop, observer, kCFRunLoopDefaultMode);
    }
}

void myRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    NSLog(@"myRunLoopObserverCallBack's status = %lu", activity);
}

/*
 * 主线程与第二线程通信，通过定时器发送消息，需要第二线程保持不退出
 * 在第二启动一个runLoop并添加source源，添加源主要为保持线程不退出，以响应主线程发送的消息来响应
 *
 */
-(void)runRunLoop
{
    secondThread = [[NSThread alloc] initWithTarget:self selector:@selector(secondThreadAction) object:nil];
    [secondThread start];
    
    repeatTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(repeatTest:) userInfo:nil repeats:YES];
    
}

-(void)secondThreadAction
{
    [self addRunLoopObserve];
    
    
    NSLog(@"CurrentThread = %@", [NSThread currentThread]);
    @autoreleasepool {
        secondRunLoop = [NSRunLoop currentRunLoop];
        CFRunLoopSourceContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        secondSource =  CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
        CFRunLoopAddSource([secondRunLoop getCFRunLoop], secondSource, kCFRunLoopCommonModes);
        [secondRunLoop run];
    }
}

-(void)repeatTest:(NSTimer *)timer
{
    [self performSelector:@selector(testAction) onThread:secondThread withObject:nil waitUntilDone:nil modes:@[NSRunLoopCommonModes]];
}

-(void)testAction
{
    NSLog(@"This is test");
}



-(void)viewWillDisappear:(BOOL)animated
{
    if (repeatTimer && repeatTimer.isValid) {
        [repeatTimer invalidate], repeatTimer = nil;
    }
   
    if (secondRunLoop && secondSource) {
        
        
        NSLog(@"secondRunloop 1 = %@", secondRunLoop);
        
        CFRunLoopRemoveSource([secondRunLoop getCFRunLoop], secondSource, kCFRunLoopCommonModes);
        NSLog(@"secondRunloop 2 = %@", secondRunLoop);
        //    CFRunLoopStop() 是需要把 runloop中的源清掉的，否则在stop之后会重新wake up起runloop，所以主线程的runloop调用这个方法没有用，系统会把一些系统的源重新加进去并wake up
        CFRunLoopStop([secondRunLoop getCFRunLoop]);

    }
}


-(void)dealloc
{
    if (observer) {
        CFRunLoopRemoveObserver([[NSRunLoop currentRunLoop] getCFRunLoop], observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    }
    
    if(secondSource) CFRelease(secondSource);
    
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
