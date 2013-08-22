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

@class BYProductFactory;

@protocol BYProductFactoryDelegate

-(void)loginDidFinish;
-(void)collectionDidFinish;

@end

@interface BYProductFactory : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate, NSXMLParserDelegate>

-(void)authLoginName:(NSString*)usr withPass:(NSString*)pass;
-(void)registerMenu:(NSString*)menuName withJSONRequest:(NSString*)request;

-(void)registerProduct:(BYProduct*)product;


-(void)getMenuContents:(int)menuIndex;



-(int)dividePieces:(int)Value forCollection:(int)collection andPos:(int)pos;
-(NSMutableDictionary*)getProductWithBasketValues;
-(NSMutableDictionary*)getCollection:(int)colNumber;

-(BYProduct*)getProductForm:(int)collection andPos:(int)pos;

@property (nonatomic, strong) NSMutableArray* products;
@property (nonatomic, strong) NSMutableArray* menus;
@property (nonatomic, weak) id <BYProductFactoryDelegate> delegate;

@property (nonatomic, strong) NSString* loginMessage;
@property (nonatomic, strong) UIColor* loginMessageColor;

@end
