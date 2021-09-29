#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[])
{
    int delay_ticks = 0;

    if (argc <= 1){
        fprintf(2,"usage: sleep NUMBER\n");
        exit(1);
    }

    delay_ticks = atoi(argv[1]);
    sleep(delay_ticks);
    exit(0);
}