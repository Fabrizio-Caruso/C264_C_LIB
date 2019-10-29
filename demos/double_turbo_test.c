#include <conio.h>
#include <peekpoke.h>

void INITRASTER(void);

int main()
{
    unsigned short i;
    unsigned long s = 0;

    clrscr();
    
    INITRASTER();
    gotoxy(1,3);
    cprintf("Raster interrupt initialized\n");
    

    while(1)
    {
    for(i=0;i<100;++i)
    {
        POKE(3072,i&0xFF);
        s+=i;
    }
    gotoxy(1,4);
    cprintf("%lu",s);
    }
    while(1){};
    return 0;
}