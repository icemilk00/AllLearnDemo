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
    
    NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
    NSLog(@"currentLoop = %@", currentLoop);
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height*2);
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
     NSLog(@"currentLoopModle = %@", [NSRunLoop currentRunLoop].currentMode);
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"currentLoopModle = %@", [NSRunLoop currentRunLoop].currentMode);
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
