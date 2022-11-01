#!/usr/bin/env fish

kmake ARCH=arm CROSS_COMPILE=arm-linux-gnu- mrproper allmodconfig arch/arm/mach-s3c/mach-crag6410.o &| grep "undeclared here"
switch "$pipestatus"
    case "0 1"
        return 0
    case "2 0"
        return 1
    case '*'
        return 125
end
