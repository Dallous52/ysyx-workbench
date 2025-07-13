#include "device.h"

void flash_spi_init();
void uart_init();

void device_init()
{
    flash_spi_init();
    uart_init();
}