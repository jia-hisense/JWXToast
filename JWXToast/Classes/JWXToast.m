//
//  JWXToast.m
//  JWXToast
//
//  Created by FUJIA JIA on 2020/11/11.
//  Copyright © 2020 FUJIA JIA. All rights reserved.
//

#import "JWXToast.h"

@implementation JWXLabel

- (instancetype)init {
    if (self = [super init]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _textInsets)];
}

@end


// 全局控制显示时间
static int changeCount;

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface JWXToast()

@property (nonatomic, strong)NSTimer *countTimer;
@property (nonatomic, strong)JWXLabel *toastLabel;
@property (nonatomic, assign)BOOL isShow;

@end

@implementation JWXToast

// 单例方法
+ (instancetype)sharedInstance {
    static JWXToast *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[JWXToast alloc] init];
    });
    return singleton;
}

// 初始化方法
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setPreference];
        __weak typeof(self)weakSelf = self;
        self.countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:weakSelf selector:@selector(changeTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.countTimer forMode:NSRunLoopCommonModes];
        self.countTimer.fireDate = [NSDate distantFuture]; //关闭定时器
    }
    return self;
}

- (void)dealloc
{
    [self.countTimer invalidate];
    self.countTimer = nil;
}

#pragma mark -- Public Methods

- (void)show:(NSString *)message {
    if ([message length] == 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isShow = YES;
        changeCount = self.duration;    // 重置计数时间
        [self setMessageText:message];
        [self showToastAnimation];
        self.countTimer.fireDate = [NSDate distantPast]; //开启定时器
    });
}

- (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isShow = NO;
        [self hideToastAnimation];
        self.countTimer.fireDate = [NSDate distantFuture];
    });
}

#pragma mark -- Private Methods

// 初始化配置
- (void)setPreference {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:15];
        self.position = JWXToastPositionCenter;
        self.duration = 2.0;
        self.marginVertical = 80.0f;
        self.maxWidth = SCREEN_WIDTH - 40.0f;
        self.textInsets = UIEdgeInsetsMake(15, 25, 15, 25);
    });
}

//定时器回调方法
- (void)changeTime {
    if(--changeCount <= 0){
        self.countTimer.fireDate = [NSDate distantFuture]; //关闭定时器
        [self hideToastAnimation];
    }
}

- (void)showToastAnimation {
    self.toastLabel.alpha = 0;
    self.toastLabel.layer.zPosition = 100;
    [[self getWindow] addSubview:self.toastLabel];
    [UIView animateWithDuration:0.2f animations:^{
        self.toastLabel.alpha = 1;
    }];
}

- (void)hideToastAnimation {
    NSLog(@"Toast Hide: changeCount=%ld", (long)changeCount);
    [UIView animateWithDuration:0.2f animations:^{
        self.toastLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [self.toastLabel removeFromSuperview];
    }];
}

//设置显示的文字
- (void)setMessageText:(NSString *)text {
    [self.toastLabel setText:text];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.maxWidth - self.textInsets.left - self.textInsets.right, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.toastLabel.font} context:nil];
    CGFloat width = rect.size.width + self.textInsets.left + self.textInsets.right;
    CGFloat height = rect.size.height + self.textInsets.top + self.textInsets.bottom;
    
    CGFloat x = (SCREEN_WIDTH - width) / 2;
    CGFloat y = (SCREEN_HEIGHT - height) / 2;
    switch (self.position) {
        case JWXToastPositionTop:
            y = self.marginVertical;
            break;
        case JWXToastPositionCenter:
            y = (SCREEN_HEIGHT - height)/2;
            break;
            case JWXToastPositionBottom:
            y = (SCREEN_HEIGHT - height - self.marginVertical);
            break;
        default:
            break;
    }
    self.toastLabel.frame = CGRectMake(x, y, width, height);
    CGFloat cornerRadius = height / 2;
    if (cornerRadius > self.font.lineHeight + self.textInsets.top || cornerRadius > self.font.lineHeight + self.textInsets.bottom) { // 避免文字过多时显示不全，不再使用半圆式圆角
        cornerRadius = 20;
    }
    self.toastLabel.layer.cornerRadius = cornerRadius;
}

- (UIWindow *)getWindow {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (id windowView in windows) {
        NSString *viewName = NSStringFromClass([windowView class]);
        if ([@"UIRemoteKeyboardWindow" isEqualToString:viewName]) {
            window = windowView;
           break;
        }
    }
    return window;
}

- (UILabel *)toastLabel {
    if (!_toastLabel) {
        _toastLabel = [[JWXLabel alloc] init];
        _toastLabel.layer.masksToBounds = YES;
        _toastLabel.layer.borderColor = [[UIColor colorWithWhite:0.4 alpha:1] CGColor];
        _toastLabel.layer.borderWidth = 0.5;
        _toastLabel.backgroundColor = self.backgroundColor;
        _toastLabel.numberOfLines = 0;
        _toastLabel.textAlignment = NSTextAlignmentCenter;
        _toastLabel.textColor = self.textColor;
        _toastLabel.font = self.font;
        _toastLabel.textInsets = UIEdgeInsetsMake(8, 20, 8, 20);
    }
    return _toastLabel;
}

#pragma mark - Setters
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.toastLabel.backgroundColor = _backgroundColor;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.toastLabel.textColor = textColor;
}
- (void)setFont:(UIFont *)font {
    _font = font;
    self.toastLabel.font = _font;
}

- (void)setTextInsets:(UIEdgeInsets)textInsets {
    _textInsets = textInsets;
    self.toastLabel.textInsets = textInsets;
}

@end

