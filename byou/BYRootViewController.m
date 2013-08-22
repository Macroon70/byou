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
    UIActivityIndicatorView* menuAct;
    NSString* menuName;
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
        //[self.basketView refreshBasketView:[self.Products getProductForm:1 andPos:pageNum] withNum:pageNum];
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
    [self setBack_button:nil];
    [self setCategoryName:nil];
    [self setCategoryCont:nil];
    [self setStockInfo:nil];
    [self setBasketInfo:nil];
    [self setItemInfoCont:nil];
    [super viewDidUnload];
}

#pragma mark - self delegates

-(IBAction)back_pushed:(id)sender {
    self.back_button.hidden = YES;
    self.CategoryCont.hidden = YES;
    self.itemInfoCont.hidden = YES;
    [self.scrollView removeFromSuperview];
}

- (IBAction)nextItem:(id)sender {
    CGPoint currentOffset = self.scrollView.contentOffset;
    currentOffset.x = currentOffset.x + self.view.bounds.size.width;
    if (self.scrollView.contentSize.width > currentOffset.x)
        [self.scrollView setContentOffset:currentOffset animated:YES];
}

- (IBAction)prevItem:(id)sender {
    CGPoint currentOffset = self.scrollView.contentOffset;
    currentOffset.x = currentOffset.x - self.view.bounds.size.width;
    if (currentOffset.x >= 0)
        [self.scrollView setContentOffset:currentOffset animated:YES];
}

- (IBAction)basketDec:(id)sender {
}

- (IBAction)basketInc:(id)sender {
}


#pragma mark - Factory Delegates

-(void)loginDidFinish {
    self.statusLabel.text = self.Products.loginMessage;
    self.statusLabel.textColor = self.Products.loginMessageColor;
    [loginAct stopAnimating];
    if ([self.Products.menus count] != 0) {
        tableVersion = @"Menu";
        [self.tableViewCont reloadData];
    }
}

-(void)collectionDidFinish {
    self.scrollView = [[BYProductImagesScrollView alloc] initWithFrame:CGRectMake(0.0f, 56.0f, self.view.bounds.size.width, self.view.bounds.size.height - 56.0f)];
    self.scrollView.delegate = self;
    self.back_button.hidden = NO;
    self.CategoryCont.hidden = NO;
    self.itemInfoCont.hidden = NO;
    self.CategoryName.text = menuName;
    [menuAct stopAnimating];
    [self.scrollView addProductsToView:self.Products.products];
    //[self.basketView refreshBasketView:[self.Products getProductForm:1 andPos:0] withNum:1];
    [self.view insertSubview:self.scrollView belowSubview:self.CategoryCont];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableVersion isEqualToString:@"Login"]) return 1;
    if ([tableVersion isEqualToString:@"Menu"]) return 3;
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableVersion isEqualToString:@"Login"]) return 3;
    if ([tableVersion isEqualToString:@"Menu"]) {
        if (section == 0) return [self.Products.menus count];
        if (section == 1) return 1;
        if (section == 2) return 1;
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
            static NSString *cellIdentifier = @"BasketCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            return cell;
        }
        if (indexPath.section == 2) {
            static NSString *cellIdentifier = @"SignOutCell";
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
        if (indexPath.row == 0 && indexPath.section == 2) {
            tableVersion = @"Login";
            [self.tableViewCont reloadData];
            self.statusLabel.text = @"";
        }
        
        if (indexPath.section == 0) {
            BYCellPrototypeMenu *clickedCell = (BYCellPrototypeMenu*)[tableView cellForRowAtIndexPath:indexPath];
            menuAct = clickedCell.menuItemsLoading;
            menuName = clickedCell.menuName.text;
            [menuAct startAnimating];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.Products getMenuContents:indexPath.row];
        }
    }
}


@end
