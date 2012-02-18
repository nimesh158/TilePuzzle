//
//  TileModel.m
//  SliderPuzzle
//
//  Created by Nimesh on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DNTileModel.h"
#import "NSArray+Shuffle.h"

@interface DNTileModel (Private)

/**
    This method updates the board for the tile to be moved and the direction 
    it is to be moved in for consistency
 */
- (void) updateBoardForTileXPos:(int) tileXPos yPos:(int) tileYPos andDirection:(PossibleMoves) direction;
@end

@implementation DNTileModel

@synthesize delegate, board;

#pragma mark - Initialization and Deallocation
- (id) init {
    self = [super init];
    if(self) {
        [self initializeTheBoard];
        
        return self;
    }
    
    return nil;
}

- (void) dealloc {
    [self.board release], board = nil;
    [super dealloc];
}

#pragma mark - Initialize the board
- (void) initializeTheBoard {    
    NSMutableArray* rows = [[NSMutableArray alloc] initWithCapacity:4];
    int counter = 0;
    for (int i = 0; i < 4; ++i) {
        NSMutableArray* column = [[NSMutableArray alloc] initWithCapacity:4];
        for (int j = 0; j < 4; ++j) {
            [column addObject:[NSNumber numberWithInt:counter]];
            counter++;
        }
        [rows addObject:column];
        [column release];
    }
    
    self.board = rows;
    [rows release];
    
    // Remove the very last tile (15th in 0 -15 terms) and then create a legal randomized board
    // that is solvable
    
    // -1 means that it's the 'empty' tile
    [[self.board objectAtIndex:3] replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:-1]];
    
    [self.delegate boardInitialized];
}

#pragma mark - Reset the board
- (void) resetBoard {
    [self.board removeAllObjects];
    [self.board release], board = nil;
    
    [self initializeTheBoard];
}

#pragma mark - Create Legal Randomized Board
- (void) createLegalRandomizedBoardWithNumberOfMoves:(int) moves {
    
    // to generate a randomized legal board
    // first move the 14th tile to the right
    // and then created the randomized board
    
    [self canMoveTileWithXPos:2 yPos:3 andDirection:RIGHT];
    while (moves > 0) {
        int xPosToMove = arc4random_uniform(4);
        int yPosToMove = arc4random_uniform(4);
        int directionToMove = arc4random_uniform(5);
        
        if(directionToMove > 0) {
            if([self canMoveTileWithXPos:xPosToMove yPos:yPosToMove andDirection:directionToMove]) {
                moves--;
            }
        }
    }
    
    [self.delegate randomizedBoardCreated];
}

#pragma mark - Can Move Tile in Direction Of
- (BOOL) canMoveTileWithXPos:(int)xPos yPos:(int)yPos andDirection:(PossibleMoves)move {

    switch (move) {
        case UP: {
            int xToCheck = xPos;
            int yToCheck = yPos - 1;
            if(yToCheck < 0)
                return NO;
            
            if([[[self.board objectAtIndex:xToCheck] objectAtIndex:yToCheck] intValue] == -1) {
                [self updateBoardForTileXPos:xPos yPos:yPos andDirection:move];
                return YES;
            }
            break;
        }
            
        case RIGHT: {
            int xToCheck =xPos + 1;
            if(xToCheck > 3)
                return NO;
            
            int yToCheck = yPos;
            
            if([[[self.board objectAtIndex:xToCheck] objectAtIndex:yToCheck] intValue] == -1) {
                [self updateBoardForTileXPos:xPos yPos:yPos andDirection:move];
                return YES;
            }
            break;
        }
            
        case DOWN:{
            int xToCheck = xPos;
            int yToCheck = yPos + 1;
            if(yToCheck > 3)
                return NO;
            
            if([[[self.board objectAtIndex:xToCheck] objectAtIndex:yToCheck] intValue] == -1) {
                [self updateBoardForTileXPos:xPos yPos:yPos andDirection:move];
                return YES;
            }
            break;
        }
            
        case LEFT: {
            int xToCheck = xPos - 1;
            if(xToCheck < 0)
                return NO;
            
            int yToCheck = yPos;
            
            if([[[self.board objectAtIndex:xToCheck] objectAtIndex:yToCheck] intValue] == -1) {
                [self updateBoardForTileXPos:xPos yPos:yPos andDirection:move];
                return YES;
            }
            break;
        }
            
        default:
            break;
    }
    return NO;
}

#pragma mark - Update the Board For Tile XPos YPos Direction
- (void) updateBoardForTileXPos:(int) tileXPos yPos:(int) tileYPos andDirection:(PossibleMoves) direction {
    switch (direction) {
        case UP: {
            int newEmptyY = tileYPos - 1;
            [[self.board objectAtIndex:tileXPos] exchangeObjectAtIndex:newEmptyY withObjectAtIndex:tileYPos];
            break;
        }
            
        case RIGHT: {
            int newEmptyX = tileXPos + 1;
            
            int temp = [[[self.board objectAtIndex:tileXPos] objectAtIndex:tileYPos] intValue];
            [[self.board objectAtIndex:newEmptyX] replaceObjectAtIndex:tileYPos withObject:[NSNumber numberWithInt:temp]];
            [[self.board objectAtIndex:tileXPos] replaceObjectAtIndex:tileYPos withObject:[NSNumber numberWithInt:-1]];
            break;
        }
            
        case DOWN: {
            int newEmptyY = tileYPos + 1;
            [[self.board objectAtIndex:tileXPos] exchangeObjectAtIndex:newEmptyY withObjectAtIndex:tileYPos];
            break;
        }
            
        case LEFT: {
            int newEmptyX = tileXPos - 1;
            
            int temp = [[[self.board objectAtIndex:tileXPos] objectAtIndex:tileYPos] intValue];
            [[self.board objectAtIndex:newEmptyX] replaceObjectAtIndex:tileYPos withObject:[NSNumber numberWithInt:temp]];
            [[self.board objectAtIndex:tileXPos] replaceObjectAtIndex:tileYPos withObject:[NSNumber numberWithInt:-1]];
            
            break;
        }
            
        default:
            break;
    }
}

@end
