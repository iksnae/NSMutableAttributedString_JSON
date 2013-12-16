//
//  NSAttributedString+JSON.m
//  JSONAttributedStringTest
//
//  Created by Khalid on 12/14/13.
//
//

#import "NSMutableAttributedString+JSON.h"


@interface UIColor (HexString)
+ (UIColor *) colorFromHexString:(NSString *)hexString;
@end

@implementation UIColor (HexString)

+ (UIColor *) colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    hexString = [hexString stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end

@implementation NSMutableAttributedString (JSON)



- (id)initWithJSONDictionary:(NSDictionary *)jsonDict
{
    NSString * text = [jsonDict valueForKey:@"text"];
    NSArray * attributes = [jsonDict valueForKey:@"attributes"];
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc]initWithString:text];
    for (NSDictionary * attrDict in attributes) {
        [attStr addAttributeWithJSONDictionary:attrDict];
    }
    return attStr;
}


- (void)addAttributeWithJSONDictionary:(NSDictionary *)jsonDict
{
    NSString * attributeName = [jsonDict valueForKey:@"name"];
    NSInteger rangeStartIndex = [[[jsonDict valueForKey:@"range"] valueForKey:@"startIndex"]integerValue];
    NSInteger rangeLength = [[[jsonDict valueForKey:@"range"] valueForKey:@"length"] integerValue];
    NSRange range = NSMakeRange(rangeStartIndex, rangeLength);
    
    
    if ([attributeName isEqualToString:@"Font"])
    {
        // Font
        NSString * fontName = [jsonDict valueForKey:@"value"];
        CGFloat fontSize = [[jsonDict valueForKey:@"size"] floatValue];
        [self addAttribute:NSFontAttributeName value:[UIFont fontWithName:fontName size:fontSize] range:range];
    }
    else if ([attributeName isEqualToString:@"ForegroundColor"])
    {
        // Foreground Color
        UIColor * color = [UIColor colorFromHexString:[jsonDict valueForKey:@"value"]];
        [self addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
    else if ([attributeName isEqualToString:@"BackgroundColor"])
    {
        // Background Color
        UIColor * color = [UIColor colorFromHexString:[jsonDict valueForKey:@"value"]];
        [self addAttribute:NSBackgroundColorAttributeName value:color range:range];
    }
    else if ([attributeName isEqualToString:@"ParagraphStyle"])
    {
        // ParagraphStyle
        NSMutableParagraphStyle * pstyle = [[NSMutableParagraphStyle alloc]init];
        [pstyle setAlignment:[self alignmentForString:[jsonDict valueForKey:@"alignment"]]];
        [pstyle setFirstLineHeadIndent:[[jsonDict valueForKey:@"firstLineHeadIndent"] floatValue]];
        [pstyle setHeadIndent:[[jsonDict valueForKey:@"headIndent"] floatValue]];
        [pstyle setLineHeightMultiple:[[jsonDict valueForKey:@"lineHeightMultiple"] floatValue]];
        [pstyle setMaximumLineHeight:[[jsonDict valueForKey:@"maximumLineHeight"] floatValue]];
        [pstyle setMinimumLineHeight:[[jsonDict valueForKey:@"minimumLineHeight"] floatValue]];
        [pstyle setTailIndent:[[jsonDict valueForKey:@"tailIndent"] floatValue]];
        [pstyle setParagraphSpacing:[[jsonDict valueForKey:@"paragraphSpacing"] floatValue]];
        [pstyle setParagraphSpacingBefore:[[jsonDict valueForKey:@"paragraphSpacingBefore"] floatValue]];
        [self addAttribute:NSParagraphStyleAttributeName value:pstyle range:range];
        
    }
    else if ([attributeName isEqualToString:@"Link"])
    {
        // Link
        [self addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[jsonDict valueForKey:@"value"]] range:range];
    }
    else if ([attributeName isEqualToString:@"Shadow"])
    {
        // Shadow
        
        CGFloat x = [[[jsonDict valueForKey:@"offset"] valueForKey:@"x"] floatValue];
        CGFloat y = [[[jsonDict valueForKey:@"offset"] valueForKey:@"y"] floatValue];
        UIColor * color = [UIColor colorFromHexString:[[jsonDict valueForKey:@"range"] valueForKey:@"color"]];
        NSShadow * shadow = [[NSShadow alloc]init];
        [shadow setShadowBlurRadius:2];
        [shadow setShadowOffset:CGSizeMake(x, y)];
        [shadow setShadowColor:color];
        [self addAttribute:NSShadowAttributeName value:shadow range:range];
    }
    else if ([attributeName isEqualToString:@"StrokeColor"])
    {
        // Stroke Color
        [self addAttribute:NSStrokeColorAttributeName value:[UIColor colorFromHexString:[jsonDict valueForKey:@"value"]] range:range];
    }
    else if ([attributeName isEqualToString:@"StrokeWidth"])
    {
        // Stroke Width
        [self addAttribute:NSStrokeWidthAttributeName value:[jsonDict valueForKey:@"value"] range:range];
    }
    else if ([attributeName isEqualToString:@"Ligature"])
    {
        // Ligature
        [self addAttribute:NSLigatureAttributeName value:[jsonDict valueForKey:@"value"] range:range];
    }
    else if ([attributeName isEqualToString:@"Attachment"])
    {
        // Attachment
        NSURL * url =[NSURL URLWithString:[jsonDict valueForKey:@"value"]];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        NSTextAttachment *attachment = [[NSTextAttachment alloc]init];
        [attachment setImage:image];
        [self insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment] atIndex:range.location];
    }
    
    
}


- (NSTextAlignment)alignmentForString:(NSString*)alignmentString
{
    if ([alignmentString isEqualToString:@"Left"]) {
        return NSTextAlignmentLeft;
    }
    else if([alignmentString isEqualToString:@"Right"])
    {
        return NSTextAlignmentRight;
    }
    else if([alignmentString isEqualToString:@"Center"])
    {
        return NSTextAlignmentCenter;
    }
    else if([alignmentString isEqualToString:@"Justified"])
    {
        return NSTextAlignmentJustified;
    }
    else if([alignmentString isEqualToString:@"Natural"])
    {
        return NSTextAlignmentNatural;
    }
    else{
        return NSTextAlignmentLeft;
    }
    
}

@end
