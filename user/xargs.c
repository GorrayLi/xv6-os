#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"

int main(int argc, char *argv[])
{
    char* exec_argv[MAXARG];
    int i;
    int len;
    char buf[512];

    if (argc < 2){
        fprintf(2, "usage: no command");
        exit(1);
    }

    if (argc + 1 > MAXARG){
        fprintf(2, "usage: exceed max argc");
        exit(1);
    }

    for (i=1; i<argc; i++)
    {
        exec_argv[i-1] = argv[i];
    }
    exec_argv[argc] = 0;

    while (1)
    {
        i = 0;
        while (1)
        {
            len = read(0, &buf[i], 1);
            if (len == 0 || (buf[i] == '\n'))
                break;
            i++;
        }
        if (i == 0)
            break;
        buf[i] = 0;
        exec_argv[argc - 1] = buf;
        if (fork() == 0){
            exec(exec_argv[0], exec_argv);
            exit(0);
        }
        else{
            wait(0);
        }
    }

    exit(0);
}