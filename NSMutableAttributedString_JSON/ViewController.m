//
//  ViewController.m
//  JSONAttributedStringTest
//
//  Created by Khalid on 12/14/13.
//
//

#import "ViewController.h"
#import "NSMutableAttributedString+JSON.h"

@interface ViewController ()
@property (nonatomic,strong) UITextView * textView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(20, 40, 280, 400 )];
    [self.view addSubview:self.textView];
    NSData * jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"json"]];
    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSMutableAttributedString * attString = [[NSMutableAttributedString alloc]initWithJSONDictionary:jsonDict];
//    [self.textView setFont:[UIFont italicSystemFontOfSize:36]];
    [self.textView setAttributedText:[attString mutableCopy]];
    
    NSDictionary * dict = [attString JSONDictionary];
    NSLog(@"out: %@",dict);
    
    
    NSMutableAttributedString * attString2 = [[NSMutableAttributedString alloc]initWithJSONDictionary:dict];
//    [self.textView setFont:[UIFont italicSystemFontOfSize:36]];
    [self.textView setAttributedText:[attString2 mutableCopy]];
    
    
    
}



@end
