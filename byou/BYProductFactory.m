//
//  BYProductFactory.m
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

NSString*(^createKey)(NSString*,NSString*) = ^(NSString* collection,NSString* subCol) {
    return [NSString stringWithFormat:@"%@ - %@",collection,subCol];
};

NSString*(^createJSONRequest)(int,int) = ^(int menuId,int colorId) {
    return [NSString stringWithFormat:@"{\"menuId\":%d, \"colorId\":%d}", menuId, colorId];
};

NSString*(^createKeyForBasket)(NSString*,int) = ^(NSString* collection,int ID) {
    return [NSString stringWithFormat:@"%@ - %d",collection,ID];
};

NSString*(^thousandSeparate3)(int) = ^(int number) {
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@" "];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];
    return [formatter stringFromNumber:[NSNumber numberWithInt:number]];
};


#define REQUEST_URL @"http://w0rkz.exceex.hu/byouWarehouse/"

#import "BYProductFactory.h"

@implementation BYProductFactory {

    NSString* URLMethod;
    NSMutableData* receivedData;
    NSString* usrName;
    NSString* actualMenu;
    NSString* actualName;
    int actualMenuId;
    int userId;
    NSString* actualOrder;
    NSString* actualDate;
    NSMutableString* imagesBaseHref;
    int actualCollection;
    int actualImage;
}

@synthesize products;
@synthesize delegate;
@synthesize loginMessage;
@synthesize loginMessageColor;
@synthesize menus;
@synthesize basket;
@synthesize allBasketKeys;
@synthesize usrMode;
@synthesize orders;
@synthesize actualOrderItems;
@synthesize userPwd;

#pragma mark - Init methods

-(id)init {
    if (self = [super init]) {
    }
    return self;
}


#pragma mark - Login Methods

-(void)authLoginName:(NSString *)usr withPass:(NSString *)pass {
    URLMethod = @"Login";
    usrName = usr;
    self.loginMessage = @"";
    if ([pass length] == 0) pass = @"__empty";
    self.userPwd = pass;
    if ([self setConnection:@"auth" withPostName:@"pwd" andPostValue:userPwd]) {
        receivedData = [NSMutableData data];
        imagesBaseHref = [NSMutableString string];
        actualCollection = 1;
        actualImage = 1;
        actualOrder = [NSString string];
        self.actualOrderItems = [NSMutableArray array];
        self.menus = [NSMutableArray array];
        self.basket = [NSMutableDictionary dictionary];
        self.orders = [NSMutableDictionary dictionary];
        self.allBasketKeys = [NSArray array];
    }
}

-(void)refreshMenu {
    URLMethod = @"Login";
    if ([self setConnection:@"auth" withPostName:@"pwd" andPostValue:userPwd]) {
        receivedData = [NSMutableData data];
        imagesBaseHref = [NSMutableString string];
        actualCollection = 1;
        actualImage = 1;
        self.menus = [NSMutableArray array];
    }
}

-(void)registerMenu:(NSString *)menuName withJSONRequest:(NSString *)request {
    BYMenu* tempMenu = [[BYMenu alloc] init];
    tempMenu.menuName = menuName;
    tempMenu.JSONRequest = request;
    [self.menus addObject:tempMenu];
}

#pragma mark - Basket methods

-(void)sendBasketInfoToDict:(NSString*)menuName {
    [self.products enumerateObjectsUsingBlock:^(BYProduct* obj, NSUInteger idx, BOOL *stop) {
        NSString* basketKey = createKeyForBasket(menuName,obj.ID);
        if ([self.basket objectForKey:basketKey] != nil) {
            if (obj.basket == 0) {
                [self.basket removeObjectForKey:basketKey];
            } else {
                [self.basket setObject:obj forKey:basketKey];
            }
        } else {
            if (obj.basket != 0) {
                [self.basket setObject:obj forKey:basketKey];
            }
        }
        self.allBasketKeys = [self.basket allKeys];
    }];
}

-(void)getBasketInfoFromDict:(NSString*)menuName {
    [[self.products copy] enumerateObjectsUsingBlock:^(BYProduct* obj, NSUInteger idx, BOOL *stop) {
        NSString* basketKey = createKeyForBasket(menuName,obj.ID);
        if ([self.basket objectForKey:basketKey] != nil) {
            BYProduct *tempObject = [self.basket objectForKey:basketKey];
            tempObject.pieces = obj.pieces;
            tempObject.imageURL = obj.imageURL;
            if (tempObject.pieces < tempObject.basket) {
                tempObject.basket = tempObject.pieces;
            }
            tempObject.pieces -= tempObject.basket;
            [self.products replaceObjectAtIndex:idx withObject:tempObject];
        }
    }];
}

-(NSString*)BasketItemsSumm {
    __block int itemsSumm = 0, valueSumm = 0;
    [self.basket enumerateKeysAndObjectsUsingBlock:^(id key, BYProduct* obj, BOOL *stop) {
        itemsSumm += obj.basket;
        valueSumm += obj.basket * obj.itemPrice;
    }];
    return [NSString stringWithFormat:@"Összesen: %d db, %@ Ft",itemsSumm,thousandSeparate3(valueSumm)];
}

#pragma mark - Menu methods

-(void)getMenuContents:(int)menuIndex {
    URLMethod = @"Collection";
    BYMenu* collectMenuDetails = [self.menus objectAtIndex:menuIndex];
    actualName = collectMenuDetails.menuName;
    if ([self setConnection:@"imgs" withPostName:@"getItems" andPostValue:collectMenuDetails.JSONRequest]) {
        self.products = [NSMutableArray array];
    }
}

-(void)getOrderContents:(NSString *)idx {
    self.actualOrderItems = [self.orders objectForKey:idx];
}

-(void)registerProduct:(BYProduct *)product {
    [self.products addObject:product];
}

-(void)setProductValues:(int)position direction:(NSString *)direction {
    BYProduct *changingProduct = [self.products objectAtIndex:position];
    if ([direction isEqualToString:@"UP"] && changingProduct.pieces != 0) {
        changingProduct.basket ++;
        changingProduct.pieces --;
    } else if ([direction isEqualToString:@"DOWN"] && changingProduct.basket != 0) {
        changingProduct.basket --;
        changingProduct.pieces ++;
    }
}


#pragma mark - Product Methods

-(BYProduct*)getProductForm:(int)pos {
    return [self.products objectAtIndex:pos];
}

#pragma mark - Basket Methods

-(void)PlaceOrder {
    URLMethod = @"PlaceOrder";
    __block NSString *JSONrequest = @"{\"order\":[";
    [self.basket enumerateKeysAndObjectsUsingBlock:^(id key, BYProduct* obj, BOOL *stop) {
        JSONrequest = [NSString stringWithFormat:@"%@{\"id\":%d,\"db\":%d,\"userid\":%d},",JSONrequest,obj.ID,obj.basket,userId];
    }];
    JSONrequest = [JSONrequest substringToIndex:[JSONrequest length] -1];
    JSONrequest = [NSString stringWithFormat:@"%@]}",JSONrequest];
    NSLog(@"%@",JSONrequest);
    if ([self setConnection:@"get" withPostName:@"json" andPostValue:JSONrequest]) {
        self.products = [NSMutableArray array];
    }
    [self.basket removeAllObjects];
    self.allBasketKeys = [NSArray array];
    
}

#pragma mark - Order Methods

-(void)addOrder:(NSDictionary*)orderDeatils {
    BYOrder* tempOrder = [[BYOrder alloc] init];
    tempOrder.itemCategory = [orderDeatils objectForKey:@"category"];
    tempOrder.itemNo = [orderDeatils objectForKey:@"cikkszam"];
    tempOrder.itemId = [[orderDeatils objectForKey:@"id"] intValue];
    tempOrder.itemImg = [orderDeatils objectForKey:@"img"];
    tempOrder.itemPrice = [[orderDeatils objectForKey:@"price"] intValue];
    tempOrder.itemQuantity = [[orderDeatils objectForKey:@"qty"] intValue];
    tempOrder.itemQuantityRel = tempOrder.itemQuantity;
    tempOrder.state = 0;
    tempOrder.orderDate = actualDate;
    tempOrder.orderId = [actualOrder intValue];
    NSString* idxName = [NSString stringWithFormat:@"Rendelés - %@", tempOrder.orderDate];
    if ([[self.orders allKeys] containsObject:idxName]) {
        NSMutableArray* tempArray = [self.orders objectForKey:idxName];
        [tempArray addObject:tempOrder];
        [self.orders setObject:tempArray forKey:idxName];
    } else {
        NSMutableArray* tempArray = [NSMutableArray arrayWithObject:tempOrder];
        [self.orders setObject:tempArray forKey:idxName];
    }
    NSLog(@"%@",self.orders);
}

-(int)OrderItemSumm {
    __block int summ = 0;
    [self.actualOrderItems enumerateObjectsUsingBlock:^(BYOrder* obj, NSUInteger idx, BOOL *stop) {
        summ += obj.itemQuantityRel;
    }];
    return summ;
}

-(void)collectedOrder {
    URLMethod = @"PlaceOrder";
    __block NSString *JSONrequest = @"{\"collOrder\":[";
    __block NSString* aId;
    [self.actualOrderItems enumerateObjectsUsingBlock:^(BYOrder* obj, NSUInteger idx, BOOL *stop) {
        JSONrequest = [NSString stringWithFormat:@"%@{\"id\":%d,\"db\":%d,\"colldb\":%d,\"userid\":%d,\"buyId\":%d},",
                       JSONrequest,obj.itemId,obj.itemQuantity,obj.itemQuantityRel,userId,obj.orderId];
        aId = obj.orderDate;

    }];
    JSONrequest = [JSONrequest substringToIndex:[JSONrequest length] -1];
    JSONrequest = [NSString stringWithFormat:@"%@]}",JSONrequest];
    NSString* deleteOrder = [NSString stringWithFormat:@"Rendelés - %@",aId];
    NSLog(@"%@",JSONrequest);
    if ([self setConnection:@"confirm" withPostName:@"json" andPostValue:JSONrequest]) {
        [self.actualOrderItems removeAllObjects];
        [self.orders removeObjectForKey:deleteOrder];
    }
}


#pragma mark - URlConnection methods

-(NSURLConnection*)setConnection:(NSString*)phpFileName withPostName:(NSString*)postName andPostValue:(NSString*)postValue {
    NSURL *initURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.php",REQUEST_URL,phpFileName]];
    NSString *post =[NSString stringWithFormat:@"%@=%@",postName,postValue];
    
    NSLog(@"%@",post);
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:initURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:40.0f];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%@",connection);
    return connection;
    
}

#pragma mark - URlConnection Delegates

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary* headers = [httpResponse allHeaderFields];
    NSLog(@"%@",headers);
    if ([[headers objectForKey:@"Content-Type"] hasPrefix:@"text/xml"]) {
        NSLog(@"%@",headers);
        receivedData.length = 0;
        if ([[headers objectForKey:@"Content-Length"] intValue] == 37 && [URLMethod isEqualToString:@"Login"]) {
            self.loginMessage = @"Hibás jelszó!";
            self.loginMessageColor = [UIColor redColor];
            [self.delegate loginDidFinish];
        }
    } else {
        NSLog(@"itt");
        [connection cancel];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([receivedData length] > 0) {
        NSLog(@"%@",[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
        NSLog(@"%d",[receivedData length]);
    
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];
        [parser setDelegate:self];
        [parser setShouldReportNamespacePrefixes:YES];
        [parser setShouldResolveExternalEntities:YES];
        [parser parse];
    }
}

#pragma mark - XMLParser delegates

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    NSLog(@"%@",elementName);
    NSLog(@"%@",attributeDict);
    
    // Auth node
    if ([elementName isEqualToString:@"result"]) {
        if ([[attributeDict objectForKey:@"status"] isEqualToString:@"yes"]) {
            userId = [[attributeDict objectForKey:@"userid"] intValue];
            usrName = [NSString stringWithFormat:@"%@",[attributeDict objectForKey:@"username"]];
            self.loginMessage = [NSString stringWithFormat:@"Bejelentkezve mint: %@", [attributeDict objectForKey:@"username"]];
            self.loginMessageColor = [UIColor blackColor];
            self.usrMode = [[attributeDict objectForKey:@"mode"] intValue];
        }
    }
    
    // Category menu nodes
    if ([elementName isEqualToString:@"menu"]) {
        actualMenu = [attributeDict objectForKey:@"name"];
        actualMenuId = [[attributeDict objectForKey:@"menuId"] intValue];
    }
    
    if ([elementName isEqualToString:@"sub"]) {
        [self registerMenu:createKey(actualMenu,[attributeDict objectForKey:@"name"])
           withJSONRequest:createJSONRequest(actualMenuId,[[attributeDict objectForKey:@"colorId"] intValue])];
    }
    
    // Category values
    if ([elementName isEqualToString:@"GALLERY"]) {
        imagesBaseHref = [attributeDict objectForKey:@"LOC"];
    }
    
    if ([elementName isEqualToString:@"IMAGE"]) {
        BYProduct* tempProduct = [[BYProduct alloc] init];
        tempProduct.CategoryName = actualName;
        tempProduct.pieces = [[attributeDict objectForKey:@"DB"] intValue];
        tempProduct.imageURL = [NSMutableString stringWithFormat:@"%@/%@",imagesBaseHref,[attributeDict objectForKey:@"SRC"]];
        tempProduct.ID = [[attributeDict objectForKey:@"ITEMID"] intValue];
        if ([[attributeDict objectForKey:@"PRICE"] length] != 0) {
            tempProduct.itemPrice = [[attributeDict objectForKey:@"PRICE"] intValue];
        }
        tempProduct.itemSummPrice = tempProduct.itemPrice * tempProduct.pieces;
        tempProduct.itemNo = [NSString stringWithFormat:@"%@", [attributeDict objectForKey:@"CIKKSZAM"]];
        [self registerProduct:tempProduct];
        actualImage ++;
    }
    
    // Orders
    if ([elementName isEqualToString:@"order"]) {
        actualOrder = (NSString*)[attributeDict objectForKey:@"id"];
        actualDate = (NSString*)[attributeDict objectForKey:@"date"];
    }
    
    if ([elementName isEqualToString:@"item"]) {
        [self addOrder:attributeDict];
    }
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"Parse end");
    if ([URLMethod isEqualToString:@"Login"]) [self.delegate loginDidFinish];
    if ([URLMethod isEqualToString:@"Collection"]) [self.delegate collectionDidFinish];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Parser error: %@", parseError);
    if ([URLMethod isEqualToString:@"Login"]) [self.delegate loginDidFinish];
}

@end
