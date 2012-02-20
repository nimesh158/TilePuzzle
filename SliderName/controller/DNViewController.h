//
//  DNViewController.h
//  SliderPuzzle
//
//  Created by Nimesh on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DNTileModel.h"
#import "DNTileView.h"

@interface DNViewController : UIViewController <DNTileModelDelegate> {
    
    // The button to start the game
    IBOutlet UIButton* startGame;
    
    // The board view
    IBOutlet UIView* boardView;
    
    // The reference Image view
    IBOutlet UIView* referenceView;
    
    // Keeps a track of if the reference view should be dragged in/out or not
    
    // Keeps a track of if the user has initialized the board very first time or not
    BOOL isBoardInitialized;
    
    // Keeps a track of what kind of move the tile can make
    PossibleMoves move;
    
    // The maximum of two tiles that can be dragged with the current tile
    DNTileView* tileOne;
    DNTileView* tileTwo;
    
    // Keeps a track if the tile can be dragged or not
    BOOL tileCanBeDragged;
    
    // Keeps track of if the dragging should be finished, or not
    BOOL finishDragging;
    
    // Keeps a track of how much the tile has been dragged by
    int draggedBy;
    
    // Keeps a track of the original position
    int firstX;
    int firstY;
    
    // Keeps a reference to the individual tile width and height
    int tileWidth, tileHeight;
    
    // Keeps a track of all the tiles
    NSMutableArray* tiles;
    
    // The tile model object
    DNTileModel* tileModel;
}

@property (nonatomic, retain) UIButton* startGame;
@property (nonatomic, retain) UIView* boardView;
@property (nonatomic, retain) UIView* referenceView;
@property (nonatomic, assign) BOOL isBoardInitialized;
@property (nonatomic, assign) PossibleMoves move;
@property (nonatomic, assign) BOOL tileCanBeDragged;
@property (nonatomic, assign) BOOL finishDragging;
@property (nonatomic, assign) int draggedBy;
@property (nonatomic, assign) int firstX;
@property (nonatomic, assign) int firstY;
@property (nonatomic, assign) int tileWidth;
@property (nonatomic, assign) int tileHeight;
@property (nonatomic, retain) NSMutableArray* tiles;
@property (nonatomic, retain) DNTileModel* tileModel;

/**
    Starts the game 
*/
- (IBAction) startTheGame:(id)sender;

@end
