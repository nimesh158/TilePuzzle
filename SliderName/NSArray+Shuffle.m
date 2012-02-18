//
//  NSArray+Shuffle.m
//  SliderGame
//
//  Created by Nimesh on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Shuffle.h"

@implementation NSArray (DNShuffle)

#pragma mark - Shuffled Array
- (NSMutableArray *) shuffledArray:(NSMutableArray *) array {
    
    NSMutableArray* shuffledArray = [NSMutableArray arrayWithCapacity:[array count]];
    
    for (int i = 0; i < 4; ++i) {
        NSMutableArray* column = [[NSMutableArray alloc] initWithCapacity:4];
        for (int j = 0; j < 4; ++j) {
            [column addObject:[NSNumber numberWithInt:-1]];
        }
        
        [shuffledArray addObject:column];
        [column release];
    }
    
    NSMutableArray* originalArray = [array mutableCopy];

    int rowToBeAddedTo = 0 ;
    int columnToBeAddedTo = 0;
    
    while ([originalArray count] > 0) {
        int rowOfItem = arc4random_uniform(4);
        int columnOfItem = arc4random_uniform(4);
        
        if(rowOfItem < [originalArray count]) {
            if(columnOfItem < [[originalArray objectAtIndex:rowOfItem] count]) {
                if([[originalArray objectAtIndex:rowOfItem] objectAtIndex:columnOfItem]) {
                    [[shuffledArray objectAtIndex:rowToBeAddedTo] replaceObjectAtIndex:columnToBeAddedTo withObject:[[originalArray objectAtIndex:rowOfItem] objectAtIndex:columnOfItem]];
                    
                    columnToBeAddedTo++;
                    if(columnToBeAddedTo > 3) {
                        columnToBeAddedTo = 0;
                        rowToBeAddedTo++;
                    }
                    
                    [[originalArray objectAtIndex:rowOfItem] removeObjectAtIndex:columnOfItem];
                    if([[originalArray objectAtIndex:rowOfItem] count] == 0) {
                        [originalArray removeObjectAtIndex:rowOfItem];
                    }
                }
            }
        }

#ifdef DEBUG
//        NSLog(@"Original Array = %@", originalArray);
//        NSLog(@"Shuffled Array = %@", shuffledArray);
#endif
    }
    
    [originalArray release];
    
    return shuffledArray;
}

@end
