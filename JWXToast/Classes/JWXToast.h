//
//  JWXToast.h
//  JWXToast
//
//  Created by FUJIA JIA on 2020/11/11.
//  Copyright © 2020 FUJIA JIA. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define JWXToastVersion @"1.0.0.202011121"

typedef enum : NSUInteger {
    JWXToastPositionTop,
    JWXToastPositionCenter,
    JWXToastPositionBottom,
} JWXToastPosition;

@interface JWXLabel : UILabel
@property (nonatomic, assign) UIEdgeInsets textInsets; // 控制字体与控件边界的间隙
@end

@interface JWXToast : NSObject

@property (nonatomic, assign)int duration;              // 展示时间，单位：秒, 只支持整数秒
@property (nonatomic, strong)UIColor *backgroundColor;  // 背景颜色
@property (nonatomic, strong)UIColor *textColor;        // 文本颜色
@property (nonatomic, assign)JWXToastPosition position; // Toast展示的位置
@property (nonatomic, strong)UIFont *font;              // 文本字体
@property (nonatomic, assign)CGFloat marginVertical;    // 到上或下边缘距离, position为JWXToastPositionCenter时无效
@property (nonatomic, assign)CGFloat maxWidth;          // Toast最大宽度，默认：屏幕宽度-40.0f
@property (nonatomic, assign)UIEdgeInsets textInsets;   // 文本边距

/// 创建单例
+ (instancetype)sharedInstance;

/// 显示Toast
/// @param message 展示的消息
- (void)show:(NSString *)message;

/// 隐藏Toast
- (void)hide;

@end

NS_ASSUME_NONNULL_END
