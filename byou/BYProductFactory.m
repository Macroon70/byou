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

#define REQUEST_URL @"http://w0rkz.exceex.hu/byouWarehouse/"

#import "BYProductFactory.h"

@implementation BYProductFactory {

    NSString* URLMethod;
    NSMutableData* receivedData;
    NSString* usrName;
    NSString* actualMenu;
    int actualMenuId;
    NSMutableString* imagesBaseHref;

    int actualCollection;
    int actualImage;
}

@synthesize products;
@synthesize delegate;
@synthesize loginMessage;
@synthesize loginMessageColor;
@synthesize menus;

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

    if ([self setConnection:@"auth" withPostName:@"pwd" andPostValue:pass]) {
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

#pragma mark - Menu methods

-(void)getMenuContents:(int)menuIndex {
    URLMethod = @"Collection";
    BYMenu* collectMenuDetails = [self.menus objectAtIndex:menuIndex];
    if ([self setConnection:@"imgs" withPostName:@"getItems" andPostValue:collectMenuDetails.JSONRequest]) {
        self.products = [NSMutableArray array];
    }
}

-(void)registerProduct:(BYProduct *)product {
    [self.products addObject:product];
}

#pragma mark - Product Methods



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
            self.loginMessage = @"Hibás felhasználónév vagy jelszó!";
            self.loginMessageColor = [UIColor redColor];
            [parser abortParsing];
            [self.delegate loginDidFinish];
        } else if ([[attributeDict objectForKey:@"status"] isEqualToString:@"yes"]) {
            self.loginMessage = [NSString stringWithFormat:@"Bejelentkezve mint: %@", usrName];
            self.loginMessageColor = [UIColor blackColor];
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
        tempProduct.pieces = [[attributeDict objectForKey:@"DB"] intValue];
        tempProduct.imageURL = [NSString stringWithFormat:@"%@/%@",imagesBaseHref,[attributeDict objectForKey:@"SRC"]];
        [self registerProduct:tempProduct];
        actualImage ++;
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    if ([URLMethod isEqualToString:@"Login"]) [self.delegate loginDidFinish];
    if ([URLMethod isEqualToString:@"Collection"]) [self.delegate collectionDidFinish];
}

#pragma mark - old Methods



-(NSMutableDictionary*)getCollection:(int)colNumber {
    if (colNumber <= 0) colNumber = 1;
    NSMutableDictionary* tempCollection = [NSMutableDictionary dictionary];
/*    [self.products enumerateKeysAndObjectsUsingBlock:^(NSString* key, BYProduct* obj, BOOL *stop) {
        if ([key hasPrefix:[NSString stringWithFormat:@"collection%d",colNumber]]) {
            [tempCollection setObject:obj forKey:key];
        }
    }];*/
    return tempCollection;
}

-(BYProduct*)getProductForm:(int)collection andPos:(int)pos {
    //return [self.Products objectForKey:createKey(collection,pos)];
}

-(int)dividePieces:(int)Value forCollection:(int)collection andPos:(int)pos {
    BYProduct* tempProduct = [self getProductForm:collection andPos:pos];
    tempProduct.pieces -= Value;
    tempProduct.basket += Value;
    //[self registerProduct:tempProduct withIdentifier:createKey(collection, pos)];
    return tempProduct.pieces;
}

-(NSMutableDictionary*)getProductWithBasketValues {
    __block NSMutableDictionary *tempList = [NSMutableDictionary dictionary];
/*    [self.Products enumerateKeysAndObjectsUsingBlock:^(NSString* key, BYProduct* obj, BOOL *stop) {
        if (obj.basket > 0) [tempList setObject:obj forKey:key];
    }];*/
    return tempList;
}

@end
