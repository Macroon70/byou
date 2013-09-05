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
    NSString* userPwd;
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

#pragma mark - Init methods

-(id)init {
    if (self = [super init]) {
    }
    return self;
}


#pragma mark - Login Methods

-(void)authLoginName:(NSString *)usr withPass:(NSString *)pass {
    userPwd = pass;
    URLMethod = @"Login";
    usrName = usr;
    self.loginMessage = @"";
    if ([pass length] == 0) pass = @"__empty";

    if ([self setConnection:@"auth" withPostName:@"pwd" andPostValue:userPwd]) {
        receivedData = [NSMutableData data];
        imagesBaseHref = [NSMutableString string];
        actualCollection = 1;
        actualImage = 1;
        self.menus = [NSMutableArray array];
        self.basket = [NSMutableDictionary dictionary];
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

-(int)BasketItemsSumm {
    __block int itemsSumm = 0;
    [self.basket enumerateKeysAndObjectsUsingBlock:^(id key, BYProduct* obj, BOOL *stop) {
        itemsSumm += obj.basket;
    }];
    return itemsSumm;
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

#pragma mark - URlConnection methods

-(NSURLConnection*)setConnection:(NSString*)phpFileName withPostName:(NSString*)postName andPostValue:(NSString*)postValue {
    NSURL *initURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.php",REQUEST_URL,phpFileName]];
    NSString *post =[NSString stringWithFormat:@"%@=%@",postName,postValue];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:initURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:10.0f];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    return connection;
    
}

#pragma mark - URlConnection Delegates

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary* headers = [httpResponse allHeaderFields];
    if ([headers objectForKey:@"Content-Length"] > 0 && [[headers objectForKey:@"Content-Type"] hasPrefix:@"text/xml"]) {
        receivedData.length = 0;
        if ([URLMethod isEqualToString:@"Login"]) {
            self.loginMessage = @"Hibás jelszó!";
            self.loginMessageColor = [UIColor redColor];
            [self.delegate loginDidFinish];
        }
    } else {
        [connection cancel];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser setShouldReportNamespacePrefixes:YES];
    [parser setShouldResolveExternalEntities:YES];
    [parser parse];
}

#pragma mark - XMLParser delegates

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    // Auth node
    if ([elementName isEqualToString:@"result"]) {
        if ([[attributeDict objectForKey:@"status"] isEqualToString:@"no"]) {
            self.loginMessage = @"Hibás jelszó!";
            self.loginMessageColor = [UIColor redColor];
            [parser abortParsing];
            [self.delegate loginDidFinish];
            NSLog(@"it");
        } else if ([[attributeDict objectForKey:@"status"] isEqualToString:@"yes"]) {
            userId = [[attributeDict objectForKey:@"userid"] intValue];
            NSLog(@"%@",[attributeDict objectForKey:@"username"]);
            usrName = [NSString stringWithFormat:@"%@",[attributeDict objectForKey:@"username"]];
            self.loginMessage = [NSString stringWithFormat:@"Bejelentkezve mint: %@", [attributeDict objectForKey:@"username"]];
            self.loginMessageColor = [UIColor blackColor];
        }
    }
    
    // Category menu nodes
    if ([elementName isEqualToString:@"menu"]) {
        actualMenu = [attributeDict objectForKey:@"name"];
        actualMenuId = [[attributeDict objectForKey:@"menuId"] intValue];
        //userId = [[attributeDict objectForKey:@"userid"] intValue];
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
        tempProduct.imageURL = [NSString stringWithFormat:@"%@/%@",imagesBaseHref,[attributeDict objectForKey:@"SRC"]];
        tempProduct.ID = [[attributeDict objectForKey:@"ITEMID"] intValue];
        [self registerProduct:tempProduct];
        actualImage ++;
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    if ([URLMethod isEqualToString:@"Login"]) [self.delegate loginDidFinish];
    if ([URLMethod isEqualToString:@"Collection"]) [self.delegate collectionDidFinish];
}

@end
