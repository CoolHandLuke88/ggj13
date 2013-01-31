//
//  HelloWorldLayer.h
//  ggj13
//
//  Created by Brennon Redmyer on 1/25/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "cocos2d.h"
#import "Box2D.h"
#import "BoxDebugLayer.h"
#import "GLES-Render.h"
#import "PhysicsSprite.h"
//#import "MyContactListener.h"
#import "ContactListener.h"

#define PTM_RATIO 32.0
#define ptm(__x__) (__x__/PTM_RATIO)

enum {
	kTagParentNode = -14,
    kTagheartParentNode = -15,
};

@interface HelloWorldLayer : CCLayer {
    // NSMutableArray *_topBlockArray;
    NSMutableArray *_rightBlockArray;
    NSMutableArray *_leftBlockArray;
    b2World *_world;
    b2Body *_body;
    b2Body *_touchedBody;
    CCSprite *_block;
    CCSprite *_refBlock;
    b2Vec2 _mouseWorld;
    b2MouseJoint *_mouseJoint;
    //added code for hearty heart and volumeeeeeeee...
    CCTexture2D *heartSpriteTexture_;	// weak ref
    CCSprite *volumeMeterSprite;
    CCSprite *volumeBarSprite;
    CCSprite *refSpr;
    CCLabelTTF *_scoreLabel;
    b2Fixture *heartFixture;
    b2Fixture *blockFixture;
   // MyContactListener *_contactListener;
    ContactListener *contactListener;
    int score;
}
@property (strong, nonatomic) NSMutableArray *topBlockArray;
@property (strong, nonatomic) NSMutableArray *topMissingArray;
@property (assign, nonatomic) b2Body *grabbedBody;
@property (assign, nonatomic) CGPoint snapPoint;
@property (assign, nonatomic) int numberofBar;
@property (assign, nonatomic) int newBar;
@property (assign, nonatomic)  b2FixtureDef blockShapeDef;
@property (assign, nonatomic) NSInteger assignedBlockTag;
@property (assign, nonatomic) BOOL canDeleteBlock;
@property (assign, nonatomic) int lastIndex;
-(void) addHeartSpriteAtPosition:(CGPoint)p;
+ (id)scene;
@end