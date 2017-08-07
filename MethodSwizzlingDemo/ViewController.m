//
//  ViewController.m
//  MethodSwizzlingDemo
//
//  Created by Memebox on 2017/8/7.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "ViewController.h"
#import <UIImageView+WebCache.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createChildView];
}

- (void)createChildView {
    for (NSUInteger i = 0; i < 6; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(100, 50+i*90, 80, 80);
        imageView.contentMode = UIStackViewAlignmentFill;
        [imageView sd_setImageWithURL:[NSURL URLWithString:@"http://ww1.sinaimg.cn/large/005B0CRugy1fibb7vj2k6g308c08ct9j.jpg"] placeholderImage:nil];
        [self.view addSubview:imageView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
