#import <Foundation/Foundation.h>
typedef void(^SuccessBlock)(NSData* data, NSURLResponse *response);
typedef void(^FailBlock)(NSError *error);
@interface HttpTool:NSObject
+(instancetype)sharedHttpTool;
-(void)GetRequestWithUrl:(NSString *)urlStr params:(NSMutableDictionary *)params success:(SuccessBlock)success fail:(FailBlock)fail;
-(void)PostRequestWithUrl:(NSString *)urlStr params:(NSMutableDictionary *)params success:(SuccessBlock)success fail:(FailBlock)fail;
-(void)PostRequestWithURL: (NSString *)urlStr parems: (NSMutableDictionary*)parems picData: (NSData *)picData picName: (NSString *)picName success:(SuccessBlock)success fail:(FailBlock)fail;
@end
