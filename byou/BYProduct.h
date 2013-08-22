//
//  BYProduct.h
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYProduct : NSObject

@property (nonatomic, strong) NSMutableString* imageURL;
@property (nonatomic, strong) NSString* CategoryName;
@property int ID;
@property int pieces;
@property int basket;

@end
