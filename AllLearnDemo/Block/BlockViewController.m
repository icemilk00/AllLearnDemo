//
//  BlockViewController.m
//  AllLearnDemo
//
//  Created by hp on 16/5/6.
//  Copyright © 2016年 hxp. All rights reserved.
//

#import "BlockViewController.h"

typedef void(^TimeBlock)(int time);

@interface BlockViewController ()
{
    int t_time;
//    TimeBlock _timeBlock;
}

@property (copy) TimeBlock timeBlock;
@end

@implementation BlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _timeBlock = ^(int time) {
        t_time = time;
    };

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _timeBlock = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    
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
