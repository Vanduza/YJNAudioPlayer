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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    
    //AVPlayerItemStatusNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yjn_receivedNotification:) name:AVPlayerItemTimeJumpedNotification object:nil];
}

-(void)p_removeNotifications {
    
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
    
    //响应播放事件通知
    if ([notifiName isEqualToString:AVPlayerItemDidPlayToEndTimeNotification]) {
        [self yjn_audioStop];
        return;
    }
    
    if ([notifiName isEqualToString:AVPlayerItemPlaybackStalledNotification]) {
        [self yjn_audioPause];
        return;
    }
}

//此处可暴露一个对外接口响应routeChange
-(void)yjn_handleRouteChange:(NSNotification *)notification {
    NSDictionary *interrruptionInfo = notification.userInfo;
    
    NSInteger reason = [[interrruptionInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
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
            NSLog(@"AVAudioSession deactive error;%@",error.localizedDescription);
        }
        if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerStoped)]) {
            [_delegate yjn_audioPlayerStoped];
        }
    }
}

#pragma mark - Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([[change objectForKey:@"new"] integerValue] == AVPlayerItemStatusReadyToPlay){
        if (_delegate && [_delegate respondsToSelector:@selector(yjn_audioPlayerReadyToPlay)]) {
            [_delegate yjn_audioPlayerReadyToPlay];
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
