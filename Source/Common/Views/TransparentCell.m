#import "TransparentCell.h"

@interface TransparentCell()
@property (nonatomic,strong) TransparentCellContentView * cellView;
@end

@implementation TransparentCell

@synthesize cellView = cellView_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.cellView = [[TransparentCellContentView alloc] initWithFrame:self.bounds];
        self.cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.cellView];
    }
    return self;
}

- (void)setShowNoise:(BOOL)noise;
{
    self.cellView.showNoise = noise;
    [self.cellView setNeedsDisplay];
}

@end
