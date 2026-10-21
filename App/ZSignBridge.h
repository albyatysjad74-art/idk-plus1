#import <Foundation/Foundation.h>

@interface ZSignBridge : NSObject

+ (BOOL)signIPA:(NSString *)ipaPath
        p12Path:(NSString *)p12Path
       provPath:(NSString *)provPath
       password:(NSString *)password
     outputPath:(NSString *)outputPath;

@end