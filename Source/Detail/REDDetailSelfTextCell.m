//  REDDetailSelfTextCell.m
//  RedditApp

#import "REDDetailSelfTextCell.h"

#import <BPDisplaySettings.h>
#import <BPMarkdownView.h>

#import "RedditApp/Util/REDColor.h"
#import "RedditApp/REDWebViewController.h"

static int const kMarginX = 15;

@interface REDDetailSelfTextCell ()<BPMarkdownViewLinkDelegate>

// A weak reference, downcasted from self.node, is kept for convenience.
@property(nonatomic, weak) REDDetailSelfTextNode *detailSelfTextNode;
@property(nonatomic, strong) BPMarkdownView *markdownView;

@end

@implementation REDDetailSelfTextCell

- (void)updateWithNode:(JMOutlineNode *)node {
  NSAssert([node isKindOfClass:[REDDetailSelfTextNode class]], @"Wrong node type.");
  self.detailSelfTextNode = (REDDetailSelfTextNode *)node;

  [self.markdownView removeFromSuperview];
  self.markdownView = [REDDetailSelfTextCell markdownViewWithWidth:self.bounds.size.width];
  self.markdownView.markdown =
      [REDDetailSelfTextCell addMarkdownForLinks:self.detailSelfTextNode.markdown];
  self.markdownView.linkDelegate = self;
  [self.contentView addSubview:self.markdownView];
  [self setCellBackgroundColor:[REDColor whiteColor]];
}

#pragma mark - sizing and layout

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView {
  NSAssert([node isKindOfClass:[REDDetailSelfTextNode class]], @"Wrong node type.");
  REDDetailSelfTextNode *detailSelfTextNode = (REDDetailSelfTextNode *)node;

  BPMarkdownView *markdownView =
      [REDDetailSelfTextCell markdownViewWithWidth:tableView.bounds.size.width];
  markdownView.markdown = [REDDetailSelfTextCell addMarkdownForLinks:detailSelfTextNode.markdown];
  return markdownView.contentSize.height + markdownView.contentInset.top +
         markdownView.contentInset.bottom;
}

- (void)layoutCellOverlays {
  self.markdownView.frame = self.bounds;
}

#pragma mark - BPMarkdownViewLinkDelegate

- (void)markdownView:(BPMarkdownView *)markdownView didHaveLinkTapped:(NSString *)link {
  if (link.length == 0) {
    return;
  }
  REDWebViewController *webViewController =
      [[REDWebViewController alloc] initWithURL:[NSURL URLWithString:link] title:link];
  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:webViewController];
  [self.detailSelfTextNode.viewController presentViewController:navigationController
                                                       animated:YES
                                                     completion:nil];
}

#pragma mark - private

+ (BPMarkdownView *)markdownViewWithWidth:(CGFloat)width {
  BPMarkdownView *markdownView =
      [[BPMarkdownView alloc] initWithFrame:CGRectMake(0, 0, width, FLT_MAX)];
  markdownView.scrollEnabled = NO;
  markdownView.backgroundColor = [UIColor clearColor];
  markdownView.contentInset = UIEdgeInsetsMake(0, kMarginX, 0, kMarginX);

  BPDisplaySettings *settings = [[BPDisplaySettings alloc] init];
  settings.linkColor = [REDColor blueColor];
  settings.defaultFont = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
  markdownView.displaySettings = settings;

  return markdownView;
}

// Use NSDataDetector to find links, then add markdown around them.
// TODO(sharkey): This could be used by other classes. If that happens, find it a happy home.
+ (NSString *)addMarkdownForLinks:(NSString *)markdown {
  // First find all of the links that are already in markdown format. We won't touch those.
  NSString *markdownLinkRegex = @"\\[.*\\]\\s*\\(.*\\)";
  NSRegularExpression *regex =
      [NSRegularExpression regularExpressionWithPattern:markdownLinkRegex options:0 error:nil];
  NSArray *markdownLinkRanges =
      [regex matchesInString:markdown options:0 range:NSMakeRange(0, markdown.length)];

  // Use an NSDataDetector to find links in the text, like www.google.com.
  NSError *error = nil;
  NSDataDetector *detector =
      [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
  if (error) {
    NSAssert(false, [error description]);
  }
  NSArray *matches =
      [detector matchesInString:markdown options:0 range:NSMakeRange(0, markdown.length)];

  // Reconstruct the string, marking up links that aren't already in Markdown.
  NSUInteger stringIndex = 0;
  NSMutableString *result = [NSMutableString string];
  for (NSTextCheckingResult *match in matches) {
    NSAssert(match.resultType == NSTextCheckingTypeLink, @"Match type should only be a link.");
    NSRange matchRange = match.range;

    // See if this link is already in Markdown. Consider changing this to a binary search if we
    // see performance issues.
    BOOL linkInMarkdown = NO;
    for (NSTextCheckingResult *markdownLinkRange in markdownLinkRanges) {
      if (NSIntersectionRange(markdownLinkRange.range, matchRange).length > 0) {
        linkInMarkdown = YES;
        break;
      }
    }

    if (!linkInMarkdown) {
      NSString *nonLinkText =
          [markdown substringWithRange:NSMakeRange(stringIndex, matchRange.location - stringIndex)];
      NSString *linkText = [markdown substringWithRange:matchRange];
      [result appendString:nonLinkText];
      [result appendFormat:@"[%@](%@)", linkText, [match.URL absoluteString]];
    } else {
      NSRange sectionRange =
          NSMakeRange(stringIndex, matchRange.location + matchRange.length - stringIndex);
      [result appendString:[markdown substringWithRange:sectionRange]];
    }

    stringIndex = matchRange.location + matchRange.length;
  }

  NSString *nonLinkText = [markdown substringFromIndex:stringIndex];
  [result appendString:nonLinkText];

  return result;
}

@end

@implementation REDDetailSelfTextNode

- (instancetype)initWithMarkdown:(NSString *)markdown
                  viewController:(__weak UIViewController *)viewController {
  self = [super init];
  if (self) {
    self.markdown = markdown;
    self.viewController = viewController;
  }
  return self;
}

+ (Class)cellClass {
  return [REDDetailSelfTextCell class];
}

@end
