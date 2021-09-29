#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void child_process(int *p)
{
    int pp[2];
    int prime;
    int num;
    int ret;

    close(p[1]);
    //terminate condition
    ret = read(p[0], &prime, sizeof(int));
    if (ret == 0){
        close(p[0]);
        exit(0);
    }
    printf("prime %d\n", prime);

    pipe(pp);
    if (fork() == 0){
        close(p[0]);
        child_process(pp);
    }
    else{
        close(pp[0]);
        while(read(p[0], &num, sizeof(int))){
            if (num % prime != 0){
                write(pp[1], &num, sizeof(int));
            }
        }
        close(pp[1]);
        close(p[0]);
        wait(0);
    }
    exit(0);
}

int main(int argc, char* argv[])
{
    int p[2];
    int num;

    if (argc > 1){
        fprintf(2,"usage: primes\n");
        exit(1);
    }

    pipe(p);
    if (fork() == 0){
        child_process(p);
    }
    else{
        close(p[0]);
        for (num=2; num<=35; num++)
        {
            write(p[1], &num, sizeof(int));
        }
        close(p[1]);
        wait(0);
    }

    exit(0);
}