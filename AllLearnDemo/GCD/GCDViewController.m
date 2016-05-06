//
//  GCDViewController.m
//  AllLearnDemo
//
//  Created by hp on 16/5/3.
//  Copyright © 2016年 hxp. All rights reserved.
//

#import "GCDViewController.h"

@interface GCDViewController ()

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self GCD_barrier];
    [self GCD_group];
}

-(void)GCD_barrier
{
    dispatch_queue_t barrier_queue = dispatch_queue_create("barrier_queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(barrier_queue, ^{
        sleep(3);
        NSLog(@"task - 1");
    });
    
    dispatch_async(barrier_queue, ^{

        NSLog(@"task - 2");
    });
    
    /*
     *  dispatch_barrier_async()会等前面的任务全部完成，才会执行，并且在执行barrier的block的时候，不会执行后面的任务，直到barrier任务结束
     */
    dispatch_barrier_async(barrier_queue, ^{
        NSLog(@"barrier -----------");
        sleep(2);
    });
    
    dispatch_async(barrier_queue, ^{
        NSLog(@"task - 3");
    });
    
    dispatch_async(barrier_queue, ^{
        NSLog(@"task - 4");
    });
}

-(void)GCD_group
{
    dispatch_queue_t group_queue = dispatch_queue_create("group_queue", DISPATCH_QUEUE_CONCURRENT);
    
    //group - 使用方法1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
        dispatch_group_t group1 = dispatch_group_create();
        dispatch_group_enter(group1);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSLog(@"task - 1");
            sleep(2);
            NSLog(@"task - 1 over");
            dispatch_group_leave(group1);
        });
        
        dispatch_group_enter(group1);
        dispatch_async(group_queue, ^{
            NSLog(@"task - 2");
            sleep(4);
            NSLog(@"task - 2 over");
             dispatch_group_leave(group1);
        });
        
        dispatch_group_enter(group1);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"task - 3");
            dispatch_group_leave(group1);
        });
        
        dispatch_group_wait(group1, DISPATCH_TIME_FOREVER);     //dispatch_group_wait() 是以同步的方式，所以如果放在主线程会阻塞主线程
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSLog(@"task 1 ,2 and 3 has over");
        });
        
    });
    
    //group - 使用方法2
    dispatch_group_t group1 = dispatch_group_create();
    dispatch_group_enter(group1);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"task - 1");
        sleep(2);
        NSLog(@"task - 1 over");
        dispatch_group_leave(group1);
    });
    
    dispatch_group_enter(group1);
    dispatch_async(group_queue, ^{
        NSLog(@"task - 2");
        sleep(4);
        NSLog(@"task - 2 over");
        dispatch_group_leave(group1);
    });
    
    dispatch_group_enter(group1);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"task - 3");
        dispatch_group_leave(group1);
    });

    //dispatch_group_notify() 是以异步的方式
    dispatch_group_notify(group1, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"task 1 ,2 and 3 has over");
    });
    
    /*
     *   方法1和方法2的效果是一样的，方法1如果不把代码块放到新线程中会阻塞主线程
     *   group不区分队列只针对任务完成度
     */
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
