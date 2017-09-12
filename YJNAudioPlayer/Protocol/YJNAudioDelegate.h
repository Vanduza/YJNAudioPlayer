//
//  YJNAudioDelegate.h
//  YJNAudioPlayerDemo
//
//  Created by 杨敬 on 2017/9/12.
//  Copyright © 2017年 杨敬. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YJNAudioPlayer;
@protocol YJNAudioDelegate <NSObject>
@optional

/**
 数据缓冲中的回调
 */
-(void)yjn_audioPlayerBuffering;

/**
 缓冲完毕准备播放
 */
-(void)yjn_audioPlayerReadyToPlay;

/**
 开始or恢复播放
 */
-(void)yjn_audioPlayerPlay;

/**
 暂停播放
 */
-(void)yjn_audioPlayerPaused;

/**
 停止播放
 */
-(void)yjn_audioPlayerStoped;


/**
 播放失败

 @param error 错误reason
 */
-(void)yjn_audioPlayerFailed:(NSError *)error;

@end
