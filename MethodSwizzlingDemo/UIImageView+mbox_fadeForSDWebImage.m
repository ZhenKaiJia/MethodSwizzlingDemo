//
//  UIImageView+mbox_fadeForSDWebImage.m
//  MethodSwizzlingDemo
//
//  Created by Memebox on 2017/8/7.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "UIImageView+mbox_fadeForSDWebImage.h"
#import <UIImageView+WebCache.h>
#import <objc/runtime.h>

@implementation UIImageView (mbox_fadeForSDWebImage)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        SEL originalSelector = @selector(sd_setImageWithURL:placeholderImage:);
        SEL swizzledSelector = @selector(sd_fadeSetImageWithURL:placeholderImage:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)sd_fadeSetImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    
    __weak typeof(self) weakSelf = self;
    
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageAvoidAutoSetImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (!weakSelf || error) {
            return ;
        }
        weakSelf.image = image;
        if (image || cacheType == SDImageCacheTypeNone) {
            CATransition *transition = [CATransition animation];
            transition.duration = 1;
            transition.type = kCATransitionFade;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.layer addAnimation:transition forKey:nil];
        }
        [weakSelf setNeedsLayout];
    }];
}

@end
