#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

static NSTimer* timer;
static int timeCount;
static UIAlertController* alert;
static UIAlertAction* changeAction;

@interface PythAlarmListController: PSListController 
{

}

@end


@implementation PythAlarmListController

- (id)specifiers 
{
	
     if(_specifiers == nil) 
    {
		
        _specifiers = [[self loadSpecifiersFromPlistName:@"PythAlarm" target:self] retain];
       NSDictionary* stats = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.alex.pythalarm.stats.plist"];
       if (stats.count != 0)
       {
           for (int i=0; i<[_specifiers count];i++)
           {
                if([[[_specifiers objectAtIndex:i] valueForKey:@"name"] isEqualToString:@"Equations faced: 0"] == YES)
                {
                    [[_specifiers objectAtIndex:i] setValue:[NSString stringWithFormat:@"Equations faced: %i",[[stats objectForKey:@"total"]intValue]] forKey:@"name"];
                }
                if([[[_specifiers objectAtIndex:i] valueForKey:@"name"] isEqualToString:@"Equations resolved: 0"] == YES)
                {
                    [[_specifiers objectAtIndex:i] setValue:[NSString stringWithFormat:@"Equations resolved: %i",[[stats objectForKey:@"sucess"]intValue]] forKey:@"name"];
                }
                if([[[_specifiers objectAtIndex:i] valueForKey:@"name"] isEqualToString:@"Equations abandonned: 0"] == YES)
                {
                    [[_specifiers objectAtIndex:i] setValue:[NSString stringWithFormat:@"Equations abandonned: %i",[[stats objectForKey:@"changed"]intValue]] forKey:@"name"];
                }
                if([[[_specifiers objectAtIndex:i] valueForKey:@"name"] isEqualToString:@"Wrong answers: 0"] == YES)
                {
                    [[_specifiers objectAtIndex:i] setValue:[NSString stringWithFormat:@"Wrong answers: %i",[[stats objectForKey:@"try"]intValue]] forKey:@"name"];
                }
           }
       }
       if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/com.alex.pythalarm.plist"] == NO)
       {
                  NSDictionary* emptyDict =  [[NSDictionary alloc]init];
                  [emptyDict writeToFile:@"/var/mobile/Library/Preferences/com.alex.pythalarm.plist" atomically:NO];
                  alert = [UIAlertController alertControllerWithTitle:@"Thank you for your purchase!" message:@"Hello, I would like to say a big thank you for your purchase and for your support, that means a lot to me! :)\n\nHowever, if you have pirated the tweak, please consider purchasing it if you appreciate it, it cost less than a coffe and represent weeks of work! ;)\n\nIn all cases, I hope you will enjoy PythAlarm!\n\n\nPlease wait 15 secondes ..." preferredStyle:UIAlertControllerStyleAlert];
                  changeAction = [UIAlertAction actionWithTitle:@"Got it!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}]; 
                  changeAction.enabled = NO;
                   [alert addAction:changeAction];
                   [[[[UIApplication sharedApplication] keyWindow]rootViewController] presentViewController:alert animated:YES completion:nil];
                   timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
                   timeCount = 15;
       }
    }
    return _specifiers;

    
}


-(void)timerFired
{
    timeCount--;
    if(timeCount == 0)
    {
        alert.message=@"Hello, I would like to say a big thank you for your purchase and for your support, that means a lot to me! :)\n\nHowever, if you have pirated the tweak, please consider purchasing it if you appreciate it, it cost less than a coffe and represent weeks of work! ;)\n\nIn all cases, I hope you will enjoy PythAlarm!";
        changeAction.enabled =YES;
        [timer invalidate];
    }
    else if (timeCount== 1)
    {
        alert.message=@"Hello, I would like to say a big thank you for your purchase and for your support, that means a lot to me! :)\n\nHowever, if you have pirated the tweak, please consider purchasing it if you appreciate it, it cost less than a coffe and represent weeks of work! ;)\n\nIn all cases, I hope you will enjoy PythAlarm!\n\n\nPlease wait 1 seconde ...";
    }
    else
    {
        alert.message= [NSString stringWithFormat:@"%@\n\n\nPlease wait %i secondes ...",@"Hello, I would like to say a big thank you for your purchase and for your support, that means a lot to me! :)\n\nHowever, if you have pirated the tweak, please consider purchasing it if you appreciate it, it cost less than a coffe and represent weeks of work! ;)\n\nIn all cases, I hope you will enjoy PythAlarm!",timeCount];
    }
}

@end


// vim:ft=objc

    