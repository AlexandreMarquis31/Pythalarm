@import UIKit;
@import Foundation;

#import <stdlib.h>
#import "substrate.h"
#import<CoreGraphics/CoreGraphics.h>


#define kAddition 1
#define kMultiplication 2
#define kDivision 3
#define kSubstraction 4


@interface UIAlertControllerView : UIView
@property (nonatomic, copy) UIView* _dimmingView ;
@end

@interface BBBulletin : NSObject
@property (nonatomic, copy) NSString *sectionID;
@end

@interface SBAwayBulletinListItem : NSObject
@property(retain) BBBulletin* activeBulletin;
@end

@interface UIEquationAlertController: UIAlertController
-(id)initEquationAlertController;
-(void)changeAlertEquation;
-(void)saveStats;
@end

static int result;
static UIEquationAlertController* mathAlert;
static NSMutableArray* operations;
static int hightestNumber = 101;
static bool enabled = YES;
static NSString* title;
static int total;
static int changes ;
static int trial;
static int sucess;

//load prefs for alert
static void loadPrefs() {
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.alex.pythalarm.plist"];
     operations=[[NSMutableArray alloc]init];
    if ([settings objectForKey:@"Enable" ]){
	   enabled = [[settings objectForKey:@"Enable"]boolValue];
    }
    if (![settings objectForKey:@"Multiplication"]||[[settings objectForKey:@"Multiplication"]boolValue]){
        [operations addObject:[NSNumber numberWithInt: kMultiplication]];
    }
    if (![settings objectForKey:@"Division"] ||[[settings objectForKey:@"Division"]boolValue]){
        [operations addObject:[NSNumber numberWithInt: kDivision]];
    }
    if (![settings objectForKey:@"Soustraction"] ||[[settings objectForKey:@"Soustraction"]boolValue]){
        [operations addObject:[NSNumber numberWithInt: kSubstraction]];
    }
    if (![settings objectForKey:@"Addition"]||[[settings objectForKey:@"Addition"]boolValue] || ![operations count]){
        [operations addObject:[NSNumber numberWithInt:kAddition]];
    }
    title = @"Let's calculate!";
    if ([settings objectForKey:@"Title"] && ![[settings objectForKey:@"Title"] isEqualToString:@""]){
        title=[settings objectForKey:@"Title"];
    }
    if ([settings objectForKey:@"hightestNumber"]){
        hightestNumber = [[settings objectForKey:@"hightestNumber"]intValue];
    }
    [settings release];
}

%hook SBLockScreenViewController
- (void)presentFullscreenBulletinAlertWithItem:(id)arg1{
    %orig;
    loadPrefs();
    if (enabled && !mathAlert && [((SBAwayBulletinListItem*)arg1).activeBulletin.sectionID isEqualToString:@"com.apple.mobiletimer"]){
         mathAlert = [[UIEquationAlertController alloc]initEquationAlertController];
         [[[[UIApplication sharedApplication] keyWindow]rootViewController] presentViewController:mathAlert animated:YES completion:nil];
         [((UIAlertControllerView*)mathAlert.view)._dimmingView setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.0]];
         total=1;
         changes = 0;
         trial=0;
         sucess = 0;
    }
}

//hide alert if the alarm disappear
- (void)dismissFullscreenBulletinAlertWithItem:(id)arg1{
    %orig;
/*
    if ([[[UIApplication sharedApplication] keyWindow]rootViewController].presentedViewController == mathAlert)
    {
        [[[[UIApplication sharedApplication] keyWindow]rootViewController] dismissViewControllerAnimated:YES completion:nil];
    changes++;
    [mathAlert saveStats];
    mathAlert=nil;
    }
*/
}
%end

//check what to do if a button is pressed
@implementation UIEquationAlertController
//init equationalert
-(id)initEquationAlertController{
    self = [UIEquationAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* validAction = [UIAlertAction actionWithTitle:@"Validate" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
    [self changeAlertEquation];
    UIAlertAction* changeAction = [UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
    [self addAction:changeAction];
    [self addAction:validAction];
    [self addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Answer";
        [textField setKeyboardType:UIKeyboardTypeNumberPad];}];
    return self;
}

-(void)_dismissAnimated:(bool) animated triggeringAction:(UIAlertAction*)action{
	 if(result == [[NSNumberFormatter alloc]numberFromString:((UITextField*)[self.textFields objectAtIndex:0]).text].intValue && action == ((UIAlertAction*)[self.actions objectAtIndex:1])){
         [UIView animateWithDuration:0.5 delay:0.0 options:nil animations:^{
             self.view.frame=CGRectMake(self.view.frame.origin.x,-360,self.view.frame.size.width,self.view.frame.size.height);}
                          completion:^(BOOL){
                              [[[[UIApplication sharedApplication] keyWindow]rootViewController] dismissViewControllerAnimated:YES completion:nil];
                              sucess = 1;
                              [self saveStats];
                              mathAlert=nil;}];
     }
     else if(action == ((UIAlertAction*)self.actions.firstObject)){
         [self changeAlertEquation];
         changes++;
         total++;
     }
     else{
         [UIView animateWithDuration:0.025 delay:0.0 options:nil animations:^{
             self.view.frame=CGRectMake(self.view.frame.origin.x-15,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);}
                          completion:^(BOOL){}];
         [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse  animations:^{
             [UIView setAnimationRepeatCount:4];
             self.view.frame=CGRectMake(self.view.frame.origin.x+30,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);}
                          completion:^(BOOL){
                              [UIView animateWithDuration:0.025 delay:0.0 options:nil animations:^{
                                  self.view.frame=CGRectMake(self.view.frame.origin.x-15,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);}
                                               completion:^(BOOL){}];}];
         trial++;
     }
}

//save equations stats
-(void)saveStats{
    NSMutableDictionary* stats = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.alex.pythalarm.stats.plist"];
    if(!stats){
        stats = [[NSMutableDictionary alloc]init];
    }
    [stats setObject: [[NSNumberFormatter alloc] stringFromNumber:[NSNumber numberWithInt:[[stats objectForKey:@"total"]intValue]+total]]forKey:@"total"];
    [stats setObject: [[NSNumberFormatter alloc] stringFromNumber:[NSNumber numberWithInt:[[stats objectForKey:@"changed"]intValue]+changes]]forKey:@"changed"];
    [stats setObject: [[NSNumberFormatter alloc] stringFromNumber:[NSNumber numberWithInt:[[stats objectForKey:@"sucess"]intValue]+sucess]]forKey:@"sucess"];
    [stats setObject: [[NSNumberFormatter alloc] stringFromNumber:[NSNumber numberWithInt:[[stats objectForKey:@"try"]intValue]+trial]]forKey:@"try"];
    [stats writeToFile:@"/var/mobile/Library/Preferences/com.alex.pythalarm.stats.plist" atomically:NO];
}

//change equation
-(void)changeAlertEquation{
    int choix = arc4random_uniform([operations count]) ;
    int firstNumber= arc4random_uniform(hightestNumber);
    int secondNumber= arc4random_uniform(hightestNumber);
    switch (((NSNumber*)[operations objectAtIndex:choix]).intValue){
        case kMultiplication :
            self.message =[NSString stringWithFormat:@"%i %@ %i",firstNumber ,@"x",secondNumber];
            result= firstNumber*secondNumber;
            break;
        case kDivision :
            while (firstNumber%secondNumber || !secondNumber){
                firstNumber= arc4random_uniform(hightestNumber);
                secondNumber= arc4random_uniform(hightestNumber);
            }
            self.message =[NSString stringWithFormat:@"%i %@ %i",firstNumber ,@"/",secondNumber];
            result= firstNumber/secondNumber;
            break;
        case kSubstraction:
            while (firstNumber <secondNumber){
                firstNumber= arc4random_uniform(hightestNumber);
                secondNumber= arc4random_uniform(hightestNumber);
            }
            self.message =[NSString stringWithFormat:@"%i %@ %i",firstNumber ,@"-",secondNumber];
            result= firstNumber-secondNumber;
            break;
        case kAddition :
            self.message =[NSString stringWithFormat:@"%i %@ %i",firstNumber ,@"+",secondNumber];
            result= firstNumber+secondNumber;
            break;
    }
}
@end

//prevent screen for diming is user is facing an equation
%hook SBBacklightController
-(void)_lockScreenDimTimerFired{
       if(!((UITextField*)mathAlert.textFields.firstObject).isFirstResponder) {
           %orig;
       }
}
%end