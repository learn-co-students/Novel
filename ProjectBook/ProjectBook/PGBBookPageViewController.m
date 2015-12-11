//
//  PGBBookPageViewController.m
//  ProjectBook
//
//  Created by Olivia Lim on 11/17/15.
//  Copyright © 2015 FIS. All rights reserved.
//

#import "PGBBookPageViewController.h"
#import "PGBDownloadHelper.h"
#import "PGBParseAPIClient.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>


@interface PGBBookPageViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) PGBDownloadHelper *downloadHelper;
@property UIDocumentInteractionController *docController;

@property (strong, nonatomic) NSMutableString *htmlString;

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *iBooksButton;

@property (weak, nonatomic) IBOutlet UITextView *bookDescriptionTV;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *genreLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UIView *linkView;
@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@property (weak, nonatomic) IBOutlet UIView *superContentView;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *optionsButton;
@property (weak, nonatomic) IBOutlet UIImageView *bookCoverImageView;

//@property (weak, nonatomic) IBOutlet UIView *webview;

@end

@implementation PGBBookPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.bookDescriptionTV.editable = NO;

    self.bookDescriptionTV.text = @"";
    PGBGoodreadsAPIClient *goodreadsAPI = [[PGBGoodreadsAPIClient alloc] init];
    [goodreadsAPI getDescriptionForBookTitle:self.book completion:^(NSString *bookDescription) {

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if ([bookDescription isEqual:@""]) {
                    self.bookDescriptionTV.text = @"There is no description for this book.";
                }else{
                    self.bookDescriptionTV.text = bookDescription;
                }
            }];
    }];


    self.titleLabel.text = self.book.title;
    self.authorLabel.text = self.book.author;
    self.genreLabel.text = self.book.genre;
    self.languageLabel.text = self.book.language;

    // if (self.book.bookCoverData) {
    //     self.bookCoverImageView.image = [UIImage imageWithData:self.book.bookCoverData];
    // }
    
    CGRect rect = self.bookDescriptionTV.frame;
    rect.size.height = self.bookDescriptionTV.contentSize.height;
    self.bookDescriptionTV.frame = rect;
    
    CGFloat totalHeight = 0.0f;
    for (UIView *view in self.superContentView.subviews)
        if (totalHeight < view.frame.origin.y + view.frame.size.height) totalHeight = view.frame.origin.y + view.frame.size.height;
    
    
//        [self getReviewswithCompletion:^(BOOL success) {
//            success = YES;
//        }];
    
    //bookmarkstuff
    UIImage *unbookmarkImg = [UIImage imageNamed:@"emptyriboon.png"];
    UIImage *bookmarkImg = [UIImage imageNamed:@"redriboon.png"];
    [self.bookmarkButton setImage:bookmarkImg forState:UIControlStateNormal];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //LEO - this is causing crash when back from book detail
    [self getReviewswithCompletion:^(BOOL success) {
        if (success) {
            NSLog(@"Succed to get description from API call - LEO");
        } else {
            NSLog(@"failed to get description from API call - LEO");
            self.bookDescriptionTV.text = @"There is no description for this book.";
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (![ PFUser currentUser]) {
        // do something
    }
    else{
        // we have a user! do somethin..
    }
    //    NSArray *permissions = @[@"public_profile"];
    //
    //    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
    //
    //        if (!user) {
    //            NSLog(@"Uh oh. The user cancelled the Facebook login.");
    //        } else if (user.isNew) {
    //            NSLog(@"User signed up and logged in through Facebook!");
    //        } else {
    //            NSLog(@"User logged in through Facebook!");
    //        }
    //    }];
    
    //get book cover image in background
    NSString *ebookID = self.book.ebookID;
    
    NSOperationQueue *bgQueue = [[NSOperationQueue alloc]init];
    [bgQueue addOperationWithBlock:^{
        
        [self.bookCoverImageView yy_setImageWithURL:[PGBRealmBook createBookCoverURL:ebookID] placeholder:[UIImage imageNamed:@"no_book_cover"] options:YYWebImageOptionProgressive completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
            
            if (image) {
                self.bookCoverImageView.image = image;
            }
            
        }];
    }];
}


-(void)getReviewswithCompletion:(void (^)(BOOL))completionBlock
{
    [PGBGoodreadsAPIClient getReviewsForBook:self.book completion:^(NSDictionary *reviewDict) {
        
        if (reviewDict) {
        
            self.htmlString = [reviewDict[@"reviews_widget"] mutableCopy];
            
            NSData *htmlData = [self.htmlString dataUsingEncoding:NSUTF8StringEncoding];
            
            NSURL *baseURL = [NSURL URLWithString:@"https://www.goodreads.com"];
            
            // make / constrain webview
            
            CGRect webViewFrame = CGRectMake(0, 0, self.webViewContainer.frame.size.width, self.webViewContainer.frame.size.height);
            
            self.webView = [[WKWebView alloc]initWithFrame: webViewFrame];
            [self.webViewContainer addSubview:self.webView];
            //                self.webView.translatesAutoresizingMaskIntoConstraints = NO;
            //
            //                [self.webView.leftAnchor constraintEqualToAnchor:self.webViewContainer.leftAnchor].active = YES;
            //                [self.webView.rightAnchor constraintEqualToAnchor:self.webViewContainer.rightAnchor].active = YES;
            //                [self.webView.topAnchor constraintEqualToAnchor:self.webViewContainer.bottomAnchor].active = YES;
            //                [self.webView.bottomAnchor constraintEqualToAnchor:self.webViewContainer.bottomAnchor].active = YES;
            
            
            [self.webView loadData:htmlData MIMEType:@"text/html" characterEncodingName:@"utf-8" baseURL:baseURL];
            

            self.webView.navigationDelegate = self;
            
            //            [self.webView.heightAnchor constraintEqualToConstant:300];
            //            [self.webViewContainer layoutSubviews];
            completionBlock(YES);
        } else {
            completionBlock(NO);
        }
    }];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    NSLog(@"didFinishNavigation");
    
    [webView.scrollView setZoomScale:0.6];
    [webView.scrollView setContentOffset:CGPointMake(0, 0)];
    
    //    [webView.scrollView zoomToRect:CGRectMake(0, 0, 20, 20) animated:YES];
}



-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
//    NSLog (@"didCommitNavigation");
    
    [webView.scrollView setZoomScale:0.6];
    [webView.scrollView setContentOffset:CGPointMake(0, 0)];
}

- (IBAction)downloadButtonTapped:(id)sender
{
    NSString *parsedEbookID = [self.book.ebookID substringFromIndex:5];
    
    NSString *idURL = [NSString stringWithFormat:@"http://www.gutenberg.org/ebooks/%@.epub.images", parsedEbookID];
    
    NSURL *URL = [NSURL URLWithString:idURL];
    self.downloadHelper = [[PGBDownloadHelper alloc] init];
    [self.downloadHelper download:URL];
    
    //    do {
    //        //modal view
    //    }
    
    //during download
    UIAlertController *downloadComplete = [UIAlertController alertControllerWithTitle:@"Book Downloaded" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                               }];
    
    [downloadComplete addAction:ok];
    [self presentViewController:downloadComplete animated:YES completion:nil];
    
    self.downloadButton.enabled = NO;
    
    if (self.book.ebookID.length) {
        
        [PGBRealmBook storeUserBookDataWithBookwithUpdateBlock:^PGBRealmBook *{
            self.book.isDownloaded = YES;
            return self.book;
        } andCompletion:^{
//            if ([PFUser currentUser]) {
//                [PGBRealmBook storeUserBookDataFromRealmStoreToParseWithRealmBook:self.book andCompletion:^{
//                    NSLog(@"saved book to parse");
//                }];
//            }
        }];
        
    }
}

- (IBAction)optionsButtonTapped:(id)sender {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *download = [UIAlertAction actionWithTitle:@"Download Book" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self downloadButtonTapped:sender];
        //        [view dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Bookmark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //bookmarks it
        [self bookmarkButtonTapped:sender];
        //        [view dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [view addAction:download];
    [view addAction:save];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)readButtonTapped:(id)sender
{
    NSString *parsedEbookID = [self.book.ebookID substringFromIndex:5];
    
    NSString *litFileName = [NSString stringWithFormat:@"pg%@-images.epub", parsedEbookID];
    
    //    NSString *litFileName = [NSString stringWithFormat:@"pg%@", self.ebookIndex];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:litFileName];
    NSURL *targetURL = [NSURL fileURLWithPath:filePath];
    
    self.docController = [UIDocumentInteractionController interactionControllerWithURL:targetURL];
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"itms-books:"]]) {
        
        [self.docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        
        //        [self.docController presentOpenInMenuFromRect:_openInIBooksButton.bounds inView:self.openInIBooksButton animated:YES];
        
        NSLog(@"iBooks installed");
        
    } else {
        UIAlertController *invalid = [UIAlertController alertControllerWithTitle:@"You don't have iBooks installed." message:@" Download iBooks and try again"preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                   }];
        [invalid addAction:ok];
        [self presentViewController:invalid animated:YES completion:nil];
        
    }
    
    NSLog(@"iBooks not installed");
}


- (IBAction)bookmarkButtonTapped:(id)sender {
    NSLog(@"bookmark button tapped!");
    
    //    UIImage *unbookmarkImg = [UIImage imageNamed:@"emptyriboon.png"];
    //    UIImage *bookmarkImg = [UIImage imageNamed:@"redriboon.png"];
    //    [self.bookmarkButton setImage:bookmarkImg forState:UIControlStateNormal];
    
    if (self.book.ebookID.length) {
        
        [PGBRealmBook storeUserBookDataWithBookwithUpdateBlock:^PGBRealmBook *{
            self.book.isBookmarked = YES;
            return self.book;
        } andCompletion:^{
//            if ([PFUser currentUser]) {
//                [PGBRealmBook storeUserBookDataFromRealmStoreToParseWithRealmBook:self.book andCompletion:^{
//                    NSLog(@"saved book to parse");
//                }];
//            }
            
        }];
        
    }
}


- (void)dealloc {

    self.webView.navigationDelegate = nil;

    [self.webView stopLoading];
}

@end
