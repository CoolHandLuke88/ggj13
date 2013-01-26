//
//  HelloWorldLayer.mm
//  ggj13
//
//  Created by Brennon Redmyer on 1/25/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "QueryCallback.h"
@implementation HelloWorldLayer {
    BOOL isGrabbed;
}
+ (id)scene {
    CCScene *scene = [CCScene node];
    HelloWorldLayer *layer = [HelloWorldLayer node];
    [scene addChild:layer];
    return scene;
}
- (id)init {
    self = [super init];
    if (self) {
        // mousejoin nil
        _mouseJoint = nil;
        // enable touch
        self.isTouchEnabled = YES;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // create sprite and add it to the layer
//        _block = [CCSprite spriteWithFile:@"block_base.png"];
//        _block.position = ccp(100, 300);
        // create a world
        b2Vec2 gravity = b2Vec2(0.0f, -8.0f);
        _world = new b2World(gravity);
        // create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0, 0);
        b2Body *groundBody = _world->CreateBody(&groundBodyDef);
        b2EdgeShape groundEdge;
        b2FixtureDef boxShapeDef;
        boxShapeDef.shape = &groundEdge;
        // wall definitions
        groundEdge.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
        groundEdge.Set(b2Vec2(0, 0), b2Vec2(0, winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        groundEdge.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        groundEdge.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
//        [self addLeftBlocks];
//        [self addRightBlocks];
        [self addTopBlocks];
        [self schedule:@selector(updateBlock:) interval:1.0f];
        [self schedule:@selector(tick:)];
    }
    return self;
}
- (void)addTopBlocks {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSprite *tempSprite = [CCSprite spriteWithFile:@"block_base.png"];
    int imageWidth = tempSprite.contentSize.width;
    int imageHeight = tempSprite.contentSize.height;
    int numBlocks = winSize.width / imageWidth;
    self.topBlockArray = [NSMutableArray arrayWithCapacity:numBlocks];
    self.topMissingArray = [NSMutableArray arrayWithCapacity:numBlocks];
    for (int i = 0; i < numBlocks; i++) {
        _body = nil;
        _block = nil;
        _block = [CCSprite spriteWithFile:@"block_base.png"];
        _block.position = CGPointMake(_block.contentSize.width * i+_block.contentSize.width * 0.5f, winSize.height - _block.contentSize.height/2);
        CCSprite *futureBlock = [CCSprite spriteWithFile:@"block_base.png"];
        futureBlock.color = ccc3(100, 100, 100);
        futureBlock.position = _block.position;
        // create block body and shape
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_staticBody;
        blockBodyDef.position.Set(_block.position.x/PTM_RATIO, _block.position.y/PTM_RATIO);
        blockBodyDef.userData = _block;
        _body = _world->CreateBody(&blockBodyDef);
        _block.userData = _body;
        // modified for box shape instead of circle (from Ray Wenderlich's tutorial series)
        b2PolygonShape box;
        box.SetAsBox(16/PTM_RATIO, 16/PTM_RATIO);
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &box;
        blockShapeDef.density = 1.0f;
        blockShapeDef.friction = 0.2f;
        blockShapeDef.restitution = 0;
        _body->CreateFixture(&blockShapeDef);
        [self.topBlockArray addObject:_block];
        [self.topMissingArray addObject:futureBlock];
        [self addChild:_block z:0];
        [self addChild:futureBlock z:-1];
    }
}
- (void)addLeftBlocks {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSprite *tempSprite = [CCSprite spriteWithFile:@"block_base.png"];
    int imageWidth = tempSprite.contentSize.width;
    int imageHeight = tempSprite.contentSize.height;
    int numBlocks = winSize.width / imageWidth;
    _leftBlockArray = [NSMutableArray arrayWithCapacity:numBlocks];
    for (int i = 0; i < numBlocks; i++) {
        _body = nil;
        _block = nil;
        _block = [CCSprite spriteWithFile:@"block_base.png"];
        _block.position = CGPointMake(imageWidth/2, (winSize.height - _block.contentSize.height - (_block.contentSize.height * i+_block.contentSize.height * 0.5f)));
        // create block body and shape
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_staticBody;
        blockBodyDef.position.Set(_block.position.x/PTM_RATIO, _block.position.y/PTM_RATIO);
        blockBodyDef.userData = _block;
        _body = _world->CreateBody(&blockBodyDef);
        // modified for box shape instead of circle (from Ray Wenderlich's tutorial series)
        b2PolygonShape box;
        box.SetAsBox(16/PTM_RATIO, 16/PTM_RATIO);
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &box;
        blockShapeDef.density = 1.0f;
        blockShapeDef.friction = 0.2f;
        blockShapeDef.restitution = 0;
        _body->CreateFixture(&blockShapeDef);
        [self addChild:_block];
    }
}
- (void)addRightBlocks {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSprite *tempSprite = [CCSprite spriteWithFile:@"block_base.png"];
    int imageWidth = tempSprite.contentSize.width;
    int imageHeight = tempSprite.contentSize.height;
    int numBlocks = winSize.width/ imageWidth;
    _rightBlockArray = [NSMutableArray arrayWithCapacity:numBlocks];
    for (int i = 0; i < numBlocks; i++) {
        _body = nil;
        _block = nil;
        _block = [CCSprite spriteWithFile:@"block_base.png"];
        _block.position = CGPointMake(winSize.width - imageWidth/2, (winSize.height - _block.contentSize.height - (_block.contentSize.height * i+_block.contentSize.height * 0.5f)));
        // create block body and shape
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_staticBody;
        blockBodyDef.position.Set(_block.position.x/PTM_RATIO, _block.position.y/PTM_RATIO);
        blockBodyDef.userData = _block;
        _body = _world->CreateBody(&blockBodyDef);
        // modified for box shape instead of circle (from Ray Wenderlich's tutorial series)
        b2PolygonShape box;
        box.SetAsBox(16/PTM_RATIO, 16/PTM_RATIO);
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &box;
        blockShapeDef.density = 1.0f;
        blockShapeDef.friction = 0.2f;
        blockShapeDef.restitution = 0;
        _body->CreateFixture(&blockShapeDef);
        [self addChild:_block];
    }
}
- (void)updateBlock:(ccTime) dt {
    CCLOG(@"array count: %d", self.topBlockArray.count);
    [self chooseBlock:dt withArray:self.topBlockArray];
}
- (void)chooseBlock:(ccTime)dt withArray:(NSMutableArray *)blockArray {
    NSMutableArray *missingArray;
    int numItems = blockArray.count;
    int randIndex = arc4random() % numItems;
    CCSprite *block = [CCSprite spriteWithFile:@"block_base.png"];
    for (int i = 0; i < numItems; i++) {
        // holy shit, pissssss
        if (i == randIndex) {
            block = [blockArray objectAtIndex:i];
            b2Body* body = (b2Body *)block.userData;
            if (body != nil)
            {
                body->SetType(b2_dynamicBody);
                [blockArray removeObject:block];
                // [missingArray insertObject:futureBlock atIndex:i];
                break;
            }
        }
    }
}
- (void)tick:(ccTime)dt {
    _world->Step(dt, 10, 10);
    for (b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *blockData = (CCSprite *)b->GetUserData();
            blockData.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            blockData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
}
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView: [myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
    
	_mouseWorld.Set(ptm(location.x), ptm(location.y));
	if (_mouseJoint != NULL)
	{
		return;
	}
    
	b2AABB aabb;
	b2Vec2 d = b2Vec2(0.001f, 0.001f);
	aabb.lowerBound = _mouseWorld - d;
	aabb.upperBound = _mouseWorld + d;
    
	// Query the world for overlapping shapes.
	QueryCallback callback(_mouseWorld);
	_world->QueryAABB(&callback, aabb);
    
	if (callback.m_fixture)
	{
        isGrabbed = YES;
        CCLOG(@"isGrabbed = %d", isGrabbed);
		b2BodyDef bodyDef;
		b2Body* groundBody = _world->CreateBody(&bodyDef);
        
		b2Body* bodyz = callback.m_fixture->GetBody();
        self.grabbedBody = bodyz;
        CCLOG(@"Grabbed body!");
		bodyz->SetAwake(true);
        
		b2MouseJointDef md;
		md.bodyA = groundBody;
		md.bodyB = bodyz;
		md.target = _mouseWorld;
		md.maxForce = 1000.0f * bodyz->GetMass();
        
		_mouseJoint = (b2MouseJoint*)_world->CreateJoint(&md);
	}
}
- (void)ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch* myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView: [myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
    
	_mouseWorld.Set(ptm(location.x), ptm(location.y));
    
	if (_mouseJoint)
	{
		_mouseJoint->SetTarget(_mouseWorld);
	}
    // hover over ghost image
    // CCSprite *futureBlock = [CCSprite spriteWithFile:@"block_base.png"];
    for (CCSprite *block in self.topMissingArray) {
        CGRect rect = CGRectMake(block.position.x, block.position.y, block.contentSize.width, block.contentSize.height);
        // CGPoint newPoint = [sprite convertToNodeSpace:oldPoint];
        if (CGRectContainsPoint(rect, location)) {
            CCLOG(@"HIT!!!");
            self.snapPoint = block.position;
            // reimplement color highlighting later
            /* block.color = ccc3(255, 255, 255); */
        } else {
            // CCLOG(@"NOPE!!!");
            // self.snapPoint = CGPointZero;
            /* block.color = ccc3(100, 100, 100); */
        }
    }
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView: [myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
    
	[self ccTouchesCancelled:touches withEvent:event];
    for (CCSprite *block in self.topMissingArray) {
        CGRect rect = CGRectMake(block.position.x, block.position.y, block.contentSize.width, block.contentSize.height);
        if (CGRectContainsPoint(rect, location)) {
            CCLOG(@"HIT!!!");
            self.snapPoint = block.position;
            /* block.color = ccc3(100, 100, 100); */
            if (!isGrabbed) {
                self.grabbedBody->SetTransform(b2Vec2(block.position.x/PTM_RATIO, block.position.y/PTM_RATIO), 0);
                self.grabbedBody->SetType(b2_staticBody);
                block.userData = self.grabbedBody;
                [self.topBlockArray addObject:block];
            }
        }
    }
}
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_mouseJoint)
	{
		_world->DestroyJoint(_mouseJoint);
		_mouseJoint = NULL;
        isGrabbed = NO;
        CCLOG(@"Released body!");
        CCLOG(@"isGrabbed: %d", isGrabbed);
	}
}
//- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    // switch bodydef to dynamic and back
////    CCLOG(@"Touch!!");
////    for (b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
////        if (b->GetType() == b2_dynamicBody) {
////            CCLOG(@"Bodies dynamic, going static...");
////            b->SetType(b2_staticBody);
////        } else {
////            CCLOG(@"Bodies static, going dynamic...");
////            b->SetType(b2_dynamicBody);
////        }
////    }
//}
@end