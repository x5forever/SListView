//
//  SWeakTimerObject.m
//  SListViewDemo
//
//  Created by x5 on 17/5/1.
//  Copyright © 2017年 Xcution. All rights reserved.
//

#import "SWeakTimerObject.h"

@interface SWeakTimerObject ()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@end

@implementation SWeakTimerObject
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    SWeakTimerObject *object = [[SWeakTimerObject alloc] init];
    object.target = aTarget;
    object.selector = aSelector;
    return [NSTimer scheduledTimerWithTimeInterval:ti target:object selector:@selector(fire:) userInfo:userInfo repeats:yesOrNo];
}
- (void)fire:(id)obj {
    [_target performSelector:_selector withObject:obj];
}
@end
