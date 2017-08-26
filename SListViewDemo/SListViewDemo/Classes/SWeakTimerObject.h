//
//  SWeakTimerObject.h
//  SListViewDemo
//
//  Created by x5 on 17/5/1.
//  Copyright © 2017年 Xcution. All rights reserved.
//

//  避免 Timer 强引用，无法释放的问题

#import <Foundation/Foundation.h>

@interface SWeakTimerObject : NSObject

+ (nonnull NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(nonnull id)aTarget selector:(nonnull SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

@end
