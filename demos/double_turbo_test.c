#include <conio.h>
#include <peekpoke.h>

void INITRASTER(void);

int main()
{
    unsigned short i; 
    unsigned short j = 0;
    unsigned long s = 0;
    unsigned long c = 0;

    clrscr();
    gotoxy(1,1);
    cprintf("press a key to start");
    cgetc();

    gotoxy(1,3);
    cprintf("raster interrupt initialized\n");    
    INITRASTER();

    for(j=0;j<40;++j)
    {
        for(i=0;i<5000;++i)
        {
            POKE(3072,i&0xFF);
            s+=i;
        }
        POKE(3072+40+(c++),81);     
    }
    while(1){};
    return 0;
}