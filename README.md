NSMutableAttributedString+JSON
==============================

Category on NSMutableAttributedString that enables initialization with JSON objects.

Compatible JSON can be generated with node.js module: [json-attributed-string](https://github.com/iksnae/json-attributed-string)

Supported Attributes:
```objective-c
NSFontAttributeName
NSParagraphStyleAttributeName
NSForegroundColorAttributeName
NSBackgroundColorAttributeName
NSLigatureAttributeName
NSStrokeColorAttributeName
NSStrokeWidthAttributeName
NSShadowAttributeName
NSAttachmentAttributeName
NSLinkAttribute
```

Usage
--------------

```smartalk

// import the category
#import "NSMutableAttributedString+JSON.h"

// create json-data object from file
NSData * jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"json"]];

// create json-dictionary from data object
NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];

// create attributed string with json-dictionary
NSMutableAttributedString * attString = [[NSMutableAttributedString alloc]initWithJSONDictionary:jsonDict];

// create new json-dictionary from attributed string
NSDictionary * outJsonDict = [attString JSONDict];

// set attributed string on text view with generated json
[self.textView setAttributedText:[outJsonDict mutableCopy]];

```



Results
--------------
![ScreenShot](https://raw.github.com/iksnae/NSMutableAttributedString_JSON/master/ss1.png)
