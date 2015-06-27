//
//  CuoTiBenClient.h
//  cuotiben
//
//  Created by Alex on 13-5-13.
//  Copyright (c) 2013年 Flyrish.com. All rights reserved.
//

typedef enum OrgType
{
    HeadQuarter = 1,
    SubCompany= 2,
    Agency = 3,
    Store = 4,
    Warehouse = 5
} OrgType;

#import "HTTPClient.h"

@class QueuedQuestion;
@class CuoTi;

@interface JGWClient : HTTPClient
{
    BOOL uploadFailed;
    BOOL uploading;
}


@property (strong, nonatomic, readonly) NSString * localCacheKey;
@property BOOL needCancelButton;

+(JGWClient *) clientWithTarget:(id)target finishedAction:(SEL) finishedAction failedAction:(SEL) failedAction;
+(JGWClient *) sharedClient;

#pragma mark - API - 用户相关
//登陆接口
-(NSDictionary *) loginWithUser: (NSString *) user andPassword: (NSString *) password;

-(NSDictionary *) registerWithMobile: (NSString *) mobile andPassword: (NSString *) password andSMSCode: (NSString *) smsCode andCompanyName: (NSString *) companyName;
-(BOOL) sendConfirmCodeToMobile: (NSString *) mobile forUsage: (NSString *) usage;
-(BOOL) resetPassword: (NSString *) password withCode: (NSString *) code forMobile: (NSString *) mobile;
-(void) logout;
-(BOOL) uploadCertificateInfo: (NSString *) phone :(NSString *) licensePicUrl :(NSString *) organizePicUrl :(NSString *)taxPicUrl;
-(NSDictionary *) getCertificateInfo;
-(NSDictionary *) getEnterpriseInfo;
-(BOOL) saveEnterpriseInfo: (NSDictionary *) enterpriseInfoDict;
-(BOOL) changeOldPwd: (NSString *) oldPwd toNewPwd: (NSString *) newPwd;

//获取用户资料
-(NSDictionary *) getUserInfo;

//保存用户资料
-(NSDictionary *)editUserInfoWithUserName:(NSString *)userName andMobile:(NSString *)mobile andAddress:(NSString *)address andNote:(NSString *)note;

//修改密码
-(void)changePasswordWithOldPwd:(NSString *)oldPwd andNewPwd:(NSString *)newPwd;

#pragma mark - API - 产品批次相关
//新增批次
-(NSDictionary *) addWithBatchCode:(NSString *)batchCode andProductBatchContent:(NSString *)productBatchContent;

//编辑批次
-(NSDictionary *) editProductBatchWithId:(NSString *)id andProductBatchCode:(NSString *)batchCode andProductBatchContent:(NSString *)productBatchContent;

//获取批次列表
-(NSDictionary *) getProductBatchListWithPageSize:(int)pageSize
                                       andPageNum:(int)pageNum;
//获取批次信息
-(NSDictionary *) getProductBatchInfoWithID:(NSString *)id;

#pragma mark - API - 产品资料相关
//获取商品列表
-(NSDictionary *) getProductListWithPageSize:(int)pageSize
                                  andPageNum:(int)pageNum;
//新增商品信息
-(NSDictionary *) addProductInfoWithProductName:(NSString *)productName andClassifyID:(NSString *)classifyID andCategoryID:(NSString *)categoryID andPriceSell:(NSString *)priceSell andPriceOriginal:(NSString *)priceOriginal andStock:(int)stock andLayer3UnitID:(int)layer3UnitID andThumbnail:(NSArray *)thumbnail;

//编辑商品信息
-(NSDictionary *) editProductInfoWithID:(NSString *)id andProductName:(NSString *)productName andClassifyID:(NSString *)classifyID andCategoryID:(NSString *)categoryID andPriceSell:(NSString *)priceSell andPriceOriginal:(NSString *)priceOriginal andStock:(int)stock andLayer3UnitID:(int)layer3UnitID andThumbnail:(NSArray *)thumbnail;

#pragma mark - API - 获取机构信息
//获取基地信息
-(NSDictionary *) getOrgInfoWithID:(NSString *)id;

//机构新增／编辑
-(NSDictionary *) editOrgInfoWithOrgName:(NSString *)orgName andOrgCode:(NSString *)orgCode andOrgType:(int)orgType andParentID:(NSString *)parentID andProvince:(NSString *)province andCity:(NSString *)city andDistrict:(NSString *)district andRegionCode:(NSString *)regionCode;

#pragma mark - API - 历史扫码相关
//历史扫码
-(NSDictionary *) getLogisticsCodeListWithpageSize:(int)pageSize andPageNum:(int)pageNum;


#pragma mark - API - 商城相关
-(NSDictionary *) getMallInfo;
-(BOOL) saveMallInfoWithDictionary: (NSDictionary *) mallDict;

#pragma mark - API - 商品相关
-(NSArray *) getProductClassify;
-(BOOL) uploadProductClassify: (NSArray *) productClassifyList;
-(NSArray *) getSystemCategory;
-(NSDictionary *) getProductListByClassifyID: (NSString *) classifyID andStatus: (int) status orderBy: (NSString *) orderField andAscending: (BOOL) ascending andPageSize: (int) pageSize andPageNo: (int) pageNo;
-(NSDictionary *) getProductDetailByGUID: (NSString *) guid;
-(NSString *) saveProductDetailFromDict: (NSDictionary *) productDict;
-(BOOL) deleteProductByGUID: (NSString *) guid;

#pragma mark - API - 积分相关
//获取某人的积分记录
-(NSDictionary *) getPointChargeRecordForUser: (NSString *) userID andUserType: (int) userType andKeyword: (NSString *) keyword andPageSize: (int) pageSize andPageNo: (int) pageNo;

#pragma mark - API - 门店相关
-(NSDictionary *) getOrgListByOrgType: (OrgType) orgType inCity: (NSString *) cityName  orderByField: (NSString *) orderField orderSequence: (BOOL) asc andSearchBy: (NSString *) key andPageSize: (int) pageSize andPageNo: (int) pageNO;
-(NSDictionary *) getOrgInfoByID: (NSString *) orgID;

-(NSString *) saveOrgInfo: (NSDictionary *) orgDict andOrgType: (OrgType) orgType;
-(BOOL) changeStatus:(BOOL) status byOrgID: (NSString *) orgID;
-(NSArray *) getStoreRegionList;
-(NSArray *) getAllCityList;


#pragma mark - API - 会员相关

//会员注册
//-(NSDictionary *) memberRegisterWithLonginName: (NSString *) loginName andProvince: (NSString *) province andCity: (NSString *) city andDistrict: (NSString *) district;
-(NSDictionary *) saveMemberInfoWithDict: (NSDictionary *) memberDict; //保存会员资料（注册、修改）
-(NSDictionary *) savePointForMobile: (NSString *) mobile withCodeList: (NSArray *) codeList; //会员积分（多个积分码）
-(NSDictionary *) searchMemberWithKeyword: (NSString *) keyword andPageNum:(int)pageNum; //会员搜索（会员资料）
-(NSDictionary *) getMemberInfoByID: (NSString *) customerID; //获取会员详情
-(NSDictionary *) getMemberChargeListByKeyword: (NSString *) keyword andPageSize: (int) pageSize andPageNo: (int) pageNo; //还没有实现

#pragma mark - API - 导购相关
-(NSDictionary *) getSalesListByKeyword: (NSString *) keyword andPageSize: (int) pageSize andPageNo: (int) pageNo;
-(NSDictionary *) getSalesInfoByID: (NSString *) salesID;
-(BOOL) saveSalesInfo: (NSDictionary *) salesDict;
//-(NSDictionary *) getSalesOrganizeListByType: (NSString *) csvOrgType andKeyword: (NSString *) keyword andPageSize: (int) pageSize andPageNo: (int) pageNo;
-(NSDictionary *) getSelectableOrgListByType: (NSString *) csvOrgType orderByField: (NSString *) orderField orderSequence: (BOOL) asc andSearchBy: (NSString *) key andPageSize: (int) pageSize andPageNo: (int) pageNO;
-(BOOL) enableSalesByID: (NSString *) salesID status: (BOOL) enabled;
-(NSDictionary *) getSalesChargeListByKeyword: (NSString *) keyword andPageSize: (int) pageSize andPageNo: (int) pageNo;

#pragma mark - 推送相关
-(BOOL) registerTagsToGeTui;

#pragma mark - API - 基础
-(NSString *) uploadFile: (NSString *) filepath;


@end
