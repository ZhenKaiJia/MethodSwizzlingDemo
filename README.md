# MethodSwizzling应用场景


###结合 **SDWebImage** 修改图片显示效果

**原理** `method swizzling` 实际上就是一种在运行时动态修改原有方法的技术, 它实际上是基于`ObjC runtime`的特性, 而 `method swizzling` 的核心方法就是 `method_exchangeImplementations(SEL origin, SEL swizzle)`使用这个方法就可以在运行时动态地改变原有的方法实现。

```
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
```

```
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
```