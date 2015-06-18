//
//  UIDevice+Hardware.m
//  Wheelmap
//
//  Created by Dorian Roy on 27.07.12.
//
//

#import "UIDevice+Hardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDevice(Hardware)

- (NSString *) platform
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

@end
