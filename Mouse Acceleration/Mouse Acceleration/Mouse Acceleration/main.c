//
//  main.c
//  Mouse Acceleration
//
//  Created by William Green on 2014-06-29.
//  Copyright (c) 2014 William Green. All rights reserved.
//

// Taken from
// http://forums3.armagetronad.net/viewtopic.php?t=3364

#include <stdio.h>
#include <IOKit/hidsystem/IOHIDLib.h>
#include <IOKit/hidsystem/IOHIDParameter.h>

int main(int argc, char **argv)
{
    io_connect_t handle = NXOpenEventStatus();
    if (!handle) {
        printf("No handle\n");
        exit(1);
    }
    
    double before;
    if (IOHIDGetAccelerationWithKey(handle, CFSTR(kIOHIDMouseAccelerationType), &before) != KERN_SUCCESS) {
        printf("error getting acceleration\n");
        exit(1);
    }
    
    printf("mouse acceleration before = %f\n", before);
    
    if (IOHIDSetAccelerationWithKey(handle, CFSTR(kIOHIDMouseAccelerationType), 0.0) != KERN_SUCCESS) {
        printf("error setting acceleration\n");
        exit(1);
    }
    
    double after;
    if (IOHIDGetAccelerationWithKey(handle, CFSTR(kIOHIDMouseAccelerationType), &after) != KERN_SUCCESS) {
        printf("error getting acceleration\n");
        exit(1);
    }
    
    printf("mouse acceleration after = %f\n", after);
    
    NXCloseEventStatus(handle);
    return 0;
    
//    const int32_t accel = -0x10000; // if this ever becomes a scale factor, we set it to one
//    if (argc < 2) {
//        fprintf(stderr, "Give me mouse and/or trackpad as arguments\n");
//        return 1;
//    }
//    
//    io_connect_t handle = NXOpenEventStatus();
//    if (handle) {
//        for (int i = 1; i < argc; i++) {
//            CFStringRef type = 0;
//            
//            if (strcmp(argv[i], "mouse") == 0)
//                type = CFSTR(kIOHIDMouseAccelerationType);
//            else if (strcmp(argv[i], "trackpad") == 0)
//                type = CFSTR(kIOHIDTrackpadAccelerationType);
//            
//            char buffer[1024];
//            IOByteCount actualSize;
//            IOHIDGetParameter(handle, type, sizeof(buffer), &buffer, &actualSize);
//            
//            printf("accel = %d\n", *(int32_t *)buffer);
//            
//            
////            if (type && IOHIDSetParameter(handle, type, &accel, sizeof accel) != KERN_SUCCESS)
////                fprintf(stderr, "Failed to kill %s accel\n", argv[i]);
//        }
//        NXCloseEventStatus(handle);
//    } else
//        fprintf(stderr, "No handle\n");
//    
//    return 0;
}