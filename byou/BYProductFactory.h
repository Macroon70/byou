//
//  BYProductFactory.h
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYProduct.h"

@class BYProductFactory;

@protocol BYProductFactoryDelegate

-(void)parserDidFinish:(BYProductFactory*)sender;

@end

@interface BYProductFactory : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate, NSXMLParserDelegate>

-(void)registerProduct:(BYProduct*)product withIdentifier:(NSString*)identifier;
-(int)dividePieces:(int)Value forCollection:(int)collection andPos:(int)pos;
-(NSMutableDictionary*)getProductWithBasketValues;
-(id)initWithURL:(NSString*)initURL;
-(NSMutableDictionary*)getCollection:(int)colNumber;

-(BYProduct*)getProductForm:(int)collection andPos:(int)pos;

@property (nonatomic, strong) NSMutableDictionary* Products;
@property (nonatomic, weak) id <BYProductFactoryDelegate> delegate;

@end
