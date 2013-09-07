//
//  BYProductFactory.h
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYProduct.h"
#import "BYMenu.h"
#import "BYOrder.h"

@class BYProductFactory;

@protocol BYProductFactoryDelegate

-(void)loginDidFinish;
-(void)collectionDidFinish;

@end

@interface BYProductFactory : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate, NSXMLParserDelegate>

-(void)authLoginName:(NSString*)usr withPass:(NSString*)pass;
-(void)refreshMenu;
-(void)registerMenu:(NSString*)menuName withJSONRequest:(NSString*)request;

-(void)registerProduct:(BYProduct*)product;
-(void)setProductValues:(int)position direction:(NSString*)direction;

-(void)getMenuContents:(int)menuIndex;
-(void)getOrderContents:(NSString*)idx;

-(BYProduct*)getProductForm:(int)pos;

-(NSString*)BasketItemsSumm;
-(int)OrderItemSumm;

-(void)PlaceOrder;
-(void)collectedOrder;

-(void)sendBasketInfoToDict:(NSString*)menuName;
-(void)getBasketInfoFromDict:(NSString*)menuName;

@property (nonatomic, strong) NSMutableArray* products;
@property (nonatomic, strong) NSMutableArray* menus;
@property (nonatomic, strong) NSMutableArray* actualOrderItems;
@property (nonatomic, strong) NSMutableDictionary* basket;
@property (nonatomic, strong) NSMutableDictionary* orders;
@property (nonatomic, weak) id <BYProductFactoryDelegate> delegate;
@property (nonatomic, strong) NSArray* allBasketKeys;

@property (nonatomic, strong) NSString* loginMessage;
@property (nonatomic, strong) UIColor* loginMessageColor;
@property (nonatomic, strong) NSString* userPwd;

@property int usrMode;

@end
