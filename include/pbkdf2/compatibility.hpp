#pragma once

#if defined(PBKDF2_STATIC)
  #define PBKDF2_API
#elif defined(_WIN32) || defined(__CYGWIN__)
  #if defined(pbkdf2_EXPORTS) || defined(PBKDF2_EXPORTS)
    #define PBKDF2_API __declspec(dllexport)
  #else
    #define PBKDF2_API __declspec(dllimport)
  #endif
#else
  #define PBKDF2_API __attribute__((visibility("default")))
#endif
