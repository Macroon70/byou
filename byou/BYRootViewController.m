//
//  BYRootViewController.m
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import "BYRootViewController.h"
#import "BYCellPrototypeLogin.h"
#import "BYCellPrototypeMenu.h"
#import "BYMenu.h"

@interface BYRootViewController ()

@end


@implementation BYRootViewController {
    UIActivityIndicatorView* loginAct;
    NSString* tableVersion;
}

@synthesize Products;
@synthesize scrollView;
@synthesize actualPieces;
@synthesize tableViewCont;
//@synthesize basketListView;

@synthesize userName;

@synthesize tableViews;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    /*
    self.scrollView = [[BYProductImagesScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    self.basketView = [[BYBasketView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,70)];
    self.basketView.delegateBasketAdd = self;
    [self.view addSubview:self.basketView];
    self.piecesPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, 70.0f, self.view.bounds.size.width, 100.0f)];
    self.piecesPicker.delegate = self;
    self.actualPieces = [NSMutableArray array];
    */
    //self.basketListView = [[BYBasketListViewController alloc] init];
    //self.basketListView.view.frame = CGRectMake(0.0f, 70.0f, self.view.bounds.size.width, self.view.bounds.size.height - 70.0);
    self.Products = [[BYProductFactory alloc] init];
    self.Products.delegate = self;
    tableVersion = @"Login";
    
}

-(void)scrollViewDidScroll:(UIScrollView *)sScrollView {
    [self.piecesPicker removeFromSuperview];
    if (sScrollView == self.scrollView) {
        int pageNum = (int)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
        [self.basketView refreshBasketView:[self.Products getProductForm:1 andPos:pageNum] withNum:pageNum];
    }
}


- (void)parserDidFinish:(BYProductFactory *)sender {
    [self.scrollView addProductsToView:[self.Products getCollection:1]];
    [self.basketView refreshBasketView:[self.Products getProductForm:1 andPos:0] withNum:1];
}

-(void)addBasketPushed {
    if ([self.view.subviews containsObject:self.piecesPicker]) {
        [self.piecesPicker removeFromSuperview];
    } else {
        int currentProduct = self.basketView.actualProduct;
        BYProduct* actualProduct = [self.Products getProductForm:1 andPos:currentProduct];
        [self.actualPieces removeAllObjects];
        for (int i=0; i <= actualProduct.pieces; i++) {
            [self.actualPieces addObject:[NSString stringWithFormat:@"%d darab",i]];
        }
        [self.piecesPicker reloadAllComponents];
        [self.view addSubview:self.piecesPicker];
    }
}

-(void)basketPushed {
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.actualPieces count];
}

-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    tempLabel.text = [self.actualPieces objectAtIndex:row];
    tempLabel.textAlignment = UITextAlignmentCenter;
    return tempLabel;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [pickerView removeFromSuperview];
    int newPieces = [self.Products dividePieces:row forCollection:1 andPos:self.basketView.actualProduct];
    self.basketView.stockInfo.text = [NSString stringWithFormat:@"Készleten %d",newPieces];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUserName:nil];
    [self setTableViews:nil];
    [self setStatusLabel:nil];
    [self setTableViewCont:nil];
    [super viewDidUnload];
}

#pragma mark - Login Methods

-(void)loginDidFinish {
    self.statusLabel.text = self.Products.loginMessage;
    self.statusLabel.textColor = self.Products.loginMessageColor;
    [loginAct stopAnimating];
    if ([self.Products.menus count] != 0) {
        tableVersion = @"Menu";
        [self.tableViewCont reloadData];
    }
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableVersion isEqualToString:@"Login"]) return 1;
    if ([tableVersion isEqualToString:@"Menu"]) return 2;
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableVersion isEqualToString:@"Login"]) return 3;
    if ([tableVersion isEqualToString:@"Menu"]) {
        if (section == 0) return [self.Products.menus count];
        if (section == 1) return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableVersion isEqualToString:@"Login"]) {
        if (indexPath.row == 2) {
            static NSString *cellIndetifier = @"LoginSend";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifier forIndexPath:indexPath];
            loginAct = (UIActivityIndicatorView*)[cell viewWithTag:1];
            return cell;
        } else {
            static NSString *CellIdentifier = @"LoginCell";
            BYCellPrototypeLogin *cell = (BYCellPrototypeLogin *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[BYCellPrototypeLogin alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
    
            switch (indexPath.row) {
                case 0:
                    cell.label.text = @"Felhasználó";
                    break;
                case 1:
                    cell.label.text = @"Jelszó";
                    cell.aTextField.secureTextEntry = YES;
                    break;
            }
            return cell;
        }
    }
    
    if ([tableVersion isEqualToString:@"Menu"]) {
        if (indexPath.section == 0) {
            static NSString *cellIdentifier = @"MenuCell";
            BYCellPrototypeMenu *cell = (BYCellPrototypeMenu*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                                          forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[BYCellPrototypeMenu alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.menuName.text = [(BYMenu*)[self.Products.menus objectAtIndex:indexPath.row] menuName];
            return cell;
        }
        if (indexPath.section == 1) {
            NSString *cellIdentifier = [[NSString alloc] init];
            if (indexPath.row == 0) {
                cellIdentifier = @"SignOutCell";
            } else {
                cellIdentifier = @"BasketCell";
            }
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableVersion isEqualToString:@"Login"]) {
        if (indexPath.row == 2) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            BYCellPrototypeLogin *cellAuth = (BYCellPrototypeLogin *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:indexPath.section]];
            BYCellPrototypeLogin *cellName = (BYCellPrototypeLogin *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
            [self.Products authLoginName:cellName.aTextField.text withPass:cellAuth.aTextField.text];
            cellAuth.aTextField.text = @"";
            cellName.aTextField.text = @"";
            [loginAct startAnimating];
            [self.view endEditing:YES];
        }
    }
    if ([tableVersion isEqualToString:@"Menu"]) {
        if (indexPath.row == 0 && indexPath.section == 1) {
            tableVersion = @"Login";
            [self.tableViewCont reloadData];
            self.statusLabel.text = @"";
        }
    }
}


@end
