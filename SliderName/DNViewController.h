//
//  DNViewController.h
//  SliderGame
//
//  Created by Nimesh on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DNTileModel.h"


@interface DNViewController : UIViewController {
    
    // The button to start the game
    IBOutlet UIButton* startGame;
    
    // The board view
    IBOutlet UIView* boardView;
    
    // The reference Image view
    IBOutlet UIView* referenceView;
    
    // Zoom into the reference view
    IBOutlet UIButton* zoomIntoReferenceView;
    
    // Keeps a track of all the tiles
    NSMutableArray* tiles;
    
    // The tile model object
    DNTileModel* tileModel;
}

@property (nonatomic, retain) UIButton* startGame;
@property (nonatomic, retain) UIView* boardView;
@property (nonatomic, retain) UIView* referenceView;
@property (nonatomic, retain) UIButton* zoomIntoReferenceView;
@property (nonatomic, retain) NSMutableArray* tiles;
@property (nonatomic, retain) DNTileModel* tileModel;

/**
    Starts the game 
*/
- (IBAction) startTheGame:(id)sender;

@end
