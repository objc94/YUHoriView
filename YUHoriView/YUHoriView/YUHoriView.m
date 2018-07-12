//
//  YUHoriView.m
//  YUHoriView
//
//  Created by objc94~yxy on 2018/7/11.
//  Copyright © 2018 YU. All rights reserved.
//


#import "YUHoriView.h"
#import "YUHoriElementButton.h"
#import <Masonry.h>


#define cOff  [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define cOn   [UIColor colorWithRed:255/255.0 green:51/255.0 blue:0 alpha:1]
#define dSpan 10
@interface YUHoriView()<UIScrollViewDelegate>
@property (strong,nonatomic) UIScrollView *scrollview;
@property (strong,nonatomic) NSMutableArray *buttons;
@property (strong,nonatomic) YUHoriElementButton *curButton;
@property (strong,nonatomic) UIView *movLine;
@end

@implementation YUHoriView
//  #pragma mark System ------> 系统方法/系统控件的代理
//  #pragma mark Init   ------> 初始化方法
//  #pragma mark View Logic --> 视图逻辑/自定义控件的代理
//  #pragma mark Event Setting -> 事件设置
//  #pragma mark Lazy Load  --> 懒加载

#pragma mark System
/**
    初始化方法，纯代码创建会调用这个方法。
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if( self ) {
        [self initSelfSetting];
        [self initSubViews];
        [self initSubViewAutoLayout];
    }
    return self;
}

/**
    初始化方法，xib创建会调用这个方法。
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if( self ) {
        [self initSelfSetting];
        [self initSubViews];
        [self initSubViewAutoLayout];
    }
    return self;
}

/**
    布局子视图，父亲view的frame发生变化的时候会调用此方法。
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    
}

/**
    scrollview 发送滚动时系统会调用此方法
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateUnderLinePos];
}
#pragma mark Init
- (void)initSelfSetting {
    self.clipsToBounds = YES;
    self.span = dSpan;
    
}

- (void)initSubViews {
    [self addSubview:self.scrollview];
    [self addSubview:self.movLine];
    self.scrollview.delegate = self;
    self.scrollview.showsHorizontalScrollIndicator = NO;
    self.scrollview.showsVerticalScrollIndicator = NO;
    [self.movLine setBackgroundColor:[UIColor colorWithRed:1.0 green:51/255.0 blue:0 alpha:1]];
}

- (void)initSubViewAutoLayout {
    __weak typeof (self)wsf = self;
    [self.scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(wsf);
        make.top.equalTo(wsf);
        make.width.equalTo(wsf);
        make.height.equalTo(wsf);
    }];
}
- (void)setUpByTitles:(NSMutableArray *)titles defaultButtonPos:(int)pos {
    self.titles = titles;
    self.defaultButtonPos = pos;
    
}
#pragma mark View Logic
/**
    重新刷新布局界面
 */
- (void)refresh {
    [self resetButtons];
    [self makeButtonsByTitles];
    [self buttonsEventSetting];
    NSAssert(self.defaultButtonPos >=0 && self.defaultButtonPos< self.buttons.count, @"#defaultButtonPos 错误，defaultButtonPos 的范围是否在 [0,titles.count-1] 中") ;
    [self layoutIfNeeded];
    [self selectPos:self.defaultButtonPos];
    
}

/**
    重置按钮,清空按钮
    1. 将所有按钮视图remove
    2. 初始化buttons
 */
- (void)resetButtons {
    for( UIView *view in self.buttons ) {
        [view removeFromSuperview];
    }
    _buttons = [[NSMutableArray alloc]init];
}

/**
    根据标题数组 重新制作按钮
 */
- (void)makeButtonsByTitles {
    __weak typeof (self)wsf = self;
    UIView *zeroView = [[UIView alloc]init];
    [self.scrollview addSubview:zeroView];
    [zeroView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@0);
        make.height.equalTo(@0);
        make.leading.top.equalTo(@0);
    }];
    UIView *lastView = zeroView;
    int pos = 0 ;
    for( NSString *title in _titles ) {
        YUHoriElementButton *btn =[YUHoriElementButton xib_YUHoriElementButton];
        btn.pos = pos++;
        [btn.titleLabel setText:title];
        [self.scrollview addSubview:btn]; //加入到scrollview
        [self.buttons addObject:btn]; // 将按钮保存起来，以便之后做清理工作
        [btn.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            // titlelabel ～ 标题标签的约束
            make.leading.equalTo(btn).with.offset(self.span / 2.0);
            make.trailing.equalTo(btn).with.offset(-self.span / 2.0);
            make.centerY.equalTo(btn);
        }];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            //按钮的约束
            make.leading.equalTo(lastView.mas_trailing).with.offset(0);
            make.top.equalTo(wsf.scrollview);
            make.height.equalTo(wsf.scrollview);
        }];
        lastView = btn;
    }
    
    // 为了设置contentsize
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@0);
    }];
}
- (void)selectPos:(int)pos {
    
    NSAssert(pos >=0 && pos< self.buttons.count, @"#Pos 错误，Pos 的范围是否在 [0,titles.count-1] 中") ;
    [self layoutIfNeeded];
    YUHoriElementButton *hbtn =     _buttons[pos];
    hbtn.onTap(hbtn, hbtn.pos);
}
/**
    更新下滑线的位置
 */
- (void)updateUnderLinePos {
    CGPoint curBtnCenter = CGPointMake(self.curButton.frame.size.width / 2.0, self.curButton.frame.size.height / 2.0 + 15) ;
    CGPoint desPt = [self.curButton convertPoint:curBtnCenter toView:self];
    [UIView animateWithDuration:0.1 animations:^{
        [self.movLine setCenter:desPt];
    }];
}
#pragma mark Event Setting
- (void)buttonsEventSetting {
    __weak typeof (self)wsf = self;
    for( YUHoriElementButton *button_i in self.buttons ) {
        //设置第i个button的事件
        button_i.onTap = ^(YUHoriElementButton *sender, int pos) {
            wsf.curButton.titleLabel.textColor = cOff;
            wsf.curButton = sender;
            wsf.curButton.titleLabel.textColor = cOn;
            CGFloat shouldX = sender.frame.origin.x - self.scrollview.frame.size.width / 2.0 + sender.frame.size.width / 2.0;
            // 右侧的补偿x，offsetRight意味着 scrollview右侧被隐藏部分的宽度。
            CGFloat offsetRight =
            + self.scrollview.contentSize.width
            - self.scrollview.frame.size.width
            - shouldX;
            CGPoint shouldPoint = CGPointMake(0, 0);
            if( shouldX > 0 && offsetRight >0) {
                shouldPoint = CGPointMake(shouldX, 0) ;
            }else {
                 if( shouldX <=0 )
                     shouldPoint = CGPointMake(0, 0) ;
                 if( offsetRight <=0 )
                     shouldPoint = CGPointMake(self.scrollview.contentSize.width - self.scrollview.frame.size.width, 0);
            }
            [self updateUnderLinePos];
            [wsf.scrollview setContentOffset:shouldPoint animated:YES];
        };
    }
}

#pragma mark Lazy Load
- (UIScrollView *)scrollview {
    if( !_scrollview ) {
         _scrollview =  [[UIScrollView alloc]init];
    }
    return _scrollview;
}

- (NSMutableArray *)buttons {
    if( !_buttons ) {
        _buttons = [[NSMutableArray alloc]init];
    }
    return _buttons;
}
- (UIView *)movLine {
    if( !_movLine ) {
        _movLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 23, 2)];
    }
    return _movLine;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
