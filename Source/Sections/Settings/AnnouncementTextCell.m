#import "AnnouncementTextCell.h"
#import "MarkupEngine.h"

@interface AnnouncementTextNode()
@property (strong) NSString *html;
@end

@implementation AnnouncementTextNode

- (id)initWithHTML:(NSString *)html;
{
  JM_SUPER_INIT(init);
  self.html = html;
  return self;
}

+ (Class)cellClass;
{
  return UNIVERSAL(AnnouncementTextCell);
}

- (NSAttributedString *)styledText;
{
  NSMutableAttributedString *styledText = [MarkupEngine markDownHTML:self.html forSubreddit:nil];
  return styledText;
}

- (CGFloat)heightForBodyConstrainedToWidth:(CGFloat)width;
{
  return [self.styledText heightConstrainedToWidth:width];
}

@end

@implementation AnnouncementTextCell

+ (CGFloat)heightForCellFooterForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
  return 0.;
}

- (void)attachOptionsDrawerIfNecessary;
{
}

+ (CGSize)commentTextPadding;
{
  if (JMIsIpad())
    return CGSizeMake(23. ,  10.);
  else
    return [NBaseStyledTextCell commentTextPadding];
}


@end
