//
//  TileModel.m
//  SliderName
//
//  Created by Nimesh on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TileModel.h"
#import "NSArray+Shuffle.h"

@interface TileModel (Private)
/**
    Initializes the board
 */
- (void) initializeTheBoard;

/**
    This method updates the board for the tile to be moved and the direction 
    it is to be moved in for consistency
 */
- (void) updateBoardForTileXPos:(int) tileXPos yPos:(int) tileYPos andDirection:(PossibleMoves) direction;
@end

@implementation TileModel

@synthesize board;

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
    
#ifdef DEBUG
    NSLog(@"Board = %@", self.board);
#endif
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
