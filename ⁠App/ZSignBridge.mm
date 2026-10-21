#import "ZSignBridge.h"
#include <iostream>
#include <string>

// استدعاء ملف المعالجة الرئيسي الخاص بـ zsign
#import "vendor/zsign/bundle.h"

@implementation ZSignBridge

+ (BOOL)signIPA:(NSString *)ipaPath
        p12Path:(NSString *)p12Path
       provPath:(NSString *)provPath
       password:(NSString *)password
     outputPath:(NSString *)outputPath {
    
    std::string strIPA = [ipaPath UTF8String];
    std::string strP12 = [p12Path UTF8String];
    std::string strProv = [provPath UTF8String];
    std::string strPass = [password UTF8String];
    std::string strOut = [outputPath UTF8String];

    ZAppBundle bundle;
    // تهيئة وتوقيع الحزمة
    if (!bundle.SignFolder(strIPA, strP12, strProv, strPass, "", "", "", false)) {
        return NO;
    }
    return YES;
}

@end