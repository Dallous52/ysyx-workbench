#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>
#include <string.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  return strlen(s);
}

char *strcpy(char *dst, const char *src) {
  return strcpy(dst, src);        
}

char *strncpy(char *dst, const char *src, size_t n) {
  return strncpy(dst, src, n);
}

char *strcat(char *dst, const char *src) {
  return strcat(dst, src);        
}

int strcmp(const char *s1, const char *s2) {
  return strcmp(s1, s2);
}

int strncmp(const char *s1, const char *s2, size_t n) {
  return strncmp(s1, s2, n);  
}

void *memset(void *s, int c, size_t n) {
  return memset(s, c, n);   
}

void *memmove(void *dst, const void *src, size_t n) {
  return memmove(dst, src, n);
}

void *memcpy(void *out, const void *in, size_t n) {
  return memcpy(out, in, n);
}

int memcmp(const void *s1, const void *s2, size_t n) {
  return memcmp(s1, s2, n);
}

#endif
