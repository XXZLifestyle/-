//
//  ViewController.m
//  动态下载系统提供的多重中文字体
//
//  Created by Jiayu_Zachary on 16/1/5.
//  Copyright © 2016年 Zachary. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController () {
    UILabel *_label;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadLabel];
    
    [self start];
}

- (void)start {
    //https://support.apple.com/zh-cn/HT202599 //字体册
    
//    [self getAllFontName]; //获取获取IOS所有字体名字
    
    NSString *fontName = @"Zapfino"; //@"DFWaWaSC-W5";
    
    BOOL isHave = [self isFontDownloadedWithFontName:fontName fontSize:30.0];
    
    if (!isHave) {
        [self downloadFontWithFontName:fontName];
    }
    else {
        NSLog(@"字体已经存在!");
        _label.font = [UIFont fontWithName:fontName size:30.0];
    }
}

- (void)downloadFontWithFontName:(NSString *)fontName {
    //用字体的PostScript名字创建一个Dictionary
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontName, kCTFontNameAttribute, nil];
    
    //创建一个字体描述对象CTFontDescriptorRef
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attrs);
    
    //将字体描述对象放到一个NSMutableArray
    NSMutableArray *descsArr = [NSMutableArray arrayWithCapacity:0];
    [descsArr addObject:(__bridge id)desc];
    CFRelease(desc);
    
    //开始下载
    __block BOOL errorDuringDownload = NO;
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler((__bridge CFArrayRef)descsArr, NULL, ^bool(CTFontDescriptorMatchingState state, CFDictionaryRef  _Nonnull progressParameter) {
        
        double progressValue = [[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
        
        if (state == kCTFontDescriptorMatchingDidBegin) {
            NSLog(@"字体已经匹配!");
        }
        else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            NSLog(@"字体开始下载!");
        }
        else if (state == kCTFontDescriptorMatchingDidFinish) {
            NSLog(@"字体%@ 下载完成!", fontName);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //修改控件的字体
                _label.font = [UIFont fontWithName:fontName size:30.0];
                
            });
        }
        else if (state == kCTFontDescriptorMatchingDidFinishDownloading) {
            NSLog(@"字体下载完成!");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //修改控件的字体
                
                
            });
            
        }
        else if (state == kCTFontDescriptorMatchingDownloading) {
            NSLog(@"下载进度%.2f%%", progressValue);
        }
        else if (state == kCTFontDescriptorMatchingDidFailWithError) {
            NSError *error = [(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingError];
            
            NSString *errorMsg = nil;
            if (error != nil) {
                errorMsg = [error description];
            }
            else {
                errorMsg = @"ERROR MESSAGE IS NOT AVAILABLE!";
            }
            
            //设置标志
            errorDuringDownload = YES;
            NSLog(@"下载错误:%@", errorMsg);
        }
        
        return (BOOL)YES;
    });
}

//判断字体是否已下载
- (BOOL)isFontDownloadedWithFontName:(NSString *)familyName fontSize:(float)fontSize{
    //传进Name里的参数是familyName而不是fontName。
    UIFont *aFont = [UIFont fontWithName:familyName size:fontSize];
    
    NSLog(@"fontName = %@, familyName = %@", aFont.fontName, aFont.familyName);
    
    if (aFont && ([aFont.fontName compare:familyName] == NSOrderedSame || [aFont.familyName compare:familyName] == NSOrderedSame)) {
        return YES;
    }
    else {
        return NO;
    }
}

//获取获取IOS所有字体名字
- (void)getAllFontName {
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily) {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        
        for (indFont=0; indFont<[fontNames count]; ++indFont){
            NSLog(@"Font name: %@", [fontNames objectAtIndex:indFont]);
        }
    }
}

#pragma mark - loading
- (void)loadLabel {
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(5, 100, self.view.frame.size.width-5*2, 50);
    _label.backgroundColor = [UIColor lightGrayColor];
    _label.text = @"北京驾遇互联科技有限公司";
    _label.font = [UIFont systemFontOfSize:30.0];
    
    [self.view addSubview:_label];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
