//
//  TLSwiper.h
//  TLSwiper
//
//  Created by Gxdy on 2020/4/26.
//  Copyright © 2020 Gxdy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TLSwiper, TLSwiperPage;
@protocol TLSwiperDataSourceAndDelegate <UITableViewDelegate>

@required
/// 返回总页数
- (NSInteger)numberOfPageInSwiper:(TLSwiper *)swiper;
/// 返回对应页面的page。可以使用`- dequeueReusablePageWithIdentifier`从缓存池中获取page
- (TLSwiperPage *)swiper:(TLSwiper *)swiper pageForIndex:(NSUInteger)index;

@optional
/// 正在显示的page, 会重复调用（滑动结束时调用）
- (void)swiper:(TLSwiper *)swiper didDisplayPage:(TLSwiperPage *)page atIndex:(NSUInteger)index;
   

@end

/// 轮播组件 视图中最多只有三个page显示在屏幕上的，其他的都会扔进缓存池
@interface TLSwiper : UIView
/// 是否为无限流，Default is true. 设置该参数后回重置页面
@property(nonatomic, assign) BOOL isInfiniteFlow;
/// 分页控件
@property (weak, nonatomic, readonly) UIPageControl *pageControl;
@property(nonatomic, assign) CGRect pageControlFrame;
/// 是否为横行滚动，default is YES
@property (assign, nonatomic, getter=isScrollHorizontal) BOOL scrollHorizontal;
/// 自动轮播，default is NO
@property(nonatomic, assign, getter=isAutoPlay) BOOL autoPlay;
@property (nonatomic, weak, nullable) id <TLSwiperDataSourceAndDelegate> delegate;
/// 是否需要复用page， default is YES， 不复用时每个page都需要有唯一的reusableId
@property(nonatomic, assign) BOOL reusable;

/// 创建实例对象
/// @param delegate 数据源和代理
+ (instancetype)swiperWithDelegate:(id <TLSwiperDataSourceAndDelegate>)delegate;
- (nullable __kindof TLSwiperPage *)dequeueReusablePageWithIdentifier:(NSString *)identifier;
- (nullable __kindof TLSwiperPage *)pageWithIndex:(NSUInteger)index;
- (void)reloadData;
- (void)nextPage;
- (void)previousPage;
//- (void)scrollToPage:(NSUInteger)index animated:(BOOL)animated; // 功能暂时未实现
- (BOOL)isFirstPage;
- (BOOL)isLastPage;
@end


@interface TLSwiperPage : NSObject
/// 页面内容（默认充满整个swiper，可以通过inset属性来调节）
@property(nonatomic, strong) __kindof UIView *pageView;
/// 复用标识符，不复用时每个page都需要有唯一的reusableId
@property(nonatomic, copy, readonly) NSString *reusableId;
/// 页面所在索引
@property(nonatomic, assign, readonly) NSUInteger index;
/// page 相对swiper向内缩进
@property(nonatomic, assign) UIEdgeInsets inset;

+ (instancetype)pageWithView:(nonnull UIView *)pageView reusableIdentifier:(nullable NSString *)reusableId;
@end
NS_ASSUME_NONNULL_END
