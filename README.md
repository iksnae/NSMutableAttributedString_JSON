NSMutableAttributedString+JSON
==============================

Category on NSMutableAttributedString that enables initialization with JSON objects.

Compatible JSON can be generated with node.js module: ![json-attributed-string](https://github.com/iksnae/json-attributed-string)


Usage
--------------

```smartalk
#import "NSMutableAttributedString+JSON.h"
NSData * jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"json"]];
NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
NSLog(@"jsonDict: %@",jsonDict);
NSMutableAttributedString * attString = [[NSMutableAttributedString alloc]initWithJSONDictionary:jsonDict];
[self.textView setAttributedText:[attString mutableCopy]];
```



Results
--------------
![ScreenShot](https://raw.github.com/iksnae/NSMutableAttributedString_JSON/master/ss1.png)
