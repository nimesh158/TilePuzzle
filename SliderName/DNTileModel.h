//
//  TileModel.h
//  SliderPuzzle
//
//  Created by Nimesh on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum Move {
    NONE        =   0,
    UP          =   1,
    RIGHT       =   2,
    DOWN        =   3,
    LEFT        =   4,
    TWOUP       =   5,
    THREEUP     =   6,
    TWORIGHT    =   7,
    THREERIGHT  =   8,
    TWODOWN     =   9,
    THREEDOWN   =   10,
    TWOLEFT     =   11,
    THREELEFT   =   12
} PossibleMoves;

@protocol DNTileModelDelegate;

@interface DNTileModel : NSObject {
    
    // The delegate object
    id<DNTileModelDelegate> delegate;
    
    // The two dimensional board of size 4x4
    NSMutableArray* board;
}

@property (nonatomic, assign) id<DNTileModelDelegate> delegate;
@property (nonatomic, retain) NSMutableArray* board;

/**
    Initializes the board
 */
- (void) initializeTheBoard;

/**
    Resets the board to "complete" condition and then
    re-randomizes the board
*/
- (void) resetBoard;

/**
    This method is used to randomize the board in the way
    that the randomized board is still legal and solvable
 */
- (void) createLegalRandomizedBoardWithNumberOfMoves:(int) moves;

/**
    This method is used to determine if a tile can be moved
    in UP, RIGHT, DOWN, LEFT or NONE
 */
- (BOOL) canMoveTileWithXPos:(int) xPos yPos:(int) yPos andDirection:(PossibleMoves) move;

/**
    Returns what kind of dragging move the current tile the user is trying to drag
    can take place
*/
- (PossibleMoves) canDragTileWithXPos:(int) xPos yPos:(int) yPos;

/**
    Performs the updating the model
*/
- (void) moveTileWithXPos:(int) xPos yPos:(int) yPos inDirection:(PossibleMoves) direction;

/**
    Performs a check to see if the game has ended by checking if all the tiles are in their
    correct position
*/
- (BOOL) hasGameEnded;

@end

@protocol DNTileModelDelegate <NSObject>

@required
- (void) boardInitialized;
- (void) randomizedBoardCreated;

@end
