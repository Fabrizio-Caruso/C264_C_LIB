#include <conio.h>

void INITRASTER(void);

int main()
{
    clrscr();
    
    gotoxy(1,1);
    cprintf("Press a key to start\n");
    cgetc();
    
    INITRASTER();
    gotoxy(1,3);
    cprintf("Raster interrupt initialized\n");
    
    while(1){};

    return 0;
}