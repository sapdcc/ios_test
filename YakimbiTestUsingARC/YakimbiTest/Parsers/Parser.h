//
//  Parser.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/16/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Parser;

@protocol ParserDelegate <NSObject>

@required
- (void)parseData:(NSData *)data;
- (void)parseData:(NSData *)data inBackground:(BOOL)inBackground;

@end

@protocol ParserResponseDelegate <NSObject>

@required
- (void)parsingFinished:(Parser *)parser;
- (void)parsingFailed:(Parser *)parser withError:(NSError *)error;

@end

@interface Parser : NSObject<ParserDelegate>
{
    __weak id _delegate;
    int _tag;
}

@property (weak , nonatomic) id delegate;
@property (assign, nonatomic) int tag;

@end
