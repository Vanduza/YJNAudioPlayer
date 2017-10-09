//
//  YJNAudioPlayer.h
//  YJNAudioPlayerDemo
//
//  Created by 杨敬 on 2017/9/11.
//  Copyright © 2017年 杨敬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJNAudioDelegate.h"

extern NSString *YJNAudioDomain;
@interface YJNAudioPlayer : NSObject
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, weak) id<YJNAudioDelegate> delegate;
+(instancetype)sharedPlayer;

-(void)yjn_audioPlayWithUrlOrPath:(NSString *)urlOrPath;
-(void)yjn_audioPause;
-(void)yjn_audioStop;
@end
