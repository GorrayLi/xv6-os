# syscall

新增syscall及调用流程
1、在usys.pl中为新的syscall添加一条entry, 如entry("trace");
2、在user/user.h添加这条syscall的声明；
3、在kernel/syscall.h中为这条syscall定义一个syscall number；
4、在kernel/syscall.c中， (*syscalls[])(void) 为新的syscall添加一条syscall number到syscall函数定义的映射关系，syscall的实现见对应的sys_<syscall_name>;
5、在kernel/sysproc.c中，完成sys_<syscall_name>的实现；

    完成以上步骤后，make qemu会根据usys.pl生成usys.S，当调用某syscall时，会根据此文件，先从a7寄存器中取出syscall number，然后通过ecall指令trap到内核，然后执行到(*syscalls[])(void) ,
通过syscall number找到对应的函数实现sys_<syscall_name>。详见xv6 book section 4.3.
