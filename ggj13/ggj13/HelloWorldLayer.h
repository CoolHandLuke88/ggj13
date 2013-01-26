//
//  HelloWorldLayer.h
//  ggj13
//
//  Created by Brennon Redmyer on 1/25/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "cocos2d.h"
#import "Box2D.h"
#define PTM_RATIO 32.0
#define ptm(__x__) (__x__/PTM_RATIO)

@interface HelloWorldLayer : CCLayer {
    NSMutableArray *_blockArray;
    b2World *_world;
    b2Body *_body;
    CCSprite *_block;
    b2Vec2 _mouseWorld;
    b2MouseJoint *_mouseJoint;
}
+ (id)scene;
@end