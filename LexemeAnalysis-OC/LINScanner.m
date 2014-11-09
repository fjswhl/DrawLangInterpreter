//
//  LINScanner.m
//  LexemeAnalysis-OC
//
//  Created by Lin on 14/11/7.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import "LINScanner.h"

Token TokenTab[] = {
    {CONST_ID,  @"PI",       3.1415926,  NULL},
    {CONST_ID,  @"E",        2.71828,    NULL},
    {T,         @"T",        0.0,        NULL},
    {FUNC,      @"SIN",      0.0,        sin},
    {FUNC,      @"COS",      0.0,        cos},
    {FUNC,      @"TAN",      0.0,        tan},
    {FUNC,      @"LN",       0.0,        log},
    {FUNC,      @"EXP",      0.0,        exp},
    {FUNC,      @"SQRT",     0.0,        sqrt},
    {ORIGIN,    @"ORIGIN",   0.0,        NULL},
    {SCALE,     @"SCALE",    0.0,        NULL},
    {ROT,       @"ROT",      0.0,        NULL},
    {IS,        @"IS",       0.0,        NULL},
    {FOR,       @"FOR",      0.0,        NULL},
    {FROM,      @"FROM",     0.0,        NULL},
    {TO,        @"TO",       0.0,        NULL},
    {STEP,      @"STEP",     0.0,        NULL},
    {DRAW,      @"DRAW",     0.0,        NULL}
};

@implementation LINScanner{
    NSInteger _lineNo;
    FILE *_inFile;
    NSString *_tokenBuffer;
}

//+ (instancetype)sharedScanner{
//    static LINScanner *sharedScanner = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedScanner = [[LINScanner alloc] init];
//    });
//    return sharedScanner;
//}

- (instancetype)init{
    if (self = [super init]) {
       // Token *aToken = [Token alloc] init
    }
    return self;
}

- (instancetype)initWithFilename:(NSString *)fileName{
    if (self = [super init]) {
        _lineNo = 1;
        _inFile = fopen([fileName cStringUsingEncoding:NSUTF8StringEncoding], "r");
        if (_inFile != NULL) {
            return self;
        }
    }
    return nil;
}

- (void)dealloc{
    fclose(_inFile);
}

- (char)getChar{
    int character = getc(_inFile);
    return toupper(character);
}

- (void)backChar:(char) character{
    if (character != EOF) {
        ungetc(character, _inFile);
    }
}

- (void)addCharToTokenString:(char)character{
    char *p = malloc(sizeof(character));
    *p = character;
    _tokenBuffer = [_tokenBuffer stringByAppendingString:[NSString stringWithCString:p encoding:NSUTF8StringEncoding]];
    free(p);
}

- (Token)judgeKeyToken:(NSString *)IDString{
    for (int i = 0; i < sizeof(TokenTab) / sizeof(TokenTab[0]); i++) {
        if ([TokenTab[i].lexeme isEqualToString: IDString]) {
            return TokenTab[i];
        }
    }
    
    Token errorToken;
    memset(&errorToken, 0, sizeof(Token));
    errorToken.type = ERRTOKEN;
    return errorToken;
}

- (Token)getToken{
    Token token;
    int character;
    
    memset(&token, 0, sizeof(token));
    
    _tokenBuffer = @"";
    
    // clear blank character
    while (1) {
        character = [self getChar];
        if (character == EOF) {
            token.type = NONTOKEN;
            return token;
        }
        if (character == '\n') {
            _lineNo++;
        }
        if (!isspace(character)) {
            break;
        }
    }
    
    [self addCharToTokenString:character];
    
    // if it is alpha, it must be id,constant,reserved word
    if (isalpha(character)) {
        while (1) {
            character = [self getChar];
            if (isalnum(character)) {
                [self addCharToTokenString:character];
            }else{
                break;
            }
        }
        [self backChar:character];
        token = [self judgeKeyToken:_tokenBuffer];
        token.lexeme = _tokenBuffer;                    //TODO TEST
        return token;
    }else if (isdigit(character)){              //number
        while (1) {
            character = [self getChar];
            if (isdigit(character)) {
                [self addCharToTokenString:character];
            }else break;
        }
        if (character == '.') {
            [self addCharToTokenString:character];
            while (1) {
                character = [self getChar];
                if (isdigit(character)) {
                    [self addCharToTokenString:character];
                }else break;
            }
        }
        
        [self backChar:character];
        token.type = CONST_ID;
        token.lexeme = _tokenBuffer;
        token.value = atof([_tokenBuffer cStringUsingEncoding:NSUTF8StringEncoding]);
        return token;
    }else{
        switch (character) {
            case ';':
                token.type = SEMICO;
                break;
            case '(':
                token.type = L_BRACKET;break;
            case ')':
                token.type = R_BRACKET;break;
            case ',':
                token.type = COMMA;break;
            case '+':
                token.type = PLUS;break;
            case '-':{
                character = [self getChar];
                if (character == '-') {
                    while (character != '\n' && character != EOF) {
                        character = [self getChar];
                    }
                    [self backChar:character];
                    return [self getToken];
                }else{
                    [self backChar:character];
                    token.type = MINUS;
                    break;
                }
            }
            case '/':{
                character = [self getChar];
                if (character == '/') {
                    while (character != '\n') {
                        character = [self getChar];
                    }
                    [self backChar:character];
                    return [self getToken];
                }else{
                    [self backChar:character];
                    token.type = DIV;
                    break;
                }
            }
            case '*':{
                character = [self getChar];
                if (character == '*') {
                    token.type = POWER;
                    break;
                }else{
                    [self backChar:character];
                    token.type = MUL;
                    break;
                }
            }
            default: token.type = ERRTOKEN;
                break;
        }
    }
    token.lexeme = _tokenBuffer;
    return token;
}
@end












































