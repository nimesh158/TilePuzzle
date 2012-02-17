//
//  TileModel.h
//  SliderName
//
//  Created by Nimesh on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TileModel : NSObject {
    
    // The two dimensional board of size 4x4
    NSMutableArray* board;
    
    // The row and column tile that is empty
    int rowOfTileToBeEmpty;
    int columnOfTileToBeEmpty;
}

@property (nonatomic, retain) NSMutableArray* board;
@property (nonatomic, assign) int rowOfTileToBeEmpty;
@property (nonatomic, assign) int columnOfTileToBeEmpty;

@end
