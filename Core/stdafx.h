// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

// _WIN32 will detect windows on most compilers
#include <stdio.h>
#include <tchar.h>

#include <iomanip>
#include <iostream>
#include <vector>
#include <algorithm>
#include <cmath>
#include <map>
#include <string.h>

#define WIN32_LEAN_AND_MEAN
#include "windows.h"

#include "shlwapi.h"

#include "hkxpch.h"

// ref: https://tenshil.blogspot.com/2017/06/visualstudio-2015-error-lnk2019.html
#if defined(_MSC_VER) && _MSC_VER >= 1900
extern "C" FILE* __cdecl __iob_func(void)
{
    static FILE iob[] = { *stdin, *stdout, *stderr };
    return iob;
}
#endif
