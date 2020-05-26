//
//  TLSwiper.m
//  TLSwiper
//
//  Created by Gxdy on 2020/4/26.
//  Copyright © 2020 Gxdy. All rights reserved.
//

#import "TLSwiper.h"

// MARK: - TLSwiperPage
@interface TLSwiperPage ()
@property(nonatomic, copy) NSString *reusableId;
@property(nonatomic, assign) NSUInteger index;
@end

@implementation TLSwiperPage
+ (instancetype)pageWithView:(UIView *)pageView reusableIdentifier:(NSString *)reusableId {
    if (pageView == nil) {
         @throw [NSException exceptionWithName:@"TLSwiperPage：`+ pageWithView: reusableIdentifier: `" reason:@"参数pageView不能为nil" userInfo:nil];
    }
    if (![pageView isKindOfClass:[UIView class]]) {
         @throw [NSException exceptionWithName:@"TLSwiperPage：`+ pageWithView: reusableIdentifier: `" reason:@"参数pageView必须是UIView或其子类" userInfo:nil];
    }
    
    TLSwiperPage *page = [[self alloc] init];
    page.pageView = pageView;
    page.reusableId = reusableId;
    return page;
}
@end

@interface TLSwiperPageContentView : UIView
@property(nonatomic, strong) TLSwiperPage *page;
@end

@implementation TLSwiperPageContentView
- (void)setPage:(TLSwiperPage *)page {
    _page = page;
    
    [self addSubview:page.pageView];
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.page) {
        UIEdgeInsets inset = self.page.inset;
        CGFloat left = inset.left;
        CGFloat top = inset.top;
        CGFloat w = CGRectGetWidth(self.bounds) - left - inset.right;
        CGFloat h = CGRectGetHeight(self.bounds) - top - inset.bottom;
        self.page.pageView.frame = CGRectMake(left, top, w, h);
    }
}
@end

// MARK: -
// MARK: - TLSwiper
@interface TLSwiper () <UIScrollViewDelegate>
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) NSTimer *timer;
@property(nonatomic, strong) NSMutableArray <TLSwiperPage *>*cachePool;
/// 显示在屏幕的page
@property(nonatomic, strong) NSMutableArray <TLSwiperPageContentView *> *swiperPages;
@property(nonatomic, weak) TLSwiperPage *curPage;
@end

@implementation TLSwiper
+ (instancetype)swiperWithDelegate:(id <TLSwiperDataSourceAndDelegate>)delegate {
    if (delegate == nil) {
         @throw [NSException exceptionWithName:@"TLSwiperPage：`+ pageWithView: reusableIdentifier: `" reason:@"参数delegate不能为nil" userInfo:nil];
    }
    
    TLSwiper *swiper = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    swiper.delegate = delegate;
    return swiper;;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initSubViews];
}

static int const SwiperPageCount = 3;
- (void)initSubViews {
    self.scrollHorizontal = YES;
    self.isInfiniteFlow  = YES;
    self.reusable = YES;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    self.swiperPages = [NSMutableArray arrayWithCapacity:SwiperPageCount];
    for (int i = 0; i<SwiperPageCount; i++) {
        TLSwiperPageContentView *pageContentView = [[TLSwiperPageContentView alloc] init];
        [scrollView addSubview:pageContentView];
        [self.swiperPages addObject:pageContentView];
    }
    
    // 页码
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = 1;
    pageControl.currentPage = 0;
    [self addSubview:pageControl];
    _pageControl = pageControl;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    self.scrollView.frame = rect;
    NSInteger qty = [self.delegate numberOfPageInSwiper:self];
    qty = !self.isInfiniteFlow && SwiperPageCount > qty ? qty : SwiperPageCount;
    if (self.isScrollHorizontal) {
        self.scrollView.contentSize = CGSizeMake(qty * rect.size.width, 0);
    } else {
        self.scrollView.contentSize = CGSizeMake(0, qty * rect.size.height);
    }
    
    for (int i = 0; i<SwiperPageCount; i++) {
        UIView *pageContentView = self.swiperPages[i];
        
        if (self.isScrollHorizontal) {
            pageContentView.frame = CGRectMake(i * rect.size.width, 0, rect.size.width, rect.size.height);
        } else {
            pageContentView.frame = CGRectMake(0, i * rect.size.height, rect.size.width, rect.size.height);
        }
    }
    
    if (CGRectIsEmpty(self.pageControlFrame)) {
        CGFloat pageW = rect.size.width;
        CGFloat pageH = 40;
        CGFloat pageX = rect.size.width - pageW;
        CGFloat pageY = rect.size.height - pageH - 30;
        self.pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
    }else {
        self.pageControl.frame = self.pageControlFrame;
    }
    
    if(self.isInfiniteFlow && rect.size.width > 0 && rect.size.height) {
        [self reloadData];
    }
}

- (void)setPageControlFrame:(CGRect)pageControlFrame {
    _pageControlFrame = pageControlFrame;
    self.pageControl.frame = self.pageControlFrame;
}

// MARK: - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 找出最中间的那个View
    NSInteger index = 0;
    CGFloat minDistance = MAXFLOAT;
    for (int i = 0; i<self.swiperPages.count; i++) {
        TLSwiperPageContentView *pageContentView = self.swiperPages[i];
        CGFloat distance = 0;
        if (self.isScrollHorizontal) {
            distance = ABS(pageContentView.frame.origin.x - scrollView.contentOffset.x);
        } else {
            distance = ABS(pageContentView.frame.origin.y - scrollView.contentOffset.y);
        }
        if (distance < minDistance) {
            minDistance = distance;
            index = pageContentView.tag;
        }
    }
    
    self.pageControl.currentPage = index;
    self.curPage = [self pageWithIndex:index];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(self.autoPlay)   [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(self.autoPlay)   [self startTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateContent];
    if ([self.delegate respondsToSelector:@selector(swiper:didDisplayPage:atIndex:)]) {
        [self.delegate swiper:self didDisplayPage:self.curPage atIndex:self.curPage.index];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateContent];
    if ([self.delegate respondsToSelector:@selector(swiper:didDisplayPage:atIndex:)]) {
        [self.delegate swiper:self didDisplayPage:self.curPage atIndex:self.curPage.index];
    }
}

// MARK: - 内容更新
- (void)setIsInfiniteFlow:(BOOL)isInfiniteFlow {
    if (self.isInfiniteFlow == isInfiniteFlow) return;
    
    _isInfiniteFlow = isInfiniteFlow;
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    self.pageControl.currentPage = 0;
    
    if (isInfiniteFlow) {
        [self reloadData];
        return;;
    }
    
    /// 非无限流下的初始化数据
    self.pageControl.numberOfPages = [self.delegate numberOfPageInSwiper:self];
    self.scrollView.scrollEnabled = self.pageControl.numberOfPages > 1;
    
    for (int i = 0; i<SwiperPageCount; i++) {
        if (i >= self.pageControl.numberOfPages) break;
        
        TLSwiperPageContentView *pageContentView = self.swiperPages[i];
        [self updatePageForIndex:i toPageContentView:pageContentView];
    }
    self.curPage = self.swiperPages.firstObject.page;
    
    self.autoPlay ? [self startTimer] : [self stopTimer];
}

- (void)reloadData {
    self.pageControl.numberOfPages = [self.delegate numberOfPageInSwiper:self];
    self.scrollView.scrollEnabled = self.pageControl.numberOfPages > 1;
    [self updateContent];
    self.autoPlay ? [self startTimer] : [self stopTimer];
}

- (void)updateContent {
    
    if(!self.isInfiniteFlow && (self.isFirstPage || self.isLastPage))  return;

    NSInteger page = self.pageControl.currentPage;
    for (int i = 0; i<SwiperPageCount; i++) {
        TLSwiperPageContentView *pageContentView = self.swiperPages[i];
        NSInteger index = page;
        if (i == 0) {
            index--;
        } else if (i == SwiperPageCount-1) {
            index++;
        }
        
        if (index < 0) {
            index = self.pageControl.numberOfPages - 1;
        } else if (index >= self.pageControl.numberOfPages) {
            index = 0;
        }
        [self updatePageForIndex:index toPageContentView:pageContentView];
    }
        
    // 设置偏移量在中间
    if (self.isScrollHorizontal) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    } else {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height);
    }
}

- (void)updatePageForIndex:(NSUInteger)index toPageContentView:(TLSwiperPageContentView *)pageContentView {
    // 将旧的page扔到缓存池
    TLSwiperPage *page = pageContentView.page;
    if (self.reusable)  [self addPageToCachePool:page];
    
    // 添加新的page
    page = [self.delegate swiper:self pageForIndex:index];
    if (self.reusable) {
        [self dequeuePageFromCachePool:page]; // 移除缓存池中已经显示的page
    }else {
        if (![self.cachePool containsObject:page]) [self addPageToCachePool:page];
    }
    
    
    pageContentView.page = page;
    page.index = index;
    pageContentView.tag = index;
}

- (nullable TLSwiperPage *)pageWithIndex:(NSUInteger)index {
    for (TLSwiperPageContentView *cView in self.swiperPages) {
        if(cView.page && cView.page.index == index) return cView.page;
    }
    return nil;
}

// MARK: - 定时器处理
- (void)setAutoPlay:(BOOL)autoPlay {
    _autoPlay = autoPlay;
    
    self.autoPlay ? [self startTimer] : [self stopTimer];
}

- (void)startTimer {
    if (self.timer || [self.delegate numberOfPageInSwiper:self] <= 1) return;
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)stopTimer {
    if (!self.timer) return;
    
    [self.timer invalidate];
    self.timer = nil;
}

// MARK: - 切换页面
- (void)timerAction {
    if (!self.isInfiniteFlow) {
        static BOOL isClockwise = YES;
        if (self.isFirstPage && !isClockwise) {
            isClockwise = YES;
        }else if (self.isLastPage && isClockwise) {
            isClockwise = NO;
        }
        isClockwise ? [self nextPage] : [self previousPage];
    }else {
        [self nextPage];
    }
}

- (void)nextPage {
    if (!self.isInfiniteFlow && [self isLastPage]) return;
    
    if (self.isScrollHorizontal) {
        CGFloat offset = self.scrollView.contentOffset.x + self.scrollView.frame.size.width; // 模拟滚动
        [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    } else {
        CGFloat offset = self.scrollView.contentOffset.y + self.scrollView.frame.size.height;
        [self.scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
    }
}

- (void)previousPage {
    if (!self.isInfiniteFlow && [self isFirstPage]) return;
    
    if (self.isScrollHorizontal) {
        CGFloat offset = self.scrollView.contentOffset.x - self.scrollView.frame.size.width;
        [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    } else {
        CGFloat offset = self.scrollView.contentOffset.y - self.scrollView.frame.size.height;
        [self.scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
    }
}

/*
- (void)scrollToPage:(NSUInteger)index animated:(BOOL)animated {
    NSUInteger curPage = self.curPage.index;
    NSInteger count = index - curPage;
    if (count != 0) {
        if (self.timer) [self stopTimer];
        
        NSTimeInterval duration = animated ? 0.25 / ABS(count) : 0.f;
        [self scrollToNextPage:count > 0 duration:duration repeatCount:ABS(count)];
    }
}

- (void)scrollToNextPage:(BOOL)isNext duration:(NSTimeInterval)duration repeatCount:(NSInteger)repeat {
    [UIView animateWithDuration:duration animations:^{
        if (isNext) {
            if (self.isScrollHorizontal) {
                self.scrollView.contentOffset = CGPointMake(2 * self.scrollView.frame.size.width, 0);
            } else {
                self.scrollView.contentOffset = CGPointMake(0, 2 * self.scrollView.frame.size.height);
            }
        }else {
            self.scrollView.contentOffset = CGPointMake(0, 0);
        }
    } completion:^(BOOL finished) {
        if (repeat > 1) {
            [self scrollToNextPage:isNext duration:duration repeatCount:repeat - 1];
        }else {
            if (self.isAutoPlay) {
                [self startTimer];
            }
        }
    }];
}
*/

- (BOOL)isFirstPage {
    return self.pageControl.currentPage == 0;
}

- (BOOL)isLastPage {
    return self.pageControl.currentPage == self.pageControl.numberOfPages - 1;
}

// MARK: - 缓存池管理
- (void)addPageToCachePool:(TLSwiperPage *)page {
    if (!page) return;
    
    if (!self.cachePool) self.cachePool = [NSMutableArray array];
    
    if(self.reusable) [page.pageView removeFromSuperview];
    
    [self.cachePool addObject:page];
}

- (void)dequeuePageFromCachePool:(TLSwiperPage *)page {
    if (self.reusable && [self.cachePool containsObject:page]) {
        [self.cachePool removeObject:page];
    }
}

- (nullable TLSwiperPage *)dequeueReusablePageWithIdentifier:(NSString *)identifier {
    for (TLSwiperPage *page in self.cachePool) {
        if (self.reusable && page.pageView.superview != nil) continue;
        if ([page.reusableId isEqualToString:identifier]) return page;
    }
    
    return nil;
}
@end
