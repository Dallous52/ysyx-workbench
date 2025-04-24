#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)


int printf(const char *fmt, ...) {
  char out[1000] = {};
  // 获取可变参数
  va_list args;
  va_start(args, fmt);
  int ret = vsprintf(out, fmt, args);
  va_end(args);
  putstr(out);
  return ret;
}


int vsprintf(char *out, const char *fmt, va_list ap) 
{
  char *p = out; // 当前写入位置

  while (*fmt) 
  {
      if (*fmt == '%') 
      {
          fmt++;
          switch (*fmt) 
          {
              case 'd': {
                int num = va_arg(ap, int);
                char buf[20];
                char *b = buf + sizeof(buf) - 1;
                *b = '\0';

                int neg = 0;
                if (num < 0) { neg = 1; num = -num;}

                do 
                {
                    *--b = '0' + (num % 10);
                    num /= 10;
                } while (num > 0);
                
                if (neg) *--b = '-';

                while (*b) *p++ = *b++;

                break;
              }

              case 's': {
                  char *s = va_arg(ap, char*);
                  while (*s) *p++ = *s++;
                  break;
              }

              case 'c': {
                  // char参数提升为int，Default Argument Promotions(默认参数提升)
                  char c = (char)va_arg(ap, int); 
                  *p++ = c;
                  break;
              }

              case '%': {
                  // 处理 %%
                  *p++ = '%';
                  break;
              }

              default: {
                  // 遇到未知的格式，原样输出
                  *p++ = '%';
                  *p++ = *fmt;
                  break;
              }
          }
      } else {
          *p++ = *fmt;
      }
      fmt++;
  }

  *p = '\0'; // 末尾加上 '\0'

  return p - out; 
}


int sprintf(char *out, const char *fmt, ...) 
{
  // 获取可变参数
  va_list args;
  va_start(args, fmt);

  int ret = vsprintf(out, fmt, args);
 
  va_end(args);
  
  // 返回总长
  return ret; 
}


int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}


int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
