//
//  NSArray+Shuffle.h
//  SliderPuzzle
//
//  Created by Nimesh on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (DNShuffle)

/**
    This method is used to randomly swap any two tiles on the board
    The problem with this method is that it can create a board ~50% of the times that
    is insolvable.
*/
- (NSMutableArray *) shuffledArray:(NSMutableArray *) array;

@end
