//
//  SListViewCell.h
//  宜人贷借款
//
//  Created by x5 on 14-6-27.
//  Copyright (c) 2014年  Creditease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SListViewCell : UIButton
@property (nonatomic, copy) NSString * identifier;
- (id)initWithIdentifier:(NSString *) identifier;
@end
