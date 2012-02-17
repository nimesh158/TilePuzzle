//
//  TileModel.h
//  SliderName
//
//  Created by Nimesh on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum Move {
    NONE = 0,
    UP = 1,
    RIGHT = 2,
    DOWN = 3,
    LEFT = 4
} PossibleMoves;

@interface TileModel : NSObject {
    
    // The two dimensional board of size 4x4
    NSMutableArray* board;
}

@property (nonatomic, retain) NSMutableArray* board;

/**
    This method is used to determine if a tile can be moved
    in UP, RIGHT, DOWN, LEFT or NONE
 */
- (BOOL) canMoveTileWithXPos:(int) xPos yPos:(int) yPos andDirection:(PossibleMoves) move;

@end
