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
  
