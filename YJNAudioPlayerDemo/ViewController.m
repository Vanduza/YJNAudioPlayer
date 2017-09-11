//
//  ViewController.m
//  YJNAudioPlayerDemo
//
//  Created by 杨敬 on 2017/9/11.
//  Copyright © 2017年 杨敬. All rights reserved.
//

#import "ViewController.h"
#import "YJNAudioPlayer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressWidth;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation ViewController {
    YJNAudioPlayer *_audioPlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _audioPlayer = [YJNAudioPlayer sharedPlayer];
}

- (IBAction)playOrPauseAction:(UIButton *)sender {
    if (!_audioPlayer.isPlaying) {
        [_playBtn setTitle:@"Pause" forState:UIControlStateNormal];
        [_audioPlayer playAudioWithUrlOrPath:@"http://yydy.file.alimmdn.com/chat_voice/Voice_20170117_160357_1578"];
    }else {
        [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
        [_audioPlayer pause];
    }
}

- (IBAction)slideAction:(UISlider *)sender {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
