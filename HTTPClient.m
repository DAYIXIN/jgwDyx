//
//  HTTPClient.m
//  cuotiben
//
//  Created by Alex on 13-5-14.
//  Copyright (c) 2013年 Flyrish.com. All rights reserved.
//

#import "CommonConstant.h"
#import "HTTPClient.h"
#import "SBJson.h"

@implementation HTTPClient
@synthesize delegate=_delegate;
@synthesize timeoutSeconds=_timeoutSeconds;
//@synthesize hasError=_hasError;
@synthesize errorMessage=_errorMessage;
@synthesize responsedString=_responsedString;
@synthesize needSaveCache=_needSaveCache;
@synthesize needLoadCacheIfFailed=_needLoadCacheIfFailed;

-(id) init
{
    if ((self= [super init]))
    {
        _timeoutSeconds = API_TIMEOUT_SECONDS;
    }
    return self;
}

-(id) initWithTarget:(id) delegate finishedAction:(SEL) finishedAction failedAction:(SEL) failedAction
{
    if ((self = [super init]))
    {
        self.delegate = delegate;
        _finishedAction = finishedAction;
        _failedActtion = failedAction;
        _timeoutSeconds = API_TIMEOUT_SECONDS;
    }
    return self;
}


#pragma mark - 子类必须覆盖的方法
- (BOOL)isResponseValid:(id)responseObj
{
    NSAssert(NO, @"Subclasses need to overwrite this method");
    return YES;
}

- (id)getData:(id)object
{
    NSAssert(NO, @"Subclasses need to overwrite this method");
    return nil;
}

-(NSString *) getErrorDetail: (id) object
{
    NSAssert(NO, @"Subclasses need to overwrite this method");
    return nil;
}

- (int)getErrorCode:(id)object
{
    NSAssert(NO, @"Subclasses need to overwrite this method");
    return 0;
}

-(void) saveToLocalCache: (NSString *) response
{
    NSAssert(NO, @"Subclasses need to overwrite this method");
}

-(NSString *) loadFromLocalCacheNoExpired
{
    NSAssert(NO, @"Subclasses need to overwrite this method");
    return nil;
}

#pragma mark - internal methods

-(NSString *) urlEncodeString: (NSString *)str
{
    if (str)
    {
        NSString* escapedUrlString =[str stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        return escapedUrlString;
    }
    else
        return nil;
}

-(NSString *) urlDecodeString: (NSString *)str
{
    if (str)
    {
        if (iOS6)
        {
            return [str stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        }
        else
        {
            NSString* notEscapedUrlString =[str stringByRemovingPercentEncoding];
            return notEscapedUrlString;
        }
        
    }
    else
        return nil;
}


- (NSString *)getURL:(NSString *)urlStr withParams:(NSDictionary *)params
{
    NSMutableString *tmpURL = [NSMutableString stringWithString:urlStr];
    NSArray *keyArray = [params allKeys];
    for (int i=0; i<[keyArray count]; i++)
    {
        NSString *key = [keyArray objectAtIndex:i];
        id obj = [params objectForKey:key];
        [tmpURL appendString: ((i==0)?@"?":@"&")];
        [tmpURL appendFormat:@"%@=%@", [self urlEncodeString:key], [self urlEncodeString: [obj description]]];
    }
    return tmpURL;
}

-(void) sendAsynchronousHttpGetRequestWithURL: (NSString *) urlString
{
    //TODO: Alex: 20140211
    //Reachability *reach = [Reachability reachabilityForInternetConnection];
    //if ([reach isReachable]) //网络可用
    {
        [_commonUtils myLogString: 3 :@"HTTP asynchronous get: " : urlString];
        NSURL * url = [NSURL URLWithString: urlString];
        _urlRequest = [[NSMutableURLRequest alloc] initWithURL: url cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_timeoutSeconds];
        //_urlRequest = [[NSMutableURLRequest alloc] initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeoutSeconds];
        [_urlRequest setHTTPMethod: @"GET"];
        
        _urlConnection = [[NSURLConnection alloc] initWithRequest: _urlRequest delegate:self startImmediately:YES];
    }
//    else  //无网络可用
//    {
//        _errorMessage = @"请检查网络";
//        if (_failedActtion)
//            [_delegate performSelector: _failedActtion withObject: self withObject: nil];
//    }
}

-(void) analysisError:(NSError *) error
{
    /* CFURL and CFURLConnection Errors
     kCFURLErrorUnknown   = -998,
     kCFURLErrorCancelled = -999,
     kCFURLErrorBadURL    = -1000,
     kCFURLErrorTimedOut  = -1001,
     kCFURLErrorUnsupportedURL = -1002,
     kCFURLErrorCannotFindHost = -1003,
     kCFURLErrorCannotConnectToHost    = -1004,
     kCFURLErrorNetworkConnectionLost  = -1005,
     kCFURLErrorDNSLookupFailed        = -1006,
     kCFURLErrorHTTPTooManyRedirects   = -1007,
     kCFURLErrorResourceUnavailable    = -1008,
     kCFURLErrorNotConnectedToInternet = -1009,
     kCFURLErrorRedirectToNonExistentLocation = -1010,
     kCFURLErrorBadServerResponse             = -1011,
     kCFURLErrorUserCancelledAuthentication   = -1012,
     kCFURLErrorUserAuthenticationRequired    = -1013,
     kCFURLErrorZeroByteResource        = -1014,
     kCFURLErrorCannotDecodeRawData     = -1015,
     kCFURLErrorCannotDecodeContentData = -1016,
     kCFURLErrorCannotParseResponse     = -1017,
     kCFURLErrorInternationalRoamingOff = -1018,
     kCFURLErrorCallIsActive               = -1019,
     kCFURLErrorDataNotAllowed             = -1020,
     kCFURLErrorRequestBodyStreamExhausted = -1021,
     kCFURLErrorFileDoesNotExist           = -1100,
     kCFURLErrorFileIsDirectory            = -1101,
     kCFURLErrorNoPermissionsToReadFile    = -1102,
     kCFURLErrorDataLengthExceedsMaximum   = -1103
     */
    switch ( [error code])
    {
        case -998:
            _errorMessage = @"未知错误";
            break;
        case -999:
            _errorMessage = @"请求被取消";
            break;
        case -1000:
            _errorMessage = @"错误的URL";
            break;
        case -1001:
            _errorMessage = @"访问超时";
            break;
        case -1002:
            _errorMessage = @"不支持的URL";
            break;
        case -1003:
            _errorMessage = @"服务器找不到";
            break;
        case -1004:
            _errorMessage = @"无法连接服务器";
            break;
        case -1005:
            _errorMessage = @"无网络连接";
            break;
        case -1006:
            _errorMessage = @"DNS失败";
            break;
        case -1007:
            _errorMessage = @"跳转太多";
            break;
        case -1008:
            _errorMessage = @"资源不可用";
            break;
        case -1009:
            _errorMessage = @"没有连接到网络";
            break;
        case -1010:
            _errorMessage = @"跳转到不存在的地址";
            break;
        case -1011:
            _errorMessage = @"服务器响应错误";
            break;
        case -1012:
            _errorMessage = @"";
            break;
        case -1013:
            _errorMessage = @"";
            break;
        case -1014:
            _errorMessage = @"";
            break;
        case -1015:
            _errorMessage = @"";
            break;
        case -1016:
            _errorMessage = @"";
            break;
        case -1017: 
            _errorMessage = @""; 
            break;
        case -1018: 
            _errorMessage = @""; 
            break;
        case -1019: 
            _errorMessage = @""; 
            break;
        case -1020: 
            _errorMessage = @""; 
            break;
        case -1021: 
            _errorMessage = @""; 
            break;
        case -1100: 
            _errorMessage = @""; 
            break;
        case -1101: 
            _errorMessage = @""; 
            break;
        case -1102: 
            _errorMessage = @""; 
            break;
        case -1103: 
            _errorMessage = @""; 
            break;
        default:
            break;
    }
    [_commonUtils myLogString:3 : @"错误信息": [error description]];

}

#pragma mark - public methods

//异步调用之后处理数据, 需要回调
-(void) handleAsynchronousResponse: (NSString *) responseString
{
    id object = [responseString JSONValue];
    
    if (object)
    {
        _errorMessage = nil;
        
        if ([self isResponseValid:object])
        {
            id responsedData = [self getData: object];
            if (self.needSaveCache)
            {
                [self saveToLocalCache: [responsedData JSONRepresentation]];
            }
            [_delegate performSelector: _finishedAction withObject: self withObject: responsedData];
        }
        else
        {
            if (self.needLoadCacheIfFailed)
            {
                NSString * cachedResponsedDataString = [self loadFromLocalCacheNoExpired];
                if (cachedResponsedDataString)
                {
                    [_delegate performSelector: _finishedAction withObject: self withObject: [cachedResponsedDataString JSONValue]];
                    return;
                }
            }
            else
            {
                if ([object isKindOfClass:[NSDictionary class]])
                {
                    _errorMessage = [self getErrorDetail:object];
                }
                [_delegate performSelector: _failedActtion withObject: self withObject: _errorMessage];
            }
        }
    }
    else
    {
        NSRange range = [responseString rangeOfString: @"404 Not Found" options: NSCaseInsensitiveSearch];
        if (range.length>0)
            _errorMessage = @"接口不存在";
        else
        {
            [_commonUtils myLogString: 3 : _responsedString];
            _errorMessage = @"未知错误";
        }
    }
}


//同步调用时处理结果数据, 没有回调
-(id) handleSynchronousResponse
{
    [_commonUtils myLogString:3 :@"Responsed:" : _responsedString];
    
    id object = [_responsedString JSONValue];
    
    if (object) //合法的JSON数据
    {
        _errorMessage = nil;
        if ([self isResponseValid:object])
        {
            id responsedData = [self getData: object];
            if (self.needSaveCache)
            {
                [self saveToLocalCache: [responsedData JSONRepresentation]];
            }
            return responsedData;
        }
        else
        {
            if ([object isKindOfClass:[NSDictionary class]])
            {
                _errorMessage = [self getErrorDetail:object];
            }
            return nil;
        }
    }
    else //非JSON数据
    {
        NSRange range = [_responsedString rangeOfString: @"404 Not Found" options: NSCaseInsensitiveSearch];
        if (range.length>0)
            _errorMessage = @"接口不存在";
        else
        {
            [_commonUtils myLogString: 3 : _responsedString];
            _errorMessage = @"未知错误";
        }
        return nil;
    }
}

-(void) stopHttpRequest
{
    _urlRequest = nil;
    if (_urlConnection)
    {
        [_urlConnection cancel];
        _urlConnection = nil;
    }
}

-(id) sendSynchronousHttpGetRequestWithURL: (NSString *) url params:(NSDictionary *)params
{
    if (!NO_NETWORK) //网络可用
    {
        NSString * urlWithParams = [self getURL: url withParams: params];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlWithParams]];
        [request setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
        //[request setCachePolicy: NSURLRequestUseProtocolCachePolicy];
        [request setTimeoutInterval: _timeoutSeconds];
        [request setHTTPMethod: @"GET"];
        [_commonUtils myLogString:3 :@"HTTP synchronous get:" : urlWithParams];
        NSError * error;
        NSData * receivedData = [NSURLConnection sendSynchronousRequest: request returningResponse:nil error: &error];
        if (error)
        {
            [self analysisError: error];
            return nil;
        }
        else
        {
            _responsedString = [[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding];
            return [self handleSynchronousResponse];
        }
    }
    else  //无网络可用
    {
        _errorMessage = @"请检查网络";
        return nil;
    }
}

-(id) sendSynchronousHttpPostRequestWithURL: (NSString *) url params:(NSDictionary *)params
{
    if (!NO_NETWORK) //网络可用
    {
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]];
        [request setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        [request setTimeoutInterval: _timeoutSeconds];
        [request setHTTPMethod: @"POST"];
        [_commonUtils myLogString:3 :@"HTTP synchronous post:" :url];
        
        if ([params count]>0)
        {
            NSMutableString * httpBodyStr = [[NSMutableString alloc] init];
            NSArray * allKeys = [params allKeys];
            for (int i=0; i<[allKeys count]; i++)
            {
                if (i!=0)
                    [httpBodyStr appendString: @"&"];
                NSString * key = [allKeys objectAtIndex: i];
                NSString * value = [[params objectForKey: key] description];
                [httpBodyStr appendFormat: @"%@=%@", [self urlEncodeString: key] ,[self urlEncodeString:value]];
            }
            [request setHTTPBody: [httpBodyStr dataUsingEncoding: NSUTF8StringEncoding]];
            [_commonUtils myLogString:3 :@"HTTP Body:" : [self urlDecodeString: httpBodyStr]];
        }

        NSError * error;
        NSData * receivedData = [NSURLConnection sendSynchronousRequest: request returningResponse:nil error: &error];
        
        if (error)
        {
            [self analysisError: error];
            return nil;
        }
        else
        {
            _responsedString = [[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding];
            return [self handleSynchronousResponse];
        }
    }
    else  //无网络可用
    {
        _errorMessage = @"请检查网络";
        return nil;
    }
    

}

-(void) sendAsynchronousHttpGetRequestWithURL: (NSString *) url params:(NSDictionary *)params
{
    [self sendAsynchronousHttpGetRequestWithURL: [self getURL: url withParams: params]];
}

-(void) sendAsynchronousHttpPostRequestWithURL: (NSString *) url params:(NSDictionary *)params
{
    if (!NO_NETWORK) //网络可用
    {
        _urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]];
        [_urlRequest setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        [_urlRequest setTimeoutInterval: _timeoutSeconds];
        [_urlRequest setHTTPMethod: @"POST"];
        [_commonUtils myLogString: 3 :@"HTTP asynchronous Post:" :url];
        if ([params count]>0)
        {
            NSArray * allKeys = [params allKeys];
            NSMutableString * httpBodyStr = [NSMutableString stringWithFormat: @"%@=%@", [allKeys objectAtIndex:0],[self urlEncodeString:[params objectForKey: [allKeys objectAtIndex:0]]]];
            
            for (int i=1; i<[allKeys count]; i++)
            {
                NSString * key = [allKeys objectAtIndex: i];
                NSString * value = [[params objectForKey: key] description];
                [httpBodyStr appendFormat: @"&%@=%@", [self urlEncodeString: key] ,[self urlEncodeString:value]];
            }
            [_urlRequest setHTTPBody: [httpBodyStr dataUsingEncoding: NSUTF8StringEncoding]];
            [_commonUtils myLogString:3 :@"HTTP Body:" : [self urlDecodeString: httpBodyStr]];
        }
        _urlConnection = [[NSURLConnection alloc] initWithRequest:_urlRequest delegate:self];
        [_urlConnection start];
    }
    else  //无网络可用
    {
        _errorMessage = @"请检查网络";
        if (_failedActtion)
            [_delegate performSelector: _failedActtion withObject: self withObject: nil];
    }

}


#pragma mark - NSURLConnectionDataDelegate
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"didReceiveResponse");
    _receivedData = [[NSMutableData alloc] init];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"didReceiveData");
    [_receivedData appendData: data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    _responsedString = [[NSString alloc] initWithData: _receivedData encoding: NSUTF8StringEncoding];
    
    [_commonUtils myLogString: 3 : @"Asynchronous requet url: ": [connection.currentRequest.URL absoluteString]];
    [_commonUtils myLogString:3 :@"Asynchronous request returned:\n" :_responsedString];
    _responsedString = [_responsedString stringByReplacingOccurrencesOfString:@"\\u0000" withString:@" "];
    [self handleAsynchronousResponse: _responsedString];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //网络调用失败后, 读取缓存
    if (self.needLoadCacheIfFailed)
    {
        NSString * cachedResponsedDataString = [self loadFromLocalCacheNoExpired];
        if (cachedResponsedDataString)
        {
            [_delegate performSelector: _finishedAction withObject: self withObject: [cachedResponsedDataString JSONValue]];
            return;
        }
    }
    
    [self analysisError: error];
    
    if (_failedActtion)
        [_delegate performSelector: _failedActtion withObject: self withObject: nil];
}

-(void) setNeedSaveCache
{
    _needSaveCache = YES;
}

-(void) setNeedLoadCacheIfFailed
{
    _needLoadCacheIfFailed = YES;
}




@end
