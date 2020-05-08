//
//  ViewController.m
//  TLSwiper
//
//  Created by Gxdy on 2020/4/26.
//  Copyright © 2020 Gxdy. All rights reserved.
//

#import "ViewController.h"
#import "TLSwiper.h"
#import "SettingController.h"

@interface ViewController ()<TLSwiperDataSourceAndDelegate>
@property(nonatomic, strong) SettingItem *settingItem;
@property(nonatomic, weak) TLSwiper *swiper;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TLSwiper *swiper = [TLSwiper swiperWithDelegate:self];
    swiper.frame = self.view.frame;
    swiper.pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    swiper.pageControl.currentPageIndicatorTintColor = [UIColor systemRedColor];
    [self.view addSubview:swiper];
    _swiper = swiper;
    
    self.settingItem = [SettingItem defaultItem];
    
    UIButton *btn = [UIButton systemButtonWithImage:[UIImage imageNamed:@"setting"] target:self action:@selector(setting)];
    btn.frame = CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height - 80, 40, 40);
    btn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    btn.layer.cornerRadius = 20;
    btn.clipsToBounds = YES;
    [self.view addSubview:btn];
}

- (void)setting {
    SettingController *vc = [SettingController new];
    vc.settingItem = self.settingItem;
    vc.commitCallback = ^(SettingItem * _Nonnull settingItem) {
        self.settingItem = settingItem;
    };
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)setSettingItem:(SettingItem *)settingItem {
    _settingItem = settingItem;
    
    _swiper.isInfiniteFlow = settingItem.isInfiniteFlow;
    _swiper.pageControlFrame = settingItem.pageControlFrame;
    _swiper.scrollHorizontal = settingItem.isScrollHorizontal;
    _swiper.autoPlay = settingItem.autoPlay;
    
    [_swiper reloadData];
}

// MARK: - TLSwiperDataSourceAndDelegate
/// 返回总页数
- (NSInteger)numberOfPageInSwiper:(TLSwiper *)swiper {
    return _settingItem.pageCount;
}

/// 返回对应页面的page。可以使用`- dequeueReusablePageWithIdentifier`从缓存池中获取page
- (TLSwiperPage *)swiper:(TLSwiper *)swiper pageForIndex:(NSUInteger)index {
    NSString *ID = _settingItem.pageViewType == 0 ? @"image page" : @"label page";
    TLSwiperPage *page = [swiper dequeueReusablePageWithIdentifier:ID];
    
    if (!page) {
        UIView *pageView = nil;
        if (_settingItem.pageViewType) {
            UILabel *label = [UILabel new];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor lightGrayColor];
            label.font = [UIFont boldSystemFontOfSize:200];
            pageView = label;
        }else {
            UIImageView *imgView = [[UIImageView alloc] init];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.backgroundColor = [UIColor tertiarySystemGroupedBackgroundColor];
            imgView.clipsToBounds = YES;
            pageView = imgView;
        }
        
        page = [TLSwiperPage pageWithView:pageView reusableIdentifier:ID];
    }
    page.inset = _settingItem.inset;
    if (_settingItem.pageViewType) {
        UILabel *label = page.pageView;
        label.text = @(index+1).stringValue;
        label.backgroundColor = index % 2 ? [UIColor systemTealColor] : [UIColor systemGreenColor];
    }else {
        UIImageView *imgView = page.pageView;
        imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%zi", index % 9]];
    }
    return page;
}

/// 会重复调用
- (void)swiper:(TLSwiper *)swiper didDisplayPage:(TLSwiperPage *)page atIndex:(NSUInteger)index {
    NSLog(@"page复用测试： %p", page);
}

@end


// MARK: - TODO:
/*
 
 1. 非无限流，自动播放，第一页和最后一页不对
 2. demo还待完善
 
 */
