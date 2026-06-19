#ifndef GIE_INTERFACE_H
#define GIE_INTERFACE_H

// Enables the Global Interrupts by setting the GIE bit
void GIE_voidEnable(void);

// Disables the Global Interrupts by clearing the GIE bit
void GIE_voidDisable(void);

#endif