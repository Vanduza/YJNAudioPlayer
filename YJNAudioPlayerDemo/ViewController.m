//
//  ViewController.m
//  YJNAudioPlayerDemo
//
//  Created by 杨敬 on 2017/9/11.
//  Copyright © 2017年 杨敬. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressWidth;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
