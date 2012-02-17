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
@end

@implementation TileModel

@synthesize board, rowOfTileToBeEmpty, columnOfTileToBeEmpty;

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
    
    self.board = [rows shuffledArray:rows];
    [rows release];

    // Generate random row and column to be empty
    self.rowOfTileToBeEmpty = arc4random_uniform(4);
    self.columnOfTileToBeEmpty = arc4random_uniform(4);

    [[self.board objectAtIndex:rowOfTileToBeEmpty] replaceObjectAtIndex:columnOfTileToBeEmpty withObject:[NSNumber numberWithInt:-1]];
    
#ifdef DEBUG
    NSLog(@"Board = %@", self.board);
#endif
}

@end
