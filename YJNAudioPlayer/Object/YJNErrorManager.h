//
//  YJNErrorManager.h
//  YJNAudioPlayerDemo
//
//  Created by 杨敬 on 2017/9/12.
//  Copyright © 2017年 杨敬. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, YJNAudioErrorCode) {
    YJNAudioStatusFailed    = 0
};

extern NSString *YJNAudioDomain;
@interface YJNErrorManager : NSObject

@end
