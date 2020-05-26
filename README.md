# TLSwiper

### 示例图片
![TLSwiper](https://upload-images.jianshu.io/upload_images/3333500-bb9fe94201a28364.gif?imageMogr2/auto-orient/strip)

### 组件特性
- 支持无限轮播（可关闭）
- 支持自动轮播（可关闭）
- 自带页码组件（可隐藏，支持样式调整）
- 支持横向和垂直两个滚动方向
- 每个页面都可自定义（可以轮播不同类型的页面）
- 页面自动缓存和复用，也可以关闭复用（关闭后每个页面都需要有一个唯一的复用标识符，一些特殊情况下复用可能带来一些负面影响，这些情况下可以关闭复用）
- 使用风格与UITableView类似

### 使用
> 集成
- 不支持pod
- 直接倒入`TLSwiper.h和TLSwiper.m`文件即可

> 演示代码
```objc
// 1. 创建swiper
TLSwiper *swiper = [TLSwiper swiperWithDelegate:self];

// 2. 属性设置
swiper.frame = self.view.frame;
swiper.isInfiniteFlow = YES;
swiper.autoPlay = YES;

// 3. 设置页码组件样式
swiper.pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
swiper.pageControl.currentPageIndicatorTintColor = [UIColor systemRedColor];
[self.view addSubview:swiper];


// 4. 实现数据源方法 TLSwiperDataSourceAndDelegate

// 返回总页数
- (NSInteger)numberOfPageInSwiper:(TLSwiper *)swiper {
    return _settingItem.pageCount;
}

/// 返回对应页面的page
- (TLSwiperPage *)swiper:(TLSwiper *)swiper pageForIndex:(NSUInteger)index {
    int type = index < 4;
    NSString *ID = type ? @"image page" : @"label page";
    TLSwiperPage *page = [swiper dequeueReusablePageWithIdentifier:ID]; // 从缓存池获取page
    
    if (!page) {
        UIView *pageView = [self pageViewWithType:type];
        page = [TLSwiperPage pageWithView:pageView reusableIdentifier:ID]; // 创建page
    }
    
    page.inset = _settingItem.inset; // page相对于swiper的缩进
    if (type == 0) {
        UILabel *label = page.pageView;
        label.text = @(index+1).stringValue;
        label.backgroundColor = index % 2 ? [UIColor systemTealColor] : [UIColor systemGreenColor];
    }else {
        UIImageView *imgView = page.pageView;
        imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%zi", index % 9]];
    }
    return page;
}

- (UIView *)pageViewWithType:(int)type {
    UIView *pageView = nil;
    if (type == 0) { // label page
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont boldSystemFontOfSize:200];
        pageView = label;

    }else { // image page
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.backgroundColor = [UIColor tertiarySystemGroupedBackgroundColor];
        imgView.clipsToBounds = YES;
        pageView = imgView;
    }
    
    return pageView;
}

```



