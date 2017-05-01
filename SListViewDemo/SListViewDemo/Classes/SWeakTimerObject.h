//
//  SWeakTimerObject.h
//  SListViewDemo
//
//  Created by x5 on 17/5/1.
//  Copyright © 2017年 Xcution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWeakTimerObject : NSObject
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;
@end
