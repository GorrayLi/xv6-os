# trap代码执行流程  
以write()系统调用为例：  
* usermode下调用write(), 跳转到usys.s中，write对应的位置，如下  
```asm
.global write
write:
 li a7, SYS_write
 ecall
 ret
```  
* 将write的syscall num加载到a7寄存器,然后执行ecall命令；  
* 执行ecall命令后，系统从usermode切换到supervisor mode, 将pc保存到SEPC寄存器（便于执行完系统调用后跳转回原位置），然后跳转到STVEC寄存器中保存的地址（内核事先设置好的trap跳转固定地址），该地址位于trampoline page，将执行汇编函数uservec，见trampoline.S：  
```asm
.globl trampoline
trampoline:
.align 4
.globl uservec
uservec:    
	#
        # trap.c sets stvec to point here, so
        # traps from user space start here,
        # in supervisor mode, but with a
        # user page table.
        #
        # sscratch points to where the process's p->trapframe is
        # mapped into user space, at TRAPFRAME.
        #
        
	# swap a0 and sscratch
        # so that a0 is TRAPFRAME
        csrrw a0, sscratch, a0

        # save the user registers in TRAPFRAME
        sd ra, 40(a0)
        sd sp, 48(a0)
        sd gp, 56(a0)
        sd tp, 64(a0)
```
* 在uservec函数中，首先交换a0和SSCRATCH寄存器，即将a0的值（write的参数）保存到SSCRATCH寄存器，SSCRATCH寄存器的值则加载到a0寄存器，而SSCRATCH原来的值是trapframe page的虚拟地址（XV6在每个user page table映射了trapframe page，此时还没有切换到内核页表），即此时a0指向trapframe page。  
   备注：SSCRATCH，STVEC寄存器等寄存器是如何被内核事先设置好的呢？答案是：一台机器总是从内核开始运行的，当机器启动的时候，它就是在内核中。 任何时候，不管是进程第一次启动还是从一个系统调用返回，进入到用户空间的唯一方法是就是执行sret指令。sret指令是由RISC-V定义的用来从supervisor mode转换到user mode。所以，在任何用户代码执行之前，内核会执行fn函数（in usertrapret(void)），并设置好所有的东西，例如SSCRATCH，STVEC寄存器。
* 接下来，将当前的用户寄存器的值借助a0寄存器全部保存到trapframe page中。  
* 加载kernel sp。（trapframe中的kernel_sp是由kernel在进入用户空间之前就设置好的，它的值是这个进程的kernel stack。所以这条指令的作用是初始化Stack Pointer指向这个进程的kernel stack的最顶端）：  
```asm
        # restore kernel stack pointer from p->trapframe->kernel_sp
        ld sp, 8(a0)
```  
  将hartid加载到tp寄存器.(向tp寄存器写入数据。因为在RISC-V中，没有一个直接的方法来确认当前运行在多核处理器的哪个核上，XV6会将CPU核的编号也就是hartid保存在tp寄存器)。  
  将函数usertrap的指针加载到t0寄存器；  
  将将kernel pagetable的地址加载到t1寄存器，然后交换到satp寄存器，清空TLB，此时satp寄存器的值发生了变化，程序也从user page table切换到kernel page table；  
  uservec函数中最后一步是jump to t0地址，由前面知t0保存了usertrap()的函数指针，即跳转到函数usertrap()。  
* usertrap中先将STVEC指向了kernelvec变量，这是内核空间trap处理代码的位置，而不是用户空间trap处理代码的位置。  
  随后通过调用myproc函数获取到当前运行的进程。myproc函数实际上会查找一个根据当前CPU核的编号索引的数组，CPU核的编号是hartid（保存在tp寄存器）；  
  为防止SEPC寄存器中的用户pc被覆盖（如进程切换），我们将它保存到一个与该进程关联的内存中。这里我们使用trapframe来保存这个程序计数器；  
  接下来我们需要找出我们现在会在usertrap函数的原因。根据触发trap的原因，RISC-V的SCAUSE寄存器会有不同的数字。数字8表明，我们现在在trap代码中是因为系统调用；  
  接下来第一件事情是检查是不是有其他的进程杀掉了当前进程，但是我们的Shell没有被杀掉，所以检查通过；
  存储在SEPC寄存器中的程序计数器，是用户程序中触发trap的指令的地址。但是当我们恢复用户程序时，我们希望在下一条指令恢复，也就是ecall之后的一条指令。所以对于系统调用，我们对于保存的用户程序计数器加4，这样我们会在ecall的下一条指令恢复，而不是重新执行ecall指令。  
  XV6会在处理系统调用的时候使能中断，这样中断可以更快的服务，有些系统调用需要许多时间处理。中断总是会被RISC-V的trap硬件关闭，所以在这个时间点，我们需要显式的打开中断。  
  下一行代码中，我们会调用syscall函数。  
```C
void
usertrap(void)
{
  int which_dev = 0;

  if((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);

  struct proc *p = myproc();
  
  // save user program counter.
  p->trapframe->epc = r_sepc();
  
  if(r_scause() == 8){
    // system call

    if(p->killed)
      exit(-1);

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;

    // an interrupt will change sstatus &c registers,
    // so don't enable until done with those registers.
    intr_on();

    syscall();
  } else if((which_dev = devintr()) != 0){
    // ok
  } else {
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    p->killed = 1;
  }

  if(p->killed)
    exit(-1);

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2)
    yield();

  usertrapret();
}
```  
* syscall函数中，首先从a7寄存器中读出syscall num，write()的syscall num为16, 然后通过syscall num索引到syscall真正的函数实现sys_write。  
```C
void
syscall(void)
{
  int num;
  struct proc *p = myproc();

  num = p->trapframe->a7;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    p->trapframe->a0 = syscalls[num]();
  } else {
    printf("%d %s: unknown sys call %d\n",
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}
```  
* syscall执行完后，返回到usertrap()继续往下执行，然后调用到usertrapret();  
* usertrapret()中，首先关闭了中断，这里关闭中断是因为我们将要更新STVEC寄存器（之前指向内核空间的trap处理代码）来指向用户空间的trap处理代码。当我们将STVEC更新到指向用户空间的trap处理代码时，我们仍然在内核中执行代码。如果这时发生了一个中断，那么程序执行会走向用户空间的trap处理代码，这会导致内核出错。  
  随后，设置了STVEC寄存器指向trampoline代码，在那里最终会执行sret指令返回到用户空间；  
  接下来，将kernel page table的指针、当前用户进程的kernel stack、usertrap函数的指针、CPU核编号存入trapframe的内容中；  
  然后，我们要设置SSTATUS寄存器。这是一个控制寄存器。这个寄存器的SPP bit位控制了sret指令的行为，该bit为0表示下次执行sret的时候，我们想要返回user mode而不是supervisor mode。这个寄存器的SPIE bit位控制了，在执行完sret之后，是否打开中断。  
  将之前保存的用户PC写道SEPC寄存器中，接下来，我们根据user page table地址生成相应的SATP值，这样我们在返回到用户空间的时候才能完成page table的切换。  
  随后计算将要跳转到汇编代码的地址fn=userret函数的地址，然后执行fn，即执行userret。  
```C
void
usertrapret(void)
{
  struct proc *p = myproc();

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()

  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
}
```  
* userret位于trampoline代码中，即程序执行又回到了trampoline；  
  首先， 切换到用户空间， 然后，将SSCRATCH寄存器恢复成保存的用户的a0寄存器（此时trapframe中之前保存a0值的位置已被syscall返回值覆盖），然后恢复之前保存的其它寄存器，然后交换a0和sscratch的值，则a0恢复到用户a0寄存器的值（syscall返回值），sscratch的值为TRAPFRAME的地址（TRAPFRAME作为userret的第一个参数保存在a0里）。最后执行sret。  
* 执行sret后，程序会切换回user mode， SEPC寄存器的数值会被拷贝到PC寄存器， 重新打开中断，最终回到用户空间。  
```asm
.globl userret
userret:
        # userret(TRAPFRAME, pagetable)
        # switch from kernel to user.
        # usertrapret() calls here.
        # a0: TRAPFRAME, in user page table.
        # a1: user page table, for satp.

        # switch to the user page table.
        csrw satp, a1
        sfence.vma zero, zero

        # put the saved user a0 in sscratch, so we
        # can swap it with our a0 (TRAPFRAME) in the last step.
        ld t0, 112(a0)
        csrw sscratch, t0

        # restore all but a0 from TRAPFRAME
        ld ra, 40(a0)
        ld sp, 48(a0)
        ld gp, 56(a0)
        ld tp, 64(a0)
        ld t0, 72(a0)
        ld t1, 80(a0)
        ld t2, 88(a0)
        ld s0, 96(a0)
        ld s1, 104(a0)
        ld a1, 120(a0)
        ld a2, 128(a0)
        ld a3, 136(a0)
        ld a4, 144(a0)
        ld a5, 152(a0)
        ld a6, 160(a0)
        ld a7, 168(a0)
        ld s2, 176(a0)
        ld s3, 184(a0)
        ld s4, 192(a0)
        ld s5, 200(a0)
        ld s6, 208(a0)
        ld s7, 216(a0)
        ld s8, 224(a0)
        ld s9, 232(a0)
        ld s10, 240(a0)
        ld s11, 248(a0)
        ld t3, 256(a0)
        ld t4, 264(a0)
        ld t5, 272(a0)
        ld t6, 280(a0)

	# restore user a0, and save TRAPFRAME in sscratch
        csrrw a0, sscratch, a0
        
        # return to user mode and user pc.
        # usertrapret() set up sstatus and sepc.
        sret
```  

  
  
  
  
