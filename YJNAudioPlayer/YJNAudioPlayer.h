//
//  YJNAudioPlayer.h
//  YJNAudioPlayerDemo
//
//  Created by 杨敬 on 2017/9/11.
//  Copyright © 2017年 杨敬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJNAudioPlayer : NSObject
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
+(instancetype)sharedPlayer;
-(void)playAudioWithUrlOrPath:(NSString *)urlOrPath;
-(void)pause;
-(void)stopPlayAudio;
@end
