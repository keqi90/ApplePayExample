//
//  ViewControllerTwo.m
//  Apple Pay
//
//  Created by iwevon on 16/3/4.
//  Copyright © 2016年 iwevon. All rights reserved.
//  原作者Demo：https://github.com/wangshunzi/ApplePayDemo


#import "ViewControllerTwo.h"
#import <PassKit/PassKit.h>

@interface ViewControllerTwo () <PKPaymentAuthorizationViewControllerDelegate>

@property (weak, nonatomic) UIView *payView;

@end

@implementation ViewControllerTwo

- (UIView *)payView
{
    if (!_payView) {
        UIView *payView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        payView.center = CGPointMake(CGRectGetWidth(self.view.frame) * 0.5, CGRectGetHeight(self.view.frame) * 0.8);
        [self.view addSubview:payView];
        _payView = payView;
    }
    return _payView;
}


#pragma mark - viewDidLoad

/*
 extern NSString * const PKEncryptionSchemeECC_V2 NS_AVAILABLE_IOS(9_0);
 
 extern NSString * const PKPaymentNetworkAmex NS_AVAILABLE(NA, 8_0);
 extern NSString * const PKPaymentNetworkChinaUnionPay NS_AVAILABLE(NA, 9_2);
 extern NSString * const PKPaymentNetworkDiscover NS_AVAILABLE(NA, 9_0);
 extern NSString * const PKPaymentNetworkInterac NS_AVAILABLE(NA, 9_2);
 extern NSString * const PKPaymentNetworkMasterCard NS_AVAILABLE(NA, 8_0);
 extern NSString * const PKPaymentNetworkPrivateLabel NS_AVAILABLE(NA, 9_0);
 extern NSString * const PKPaymentNetworkVisa NS_AVAILABLE(NA, 8_0);
 
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    //1.判断当前设备是否支持Apple Pay
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设备不支持Appleq Pay" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alerView show];
        self.payView.hidden = YES;
        
    } else if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkChinaUnionPay]]) { //判断是否添加了一个银行卡
        
        //创建一个跳转按钮，当用户点击按钮时，跳转到添加银行卡的界面
        PKPaymentButton *setUpButton = [PKPaymentButton buttonWithType:PKPaymentButtonTypeSetUp style:PKPaymentButtonStyleWhiteOutline];
        [setUpButton addTarget:self action:@selector(setUpButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.payView addSubview:setUpButton];
    } else {
        
        //创建一个购买按钮，当用户点击按钮时，跳转到添加银行卡的界面
        PKPaymentButton *buyButton = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleBlack];
        [buyButton addTarget:self action:@selector(buyButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.payView addSubview:buyButton];
    }
}

#pragma mark - private

//跳转到添加银行卡界面
- (void)setUpButtonClick
{
    PKPassLibrary *pl = [[PKPassLibrary alloc] init];
    [pl openPaymentSetup];
}

//购买商品
- (void)buyButtonClick
{
    NSLog(@"购买商品，开始支付");
    //1.创建一个支付请求
    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
    // 1.1 配置支付请求
    // 1.1.1 配置商家ID
    request.merchantIdentifier = @"merchant.com.iwevon.applepay";
    
    // 1.1.2 配置货币代码，以及国家代码
    request.countryCode = @"CN";
    request.currencyCode = @"CNY";
    
    // 1.1.3 配置请求支持的支付网络
    request.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkChinaUnionPay];
    
    // 1.1.4 配置商户的处理方式
    request.merchantCapabilities = PKMerchantCapability3DS;
    
    // 1.1.5 配置购买的商品列表
    NSDecimalNumber *price1 = [NSDecimalNumber decimalNumberWithString:@"8.0"];
    PKPaymentSummaryItem *item1 = [PKPaymentSummaryItem summaryItemWithLabel:@"iPhone 6S" amount: price1];
    NSDecimalNumber *price11 = [NSDecimalNumber decimalNumberWithString:@"10.0"];
    PKPaymentSummaryItem *item11 = [PKPaymentSummaryItem summaryItemWithLabel:@"iPhone 5S" amount: price11];
    NSDecimalNumber *price111 = [NSDecimalNumber decimalNumberWithString:@"18.0"];
    PKPaymentSummaryItem *item111 = [PKPaymentSummaryItem summaryItemWithLabel:@"iPhone 5S + iPhone 6S" amount: price111];
    
    // 注意：支付列表最后一个，代表汇总
    request.paymentSummaryItems = @[item1, item11, item111];
    
    // 1.2 配置请求的附加项
    // 1.2.1 是否显示发票收货地址，显示哪些选项
    request.requiredBillingAddressFields = PKAddressFieldAll;
    // 1.2.2 是否显示快递地址，显示哪些选项
    request.requiredShippingAddressFields = PKAddressFieldAll;
    
    // 1.2.3.1 配置快递方式
    NSDecimalNumber *price2 = [NSDecimalNumber decimalNumberWithString:@"18.0"];
    PKShippingMethod *method1 = [PKShippingMethod summaryItemWithLabel:@"顺丰快递" amount:price2];
    method1.detail = @"24小时内送达";
    method1.identifier = @"shunfeng";
    
    NSDecimalNumber *price3 = [NSDecimalNumber decimalNumberWithString:@"16.0"];
    PKShippingMethod *method2 = [PKShippingMethod summaryItemWithLabel:@"韵达快递" amount:price3];
    method2.detail = @"送货上门";
    method2.identifier = @"yunda";
    request.shippingMethods = @[method1, method2];
    
    // 1.2.3.2 配置快递的类型
    request.shippingType = PKShippingTypeStorePickup;
    
    // 1.3 添加一些附加的数据
    request.applicationData = [@"buyID=123456" dataUsingEncoding:NSUTF8StringEncoding];
    
    //2.验证用户的支付授权
    PKPaymentAuthorizationViewController *avc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    avc.delegate = self;
    [self presentViewController:avc animated:YES completion:nil];
    
}



#pragma mark - PKPaymentAuthorizationViewControllerDelegate
/**
 *  如果当用户授权成功，就会调用该方法
 *
 *  @param controller 授权控制器
 *  @param payment    支付对象
 *  @param completion 系统给定的一个代码块，我们需要执行这个代码块，来告诉系统当前的支付状态是否成功
 */
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    // 一般在此处拿到支付信息，发送给服务器处理，处理完毕之后，服务端会发送一个状态，告诉客户端，是否支付成功，然后由客户端进行处理
    BOOL isSuccess = YES;
    
    if (isSuccess) {
        completion(PKPaymentAuthorizationStatusSuccess); // Merchant auth'd (or expects to auth) the transaction successfully.
    } else {
        completion(PKPaymentAuthorizationStatusFailure); // Merchant failed to auth the transaction
    }
}

// 当用户授权成功，或者取消授权时调用
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    NSLog(@"授权结束");
    [self dismissViewControllerAnimated:controller completion:nil];
}

#pragma mark - super function

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//  原作者Demo：https://github.com/wangshunzi/ApplePayDemo