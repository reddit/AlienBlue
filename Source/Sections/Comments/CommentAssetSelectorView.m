#import "CommentAssetSelectorView.h"
#import "SubredditManager.h"
#import "UIView+Additions.h"
#import "CommentEntryView.h"
#import "Resources.h"

@interface CommentAssetSelectorView()
@property (nonatomic,strong) iCarousel * assetCarousel;
@property (nonatomic,strong) UIButton * insertAssetButton;
@property (nonatomic,strong) NSArray * assets;
@property (nonatomic,strong) NSString * assetFolder;
@end

@interface AssetSelectorOverlay : UIView
@end

@implementation CommentAssetSelectorView

@synthesize assetCarousel = assetCarousel_;
@synthesize insertAssetButton = insertAssetButton_;
@synthesize assets = assets_;
@synthesize assetFolder = assetFolder_;

- (void)dealloc
{
    self.assetCarousel.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame assetFolder:(NSString *)assetFolder;
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        self.layer.cornerRadius = 24.;
        [self setClipsToBounds:YES];

        self.assetFolder = assetFolder;
        self.assets = [[SubredditManager sharedSubredditManager] imageTagsAvailableForSubreddit:assetFolder];
        
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.assetCarousel = [[iCarousel alloc] initWithFrame:self.bounds];
        self.assetCarousel.dataSource = self;
        self.assetCarousel.delegate = self;
        self.assetCarousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.assetCarousel];
        
        AssetSelectorOverlay * assetOverlay = [[AssetSelectorOverlay alloc] initWithFrame:self.bounds];
        assetOverlay.backgroundColor = [UIColor clearColor];
        assetOverlay.userInteractionEnabled = NO;
        assetOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:assetOverlay];
        
        self.insertAssetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.insertAssetButton.frame = CGRectMake(180., 0., 50., 50.);
        [self.insertAssetButton addTarget:self action:@selector(confirmTagSelection) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.insertAssetButton];
    }
    return self;
}

- (float)carouselItemWidth:(iCarousel *)carousel;
{
    return 60.;
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel;
{
    return YES;
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    [self.insertAssetButton centerHorizontallyInSuperView];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel;
{
    return [self.assets count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index;
{
    NSString * tagName = [self.assets objectAtIndex:index];
    UIImage * tagImage = [[SubredditManager sharedSubredditManager] imageForTag:tagName inSubreddit:self.assetFolder];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:tagImage];
    imageView.frame = CGRectMake(0, 0, 36., 36.);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

- (void)confirmTagSelection;
{
    NSString * tag = [self.assets objectAtIndex:[self.assetCarousel currentItemIndex]];
    if ([Resources isIPAD])
    {
        [(CommentEntryView *)[[self superview] superview] didSelectTagFromCarousel:tag];
    }
    else
    {
        [(CommentEntryView *)self.superview.superview.superview.superview didSelectTagFromCarousel:tag];        
    }
}

@end


#pragma Mark -
#pragma Mark - Overlay

@implementation AssetSelectorOverlay

- (void)drawRect:(CGRect)rect;
{
    [self drawInnerShadowInRect:rect fillColor:[UIColor clearColor]];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(rect.size.width / 2 - 8.,0.)];
    [path addLineToPoint:CGPointMake(rect.size.width / 2, 8.)];
    [path addLineToPoint:CGPointMake(rect.size.width / 2 + 8.,0)];
    [path closePath];
    
    [[UIColor blackColor] set];
    [path fill];
}
@end
