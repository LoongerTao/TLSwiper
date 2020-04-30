//
//  SettingController.h
//  TLSwiper
//
//  Created by Gxdy on 2020/4/30.
//  Copyright © 2020 Gxdy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingItem : NSObject
@property(nonatomic, assign) BOOL isInfiniteFlow;
@property (assign, nonatomic) NSInteger pageCount;
@property(nonatomic, assign) CGRect pageControlFrame;
@property (assign, nonatomic, getter=isScrollHorizontal) BOOL scrollHorizontal;
@property(nonatomic, assign, getter=isAutoPlay) BOOL autoPlay;
@property(nonatomic, assign) NSInteger pageViewType;
@property(nonatomic, assign) UIEdgeInsets inset;

+ (instancetype)defaultItem;
@end




@interface SettingController : UIViewController
@property(nonatomic, strong) SettingItem *settingItem;
@property(nonatomic, copy) void(^commitCallback)(SettingItem *settingItem);
@end

NS_ASSUME_NONNULL_END
