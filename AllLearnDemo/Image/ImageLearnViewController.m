//
//  ImageLearnViewController.m
//  AllLearnDemo
//
//  Created by hp on 16/4/22.
//  Copyright © 2016年 hxp. All rights reserved.
//

#import "ImageLearnViewController.h"

@interface ImageLearnViewController ()

@end

@implementation ImageLearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"frame= %@", _showImageView);
    NSLog(@"frame= %@", _showImageView.image);
    
    UIImage *image = _showImageView.image;
    float min = MIN(image.size.width, image.size.height);
    CGRect rect = CGRectMake((image.size.width-min)/2, (image.size.height-min)/2, min, min);
    CGImageRef squareRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *squareImage = [UIImage imageWithCGImage:squareRef];
    CGImageRelease(squareRef);
    
    NSLog(@"frame= %@", squareImage);
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
