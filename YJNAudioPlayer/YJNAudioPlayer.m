//
//  YJNAudioPlayer.m
//  YJNAudioPlayerDemo
//
//  Created by 杨敬 on 2017/9/11.
//  Copyright © 2017年 杨敬. All rights reserved.
//

#import "YJNAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIApplication.h>
#import "YJNErrorManager.h"

@interface YJNAudioPlayer()
@property (nonatomic, strong) AVPlayer *player;
@end
@implementation YJNAudioPlayer {
    AVPlayer *_player;
}

NSString *YJNAudioDomain = @"YJN_AUDIO_DOMAIN";

+(instancetype)sharedPlayer {
    static YJNAudioPlayer *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YJNAudioPlayer alloc] init];
        manager.player = [[AVPlayer alloc] init];
        manager.player.volume = [[AVAudioSession sharedInstance] outputVolume];
        [manager p_registerNotifications];
    });
    return manager;
}

-(void)p_registerNotifications {
    //UIApplicationStatusNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];//应用激活
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];//进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVAudioSessionRouteChangeNotification object:nil];//路径改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVAudioSessionInterruptionNotification object:nil];//中断事件
    
    //AVPlayerItemStatusNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVPlayerItemTimeJumpedNotification object:nil];
}

-(void)yjn_receivedNotification:(NSNotification *)notification {
    NSString *notifiName = notification.name;
    //响应应用级事件通知
    if ([notifiName isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [self yjn_audioPlay];
        return;
    }
    
    if ([notifiName isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self yjn_audioPause];
        return;
    }
    
    if ([notifiName isEqualToString:AVAudioSessionRouteChangeNotification]) {
        [self yjn_handleRouteChange:notification];
        return;
    }
    
    if ([notifiName isEqualToString:AVAudioSessionInterruptionNotification]) {
        [self p_handleInterruptionWithInfo:notification];
        return;
    }
    
    //响应播放事件通知
    if ([notifiName isEqualToString:AVPlayerItemDidPlayToEndTimeNotification]) {
        if(_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerPlayToEnd:)]) {
            [_delegate yjn_audioPlayerPlayToEnd:self];
        }
        return;
    }
    
    if ([notifiName isEqualToString:AVPlayerItemPlaybackStalledNotification]) {
        [self yjn_audioPause];
        return;
    }
}

#pragma mark - 处理通知的相关事件
//处理输出路径改变
-(void)yjn_handleRouteChange:(NSNotification *)notification {
    NSDictionary *interrruptionInfo = notification.userInfo;
    
    AVAudioSessionRouteChangeReason reason = [[interrruptionInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable: {
            // 耳机插入
            AVAudioSession *session = [AVAudioSession sharedInstance];
            for (AVAudioSessionPortDescription * output in session.currentRoute.outputs) {
                if (output.portType == AVAudioSessionPortHeadphones) {
                    [self yjn_audioPlay];
                }
            }
        }break;

        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            // 耳机拔掉
            [self yjn_audioPause];
            if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerInterrupted:)]) {
                [_delegate yjn_audioPlayerInterrupted:self];
            }
        }break;
        case AVAudioSessionRouteChangeReasonCategoryChange: {
            // 策略改变
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
        }break;
        default: {
            NSLog(@"AVAudioSessionRouteChangeReason code:%ld",reason);
        }break;
    }
}

//处理中断事件
-(void)p_handleInterruptionWithInfo:(NSNotification *)notification {
    AVAudioSessionInterruptionType type = [[notification.userInfo objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self.player pause];
        if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerInterrupted:)]) {
            [_delegate yjn_audioPlayerInterrupted:self];
        }
    }else {
        AVAudioSessionInterruptionOptions options = [[notification.userInfo objectForKey:AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            [self.player play];
            if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerResume:)]) {
                [_delegate yjn_audioPlayerResume:self];
            }
        }
        NSLog(@"Current interruption type:%lud",type);
    }
}

#pragma mark - 播放器相关方法
-(void)yjn_audioPlayWithUrlOrPath:(NSString *)urlOrPath {
    [self yjn_audioStop];
    
    if (!urlOrPath.length) {
        return;
    }
    
    NSURL *url = nil;
    if ([urlOrPath hasPrefix:@"http"]) {
        url = [NSURL URLWithString:urlOrPath];
    }else {
        url = [NSURL fileURLWithPath:urlOrPath];
    }
    
    AVPlayerItem *audioItem = [AVPlayerItem playerItemWithURL:url];
    [audioItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [_player replaceCurrentItemWithPlayerItem:audioItem];
    [_player play];
}

-(void)yjn_audioPlay {
    if (self.player.currentItem) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (error) {
            if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerFailed:)]) {
                [_delegate yjn_audioPlayerFailed:error];
            }
            NSLog(@"AVAudioSession active error;%@",error.localizedDescription);
        }
        [self.player play];
        if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerPlay)]) {
            [_delegate yjn_audioPlayerPlay];
        }
    }
}

-(void)yjn_audioPause {
    if (self.player.currentItem) {
        [self.player pause];
        if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerPaused)]) {
            [_delegate yjn_audioPlayerPaused];
        }
    }
}

-(void)yjn_audioStop {
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        [self.player pause];
        [self.player replaceCurrentItemWithPlayerItem:nil];
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:NO error:&error];
        if (error) {
            NSLog(@"AVAudioSession deactive error:%@",error.localizedDescription);
            if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerFailed:)]) {
                [_delegate yjn_audioPlayerFailed:error];
            }
        }
        if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerStoped)]) {
            [_delegate yjn_audioPlayerStoped];
        }
    }
}

#pragma mark - Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([[change objectForKey:@"new"] integerValue] == AVPlayerItemStatusReadyToPlay){
        if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerReadyToPlay:)]) {
            [_delegate yjn_audioPlayerReadyToPlay:self];
        }
    }else if([[change objectForKey:@"new"] integerValue] == AVPlayerItemStatusFailed){
        if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerFailed:)]) {
            NSError *error = [NSError errorWithDomain:YJNAudioDomain code:YJNAudioStatusFailed userInfo:@{NSLocalizedDescriptionKey:@"缓冲失败"}];
            [_delegate yjn_audioPlayerFailed:error];
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
