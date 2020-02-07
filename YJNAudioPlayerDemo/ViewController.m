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
    int _mediaDuration;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _shortAudio = @"example:shortsource.mp3";
    _longAudio = @"example:longsource.mp3";
    _audioPlayer = [YJNAudioPlayer sharedPlayer];
    _audioPlayer.delegate = self;
}

- (IBAction)playOrPauseAction:(UIButton *)sender {
    if (!_audioPlayer.isPlaying) {
        [_playBtn setTitle:@"Pause" forState:UIControlStateNormal];
        [_audioPlayer yjn_audioPlayWithUrlOrPath:_longAudio];
    }else {
        [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
        [_audioPlayer yjn_audioPause];
    }
}

- (IBAction)slideAction:(UISlider *)sender {
    
}

#pragma mark - YJNAudioDelegate
-(void)yjn_audioPlayerReadyToPlay:(YJNAudioPlayer *)player {
    _mediaDuration = [player yjn_audioDurationWithUrlOrPath:_longAudio];
//    _progressLabel.text = [NSString stringWithFormat:@"ready:%d",_mediaDuration];
    [_slider setMaximumValue:_mediaDuration];
}

-(void)yjn_audioPlayerPlayToEnd:(YJNAudioPlayer *)player {
    [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
}

-(void)yjn_audioPlayerBuffering:(YJNAudioPlayer *)player progress:(NSTimeInterval)progress {
    _progressLabel.text = [NSString stringWithFormat:@"buffering:%.2f/%.2d",progress,_mediaDuration];
}

-(void)yjn_audioPlayerPlayingWithProgress:(NSTimeInterval)progress {
    [_slider setValue:progress animated:YES];
}


@end
