//
//  GameLayer.h
//  CocosDD
//
//  Created by 欧 on 11/05/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface GameLayer : CCLayer {
@private
    CGSize winSize;

    CCSprite *background;
    CCSprite *selSprite;
    NSMutableArray *movableSprites;
}

+(CCScene *) scene;

//- (void)selectSpriteForTouch:(CGPoint)touchLocation;
@end
