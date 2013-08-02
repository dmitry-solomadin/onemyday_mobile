#import "UICustomImageView.h"

@implementation UICustomImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self checkFor568];
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self checkFor568];
}

-(void)checkFor568 {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if(screenSize.height == 568) {
            if (self.filename568 != nil)
                self.image = [UIImage imageNamed:self.filename568];
        }
    }
}

@end