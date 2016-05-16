//
//  ViewController.m
//  AllLearnDemo
//
//  Created by hp on 16/3/14.
//  Copyright © 2016年 hxp. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSTimer *timer;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    __weak RegisterSecondStepViewController *wwself = self;
   
    
//    timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(timeAction) userInfo:nil repeats:NO];
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//    [timer fire];
}

-(void)timeAction
{
    NSLog(@"timeAction");
    sleep(3);
    NSLog(@"again");
    [timer fire];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
