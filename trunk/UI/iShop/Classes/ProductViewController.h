//
//  ProductViewController.h
//  iShop
//
//  Created by Andrey Konovalov on 18.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

class CProductListContainer;
@class LoadMoreViewCell;

@interface ProductViewController : UIViewController
{
	IBOutlet LoadMoreViewCell	*loadMoreCell;
	IBOutlet UITableView		*mainTable;
	IBOutlet UIActivityIndicatorView *indicator;

	int				categoryId;
	int				itemsCnt;
	Boolean			isFavControl;
	NSString		*categoryName;
}
@property (nonatomic, retain) UITableViewCell	*loadMoreCell;
@property (nonatomic, retain) UITableView		*mainTable;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;


@property(readwrite) int categoryId;
@property(readwrite) int itemsCnt;
@property(readwrite) Boolean isFavControl;
@property (nonatomic, retain) NSString *categoryName;

@end
