//
//  TileView.h
//  SliderName
//
//  Created by Nimesh on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileView : UIImageView {
    
    // This value determines the win condition position of the tile
    int winConditionPosition;
    
    // This value is used to determine the current position of the tile on the board
    int currentPosition;
}

@property (nonatomic, assign) int winConditionPosition;
@property (nonatomic, assign) int currentPosition;

@end
