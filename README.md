# page table
## lab1: print a page table
* 编写一个函数vmprint()，参数为pagetable_t, 即给定第一级页表的物理地址，首先打印传参页表地址，然后打印出该页表中所有的PTE（同时解析对应的PA也打印出来），以及以该页表为根页表的整个页表树的PTE（和>PA）。
* 要求：  
  1) 无效的PTE(PTE的valid标志未置上)不打印；  
  2) 按如下示例格式打印：  
```
    page table 0x0000000087f6e000
    ..0: pte 0x0000000021fda801 pa 0x0000000087f6a000
    .. ..0: pte 0x0000000021fda401 pa 0x0000000087f69000
    .. .. ..0: pte 0x0000000021fdac1f pa 0x0000000087f6b000
    .. .. ..1: pte 0x0000000021fda00f pa 0x0000000087f68000
    .. .. ..2: pte 0x0000000021fd9c1f pa 0x0000000087f67000
    ..255: pte 0x0000000021fdb401 pa 0x0000000087f6d000
    .. ..511: pte 0x0000000021fdb001 pa 0x0000000087f6c000
    .. .. ..510: pte 0x0000000021fdd807 pa 0x0000000087f76000
    .. .. ..511: pte 0x0000000020001c0b pa 0x0000000080007000
```
* 题解及关键代码：  
  仿照freewalk()，采用递归调用，打印整个页表树的PTE。参照freewalk()，前两级页表中的PTE flags，可读可写可执行均为0，只有最后一级页表PTE对应最终的物理地址，可读可写可执行标志至少有一个会置上，这可以作为递归的终止条件。
* 关键代码：  
```C
//recursively print a page-table
void
vmprint_content(pagetable_t pagetable, int level)
{
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++) {
    pte_t pte = pagetable[i];
    if (pte & PTE_V){
      for (int j = 0; j <= (3 - level); j++){
        if (j != 0)
          printf(" ");
        printf("..");
      }

      uint64 child = PTE2PA(pte);

      printf("%d: pte %p pa %p\n", i, pte, child);
      
      if ((pte & (PTE_R|PTE_W|PTE_X)) == 0){
        // this PTE points to a lower-level page table.
        vmprint_content((pagetable_t)child, level-1);
      }
    }
  }
}

void
vmprint(pagetable_t pagetable)
{
  printf("page table %p\n", pagetable);
  vmprint_content(pagetable, 3);
}
```  

## lab2: A kernel page table per process  
* 背景：系统的内核页表全局只有一张，其虚拟地址和物理地址一一对应相等，所有进程共用此张内核页表。当进程产生系统调用时，传下来的地址是用户空间的虚拟地址，无法通过此内核页表映射。对于这种情况，现存的方案 是将进程用户页表也作为参数一并传下来，将系统调用传下来的用户虚拟地址，先通过页表映射到物理地址，由于内核页表将虚拟地址和物理地址映射相等，物理地址即内核空间的虚拟地址，即可在内核中正常访问。
* 题目要求：为每一个进程分配一个内核页表，其内容与全局页表一致，（并将用户页表内容copy到这个分进程的内核页表中，此部分见lab3）。当进程运行时，将内核页表切换为这个分进程的内核页表，这样用户空间传下来的用户虚拟地址，可直接通过此内核页表映射物理地址，从而解决背景中的问题，使系统调用传下来的地址可直接被访问。
*  题解及关键代码：   
   1、在struct proc中增加进程内核页表字段；  
   2、在allocproc()中给进程分配一个kernel pagetable, 然后kvminit()编写一个proc_kvminit(), 在allocproc()中调用，建立此进程内核页表的基本映射关系；  
   3、仿照procinit()建立内核栈的映射；  
```C
  // alloc and init a kernel pagetbl
  p->kernel_pagetable = proc_kvminit();
  if(p->kernel_pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }  
  
  proc_kvmmap(p->kernel_pagetable, KSTACK((int) (p - proc)),
    kvmpa(KSTACK((int) (p - proc))), PGSIZE, PTE_R | PTE_W);
```   
   4、进程调度的时候，在切换到某个进程之前，先将其对应的kernel pagetable的物理地址加载到satp寄存器，并清除TLB，进程退出时，重新恢复成全局kernel pagetable，加载到satp寄存器。scheduler()中关键代码如下：
```C
    for(p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if(p->state == RUNNABLE) {
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
        c->proc = p;
        proc_kvminithart(p->kernel_pagetable);
        swtch(&c->context, &p->context);

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        kvminithart();
        c->proc = 0;

        found = 1;
      }
      release(&p->lock);
    }
```    

   5、 释放进程资源时，也要释放进程的kernel pagetable，但要注意不要释放掉最终物理地址的内存，在freeproc()中增加如下代码： 
```C
  if(p->kernel_pagetable)
    proc_kpg_freewalk(p->kernel_pagetable);
  p->kernel_pagetable = 0;
```  

## lab3: Simplify copyin/copyinstr  
* 在lab2的基础上，将进程的用户页表信息copy到内核页表，这样系统调用传下来的用户地址，可以跟内核地址使用同一张映射表来访问物理地址。以实现copyin/copyinstr的简化。  
* 题解及关键代码：  
  1、修改copyin/copyinstr，在函数体内调用copyin_new/copyinstr_new;  
  2、在包括fork(), exec(), sbrk()在内的会改变进程用户地址映射的系统调用中，增加copy到进程kernel pagetable的代码。如下:  
  proc_kernel_uvmcopy():  
```C
// copy mappings for user space to proc's kernel pagetable
int
proc_kernel_uvmcopy(pagetable_t user_pagetbl, pagetable_t kernel_pagetbl, int oldsz, int newsz)
{
  uint64 a;
  uint64 pa;
  uint flags;
  pte_t *pte;
  if (newsz < oldsz)
    return -1;
  oldsz = PGROUNDUP(oldsz);
  for (a = oldsz; a < newsz; a += PGSIZE){
    if ((pte = walk(user_pagetbl, a, 0)) == 0){
      panic("proc_kernel_uvmcopy: no exist pte");
    }
    if ((*pte & PTE_V) == 0){
      panic("proc_kernel_uvmcopy: invalid pte");
    }
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    flags &= (~PTE_U);
    if (proc_kmappages(kernel_pagetbl, a, PGSIZE, pa, flags) != 0){
      uvmunmap(kernel_pagetbl, oldsz, (a-oldsz)/PGSIZE, 0);
      return -1;
    }
  }
  return 0;
}
```
  fork():  
  ```C
  //copy child user mappings to its kernel pagetable
  if (proc_kernel_uvmcopy(np->pagetable, np->kernel_pagetable, 0, np->sz) != 0){
    freeproc(np);
    release(&np->lock);
    return -1;   
  }
  ```  
  exec():  
  ```C
  // Commit to the user image.
  oldpagetable = p->pagetable;
  p->pagetable = pagetable;
  p->sz = sz;

  if (0 != proc_kernel_uvmcopy(p->pagetable, p->kernel_pagetable, 0, sz))
    goto bad;
  proc_kvminithart(p->kernel_pagetable);
  ```  
  growproc():
  ```C
  sz = p->sz;
  if(n > 0){
    if (sz + n >= PLIC){
      return -1;
    }
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
      return -1;
    }
    if (0 != proc_kernel_uvmcopy(p->pagetable, p->kernel_pagetable, p->sz, sz)){
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    if (sz < p->sz){
      uvmunmap(p->kernel_pagetable, PGROUNDUP(sz), (PGROUNDUP(p->sz)-PGROUNDUP(sz))/PGSIZE, 0);
    }
  }
  p->sz = sz;
  proc_kvminithart(p->kernel_pagetable);
  ```  
  3、userinit()中创建第一个进程的时候，也要执行2中的操作；  
  ```C
    proc_kernel_uvmcopy(p->pagetable, p->kernel_pagetable, 0, p->sz);
  ```
    
  
  
  
