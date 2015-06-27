//
//  CuoTiBenClient.m
//  cuotiben
//
//  Created by Alex on 13-5-13.
//  Copyright (c) 2013年 Flyrish.com. All rights reserved.
//

#import "JGWClient.h"
#import "CommonConstant.h"
#import "SBJson.h"
#import "NSString+MD5.h"
//#import "GexinSdk.h"

#define CLIENT_ID_VALUE_KEY CLIENT_ID,@"clientID"
#define DEVICE_VALUE_KEY Device,@"device"
#define VERSION_VALUE_KEY AppVersion,@"appVersion"

#define TOKEN_VALUE_KEY Token,@"token"


static JGWClient * _INS;


@implementation JGWClient
@synthesize localCacheKey=_localCacheKey;

//调整顺序 by Alex 07/20/2013
+(JGWClient *) clientWithTarget:(id)target finishedAction:(SEL) finishedAction failedAction:(SEL) failedAction
{
    return [[JGWClient alloc] initWithTarget: target finishedAction: finishedAction failedAction: failedAction];
}

//sharedClient是封装的接口类的一个实例
+(JGWClient *) sharedClient
{
	@synchronized(self)
	{
		if (_INS == nil)
		{
			_INS = [[self alloc] initWithTarget:nil finishedAction:nil failedAction:nil];
		}
	}
	return _INS;
}

#pragma mark - 子类 必须覆盖的方法
- (BOOL)isResponseValid:(id)responseObj
{
#if MOCK
    int r = arc4random()%5;
    [_commonUtils myLogLevel: 3 andString: @"mock sleep seconds " andInt: r];
    [_commonUtils mySleep: r];
#endif
    
    if ([responseObj isKindOfClass:[NSDictionary class]])
    {
        int result = [[responseObj objectForKey: @"Result"] intValue];
        if (result==1)
        {
            self.errorMessage = [responseObj objectForKey: @"Error"]; //20150401，返回结果正确时也有可能带一些错误信息，比如部分积分码积分失败。
            if ([self.errorMessage length]==0)
                self.errorMessage = nil;
            return YES;
        }
        else
        {
            if (result==0)
            {
                self.errorMessage = [responseObj objectForKey: @"Error"];
                if ([self.errorMessage length]==0)
                    self.errorMessage = @"未知错误";
            }
            else if (result==-1)
            {
                self.errorMessage = @"参数错误";
            }
            else if (result==-2)
            {
                self.errorMessage = @"Token异常";
            }
            else if (result==-3)
            {
                self.errorMessage = @"验证码错误";
            }
            
//            if ([responseObj objectForKey: @"Error"])
//                self.errorMessage = [responseObj objectForKey: @"Error"];
        }
        
        
        return NO;
    }
    else //返回内容不是有效的JSON格式数据
    {
        self.errorMessage = @"未知错误";
        return NO;
    }
}

- (id)getData:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        id data = [object objectForKey:@"Data"];
        if ([data isEqual: [NSNull null]])
            return nil;
        else if ([data isKindOfClass: [NSString class]])
        {
            if ([data length]==0)
                return nil;
            else
                return data;
        }
        else
            return data;
    }
    return nil;
}

-(NSString *) getErrorDetail: (id) object
{
    //DONE: owner: Alex
    return self.errorMessage;
}

- (int)getErrorCode:(id)object
{
    int errorCode = 0;
    if ([object isKindOfClass:[NSDictionary class]])
    {
        errorCode =  IntValue(object,@"action_result");
    }
    return errorCode;
}

-(void) saveToLocalCache: (NSString *) response
{
    [_commonUtils myLogString: 3 : [NSString stringWithFormat: @"save to local cache with key: %@",self.localCacheKey]];
    [USER_DEFAULT setObject: response forKey: self.localCacheKey];
}

#pragma mark - 内部方法
//从本地cache中加载(cache有失效)
-(NSString *) loadFromLocalCache
{
    [_commonUtils myLogString: 3 : [NSString stringWithFormat: @"load from local cache by key: %@",self.localCacheKey]];
    NSString * savedResponse = [USER_DEFAULT objectForKey: self.localCacheKey];
    if (savedResponse)
    {
        return savedResponse;
    }
    else
    {
        return nil;
    }
}

//从本地cache中加载(cache无失效)
-(NSString *) loadFromLocalCacheNoExpired
{
    //NSLog(@"loadFromLocalCacheNoExpired");
    NSString * timedString = [USER_DEFAULT objectForKey: self.localCacheKey];
    if (timedString)
    {
        return [_commonUtils valueOfTimedString: timedString];
    }
    else
    {
        return nil;
    }
}

//异步调用接口
//url: 接口http地址
//method: get或post
//cacheKey: 保存或加载cache的key, 为nil时不使用cache
//cacheFirst: 是否cache优先,此参数仅当上一参数不为nil时有效. cache优先时, 先从cache中找, 没有找到再调用接口.   cache不优先时, 只有网络调用失败, 才去cache中找
-(void) callAsynchronousAPI: (NSString *) url method:(HTTP_METHOD) method useCache: (NSString *) cacheKey cacheFirst:(BOOL) cacheFirst andParams:(NSDictionary *) params
{
    
#if MOCK
    url = [NSString stringWithFormat: @"%@/%@", url, [params objectForKey: @"function"]];
#endif

    if (cacheKey) //使用cache
    {
        _localCacheKey = cacheKey;
        
        if (cacheFirst) ////优先使用Cache, cache里没有或已失效, 才使用网络
        {
            NSString * cachedReturnDataString = [self loadFromLocalCache];
            if (cachedReturnDataString) //cache命中
            {
                [self.delegate performSelector: _finishedAction withObject: self withObject: [cachedReturnDataString JSONValue]];
            }
            else //cache没有命中
            {
                [self setNeedSaveCache];
                [self setNeedLoadCacheIfFailed];  //如果网络失败, 则使用不失效的cache数据
                if (method==HTTP_POST)
                    [self sendAsynchronousHttpPostRequestWithURL: url params: params];
                else
                    [self sendAsynchronousHttpGetRequestWithURL: url params: params];
            }
        }
        else  //网络调用优先, 失败才找cache  
        {
            [self setNeedSaveCache];  //网络调用成功需要写缓存
            [self setNeedLoadCacheIfFailed]; //网络调用失败需要读取缓存 (因为是异步调用, 必须在父类中判断是否失败)
            if (method==HTTP_POST)
                [self sendAsynchronousHttpPostRequestWithURL: url params: params];
            else
                [self sendAsynchronousHttpGetRequestWithURL: url params: params];
        }
    }
    else
    {
        if (method==HTTP_POST)
            [self sendAsynchronousHttpPostRequestWithURL: url params: params];
        else
            [self sendAsynchronousHttpGetRequestWithURL: url params: params];
    }
}

//同步调用接口
//url: 接口http地址
//method: get或post
//cacheKey: 保存或加载cache的key, 为nil时不使用cache
//cacheFirst: 是否cache优先,此参数仅当上一参数不为ni时有效. cache优先时, 先从cache中找有失效的数据, 没有找到再调用接口, 网络调用失败, 再去cache中找无失效的数据.   cache不优先时, 只有网络调用失败, 才去cache中找
-(id) callSynchronousAPI: (NSString *) url method:(HTTP_METHOD) method useCache: (NSString *) cacheKey cacheFirst:(BOOL) cacheFirst andParams:(NSDictionary *) params
{
#if MOCK
    url = [NSString stringWithFormat: @"%@/%@", url, [params objectForKey: @"function"]];
#endif
    
    if (cacheKey) //使用cache
    {
        _localCacheKey = cacheKey;
        
        if (cacheFirst) //cache优先
        {
            NSString * cachedReturnDataString = [self loadFromLocalCache];
            if (cachedReturnDataString) //cache命中
            {
                return [cachedReturnDataString JSONValue];
            }
            else //cache没有命中
            {
                [self setNeedSaveCache];
                id responsedData;
                if (method==HTTP_POST)
                    responsedData = [self sendSynchronousHttpPostRequestWithURL: url params: params];
                else
                    responsedData = [self sendSynchronousHttpGetRequestWithURL: url params: params];
                if (responsedData)
                {
                    return responsedData;
                }
                else  //网络调用失败, 再次读取本地缓存(不考虑失效)
                {
                    NSString * cachedResponseDataString = [self loadFromLocalCacheNoExpired];
                    return [cachedResponseDataString JSONValue];
                }
            }
        }
        else //网络调用优先
        {
            [self setNeedSaveCache];
            id responsedData;
            if (method==HTTP_POST)
                responsedData = [self sendSynchronousHttpPostRequestWithURL: url params: params];
            else
                responsedData = [self sendSynchronousHttpGetRequestWithURL: url params: params];
            if (responsedData)  //  网络调用成功
            {
                return responsedData;
            }
            else    //网络调用失败, 读取本地缓存
            {
                NSString * cachedResponseDataString = [self loadFromLocalCacheNoExpired];
                return [cachedResponseDataString JSONValue];
            }
        }
    }
    else //不使用cache
    {
        id responsedData;
        if (method==HTTP_POST)
            responsedData = [self sendSynchronousHttpPostRequestWithURL: url params: params];
        else
            responsedData = [self sendSynchronousHttpGetRequestWithURL: url params: params];
        return responsedData;
    }
}

-(void) errorDecode: (NSString *) error
{
    if ([error isEqualToString: @"invalid_client"])
        self.errorMessage = @"无效的客户端";
    else if ([error isEqualToString: @"client_disabled"])
        self.errorMessage = @"客户端被禁用";
    else if ([error isEqualToString: @"services_unavaible"])
        self.errorMessage = @"服务暂时不可用";
    else if ([error isEqualToString: @"old_password_error"])
        self.errorMessage = @"旧密码不正确";
    else
        self.errorMessage = @"未知错误";
}

#pragma  mark - API - 产品批次相关
//新增批次
-(NSDictionary *) addWithBatchCode:(NSString *)batchCode andProductBatchContent:(NSString *)productBatchContent
    {
        [_commonUtils myLogString:3 : @"call API: 新增批次"];
        NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                        method: HTTP_POST
                                                      useCache: nil
                                                    cacheFirst: NO
                                                     andParams: @{@"function": @"editProductBatch",
                                                                  @"productBatchCode": batchCode,
                                                                  @"productBatchContent":productBatchContent,
                                                                  @"token":TOKEN,
                                                                  }
                                       ];
        return responseDict;
    }

//编辑批次
-(NSDictionary *) editProductBatchWithId:(NSString *)id andProductBatchCode:(NSString *)batchCode andProductBatchContent:(NSString *)productBatchContent
{
    [_commonUtils myLogString:3 : @"call API: 新增批次"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"editProductBatch",
                                                              @"id":id,
                                                              @"productBatchCode": batchCode,
                                                              @"productBatchContent":productBatchContent,
                                                              @"token":TOKEN,
                                                              }
                                   ];
    return responseDict;

}

//获取批次列表
-(NSDictionary *) getProductBatchListWithPageSize:(int)proPageSize
                                       andPageNum:(int)proPageNum
{
    [_commonUtils myLogString:3 : @"call API: 批次列表"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"getProductBatchList",
                                                              @"pageSize":
                                                                  @(proPageSize),
                                                              @"pageNum":        @(proPageNum),
                                                              @"token":TOKEN,
                                                              }
                                   ];
    //NSLog(@"----%@----", responseDict[@"Rows"]);
    return responseDict;

}
//获取批次信息
-(NSDictionary *) getProductBatchInfoWithID:(NSString *)id
{
    [_commonUtils myLogString:3 : @"call API: 批次信息"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"getProductBatchInfo",
                                                              @"id":id,                                                              
                                                              @"token":TOKEN,
                                                              }
                                   ];
    return responseDict;

}

#pragma mark - API - 产品资料相关
//获取商品列表
-(NSDictionary *) getProductListWithPageSize:(int)pageSize
                                  andPageNum:(int)pageNum
{
    [_commonUtils myLogString:3 : @"call API: 获取商品列表"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"getProductList",
                                                              @"pageSize":
                                                                  @(pageSize),
                                                              @"pageNum":         @(pageNum),
                                                              @"token":TOKEN,
                                                              }
                                   ];
   
    return responseDict;

}

//获取商品分类列表
-(NSArray *) getProductClassify
{
    [_commonUtils myLogString:3 : @"call API: 获取商品分类列表"];
    self.errorMessage = nil;
    NSArray * responseList = [self callSynchronousAPI: SERVER_URL_PREFIX
                                               method: HTTP_POST
                                             useCache: nil
                                           cacheFirst: NO
                                            andParams: @{@"function": @"getProductClassify",
                                                         @"token": TOKEN
                                                         }
                              ];
    
    if (self.errorMessage)
        return nil;
    else
    {
        if (responseList)
            return responseList;
        else
            return [[NSArray alloc] init];
    }
    
}



//新增商品信息
-(NSDictionary *) addProductInfoWithProductName:(NSString *)productName andClassifyID:(NSString *)classifyID andCategoryID:(NSString *)categoryID andPriceSell:(NSString *)priceSell andPriceOriginal:(NSString *)priceOriginal andStock:(int)stock andLayer3UnitID:(int)layer3UnitID andThumbnail:(NSArray *)thumbnail
{
    [_commonUtils myLogString:3 : @"call API: 新增商品信息"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"editProductInfo",
                                                              @"ProductName":
                                                                  productName,
                                                              @"ClassifyID":         classifyID,
                                                              @"CategoryID":categoryID,
                                                              @"PriceSell":priceSell,
                                                                       @"PriceOriginal":priceOriginal,
                                                                       @"Stock":@(stock),
                                                     @"Layer3UnitID":@(layer3UnitID),
                                                              @"Thumbnail":thumbnail,
                                                              
                                                              @"token":TOKEN,
                                                              }
                                   ];
    
    return responseDict;

}

//编辑商品信息
-(NSDictionary *) editProductInfoWithID:(NSString *)id andProductName:(NSString *)productName andClassifyID:(NSString *)classifyID andCategoryID:(NSString *)categoryID andPriceSell:(NSString *)priceSell andPriceOriginal:(NSString *)priceOriginal andStock:(int)stock andLayer3UnitID:(int)layer3UnitID andThumbnail:(NSArray *)thumbnail
{
    [_commonUtils myLogString:3 : @"call API: 新增商品信息"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"editProductInfo",
                                                              @"id":
                                                                  id,
                                                              @"ProductName":
                                                                  productName,
                                                              @"ClassifyID":         classifyID,
                                                              @"CategoryID":categoryID,
                                                              @"PriceSell":priceSell,
                                                              @"PriceOriginal":priceOriginal,
                                                              @"Stock":@(stock),
                                                              @"Layer3UnitID":@(layer3UnitID),
                                                                          @"Thumbnail":thumbnail,
                                                              @"token":TOKEN,
                                                              }
                                   ];
    
    return responseDict;
    
}


#pragma mark - API -  历史扫码相关
//历史扫码
-(NSDictionary *) getLogisticsCodeListWithpageSize:(int)pageSize andPageNum:(int)pageNum
{
    [_commonUtils myLogString:3 : @"call API: 获取物流码列表"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"getLogisticsCodeList",
                                                              @"pageSize":@(pageSize),
                                                               @"pageNum":@(pageNum),
                                                              @"token":TOKEN,
                                                              }
                                   ];
    return responseDict;
}


#pragma mark - API - 用户相关
//用户登录
-(NSDictionary *) loginWithUser: (NSString *) user andPassword: (NSString *) password
{
    [_commonUtils myLogString:3 : @"call API: 用户登录"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"login",
                                                              @"user": user,
//                                                              @"pwd": [[password md5] uppercaseString] //@"BC3C4A6331A8A9950945A1AA8C95AB8A"
                                                              @"pwd": password
                                                              }
                                   ];

    if ([responseDict objectForKey: @"Token"]!=nil)
    {
        return responseDict;
    }
    else
    {
        return nil;
    }
}

//获取用户资料
-(NSDictionary *)getUserInfo
{
    [_commonUtils myLogString:3 : @"call API: 获取用户资料"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"getUserInfo",
                                                     @"token":TOKEN,
                                                              }
                                   ];
    return responseDict;
}

//保存用户资料
-(NSDictionary *)editUserInfoWithUserName:(NSString *)userName andMobile:(NSString *)mobile andAddress:(NSString *)address andNote:(NSString *)note
{
    [_commonUtils myLogString:3 : @"call API: 保存用户资料"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"getUserInfo",
                                                              @"UserName":userName,
                                                              @"Mobile":
                                                                  mobile,
                                                              @"Address":
                                                                  address,
                                                              @"Note":
                                                                  note,
                                                              @"token":TOKEN,
                                                              }
                                   ];
    return responseDict;

}


//修改密码
-(void)changePasswordWithOldPwd:(NSString *)oldPwd andNewPwd:(NSString *)newPwd{
    [_commonUtils myLogString:3 : @"call API: 修改密码"];
   [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"changePassword",
                                                              @"oldPwd":oldPwd,
                                                              @"newPwd":newPwd,
                                                              @"token":TOKEN,
                                                              }
                                   ];
 }

#pragma mark - API - 获取机构信息
//获取基地信息
-(NSDictionary *) getOrgInfoWithID:(NSString *)id
{
    [_commonUtils myLogString:3 : @"call API: 获取机构信息"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @" getOrgInfo",
                                                              @"id":id,
                                                              @"token":TOKEN,
                                                              }
                                   ];
    return responseDict;
}

//机构新增／编辑
-(NSDictionary *) editOrgInfoWithOrgName:(NSString *)orgName andOrgCode:(NSString *)orgCode andOrgType:(int)orgType andParentID:(NSString *)parentID andProvince:(NSString *)province andCity:(NSString *)city andDistrict:(NSString *)district andRegionCode:(NSString *)regionCode
{
    [_commonUtils myLogString:3 : @"call API: 机构新增／编辑"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @" editOrgInfo",
                                                              @"orgName":orgName,
                                                              @"orgCode":orgCode,
                                                              @"orgType":@(orgType),
                                                              @"parentID":parentID,
                                                              @"province":province,
                                                              @"city":city,
                                                              @"district":district,
                                                              @"regionCode":regionCode,
                                                              @"token":TOKEN,
                                                              }
                                   ];
    return responseDict;

}

-(NSDictionary *) registerWithMobile: (NSString *) mobile andPassword: (NSString *) password andSMSCode: (NSString *) smsCode andCompanyName: (NSString *) companyName
{
    [_commonUtils myLogString:3 : @"call API: 用户注册"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"register",
                                                              @"mobile": mobile,
                                                              @"pwd": password,
                                                              @"code": smsCode,
                                                              @"corpname": companyName,
                                                              @"version": VERSION,
                                                              @"device": iPhone?@"iPhone":@"iPad"
                                                              }
                                   ];
    
    if ([responseDict objectForKey: @"Token"]!=nil)
    {
        return responseDict;
    }
    else
    {
        return nil;
    }
}


-(BOOL) sendConfirmCodeToMobile: (NSString *) mobile forUsage: (NSString *) usage
{
    [_commonUtils myLogString:3 : @"call API: 发送验证码"];
    self.errorMessage = nil;
    [self callSynchronousAPI: SERVER_URL_PREFIX
                      method: HTTP_POST
                    useCache: nil
                  cacheFirst: NO
                   andParams: @{@"function": @"getCode",
                                @"mobile": mobile,
                                @"usage": usage,
                                @"version": VERSION,
                                @"device": iPhone?@"iPhone":@"iPad"
                                }
     ];
    
    if (self.errorMessage)
        return NO;
    else
        return YES;
    
}

-(void) logout
{
    //此接口去掉了
    /*
    [_commonUtils myLogString:3 : @"call API: 退出登录"];
    self.errorMessage = nil;
    [self callAsynchronousAPI: SERVER_URL_PREFIX
                      method: HTTP_POST
                    useCache: nil
                  cacheFirst: NO
                   andParams: @{@"function": @"logout",
                                @"token": TOKEN
                                }
     ];
    */
}


-(BOOL) uploadCertificateInfo: (NSString *) phone :(NSString *) licensePicUrl :(NSString *) organizePicUrl :(NSString *)taxPicUrl
{
    //$url/DataServiceJson.ashx?function=authenticateCorp
    [_commonUtils myLogString:3 : @"call API: 上传企业认证资料"];
    self.errorMessage = nil;
    [self callSynchronousAPI: SERVER_URL_PREFIX
                      method: HTTP_POST
                    useCache: nil
                  cacheFirst: NO
                   andParams: @{@"function": @"authenticateCorp",
                                @"token": TOKEN,
                                @"licenseImg": licensePicUrl,
                                @"organizeImg": organizePicUrl,
                                @"taxImg": taxPicUrl,
                                @"phone": phone
                                }
     ];
    
    if (self.errorMessage)
        return NO;
    else
        return YES;

}

-(NSDictionary *) getCertificateInfo
{
    //getCorpAuthenticate
    [_commonUtils myLogString:3 : @"call API: 获取企业认证信息"];
    //getCorpInfo
    self.errorMessage = nil;
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"getCorpAuthenticate",
                                                              @"token": TOKEN//@"5f1cbcc0-42fb-4442-95d4-eee7b7ac4e74" //TOKEN
                                                              }
                                   ];
    
    return responseDict;
}

-(NSDictionary *) getEnterpriseInfo
{
    [_commonUtils myLogString:3 : @"call API: 获取企业信息"];
    //getCorpInfo
    self.errorMessage = nil;
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"getCorpInfo",
                                                              @"token": TOKEN
                                                              }
                                   ];
    
    //1.1增加获取企业认证状态
    if (responseDict)
    {
        _commonObjects.certificateStatus = [[responseDict objectForKey: @"Status"] intValue];
    }
    else
    {
        _commonObjects.certificateStatus = 0; //未知
    }
    
    [USER_DEFAULT setObject: [NSNumber numberWithInt: _commonObjects.certificateStatus] forKey: @"lastCertifyStatus"];

    
    return responseDict;
}


-(BOOL) saveEnterpriseInfo: (NSDictionary *) enterpriseInfoDict
{
    [_commonUtils myLogString:3 : @"call API: 保存企业信息"];
    self.errorMessage = nil;
    [self callSynchronousAPI: SERVER_URL_PREFIX
                      method: HTTP_POST
                    useCache: nil
                  cacheFirst: NO
                   andParams: @{@"function": @"editCorpInfo",
                                @"token": TOKEN,
                                @"corpName": [enterpriseInfoDict objectForKey: @"CorpName"],
                                @"phone": [enterpriseInfoDict objectForKey: @"Phone"],
                                @"address": [enterpriseInfoDict objectForKey: @"Address"]//,
//                                @"intro": [enterpriseInfoDict objectForKey: @"Intro"]
                                }
     ];
    
    if (self.errorMessage)
        return NO;
    else
        return YES;
}

-(BOOL) changeOldPwd: (NSString *) oldPwd toNewPwd: (NSString *) newPwd
{
    [_commonUtils myLogString:3 : @"call API: 修改用户密码"];
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"api_name": @"user_change_password",
                                                              @"access_token": _commonObjects.token,
                                                              @"old_password": oldPwd,
                                                              @"new_password": newPwd
                                                              }
                                   ];
    
    
    if ([[responseDict objectForKey: @"result"] isEqualToString: @"success"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL) resetPassword: (NSString *) password withCode: (NSString *) code forMobile: (NSString *) mobile
{
    [_commonUtils myLogString:3 : @"call API: 重置密码"];
    self.errorMessage = nil;
    [self callSynchronousAPI: SERVER_URL_PREFIX
                      method: HTTP_POST
                    useCache: nil
                  cacheFirst: NO
                   andParams: @{@"function": @"resetPassword",
                                @"mobile": mobile,
                                @"pwd": password,
                                @"code": code,
                                @"version": VERSION,
                                @"device": iPhone?@"iPhone":@"iPad"
                                }
     ];
    
    if (self.errorMessage)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - API - 商城相关
-(NSDictionary *) getMallInfo
{
    [_commonUtils myLogString:3 : @"call API: 获取商城信息"];
    self.errorMessage = nil;
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                               method: HTTP_POST
                                             useCache: nil
                                           cacheFirst: NO
                                            andParams: @{@"function": @"getMallInfo",
                                                         @"token": TOKEN
                                                         }
                              ];
    
    if (self.errorMessage)
        return nil;
    else
    {
        if (responseDict)
            return responseDict;
        else
            return [[NSDictionary alloc] init];
    }
}

-(BOOL) saveMallInfoWithDictionary: (NSDictionary *) mallDict
{
    [_commonUtils myLogString:3 : @"call API: 保存商城信息"];
    self.errorMessage = nil;
    [self callSynchronousAPI: SERVER_URL_PREFIX
                      method: HTTP_POST
                    useCache: nil
                  cacheFirst: NO
                   andParams: @{@"function": @"editMallInfo",
                                @"token": TOKEN,
                                @"mallLogo": [mallDict objectForKey: @"MallLogo"],
                                @"mallName": [mallDict objectForKey: @"MallName"],
                                @"mallInfo": [mallDict objectForKey: @"MallInfo"]
                                }
     ];
    
    if (self.errorMessage)
        return NO;
    else
    {
        return YES;
    }
    return YES;
}



#pragma mark - API - 商品相关

-(BOOL) uploadProductClassify:(NSArray *)productClassifyList
{
    [_commonUtils myLogString:3 : @"call API: 保存商品分类列表"];
    self.errorMessage = nil;
    [self callSynchronousAPI: SERVER_URL_PREFIX
                                               method: HTTP_POST
                                             useCache: nil
                                           cacheFirst: NO
                                            andParams: @{@"function": @"editProductClassify",
                                                         @"token": TOKEN,
                                                         @"Items": [productClassifyList JSONRepresentation]
                                                         }
                              ];
    
    if (self.errorMessage)
        return NO;
    else
        return YES;
}

-(NSArray *) getSystemCategory
{
    [_commonUtils myLogString:3 : @"call API: 获取商品类目列表"];
    self.errorMessage = nil;
    NSArray * responseList = [self callSynchronousAPI: SERVER_URL_PREFIX
                                               method: HTTP_POST
                                             useCache: nil
                                           cacheFirst: NO
                                            andParams: @{@"function": @"getProductCategory",
                                                         @"token": TOKEN
                                                         }
                              ];
    
    if (self.errorMessage)
        return nil;
    else
    {
        if (responseList)
            return responseList;
        else
            return [[NSArray alloc] init];
    }
}


-(NSDictionary *) getProductListByClassifyID: (NSString *) classifyID andStatus: (int) status orderBy: (NSString *) orderField andAscending: (BOOL) ascending andPageSize: (int) pageSize andPageNo: (int) pageNo
{
    [_commonUtils myLogString:3 : @"call API: 获取商品列表"];
    self.errorMessage = nil;
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];

    [params setObject: @"getProductList" forKey: @"function"];
    [params setObject: TOKEN forKey: @"token"];
    
    if (classifyID)
        [params setObject: classifyID forKey: @"classifyID"];
    
    if (status==0) //已下架
    {
        [params setObject: @"0" forKey: @"status"];
    }
    else
    {
        [params setObject: @"1" forKey: @"status"];
        if (orderField)
        {
            [params setObject: orderField forKey: @"orderField"];
            [params setObject: ascending?@"1":@"0" forKey: @"orderType"];
        }
    }
    
    [params setObject: [NSNumber numberWithInt: pageNo] forKey: @"pageNum"];
    [params setObject: [NSNumber numberWithInt: pageSize] forKey: @"pageSize"];
    
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                               method: HTTP_POST
                                             useCache: nil
                                           cacheFirst: NO
                                            andParams: params
                              ];
    
    if (self.errorMessage)
        return nil;
    else
    {
        if (responseDict)
            return responseDict;
        else
            return [[NSDictionary alloc] init];
    }
}

-(NSDictionary *) getProductDetailByGUID: (NSString *) guid
{
    [_commonUtils myLogString:3 : @"call API: 获取商品详情"];
    self.errorMessage = nil;
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"getProductInfo",
                                                              @"token": TOKEN,
                                                              @"id": guid
                                                              }
                                   ];
    
    if (self.errorMessage)
        return nil;
    else
        return responseDict;
}

-(NSString *) saveProductDetailFromDict: (NSDictionary *) productDict
{
    [_commonUtils myLogString:3 : @"call API: 保存商品信息"];
    self.errorMessage = nil;
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setObject: @"editProductInfo" forKey: @"function"];
    [params setObject: TOKEN forKey: @"token"];
    
    id obj = [productDict objectForKey: @"ID"];
    if (obj)
        [params setObject: obj forKey: @"id"];
    
    
    obj = [productDict objectForKey: @"ProductName"];
    if (obj)
        [params setObject: obj forKey: @"productName"];
    
//    obj = [productDict objectForKey: @"Color"];
//    if (obj)
//        [params setObject: obj forKey: @"color"];

    obj = [productDict objectForKey: @"ClassifyID"];
    if (obj)
        [params setObject: obj forKey: @"classifyID"];
    else
        [params setObject: @"" forKey: @"classifyID"];
    
    obj = [productDict objectForKey: @"Thumbnail"];
    if (obj)
        [params setObject: [obj JSONRepresentation] forKey: @"thumbnail"];
    
//    obj = [productDict objectForKey: @"Spec"];
//    if (obj)
//        [params setObject: obj forKey: @"spec"];
    
    obj = [productDict objectForKey: @"CategoryID"];
    if (obj)
        [params setObject: obj forKey: @"categoryID"];
    
    obj = [productDict objectForKey: @"Detail"];
    if (obj)
    {
        NSMutableArray * detailItems = (NSMutableArray *)obj;
        int index = 1;
        for (NSMutableDictionary * detailItem in detailItems)
        {
            [detailItem setObject: [NSNumber numberWithInt: index++] forKey: @"Index"];
        }
        [params setObject: [detailItems JSONRepresentation] forKey: @"detail"];
    }
    
    obj = [productDict objectForKey: @"PriceSell"];
    if (obj)
        [params setObject: obj forKey: @"priceSell"];
    
    obj = [productDict objectForKey: @"Stock"];
    if (obj)
        [params setObject: obj forKey: @"stock"];
    
//    obj = [productDict objectForKey: @"Shipping"];
//    if (obj)
//        [params setObject: obj forKey: @"shipping"];
    
    obj = [productDict objectForKey: @"IntegralValue"];
    if (obj)
        [params setObject: obj forKey: @"IntegralValue"];

    
    obj = [productDict objectForKey: @"PriceOriginal"];
    if (obj)
        [params setObject: obj forKey: @"priceOriginal"];

    
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: params
                                   ];
    
    //NSLog(@"%@", [responseDict JSONRepresentation]);
    if (self.errorMessage)
        return 0;
    else
        return [responseDict objectForKey: @"ID"];
}


-(BOOL) deleteProductByGUID: (NSString *) guid
{
    [_commonUtils myLogString:3 : @"call API: 删除商品"];
    self.errorMessage = nil;
    [self callSynchronousAPI: SERVER_URL_PREFIX
                      method: HTTP_POST
                    useCache: nil
                  cacheFirst: NO
                   andParams: @{@"function": @"deleteProduct",
                                @"token": TOKEN,
                                @"id": guid
                                }
     ];
    
    if (self.errorMessage)
        return NO;
    else
        return YES;
}


#pragma mark - API - 积分相关
//获取某人的积分记录
-(NSDictionary *) getPointChargeRecordForUser: (NSString *) userID
                                  andUserType: (int) userType
                                   andKeyword: (NSString *) keyword
                                  andPageSize: (int) pageSize
                                    andPageNo: (int) pageNo
{
    [_commonUtils myLogString: 3 : @"call API: 获取某人的积分兑换记录"];
    self.errorMessage = nil;
    
    NSDictionary * params;
    if ([keyword length]>0)
    {
        params = @{ @"function": @"getTargetIntegralList",
                    @"token": TOKEN,
                    @"targetType": @(userType),
                    @"id": userID,
                    @"pageSize": @(pageSize),
                    @"pageNum": @(pageNo),
                    @"KeyWord": keyword
                    };
    }
    else
    {
        params = @{ @"function": @"getTargetIntegralList",
                    @"token": TOKEN,
                    @"targetType": @(userType),
                    @"id": userID,
                    @"pageSize": @(pageSize),
                    @"pageNum": @(pageNo)
                    };
    }

    
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: params
                                   ];
    
    if (self.errorMessage)
        return nil;
    else
    {
        if (responseDict)
            return responseDict;
        else
            return [[NSDictionary alloc] init];
    }
}



#pragma mark - API - 门店相关
-(NSDictionary *) getOrgListByOrgType: (OrgType) orgType inCity: (NSString *) cityName  orderByField: (NSString *) orderField orderSequence: (BOOL) asc andSearchBy: (NSString *) key andPageSize: (int) pageSize andPageNo: (int) pageNO
{
    [_commonUtils myLogString:3 : @"call API: 获取机构列表"];
    self.errorMessage = nil;
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    //[params setObject: @"getstorelist" forKey: @"function"];
    [params setObject: @"getOrglist" forKey: @"function"];  //接口变更 10/22
    [params setObject: TOKEN forKey: @"token"];
    [params setObject: [NSNumber numberWithInt: pageNO] forKey: @"pageNum"];
    [params setObject: [NSNumber numberWithInt: pageSize] forKey: @"pageSize"];
    [params setObject: @(orgType) forKey: @"OrgType"];
    
    if ([cityName length]>0 && ![cityName isEqualToString: @"全部"])
        [params setObject: cityName forKey: @"City"];
    
    if ([key length]>0)
        [params setObject: key forKey: @"KeyWord"];
    
    if ([orderField length]>0)
    {
        [params setObject: orderField forKey: @"orderField"];
        if (asc)
            [params setObject: @1 forKey: @"orderType"];
        else
            [params setObject: @0 forKey: @"orderType"];
        
    }
    
    
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: params
                                   ];
    
    if (self.errorMessage)
        return nil;
    else
    {
        if (responseDict)
            return responseDict;
        else
            return [[NSDictionary alloc] init];
    }

}

-(NSDictionary *) getOrgInfoByID: (NSString *) orgID
{
    [_commonUtils myLogString:3 : @"call API: 获取门店信息"];
    self.errorMessage = nil;
    NSDictionary * storeDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                 method: HTTP_POST
                                               useCache: nil
                                             cacheFirst: NO
                                              andParams: @{@"function": @"getOrgInfo",
                                                           @"token": TOKEN,
                                                           @"ID": orgID
                                                           }];
    
    if (self.errorMessage)
        return nil;
    else
        return storeDict;
}

-(NSString *) saveOrgInfo: (NSDictionary *) orgDict andOrgType: (OrgType) orgType
{
    [_commonUtils myLogString:3 : @"call API: 保存门店信息"];
    self.errorMessage = nil;
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary: orgDict];
    [params setObject: TOKEN forKey: @"token"];
    [params setObject: @"editOrgInfo" forKey: @"function"];
    [params setObject: @(orgType) forKey: @"OrgType"];
    
    
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: params
     ];
    
    if ([responseDict objectForKey: @"ID"])
        return [responseDict objectForKey: @"ID"];
    else
        return nil;
}

-(BOOL) changeStatus:(BOOL) status byOrgID: (NSString *) orgID
{
    [_commonUtils myLogString:3 : @"call API: 机构启用、禁用"];
    self.errorMessage = nil;
    [self callSynchronousAPI: SERVER_URL_PREFIX
                      method: HTTP_POST
                    useCache: nil
                  cacheFirst: NO
                   andParams: @{@"function": @"changeOrgStatus",
                                @"token": TOKEN,
                                @"id": orgID,
                                @"status": (status?@"1":@"0")
                                }
     ];
    
    if (self.errorMessage)
        return NO;
    else
        return YES;
    
}


-(NSArray *) getStoreRegionList
{
    [_commonUtils myLogString:3 : @"call API: 获取门店城市列表"];
    self.errorMessage = nil;
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                 method: HTTP_POST
                                               useCache: nil
                                             cacheFirst: NO
                                              andParams: @{@"function": @"havecity",
                                                           @"token": TOKEN,
                                                           }];
    
    if (self.errorMessage)
        return nil;
    else
        return [responseDict objectForKey: @"Rows"];
}

-(NSArray *) getAllCityList
{
    [_commonUtils myLogString:3 : @"call API: 获取门店城市列表"];
    self.errorMessage = nil;
//    NSArray * cityList = [self callSynchronousAPI: SERVER_URL_PREFIX
//                                           method: HTTP_POST
//                                         useCache: nil
//                                       cacheFirst: NO
//                                        andParams: @{@"function": @"getsysregion",
//                                                     @"token": TOKEN,
//                                                     }];
    NSString * string = [NSString stringWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"region" ofType:@"json" inDirectory: @"json"] encoding: NSUTF8StringEncoding error: nil];
    NSArray * cityList = [string JSONValue];
    
    if (self.errorMessage)
        return nil;
    else
        return cityList;
}

#pragma mark - API - 会员相关
-(NSDictionary *) saveMemberInfoWithDict: (NSDictionary *) memberDict
{
//    文件名	$url/Ashx/App.ashx?function= editCustomer
//    方式	post
//    说明：
//    参数	类型	说明
//    token	String	登录获取的token
//    id	String	会员ID（编辑才需要此参数）
//    loginName	String	11位国内手机号（作为登录名）
//    province	String	省
//    city	String	市
//    district	String	区
//    regionCode	String	所在地的行政区编码（区级）
//    email	String	电子邮箱
//    birthday	Datetime	生日
//    note	String	备注
//    返回data示例	{
//        "Password": "123456",  //会员密码
//        "Integral": “30”   //获得的积分
//    }
    [_commonUtils myLogString: 3 : @"call API: 保存会员资料"];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary: memberDict];
    [params setObject: @"editCustomer" forKey: @"function"];
    [params setObject: TOKEN forKey: @"token"];
    
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                     method: HTTP_POST
                                                   useCache: nil
                                                 cacheFirst: NO
                                                  andParams: params];
    
    if (self.errorMessage)
        return nil;
    else
        return responseDict;
    
    return nil;
}

-(NSDictionary *) savePointForMobile: (NSString *) mobile withCodeList: (NSArray *) codeList //会员积分（多个积分码）
{
//    32.	会员积分【OK】
//    文件名	$url/Ashx/App.ashx?function= customerIntegral
//    方式	post
//    说明：
//    参数	类型	说明
//    token	String	登录获取的token
//    loginName	String	11位国内手机号（登录名）
//    integralCode	String	积分码（多个中间以逗号隔开）
//    返回data示例	{
//        "TotalIntegral": "400",  //累计积分
//        "RemainIntegral": “300” ,  //可用积分
//        "IntegralThisTime": “30”   //本次获得积分
//    }
    [_commonUtils myLogString: 3 : @"call API: 会员积分"];
    self.errorMessage = nil;
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setObject: @"customerIntegral" forKey: @"function"];
    [params setObject: TOKEN forKey: @"token"];
    [params setObject: mobile forKey: @"loginName"];
    NSMutableString * codes = [NSMutableString stringWithString: [codeList objectAtIndex: 0]];
    for (NSInteger i=1; i<[codeList count]; i++)
    {
        [codes appendFormat: @",%@", [codeList objectAtIndex: i]];
    }
    [params setObject: codes forKey: @"integralCode"];
    
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: params];

    if (responseDict)
        return responseDict;
    else
        return nil;
    
}

-(NSDictionary *) searchMemberWithKeyword: (NSString *) keyword andPageNum:(int)pageNum //会员搜索（会员资料）
{
    //TODO: 会员资料
    /*
    33.	获取会员列表【OK】
    文件名	$url/Ashx/App.ashx?function= getCustomerList
    方式	post
    说明：
    参数	类型	说明
    token	String	登录获取的token
    keyWord	String	搜索关键字
    orderField	String	排序字段（预留）
    orderType	Int	0降序 1升序（预留）
    pageSize	Int	每页显示数量
    pageNum	Int	当前页码
    返回data示例	{
        "Total": 20,
        "Rows": [
                 {
                     "CustomerID": "29ac7967-3bbc-4bd3-abab-d85f5fe1cbd1",    //会员ID
                     "CustomerName": "高凯",      //会员姓名
                     "TotalIntegral": "400",         //累计积分
                     "RemainIntegral": "250",       //可用积分
                     "Phone ": "15088649454",      //手机号
                     Status”:“1”    //状态
                 }
                 ]
    }
    */
    
    [_commonUtils myLogString: 3 : @"call API: 会员搜索"];
    self.errorMessage = nil;
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setObject: @"getCustomerList" forKey: @"function"];
    [params setObject: TOKEN forKey: @"token"];
    
    if ([keyword length]>0)
    {
        [params setObject: keyword forKey: @"keyWord"];
    }
    
    [params setObject: @(20) forKey: @"pageSize"];
    [params setObject: @(pageNum) forKey: @"pageNum"];
    
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: params];
    
    if (responseDict)
        return responseDict;
    else
        return nil;
}


-(NSDictionary *) getMemberInfoByID: (NSString *) customerID //获取会员详情
{
    /*
     34.	获取会员信息【OK】
     文件名	$url/Ashx/App.ashx?function= getCustomerInfo
     方式	post
     说明：
     参数	类型	说明
     token	String	登录获取的token
     id	String	会员ID
     返回data示例	{
     "Phone": "15088645141",      //手机
     "Province": “浙江省” ,          //可用积分
     "City": “杭州市”,               //本次获得积分
     "District": “西湖区”,            //错误信息
     "Email": “1204541@qq.com”,    //电子邮箱
     "Birthday": “1990-12-10”,       //生日
     "Note":”123”,                  //备注
     "Status": 1,                    //状态（见下表）
     "OrgCode": “00012”,             //注册门店代码
     " OrgName": “西湖区门店”,       //注册门店名称
     " TotalIntegral ": “400”,          //累计积分
     " RemainIntegral ": “200”,        //可用积分
     " SourceName": “wap商城”,      //注册途径
     " CreateTime ": “2014-08-20”    //注册时间
     }
    */
    
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"token":TOKEN,
                                                              @"function":@"getCustomerInfo",
                                                              @"id":customerID}];
    
    if (responseDict)
        return responseDict;
    else
        return nil;
}



#pragma mark - API - 导购相关
-(NSDictionary *) getSalesListByKeyword: (NSString *) keyword andPageSize: (int) pageSize andPageNo: (int) pageNo
{
    [_commonUtils myLogString: 3 : @"call API: 获取导购列表"];
    self.errorMessage = nil;
    NSDictionary * params;
    if ([keyword length]>0)
    {
        params = @{@"function": @"getGuideList",
                   @"token": TOKEN,
                   @"keyWord": keyword,
                   @"pageSize": @(pageSize),
                   @"pageNum": @(pageNo)};
    }
    else
    {
        params = @{@"function": @"getGuideList",
                   @"token": TOKEN,
                   @"pageSize": @(pageSize),
                   @"pageNum": @(pageNo)};
    }
    
    NSDictionary * salesListDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                 method: HTTP_POST
                                               useCache: nil
                                             cacheFirst: NO
                                              andParams: params];
    
    if (self.errorMessage)
        return nil;
    else
        return salesListDict;
    return nil;
}


-(NSDictionary *)getSalesInfoByID: (NSString *) salesID
{
    [_commonUtils myLogString:3 : @"call API: 获取导购信息"];
    self.errorMessage = nil;
    NSDictionary * salesInfo = [self callSynchronousAPI: SERVER_URL_PREFIX
                                           method: HTTP_POST
                                         useCache: nil
                                       cacheFirst: NO
                                        andParams: @{@"function": @"getGuideInfo",
                                                     @"token": TOKEN,
                                                     @"id": salesID
                                                     }];
    
    if (self.errorMessage)
        return nil;
    else
        return salesInfo;
}

-(BOOL) saveSalesInfo: (NSDictionary *) salesDict
{
    [_commonUtils myLogString:3 : @"call API: 保存导购信息"];
    self.errorMessage = nil;
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary: salesDict];
    [params setObject: TOKEN forKey: @"token"];
    [params setObject: @"editGuide" forKey: @"function"];
    
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: params
                                   ];
    
    if (self.errorMessage)
        return NO;
    else
        return YES;
}

//-(NSDictionary *) getSalesOrganizeListByType: (NSString *) csvOrgType andKeyword: (NSString *) keyword andPageSize: (int) pageSize andPageNo: (int) pageNo
-(NSDictionary *) getSelectableOrgListByType: (NSString *) csvOrgType orderByField: (NSString *) orderField orderSequence: (BOOL) asc andSearchBy: (NSString *) key andPageSize: (int) pageSize andPageNo: (int) pageNO
{
    [_commonUtils myLogString:3 : @"call API: 获取机构列表"];
    self.errorMessage = nil;
    
    NSDictionary * params;
    if (key)
    {
        params = @{@"function": @"getSelectableOrgList",
                   @"token": TOKEN,
                   @"keyWord": key,
                   @"pageSize": @(pageSize),
                   @"pageNum": @(pageNO),
                   @"orgType": csvOrgType
                   };
    }
    else
    {
        params = @{@"function": @"getSelectableOrgList",
                   @"token": TOKEN,
                   @"pageSize": @(pageSize),
                   @"pageNum": @(pageNO),
                   @"orgType": csvOrgType
                   };
    }
    
    NSDictionary * salesOrgList = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                 method: HTTP_POST
                                               useCache: nil
                                             cacheFirst: NO
                                              andParams: params];
    
    if (self.errorMessage)
        return nil;
    else
        return salesOrgList;
    return nil;
}

-(BOOL) enableSalesByID: (NSString *) salesID status: (BOOL) enabled
{
//    changeGuideStatus
    [_commonUtils myLogString:3 : @"call API: 启用/禁用导购"];
    self.errorMessage = nil;
    
    NSDictionary * responseDict = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: @{@"function": @"changeGuideStatus",
                                                              @"token": TOKEN,
                                                              @"id": salesID,
                                                              @"status": @(enabled?1:0)
                                                              }
                                   ];
    
    if (self.errorMessage)
        return NO;
    else
        return YES;
}


-(NSDictionary *) getSalesChargeListByKeyword: (NSString *) keyword andPageSize: (int) pageSize andPageNo: (int) pageNo
{
    [_commonUtils myLogString:3 : @"call API: 获取导购积分记录"];
    self.errorMessage = nil;
    
    NSDictionary * params;
    if ([keyword length]>0)
    {
        params = @{@"function": @"getGuideIntegralList",
                   @"token": TOKEN,
                   @"keyWord": keyword,
                   @"pageSize": @(pageSize),
                   @"pageNum": @(pageNo),
                   };
    }
    else
    {
        params = @{@"function": @"getGuideIntegralList",
                   @"token": TOKEN,
                   @"pageSize": @(pageSize),
                   @"pageNum": @(pageNo),
                   };
    }
    
    NSDictionary * salesOrgList = [self callSynchronousAPI: SERVER_URL_PREFIX
                                                    method: HTTP_POST
                                                  useCache: nil
                                                cacheFirst: NO
                                                 andParams: params];
    
    if (self.errorMessage)
        return nil;
    else
        return salesOrgList;
    return nil;
}


#pragma mark - 推送相关
/*
-(BOOL) registerTagsToGeTui
{
    if (_commonObjects.sdkStatus==SdkStatusStarting)
    {
        NSMutableArray * tags = [[NSMutableArray alloc] initWithObjects: @"all", @"ios", iPhone?@"iphone":@"ipad", nil];
        [tags addObject: [NSString stringWithFormat: @"v%@", VERSION]];
        if (TOKEN)
        {
            [tags addObject: @"login"];
            [tags addObject: [NSString stringWithFormat: @"u%@", CorpID]];
        }
        else
        {
            if ([[USER_DEFAULT objectForKey: @"lastUser"] length]>0)
                [tags addObject: @"logout"];
            else
                [tags addObject: @"new"];
        }
        
        if (_commonObjects.pasteboardString==nil)
            _commonObjects.pasteboardString = [NSMutableString stringWithFormat: @"tags: \n%@", [tags componentsJoinedByString: @"\n"]];
        else
            [_commonObjects.pasteboardString appendFormat: @"\n\ntags: \n%@", [tags componentsJoinedByString: @"\n"]];
        
        UIPasteboard * pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = _commonObjects.pasteboardString;

        BOOL success = [_commonObjects.gexinPusher setTags: tags];
        return success;
    }
    else
        return NO;
}
*/

#pragma mark - API - 基础
-(NSString *) uploadFile: (NSString *) filepath
{
    [_commonUtils myLogString: 3 : @"Started to upload file: " : filepath];
    ASIFormDataRequest * _asiRequest = [ASIFormDataRequest requestWithURL: [NSURL URLWithString: SERVER_URL_PREFIX]];
    [_asiRequest setPostValue: @"upload" forKey: @"function"];
    [_asiRequest setPostValue: TOKEN forKey: @"token"];
    [self setRequestData: _asiRequest file: filepath];
    [_asiRequest setDelegate: self];
    [_asiRequest setTimeOutSeconds: 600];
    [_asiRequest startAsynchronous];

    
    uploadFailed = NO;
    uploading = YES;
    while (uploading) //3秒轮询一次
    {
        [_commonUtils myLogString: 3 : @"still uploading..."];
        NSDate * threeSecondsLater = [NSDate dateWithTimeIntervalSinceNow: 3];
        [[NSRunLoop currentRunLoop] runUntilDate: threeSecondsLater];
    }
    
    if (!uploadFailed)
    {
        NSString * cachedFile = [_commonUtils getCachedFilePathForURL: _asiRequest.accessibilityHint];
        NSFileManager * fm = [[NSFileManager alloc] init];
        [fm moveItemAtPath: filepath toPath: cachedFile error: nil];
        return _asiRequest.accessibilityHint;
    }
    else
    {
        return nil;
    }

}

-(void) setRequestData: (ASIFormDataRequest *) request file: (NSString *) file
{
    [request setData: [NSData dataWithContentsOfFile: file]
        withFileName: [file lastPathComponent]
      andContentType: @"application/jpeg"
              forKey: @"file"];
}





#pragma mark - ASIHTTPRequestDelegate
-(void) requestFinished:(ASIHTTPRequest *)request
{
    [_commonUtils myLogString: 3 :[NSString stringWithFormat: @"upload Finished : %@", [request responseString]]];
    NSDictionary * responsedDict = [[request responseString] JSONValue];
    if ([[responsedDict objectForKey: @"Result"] intValue]==1)
    {
        uploadFailed = NO;
        request.accessibilityHint = [[[responsedDict objectForKey: @"Data"] objectAtIndex: 0] objectForKey: @"Url"];
    }
    else
    {
        uploadFailed = YES;
    }
    uploading = NO;
}

-(void) requestFailed:(ASIHTTPRequest *)request
{
    [_commonUtils myLogString: 3 : @"upload failed: " : [[request error] description]];
    uploadFailed = YES;
    uploading = NO;
}


@end
