//
//  PGBSearchViewController.m
//  ProjectBook
//
//  Created by Wo Jun Feng on 11/30/15.
//  Copyright © 2015 FIS. All rights reserved.
//

#import "PGBSearchViewController.h"
#import "PGBBookViewController.h"
#import "PGBSearchCustomTableCell.h"
#import "PGBRealmBook.h"
#import "PGBDataStore.h"
#import "Book.h"
#import <Masonry/Masonry.h>


@interface PGBSearchViewController () <UISearchBarDelegate, UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *bookTableView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) UISearchBar *bookSearchBar;
@property (strong, nonatomic) UIView *defaultContentView;

@property (strong, nonatomic) NSMutableArray *books;
@property (strong, nonatomic) PGBDataStore *dataStore;

@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboardGesture;

@property (nonatomic, strong) NSOperationQueue *bgQueue;
@property (nonatomic, strong) NSOperationQueue *bookCoverBgQueue;

@property (nonatomic, strong) NSTimer *searchTimer;

@end

@implementation PGBSearchViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadDefaultView];
    
    self.dataStore = [PGBDataStore sharedDataStore];
    [self.dataStore fetchData];
    
    self.books = [[NSMutableArray alloc]init];
    
    self.dismissKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:self.dismissKeyboardGesture];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bookSearchBar.hidden = NO;
}

- (void)loadDefaultView
{
    //create search bar
    self.bookSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 10, self.navigationController.navigationBar.bounds.size.width, self.navigationController.navigationBar.bounds.size.height/2)];
    self.bookSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.bookSearchBar.placeholder = @"Search";
    self.bookSearchBar.delegate = self;
    
    [self.navigationController.navigationBar addSubview:self.bookSearchBar];
    
    [self.bookSearchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 10, 0, 10));
    }];
    
    //create table view custom cell
    [self.bookTableView registerNib:[UINib nibWithNibName:@"PGBSearchCustomTableCell" bundle:nil] forCellReuseIdentifier:@"SearchCustomCell"];
    self.bookTableView.rowHeight = 70;
    
    self.bookTableView.delegate = self;
    self.bookTableView.dataSource = self;
    
    //create default content view to show book genres
    self.defaultContentView = [[UIView alloc]initWithFrame:[self.bookTableView bounds]];
    self.defaultContentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.defaultContentView];
    
    [self.defaultContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    //create book genre buttons into stack view
    UIButton *fictionButton = [self createGenreButtonWithTitle:@"Fiction"];
    UIButton *romanceButton = [self createGenreButtonWithTitle:@"Romance"];
    UIButton *dramaButton = [self createGenreButtonWithTitle:@"Drama"];
    UIButton *historyButton = [self createGenreButtonWithTitle:@"History"];
    UIButton *comedyButton = [self createGenreButtonWithTitle:@"Comedy"];
    UIButton *operaButton = [self createGenreButtonWithTitle:@"Opera"];
    UIButton *biographyButton = [self createGenreButtonWithTitle:@"Biography"];
    UIButton *childrenButton = [self createGenreButtonWithTitle:@"Children"];
    
    //adding buttons to stack view
    UIStackView *genreButtonStackView = [[UIStackView alloc]init];
    genreButtonStackView.axis = UILayoutConstraintAxisVertical;
    genreButtonStackView.distribution = UIStackViewDistributionFillEqually;
    genreButtonStackView.alignment = UIStackViewAlignmentCenter;
    genreButtonStackView.spacing = 0;
    
    [genreButtonStackView addArrangedSubview:fictionButton];
    [genreButtonStackView addArrangedSubview:romanceButton];
    [genreButtonStackView addArrangedSubview:dramaButton];
    [genreButtonStackView addArrangedSubview:historyButton];
    [genreButtonStackView addArrangedSubview:comedyButton];
    [genreButtonStackView addArrangedSubview:operaButton];
    [genreButtonStackView addArrangedSubview:biographyButton];
    [genreButtonStackView addArrangedSubview:childrenButton];
    
    genreButtonStackView.translatesAutoresizingMaskIntoConstraints = false;
    [self.defaultContentView addSubview:genreButtonStackView];
    
    [genreButtonStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.defaultContentView);
    }];
}


- (void)genreButtonTapped:(UIButton *)sender
{
    self.bookSearchBar.text = sender.titleLabel.text;
    [self.bookSearchBar becomeFirstResponder];
    [self searchBar:self.bookSearchBar textDidChange:self.bookSearchBar.text];
}

- (UIButton *)createGenreButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    
    [button addTarget:self
                      action:@selector(genreButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma UITableView DataSource Method ::
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.books.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.bookTableView) {
        
        PGBSearchCustomTableCell *cell = (PGBSearchCustomTableCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchCustomCell" forIndexPath:indexPath];
        
        PGBRealmBook *realmBook = self.books[indexPath.row];
        
        if (realmBook.title.length != 0) {
            cell.titleLabel.text = realmBook.title;
        } else {
            cell.titleLabel.text = realmBook.friendlyTitle;
        }
        
        cell.authorLabel.text = realmBook.author;
        cell.genreLabel.text = realmBook.genre;
        
        return cell;
    }
    
    return [[UITableViewCell alloc]init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.bookSearchBar resignFirstResponder];
    self.bookSearchBar.hidden = YES;
    PGBBookViewController *bookPageVC = [[PGBBookViewController alloc] init];
    PGBRealmBook *bookAtIndexPath = self.books[indexPath.row];
    bookPageVC.book = bookAtIndexPath;
    
    [self.navigationController pushViewController:bookPageVC animated:YES];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    PGBBookViewController *bookPageVC = segue.destinationViewController;

    NSIndexPath *selectedIndexPath = self.bookTableView.indexPathForSelectedRow;
    PGBRealmBook *bookAtIndexPath = self.books[selectedIndexPath.row];
    
    bookPageVC.book = bookAtIndexPath;
}

#pragma UISearchBar Method::

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (searchBar == self.bookSearchBar) {
        if (!self.bookSearchBar.text.length) {
            self.defaultContentView.hidden = NO;
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar == self.bookSearchBar) {
        if (self.bookSearchBar.isFirstResponder) {
            self.defaultContentView.hidden = YES;
        }

        NSString *lowercaseAndUnaccentedSearchText = [searchText stringByFoldingWithOptions:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch locale:nil];
        
        [self.searchTimer invalidate];
        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(searchTimerFired:) userInfo:@{ @"searchString": lowercaseAndUnaccentedSearchText } repeats:NO];
        
        if (!searchText.length) {
            self.dismissKeyboardGesture.enabled = YES;
        } else {
            self.dismissKeyboardGesture.enabled = NO;
        }
        
    }
}

- (void)searchTimerFired:(NSTimer *)timer
{
    NSString *searchText = timer.userInfo[@"searchString"];
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"eBookSearchTerms CONTAINS %@", searchText];
    NSArray *coreDataBooks = [self.dataStore.managedBookObjects filteredArrayUsingPredicate:searchFilter];

    [self.books removeAllObjects];

    for (Book *coreDataBook in coreDataBooks) {
        PGBRealmBook *realmBook = [PGBRealmBook createPGBRealmBookWithBook:coreDataBook];

        if (realmBook) {
            [self.books addObject:realmBook];
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bookTableView reloadData];
    });
}

- (void) hideKeyboard
{
    self.defaultContentView.hidden = NO;
    [self.bookSearchBar resignFirstResponder];
}

#pragma UIScroll View Method::
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.bookTableView && self.bookSearchBar.text.length) {
        [self.bookSearchBar resignFirstResponder];
    }
    
}

@end
