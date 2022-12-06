// Used if RPushPNP is built as a framework, use_frameworks! is used in Podfile
#if __has_include(<RPushPNP/RPushPNP-Swift.h>)
    #import <RPushPNP/RPushPNP-Swift.h>

// Used if RPushPNP is built as a static library, use_frameworks! is not used in Podfile
#elif __has_include("RPushPNP-Swift.h")
    #import "RPushPNP-Swift.h"
#endif
