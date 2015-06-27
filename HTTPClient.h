//
//  HTTPClient.h
//  cuotiben
//
//  Created by Alex on 13-5-14.
//  Copyright (c) 2013年 Flyrish.com. All rights reserved.
//


typedef enum HTTP_METHOD
{
    HTTP_GET = 0,
    HTTP_POST = 1
} HTTP_METHOD;

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface HTTPClient : NSObject <NSURLConnectionDataDelegate>
{
    SEL                     _finishedAction; //完成动作
    SEL                     _failedActtion; //动作失败
    
    NSMutableURLRequest     *_urlRequest;
    NSURLConnection         *_urlConnection;
    NSMutableData           *_receivedData;
}
@property int tag;  //增加一个tag by Alex 07/24/2013
@property int pageNo; //增加一个页码， 第1页数据替换本地所有列表， 非第1页数据追加
@property (weak, nonatomic) id delegate;
@property int timeoutSeconds;
//@property (readonly) BOOL hasError;
@property (strong, nonatomic) NSString * errorMessage;
@property (strong, nonatomic, readonly) NSString * responsedString;
@property (readonly) BOOL needSaveCache;
@property (readonly) BOOL needLoadCacheIfFailed;


-(id) initWithTarget:(id) delegate finishedAction:(SEL) finishedAction failedAction:(SEL) failedAction;
//停止请求任务的方法
-(void) stopHttpRequest;
//-(void) handleAsynchronousResponse: (NSString *) responseString;
//get(同步)
-(NSString *) sendSynchronousHttpGetRequestWithURL: (NSString *) url params:(NSDictionary *)params;
//post(同步)
-(NSString *) sendSynchronousHttpPostRequestWithURL: (NSString *) url params:(NSDictionary *)params;
//get(异步)
-(void) sendAsynchronousHttpGetRequestWithURL: (NSString *) url params:(NSDictionary *)params;
//post(同步)
-(void) sendAsynchronousHttpPostRequestWithURL: (NSString *) url params:(NSDictionary *)params;

//两个set方法，修改只读属性的值
-(void) setNeedSaveCache;
-(void) setNeedLoadCacheIfFailed;


@end
