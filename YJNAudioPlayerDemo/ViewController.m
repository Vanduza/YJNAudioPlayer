//
//  ViewController.m
//  YJNAudioPlayerDemo
//
//  Created by 杨敬 on 2017/9/11.
//  Copyright © 2017年 杨敬. All rights reserved.
//

#import "ViewController.h"
#import "YJNAudioPlayer.h"

@interface ViewController ()<YJNAudioDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressWidth;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation ViewController {
    YJNAudioPlayer *_audioPlayer;
    NSString *_shortAudio;
    NSString *_longAudio;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _shortAudio = @"http://yiyichat-dev.oss-cn-shenzhen.aliyuncs.com/d81249e7d9c2f2a144f563ddeedf91ed/video/TTT1.mp3";
    _longAudio = @"http://yiyichat-dev.oss-cn-shenzhen.aliyuncs.com/d81249e7d9c2f2a144f563ddeedf91ed/audio/TTT.mp3";
    _audioPlayer = [YJNAudioPlayer sharedPlayer];
    _audioPlayer.delegate = self;
}

- (IBAction)playOrPauseAction:(UIButton *)sender {
    if (!_audioPlayer.isPlaying) {
        [_playBtn setTitle:@"Pause" forState:UIControlStateNormal];
        [_audioPlayer yjn_audioPlayWithUrlOrPath:_shortAudio];
    }else {
        [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
        [_audioPlayer yjn_audioPause];
    }
}

- (IBAction)slideAction:(UISlider *)sender {
    
}

#pragma mark - YJNAudioDelegate
-(void)yjn_audioPlayerBuffering:(YJNAudioPlayer *)player {
    _progressLabel.text = @"loading";
}

-(void)yjn_audioPlayerReadyToPlay:(YJNAudioPlayer *)player {
    _progressLabel.text = @"ready";
}

-(void)yjn_audioPlayerPlayToEnd:(YJNAudioPlayer *)player {
    [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
}


@end
