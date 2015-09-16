//
//  WMLabel.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMLabel.h"
#define FONT_FAMILY_NAME @"HelveticaNeue"

@implementation WMLabel
@synthesize fontSize = _fontSize;
@synthesize fontType = _fontType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.font = [UIFont fontWithName:FONT_FAMILY_NAME size:15.0];   // default font is HelveticaNeue Regular with font size 15pt.
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (id)initWithFrameByNodeType:(CGRect)frame nodeType:(enum WMNodeListViewControllerUseCase*)nodeType
{
    self = [super initWithFrame:frame];
    if (self) {
        if ((WMNodeListViewControllerUseCase)nodeType == kWMNodeListViewControllerUseCaseContribute) {
            self.fontSize = 13.0;
            self.textAlignment = NSTextAlignmentLeft;
            self.numberOfLines = 3;
            self.lineBreakMode = NSLineBreakByTruncatingTail;
            self.textColor = [UIColor whiteColor];
            self.text = NSLocalizedString(@"HelpByMarking", nil);
        }
    }
    return self;
}



#pragma mark -
#pragma mark Font Size and Types
-(void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    self.font = [UIFont fontWithName:self.font.fontName size:fontSize];
}

-(CGFloat)fontSize
{
    return _fontSize;
}

-(void)setFontType:(WMLabelFontType)fontType
{
    _fontType = fontType;
    NSString* fontName;
    switch (fontType) {
        case kWMLabelFontTypeRegular:
            fontName = FONT_FAMILY_NAME;
            break;
        case kWMLabelFontTypeItalic:
            fontName = [NSString stringWithFormat:@"%@-Italic", FONT_FAMILY_NAME];
            break;
        case kWMLabelFontTypeBold:
            fontName = [NSString stringWithFormat:@"%@-Bold", FONT_FAMILY_NAME];
            break;
        default:
            fontName = FONT_FAMILY_NAME;
            break;
    }
    
    self.font = [UIFont fontWithName:fontName size:self.fontSize];
}

-(WMLabelFontType)fontType
{
    return _fontType;
}

- (void)adjustHeightToContent {
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,9999);
    
    CGSize expectedLabelSize = [self.text boundingRectWithSize:maximumLabelSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:self.font}
                                                       context:nil].size;

    
    //adjust the label the the new height.
    CGRect newFrame = self.frame;
    newFrame.size.height = expectedLabelSize.height;
    self.frame = newFrame;
}


@end
