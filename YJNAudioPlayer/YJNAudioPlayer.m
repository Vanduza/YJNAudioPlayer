//
//  YJNAudioPlayer.m
//  YJNAudioPlayerDemo
//
//  Created by 杨敬 on 2017/9/11.
//  Copyright © 2017年 杨敬. All rights reserved.
//

#import "YJNAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
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
        [manager registerNotifications];
        
    });
    return manager;
}

-(void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receivedAudioStatusChanged:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];//Media did play to end
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receivedAudioStatusChanged:) name:AVPlayerItemPlaybackStalledNotification object:nil];//
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receivedAudioStatusChanged:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receivedAudioStatusChanged:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

-(void)p_receivedAudioStatusChanged:(NSNotification *)notification {
    
}

-(void)playAudioWithUrlOrPath:(NSString *)urlOrPath {
    [self stopPlayAudio];
    
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
    [_player replaceCurrentItemWithPlayerItem:audioItem];
    [_player play];
    
}

-(void)pause {
    [self.player pause];
}

-(void)stopPlayAudio {
    
}
@end
