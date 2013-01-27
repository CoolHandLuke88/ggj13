//
//  TitleLayer.m
//  ggj13
//
//  Created by Brennon Redmyer on 1/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "TitleLayer.h"
#import "HelloWorldLayer.h"


@implementation TitleLayer
+ (CCScene *)scene {
    CCScene *scene = [CCScene node];
    TitleLayer *layer = [TitleLayer node];
    [scene addChild:layer];
    return scene;
}
- (id)init {
    self = [super init];
    if (self) {
        CCLabelTTF *titleLabel = [CCLabelTTF labelWithString:@"Cardio Drop" fontName:@"Marker Felt" fontSize:64];
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // position label at center of screen
        titleLabel.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:titleLabel];
        // menu items
        [CCMenuItemFont setFontSize:28];
        CCMenuItem *itemStartGame = [CCMenuItemFont itemWithString:@"Play" block:^(id sender) {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer scene] withColor:ccWHITE]];
        }];
        CCMenu *menu = [CCMenu menuWithItems:itemStartGame, nil];
        [menu setPosition:ccp(winSize.width/2, winSize.height/2 - 50)];
        [self addChild:menu];
    }
    return self;
}
@end
