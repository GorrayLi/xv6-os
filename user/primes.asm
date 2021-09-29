
user/_primes:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <child_process>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void child_process(int *p)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
   a:	84aa                	mv	s1,a0
    int pp[2];
    int prime;
    int num;
    int ret;

    close(p[1]);
   c:	4148                	lw	a0,4(a0)
   e:	00000097          	auipc	ra,0x0
  12:	41e080e7          	jalr	1054(ra) # 42c <close>
    //terminate condition
    ret = read(p[0], &prime, sizeof(int));
  16:	4611                	li	a2,4
  18:	fd440593          	addi	a1,s0,-44
  1c:	4088                	lw	a0,0(s1)
  1e:	00000097          	auipc	ra,0x0
  22:	3fe080e7          	jalr	1022(ra) # 41c <read>
    if (ret == 0){
  26:	e919                	bnez	a0,3c <child_process+0x3c>
        close(p[0]);
  28:	4088                	lw	a0,0(s1)
  2a:	00000097          	auipc	ra,0x0
  2e:	402080e7          	jalr	1026(ra) # 42c <close>
        exit(0);
  32:	4501                	li	a0,0
  34:	00000097          	auipc	ra,0x0
  38:	3d0080e7          	jalr	976(ra) # 404 <exit>
    }
    printf("prime %d\n", prime);
  3c:	fd442583          	lw	a1,-44(s0)
  40:	00001517          	auipc	a0,0x1
  44:	8e050513          	addi	a0,a0,-1824 # 920 <malloc+0xe6>
  48:	00000097          	auipc	ra,0x0
  4c:	734080e7          	jalr	1844(ra) # 77c <printf>

    pipe(pp);
  50:	fd840513          	addi	a0,s0,-40
  54:	00000097          	auipc	ra,0x0
  58:	3c0080e7          	jalr	960(ra) # 414 <pipe>
    if (fork() == 0){
  5c:	00000097          	auipc	ra,0x0
  60:	3a0080e7          	jalr	928(ra) # 3fc <fork>
  64:	ed01                	bnez	a0,7c <child_process+0x7c>
        close(p[0]);
  66:	4088                	lw	a0,0(s1)
  68:	00000097          	auipc	ra,0x0
  6c:	3c4080e7          	jalr	964(ra) # 42c <close>
        child_process(pp);
  70:	fd840513          	addi	a0,s0,-40
  74:	00000097          	auipc	ra,0x0
  78:	f8c080e7          	jalr	-116(ra) # 0 <child_process>
    }
    else{
        close(pp[0]);
  7c:	fd842503          	lw	a0,-40(s0)
  80:	00000097          	auipc	ra,0x0
  84:	3ac080e7          	jalr	940(ra) # 42c <close>
        while(read(p[0], &num, sizeof(int))){
  88:	4611                	li	a2,4
  8a:	fd040593          	addi	a1,s0,-48
  8e:	4088                	lw	a0,0(s1)
  90:	00000097          	auipc	ra,0x0
  94:	38c080e7          	jalr	908(ra) # 41c <read>
  98:	c115                	beqz	a0,bc <child_process+0xbc>
            if (num % prime != 0){
  9a:	fd042783          	lw	a5,-48(s0)
  9e:	fd442703          	lw	a4,-44(s0)
  a2:	02e7e7bb          	remw	a5,a5,a4
  a6:	d3ed                	beqz	a5,88 <child_process+0x88>
                write(pp[1], &num, sizeof(int));
  a8:	4611                	li	a2,4
  aa:	fd040593          	addi	a1,s0,-48
  ae:	fdc42503          	lw	a0,-36(s0)
  b2:	00000097          	auipc	ra,0x0
  b6:	372080e7          	jalr	882(ra) # 424 <write>
  ba:	b7f9                	j	88 <child_process+0x88>
            }
        }
        close(pp[1]);
  bc:	fdc42503          	lw	a0,-36(s0)
  c0:	00000097          	auipc	ra,0x0
  c4:	36c080e7          	jalr	876(ra) # 42c <close>
        close(p[0]);
  c8:	4088                	lw	a0,0(s1)
  ca:	00000097          	auipc	ra,0x0
  ce:	362080e7          	jalr	866(ra) # 42c <close>
        wait(0);
  d2:	4501                	li	a0,0
  d4:	00000097          	auipc	ra,0x0
  d8:	338080e7          	jalr	824(ra) # 40c <wait>
    }
    exit(0);
  dc:	4501                	li	a0,0
  de:	00000097          	auipc	ra,0x0
  e2:	326080e7          	jalr	806(ra) # 404 <exit>

00000000000000e6 <main>:
}

int main(int argc, char* argv[])
{
  e6:	7179                	addi	sp,sp,-48
  e8:	f406                	sd	ra,40(sp)
  ea:	f022                	sd	s0,32(sp)
  ec:	ec26                	sd	s1,24(sp)
  ee:	1800                	addi	s0,sp,48
    int p[2];
    int num;

    if (argc > 1){
  f0:	4785                	li	a5,1
  f2:	02a7d063          	bge	a5,a0,112 <main+0x2c>
        fprintf(2,"usage: primes\n");
  f6:	00001597          	auipc	a1,0x1
  fa:	83a58593          	addi	a1,a1,-1990 # 930 <malloc+0xf6>
  fe:	4509                	li	a0,2
 100:	00000097          	auipc	ra,0x0
 104:	64e080e7          	jalr	1614(ra) # 74e <fprintf>
        exit(1);
 108:	4505                	li	a0,1
 10a:	00000097          	auipc	ra,0x0
 10e:	2fa080e7          	jalr	762(ra) # 404 <exit>
    }

    pipe(p);
 112:	fd840513          	addi	a0,s0,-40
 116:	00000097          	auipc	ra,0x0
 11a:	2fe080e7          	jalr	766(ra) # 414 <pipe>
    if (fork() == 0){
 11e:	00000097          	auipc	ra,0x0
 122:	2de080e7          	jalr	734(ra) # 3fc <fork>
 126:	e519                	bnez	a0,134 <main+0x4e>
        child_process(p);
 128:	fd840513          	addi	a0,s0,-40
 12c:	00000097          	auipc	ra,0x0
 130:	ed4080e7          	jalr	-300(ra) # 0 <child_process>
    }
    else{
        close(p[0]);
 134:	fd842503          	lw	a0,-40(s0)
 138:	00000097          	auipc	ra,0x0
 13c:	2f4080e7          	jalr	756(ra) # 42c <close>
        for (num=2; num<=35; num++)
 140:	4789                	li	a5,2
 142:	fcf42a23          	sw	a5,-44(s0)
 146:	02300493          	li	s1,35
        {
            write(p[1], &num, sizeof(int));
 14a:	4611                	li	a2,4
 14c:	fd440593          	addi	a1,s0,-44
 150:	fdc42503          	lw	a0,-36(s0)
 154:	00000097          	auipc	ra,0x0
 158:	2d0080e7          	jalr	720(ra) # 424 <write>
        for (num=2; num<=35; num++)
 15c:	fd442783          	lw	a5,-44(s0)
 160:	2785                	addiw	a5,a5,1
 162:	0007871b          	sext.w	a4,a5
 166:	fcf42a23          	sw	a5,-44(s0)
 16a:	fee4d0e3          	bge	s1,a4,14a <main+0x64>
        }
        close(p[1]);
 16e:	fdc42503          	lw	a0,-36(s0)
 172:	00000097          	auipc	ra,0x0
 176:	2ba080e7          	jalr	698(ra) # 42c <close>
        wait(0);
 17a:	4501                	li	a0,0
 17c:	00000097          	auipc	ra,0x0
 180:	290080e7          	jalr	656(ra) # 40c <wait>
    }

    exit(0);
 184:	4501                	li	a0,0
 186:	00000097          	auipc	ra,0x0
 18a:	27e080e7          	jalr	638(ra) # 404 <exit>

000000000000018e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 18e:	1141                	addi	sp,sp,-16
 190:	e422                	sd	s0,8(sp)
 192:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 194:	87aa                	mv	a5,a0
 196:	0585                	addi	a1,a1,1
 198:	0785                	addi	a5,a5,1
 19a:	fff5c703          	lbu	a4,-1(a1)
 19e:	fee78fa3          	sb	a4,-1(a5)
 1a2:	fb75                	bnez	a4,196 <strcpy+0x8>
    ;
  return os;
}
 1a4:	6422                	ld	s0,8(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret

00000000000001aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	cb91                	beqz	a5,1c8 <strcmp+0x1e>
 1b6:	0005c703          	lbu	a4,0(a1)
 1ba:	00f71763          	bne	a4,a5,1c8 <strcmp+0x1e>
    p++, q++;
 1be:	0505                	addi	a0,a0,1
 1c0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1c2:	00054783          	lbu	a5,0(a0)
 1c6:	fbe5                	bnez	a5,1b6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1c8:	0005c503          	lbu	a0,0(a1)
}
 1cc:	40a7853b          	subw	a0,a5,a0
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret

00000000000001d6 <strlen>:

uint
strlen(const char *s)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	cf91                	beqz	a5,1fc <strlen+0x26>
 1e2:	0505                	addi	a0,a0,1
 1e4:	87aa                	mv	a5,a0
 1e6:	4685                	li	a3,1
 1e8:	9e89                	subw	a3,a3,a0
 1ea:	00f6853b          	addw	a0,a3,a5
 1ee:	0785                	addi	a5,a5,1
 1f0:	fff7c703          	lbu	a4,-1(a5)
 1f4:	fb7d                	bnez	a4,1ea <strlen+0x14>
    ;
  return n;
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
  for(n = 0; s[n]; n++)
 1fc:	4501                	li	a0,0
 1fe:	bfe5                	j	1f6 <strlen+0x20>

0000000000000200 <memset>:

void*
memset(void *dst, int c, uint n)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 206:	ce09                	beqz	a2,220 <memset+0x20>
 208:	87aa                	mv	a5,a0
 20a:	fff6071b          	addiw	a4,a2,-1
 20e:	1702                	slli	a4,a4,0x20
 210:	9301                	srli	a4,a4,0x20
 212:	0705                	addi	a4,a4,1
 214:	972a                	add	a4,a4,a0
    cdst[i] = c;
 216:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 21a:	0785                	addi	a5,a5,1
 21c:	fee79de3          	bne	a5,a4,216 <memset+0x16>
  }
  return dst;
}
 220:	6422                	ld	s0,8(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret

0000000000000226 <strchr>:

char*
strchr(const char *s, char c)
{
 226:	1141                	addi	sp,sp,-16
 228:	e422                	sd	s0,8(sp)
 22a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 22c:	00054783          	lbu	a5,0(a0)
 230:	cb99                	beqz	a5,246 <strchr+0x20>
    if(*s == c)
 232:	00f58763          	beq	a1,a5,240 <strchr+0x1a>
  for(; *s; s++)
 236:	0505                	addi	a0,a0,1
 238:	00054783          	lbu	a5,0(a0)
 23c:	fbfd                	bnez	a5,232 <strchr+0xc>
      return (char*)s;
  return 0;
 23e:	4501                	li	a0,0
}
 240:	6422                	ld	s0,8(sp)
 242:	0141                	addi	sp,sp,16
 244:	8082                	ret
  return 0;
 246:	4501                	li	a0,0
 248:	bfe5                	j	240 <strchr+0x1a>

000000000000024a <gets>:

char*
gets(char *buf, int max)
{
 24a:	711d                	addi	sp,sp,-96
 24c:	ec86                	sd	ra,88(sp)
 24e:	e8a2                	sd	s0,80(sp)
 250:	e4a6                	sd	s1,72(sp)
 252:	e0ca                	sd	s2,64(sp)
 254:	fc4e                	sd	s3,56(sp)
 256:	f852                	sd	s4,48(sp)
 258:	f456                	sd	s5,40(sp)
 25a:	f05a                	sd	s6,32(sp)
 25c:	ec5e                	sd	s7,24(sp)
 25e:	1080                	addi	s0,sp,96
 260:	8baa                	mv	s7,a0
 262:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 264:	892a                	mv	s2,a0
 266:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 268:	4aa9                	li	s5,10
 26a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 26c:	89a6                	mv	s3,s1
 26e:	2485                	addiw	s1,s1,1
 270:	0344d863          	bge	s1,s4,2a0 <gets+0x56>
    cc = read(0, &c, 1);
 274:	4605                	li	a2,1
 276:	faf40593          	addi	a1,s0,-81
 27a:	4501                	li	a0,0
 27c:	00000097          	auipc	ra,0x0
 280:	1a0080e7          	jalr	416(ra) # 41c <read>
    if(cc < 1)
 284:	00a05e63          	blez	a0,2a0 <gets+0x56>
    buf[i++] = c;
 288:	faf44783          	lbu	a5,-81(s0)
 28c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 290:	01578763          	beq	a5,s5,29e <gets+0x54>
 294:	0905                	addi	s2,s2,1
 296:	fd679be3          	bne	a5,s6,26c <gets+0x22>
  for(i=0; i+1 < max; ){
 29a:	89a6                	mv	s3,s1
 29c:	a011                	j	2a0 <gets+0x56>
 29e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a0:	99de                	add	s3,s3,s7
 2a2:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a6:	855e                	mv	a0,s7
 2a8:	60e6                	ld	ra,88(sp)
 2aa:	6446                	ld	s0,80(sp)
 2ac:	64a6                	ld	s1,72(sp)
 2ae:	6906                	ld	s2,64(sp)
 2b0:	79e2                	ld	s3,56(sp)
 2b2:	7a42                	ld	s4,48(sp)
 2b4:	7aa2                	ld	s5,40(sp)
 2b6:	7b02                	ld	s6,32(sp)
 2b8:	6be2                	ld	s7,24(sp)
 2ba:	6125                	addi	sp,sp,96
 2bc:	8082                	ret

00000000000002be <stat>:

int
stat(const char *n, struct stat *st)
{
 2be:	1101                	addi	sp,sp,-32
 2c0:	ec06                	sd	ra,24(sp)
 2c2:	e822                	sd	s0,16(sp)
 2c4:	e426                	sd	s1,8(sp)
 2c6:	e04a                	sd	s2,0(sp)
 2c8:	1000                	addi	s0,sp,32
 2ca:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2cc:	4581                	li	a1,0
 2ce:	00000097          	auipc	ra,0x0
 2d2:	176080e7          	jalr	374(ra) # 444 <open>
  if(fd < 0)
 2d6:	02054563          	bltz	a0,300 <stat+0x42>
 2da:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2dc:	85ca                	mv	a1,s2
 2de:	00000097          	auipc	ra,0x0
 2e2:	17e080e7          	jalr	382(ra) # 45c <fstat>
 2e6:	892a                	mv	s2,a0
  close(fd);
 2e8:	8526                	mv	a0,s1
 2ea:	00000097          	auipc	ra,0x0
 2ee:	142080e7          	jalr	322(ra) # 42c <close>
  return r;
}
 2f2:	854a                	mv	a0,s2
 2f4:	60e2                	ld	ra,24(sp)
 2f6:	6442                	ld	s0,16(sp)
 2f8:	64a2                	ld	s1,8(sp)
 2fa:	6902                	ld	s2,0(sp)
 2fc:	6105                	addi	sp,sp,32
 2fe:	8082                	ret
    return -1;
 300:	597d                	li	s2,-1
 302:	bfc5                	j	2f2 <stat+0x34>

0000000000000304 <atoi>:

int
atoi(const char *s)
{
 304:	1141                	addi	sp,sp,-16
 306:	e422                	sd	s0,8(sp)
 308:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 30a:	00054603          	lbu	a2,0(a0)
 30e:	fd06079b          	addiw	a5,a2,-48
 312:	0ff7f793          	andi	a5,a5,255
 316:	4725                	li	a4,9
 318:	02f76963          	bltu	a4,a5,34a <atoi+0x46>
 31c:	86aa                	mv	a3,a0
  n = 0;
 31e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 320:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 322:	0685                	addi	a3,a3,1
 324:	0025179b          	slliw	a5,a0,0x2
 328:	9fa9                	addw	a5,a5,a0
 32a:	0017979b          	slliw	a5,a5,0x1
 32e:	9fb1                	addw	a5,a5,a2
 330:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 334:	0006c603          	lbu	a2,0(a3)
 338:	fd06071b          	addiw	a4,a2,-48
 33c:	0ff77713          	andi	a4,a4,255
 340:	fee5f1e3          	bgeu	a1,a4,322 <atoi+0x1e>
  return n;
}
 344:	6422                	ld	s0,8(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret
  n = 0;
 34a:	4501                	li	a0,0
 34c:	bfe5                	j	344 <atoi+0x40>

000000000000034e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 34e:	1141                	addi	sp,sp,-16
 350:	e422                	sd	s0,8(sp)
 352:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 354:	02b57663          	bgeu	a0,a1,380 <memmove+0x32>
    while(n-- > 0)
 358:	02c05163          	blez	a2,37a <memmove+0x2c>
 35c:	fff6079b          	addiw	a5,a2,-1
 360:	1782                	slli	a5,a5,0x20
 362:	9381                	srli	a5,a5,0x20
 364:	0785                	addi	a5,a5,1
 366:	97aa                	add	a5,a5,a0
  dst = vdst;
 368:	872a                	mv	a4,a0
      *dst++ = *src++;
 36a:	0585                	addi	a1,a1,1
 36c:	0705                	addi	a4,a4,1
 36e:	fff5c683          	lbu	a3,-1(a1)
 372:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 376:	fee79ae3          	bne	a5,a4,36a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 37a:	6422                	ld	s0,8(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret
    dst += n;
 380:	00c50733          	add	a4,a0,a2
    src += n;
 384:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 386:	fec05ae3          	blez	a2,37a <memmove+0x2c>
 38a:	fff6079b          	addiw	a5,a2,-1
 38e:	1782                	slli	a5,a5,0x20
 390:	9381                	srli	a5,a5,0x20
 392:	fff7c793          	not	a5,a5
 396:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 398:	15fd                	addi	a1,a1,-1
 39a:	177d                	addi	a4,a4,-1
 39c:	0005c683          	lbu	a3,0(a1)
 3a0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3a4:	fee79ae3          	bne	a5,a4,398 <memmove+0x4a>
 3a8:	bfc9                	j	37a <memmove+0x2c>

00000000000003aa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3aa:	1141                	addi	sp,sp,-16
 3ac:	e422                	sd	s0,8(sp)
 3ae:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3b0:	ca05                	beqz	a2,3e0 <memcmp+0x36>
 3b2:	fff6069b          	addiw	a3,a2,-1
 3b6:	1682                	slli	a3,a3,0x20
 3b8:	9281                	srli	a3,a3,0x20
 3ba:	0685                	addi	a3,a3,1
 3bc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3be:	00054783          	lbu	a5,0(a0)
 3c2:	0005c703          	lbu	a4,0(a1)
 3c6:	00e79863          	bne	a5,a4,3d6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ca:	0505                	addi	a0,a0,1
    p2++;
 3cc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3ce:	fed518e3          	bne	a0,a3,3be <memcmp+0x14>
  }
  return 0;
 3d2:	4501                	li	a0,0
 3d4:	a019                	j	3da <memcmp+0x30>
      return *p1 - *p2;
 3d6:	40e7853b          	subw	a0,a5,a4
}
 3da:	6422                	ld	s0,8(sp)
 3dc:	0141                	addi	sp,sp,16
 3de:	8082                	ret
  return 0;
 3e0:	4501                	li	a0,0
 3e2:	bfe5                	j	3da <memcmp+0x30>

00000000000003e4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3e4:	1141                	addi	sp,sp,-16
 3e6:	e406                	sd	ra,8(sp)
 3e8:	e022                	sd	s0,0(sp)
 3ea:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ec:	00000097          	auipc	ra,0x0
 3f0:	f62080e7          	jalr	-158(ra) # 34e <memmove>
}
 3f4:	60a2                	ld	ra,8(sp)
 3f6:	6402                	ld	s0,0(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret

00000000000003fc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3fc:	4885                	li	a7,1
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <exit>:
.global exit
exit:
 li a7, SYS_exit
 404:	4889                	li	a7,2
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <wait>:
.global wait
wait:
 li a7, SYS_wait
 40c:	488d                	li	a7,3
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 414:	4891                	li	a7,4
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <read>:
.global read
read:
 li a7, SYS_read
 41c:	4895                	li	a7,5
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <write>:
.global write
write:
 li a7, SYS_write
 424:	48c1                	li	a7,16
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <close>:
.global close
close:
 li a7, SYS_close
 42c:	48d5                	li	a7,21
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <kill>:
.global kill
kill:
 li a7, SYS_kill
 434:	4899                	li	a7,6
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <exec>:
.global exec
exec:
 li a7, SYS_exec
 43c:	489d                	li	a7,7
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <open>:
.global open
open:
 li a7, SYS_open
 444:	48bd                	li	a7,15
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 44c:	48c5                	li	a7,17
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 454:	48c9                	li	a7,18
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 45c:	48a1                	li	a7,8
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <link>:
.global link
link:
 li a7, SYS_link
 464:	48cd                	li	a7,19
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 46c:	48d1                	li	a7,20
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 474:	48a5                	li	a7,9
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <dup>:
.global dup
dup:
 li a7, SYS_dup
 47c:	48a9                	li	a7,10
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 484:	48ad                	li	a7,11
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 48c:	48b1                	li	a7,12
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 494:	48b5                	li	a7,13
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 49c:	48b9                	li	a7,14
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4a4:	1101                	addi	sp,sp,-32
 4a6:	ec06                	sd	ra,24(sp)
 4a8:	e822                	sd	s0,16(sp)
 4aa:	1000                	addi	s0,sp,32
 4ac:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4b0:	4605                	li	a2,1
 4b2:	fef40593          	addi	a1,s0,-17
 4b6:	00000097          	auipc	ra,0x0
 4ba:	f6e080e7          	jalr	-146(ra) # 424 <write>
}
 4be:	60e2                	ld	ra,24(sp)
 4c0:	6442                	ld	s0,16(sp)
 4c2:	6105                	addi	sp,sp,32
 4c4:	8082                	ret

00000000000004c6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4c6:	7139                	addi	sp,sp,-64
 4c8:	fc06                	sd	ra,56(sp)
 4ca:	f822                	sd	s0,48(sp)
 4cc:	f426                	sd	s1,40(sp)
 4ce:	f04a                	sd	s2,32(sp)
 4d0:	ec4e                	sd	s3,24(sp)
 4d2:	0080                	addi	s0,sp,64
 4d4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4d6:	c299                	beqz	a3,4dc <printint+0x16>
 4d8:	0805c863          	bltz	a1,568 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4dc:	2581                	sext.w	a1,a1
  neg = 0;
 4de:	4881                	li	a7,0
 4e0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4e4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4e6:	2601                	sext.w	a2,a2
 4e8:	00000517          	auipc	a0,0x0
 4ec:	46050513          	addi	a0,a0,1120 # 948 <digits>
 4f0:	883a                	mv	a6,a4
 4f2:	2705                	addiw	a4,a4,1
 4f4:	02c5f7bb          	remuw	a5,a1,a2
 4f8:	1782                	slli	a5,a5,0x20
 4fa:	9381                	srli	a5,a5,0x20
 4fc:	97aa                	add	a5,a5,a0
 4fe:	0007c783          	lbu	a5,0(a5)
 502:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 506:	0005879b          	sext.w	a5,a1
 50a:	02c5d5bb          	divuw	a1,a1,a2
 50e:	0685                	addi	a3,a3,1
 510:	fec7f0e3          	bgeu	a5,a2,4f0 <printint+0x2a>
  if(neg)
 514:	00088b63          	beqz	a7,52a <printint+0x64>
    buf[i++] = '-';
 518:	fd040793          	addi	a5,s0,-48
 51c:	973e                	add	a4,a4,a5
 51e:	02d00793          	li	a5,45
 522:	fef70823          	sb	a5,-16(a4)
 526:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 52a:	02e05863          	blez	a4,55a <printint+0x94>
 52e:	fc040793          	addi	a5,s0,-64
 532:	00e78933          	add	s2,a5,a4
 536:	fff78993          	addi	s3,a5,-1
 53a:	99ba                	add	s3,s3,a4
 53c:	377d                	addiw	a4,a4,-1
 53e:	1702                	slli	a4,a4,0x20
 540:	9301                	srli	a4,a4,0x20
 542:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 546:	fff94583          	lbu	a1,-1(s2)
 54a:	8526                	mv	a0,s1
 54c:	00000097          	auipc	ra,0x0
 550:	f58080e7          	jalr	-168(ra) # 4a4 <putc>
  while(--i >= 0)
 554:	197d                	addi	s2,s2,-1
 556:	ff3918e3          	bne	s2,s3,546 <printint+0x80>
}
 55a:	70e2                	ld	ra,56(sp)
 55c:	7442                	ld	s0,48(sp)
 55e:	74a2                	ld	s1,40(sp)
 560:	7902                	ld	s2,32(sp)
 562:	69e2                	ld	s3,24(sp)
 564:	6121                	addi	sp,sp,64
 566:	8082                	ret
    x = -xx;
 568:	40b005bb          	negw	a1,a1
    neg = 1;
 56c:	4885                	li	a7,1
    x = -xx;
 56e:	bf8d                	j	4e0 <printint+0x1a>

0000000000000570 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 570:	7119                	addi	sp,sp,-128
 572:	fc86                	sd	ra,120(sp)
 574:	f8a2                	sd	s0,112(sp)
 576:	f4a6                	sd	s1,104(sp)
 578:	f0ca                	sd	s2,96(sp)
 57a:	ecce                	sd	s3,88(sp)
 57c:	e8d2                	sd	s4,80(sp)
 57e:	e4d6                	sd	s5,72(sp)
 580:	e0da                	sd	s6,64(sp)
 582:	fc5e                	sd	s7,56(sp)
 584:	f862                	sd	s8,48(sp)
 586:	f466                	sd	s9,40(sp)
 588:	f06a                	sd	s10,32(sp)
 58a:	ec6e                	sd	s11,24(sp)
 58c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 58e:	0005c903          	lbu	s2,0(a1)
 592:	18090f63          	beqz	s2,730 <vprintf+0x1c0>
 596:	8aaa                	mv	s5,a0
 598:	8b32                	mv	s6,a2
 59a:	00158493          	addi	s1,a1,1
  state = 0;
 59e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5a0:	02500a13          	li	s4,37
      if(c == 'd'){
 5a4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5a8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5ac:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5b0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5b4:	00000b97          	auipc	s7,0x0
 5b8:	394b8b93          	addi	s7,s7,916 # 948 <digits>
 5bc:	a839                	j	5da <vprintf+0x6a>
        putc(fd, c);
 5be:	85ca                	mv	a1,s2
 5c0:	8556                	mv	a0,s5
 5c2:	00000097          	auipc	ra,0x0
 5c6:	ee2080e7          	jalr	-286(ra) # 4a4 <putc>
 5ca:	a019                	j	5d0 <vprintf+0x60>
    } else if(state == '%'){
 5cc:	01498f63          	beq	s3,s4,5ea <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5d0:	0485                	addi	s1,s1,1
 5d2:	fff4c903          	lbu	s2,-1(s1)
 5d6:	14090d63          	beqz	s2,730 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5da:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5de:	fe0997e3          	bnez	s3,5cc <vprintf+0x5c>
      if(c == '%'){
 5e2:	fd479ee3          	bne	a5,s4,5be <vprintf+0x4e>
        state = '%';
 5e6:	89be                	mv	s3,a5
 5e8:	b7e5                	j	5d0 <vprintf+0x60>
      if(c == 'd'){
 5ea:	05878063          	beq	a5,s8,62a <vprintf+0xba>
      } else if(c == 'l') {
 5ee:	05978c63          	beq	a5,s9,646 <vprintf+0xd6>
      } else if(c == 'x') {
 5f2:	07a78863          	beq	a5,s10,662 <vprintf+0xf2>
      } else if(c == 'p') {
 5f6:	09b78463          	beq	a5,s11,67e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5fa:	07300713          	li	a4,115
 5fe:	0ce78663          	beq	a5,a4,6ca <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 602:	06300713          	li	a4,99
 606:	0ee78e63          	beq	a5,a4,702 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 60a:	11478863          	beq	a5,s4,71a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 60e:	85d2                	mv	a1,s4
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	e92080e7          	jalr	-366(ra) # 4a4 <putc>
        putc(fd, c);
 61a:	85ca                	mv	a1,s2
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	e86080e7          	jalr	-378(ra) # 4a4 <putc>
      }
      state = 0;
 626:	4981                	li	s3,0
 628:	b765                	j	5d0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 62a:	008b0913          	addi	s2,s6,8
 62e:	4685                	li	a3,1
 630:	4629                	li	a2,10
 632:	000b2583          	lw	a1,0(s6)
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	e8e080e7          	jalr	-370(ra) # 4c6 <printint>
 640:	8b4a                	mv	s6,s2
      state = 0;
 642:	4981                	li	s3,0
 644:	b771                	j	5d0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 646:	008b0913          	addi	s2,s6,8
 64a:	4681                	li	a3,0
 64c:	4629                	li	a2,10
 64e:	000b2583          	lw	a1,0(s6)
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	e72080e7          	jalr	-398(ra) # 4c6 <printint>
 65c:	8b4a                	mv	s6,s2
      state = 0;
 65e:	4981                	li	s3,0
 660:	bf85                	j	5d0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 662:	008b0913          	addi	s2,s6,8
 666:	4681                	li	a3,0
 668:	4641                	li	a2,16
 66a:	000b2583          	lw	a1,0(s6)
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	e56080e7          	jalr	-426(ra) # 4c6 <printint>
 678:	8b4a                	mv	s6,s2
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bf91                	j	5d0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 67e:	008b0793          	addi	a5,s6,8
 682:	f8f43423          	sd	a5,-120(s0)
 686:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 68a:	03000593          	li	a1,48
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	e14080e7          	jalr	-492(ra) # 4a4 <putc>
  putc(fd, 'x');
 698:	85ea                	mv	a1,s10
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	e08080e7          	jalr	-504(ra) # 4a4 <putc>
 6a4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a6:	03c9d793          	srli	a5,s3,0x3c
 6aa:	97de                	add	a5,a5,s7
 6ac:	0007c583          	lbu	a1,0(a5)
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	df2080e7          	jalr	-526(ra) # 4a4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ba:	0992                	slli	s3,s3,0x4
 6bc:	397d                	addiw	s2,s2,-1
 6be:	fe0914e3          	bnez	s2,6a6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6c2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b721                	j	5d0 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ca:	008b0993          	addi	s3,s6,8
 6ce:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6d2:	02090163          	beqz	s2,6f4 <vprintf+0x184>
        while(*s != 0){
 6d6:	00094583          	lbu	a1,0(s2)
 6da:	c9a1                	beqz	a1,72a <vprintf+0x1ba>
          putc(fd, *s);
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	dc6080e7          	jalr	-570(ra) # 4a4 <putc>
          s++;
 6e6:	0905                	addi	s2,s2,1
        while(*s != 0){
 6e8:	00094583          	lbu	a1,0(s2)
 6ec:	f9e5                	bnez	a1,6dc <vprintf+0x16c>
        s = va_arg(ap, char*);
 6ee:	8b4e                	mv	s6,s3
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	bdf9                	j	5d0 <vprintf+0x60>
          s = "(null)";
 6f4:	00000917          	auipc	s2,0x0
 6f8:	24c90913          	addi	s2,s2,588 # 940 <malloc+0x106>
        while(*s != 0){
 6fc:	02800593          	li	a1,40
 700:	bff1                	j	6dc <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 702:	008b0913          	addi	s2,s6,8
 706:	000b4583          	lbu	a1,0(s6)
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	d98080e7          	jalr	-616(ra) # 4a4 <putc>
 714:	8b4a                	mv	s6,s2
      state = 0;
 716:	4981                	li	s3,0
 718:	bd65                	j	5d0 <vprintf+0x60>
        putc(fd, c);
 71a:	85d2                	mv	a1,s4
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	d86080e7          	jalr	-634(ra) # 4a4 <putc>
      state = 0;
 726:	4981                	li	s3,0
 728:	b565                	j	5d0 <vprintf+0x60>
        s = va_arg(ap, char*);
 72a:	8b4e                	mv	s6,s3
      state = 0;
 72c:	4981                	li	s3,0
 72e:	b54d                	j	5d0 <vprintf+0x60>
    }
  }
}
 730:	70e6                	ld	ra,120(sp)
 732:	7446                	ld	s0,112(sp)
 734:	74a6                	ld	s1,104(sp)
 736:	7906                	ld	s2,96(sp)
 738:	69e6                	ld	s3,88(sp)
 73a:	6a46                	ld	s4,80(sp)
 73c:	6aa6                	ld	s5,72(sp)
 73e:	6b06                	ld	s6,64(sp)
 740:	7be2                	ld	s7,56(sp)
 742:	7c42                	ld	s8,48(sp)
 744:	7ca2                	ld	s9,40(sp)
 746:	7d02                	ld	s10,32(sp)
 748:	6de2                	ld	s11,24(sp)
 74a:	6109                	addi	sp,sp,128
 74c:	8082                	ret

000000000000074e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 74e:	715d                	addi	sp,sp,-80
 750:	ec06                	sd	ra,24(sp)
 752:	e822                	sd	s0,16(sp)
 754:	1000                	addi	s0,sp,32
 756:	e010                	sd	a2,0(s0)
 758:	e414                	sd	a3,8(s0)
 75a:	e818                	sd	a4,16(s0)
 75c:	ec1c                	sd	a5,24(s0)
 75e:	03043023          	sd	a6,32(s0)
 762:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 766:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 76a:	8622                	mv	a2,s0
 76c:	00000097          	auipc	ra,0x0
 770:	e04080e7          	jalr	-508(ra) # 570 <vprintf>
}
 774:	60e2                	ld	ra,24(sp)
 776:	6442                	ld	s0,16(sp)
 778:	6161                	addi	sp,sp,80
 77a:	8082                	ret

000000000000077c <printf>:

void
printf(const char *fmt, ...)
{
 77c:	711d                	addi	sp,sp,-96
 77e:	ec06                	sd	ra,24(sp)
 780:	e822                	sd	s0,16(sp)
 782:	1000                	addi	s0,sp,32
 784:	e40c                	sd	a1,8(s0)
 786:	e810                	sd	a2,16(s0)
 788:	ec14                	sd	a3,24(s0)
 78a:	f018                	sd	a4,32(s0)
 78c:	f41c                	sd	a5,40(s0)
 78e:	03043823          	sd	a6,48(s0)
 792:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 796:	00840613          	addi	a2,s0,8
 79a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 79e:	85aa                	mv	a1,a0
 7a0:	4505                	li	a0,1
 7a2:	00000097          	auipc	ra,0x0
 7a6:	dce080e7          	jalr	-562(ra) # 570 <vprintf>
}
 7aa:	60e2                	ld	ra,24(sp)
 7ac:	6442                	ld	s0,16(sp)
 7ae:	6125                	addi	sp,sp,96
 7b0:	8082                	ret

00000000000007b2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b2:	1141                	addi	sp,sp,-16
 7b4:	e422                	sd	s0,8(sp)
 7b6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bc:	00000797          	auipc	a5,0x0
 7c0:	1a47b783          	ld	a5,420(a5) # 960 <freep>
 7c4:	a805                	j	7f4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c6:	4618                	lw	a4,8(a2)
 7c8:	9db9                	addw	a1,a1,a4
 7ca:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ce:	6398                	ld	a4,0(a5)
 7d0:	6318                	ld	a4,0(a4)
 7d2:	fee53823          	sd	a4,-16(a0)
 7d6:	a091                	j	81a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7d8:	ff852703          	lw	a4,-8(a0)
 7dc:	9e39                	addw	a2,a2,a4
 7de:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7e0:	ff053703          	ld	a4,-16(a0)
 7e4:	e398                	sd	a4,0(a5)
 7e6:	a099                	j	82c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e8:	6398                	ld	a4,0(a5)
 7ea:	00e7e463          	bltu	a5,a4,7f2 <free+0x40>
 7ee:	00e6ea63          	bltu	a3,a4,802 <free+0x50>
{
 7f2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f4:	fed7fae3          	bgeu	a5,a3,7e8 <free+0x36>
 7f8:	6398                	ld	a4,0(a5)
 7fa:	00e6e463          	bltu	a3,a4,802 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fe:	fee7eae3          	bltu	a5,a4,7f2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 802:	ff852583          	lw	a1,-8(a0)
 806:	6390                	ld	a2,0(a5)
 808:	02059713          	slli	a4,a1,0x20
 80c:	9301                	srli	a4,a4,0x20
 80e:	0712                	slli	a4,a4,0x4
 810:	9736                	add	a4,a4,a3
 812:	fae60ae3          	beq	a2,a4,7c6 <free+0x14>
    bp->s.ptr = p->s.ptr;
 816:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 81a:	4790                	lw	a2,8(a5)
 81c:	02061713          	slli	a4,a2,0x20
 820:	9301                	srli	a4,a4,0x20
 822:	0712                	slli	a4,a4,0x4
 824:	973e                	add	a4,a4,a5
 826:	fae689e3          	beq	a3,a4,7d8 <free+0x26>
  } else
    p->s.ptr = bp;
 82a:	e394                	sd	a3,0(a5)
  freep = p;
 82c:	00000717          	auipc	a4,0x0
 830:	12f73a23          	sd	a5,308(a4) # 960 <freep>
}
 834:	6422                	ld	s0,8(sp)
 836:	0141                	addi	sp,sp,16
 838:	8082                	ret

000000000000083a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 83a:	7139                	addi	sp,sp,-64
 83c:	fc06                	sd	ra,56(sp)
 83e:	f822                	sd	s0,48(sp)
 840:	f426                	sd	s1,40(sp)
 842:	f04a                	sd	s2,32(sp)
 844:	ec4e                	sd	s3,24(sp)
 846:	e852                	sd	s4,16(sp)
 848:	e456                	sd	s5,8(sp)
 84a:	e05a                	sd	s6,0(sp)
 84c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 84e:	02051493          	slli	s1,a0,0x20
 852:	9081                	srli	s1,s1,0x20
 854:	04bd                	addi	s1,s1,15
 856:	8091                	srli	s1,s1,0x4
 858:	0014899b          	addiw	s3,s1,1
 85c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 85e:	00000517          	auipc	a0,0x0
 862:	10253503          	ld	a0,258(a0) # 960 <freep>
 866:	c515                	beqz	a0,892 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 868:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 86a:	4798                	lw	a4,8(a5)
 86c:	02977f63          	bgeu	a4,s1,8aa <malloc+0x70>
 870:	8a4e                	mv	s4,s3
 872:	0009871b          	sext.w	a4,s3
 876:	6685                	lui	a3,0x1
 878:	00d77363          	bgeu	a4,a3,87e <malloc+0x44>
 87c:	6a05                	lui	s4,0x1
 87e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 882:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 886:	00000917          	auipc	s2,0x0
 88a:	0da90913          	addi	s2,s2,218 # 960 <freep>
  if(p == (char*)-1)
 88e:	5afd                	li	s5,-1
 890:	a88d                	j	902 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 892:	00000797          	auipc	a5,0x0
 896:	0d678793          	addi	a5,a5,214 # 968 <base>
 89a:	00000717          	auipc	a4,0x0
 89e:	0cf73323          	sd	a5,198(a4) # 960 <freep>
 8a2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a8:	b7e1                	j	870 <malloc+0x36>
      if(p->s.size == nunits)
 8aa:	02e48b63          	beq	s1,a4,8e0 <malloc+0xa6>
        p->s.size -= nunits;
 8ae:	4137073b          	subw	a4,a4,s3
 8b2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b4:	1702                	slli	a4,a4,0x20
 8b6:	9301                	srli	a4,a4,0x20
 8b8:	0712                	slli	a4,a4,0x4
 8ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8c0:	00000717          	auipc	a4,0x0
 8c4:	0aa73023          	sd	a0,160(a4) # 960 <freep>
      return (void*)(p + 1);
 8c8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8cc:	70e2                	ld	ra,56(sp)
 8ce:	7442                	ld	s0,48(sp)
 8d0:	74a2                	ld	s1,40(sp)
 8d2:	7902                	ld	s2,32(sp)
 8d4:	69e2                	ld	s3,24(sp)
 8d6:	6a42                	ld	s4,16(sp)
 8d8:	6aa2                	ld	s5,8(sp)
 8da:	6b02                	ld	s6,0(sp)
 8dc:	6121                	addi	sp,sp,64
 8de:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8e0:	6398                	ld	a4,0(a5)
 8e2:	e118                	sd	a4,0(a0)
 8e4:	bff1                	j	8c0 <malloc+0x86>
  hp->s.size = nu;
 8e6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ea:	0541                	addi	a0,a0,16
 8ec:	00000097          	auipc	ra,0x0
 8f0:	ec6080e7          	jalr	-314(ra) # 7b2 <free>
  return freep;
 8f4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8f8:	d971                	beqz	a0,8cc <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8fc:	4798                	lw	a4,8(a5)
 8fe:	fa9776e3          	bgeu	a4,s1,8aa <malloc+0x70>
    if(p == freep)
 902:	00093703          	ld	a4,0(s2)
 906:	853e                	mv	a0,a5
 908:	fef719e3          	bne	a4,a5,8fa <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 90c:	8552                	mv	a0,s4
 90e:	00000097          	auipc	ra,0x0
 912:	b7e080e7          	jalr	-1154(ra) # 48c <sbrk>
  if(p == (char*)-1)
 916:	fd5518e3          	bne	a0,s5,8e6 <malloc+0xac>
        return 0;
 91a:	4501                	li	a0,0
 91c:	bf45                	j	8cc <malloc+0x92>
