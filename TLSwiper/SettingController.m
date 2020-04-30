//
//  SettingController.m
//  TLSwiper
//
//  Created by Gxdy on 2020/4/30.
//  Copyright © 2020 Gxdy. All rights reserved.
//

#import "SettingController.h"


@implementation SettingItem
+ (instancetype)defaultItem {
    SettingItem *item = [[SettingItem alloc] init];
    item.isInfiniteFlow = YES;
    item.pageCount = 5;
    item.pageControlFrame = CGRectZero;
    item.scrollHorizontal = YES;
    item.autoPlay = NO;
    item.pageViewType = 0;
    item.inset = UIEdgeInsetsZero;
    
    return item;
}
@end




@interface SettingController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *scrollDirectionSgmt;
@property (weak, nonatomic) IBOutlet UISwitch *infiniteFlowSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoPlaySwitch;
@property (weak, nonatomic) IBOutlet UITextField *pageCountTextField;
@property (weak, nonatomic) IBOutlet UITextField *leftTextField;
@property (weak, nonatomic) IBOutlet UITextField *topTextField;
@property (weak, nonatomic) IBOutlet UITextField *bottomTextField;
@property (weak, nonatomic) IBOutlet UITextField *rightTextField;
@property (weak, nonatomic) IBOutlet UITextField *xTextField;
@property (weak, nonatomic) IBOutlet UITextField *yTextField;
@property (weak, nonatomic) IBOutlet UITextField *widthTextField;
@property (weak, nonatomic) IBOutlet UITextField *heightTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pageTypeSgmt;


@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)setSettingItem:(SettingItem *)settingItem {
    _settingItem = settingItem;
    
    _scrollDirectionSgmt.selectedSegmentIndex = settingItem.isScrollHorizontal ? 0 : 1;
    _infiniteFlowSwitch.on = settingItem.isInfiniteFlow;
    _autoPlaySwitch.on = settingItem.isAutoPlay;
    _pageCountTextField.text = @(settingItem.pageCount).stringValue;
    _leftTextField.text = @(settingItem.inset.left).stringValue;
    _topTextField.text = @(settingItem.inset.top).stringValue;
    _bottomTextField.text = @(settingItem.inset.bottom).stringValue;
    _rightTextField.text = @(settingItem.inset.right).stringValue;
    _xTextField.text = @(settingItem.pageControlFrame.origin.x).stringValue;
    _yTextField.text = @(settingItem.pageControlFrame.origin.y).stringValue;
    _widthTextField.text = @(settingItem.pageControlFrame.size.width).stringValue;
    _heightTextField.text = @(settingItem.pageControlFrame.size.height).stringValue;
    _pageTypeSgmt.selectedSegmentIndex = settingItem.pageViewType;
}

- (IBAction)commit:(id)sender {
    
    _settingItem.isInfiniteFlow = _infiniteFlowSwitch.isOn;
    _settingItem.pageCount = _pageCountTextField.text.integerValue;
    _settingItem.pageControlFrame = CGRectMake(_xTextField.text.floatValue,
                                               _yTextField.text.floatValue,
                                               _widthTextField.text.floatValue,
                                               _heightTextField.text.floatValue);
    _settingItem.scrollHorizontal = _scrollDirectionSgmt.selectedSegmentIndex == 0;
    _settingItem.autoPlay = _autoPlaySwitch.isOn;
    _settingItem.pageViewType = _pageTypeSgmt.selectedSegmentIndex;
    _settingItem.inset = UIEdgeInsetsMake(_topTextField.text.floatValue,
                                          _leftTextField.text.floatValue,
                                          _bottomTextField.text.floatValue,
                                          _rightTextField.text.floatValue);
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.commitCallback) {
            self.commitCallback(self.settingItem);
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0) {
        [textField resignFirstResponder];
    }else {
        UITextField *nextTextFiled = [textField.superview viewWithTag:textField.tag-1];
        [nextTextFiled becomeFirstResponder];
    }
    return YES;
}
@end
