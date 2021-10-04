#import "EULAViewController.h"
#import "GTMNSString+HTML.h"
#import "JMArticleContentOptimizer.h"

@interface EULAViewController () <UIWebViewDelegate>
@property (strong) UIWebView *webView;
@end

@implementation EULAViewController

- (id)init;
{
  self = [super initWithNibName:nil bundle:nil];
  if (self)
  {
    [self setNavbarTitle:@"End User License Agreement"];
    [self updateToolbarAnimated:NO];
  }
  return self;
}

- (void)updateToolbarAnimated:(BOOL)animated;
{
  UIBarButtonItem *backItem = [UIBarButtonItem skinBarItemWithIcon:@"back-arrow-icon" target:self action:@selector(browserBack)];
  UIBarButtonItem *forwardItem = [UIBarButtonItem skinBarItemWithIcon:@"forward-arrow-icon" target:self action:@selector(browserForward)];

  backItem.enabled = self.webView.canGoBack;
  forwardItem.enabled = self.webView.canGoForward;
  
  UIBarButtonItem * fixedWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  [fixedWidth setWidth:27.0];
  UIBarButtonItem * flexibleWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  
  UIBarButtonItem *agreeButton = [UIBarButtonItem skinBarItemWithTitle:@"I Agree" textColor:JMHexColor(ffffff) fillColor:JMHexColor(6d9f60) positionOffset:CGSizeZero target:self action:@selector(didTapAgree)];
  
  NSMutableArray *items = [NSMutableArray array];
  [items addObject:backItem];
  [items addObject:fixedWidth];
  [items addObject:forwardItem];
  [items addObject:flexibleWidth];
  [items addObject:agreeButton];
  
  [self setToolbarItems:items animated:animated];
}

- (void)loadView;
{
  [super loadView];
  self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
  self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.webView.delegate = self;
  self.view.backgroundColor = [UIColor colorForBackground];
  self.webView.backgroundColor = [UIColor colorForBackground];
  self.webView.scalesPageToFit = YES;
  [self.view addSubview:self.webView];
  
  UIView *statusMaskingView = [[UIView alloc] initWithFrame:CGRectCropToTop(self.view.bounds, 21.)];
  statusMaskingView.backgroundColor = [UIColor colorForBackground];
  statusMaskingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:statusMaskingView];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [[NavigationManager shared] interactionIconsNeedUpdate];
	[self.webView stopLoading];
  self.webView.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
//  NSURL *eulaURL = [[NSBundle mainBundle] URLForResource:@"eula" withExtension:@"html"];
  NSURL *eulaURL = [@"http://alienblue-static.s3.amazonaws.com/reddit/eula.html" URL];
  [self.webView loadRequest:[NSURLRequest requestWithURL:eulaURL]];
}

//- (void)prepareWebviewWithEULAContent;
//{
//  BSELF(EULAViewController);
//  NSURLRequest *request = [NSURLRequest requestWithURL:[@"http://www.reddit.com/wiki/useragreement.json" URL]];
//  AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//    
//    NSString *htmlEscaped = [JSON valueForKeyPath:@"data.content_html"];
//    NSString *html = [htmlEscaped gtm_stringByUnescapingFromHTML];
//    NSString *formattedHTML = JMOptimalFormattedHTMLWithContent(html, @"", self.view.bounds.size.width);
//    formattedHTML = [formattedHTML jm_replace:@"overflow: hidden" withString:@"overflow: scroll"];
//    [blockSelf.webView loadHTMLString:formattedHTML baseURL:@"http://www.reddit.com".URL];
//    
//    DLog(@"%@", html);
//  } failure:nil];
//  [op start];
//}

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
  [self updateToolbarAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
  [self updateToolbarAnimated:YES];
}

- (void)browserBack;
{
  [self.webView goBack];
}

- (void)browserForward;
{
  [self.webView goForward];
}

- (void)didTapAgree;
{
  [self.navigationController.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
  return [[NavigationManager shared] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

@end
