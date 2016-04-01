//
//  RunLoopViewController.m
//  AllLearnDemo
//
//  Created by hp on 16/3/14.
//  Copyright © 2016年 hxp. All rights reserved.
//

#import "RunLoopViewController.h"

@interface RunLoopViewController () <UIScrollViewDelegate>

@end

@implementation RunLoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self seeCurrentLoop];      //查看runloop结构
    [self makeMySource];
}

-(void)seeCurrentLoop
{
    NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
    NSLog(@"currentLoop = %@", currentLoop);
}

-(void)makeMySource
{
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_event_handler(source, ^{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Source Event" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//        [alert show];
        NSLog(@"1111");
    });
    
    dispatch_resume(source);
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_merge_data(source, 1);
    });
    dispatch_resume(timer);
    
//    dispatch_main();
    
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
