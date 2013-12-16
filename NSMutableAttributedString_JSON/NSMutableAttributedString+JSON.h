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
- (void)addAttributeWithJSONDictionary:(NSDictionary *)jsonDict;
@end
