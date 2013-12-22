//
//  NSAttributedString+JSON.m
//  JSONAttributedStringTest
//
//  Created by Khalid on 12/14/13.
//
//

#import "NSMutableAttributedString+JSON.h"
#import <objc/runtime.h>

// category on NSTextAttachment to allow saving of URL
static char ATTACHMENT_URL_KEY;

@interface NSTextAttachment (JSON)
- (NSURL*)url;
- (void)setURL:(NSURL*)url;
@end

@implementation NSTextAttachment (JSON)
- (NSURL *)url
{
    NSURL * attachmentUrl = objc_getAssociatedObject(self, &ATTACHMENT_URL_KEY);
    return attachmentUrl;
}
- (void)setURL:(NSURL *)url
{
    [self willChangeValueForKey:@"url"];
    objc_setAssociatedObject(self, &ATTACHMENT_URL_KEY, url, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"url"];
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
    NSInteger rangeStartLocation = [[[jsonDict objectForKey:@"range"] valueForKey:@"startLocation"]integerValue];
    NSInteger rangeLength = [[[jsonDict objectForKey:@"range"] valueForKey:@"length"] integerValue];
    NSRange range = NSMakeRange(rangeStartLocation, rangeLength);
    
    
    if ([attributeName isEqualToString:@"Font"])
    {
        // Font
        NSString * fontName = [jsonDict valueForKey:@"fontName"];
        CGFloat fontSize = [[jsonDict valueForKey:@"fontSize"] floatValue];
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
        [pstyle setAlignment:[[jsonDict valueForKey:@"alignment"] integerValue]];
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
        NSString * url = [jsonDict valueForKey:@"value"];
        
        [self addAttribute:NSLinkAttributeName value:url range:range];
    }
    else if ([attributeName isEqualToString:@"Shadow"])
    {
        // Shadow
        CGFloat x = [[[jsonDict valueForKey:@"offset"] valueForKey:@"x"] floatValue];
        CGFloat y = [[[jsonDict valueForKey:@"offset"] valueForKey:@"y"] floatValue];
        UIColor * color = [UIColor colorFromHexString:[jsonDict valueForKey:@"color"]];
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
        NSData * imgData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imgData];
     
        NSTextAttachment *attachment = [[NSTextAttachment alloc]init];
        [attachment setURL:url];
        [attachment setImage:image];
        [self insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment] atIndex:range.location];
    }
}


- (NSDictionary*)JSONDictionary
{
    __block NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    __block NSMutableArray * attributes = [NSMutableArray array];
    __block NSInteger i = 0;
    
    NSArray * attributeNames = @[NSParagraphStyleAttributeName,
                                 NSFontAttributeName,
                                 NSForegroundColorAttributeName,
                                 NSBackgroundColorAttributeName,
                                 NSLigatureAttributeName,
                                 NSLinkAttributeName,
                                 NSStrokeColorAttributeName,
                                 NSStrokeWidthAttributeName,
                                 NSShadowAttributeName,
                                 NSAttachmentAttributeName];
    
    
    [dict setValue:self.string forKey:@"text"];
    
    for (NSString* attributeName in attributeNames) {
       
        NSLog(@"Attribute: %@\n",attributeName);
        [self enumerateAttribute:attributeName inRange:NSMakeRange(0, self.string.length)  options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
            //
            
            if (value) {
                if ([attributeName isEqualToString:NSParagraphStyleAttributeName]) {
                    // paragraph style
                    [self addParagraphStyleAttribute:value toAttributes:&attributes withRange:range];
                }
                if ([attributeName isEqualToString:NSFontAttributeName]) {
                    // font
                    [self addFontAttributeName:value toAttributes:&attributes withRange:range];
                }
                if ([attributeName isEqualToString:NSForegroundColorAttributeName]) {
                    // foreground color
                    [self addForegroundColorAttributeName:value toAttributes:&attributes withRange:range];
                }
                if ([attributeName isEqualToString:NSBackgroundColorAttributeName]) {
                    // background color
                    [self addBackgroundColorAttributeName:value toAttributes:&attributes withRange:range];
                }
                if ([attributeName isEqualToString:NSLigatureAttributeName]) {
                    // ligature
                    [self addLigatureAttributeName:value toAttributes:&attributes withRange:range];
                }
                if ([attributeName isEqualToString:NSLinkAttributeName]) {
                    // link
                    [self addLinkAttributeName:value toAttributes:&attributes withRange:range];
                }
                
                if ([attributeName isEqualToString:NSStrokeColorAttributeName]) {
                    // stroke color
                    [self addStrokeColorAttributeName:value toAttributes:&attributes withRange:range];
                }
                
                if ([attributeName isEqualToString:NSStrokeWidthAttributeName]) {
                    // stroke width
                    [self addStrokeWidthAttributeName:value toAttributes:&attributes withRange:range];
                }
                
                if ([attributeName isEqualToString:NSShadowAttributeName]) {
                    // shadow
                    [self addShadowAttributeName:value toAttributes:&attributes withRange:range];
                }
                
                if ([attributeName isEqualToString:NSAttachmentAttributeName]) {
                    // attachment
                    [self addAttachmentAttributeName:value toAttributes:&attributes withRange:range];
                }
                
                i++;
            }
        }];
    }
    NSLog(@"total: %d",i);
    [dict setValue:attributes forKey:@"attributes"];
    return dict.mutableCopy;
}


- (void)addFontAttributeName:(id)attrib toAttributes:(NSMutableArray**)attributes withRange:(NSRange)range
{
    NSString *name = NSStringFromClass([attrib class]);
    if([name isEqualToString:@"UICTFont"])
    {
        UIFontDescriptor * desc = [attrib fontDescriptor];
       
        [*attributes addObject:@{
                                 @"name":@"Font",
                                 @"fontName" : [desc.fontAttributes valueForKey:@"NSFontNameAttribute"],
                                 @"fontSize" : [desc.fontAttributes valueForKey:@"NSFontSizeAttribute"],
                                 @"range": @{ @"startLocation":@(range.location), @"length":@(range.length)}
                                 }];
    }
}


- (void)addForegroundColorAttributeName:(id)attrib toAttributes:(NSMutableArray**)attributes withRange:(NSRange)range
{
    
    UIColor * color = (UIColor*)attrib;
    [*attributes addObject:@{
                             @"name":@"ForegroundColor",
                             @"value":[color hexString],
                             @"range": @{ @"startLocation":@(range.location), @"length":@(range.length)}
                             }];
}


- (void)addBackgroundColorAttributeName:(id)attrib toAttributes:(NSMutableArray**)attributes withRange:(NSRange)range
{
    UIColor * color = (UIColor*)attrib;
    [*attributes addObject:@{
                             @"name":@"BackgroundColor",
                             @"value":[color hexString],
                             @"range": @{ @"startLocation":@(range.location), @"length":@(range.length)}
                             }];
}


- (void)addLigatureAttributeName:(id)attrib toAttributes:(NSMutableArray**)attributes withRange:(NSRange)range
{
    
    [*attributes addObject:@{
                             @"name":@"Ligature",
                             @"value":attrib,
                             @"range": @{ @"startLocation":@(range.location), @"length":@(range.length)}
                             }];
}


- (void)addLinkAttributeName:(id)attrib toAttributes:(NSMutableArray**)attributes withRange:(NSRange)range
{
    
    [*attributes addObject:@{
                             @"name":@"Link",
                             @"value":attrib,
                             @"range": @{ @"startLocation":@(range.location), @"length":@(range.length)}
                             }];
}


- (void)addStrokeColorAttributeName:(id)attrib toAttributes:(NSMutableArray**)attributes withRange:(NSRange)range
{
    UIColor * color = (UIColor*)attrib;
    [*attributes addObject:@{
                             @"name":@"StrokeColor",
                             @"value":[color hexString],
                             @"range": @{ @"startLocation":@(range.location), @"length":@(range.length)}
                             }];
}


- (void)addStrokeWidthAttributeName:(id)attrib toAttributes:(NSMutableArray**)attributes withRange:(NSRange)range
{
    
    [*attributes addObject:@{
                             @"name":@"StrokeWidth",
                             @"value":attrib,
                             @"range": @{ @"startLocation":@(range.location), @"length":@(range.length)}
                             }];
}


- (void)addShadowAttributeName:(NSShadow*)attrib toAttributes:(NSMutableArray**)attributes withRange:(NSRange)range
{
    
    [*attributes addObject:@{
                             @"name":@"Shadow",
                             @"offset":@{@"x": @(attrib.shadowOffset.width),
                                         @"y": @(attrib.shadowOffset.height)
                                         },
                             @"color": [attrib.shadowColor hexString],
                             @"shadowBlurRadius": @(attrib.shadowBlurRadius),
                             
                             
                             @"range": @{ @"startLocation":@(range.location), @"length":@(range.length)}
                             }];
}


- (void)addAttachmentAttributeName:(NSTextAttachment*)attrib toAttributes:(NSMutableArray**)attributes withRange:(NSRange)range
{
    NSLog(@"url: %@",attrib.url);
    
    [*attributes addObject:@{
                             @"name":@"Attachment",
                             @"value":[attrib.url description],
                             @"range": @{ @"startLocation":@(range.location), @"length":@(range.length)}
                             }];
}


- (void)addParagraphStyleAttribute:(NSMutableParagraphStyle*)attrib toAttributes:(NSMutableArray**)attributes withRange:(NSRange)range
{
   
    
    [*attributes addObject:@{
                             @"name":@"ParagraphStyle",
                             @"alignment": @(attrib.alignment),
                             @"firstLineHeadIndent": @(attrib.firstLineHeadIndent),
                             @"headIndent": @(attrib.headIndent),
                             @"lineHeightMultiple": @(attrib.lineHeightMultiple),
                             @"maximumLineHeight": @(attrib.maximumLineHeight),
                             @"minimumLineHeight": @(attrib.minimumLineHeight),
                             @"tailIndent": @(attrib.tailIndent),
                             @"paragraphSpacing": @(attrib.paragraphSpacing),
                             @"paragraphSpacingBefore": @(attrib.paragraphSpacingBefore),
                             @"range": @{ @"startLocation":@(range.location), @"length":@(range.length)}
                             }];
}

@end



// Category on UIColor add hex string capabilities
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



- (NSString*)hexString
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    CGFloat red, green, blue;
    red = roundf(components[0] * 255.0);
    green = roundf(components[1] * 255.0);
    blue = roundf(components[2] * 255.0);
    
    return [[NSString alloc]initWithFormat:@"0x%02x%02x%02x", (int)red, (int)green, (int)blue];
}


@end