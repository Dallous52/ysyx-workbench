#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) 
{
  const char* st = s;
  while (*s != '\0')
    s++;
  return s - st;
}


char *strcpy(char *dst, const char *src) 
{
  char* p = dst;
  while ((*(p++) = *(src++)));
  return dst;
}


char *strncpy(char *dst, const char *src, size_t n) 
{
  char* p = dst;
  while ((*(p++) = *(src++))){
    if (p - dst == n) break;
  }
  return dst;
}


char *strcat(char *dst, const char *src) 
{
  char* p = dst;
  while (*p) p++;
  while ((*(p++) = *(src++)));
  return dst;
}


int strcmp(const char *s1, const char *s2) 
{
  while (*s1 && (*s1 == *s2))
  {
    s1++;
    s2++;
  }

  return *((uint8_t*)s1) - *((uint8_t*)s2);
}


int strncmp(const char *s1, const char *s2, size_t n) 
{
  while (n-- > 0)
  {
    if (*s1 != *s2) return *((uint8_t*)s1) - *((uint8_t*)s2);
    
    if (*s1 == 0) return 0;

    s1++; s2++;
  }
  return 0;
}


void *memset(void *s, int c, size_t n) 
{
  uint8_t* p = s;
  while (n--) *p++ = (uint8_t)c;
  return s;
}


void *memmove(void *dst, const void *src, size_t n)
{
  uint8_t *d = dst;
  const uint8_t *s = src;

  if (d < s) 
  {
    while (n--) *d++ = *s++;
  }
  else
  {
    d += n;
    s += n;
    while (n--) *(--d) = *(--s);
  }
  
  return dst;
}


void *memcpy(void *out, const void *in, size_t n) 
{
  uint8_t *d = out;
  const uint8_t *s = in;

  while (n--) *d++ = *s++;

  return out;
}


int memcmp(const void *s1, const void *s2, size_t n) 
{
  const uint8_t* p1 = s1;
  const uint8_t* p2 = s2;

  while (n--)
  {
    if (*p1 != *p2) return *p1 - *p2;
    ++p1;
    ++p2;
  }

  return 0;
}

#endif
