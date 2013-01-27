//
//  GameOverLayer.h
//  ggj13
//
//  Created by Brennon Redmyer on 1/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOverLayer : CCLayer {
    
}
+ (CCScene *)sceneWithWon:(BOOL)won;
- (id)initWithWon:(BOOL)won;
@end