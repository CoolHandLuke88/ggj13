//
//  GameOverLayer.m
//  ggj13
//
//  Created by Brennon Redmyer on 1/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
#import "GameOverLayer.h"
#import "TitleLayer.h"
@implementation GameOverLayer
+ (CCScene *)sceneWithWon:(BOOL)won {
    CCScene *scene = [CCScene node];
    GameOverLayer *layer = [[GameOverLayer alloc] initWithWon:won];
    [scene addChild:layer];
    return scene;
}
- (id)initWithWon:(BOOL)won {
    self = [super init];
    if (self) {
        NSString *message;
        if (won) {
            message = [NSString stringWithFormat:@"You Won!"];
        } else {
            message = [NSString stringWithFormat:@"You Lose!"];
        }
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCLabelTTF *label = [CCLabelTTF labelWithString:message fontName:@"Marker Felt" fontSize:64];
        label.color = ccc3(255, 255, 255);
        label.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:label];
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3], [CCCallBlockN actionWithBlock:^(CCNode *node) {
            [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
        }], nil]];
    }
    return self;
}
@end
