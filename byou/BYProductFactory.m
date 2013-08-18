//
//  BYProductFactory.m
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

NSString*(^createKey)(int,int) = ^(int collection,int pos) {
    return [NSString stringWithFormat:@"collection%dposition%d",collection,pos];
};

#define REQUEST_URL @"http://w0rkz.exceex.hu/byouWarehouse/imgs.php"

#import "BYProductFactory.h"

@implementation BYProductFactory {
    NSMutableData* receivedData;
    NSMutableString* imagesBaseHref;
    int actualCollection;
    int actualImage;
}

@synthesize Products;
@synthesize delegate;

-(id)initWithURL:(NSString *)initURL {
    if (self == [super init]) {
        if (initURL.length == 0) {
            initURL = REQUEST_URL;
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:initURL]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:30.0];

        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (connection) {
            receivedData = [NSMutableData data];
            imagesBaseHref = [NSMutableString string];
            actualCollection = 1;
            actualImage = 1;
            self.Products = [NSMutableDictionary dictionary];
        }
        
        ///////////////
        
        NSString* pwd=@"1111";

        NSString *post =[NSString stringWithFormat:@"pwd=%@",pwd];
        NSURL *url=[NSURL URLWithString:@"http://w0rkz.exceex.hu/byouWarehouse/auth.php?"];
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
        NSMutableURLRequest *arequest = [[NSMutableURLRequest alloc] init] ;
        [arequest setURL:url];
        [arequest setHTTPMethod:@"POST"];
        [arequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [arequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [arequest setHTTPBody:postData];
        
        
        NSError *error;
        NSURLResponse *response;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:arequest returningResponse:&response error:&error];
        
        NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",data);

        ///////////
        
        
        /*
        NSMutableDictionary *jsondict = [NSDictionary
                                         dictionaryWithObjects:[NSArray arrayWithObjects:@"3456",@"9876",nil]
                                         forKeys:[NSArray  arrayWithObjects:@"id",@"db", nil]];
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        [arr addObject:jsondict];
        NSError *jsonerr;
        NSData *jsondata = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:&jsonerr];
        NSString *jsonstring = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
         */
         NSString *jsonstring = @"{\"order\":[{\"id\":314,\"db\":456},{\"id\":657,\"db\":3}]}";

         NSString *apost =[NSString stringWithFormat:@"json=%@",jsonstring];
         NSURL *aurl=[NSURL URLWithString:@"http://w0rkz.exceex.hu/byouWarehouse/get.php"];
        
        
        NSData *apostData = [apost dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        //NSData *apostData = [NSData dataWithBytes:[jsonstring UTF8String] length:[jsonstring length]];
        NSLog(@"%@",apostData);
        NSLog(@"%@",[[NSString alloc] initWithData:apostData encoding:NSUTF8StringEncoding]);
        
        NSString *apostLength = [NSString stringWithFormat:@"%d", [apostData length]];
        NSLog(@"%@",jsonstring);
        
        NSMutableURLRequest *brequest = [[NSMutableURLRequest alloc] init] ;
        [brequest setURL:aurl];
        [brequest setHTTPMethod:@"POST"];
        [brequest setValue:apostLength forHTTPHeaderField:@"Content-Length"];
        [brequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [brequest setHTTPBody:apostData];
        
        
        NSError *aerror;
        NSHTTPURLResponse *aresponse;
        NSData *aurlData=[NSURLConnection sendSynchronousRequest:brequest returningResponse:&aresponse error:&aerror];

        NSLog(@"%@",[aresponse allHeaderFields]);
        
        NSString *adata=[[NSString alloc]initWithData:aurlData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",adata);
        
        
    
    }
    return self;
}

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

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"GALLERY"]) {
        imagesBaseHref = [attributeDict objectForKey:@"LOC"];
    }
    if ([elementName isEqualToString:@"IMAGE"]) {
        BYProduct* tempProduct = [[BYProduct alloc] init];
        tempProduct.pieces = [[attributeDict objectForKey:@"DB"] intValue];
        tempProduct.imageURL = [NSString stringWithFormat:@"%@/%@",imagesBaseHref,[attributeDict objectForKey:@"SRC"]];
        [self registerProduct:tempProduct
               withIdentifier:createKey(actualCollection, actualImage)];
        actualImage ++;
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    //NSLog(@"%@", self.Products);
    [self.delegate parserDidFinish:self];
}

-(void)registerProduct:(BYProduct *)product withIdentifier:(NSString *)identifier {
    [self.Products setObject:product forKey:identifier];
}

-(NSMutableDictionary*)getCollection:(int)colNumber {
    if (colNumber <= 0) colNumber = 1;
    NSMutableDictionary* tempCollection = [NSMutableDictionary dictionary];
    [self.Products enumerateKeysAndObjectsUsingBlock:^(NSString* key, BYProduct* obj, BOOL *stop) {
        if ([key hasPrefix:[NSString stringWithFormat:@"collection%d",colNumber]]) {
            [tempCollection setObject:obj forKey:key];
        }
    }];
    return tempCollection;
}

-(BYProduct*)getProductForm:(int)collection andPos:(int)pos {
    return [self.Products objectForKey:createKey(collection,pos)];
}

-(int)dividePieces:(int)Value forCollection:(int)collection andPos:(int)pos {
    BYProduct* tempProduct = [self getProductForm:collection andPos:pos];
    tempProduct.pieces -= Value;
    tempProduct.basket += Value;
    [self registerProduct:tempProduct withIdentifier:createKey(collection, pos)];
    return tempProduct.pieces;
}

-(NSMutableDictionary*)getProductWithBasketValues {
    __block NSMutableDictionary *tempList = [NSMutableDictionary dictionary];
    [self.Products enumerateKeysAndObjectsUsingBlock:^(NSString* key, BYProduct* obj, BOOL *stop) {
        if (obj.basket > 0) [tempList setObject:obj forKey:key];
    }];
    return tempList;
}

@end
