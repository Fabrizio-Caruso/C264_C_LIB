#include <conio.h>
#include <peekpoke.h>

void INITRASTER(void);

int main()
{
    unsigned char i;
    
    clrscr();
    
    gotoxy(1,1);
    cprintf("Press a key to start\n");
    cgetc();
    
    INITRASTER();
    gotoxy(1,3);
    cprintf("Raster interrupt initialized\n");
    
    while(1)
    {
        POKE(3072,++i);
    };

    return 0;
}