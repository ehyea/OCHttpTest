#import "HttpTool.h"
#import "NSString+URL.h"
@implementation HttpTool
+(instancetype)sharedHttpsTool{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(void)GetRequestWithUrl:(NSString *)urlStr params:(NSMutableDictionary *)params success:(SuccessBlock)success fail:(FailBlock)fail{
    NSMutableString *strM = [[NSMutableString alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop){
        NSString *paramsKey = key;
        NSString *paramsValue = obj;
        [strM appendFormat:@"%@=%@&", paramsKey, [paramsValue URLEncodedString]];
    }];
    NSString *urlQuery = [strM substringToIndex:strM.length - 1];
    
    urlStr = [NSString stringWithFormat:@"%@?%@",urlStr, urlQuery];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success(data,response);
                }
                
            });
        }else{
            if (fail) {
                fail(error);
            }
        }
        
    }] resume];
    
}
-(void)PostRequestWithUrl:(NSString *)urlStr params:(NSMutableDictionary *)params success:(SuccessBlock)success fail:(FailBlock)fail{
    NSMutableString *strM = [[NSMutableString alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop){
        NSString *paramsKey = key;
        NSString *paramsValue = obj;
        [strM appendFormat:@"%@=%@&", paramsKey, [paramsValue URLEncodedString]];
    }];
    NSString *body = [strM substringToIndex:strM.length - 1];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    //封装
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    request.HTTPBody = bodyData;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success(data,response);
                }
            });
        }else{
            if (fail) {
                fail(error);
            }
        }
    }] resume];
    
}
-(void)PostRequestWithURL: (NSString *)urlStr parems: (NSMutableDictionary*)parems picData: (NSData *)picData picName: (NSString *)picName success:(SuccessBlock)success fail:(FailBlock)fail
{
    NSString *TWITTERFON_FORM_BOUNDARY = @"0xKhTmLbOuNdArY";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:15];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    NSArray *keys= [parems allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++)
    {
        //得到当前key
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [[parems objectForKey:key] URLDecodedString];
        //添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        //添加字段的值
        [body appendFormat:@"%@\r\n",value];
        
        //NSLog(@"添加字段的值==%@",value);
    }
    
    if(picData){
        ////添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        
        //声明pic字段，
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file", picName];
        //声明上传文件的格式
        [body appendFormat:@"Content-Type: image/jpeg, image/png\r\n\r\n"];
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    if(picData){
        //将image的data加入
        [myRequestData appendData:picData];
    }
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success(data,response);
                }
            });
        }else{
            if (fail) {
                fail(error);
            }
        }
    }] resume];
    
}
@end
