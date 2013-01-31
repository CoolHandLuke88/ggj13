//
//  ContactListener.m
//  ggj13
//
//  Created by Luke McDonald on 1/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ContactListener.h"

ContactListener::ContactListener() : _contacts() {
}

ContactListener::~ContactListener() {
}



void ContactListener::BeginContact(b2Contact *contact)
{
    b2Body *bodyA = contact->GetFixtureA()->GetBody();
    b2Body *bodyB = contact->GetFixtureB()->GetBody();
    CCSprite *spriteA = (CCSprite*)bodyA->GetUserData();
    CCSprite *spriteB = (CCSprite*)bodyB->GetUserData();
    
   
    
    if (spriteA != NULL && spriteB != NULL) {
        spriteA.color = ccMAGENTA;
        spriteB.color = ccMAGENTA;
        
        MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
        _contacts.push_back(myContact);
    }
}

void ContactListener::EndContact(b2Contact *contact)
{
    b2Body *bodyA = contact->GetFixtureA()->GetBody();
    b2Body *bodyB = contact->GetFixtureB()->GetBody();
    CCSprite *spriteA = (CCSprite*)bodyA->GetUserData();
    CCSprite *spriteB = (CCSprite*)bodyB->GetUserData();
    
    
    
    if (spriteA != NULL && spriteB != NULL) {
        spriteA.color = ccWHITE;
        spriteB.color = ccWHITE;
        
                MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
                std::vector<MyContact>::iterator pos;
                pos = std::find(_contacts.begin(), _contacts.end(), myContact);
                if (pos != _contacts.end()) {
                    _contacts.erase(pos);
                }
            }
}

void ContactListener::PreSolve(b2Contact* contact,
                                 const b2Manifold* oldManifold) {
}

void ContactListener::PostSolve(b2Contact* contact,
                                  const b2ContactImpulse* impulse) {
}

