//
//  TileView.h
//  SliderGame
//
//  Created by Nimesh on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DNTileView : UIImageView {
    
    // This value determines the win condition position of the tile
    int winConditionXPosition;
    int winConditionYPosition;
    
    // This value is used to determine the current position of the tile on the board
    int currentXPosition;
    int currentYPosition;
}

@property (nonatomic, assign) int winConditionXPosition;
@property (nonatomic, assign) int winConditionYPosition;
@property (nonatomic, assign) int currentXPosition;
@property (nonatomic, assign) int currentYPosition;

@end
