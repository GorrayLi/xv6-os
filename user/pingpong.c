#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[])
{
    char content;
    int pid;
    int p[2];

    if (argc > 1){
        fprintf(2,"usage: pingpong\n");
        exit(1);
    }

    pipe(p);
    if (fork() == 0){
        pid = getpid();
        read(p[0], &content, 1);
        close(p[0]);
        printf("%d: received ping\n", pid);
        write(p[1], "0", 1);
        close(p[1]);
        exit(0);
    } else {
        pid = getpid();

        write(p[1], "0", 1);
        close(p[1]);
        wait(0);

        read(p[0], &content, 1);
        close(p[0]);
        printf("%d: received pong\n", pid);
        exit(0);
    }
}