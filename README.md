# xv6 lazy page allocation
## lab1: Eliminate allocation from sbrk()  
* 修改sbrk(n)系统调用，使得sbrk执行内存增长时，并不分配堆内存，只是将p->sz增加n，返回增加前的地址(即增加前的p->sz)。从而达到如下效果: 当进程访问这段实际未分配的内存时产生page fault。
* 很简单，不做多余描述。  
```C
uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  myproc()->sz += n; 
  //if(growproc(n) < 0)
  //  return -1;
  return addr;
}
```  

## lab2:  lazy allocation
* 修改trap.c完成lazy allocation的实现，当系统因lab1的修改产生page fault trap到内核时，针对lazy allocation的场景，判断是因为lazy allocation引起的page fault，则对产生page fault的地址所在的page申请物理pagetable,完成地址映射，返回到用户空间，再次执行，即可正常访问改内存。  
* 单纯完成lab2比较简单，但要完成一个完善的lazy allocation，需要考虑的特殊场景比较多，这会在lab3中有所体现。这里我们暂且不考虑一些特殊或边界情况，先完成lab2的基本功能，通过lab2的测试，然后在lab3中对程序进一步改写和完善。  
* 首先，我们要找到page fault对应的r_scause()的值，参考上一章的lab，syscall的trap reason是r_scause()==8，那么lazy allocation场景下的page fault的trap reason按照提示应该是13或15，我们可以通过《riscv-privileged》查table 4.2知道，13、15分别是load、store page fault。  
* STVAL寄存器中保存了引起page fault的虚拟地址，可通过r_stval()获取到，该地址所在的page首地址，可通过PGROUNDDOWN(va)得到。
* uvmunmap() 中对于虚拟地址映射不到的物理内存page，会panic，而对于lazy allocate的内存，若实际未使用到过，那么uvmunmap的时候映射不到其实是正常的，因此，这里我们需要修改，不能panic,而是对这样的情况直接continue即可。
* 代码如下：  
usertrap():
```C
} else if (r_scause() == 13 || (r_scause() == 15)){
    uint64 va = r_stval();
    //printf("page fault, va=%p\n", va);
    uint64 pa = (uint64)kalloc();
    if (pa == 0){
      p->killed = 1;
    }
    else {
      memset((void*)pa, 0, PGSIZE);
      va = PGROUNDDOWN(va);
      if(mappages(p->pagetable, va, PGSIZE, pa, PTE_W|PTE_R|PTE_U) != 0){
        kfree((void*)pa);
        p->killed = 1;
      }
    }
  }
```  
uvmunmap():  
```C
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    if((pte = walk(pagetable, a, 0)) == 0)
      continue;
    if((*pte & PTE_V) == 0)
      continue;
```
  
## lab3: lazytests and usertests  
* 如果我们直接用lab2的代码来跑lab3的测试，很明显是无法通过的，因为我们只完成了lazy allocation的基本功能，并没有考虑一些特殊场景或边界条件。因此，我们还需要对其进行完善。  
* 提示1： Handle negative sbrk() arguments，显然我们的lazy allocation只针对sbrk的参数n>0的情况，n<0时代表削减内存，这部分的原代码逻辑是应该保留的，因此，再次修改sys_sbrk，如下：  
```C
uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;

  if (n > 0){
    myproc()->sz += n; 
  }
  else {
    if(growproc(n) < 0)
      return -1;
  }

  return addr;
}
```  
* 提示2： Kill a process if it page-faults on a virtual memory address higher than any allocated with sbrk()。虚拟地址小于p->sz的堆内存，未映射到物理page的才是lazy allocation出来的，当虚拟地址va >= p->sz，则该地址并非已lazy分配的地址，即此时应该按通常的page fault处理，kill进程。  
* 提示3： Handle the parent-to-child memory copy in fork() correctly. fork()一个子进程时，子进程copy父进程的memory及映射关系。由于父进程采用了lazy allocation分配堆内存，那么属于父进程的有些虚拟地址实际是没有使用的，也就没有映射到物理内存，此时，执行uvmcopy时，若父进程的虚拟地址通过walk无法找到对于的物理page，则是lazy allocation引起的正常现象，故不能按原逻辑panic。 修改如下：  
```C
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walk(old, i, 0)) == 0)
      continue;
    if((*pte & PTE_V) == 0)
      continue;
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
      kfree(mem);
      goto err;
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
  return -1;
}
```  
* 提示4：Handle the case in which a process passes a valid address from sbrk() to a system call such as read or write, but the memory for that address has not yet been allocated.
* 这个相对难理解一点。这也是一种特殊情况。我们lab2中实现的lazy allocation中，对page fault的处理，只针对从用户空间访问lazy分配的地址，因为只有从用户空间trap到内核，才会进usertrap()，从而被我们捕捉到，进行相应的处理。对于read\write等system call，在sys_write/read()中访问lazy分配的地址，不会进usertrap，因为是在内核中触发的page fault。对于write、read系统调用，最终引起page fault的原因是，它们对于用户侧传下来的虚拟地址，必须先通过walkaddr查找到对应的物理地址，才能对其进行访问。而通过walkaddr，lazy分配的未使用内存虚拟地址是查不到映射的物理地址的（因为本来就没有为其映射物理page）。因此，这里我们需要把usertrap中的处理逻辑，移植一份到这个函数，即在walkaddr中完成这种情况下的物理内存分配和映射。  
```C
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    return 0;

  pte = walk(pagetable, va, 0);
  if((pte == 0) || ((*pte & PTE_V) == 0)){
    if ((va >= myproc()->sz) || va < PGROUNDUP(myproc()->trapframe->sp)){
      return 0;
    }
    pa = (uint64)kalloc();
    if (pa == 0){
      return 0;
    }
    else {
      memset((void*)pa, 0, PGSIZE);
      va = PGROUNDDOWN(va);
      if(mappages(myproc()->pagetable, va, PGSIZE, pa, PTE_W|PTE_R|PTE_U|PTE_X) != 0){
        kfree((void*)pa);
        return 0;
      }
    }        
    return pa;
  }

  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
```  
值得注意的是，这里有一个返回条件va < PGROUNDUP(myproc()->trapframe->sp)的意义是什么？我们随后解释。  
* 提示5：Handle out-of-memory correctly: if kalloc() fails in the page fault handler, kill the current process.  这条简单，代码中已有处理，即：  
```C
  } else if (r_scause() == 13 || (r_scause() == 15)){
    uint64 va = r_stval();
    //printf("page fault, va=%p\n", va);
    uint64 sp = p->trapframe->sp;
    if ((va >= p->sz) || (va < PGROUNDDOWN(sp))){
      p->killed = 1;
    }
    else{
      uint64 pa = (uint64)kalloc();
      if (pa == 0){
        p->killed = 1;
      }
```  
* 提示6：Handle faults on the invalid page below the user stack.
* 这里我们结合用户地址空间的分布来分析，如下：  
![](https://github.com/garylee-great/mit-xv6-labs-2020/blob/lazy/user_address_space.png)  
  用户进程的stack page下方有一个guard page，由于栈空间的地址增长方向是从高地址到低地址，也就是当栈溢出的时候，就会访问到guard page，此时也会产生page fault（guard page pte的flag PTE_U未置上，用户侧无法访问），但此时产生的page fault并不是lazy allocation引起的，因此不能让其进入lazy allocation的处理逻辑，故需要在usertrap()中加一个判断条件，即va属于guard page时kill进程。guard page紧临stack，因此guard page的va小于栈空间的最低地址。由于sp指针（寄存器）指向栈顶，PGROUNDDOWN(sp)即栈空间的最低地址。  
```C
  } else if (r_scause() == 13 || (r_scause() == 15)){
    uint64 va = r_stval();
    //printf("page fault, va=%p\n", va);
    uint64 sp = p->trapframe->sp;
    if ((va >= p->sz) || (va < PGROUNDDOWN(sp))){
      p->killed = 1;
    }
```
  现在我们再来解释一下提示4中，va < PGROUNDUP(myproc()->trapframe->sp)这个判断条件的意义，在walkaddr中，我们只针对lazy allocate的地址做处理，而这部分地址属于堆内存（heap），因此位于栈空间（stack）的地址不应该进入这段逻辑，而是应该按照原逻辑，直接return 0。
  最后，还有一个有意思的点，那就是p->sz，其实是除了trappoline page和trapframe page以外，用户进程使用到的虚拟地址上限，这也是为什么uvmfree()会按如下方式实现：  
```C
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
  if(sz > 0)
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
}
```  
  当然，这个点跟题目没有什么关系，只是题外话。
 



