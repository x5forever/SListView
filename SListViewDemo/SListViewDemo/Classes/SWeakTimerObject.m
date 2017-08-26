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
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    SWeakTimerObject *object = [[SWeakTimerObject alloc] init];
    object.target = aTarget;
    object.selector = aSelector;
    return [NSTimer scheduledTimerWithTimeInterval:ti target:object selector:@selector(fire:) userInfo:userInfo repeats:yesOrNo];
}
- (void)fire:(NSTimer *)obj {
//    [_target performSelector:_selector withObject:obj]; /* ⚠️: "PerformSelector may cause a leak because its selector is unknown" */
    if (_target && _selector) {
        IMP imp = [_target methodForSelector:_selector];
        void (*func)(id, SEL, id) = (void *)imp;
        func(_target,_selector,obj.userInfo);
    }
}
@end
