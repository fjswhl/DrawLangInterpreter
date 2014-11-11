//
//  main.m
//  LexemeAnalysis-OC
//
//  Created by Lin on 14/11/7.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LINScanner.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        Token token;
        
        LINScanner *aScanner = [[LINScanner alloc] initWithFilename:@"aa"];
        if (!aScanner) {
            NSLog(@"cannot open file");
            return 0;
        }
        while (1) {
            token = [aScanner getToken];
            if (token.type != NONTOKEN) {
       //         NSLog(@"%4lu, %12@, %12f, %12x", token.type, token.lexeme, token.value, token.fptr);
                printf("%4d, %12s, %12f, %12x\n", (int)token.type, [token.lexeme cStringUsingEncoding:NSUTF8StringEncoding], token.value, (unsigned int)token.fptr);

            }else break;
        }

    }
    return 0;
}
