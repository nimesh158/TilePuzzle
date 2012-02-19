//
//  DNViewController.h
//  SliderPuzzle
//
//  Created by Nimesh on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DNTileModel.h"


@interface DNViewController : UIViewController <DNTileModelDelegate> {
    
    // The button to start the game
    IBOutlet UIButton* startGame;
    
    // The board view
    IBOutlet UIView* boardView;
    
    // The reference Image view
    IBOutlet UIView* referenceView;
    
    // Zoom into the reference view
    IBOutlet UIButton* zoomIntoReferenceView;
    
    // Keeps a track of if the user has initialized the board very first time or not
    BOOL isBoardInitialized;
    
    // Keeps a track if the tile can be dragged or not
    BOOL tileCanBeDragged;
    
    // Keeps track of if the dragging should be finished, or not
    BOOL finishDragging;
    
    // Keeps a track of how much the tile has been dragged by
    int draggedBy;
    
    // Keeps a track of the original position
    int firstX;
    int firstY;
    
    // Keeps a track of all the tiles
    NSMutableArray* tiles;
    
    // The tile model object
    DNTileModel* tileModel;
}

@property (nonatomic, retain) UIButton* startGame;
@property (nonatomic, retain) UIView* boardView;
@property (nonatomic, retain) UIView* referenceView;
@property (nonatomic, retain) UIButton* zoomIntoReferenceView;
@property (nonatomic, assign) BOOL isBoardInitialized;
@property (nonatomic, assign) BOOL tileCanBeDragged;
@property (nonatomic, retain) NSMutableArray* tiles;
@property (nonatomic, retain) DNTileModel* tileModel;

/**
    Starts the game 
*/
- (IBAction) startTheGame:(id)sender;

@end
