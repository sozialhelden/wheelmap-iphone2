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
        self.textAlignment = UITextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
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


@end
