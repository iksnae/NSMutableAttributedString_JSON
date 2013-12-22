//
//  NSAttributedString+JSON.h
//  JSONAttributedStringTest
//
//  Created by Khalid on 12/14/13.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (JSON)
- (id)initWithJSONDictionary:(NSDictionary *)jsonDict;
- (NSDictionary*)JSONDictionary;
@end



@interface UIColor (HexString)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
- (NSString*)hexString;
@end