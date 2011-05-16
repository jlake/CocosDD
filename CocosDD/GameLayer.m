//
//  GameLayer.m
//  CocosDD
//
//  Created by 欧 on 11/05/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"

@implementation GameLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];

	return scene;
}

- (id)init
{
	if((self=[super init])) {
        winSize = [CCDirector sharedDirector].winSize;
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        background = [CCSprite spriteWithFile:@"blue-shooting-stars.png"];
        background.anchorPoint = ccp(0, 0);
        [self addChild:background];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        movableSprites = [[NSMutableArray alloc] init];
        NSArray *images = [NSArray arrayWithObjects:@"bird.png", @"cat.png", @"dog.png", @"turtle.png", nil];
        int count = images.count;
        for(int i=0; i<count; i++) {
            CCSprite *sprite = [CCSprite spriteWithFile:[images objectAtIndex:i]];
            sprite.position = ccp(winSize.width*(i+1)/(count+1), winSize.height/2);
            
            [self addChild:sprite];
            [movableSprites addObject:sprite];
        }
        
        //// Drag & Drop without gesture
        //[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	}
	return self;
}

- (void)selectSpriteForTouch:(CGPoint)touchLocation
{
    CCSprite *newSprite = nil;
    for(CCSprite *sprite in movableSprites) {
        //NSLog(@"sprite: %@", sprite);
        if(CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
            newSprite = sprite;
            break;
        }
    }
    //NSLog(@"newSprite: %@", newSprite);
    if(newSprite != selSprite) {
        [selSprite stopAllActions];
        [selSprite runAction:[CCRotateTo actionWithDuration:0.1 angle:0]];
        CCRotateTo *rotLeft = [CCRotateBy actionWithDuration:0.1 angle:-4.0];
        CCRotateTo *rotCenter = [CCRotateBy actionWithDuration:0.1 angle:0.0];
        CCRotateTo *rotRight = [CCRotateBy actionWithDuration:0.1 angle:4.0];
        CCRotateTo *rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, nil];
        [newSprite runAction:[CCRepeatForever actionWithAction:rotSeq]];
        selSprite = newSprite;
    }
}

- (CGPoint)boundLayerPos:(CGPoint)newPos
{
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -background.contentSize.width + winSize.width);
    retval.y = self.position.y;
    return retval;
}

- (void)panForTranslation:(CGPoint)translation {
    if (selSprite) {
        CGPoint newPos = ccpAdd(selSprite.position, translation);
        selSprite.position = newPos;
    } else {
        CGPoint newPos = ccpAdd(self.position, translation);
        self.position = [self boundLayerPos: newPos];
    }
}


//// Drag & Drop without gesture
//- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
//    [self selectSpriteForTouch:touchLocation];
//    return TRUE;
//}
//
//
//- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
//    
//    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
//    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
//    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
//    
//    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
//    [self panForTranslation:translation];
//}


// Drag & Drop with gesture
-(void)handlePanFrom:(UIPanGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        touchLocation = [self convertToNodeSpace:touchLocation];
        //NSLog(@"touchLocation x=%f, y= %f", touchLocation.x, touchLocation.y);
        [self selectSpriteForTouch:touchLocation];
        
    } else if(recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = ccp(translation.x, -translation.y);
        [self panForTranslation:translation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
    } else if(recognizer.state == UIGestureRecognizerStateEnded) {
        
        if(!selSprite) {
            float scrollDuration = 0.2;
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            CGPoint newPos = ccpAdd(self.position, ccpMult(velocity, scrollDuration));
            newPos = [self boundLayerPos:newPos];
            
            [self stopAllActions];
            CCMoveTo *moveTo = [CCMoveTo actionWithDuration:scrollDuration position:newPos];
            [self runAction:[CCEaseOut actionWithAction:moveTo rate:1.0]];
        }
    }
}

- (void)dealloc
{
    [movableSprites release];
    movableSprites = nil;
    
	[super dealloc];
}

@end
