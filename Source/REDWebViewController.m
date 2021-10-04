//  REDWebViewController.m
//  RedditApp

#import "RedditApp/REDWebViewController.h"

@interface REDWebView : UIView<UIWebViewDelegate>

@property(nonatomic, strong) UIActivityIndicatorView *spinner;

- (instancetype)initWithURL:(NSURL *)URL;

@end

@implementation REDWebView

- (instancetype)initWithURL:(NSURL *)URL {
  if (self = [super init]) {
    UIWebView *webView = [[UIWebView alloc] init];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:URL]];
    [self addSubview:webView];

    self.spinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.spinner startAnimating];
    [self addSubview:self.spinner];
  }
  return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  [self.spinner sizeToFit];
  self.spinner.center = self.center;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [self.spinner stopAnimating];
  [self.spinner removeFromSuperview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  // TODO(sharkey): Show an error.
}

@end

@interface REDWebViewController ()
@property(nonatomic, strong) NSURL *URL;
@end

@implementation REDWebViewController

- (instancetype)initWithURL:(NSURL *)URL title:(NSString *)title {
  if (self = [super init]) {
    self.URL = URL;
    UIBarButtonItem *closeButton =
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close_small"]
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(_didPressClose)];
    self.navigationItem.leftBarButtonItem = closeButton;
    self.title = title;
    // Force an early load of the webview.
    [self loadView];
  }
  return self;
}

#pragma mark - UIViewController

- (void)loadView {
  self.view = [[REDWebView alloc] initWithURL:self.URL];
}

#pragma mark - private

- (void)_didPressClose {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
