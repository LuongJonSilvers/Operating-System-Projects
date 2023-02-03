
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 8b 3a 10 80       	mov    $0x80103a8b,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	f3 0f 1e fb          	endbr32 
80100038:	55                   	push   %ebp
80100039:	89 e5                	mov    %esp,%ebp
8010003b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003e:	83 ec 08             	sub    $0x8,%esp
80100041:	68 50 92 10 80       	push   $0x80109250
80100046:	68 60 d6 10 80       	push   $0x8010d660
8010004b:	e8 a1 52 00 00       	call   801052f1 <initlock>
80100050:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100053:	c7 05 ac 1d 11 80 5c 	movl   $0x80111d5c,0x80111dac
8010005a:	1d 11 80 
  bcache.head.next = &bcache.head;
8010005d:	c7 05 b0 1d 11 80 5c 	movl   $0x80111d5c,0x80111db0
80100064:	1d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100067:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
8010006e:	eb 47                	jmp    801000b7 <binit+0x83>
    b->next = bcache.head.next;
80100070:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
80100076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100079:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
8010007c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007f:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100089:	83 c0 0c             	add    $0xc,%eax
8010008c:	83 ec 08             	sub    $0x8,%esp
8010008f:	68 57 92 10 80       	push   $0x80109257
80100094:	50                   	push   %eax
80100095:	e8 c4 50 00 00       	call   8010515e <initsleeplock>
8010009a:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010009d:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a5:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b0:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b7:	b8 5c 1d 11 80       	mov    $0x80111d5c,%eax
801000bc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bf:	72 af                	jb     80100070 <binit+0x3c>
  }
}
801000c1:	90                   	nop
801000c2:	90                   	nop
801000c3:	c9                   	leave  
801000c4:	c3                   	ret    

801000c5 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c5:	f3 0f 1e fb          	endbr32 
801000c9:	55                   	push   %ebp
801000ca:	89 e5                	mov    %esp,%ebp
801000cc:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000cf:	83 ec 0c             	sub    $0xc,%esp
801000d2:	68 60 d6 10 80       	push   $0x8010d660
801000d7:	e8 3b 52 00 00       	call   80105317 <acquire>
801000dc:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000df:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000e7:	eb 58                	jmp    80100141 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 40 04             	mov    0x4(%eax),%eax
801000ef:	39 45 08             	cmp    %eax,0x8(%ebp)
801000f2:	75 44                	jne    80100138 <bget+0x73>
801000f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f7:	8b 40 08             	mov    0x8(%eax),%eax
801000fa:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000fd:	75 39                	jne    80100138 <bget+0x73>
      b->refcnt++;
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	8b 40 4c             	mov    0x4c(%eax),%eax
80100105:	8d 50 01             	lea    0x1(%eax),%edx
80100108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010b:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
8010010e:	83 ec 0c             	sub    $0xc,%esp
80100111:	68 60 d6 10 80       	push   $0x8010d660
80100116:	e8 6e 52 00 00       	call   80105389 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 71 50 00 00       	call   8010519e <acquiresleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      return b;
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	e9 9d 00 00 00       	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013b:	8b 40 54             	mov    0x54(%eax),%eax
8010013e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100141:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
80100148:	75 9f                	jne    801000e9 <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010014a:	a1 ac 1d 11 80       	mov    0x80111dac,%eax
8010014f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100152:	eb 6b                	jmp    801001bf <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100157:	8b 40 4c             	mov    0x4c(%eax),%eax
8010015a:	85 c0                	test   %eax,%eax
8010015c:	75 58                	jne    801001b6 <bget+0xf1>
8010015e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100161:	8b 00                	mov    (%eax),%eax
80100163:	83 e0 04             	and    $0x4,%eax
80100166:	85 c0                	test   %eax,%eax
80100168:	75 4c                	jne    801001b6 <bget+0xf1>
      b->dev = dev;
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 55 08             	mov    0x8(%ebp),%edx
80100170:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100176:	8b 55 0c             	mov    0xc(%ebp),%edx
80100179:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
8010017c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
80100185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100188:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
8010018f:	83 ec 0c             	sub    $0xc,%esp
80100192:	68 60 d6 10 80       	push   $0x8010d660
80100197:	e8 ed 51 00 00       	call   80105389 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 f0 4f 00 00       	call   8010519e <acquiresleep>
801001ae:	83 c4 10             	add    $0x10,%esp
      return b;
801001b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b4:	eb 1f                	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b9:	8b 40 50             	mov    0x50(%eax),%eax
801001bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001bf:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
801001c6:	75 8c                	jne    80100154 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 5e 92 10 80       	push   $0x8010925e
801001d0:	e8 33 04 00 00       	call   80100608 <panic>
}
801001d5:	c9                   	leave  
801001d6:	c3                   	ret    

801001d7 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001d7:	f3 0f 1e fb          	endbr32 
801001db:	55                   	push   %ebp
801001dc:	89 e5                	mov    %esp,%ebp
801001de:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001e1:	83 ec 08             	sub    $0x8,%esp
801001e4:	ff 75 0c             	pushl  0xc(%ebp)
801001e7:	ff 75 08             	pushl  0x8(%ebp)
801001ea:	e8 d6 fe ff ff       	call   801000c5 <bget>
801001ef:	83 c4 10             	add    $0x10,%esp
801001f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 02             	and    $0x2,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0e                	jne    8010020f <bread+0x38>
    iderw(b);
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	ff 75 f4             	pushl  -0xc(%ebp)
80100207:	e8 de 28 00 00       	call   80102aea <iderw>
8010020c:	83 c4 10             	add    $0x10,%esp
  }
  return b;
8010020f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100212:	c9                   	leave  
80100213:	c3                   	ret    

80100214 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100214:	f3 0f 1e fb          	endbr32 
80100218:	55                   	push   %ebp
80100219:	89 e5                	mov    %esp,%ebp
8010021b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010021e:	8b 45 08             	mov    0x8(%ebp),%eax
80100221:	83 c0 0c             	add    $0xc,%eax
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	50                   	push   %eax
80100228:	e8 2b 50 00 00       	call   80105258 <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 6f 92 10 80       	push   $0x8010926f
8010023c:	e8 c7 03 00 00       	call   80100608 <panic>
  b->flags |= B_DIRTY;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 00                	mov    (%eax),%eax
80100246:	83 c8 04             	or     $0x4,%eax
80100249:	89 c2                	mov    %eax,%edx
8010024b:	8b 45 08             	mov    0x8(%ebp),%eax
8010024e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100250:	83 ec 0c             	sub    $0xc,%esp
80100253:	ff 75 08             	pushl  0x8(%ebp)
80100256:	e8 8f 28 00 00       	call   80102aea <iderw>
8010025b:	83 c4 10             	add    $0x10,%esp
}
8010025e:	90                   	nop
8010025f:	c9                   	leave  
80100260:	c3                   	ret    

80100261 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100261:	f3 0f 1e fb          	endbr32 
80100265:	55                   	push   %ebp
80100266:	89 e5                	mov    %esp,%ebp
80100268:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	83 c0 0c             	add    $0xc,%eax
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	50                   	push   %eax
80100275:	e8 de 4f 00 00       	call   80105258 <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 76 92 10 80       	push   $0x80109276
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 69 4f 00 00       	call   80105206 <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 d6 10 80       	push   $0x8010d660
801002a8:	e8 6a 50 00 00       	call   80105317 <acquire>
801002ad:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002b0:	8b 45 08             	mov    0x8(%ebp),%eax
801002b3:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801002b9:	8b 45 08             	mov    0x8(%ebp),%eax
801002bc:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002bf:	8b 45 08             	mov    0x8(%ebp),%eax
801002c2:	8b 40 4c             	mov    0x4c(%eax),%eax
801002c5:	85 c0                	test   %eax,%eax
801002c7:	75 47                	jne    80100310 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002c9:	8b 45 08             	mov    0x8(%ebp),%eax
801002cc:	8b 40 54             	mov    0x54(%eax),%eax
801002cf:	8b 55 08             	mov    0x8(%ebp),%edx
801002d2:	8b 52 50             	mov    0x50(%edx),%edx
801002d5:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	8b 40 50             	mov    0x50(%eax),%eax
801002de:	8b 55 08             	mov    0x8(%ebp),%edx
801002e1:	8b 52 54             	mov    0x54(%edx),%edx
801002e4:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002e7:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
801002ed:	8b 45 08             	mov    0x8(%ebp),%eax
801002f0:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    bcache.head.next->prev = b;
801002fd:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
80100302:	8b 55 08             	mov    0x8(%ebp),%edx
80100305:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100308:	8b 45 08             	mov    0x8(%ebp),%eax
8010030b:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  }
  
  release(&bcache.lock);
80100310:	83 ec 0c             	sub    $0xc,%esp
80100313:	68 60 d6 10 80       	push   $0x8010d660
80100318:	e8 6c 50 00 00       	call   80105389 <release>
8010031d:	83 c4 10             	add    $0x10,%esp
}
80100320:	90                   	nop
80100321:	c9                   	leave  
80100322:	c3                   	ret    

80100323 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80100323:	55                   	push   %ebp
80100324:	89 e5                	mov    %esp,%ebp
80100326:	83 ec 14             	sub    $0x14,%esp
80100329:	8b 45 08             	mov    0x8(%ebp),%eax
8010032c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100330:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100334:	89 c2                	mov    %eax,%edx
80100336:	ec                   	in     (%dx),%al
80100337:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010033a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010033e:	c9                   	leave  
8010033f:	c3                   	ret    

80100340 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80100340:	55                   	push   %ebp
80100341:	89 e5                	mov    %esp,%ebp
80100343:	83 ec 08             	sub    $0x8,%esp
80100346:	8b 45 08             	mov    0x8(%ebp),%eax
80100349:	8b 55 0c             	mov    0xc(%ebp),%edx
8010034c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100350:	89 d0                	mov    %edx,%eax
80100352:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100355:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100359:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010035d:	ee                   	out    %al,(%dx)
}
8010035e:	90                   	nop
8010035f:	c9                   	leave  
80100360:	c3                   	ret    

80100361 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100361:	55                   	push   %ebp
80100362:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100364:	fa                   	cli    
}
80100365:	90                   	nop
80100366:	5d                   	pop    %ebp
80100367:	c3                   	ret    

80100368 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100368:	f3 0f 1e fb          	endbr32 
8010036c:	55                   	push   %ebp
8010036d:	89 e5                	mov    %esp,%ebp
8010036f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100372:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100376:	74 1c                	je     80100394 <printint+0x2c>
80100378:	8b 45 08             	mov    0x8(%ebp),%eax
8010037b:	c1 e8 1f             	shr    $0x1f,%eax
8010037e:	0f b6 c0             	movzbl %al,%eax
80100381:	89 45 10             	mov    %eax,0x10(%ebp)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 0a                	je     80100394 <printint+0x2c>
    x = -xx;
8010038a:	8b 45 08             	mov    0x8(%ebp),%eax
8010038d:	f7 d8                	neg    %eax
8010038f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100392:	eb 06                	jmp    8010039a <printint+0x32>
  else
    x = xx;
80100394:	8b 45 08             	mov    0x8(%ebp),%eax
80100397:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010039a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
801003a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a7:	ba 00 00 00 00       	mov    $0x0,%edx
801003ac:	f7 f1                	div    %ecx
801003ae:	89 d1                	mov    %edx,%ecx
801003b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003b3:	8d 50 01             	lea    0x1(%eax),%edx
801003b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003b9:	0f b6 91 04 a0 10 80 	movzbl -0x7fef5ffc(%ecx),%edx
801003c0:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003ca:	ba 00 00 00 00       	mov    $0x0,%edx
801003cf:	f7 f1                	div    %ecx
801003d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003d8:	75 c7                	jne    801003a1 <printint+0x39>

  if(sign)
801003da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003de:	74 2a                	je     8010040a <printint+0xa2>
    buf[i++] = '-';
801003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003e3:	8d 50 01             	lea    0x1(%eax),%edx
801003e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003e9:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ee:	eb 1a                	jmp    8010040a <printint+0xa2>
    consputc(buf[i]);
801003f0:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003f6:	01 d0                	add    %edx,%eax
801003f8:	0f b6 00             	movzbl (%eax),%eax
801003fb:	0f be c0             	movsbl %al,%eax
801003fe:	83 ec 0c             	sub    $0xc,%esp
80100401:	50                   	push   %eax
80100402:	e8 36 04 00 00       	call   8010083d <consputc>
80100407:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
8010040a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010040e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100412:	79 dc                	jns    801003f0 <printint+0x88>
}
80100414:	90                   	nop
80100415:	90                   	nop
80100416:	c9                   	leave  
80100417:	c3                   	ret    

80100418 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100418:	f3 0f 1e fb          	endbr32 
8010041c:	55                   	push   %ebp
8010041d:	89 e5                	mov    %esp,%ebp
8010041f:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100422:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
80100427:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //changed: added holding check
  if(locking && !holding(&cons.lock))
8010042a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010042e:	74 24                	je     80100454 <cprintf+0x3c>
80100430:	83 ec 0c             	sub    $0xc,%esp
80100433:	68 c0 c5 10 80       	push   $0x8010c5c0
80100438:	e8 21 50 00 00       	call   8010545e <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 c5 10 80       	push   $0x8010c5c0
8010044c:	e8 c6 4e 00 00       	call   80105317 <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 80 92 10 80       	push   $0x80109280
80100463:	e8 a0 01 00 00       	call   80100608 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100468:	8d 45 0c             	lea    0xc(%ebp),%eax
8010046b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010046e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100475:	e9 52 01 00 00       	jmp    801005cc <cprintf+0x1b4>
    if(c != '%'){
8010047a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047e:	74 13                	je     80100493 <cprintf+0x7b>
      consputc(c);
80100480:	83 ec 0c             	sub    $0xc,%esp
80100483:	ff 75 e4             	pushl  -0x1c(%ebp)
80100486:	e8 b2 03 00 00       	call   8010083d <consputc>
8010048b:	83 c4 10             	add    $0x10,%esp
      continue;
8010048e:	e9 35 01 00 00       	jmp    801005c8 <cprintf+0x1b0>
    }
    c = fmt[++i] & 0xff;
80100493:	8b 55 08             	mov    0x8(%ebp),%edx
80100496:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010049a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010049d:	01 d0                	add    %edx,%eax
8010049f:	0f b6 00             	movzbl (%eax),%eax
801004a2:	0f be c0             	movsbl %al,%eax
801004a5:	25 ff 00 00 00       	and    $0xff,%eax
801004aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
801004ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801004b1:	0f 84 37 01 00 00    	je     801005ee <cprintf+0x1d6>
      break;
    switch(c){
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 dc 00 00 00    	je     8010059d <cprintf+0x185>
801004c1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004c5:	0f 8c e1 00 00 00    	jl     801005ac <cprintf+0x194>
801004cb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004cf:	0f 8f d7 00 00 00    	jg     801005ac <cprintf+0x194>
801004d5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
801004d9:	0f 8c cd 00 00 00    	jl     801005ac <cprintf+0x194>
801004df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004e2:	83 e8 63             	sub    $0x63,%eax
801004e5:	83 f8 15             	cmp    $0x15,%eax
801004e8:	0f 87 be 00 00 00    	ja     801005ac <cprintf+0x194>
801004ee:	8b 04 85 90 92 10 80 	mov    -0x7fef6d70(,%eax,4),%eax
801004f5:	3e ff e0             	notrack jmp *%eax
    case 'd':
      printint(*argp++, 10, 1);
801004f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fb:	8d 50 04             	lea    0x4(%eax),%edx
801004fe:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100501:	8b 00                	mov    (%eax),%eax
80100503:	83 ec 04             	sub    $0x4,%esp
80100506:	6a 01                	push   $0x1
80100508:	6a 0a                	push   $0xa
8010050a:	50                   	push   %eax
8010050b:	e8 58 fe ff ff       	call   80100368 <printint>
80100510:	83 c4 10             	add    $0x10,%esp
      break;
80100513:	e9 b0 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	83 ec 04             	sub    $0x4,%esp
80100526:	6a 00                	push   $0x0
80100528:	6a 10                	push   $0x10
8010052a:	50                   	push   %eax
8010052b:	e8 38 fe ff ff       	call   80100368 <printint>
80100530:	83 c4 10             	add    $0x10,%esp
      break;
80100533:	e9 90 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 's':
      if((s = (char*)*argp++) == 0)
80100538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010053b:	8d 50 04             	lea    0x4(%eax),%edx
8010053e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100541:	8b 00                	mov    (%eax),%eax
80100543:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100546:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010054a:	75 22                	jne    8010056e <cprintf+0x156>
        s = "(null)";
8010054c:	c7 45 ec 89 92 10 80 	movl   $0x80109289,-0x14(%ebp)
      for(; *s; s++)
80100553:	eb 19                	jmp    8010056e <cprintf+0x156>
        consputc(*s);
80100555:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f be c0             	movsbl %al,%eax
8010055e:	83 ec 0c             	sub    $0xc,%esp
80100561:	50                   	push   %eax
80100562:	e8 d6 02 00 00       	call   8010083d <consputc>
80100567:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010056a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010056e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100571:	0f b6 00             	movzbl (%eax),%eax
80100574:	84 c0                	test   %al,%al
80100576:	75 dd                	jne    80100555 <cprintf+0x13d>
      break;
80100578:	eb 4e                	jmp    801005c8 <cprintf+0x1b0>
    case 'c':
      s = (char*)argp++;
8010057a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010057d:	8d 50 04             	lea    0x4(%eax),%edx
80100580:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100583:	89 45 ec             	mov    %eax,-0x14(%ebp)
      consputc(*(s));
80100586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100589:	0f b6 00             	movzbl (%eax),%eax
8010058c:	0f be c0             	movsbl %al,%eax
8010058f:	83 ec 0c             	sub    $0xc,%esp
80100592:	50                   	push   %eax
80100593:	e8 a5 02 00 00       	call   8010083d <consputc>
80100598:	83 c4 10             	add    $0x10,%esp
      break;
8010059b:	eb 2b                	jmp    801005c8 <cprintf+0x1b0>
    case '%':
      consputc('%');
8010059d:	83 ec 0c             	sub    $0xc,%esp
801005a0:	6a 25                	push   $0x25
801005a2:	e8 96 02 00 00       	call   8010083d <consputc>
801005a7:	83 c4 10             	add    $0x10,%esp
      break;
801005aa:	eb 1c                	jmp    801005c8 <cprintf+0x1b0>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801005ac:	83 ec 0c             	sub    $0xc,%esp
801005af:	6a 25                	push   $0x25
801005b1:	e8 87 02 00 00       	call   8010083d <consputc>
801005b6:	83 c4 10             	add    $0x10,%esp
      consputc(c);
801005b9:	83 ec 0c             	sub    $0xc,%esp
801005bc:	ff 75 e4             	pushl  -0x1c(%ebp)
801005bf:	e8 79 02 00 00       	call   8010083d <consputc>
801005c4:	83 c4 10             	add    $0x10,%esp
      break;
801005c7:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801005c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005cc:	8b 55 08             	mov    0x8(%ebp),%edx
801005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d2:	01 d0                	add    %edx,%eax
801005d4:	0f b6 00             	movzbl (%eax),%eax
801005d7:	0f be c0             	movsbl %al,%eax
801005da:	25 ff 00 00 00       	and    $0xff,%eax
801005df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801005e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005e6:	0f 85 8e fe ff ff    	jne    8010047a <cprintf+0x62>
801005ec:	eb 01                	jmp    801005ef <cprintf+0x1d7>
      break;
801005ee:	90                   	nop
    }
  }

  if(locking)
801005ef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005f3:	74 10                	je     80100605 <cprintf+0x1ed>
    release(&cons.lock);
801005f5:	83 ec 0c             	sub    $0xc,%esp
801005f8:	68 c0 c5 10 80       	push   $0x8010c5c0
801005fd:	e8 87 4d 00 00       	call   80105389 <release>
80100602:	83 c4 10             	add    $0x10,%esp
}
80100605:	90                   	nop
80100606:	c9                   	leave  
80100607:	c3                   	ret    

80100608 <panic>:

void
panic(char *s)
{
80100608:	f3 0f 1e fb          	endbr32 
8010060c:	55                   	push   %ebp
8010060d:	89 e5                	mov    %esp,%ebp
8010060f:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
80100612:	e8 4a fd ff ff       	call   80100361 <cli>
  cons.locking = 0;
80100617:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010061e:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100621:	e8 b6 2b 00 00       	call   801031dc <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 e8 92 10 80       	push   $0x801092e8
8010062f:	e8 e4 fd ff ff       	call   80100418 <cprintf>
80100634:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100637:	8b 45 08             	mov    0x8(%ebp),%eax
8010063a:	83 ec 0c             	sub    $0xc,%esp
8010063d:	50                   	push   %eax
8010063e:	e8 d5 fd ff ff       	call   80100418 <cprintf>
80100643:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100646:	83 ec 0c             	sub    $0xc,%esp
80100649:	68 fc 92 10 80       	push   $0x801092fc
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 79 4d 00 00       	call   801053df <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 fe 92 10 80       	push   $0x801092fe
80100682:	e8 91 fd ff ff       	call   80100418 <cprintf>
80100687:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010068a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010068e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100692:	7e de                	jle    80100672 <panic+0x6a>
  panicked = 1; // freeze other CPU
80100694:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
8010069b:	00 00 00 
  for(;;)
8010069e:	eb fe                	jmp    8010069e <panic+0x96>

801006a0 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801006a0:	f3 0f 1e fb          	endbr32 
801006a4:	55                   	push   %ebp
801006a5:	89 e5                	mov    %esp,%ebp
801006a7:	53                   	push   %ebx
801006a8:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801006ab:	6a 0e                	push   $0xe
801006ad:	68 d4 03 00 00       	push   $0x3d4
801006b2:	e8 89 fc ff ff       	call   80100340 <outb>
801006b7:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
801006ba:	68 d5 03 00 00       	push   $0x3d5
801006bf:	e8 5f fc ff ff       	call   80100323 <inb>
801006c4:	83 c4 04             	add    $0x4,%esp
801006c7:	0f b6 c0             	movzbl %al,%eax
801006ca:	c1 e0 08             	shl    $0x8,%eax
801006cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801006d0:	6a 0f                	push   $0xf
801006d2:	68 d4 03 00 00       	push   $0x3d4
801006d7:	e8 64 fc ff ff       	call   80100340 <outb>
801006dc:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
801006df:	68 d5 03 00 00       	push   $0x3d5
801006e4:	e8 3a fc ff ff       	call   80100323 <inb>
801006e9:	83 c4 04             	add    $0x4,%esp
801006ec:	0f b6 c0             	movzbl %al,%eax
801006ef:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
801006f2:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
801006f6:	75 30                	jne    80100728 <cgaputc+0x88>
    pos += 80 - pos%80;
801006f8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fb:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100700:	89 c8                	mov    %ecx,%eax
80100702:	f7 ea                	imul   %edx
80100704:	c1 fa 05             	sar    $0x5,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	c1 f8 1f             	sar    $0x1f,%eax
8010070c:	29 c2                	sub    %eax,%edx
8010070e:	89 d0                	mov    %edx,%eax
80100710:	c1 e0 02             	shl    $0x2,%eax
80100713:	01 d0                	add    %edx,%eax
80100715:	c1 e0 04             	shl    $0x4,%eax
80100718:	29 c1                	sub    %eax,%ecx
8010071a:	89 ca                	mov    %ecx,%edx
8010071c:	b8 50 00 00 00       	mov    $0x50,%eax
80100721:	29 d0                	sub    %edx,%eax
80100723:	01 45 f4             	add    %eax,-0xc(%ebp)
80100726:	eb 38                	jmp    80100760 <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100728:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010072f:	75 0c                	jne    8010073d <cgaputc+0x9d>
    if(pos > 0) --pos;
80100731:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100735:	7e 29                	jle    80100760 <cgaputc+0xc0>
80100737:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010073b:	eb 23                	jmp    80100760 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010073d:	8b 45 08             	mov    0x8(%ebp),%eax
80100740:	0f b6 c0             	movzbl %al,%eax
80100743:	80 cc 07             	or     $0x7,%ah
80100746:	89 c3                	mov    %eax,%ebx
80100748:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100751:	8d 50 01             	lea    0x1(%eax),%edx
80100754:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100757:	01 c0                	add    %eax,%eax
80100759:	01 c8                	add    %ecx,%eax
8010075b:	89 da                	mov    %ebx,%edx
8010075d:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100760:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100764:	78 09                	js     8010076f <cgaputc+0xcf>
80100766:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
8010076d:	7e 0d                	jle    8010077c <cgaputc+0xdc>
    panic("pos under/overflow");
8010076f:	83 ec 0c             	sub    $0xc,%esp
80100772:	68 02 93 10 80       	push   $0x80109302
80100777:	e8 8c fe ff ff       	call   80100608 <panic>

  if((pos/80) >= 24){  // Scroll up.
8010077c:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100783:	7e 4c                	jle    801007d1 <cgaputc+0x131>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100785:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010078a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100790:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100795:	83 ec 04             	sub    $0x4,%esp
80100798:	68 60 0e 00 00       	push   $0xe60
8010079d:	52                   	push   %edx
8010079e:	50                   	push   %eax
8010079f:	e8 d9 4e 00 00       	call   8010567d <memmove>
801007a4:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801007a7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801007ab:	b8 80 07 00 00       	mov    $0x780,%eax
801007b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801007b3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801007b6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007bb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801007be:	01 c9                	add    %ecx,%ecx
801007c0:	01 c8                	add    %ecx,%eax
801007c2:	83 ec 04             	sub    $0x4,%esp
801007c5:	52                   	push   %edx
801007c6:	6a 00                	push   $0x0
801007c8:	50                   	push   %eax
801007c9:	e8 e8 4d 00 00       	call   801055b6 <memset>
801007ce:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
801007d1:	83 ec 08             	sub    $0x8,%esp
801007d4:	6a 0e                	push   $0xe
801007d6:	68 d4 03 00 00       	push   $0x3d4
801007db:	e8 60 fb ff ff       	call   80100340 <outb>
801007e0:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
801007e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007e6:	c1 f8 08             	sar    $0x8,%eax
801007e9:	0f b6 c0             	movzbl %al,%eax
801007ec:	83 ec 08             	sub    $0x8,%esp
801007ef:	50                   	push   %eax
801007f0:	68 d5 03 00 00       	push   $0x3d5
801007f5:	e8 46 fb ff ff       	call   80100340 <outb>
801007fa:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007fd:	83 ec 08             	sub    $0x8,%esp
80100800:	6a 0f                	push   $0xf
80100802:	68 d4 03 00 00       	push   $0x3d4
80100807:	e8 34 fb ff ff       	call   80100340 <outb>
8010080c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100812:	0f b6 c0             	movzbl %al,%eax
80100815:	83 ec 08             	sub    $0x8,%esp
80100818:	50                   	push   %eax
80100819:	68 d5 03 00 00       	push   $0x3d5
8010081e:	e8 1d fb ff ff       	call   80100340 <outb>
80100823:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100826:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010082b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010082e:	01 d2                	add    %edx,%edx
80100830:	01 d0                	add    %edx,%eax
80100832:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100837:	90                   	nop
80100838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010083b:	c9                   	leave  
8010083c:	c3                   	ret    

8010083d <consputc>:

void
consputc(int c)
{
8010083d:	f3 0f 1e fb          	endbr32 
80100841:	55                   	push   %ebp
80100842:	89 e5                	mov    %esp,%ebp
80100844:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100847:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010084c:	85 c0                	test   %eax,%eax
8010084e:	74 07                	je     80100857 <consputc+0x1a>
    cli();
80100850:	e8 0c fb ff ff       	call   80100361 <cli>
    for(;;)
80100855:	eb fe                	jmp    80100855 <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
80100857:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010085e:	75 29                	jne    80100889 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100860:	83 ec 0c             	sub    $0xc,%esp
80100863:	6a 08                	push   $0x8
80100865:	e8 5b 68 00 00       	call   801070c5 <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 4e 68 00 00       	call   801070c5 <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 41 68 00 00       	call   801070c5 <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 31 68 00 00       	call   801070c5 <uartputc>
80100894:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100897:	83 ec 0c             	sub    $0xc,%esp
8010089a:	ff 75 08             	pushl  0x8(%ebp)
8010089d:	e8 fe fd ff ff       	call   801006a0 <cgaputc>
801008a2:	83 c4 10             	add    $0x10,%esp
}
801008a5:	90                   	nop
801008a6:	c9                   	leave  
801008a7:	c3                   	ret    

801008a8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801008a8:	f3 0f 1e fb          	endbr32 
801008ac:	55                   	push   %ebp
801008ad:	89 e5                	mov    %esp,%ebp
801008af:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801008b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801008b9:	83 ec 0c             	sub    $0xc,%esp
801008bc:	68 c0 c5 10 80       	push   $0x8010c5c0
801008c1:	e8 51 4a 00 00       	call   80105317 <acquire>
801008c6:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801008c9:	e9 52 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    switch(c){
801008ce:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008d2:	0f 84 81 00 00 00    	je     80100959 <consoleintr+0xb1>
801008d8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008dc:	0f 8f ac 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008e2:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008e6:	74 43                	je     8010092b <consoleintr+0x83>
801008e8:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008ec:	0f 8f 9c 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008f2:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
801008f6:	74 61                	je     80100959 <consoleintr+0xb1>
801008f8:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
801008fc:	0f 85 8c 00 00 00    	jne    8010098e <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100902:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100909:	e9 12 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010090e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100913:	83 e8 01             	sub    $0x1,%eax
80100916:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
8010091b:	83 ec 0c             	sub    $0xc,%esp
8010091e:	68 00 01 00 00       	push   $0x100
80100923:	e8 15 ff ff ff       	call   8010083d <consputc>
80100928:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010092b:	8b 15 48 20 11 80    	mov    0x80112048,%edx
80100931:	a1 44 20 11 80       	mov    0x80112044,%eax
80100936:	39 c2                	cmp    %eax,%edx
80100938:	0f 84 e2 00 00 00    	je     80100a20 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010093e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100943:	83 e8 01             	sub    $0x1,%eax
80100946:	83 e0 7f             	and    $0x7f,%eax
80100949:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
      while(input.e != input.w &&
80100950:	3c 0a                	cmp    $0xa,%al
80100952:	75 ba                	jne    8010090e <consoleintr+0x66>
      }
      break;
80100954:	e9 c7 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100959:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010095f:	a1 44 20 11 80       	mov    0x80112044,%eax
80100964:	39 c2                	cmp    %eax,%edx
80100966:	0f 84 b4 00 00 00    	je     80100a20 <consoleintr+0x178>
        input.e--;
8010096c:	a1 48 20 11 80       	mov    0x80112048,%eax
80100971:	83 e8 01             	sub    $0x1,%eax
80100974:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 00 01 00 00       	push   $0x100
80100981:	e8 b7 fe ff ff       	call   8010083d <consputc>
80100986:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100989:	e9 92 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010098e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100992:	0f 84 87 00 00 00    	je     80100a1f <consoleintr+0x177>
80100998:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010099e:	a1 40 20 11 80       	mov    0x80112040,%eax
801009a3:	29 c2                	sub    %eax,%edx
801009a5:	89 d0                	mov    %edx,%eax
801009a7:	83 f8 7f             	cmp    $0x7f,%eax
801009aa:	77 73                	ja     80100a1f <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
801009ac:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801009b0:	74 05                	je     801009b7 <consoleintr+0x10f>
801009b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009b5:	eb 05                	jmp    801009bc <consoleintr+0x114>
801009b7:	b8 0a 00 00 00       	mov    $0xa,%eax
801009bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801009bf:	a1 48 20 11 80       	mov    0x80112048,%eax
801009c4:	8d 50 01             	lea    0x1(%eax),%edx
801009c7:	89 15 48 20 11 80    	mov    %edx,0x80112048
801009cd:	83 e0 7f             	and    $0x7f,%eax
801009d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009d3:	88 90 c0 1f 11 80    	mov    %dl,-0x7feee040(%eax)
        consputc(c);
801009d9:	83 ec 0c             	sub    $0xc,%esp
801009dc:	ff 75 f0             	pushl  -0x10(%ebp)
801009df:	e8 59 fe ff ff       	call   8010083d <consputc>
801009e4:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009e7:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009eb:	74 18                	je     80100a05 <consoleintr+0x15d>
801009ed:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009f1:	74 12                	je     80100a05 <consoleintr+0x15d>
801009f3:	a1 48 20 11 80       	mov    0x80112048,%eax
801009f8:	8b 15 40 20 11 80    	mov    0x80112040,%edx
801009fe:	83 ea 80             	sub    $0xffffff80,%edx
80100a01:	39 d0                	cmp    %edx,%eax
80100a03:	75 1a                	jne    80100a1f <consoleintr+0x177>
          input.w = input.e;
80100a05:	a1 48 20 11 80       	mov    0x80112048,%eax
80100a0a:	a3 44 20 11 80       	mov    %eax,0x80112044
          wakeup(&input.r);
80100a0f:	83 ec 0c             	sub    $0xc,%esp
80100a12:	68 40 20 11 80       	push   $0x80112040
80100a17:	e8 7b 45 00 00       	call   80104f97 <wakeup>
80100a1c:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100a1f:	90                   	nop
  while((c = getc()) >= 0){
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	ff d0                	call   *%eax
80100a25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100a28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a2c:	0f 89 9c fe ff ff    	jns    801008ce <consoleintr+0x26>
    }
  }
  release(&cons.lock);
80100a32:	83 ec 0c             	sub    $0xc,%esp
80100a35:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a3a:	e8 4a 49 00 00       	call   80105389 <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 10 46 00 00       	call   8010505d <procdump>
  }
}
80100a4d:	90                   	nop
80100a4e:	c9                   	leave  
80100a4f:	c3                   	ret    

80100a50 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a50:	f3 0f 1e fb          	endbr32 
80100a54:	55                   	push   %ebp
80100a55:	89 e5                	mov    %esp,%ebp
80100a57:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a5a:	83 ec 0c             	sub    $0xc,%esp
80100a5d:	ff 75 08             	pushl  0x8(%ebp)
80100a60:	e8 0b 12 00 00       	call   80101c70 <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a76:	e8 9c 48 00 00       	call   80105317 <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 85 3a 00 00       	call   8010450d <myproc>
80100a88:	8b 40 24             	mov    0x24(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a97:	e8 ed 48 00 00       	call   80105389 <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 af 10 00 00       	call   80101b59 <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abf:	68 40 20 11 80       	push   $0x80112040
80100ac4:	e8 dc 43 00 00       	call   80104ea5 <sleep>
80100ac9:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100acc:	8b 15 40 20 11 80    	mov    0x80112040,%edx
80100ad2:	a1 44 20 11 80       	mov    0x80112044,%eax
80100ad7:	39 c2                	cmp    %eax,%edx
80100ad9:	74 a8                	je     80100a83 <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100adb:	a1 40 20 11 80       	mov    0x80112040,%eax
80100ae0:	8d 50 01             	lea    0x1(%eax),%edx
80100ae3:	89 15 40 20 11 80    	mov    %edx,0x80112040
80100ae9:	83 e0 7f             	and    $0x7f,%eax
80100aec:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
80100af3:	0f be c0             	movsbl %al,%eax
80100af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100af9:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100afd:	75 17                	jne    80100b16 <consoleread+0xc6>
      if(n < target){
80100aff:	8b 45 10             	mov    0x10(%ebp),%eax
80100b02:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100b05:	76 2f                	jbe    80100b36 <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b07:	a1 40 20 11 80       	mov    0x80112040,%eax
80100b0c:	83 e8 01             	sub    $0x1,%eax
80100b0f:	a3 40 20 11 80       	mov    %eax,0x80112040
      }
      break;
80100b14:	eb 20                	jmp    80100b36 <consoleread+0xe6>
    }
    *dst++ = c;
80100b16:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b19:	8d 50 01             	lea    0x1(%eax),%edx
80100b1c:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b22:	88 10                	mov    %dl,(%eax)
    --n;
80100b24:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b28:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b2c:	74 0b                	je     80100b39 <consoleread+0xe9>
  while(n > 0){
80100b2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b32:	7f 98                	jg     80100acc <consoleread+0x7c>
80100b34:	eb 04                	jmp    80100b3a <consoleread+0xea>
      break;
80100b36:	90                   	nop
80100b37:	eb 01                	jmp    80100b3a <consoleread+0xea>
      break;
80100b39:	90                   	nop
  }
  release(&cons.lock);
80100b3a:	83 ec 0c             	sub    $0xc,%esp
80100b3d:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b42:	e8 42 48 00 00       	call   80105389 <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 04 10 00 00       	call   80101b59 <ilock>
80100b55:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b58:	8b 45 10             	mov    0x10(%ebp),%eax
80100b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b5e:	29 c2                	sub    %eax,%edx
80100b60:	89 d0                	mov    %edx,%eax
}
80100b62:	c9                   	leave  
80100b63:	c3                   	ret    

80100b64 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b64:	f3 0f 1e fb          	endbr32 
80100b68:	55                   	push   %ebp
80100b69:	89 e5                	mov    %esp,%ebp
80100b6b:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b6e:	83 ec 0c             	sub    $0xc,%esp
80100b71:	ff 75 08             	pushl  0x8(%ebp)
80100b74:	e8 f7 10 00 00       	call   80101c70 <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b84:	e8 8e 47 00 00       	call   80105317 <acquire>
80100b89:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b93:	eb 21                	jmp    80100bb6 <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100b95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b9b:	01 d0                	add    %edx,%eax
80100b9d:	0f b6 00             	movzbl (%eax),%eax
80100ba0:	0f be c0             	movsbl %al,%eax
80100ba3:	0f b6 c0             	movzbl %al,%eax
80100ba6:	83 ec 0c             	sub    $0xc,%esp
80100ba9:	50                   	push   %eax
80100baa:	e8 8e fc ff ff       	call   8010083d <consputc>
80100baf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100bb2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bb9:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bbc:	7c d7                	jl     80100b95 <consolewrite+0x31>
  release(&cons.lock);
80100bbe:	83 ec 0c             	sub    $0xc,%esp
80100bc1:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bc6:	e8 be 47 00 00       	call   80105389 <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 80 0f 00 00       	call   80101b59 <ilock>
80100bd9:	83 c4 10             	add    $0x10,%esp

  return n;
80100bdc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bdf:	c9                   	leave  
80100be0:	c3                   	ret    

80100be1 <consoleinit>:

void
consoleinit(void)
{
80100be1:	f3 0f 1e fb          	endbr32 
80100be5:	55                   	push   %ebp
80100be6:	89 e5                	mov    %esp,%ebp
80100be8:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100beb:	83 ec 08             	sub    $0x8,%esp
80100bee:	68 15 93 10 80       	push   $0x80109315
80100bf3:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bf8:	e8 f4 46 00 00       	call   801052f1 <initlock>
80100bfd:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100c00:	c7 05 0c 2a 11 80 64 	movl   $0x80100b64,0x80112a0c
80100c07:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c0a:	c7 05 08 2a 11 80 50 	movl   $0x80100a50,0x80112a08
80100c11:	0a 10 80 
  cons.locking = 1;
80100c14:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100c1b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c1e:	83 ec 08             	sub    $0x8,%esp
80100c21:	6a 00                	push   $0x0
80100c23:	6a 01                	push   $0x1
80100c25:	e8 99 20 00 00       	call   80102cc3 <ioapicenable>
80100c2a:	83 c4 10             	add    $0x10,%esp
}
80100c2d:	90                   	nop
80100c2e:	c9                   	leave  
80100c2f:	c3                   	ret    

80100c30 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c30:	f3 0f 1e fb          	endbr32 
80100c34:	55                   	push   %ebp
80100c35:	89 e5                	mov    %esp,%ebp
80100c37:	81 ec 28 01 00 00    	sub    $0x128,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c3d:	e8 cb 38 00 00       	call   8010450d <myproc>
80100c42:	89 45 cc             	mov    %eax,-0x34(%ebp)

  begin_op();
80100c45:	e8 04 2b 00 00       	call   8010374e <begin_op>

  if((ip = namei(path)) == 0){
80100c4a:	83 ec 0c             	sub    $0xc,%esp
80100c4d:	ff 75 08             	pushl  0x8(%ebp)
80100c50:	e8 6f 1a 00 00       	call   801026c4 <namei>
80100c55:	83 c4 10             	add    $0x10,%esp
80100c58:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c5b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c5f:	75 1f                	jne    80100c80 <exec+0x50>
    end_op();
80100c61:	e8 78 2b 00 00       	call   801037de <end_op>
    cprintf("exec: fail\n");
80100c66:	83 ec 0c             	sub    $0xc,%esp
80100c69:	68 1d 93 10 80       	push   $0x8010931d
80100c6e:	e8 a5 f7 ff ff       	call   80100418 <cprintf>
80100c73:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c7b:	e9 6f 04 00 00       	jmp    801010ef <exec+0x4bf>
  }
  ilock(ip);
80100c80:	83 ec 0c             	sub    $0xc,%esp
80100c83:	ff 75 d8             	pushl  -0x28(%ebp)
80100c86:	e8 ce 0e 00 00       	call   80101b59 <ilock>
80100c8b:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c8e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c95:	6a 34                	push   $0x34
80100c97:	6a 00                	push   $0x0
80100c99:	8d 85 fc fe ff ff    	lea    -0x104(%ebp),%eax
80100c9f:	50                   	push   %eax
80100ca0:	ff 75 d8             	pushl  -0x28(%ebp)
80100ca3:	e8 b9 13 00 00       	call   80102061 <readi>
80100ca8:	83 c4 10             	add    $0x10,%esp
80100cab:	83 f8 34             	cmp    $0x34,%eax
80100cae:	0f 85 e4 03 00 00    	jne    80101098 <exec+0x468>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cb4:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cba:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cbf:	0f 85 d6 03 00 00    	jne    8010109b <exec+0x46b>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100cc5:	e8 32 74 00 00       	call   801080fc <setupkvm>
80100cca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ccd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cd1:	0f 84 c7 03 00 00    	je     8010109e <exec+0x46e>
    goto bad;

  // Load program into memory.
  sz = 0;
80100cd7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cde:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ce5:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100ceb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cee:	e9 de 00 00 00       	jmp    80100dd1 <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cf6:	6a 20                	push   $0x20
80100cf8:	50                   	push   %eax
80100cf9:	8d 85 dc fe ff ff    	lea    -0x124(%ebp),%eax
80100cff:	50                   	push   %eax
80100d00:	ff 75 d8             	pushl  -0x28(%ebp)
80100d03:	e8 59 13 00 00       	call   80102061 <readi>
80100d08:	83 c4 10             	add    $0x10,%esp
80100d0b:	83 f8 20             	cmp    $0x20,%eax
80100d0e:	0f 85 8d 03 00 00    	jne    801010a1 <exec+0x471>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d14:	8b 85 dc fe ff ff    	mov    -0x124(%ebp),%eax
80100d1a:	83 f8 01             	cmp    $0x1,%eax
80100d1d:	0f 85 a0 00 00 00    	jne    80100dc3 <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100d23:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d29:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d2f:	39 c2                	cmp    %eax,%edx
80100d31:	0f 82 6d 03 00 00    	jb     801010a4 <exec+0x474>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d37:	8b 95 e4 fe ff ff    	mov    -0x11c(%ebp),%edx
80100d3d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d43:	01 c2                	add    %eax,%edx
80100d45:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100d4b:	39 c2                	cmp    %eax,%edx
80100d4d:	0f 82 54 03 00 00    	jb     801010a7 <exec+0x477>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d53:	8b 95 e4 fe ff ff    	mov    -0x11c(%ebp),%edx
80100d59:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d5f:	01 d0                	add    %edx,%eax
80100d61:	83 ec 04             	sub    $0x4,%esp
80100d64:	50                   	push   %eax
80100d65:	ff 75 e0             	pushl  -0x20(%ebp)
80100d68:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d6b:	e8 4a 77 00 00       	call   801084ba <allocuvm>
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7a:	0f 84 2a 03 00 00    	je     801010aa <exec+0x47a>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d80:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100d86:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 1a 03 00 00    	jne    801010ad <exec+0x47d>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d93:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d99:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
80100d9f:	8b 8d e4 fe ff ff    	mov    -0x11c(%ebp),%ecx
80100da5:	83 ec 0c             	sub    $0xc,%esp
80100da8:	52                   	push   %edx
80100da9:	50                   	push   %eax
80100daa:	ff 75 d8             	pushl  -0x28(%ebp)
80100dad:	51                   	push   %ecx
80100dae:	ff 75 d4             	pushl  -0x2c(%ebp)
80100db1:	e8 33 76 00 00       	call   801083e9 <loaduvm>
80100db6:	83 c4 20             	add    $0x20,%esp
80100db9:	85 c0                	test   %eax,%eax
80100dbb:	0f 88 ef 02 00 00    	js     801010b0 <exec+0x480>
80100dc1:	eb 01                	jmp    80100dc4 <exec+0x194>
      continue;
80100dc3:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100dc4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100dc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100dcb:	83 c0 20             	add    $0x20,%eax
80100dce:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100dd1:	0f b7 85 28 ff ff ff 	movzwl -0xd8(%ebp),%eax
80100dd8:	0f b7 c0             	movzwl %ax,%eax
80100ddb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100dde:	0f 8c 0f ff ff ff    	jl     80100cf3 <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100de4:	83 ec 0c             	sub    $0xc,%esp
80100de7:	ff 75 d8             	pushl  -0x28(%ebp)
80100dea:	e8 a7 0f 00 00       	call   80101d96 <iunlockput>
80100def:	83 c4 10             	add    $0x10,%esp
  end_op();
80100df2:	e8 e7 29 00 00       	call   801037de <end_op>
  ip = 0;
80100df7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)


  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e01:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  int tempsz = sz;
80100e0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e11:	89 45 c8             	mov    %eax,-0x38(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e17:	05 00 20 00 00       	add    $0x2000,%eax
80100e1c:	83 ec 04             	sub    $0x4,%esp
80100e1f:	50                   	push   %eax
80100e20:	ff 75 e0             	pushl  -0x20(%ebp)
80100e23:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e26:	e8 8f 76 00 00       	call   801084ba <allocuvm>
80100e2b:	83 c4 10             	add    $0x10,%esp
80100e2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e31:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e35:	0f 84 78 02 00 00    	je     801010b3 <exec+0x483>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e3e:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e43:	83 ec 08             	sub    $0x8,%esp
80100e46:	50                   	push   %eax
80100e47:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e4a:	e8 dd 78 00 00       	call   8010872c <clearpteu>
80100e4f:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e55:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e58:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e5f:	e9 96 00 00 00       	jmp    80100efa <exec+0x2ca>
    if(argc >= MAXARG)
80100e64:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e68:	0f 87 48 02 00 00    	ja     801010b6 <exec+0x486>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e78:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e7b:	01 d0                	add    %edx,%eax
80100e7d:	8b 00                	mov    (%eax),%eax
80100e7f:	83 ec 0c             	sub    $0xc,%esp
80100e82:	50                   	push   %eax
80100e83:	e8 97 49 00 00       	call   8010581f <strlen>
80100e88:	83 c4 10             	add    $0x10,%esp
80100e8b:	89 c2                	mov    %eax,%edx
80100e8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e90:	29 d0                	sub    %edx,%eax
80100e92:	83 e8 01             	sub    $0x1,%eax
80100e95:	83 e0 fc             	and    $0xfffffffc,%eax
80100e98:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea8:	01 d0                	add    %edx,%eax
80100eaa:	8b 00                	mov    (%eax),%eax
80100eac:	83 ec 0c             	sub    $0xc,%esp
80100eaf:	50                   	push   %eax
80100eb0:	e8 6a 49 00 00       	call   8010581f <strlen>
80100eb5:	83 c4 10             	add    $0x10,%esp
80100eb8:	83 c0 01             	add    $0x1,%eax
80100ebb:	89 c1                	mov    %eax,%ecx
80100ebd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eca:	01 d0                	add    %edx,%eax
80100ecc:	8b 00                	mov    (%eax),%eax
80100ece:	51                   	push   %ecx
80100ecf:	50                   	push   %eax
80100ed0:	ff 75 dc             	pushl  -0x24(%ebp)
80100ed3:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ed6:	e8 0d 7a 00 00       	call   801088e8 <copyout>
80100edb:	83 c4 10             	add    $0x10,%esp
80100ede:	85 c0                	test   %eax,%eax
80100ee0:	0f 88 d3 01 00 00    	js     801010b9 <exec+0x489>
      goto bad;
    ustack[3+argc] = sp;
80100ee6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee9:	8d 50 03             	lea    0x3(%eax),%edx
80100eec:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100eef:	89 84 95 30 ff ff ff 	mov    %eax,-0xd0(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100ef6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100efd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f04:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f07:	01 d0                	add    %edx,%eax
80100f09:	8b 00                	mov    (%eax),%eax
80100f0b:	85 c0                	test   %eax,%eax
80100f0d:	0f 85 51 ff ff ff    	jne    80100e64 <exec+0x234>
  }
  ustack[3+argc] = 0;
80100f13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f16:	83 c0 03             	add    $0x3,%eax
80100f19:	c7 84 85 30 ff ff ff 	movl   $0x0,-0xd0(%ebp,%eax,4)
80100f20:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f24:	c7 85 30 ff ff ff ff 	movl   $0xffffffff,-0xd0(%ebp)
80100f2b:	ff ff ff 
  ustack[1] = argc;
80100f2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f31:	89 85 34 ff ff ff    	mov    %eax,-0xcc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f3a:	83 c0 01             	add    $0x1,%eax
80100f3d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f44:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f47:	29 d0                	sub    %edx,%eax
80100f49:	89 85 38 ff ff ff    	mov    %eax,-0xc8(%ebp)

  sp -= (3+argc+1) * 4;
80100f4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f52:	83 c0 04             	add    $0x4,%eax
80100f55:	c1 e0 02             	shl    $0x2,%eax
80100f58:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f5e:	83 c0 04             	add    $0x4,%eax
80100f61:	c1 e0 02             	shl    $0x2,%eax
80100f64:	50                   	push   %eax
80100f65:	8d 85 30 ff ff ff    	lea    -0xd0(%ebp),%eax
80100f6b:	50                   	push   %eax
80100f6c:	ff 75 dc             	pushl  -0x24(%ebp)
80100f6f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f72:	e8 71 79 00 00       	call   801088e8 <copyout>
80100f77:	83 c4 10             	add    $0x10,%esp
80100f7a:	85 c0                	test   %eax,%eax
80100f7c:	0f 88 3a 01 00 00    	js     801010bc <exec+0x48c>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f82:	8b 45 08             	mov    0x8(%ebp),%eax
80100f85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f8e:	eb 17                	jmp    80100fa7 <exec+0x377>
    if(*s == '/')
80100f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f93:	0f b6 00             	movzbl (%eax),%eax
80100f96:	3c 2f                	cmp    $0x2f,%al
80100f98:	75 09                	jne    80100fa3 <exec+0x373>
      last = s+1;
80100f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f9d:	83 c0 01             	add    $0x1,%eax
80100fa0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100fa3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100faa:	0f b6 00             	movzbl (%eax),%eax
80100fad:	84 c0                	test   %al,%al
80100faf:	75 df                	jne    80100f90 <exec+0x360>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fb1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fb4:	83 c0 6c             	add    $0x6c,%eax
80100fb7:	83 ec 04             	sub    $0x4,%esp
80100fba:	6a 10                	push   $0x10
80100fbc:	ff 75 f0             	pushl  -0x10(%ebp)
80100fbf:	50                   	push   %eax
80100fc0:	e8 0c 48 00 00       	call   801057d1 <safestrcpy>
80100fc5:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100fc8:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fcb:	8b 40 04             	mov    0x4(%eax),%eax
80100fce:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  curproc->pgdir = pgdir;
80100fd1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fd4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fd7:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100fda:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fdd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fe0:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fe2:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fe5:	8b 40 18             	mov    0x18(%eax),%eax
80100fe8:	8b 95 14 ff ff ff    	mov    -0xec(%ebp),%edx
80100fee:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100ff1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100ff4:	8b 40 18             	mov    0x18(%eax),%eax
80100ff7:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ffa:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100ffd:	83 ec 0c             	sub    $0xc,%esp
80101000:	ff 75 cc             	pushl  -0x34(%ebp)
80101003:	e8 ca 71 00 00       	call   801081d2 <switchuvm>
80101008:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
8010100b:	83 ec 0c             	sub    $0xc,%esp
8010100e:	ff 75 c4             	pushl  -0x3c(%ebp)
80101011:	e8 77 76 00 00       	call   8010868d <freevm>
80101016:	83 c4 10             	add    $0x10,%esp

  mencrypt((char *)(tempsz+PGSIZE),1);
80101019:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010101c:	05 00 10 00 00       	add    $0x1000,%eax
80101021:	83 ec 08             	sub    $0x8,%esp
80101024:	6a 01                	push   $0x1
80101026:	50                   	push   %eax
80101027:	e8 65 7d 00 00       	call   80108d91 <mencrypt>
8010102c:	83 c4 10             	add    $0x10,%esp
  int pages = tempsz/PGSIZE;
8010102f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101032:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101038:	85 c0                	test   %eax,%eax
8010103a:	0f 48 c2             	cmovs  %edx,%eax
8010103d:	c1 f8 0c             	sar    $0xc,%eax
80101040:	89 45 c0             	mov    %eax,-0x40(%ebp)
  mencrypt(0,pages);
80101043:	83 ec 08             	sub    $0x8,%esp
80101046:	ff 75 c0             	pushl  -0x40(%ebp)
80101049:	6a 00                	push   $0x0
8010104b:	e8 41 7d 00 00       	call   80108d91 <mencrypt>
80101050:	83 c4 10             	add    $0x10,%esp
  for(int i =0;i<CLOCKSIZE;i++){
80101053:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010105a:	eb 2f                	jmp    8010108b <exec+0x45b>
    curproc->clock[i]=-1;
8010105c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010105f:	8b 55 d0             	mov    -0x30(%ebp),%edx
80101062:	83 c2 1c             	add    $0x1c,%edx
80101065:	c7 44 90 0c ff ff ff 	movl   $0xffffffff,0xc(%eax,%edx,4)
8010106c:	ff 
    curproc->clock_hand=0;
8010106d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101070:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
80101077:	00 00 00 
    curproc->current_searches=0;
8010107a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010107d:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
80101084:	00 00 00 
  for(int i =0;i<CLOCKSIZE;i++){
80101087:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
8010108b:	83 7d d0 07          	cmpl   $0x7,-0x30(%ebp)
8010108f:	7e cb                	jle    8010105c <exec+0x42c>
  }
  return 0;
80101091:	b8 00 00 00 00       	mov    $0x0,%eax
80101096:	eb 57                	jmp    801010ef <exec+0x4bf>
    goto bad;
80101098:	90                   	nop
80101099:	eb 22                	jmp    801010bd <exec+0x48d>
    goto bad;
8010109b:	90                   	nop
8010109c:	eb 1f                	jmp    801010bd <exec+0x48d>
    goto bad;
8010109e:	90                   	nop
8010109f:	eb 1c                	jmp    801010bd <exec+0x48d>
      goto bad;
801010a1:	90                   	nop
801010a2:	eb 19                	jmp    801010bd <exec+0x48d>
      goto bad;
801010a4:	90                   	nop
801010a5:	eb 16                	jmp    801010bd <exec+0x48d>
      goto bad;
801010a7:	90                   	nop
801010a8:	eb 13                	jmp    801010bd <exec+0x48d>
      goto bad;
801010aa:	90                   	nop
801010ab:	eb 10                	jmp    801010bd <exec+0x48d>
      goto bad;
801010ad:	90                   	nop
801010ae:	eb 0d                	jmp    801010bd <exec+0x48d>
      goto bad;
801010b0:	90                   	nop
801010b1:	eb 0a                	jmp    801010bd <exec+0x48d>
    goto bad;
801010b3:	90                   	nop
801010b4:	eb 07                	jmp    801010bd <exec+0x48d>
      goto bad;
801010b6:	90                   	nop
801010b7:	eb 04                	jmp    801010bd <exec+0x48d>
      goto bad;
801010b9:	90                   	nop
801010ba:	eb 01                	jmp    801010bd <exec+0x48d>
    goto bad;
801010bc:	90                   	nop

 bad:
  if(pgdir)
801010bd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801010c1:	74 0e                	je     801010d1 <exec+0x4a1>
    freevm(pgdir);
801010c3:	83 ec 0c             	sub    $0xc,%esp
801010c6:	ff 75 d4             	pushl  -0x2c(%ebp)
801010c9:	e8 bf 75 00 00       	call   8010868d <freevm>
801010ce:	83 c4 10             	add    $0x10,%esp
  if(ip){
801010d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010d5:	74 13                	je     801010ea <exec+0x4ba>
    iunlockput(ip);
801010d7:	83 ec 0c             	sub    $0xc,%esp
801010da:	ff 75 d8             	pushl  -0x28(%ebp)
801010dd:	e8 b4 0c 00 00       	call   80101d96 <iunlockput>
801010e2:	83 c4 10             	add    $0x10,%esp
    end_op();
801010e5:	e8 f4 26 00 00       	call   801037de <end_op>
  }
  return -1;
801010ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010ef:	c9                   	leave  
801010f0:	c3                   	ret    

801010f1 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010f1:	f3 0f 1e fb          	endbr32 
801010f5:	55                   	push   %ebp
801010f6:	89 e5                	mov    %esp,%ebp
801010f8:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010fb:	83 ec 08             	sub    $0x8,%esp
801010fe:	68 29 93 10 80       	push   $0x80109329
80101103:	68 60 20 11 80       	push   $0x80112060
80101108:	e8 e4 41 00 00       	call   801052f1 <initlock>
8010110d:	83 c4 10             	add    $0x10,%esp
}
80101110:	90                   	nop
80101111:	c9                   	leave  
80101112:	c3                   	ret    

80101113 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101113:	f3 0f 1e fb          	endbr32 
80101117:	55                   	push   %ebp
80101118:	89 e5                	mov    %esp,%ebp
8010111a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010111d:	83 ec 0c             	sub    $0xc,%esp
80101120:	68 60 20 11 80       	push   $0x80112060
80101125:	e8 ed 41 00 00       	call   80105317 <acquire>
8010112a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010112d:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
80101134:	eb 2d                	jmp    80101163 <filealloc+0x50>
    if(f->ref == 0){
80101136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101139:	8b 40 04             	mov    0x4(%eax),%eax
8010113c:	85 c0                	test   %eax,%eax
8010113e:	75 1f                	jne    8010115f <filealloc+0x4c>
      f->ref = 1;
80101140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101143:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010114a:	83 ec 0c             	sub    $0xc,%esp
8010114d:	68 60 20 11 80       	push   $0x80112060
80101152:	e8 32 42 00 00       	call   80105389 <release>
80101157:	83 c4 10             	add    $0x10,%esp
      return f;
8010115a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010115d:	eb 23                	jmp    80101182 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010115f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101163:	b8 f4 29 11 80       	mov    $0x801129f4,%eax
80101168:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010116b:	72 c9                	jb     80101136 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010116d:	83 ec 0c             	sub    $0xc,%esp
80101170:	68 60 20 11 80       	push   $0x80112060
80101175:	e8 0f 42 00 00       	call   80105389 <release>
8010117a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010117d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101182:	c9                   	leave  
80101183:	c3                   	ret    

80101184 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101184:	f3 0f 1e fb          	endbr32 
80101188:	55                   	push   %ebp
80101189:	89 e5                	mov    %esp,%ebp
8010118b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010118e:	83 ec 0c             	sub    $0xc,%esp
80101191:	68 60 20 11 80       	push   $0x80112060
80101196:	e8 7c 41 00 00       	call   80105317 <acquire>
8010119b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010119e:	8b 45 08             	mov    0x8(%ebp),%eax
801011a1:	8b 40 04             	mov    0x4(%eax),%eax
801011a4:	85 c0                	test   %eax,%eax
801011a6:	7f 0d                	jg     801011b5 <filedup+0x31>
    panic("filedup");
801011a8:	83 ec 0c             	sub    $0xc,%esp
801011ab:	68 30 93 10 80       	push   $0x80109330
801011b0:	e8 53 f4 ff ff       	call   80100608 <panic>
  f->ref++;
801011b5:	8b 45 08             	mov    0x8(%ebp),%eax
801011b8:	8b 40 04             	mov    0x4(%eax),%eax
801011bb:	8d 50 01             	lea    0x1(%eax),%edx
801011be:	8b 45 08             	mov    0x8(%ebp),%eax
801011c1:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801011c4:	83 ec 0c             	sub    $0xc,%esp
801011c7:	68 60 20 11 80       	push   $0x80112060
801011cc:	e8 b8 41 00 00       	call   80105389 <release>
801011d1:	83 c4 10             	add    $0x10,%esp
  return f;
801011d4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011d7:	c9                   	leave  
801011d8:	c3                   	ret    

801011d9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011d9:	f3 0f 1e fb          	endbr32 
801011dd:	55                   	push   %ebp
801011de:	89 e5                	mov    %esp,%ebp
801011e0:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801011e3:	83 ec 0c             	sub    $0xc,%esp
801011e6:	68 60 20 11 80       	push   $0x80112060
801011eb:	e8 27 41 00 00       	call   80105317 <acquire>
801011f0:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011f3:	8b 45 08             	mov    0x8(%ebp),%eax
801011f6:	8b 40 04             	mov    0x4(%eax),%eax
801011f9:	85 c0                	test   %eax,%eax
801011fb:	7f 0d                	jg     8010120a <fileclose+0x31>
    panic("fileclose");
801011fd:	83 ec 0c             	sub    $0xc,%esp
80101200:	68 38 93 10 80       	push   $0x80109338
80101205:	e8 fe f3 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
8010120a:	8b 45 08             	mov    0x8(%ebp),%eax
8010120d:	8b 40 04             	mov    0x4(%eax),%eax
80101210:	8d 50 ff             	lea    -0x1(%eax),%edx
80101213:	8b 45 08             	mov    0x8(%ebp),%eax
80101216:	89 50 04             	mov    %edx,0x4(%eax)
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 40 04             	mov    0x4(%eax),%eax
8010121f:	85 c0                	test   %eax,%eax
80101221:	7e 15                	jle    80101238 <fileclose+0x5f>
    release(&ftable.lock);
80101223:	83 ec 0c             	sub    $0xc,%esp
80101226:	68 60 20 11 80       	push   $0x80112060
8010122b:	e8 59 41 00 00       	call   80105389 <release>
80101230:	83 c4 10             	add    $0x10,%esp
80101233:	e9 8b 00 00 00       	jmp    801012c3 <fileclose+0xea>
    return;
  }
  ff = *f;
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 10                	mov    (%eax),%edx
8010123d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101240:	8b 50 04             	mov    0x4(%eax),%edx
80101243:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101246:	8b 50 08             	mov    0x8(%eax),%edx
80101249:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010124c:	8b 50 0c             	mov    0xc(%eax),%edx
8010124f:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101252:	8b 50 10             	mov    0x10(%eax),%edx
80101255:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101258:	8b 40 14             	mov    0x14(%eax),%eax
8010125b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010125e:	8b 45 08             	mov    0x8(%ebp),%eax
80101261:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101268:	8b 45 08             	mov    0x8(%ebp),%eax
8010126b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101271:	83 ec 0c             	sub    $0xc,%esp
80101274:	68 60 20 11 80       	push   $0x80112060
80101279:	e8 0b 41 00 00       	call   80105389 <release>
8010127e:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101281:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101284:	83 f8 01             	cmp    $0x1,%eax
80101287:	75 19                	jne    801012a2 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101289:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010128d:	0f be d0             	movsbl %al,%edx
80101290:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101293:	83 ec 08             	sub    $0x8,%esp
80101296:	52                   	push   %edx
80101297:	50                   	push   %eax
80101298:	e8 e7 2e 00 00       	call   80104184 <pipeclose>
8010129d:	83 c4 10             	add    $0x10,%esp
801012a0:	eb 21                	jmp    801012c3 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801012a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801012a5:	83 f8 02             	cmp    $0x2,%eax
801012a8:	75 19                	jne    801012c3 <fileclose+0xea>
    begin_op();
801012aa:	e8 9f 24 00 00       	call   8010374e <begin_op>
    iput(ff.ip);
801012af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012b2:	83 ec 0c             	sub    $0xc,%esp
801012b5:	50                   	push   %eax
801012b6:	e8 07 0a 00 00       	call   80101cc2 <iput>
801012bb:	83 c4 10             	add    $0x10,%esp
    end_op();
801012be:	e8 1b 25 00 00       	call   801037de <end_op>
  }
}
801012c3:	c9                   	leave  
801012c4:	c3                   	ret    

801012c5 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801012c5:	f3 0f 1e fb          	endbr32 
801012c9:	55                   	push   %ebp
801012ca:	89 e5                	mov    %esp,%ebp
801012cc:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801012cf:	8b 45 08             	mov    0x8(%ebp),%eax
801012d2:	8b 00                	mov    (%eax),%eax
801012d4:	83 f8 02             	cmp    $0x2,%eax
801012d7:	75 40                	jne    80101319 <filestat+0x54>
    ilock(f->ip);
801012d9:	8b 45 08             	mov    0x8(%ebp),%eax
801012dc:	8b 40 10             	mov    0x10(%eax),%eax
801012df:	83 ec 0c             	sub    $0xc,%esp
801012e2:	50                   	push   %eax
801012e3:	e8 71 08 00 00       	call   80101b59 <ilock>
801012e8:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801012eb:	8b 45 08             	mov    0x8(%ebp),%eax
801012ee:	8b 40 10             	mov    0x10(%eax),%eax
801012f1:	83 ec 08             	sub    $0x8,%esp
801012f4:	ff 75 0c             	pushl  0xc(%ebp)
801012f7:	50                   	push   %eax
801012f8:	e8 1a 0d 00 00       	call   80102017 <stati>
801012fd:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101300:	8b 45 08             	mov    0x8(%ebp),%eax
80101303:	8b 40 10             	mov    0x10(%eax),%eax
80101306:	83 ec 0c             	sub    $0xc,%esp
80101309:	50                   	push   %eax
8010130a:	e8 61 09 00 00       	call   80101c70 <iunlock>
8010130f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101312:	b8 00 00 00 00       	mov    $0x0,%eax
80101317:	eb 05                	jmp    8010131e <filestat+0x59>
  }
  return -1;
80101319:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010131e:	c9                   	leave  
8010131f:	c3                   	ret    

80101320 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101320:	f3 0f 1e fb          	endbr32 
80101324:	55                   	push   %ebp
80101325:	89 e5                	mov    %esp,%ebp
80101327:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010132a:	8b 45 08             	mov    0x8(%ebp),%eax
8010132d:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101331:	84 c0                	test   %al,%al
80101333:	75 0a                	jne    8010133f <fileread+0x1f>
    return -1;
80101335:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010133a:	e9 9b 00 00 00       	jmp    801013da <fileread+0xba>
  if(f->type == FD_PIPE)
8010133f:	8b 45 08             	mov    0x8(%ebp),%eax
80101342:	8b 00                	mov    (%eax),%eax
80101344:	83 f8 01             	cmp    $0x1,%eax
80101347:	75 1a                	jne    80101363 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101349:	8b 45 08             	mov    0x8(%ebp),%eax
8010134c:	8b 40 0c             	mov    0xc(%eax),%eax
8010134f:	83 ec 04             	sub    $0x4,%esp
80101352:	ff 75 10             	pushl  0x10(%ebp)
80101355:	ff 75 0c             	pushl  0xc(%ebp)
80101358:	50                   	push   %eax
80101359:	e8 db 2f 00 00       	call   80104339 <piperead>
8010135e:	83 c4 10             	add    $0x10,%esp
80101361:	eb 77                	jmp    801013da <fileread+0xba>
  if(f->type == FD_INODE){
80101363:	8b 45 08             	mov    0x8(%ebp),%eax
80101366:	8b 00                	mov    (%eax),%eax
80101368:	83 f8 02             	cmp    $0x2,%eax
8010136b:	75 60                	jne    801013cd <fileread+0xad>
    ilock(f->ip);
8010136d:	8b 45 08             	mov    0x8(%ebp),%eax
80101370:	8b 40 10             	mov    0x10(%eax),%eax
80101373:	83 ec 0c             	sub    $0xc,%esp
80101376:	50                   	push   %eax
80101377:	e8 dd 07 00 00       	call   80101b59 <ilock>
8010137c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010137f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101382:	8b 45 08             	mov    0x8(%ebp),%eax
80101385:	8b 50 14             	mov    0x14(%eax),%edx
80101388:	8b 45 08             	mov    0x8(%ebp),%eax
8010138b:	8b 40 10             	mov    0x10(%eax),%eax
8010138e:	51                   	push   %ecx
8010138f:	52                   	push   %edx
80101390:	ff 75 0c             	pushl  0xc(%ebp)
80101393:	50                   	push   %eax
80101394:	e8 c8 0c 00 00       	call   80102061 <readi>
80101399:	83 c4 10             	add    $0x10,%esp
8010139c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010139f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801013a3:	7e 11                	jle    801013b6 <fileread+0x96>
      f->off += r;
801013a5:	8b 45 08             	mov    0x8(%ebp),%eax
801013a8:	8b 50 14             	mov    0x14(%eax),%edx
801013ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ae:	01 c2                	add    %eax,%edx
801013b0:	8b 45 08             	mov    0x8(%ebp),%eax
801013b3:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801013b6:	8b 45 08             	mov    0x8(%ebp),%eax
801013b9:	8b 40 10             	mov    0x10(%eax),%eax
801013bc:	83 ec 0c             	sub    $0xc,%esp
801013bf:	50                   	push   %eax
801013c0:	e8 ab 08 00 00       	call   80101c70 <iunlock>
801013c5:	83 c4 10             	add    $0x10,%esp
    return r;
801013c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013cb:	eb 0d                	jmp    801013da <fileread+0xba>
  }
  panic("fileread");
801013cd:	83 ec 0c             	sub    $0xc,%esp
801013d0:	68 42 93 10 80       	push   $0x80109342
801013d5:	e8 2e f2 ff ff       	call   80100608 <panic>
}
801013da:	c9                   	leave  
801013db:	c3                   	ret    

801013dc <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801013dc:	f3 0f 1e fb          	endbr32 
801013e0:	55                   	push   %ebp
801013e1:	89 e5                	mov    %esp,%ebp
801013e3:	53                   	push   %ebx
801013e4:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801013e7:	8b 45 08             	mov    0x8(%ebp),%eax
801013ea:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801013ee:	84 c0                	test   %al,%al
801013f0:	75 0a                	jne    801013fc <filewrite+0x20>
    return -1;
801013f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013f7:	e9 1b 01 00 00       	jmp    80101517 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801013fc:	8b 45 08             	mov    0x8(%ebp),%eax
801013ff:	8b 00                	mov    (%eax),%eax
80101401:	83 f8 01             	cmp    $0x1,%eax
80101404:	75 1d                	jne    80101423 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101406:	8b 45 08             	mov    0x8(%ebp),%eax
80101409:	8b 40 0c             	mov    0xc(%eax),%eax
8010140c:	83 ec 04             	sub    $0x4,%esp
8010140f:	ff 75 10             	pushl  0x10(%ebp)
80101412:	ff 75 0c             	pushl  0xc(%ebp)
80101415:	50                   	push   %eax
80101416:	e8 18 2e 00 00       	call   80104233 <pipewrite>
8010141b:	83 c4 10             	add    $0x10,%esp
8010141e:	e9 f4 00 00 00       	jmp    80101517 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101423:	8b 45 08             	mov    0x8(%ebp),%eax
80101426:	8b 00                	mov    (%eax),%eax
80101428:	83 f8 02             	cmp    $0x2,%eax
8010142b:	0f 85 d9 00 00 00    	jne    8010150a <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101431:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101438:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010143f:	e9 a3 00 00 00       	jmp    801014e7 <filewrite+0x10b>
      int n1 = n - i;
80101444:	8b 45 10             	mov    0x10(%ebp),%eax
80101447:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010144a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010144d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101450:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101453:	7e 06                	jle    8010145b <filewrite+0x7f>
        n1 = max;
80101455:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101458:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010145b:	e8 ee 22 00 00       	call   8010374e <begin_op>
      ilock(f->ip);
80101460:	8b 45 08             	mov    0x8(%ebp),%eax
80101463:	8b 40 10             	mov    0x10(%eax),%eax
80101466:	83 ec 0c             	sub    $0xc,%esp
80101469:	50                   	push   %eax
8010146a:	e8 ea 06 00 00       	call   80101b59 <ilock>
8010146f:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101472:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101475:	8b 45 08             	mov    0x8(%ebp),%eax
80101478:	8b 50 14             	mov    0x14(%eax),%edx
8010147b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010147e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101481:	01 c3                	add    %eax,%ebx
80101483:	8b 45 08             	mov    0x8(%ebp),%eax
80101486:	8b 40 10             	mov    0x10(%eax),%eax
80101489:	51                   	push   %ecx
8010148a:	52                   	push   %edx
8010148b:	53                   	push   %ebx
8010148c:	50                   	push   %eax
8010148d:	e8 28 0d 00 00       	call   801021ba <writei>
80101492:	83 c4 10             	add    $0x10,%esp
80101495:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101498:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010149c:	7e 11                	jle    801014af <filewrite+0xd3>
        f->off += r;
8010149e:	8b 45 08             	mov    0x8(%ebp),%eax
801014a1:	8b 50 14             	mov    0x14(%eax),%edx
801014a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014a7:	01 c2                	add    %eax,%edx
801014a9:	8b 45 08             	mov    0x8(%ebp),%eax
801014ac:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801014af:	8b 45 08             	mov    0x8(%ebp),%eax
801014b2:	8b 40 10             	mov    0x10(%eax),%eax
801014b5:	83 ec 0c             	sub    $0xc,%esp
801014b8:	50                   	push   %eax
801014b9:	e8 b2 07 00 00       	call   80101c70 <iunlock>
801014be:	83 c4 10             	add    $0x10,%esp
      end_op();
801014c1:	e8 18 23 00 00       	call   801037de <end_op>

      if(r < 0)
801014c6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801014ca:	78 29                	js     801014f5 <filewrite+0x119>
        break;
      if(r != n1)
801014cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014cf:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801014d2:	74 0d                	je     801014e1 <filewrite+0x105>
        panic("short filewrite");
801014d4:	83 ec 0c             	sub    $0xc,%esp
801014d7:	68 4b 93 10 80       	push   $0x8010934b
801014dc:	e8 27 f1 ff ff       	call   80100608 <panic>
      i += r;
801014e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014e4:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801014e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ea:	3b 45 10             	cmp    0x10(%ebp),%eax
801014ed:	0f 8c 51 ff ff ff    	jl     80101444 <filewrite+0x68>
801014f3:	eb 01                	jmp    801014f6 <filewrite+0x11a>
        break;
801014f5:	90                   	nop
    }
    return i == n ? n : -1;
801014f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014f9:	3b 45 10             	cmp    0x10(%ebp),%eax
801014fc:	75 05                	jne    80101503 <filewrite+0x127>
801014fe:	8b 45 10             	mov    0x10(%ebp),%eax
80101501:	eb 14                	jmp    80101517 <filewrite+0x13b>
80101503:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101508:	eb 0d                	jmp    80101517 <filewrite+0x13b>
  }
  panic("filewrite");
8010150a:	83 ec 0c             	sub    $0xc,%esp
8010150d:	68 5b 93 10 80       	push   $0x8010935b
80101512:	e8 f1 f0 ff ff       	call   80100608 <panic>
}
80101517:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010151a:	c9                   	leave  
8010151b:	c3                   	ret    

8010151c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010151c:	f3 0f 1e fb          	endbr32 
80101520:	55                   	push   %ebp
80101521:	89 e5                	mov    %esp,%ebp
80101523:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101526:	8b 45 08             	mov    0x8(%ebp),%eax
80101529:	83 ec 08             	sub    $0x8,%esp
8010152c:	6a 01                	push   $0x1
8010152e:	50                   	push   %eax
8010152f:	e8 a3 ec ff ff       	call   801001d7 <bread>
80101534:	83 c4 10             	add    $0x10,%esp
80101537:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010153a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010153d:	83 c0 5c             	add    $0x5c,%eax
80101540:	83 ec 04             	sub    $0x4,%esp
80101543:	6a 1c                	push   $0x1c
80101545:	50                   	push   %eax
80101546:	ff 75 0c             	pushl  0xc(%ebp)
80101549:	e8 2f 41 00 00       	call   8010567d <memmove>
8010154e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101551:	83 ec 0c             	sub    $0xc,%esp
80101554:	ff 75 f4             	pushl  -0xc(%ebp)
80101557:	e8 05 ed ff ff       	call   80100261 <brelse>
8010155c:	83 c4 10             	add    $0x10,%esp
}
8010155f:	90                   	nop
80101560:	c9                   	leave  
80101561:	c3                   	ret    

80101562 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101562:	f3 0f 1e fb          	endbr32 
80101566:	55                   	push   %ebp
80101567:	89 e5                	mov    %esp,%ebp
80101569:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010156c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010156f:	8b 45 08             	mov    0x8(%ebp),%eax
80101572:	83 ec 08             	sub    $0x8,%esp
80101575:	52                   	push   %edx
80101576:	50                   	push   %eax
80101577:	e8 5b ec ff ff       	call   801001d7 <bread>
8010157c:	83 c4 10             	add    $0x10,%esp
8010157f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101585:	83 c0 5c             	add    $0x5c,%eax
80101588:	83 ec 04             	sub    $0x4,%esp
8010158b:	68 00 02 00 00       	push   $0x200
80101590:	6a 00                	push   $0x0
80101592:	50                   	push   %eax
80101593:	e8 1e 40 00 00       	call   801055b6 <memset>
80101598:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010159b:	83 ec 0c             	sub    $0xc,%esp
8010159e:	ff 75 f4             	pushl  -0xc(%ebp)
801015a1:	e8 f1 23 00 00       	call   80103997 <log_write>
801015a6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801015a9:	83 ec 0c             	sub    $0xc,%esp
801015ac:	ff 75 f4             	pushl  -0xc(%ebp)
801015af:	e8 ad ec ff ff       	call   80100261 <brelse>
801015b4:	83 c4 10             	add    $0x10,%esp
}
801015b7:	90                   	nop
801015b8:	c9                   	leave  
801015b9:	c3                   	ret    

801015ba <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801015ba:	f3 0f 1e fb          	endbr32 
801015be:	55                   	push   %ebp
801015bf:	89 e5                	mov    %esp,%ebp
801015c1:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801015c4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801015cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801015d2:	e9 13 01 00 00       	jmp    801016ea <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801015d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015da:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801015e0:	85 c0                	test   %eax,%eax
801015e2:	0f 48 c2             	cmovs  %edx,%eax
801015e5:	c1 f8 0c             	sar    $0xc,%eax
801015e8:	89 c2                	mov    %eax,%edx
801015ea:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801015ef:	01 d0                	add    %edx,%eax
801015f1:	83 ec 08             	sub    $0x8,%esp
801015f4:	50                   	push   %eax
801015f5:	ff 75 08             	pushl  0x8(%ebp)
801015f8:	e8 da eb ff ff       	call   801001d7 <bread>
801015fd:	83 c4 10             	add    $0x10,%esp
80101600:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101603:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010160a:	e9 a6 00 00 00       	jmp    801016b5 <balloc+0xfb>
      m = 1 << (bi % 8);
8010160f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101612:	99                   	cltd   
80101613:	c1 ea 1d             	shr    $0x1d,%edx
80101616:	01 d0                	add    %edx,%eax
80101618:	83 e0 07             	and    $0x7,%eax
8010161b:	29 d0                	sub    %edx,%eax
8010161d:	ba 01 00 00 00       	mov    $0x1,%edx
80101622:	89 c1                	mov    %eax,%ecx
80101624:	d3 e2                	shl    %cl,%edx
80101626:	89 d0                	mov    %edx,%eax
80101628:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010162b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010162e:	8d 50 07             	lea    0x7(%eax),%edx
80101631:	85 c0                	test   %eax,%eax
80101633:	0f 48 c2             	cmovs  %edx,%eax
80101636:	c1 f8 03             	sar    $0x3,%eax
80101639:	89 c2                	mov    %eax,%edx
8010163b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010163e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101643:	0f b6 c0             	movzbl %al,%eax
80101646:	23 45 e8             	and    -0x18(%ebp),%eax
80101649:	85 c0                	test   %eax,%eax
8010164b:	75 64                	jne    801016b1 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010164d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101650:	8d 50 07             	lea    0x7(%eax),%edx
80101653:	85 c0                	test   %eax,%eax
80101655:	0f 48 c2             	cmovs  %edx,%eax
80101658:	c1 f8 03             	sar    $0x3,%eax
8010165b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010165e:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101663:	89 d1                	mov    %edx,%ecx
80101665:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101668:	09 ca                	or     %ecx,%edx
8010166a:	89 d1                	mov    %edx,%ecx
8010166c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010166f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101673:	83 ec 0c             	sub    $0xc,%esp
80101676:	ff 75 ec             	pushl  -0x14(%ebp)
80101679:	e8 19 23 00 00       	call   80103997 <log_write>
8010167e:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101681:	83 ec 0c             	sub    $0xc,%esp
80101684:	ff 75 ec             	pushl  -0x14(%ebp)
80101687:	e8 d5 eb ff ff       	call   80100261 <brelse>
8010168c:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010168f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101692:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101695:	01 c2                	add    %eax,%edx
80101697:	8b 45 08             	mov    0x8(%ebp),%eax
8010169a:	83 ec 08             	sub    $0x8,%esp
8010169d:	52                   	push   %edx
8010169e:	50                   	push   %eax
8010169f:	e8 be fe ff ff       	call   80101562 <bzero>
801016a4:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801016a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ad:	01 d0                	add    %edx,%eax
801016af:	eb 57                	jmp    80101708 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801016b1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801016b5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801016bc:	7f 17                	jg     801016d5 <balloc+0x11b>
801016be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c4:	01 d0                	add    %edx,%eax
801016c6:	89 c2                	mov    %eax,%edx
801016c8:	a1 60 2a 11 80       	mov    0x80112a60,%eax
801016cd:	39 c2                	cmp    %eax,%edx
801016cf:	0f 82 3a ff ff ff    	jb     8010160f <balloc+0x55>
      }
    }
    brelse(bp);
801016d5:	83 ec 0c             	sub    $0xc,%esp
801016d8:	ff 75 ec             	pushl  -0x14(%ebp)
801016db:	e8 81 eb ff ff       	call   80100261 <brelse>
801016e0:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801016e3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016ea:	8b 15 60 2a 11 80    	mov    0x80112a60,%edx
801016f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f3:	39 c2                	cmp    %eax,%edx
801016f5:	0f 87 dc fe ff ff    	ja     801015d7 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801016fb:	83 ec 0c             	sub    $0xc,%esp
801016fe:	68 68 93 10 80       	push   $0x80109368
80101703:	e8 00 ef ff ff       	call   80100608 <panic>
}
80101708:	c9                   	leave  
80101709:	c3                   	ret    

8010170a <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010170a:	f3 0f 1e fb          	endbr32 
8010170e:	55                   	push   %ebp
8010170f:	89 e5                	mov    %esp,%ebp
80101711:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
80101714:	8b 45 0c             	mov    0xc(%ebp),%eax
80101717:	c1 e8 0c             	shr    $0xc,%eax
8010171a:	89 c2                	mov    %eax,%edx
8010171c:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101721:	01 c2                	add    %eax,%edx
80101723:	8b 45 08             	mov    0x8(%ebp),%eax
80101726:	83 ec 08             	sub    $0x8,%esp
80101729:	52                   	push   %edx
8010172a:	50                   	push   %eax
8010172b:	e8 a7 ea ff ff       	call   801001d7 <bread>
80101730:	83 c4 10             	add    $0x10,%esp
80101733:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101736:	8b 45 0c             	mov    0xc(%ebp),%eax
80101739:	25 ff 0f 00 00       	and    $0xfff,%eax
8010173e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101741:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101744:	99                   	cltd   
80101745:	c1 ea 1d             	shr    $0x1d,%edx
80101748:	01 d0                	add    %edx,%eax
8010174a:	83 e0 07             	and    $0x7,%eax
8010174d:	29 d0                	sub    %edx,%eax
8010174f:	ba 01 00 00 00       	mov    $0x1,%edx
80101754:	89 c1                	mov    %eax,%ecx
80101756:	d3 e2                	shl    %cl,%edx
80101758:	89 d0                	mov    %edx,%eax
8010175a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010175d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101760:	8d 50 07             	lea    0x7(%eax),%edx
80101763:	85 c0                	test   %eax,%eax
80101765:	0f 48 c2             	cmovs  %edx,%eax
80101768:	c1 f8 03             	sar    $0x3,%eax
8010176b:	89 c2                	mov    %eax,%edx
8010176d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101770:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101775:	0f b6 c0             	movzbl %al,%eax
80101778:	23 45 ec             	and    -0x14(%ebp),%eax
8010177b:	85 c0                	test   %eax,%eax
8010177d:	75 0d                	jne    8010178c <bfree+0x82>
    panic("freeing free block");
8010177f:	83 ec 0c             	sub    $0xc,%esp
80101782:	68 7e 93 10 80       	push   $0x8010937e
80101787:	e8 7c ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
8010178c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010178f:	8d 50 07             	lea    0x7(%eax),%edx
80101792:	85 c0                	test   %eax,%eax
80101794:	0f 48 c2             	cmovs  %edx,%eax
80101797:	c1 f8 03             	sar    $0x3,%eax
8010179a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010179d:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801017a2:	89 d1                	mov    %edx,%ecx
801017a4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017a7:	f7 d2                	not    %edx
801017a9:	21 ca                	and    %ecx,%edx
801017ab:	89 d1                	mov    %edx,%ecx
801017ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017b0:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801017b4:	83 ec 0c             	sub    $0xc,%esp
801017b7:	ff 75 f4             	pushl  -0xc(%ebp)
801017ba:	e8 d8 21 00 00       	call   80103997 <log_write>
801017bf:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017c2:	83 ec 0c             	sub    $0xc,%esp
801017c5:	ff 75 f4             	pushl  -0xc(%ebp)
801017c8:	e8 94 ea ff ff       	call   80100261 <brelse>
801017cd:	83 c4 10             	add    $0x10,%esp
}
801017d0:	90                   	nop
801017d1:	c9                   	leave  
801017d2:	c3                   	ret    

801017d3 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801017d3:	f3 0f 1e fb          	endbr32 
801017d7:	55                   	push   %ebp
801017d8:	89 e5                	mov    %esp,%ebp
801017da:	57                   	push   %edi
801017db:	56                   	push   %esi
801017dc:	53                   	push   %ebx
801017dd:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801017e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801017e7:	83 ec 08             	sub    $0x8,%esp
801017ea:	68 91 93 10 80       	push   $0x80109391
801017ef:	68 80 2a 11 80       	push   $0x80112a80
801017f4:	e8 f8 3a 00 00       	call   801052f1 <initlock>
801017f9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101803:	eb 2d                	jmp    80101832 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101805:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101808:	89 d0                	mov    %edx,%eax
8010180a:	c1 e0 03             	shl    $0x3,%eax
8010180d:	01 d0                	add    %edx,%eax
8010180f:	c1 e0 04             	shl    $0x4,%eax
80101812:	83 c0 30             	add    $0x30,%eax
80101815:	05 80 2a 11 80       	add    $0x80112a80,%eax
8010181a:	83 c0 10             	add    $0x10,%eax
8010181d:	83 ec 08             	sub    $0x8,%esp
80101820:	68 98 93 10 80       	push   $0x80109398
80101825:	50                   	push   %eax
80101826:	e8 33 39 00 00       	call   8010515e <initsleeplock>
8010182b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010182e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101832:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101836:	7e cd                	jle    80101805 <iinit+0x32>
  }

  readsb(dev, &sb);
80101838:	83 ec 08             	sub    $0x8,%esp
8010183b:	68 60 2a 11 80       	push   $0x80112a60
80101840:	ff 75 08             	pushl  0x8(%ebp)
80101843:	e8 d4 fc ff ff       	call   8010151c <readsb>
80101848:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010184b:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101850:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101853:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
80101859:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
8010185f:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
80101865:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
8010186b:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
80101871:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101876:	ff 75 d4             	pushl  -0x2c(%ebp)
80101879:	57                   	push   %edi
8010187a:	56                   	push   %esi
8010187b:	53                   	push   %ebx
8010187c:	51                   	push   %ecx
8010187d:	52                   	push   %edx
8010187e:	50                   	push   %eax
8010187f:	68 a0 93 10 80       	push   $0x801093a0
80101884:	e8 8f eb ff ff       	call   80100418 <cprintf>
80101889:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010188c:	90                   	nop
8010188d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101890:	5b                   	pop    %ebx
80101891:	5e                   	pop    %esi
80101892:	5f                   	pop    %edi
80101893:	5d                   	pop    %ebp
80101894:	c3                   	ret    

80101895 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101895:	f3 0f 1e fb          	endbr32 
80101899:	55                   	push   %ebp
8010189a:	89 e5                	mov    %esp,%ebp
8010189c:	83 ec 28             	sub    $0x28,%esp
8010189f:	8b 45 0c             	mov    0xc(%ebp),%eax
801018a2:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018a6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801018ad:	e9 9e 00 00 00       	jmp    80101950 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b5:	c1 e8 03             	shr    $0x3,%eax
801018b8:	89 c2                	mov    %eax,%edx
801018ba:	a1 74 2a 11 80       	mov    0x80112a74,%eax
801018bf:	01 d0                	add    %edx,%eax
801018c1:	83 ec 08             	sub    $0x8,%esp
801018c4:	50                   	push   %eax
801018c5:	ff 75 08             	pushl  0x8(%ebp)
801018c8:	e8 0a e9 ff ff       	call   801001d7 <bread>
801018cd:	83 c4 10             	add    $0x10,%esp
801018d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d6:	8d 50 5c             	lea    0x5c(%eax),%edx
801018d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018dc:	83 e0 07             	and    $0x7,%eax
801018df:	c1 e0 06             	shl    $0x6,%eax
801018e2:	01 d0                	add    %edx,%eax
801018e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018ea:	0f b7 00             	movzwl (%eax),%eax
801018ed:	66 85 c0             	test   %ax,%ax
801018f0:	75 4c                	jne    8010193e <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
801018f2:	83 ec 04             	sub    $0x4,%esp
801018f5:	6a 40                	push   $0x40
801018f7:	6a 00                	push   $0x0
801018f9:	ff 75 ec             	pushl  -0x14(%ebp)
801018fc:	e8 b5 3c 00 00       	call   801055b6 <memset>
80101901:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101904:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101907:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010190b:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010190e:	83 ec 0c             	sub    $0xc,%esp
80101911:	ff 75 f0             	pushl  -0x10(%ebp)
80101914:	e8 7e 20 00 00       	call   80103997 <log_write>
80101919:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010191c:	83 ec 0c             	sub    $0xc,%esp
8010191f:	ff 75 f0             	pushl  -0x10(%ebp)
80101922:	e8 3a e9 ff ff       	call   80100261 <brelse>
80101927:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010192a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192d:	83 ec 08             	sub    $0x8,%esp
80101930:	50                   	push   %eax
80101931:	ff 75 08             	pushl  0x8(%ebp)
80101934:	e8 fc 00 00 00       	call   80101a35 <iget>
80101939:	83 c4 10             	add    $0x10,%esp
8010193c:	eb 30                	jmp    8010196e <ialloc+0xd9>
    }
    brelse(bp);
8010193e:	83 ec 0c             	sub    $0xc,%esp
80101941:	ff 75 f0             	pushl  -0x10(%ebp)
80101944:	e8 18 e9 ff ff       	call   80100261 <brelse>
80101949:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010194c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101950:	8b 15 68 2a 11 80    	mov    0x80112a68,%edx
80101956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101959:	39 c2                	cmp    %eax,%edx
8010195b:	0f 87 51 ff ff ff    	ja     801018b2 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101961:	83 ec 0c             	sub    $0xc,%esp
80101964:	68 f3 93 10 80       	push   $0x801093f3
80101969:	e8 9a ec ff ff       	call   80100608 <panic>
}
8010196e:	c9                   	leave  
8010196f:	c3                   	ret    

80101970 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101970:	f3 0f 1e fb          	endbr32 
80101974:	55                   	push   %ebp
80101975:	89 e5                	mov    %esp,%ebp
80101977:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010197a:	8b 45 08             	mov    0x8(%ebp),%eax
8010197d:	8b 40 04             	mov    0x4(%eax),%eax
80101980:	c1 e8 03             	shr    $0x3,%eax
80101983:	89 c2                	mov    %eax,%edx
80101985:	a1 74 2a 11 80       	mov    0x80112a74,%eax
8010198a:	01 c2                	add    %eax,%edx
8010198c:	8b 45 08             	mov    0x8(%ebp),%eax
8010198f:	8b 00                	mov    (%eax),%eax
80101991:	83 ec 08             	sub    $0x8,%esp
80101994:	52                   	push   %edx
80101995:	50                   	push   %eax
80101996:	e8 3c e8 ff ff       	call   801001d7 <bread>
8010199b:	83 c4 10             	add    $0x10,%esp
8010199e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a4:	8d 50 5c             	lea    0x5c(%eax),%edx
801019a7:	8b 45 08             	mov    0x8(%ebp),%eax
801019aa:	8b 40 04             	mov    0x4(%eax),%eax
801019ad:	83 e0 07             	and    $0x7,%eax
801019b0:	c1 e0 06             	shl    $0x6,%eax
801019b3:	01 d0                	add    %edx,%eax
801019b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019b8:	8b 45 08             	mov    0x8(%ebp),%eax
801019bb:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801019bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c2:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801019c5:	8b 45 08             	mov    0x8(%ebp),%eax
801019c8:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801019cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cf:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801019d3:	8b 45 08             	mov    0x8(%ebp),%eax
801019d6:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801019da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019dd:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019e1:	8b 45 08             	mov    0x8(%ebp),%eax
801019e4:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801019e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019eb:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801019ef:	8b 45 08             	mov    0x8(%ebp),%eax
801019f2:	8b 50 58             	mov    0x58(%eax),%edx
801019f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f8:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019fb:	8b 45 08             	mov    0x8(%ebp),%eax
801019fe:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a04:	83 c0 0c             	add    $0xc,%eax
80101a07:	83 ec 04             	sub    $0x4,%esp
80101a0a:	6a 34                	push   $0x34
80101a0c:	52                   	push   %edx
80101a0d:	50                   	push   %eax
80101a0e:	e8 6a 3c 00 00       	call   8010567d <memmove>
80101a13:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101a16:	83 ec 0c             	sub    $0xc,%esp
80101a19:	ff 75 f4             	pushl  -0xc(%ebp)
80101a1c:	e8 76 1f 00 00       	call   80103997 <log_write>
80101a21:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101a24:	83 ec 0c             	sub    $0xc,%esp
80101a27:	ff 75 f4             	pushl  -0xc(%ebp)
80101a2a:	e8 32 e8 ff ff       	call   80100261 <brelse>
80101a2f:	83 c4 10             	add    $0x10,%esp
}
80101a32:	90                   	nop
80101a33:	c9                   	leave  
80101a34:	c3                   	ret    

80101a35 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a35:	f3 0f 1e fb          	endbr32 
80101a39:	55                   	push   %ebp
80101a3a:	89 e5                	mov    %esp,%ebp
80101a3c:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a3f:	83 ec 0c             	sub    $0xc,%esp
80101a42:	68 80 2a 11 80       	push   $0x80112a80
80101a47:	e8 cb 38 00 00       	call   80105317 <acquire>
80101a4c:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a4f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a56:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80101a5d:	eb 60                	jmp    80101abf <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a62:	8b 40 08             	mov    0x8(%eax),%eax
80101a65:	85 c0                	test   %eax,%eax
80101a67:	7e 39                	jle    80101aa2 <iget+0x6d>
80101a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6c:	8b 00                	mov    (%eax),%eax
80101a6e:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a71:	75 2f                	jne    80101aa2 <iget+0x6d>
80101a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a76:	8b 40 04             	mov    0x4(%eax),%eax
80101a79:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a7c:	75 24                	jne    80101aa2 <iget+0x6d>
      ip->ref++;
80101a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a81:	8b 40 08             	mov    0x8(%eax),%eax
80101a84:	8d 50 01             	lea    0x1(%eax),%edx
80101a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8a:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a8d:	83 ec 0c             	sub    $0xc,%esp
80101a90:	68 80 2a 11 80       	push   $0x80112a80
80101a95:	e8 ef 38 00 00       	call   80105389 <release>
80101a9a:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa0:	eb 77                	jmp    80101b19 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101aa2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101aa6:	75 10                	jne    80101ab8 <iget+0x83>
80101aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aab:	8b 40 08             	mov    0x8(%eax),%eax
80101aae:	85 c0                	test   %eax,%eax
80101ab0:	75 06                	jne    80101ab8 <iget+0x83>
      empty = ip;
80101ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101ab8:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101abf:	81 7d f4 d4 46 11 80 	cmpl   $0x801146d4,-0xc(%ebp)
80101ac6:	72 97                	jb     80101a5f <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101ac8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101acc:	75 0d                	jne    80101adb <iget+0xa6>
    panic("iget: no inodes");
80101ace:	83 ec 0c             	sub    $0xc,%esp
80101ad1:	68 05 94 10 80       	push   $0x80109405
80101ad6:	e8 2d eb ff ff       	call   80100608 <panic>

  ip = empty;
80101adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ade:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae4:	8b 55 08             	mov    0x8(%ebp),%edx
80101ae7:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aec:	8b 55 0c             	mov    0xc(%ebp),%edx
80101aef:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aff:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101b06:	83 ec 0c             	sub    $0xc,%esp
80101b09:	68 80 2a 11 80       	push   $0x80112a80
80101b0e:	e8 76 38 00 00       	call   80105389 <release>
80101b13:	83 c4 10             	add    $0x10,%esp

  return ip;
80101b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b19:	c9                   	leave  
80101b1a:	c3                   	ret    

80101b1b <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b1b:	f3 0f 1e fb          	endbr32 
80101b1f:	55                   	push   %ebp
80101b20:	89 e5                	mov    %esp,%ebp
80101b22:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b25:	83 ec 0c             	sub    $0xc,%esp
80101b28:	68 80 2a 11 80       	push   $0x80112a80
80101b2d:	e8 e5 37 00 00       	call   80105317 <acquire>
80101b32:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101b35:	8b 45 08             	mov    0x8(%ebp),%eax
80101b38:	8b 40 08             	mov    0x8(%eax),%eax
80101b3b:	8d 50 01             	lea    0x1(%eax),%edx
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	68 80 2a 11 80       	push   $0x80112a80
80101b4c:	e8 38 38 00 00       	call   80105389 <release>
80101b51:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b54:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b57:	c9                   	leave  
80101b58:	c3                   	ret    

80101b59 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b59:	f3 0f 1e fb          	endbr32 
80101b5d:	55                   	push   %ebp
80101b5e:	89 e5                	mov    %esp,%ebp
80101b60:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b63:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b67:	74 0a                	je     80101b73 <ilock+0x1a>
80101b69:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6c:	8b 40 08             	mov    0x8(%eax),%eax
80101b6f:	85 c0                	test   %eax,%eax
80101b71:	7f 0d                	jg     80101b80 <ilock+0x27>
    panic("ilock");
80101b73:	83 ec 0c             	sub    $0xc,%esp
80101b76:	68 15 94 10 80       	push   $0x80109415
80101b7b:	e8 88 ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b80:	8b 45 08             	mov    0x8(%ebp),%eax
80101b83:	83 c0 0c             	add    $0xc,%eax
80101b86:	83 ec 0c             	sub    $0xc,%esp
80101b89:	50                   	push   %eax
80101b8a:	e8 0f 36 00 00       	call   8010519e <acquiresleep>
80101b8f:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b92:	8b 45 08             	mov    0x8(%ebp),%eax
80101b95:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b98:	85 c0                	test   %eax,%eax
80101b9a:	0f 85 cd 00 00 00    	jne    80101c6d <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba3:	8b 40 04             	mov    0x4(%eax),%eax
80101ba6:	c1 e8 03             	shr    $0x3,%eax
80101ba9:	89 c2                	mov    %eax,%edx
80101bab:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101bb0:	01 c2                	add    %eax,%edx
80101bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb5:	8b 00                	mov    (%eax),%eax
80101bb7:	83 ec 08             	sub    $0x8,%esp
80101bba:	52                   	push   %edx
80101bbb:	50                   	push   %eax
80101bbc:	e8 16 e6 ff ff       	call   801001d7 <bread>
80101bc1:	83 c4 10             	add    $0x10,%esp
80101bc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bca:	8d 50 5c             	lea    0x5c(%eax),%edx
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	8b 40 04             	mov    0x4(%eax),%eax
80101bd3:	83 e0 07             	and    $0x7,%eax
80101bd6:	c1 e0 06             	shl    $0x6,%eax
80101bd9:	01 d0                	add    %edx,%eax
80101bdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be1:	0f b7 10             	movzwl (%eax),%edx
80101be4:	8b 45 08             	mov    0x8(%ebp),%eax
80101be7:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bee:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf5:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bfc:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c0a:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c11:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101c15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c18:	8b 50 08             	mov    0x8(%eax),%edx
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c24:	8d 50 0c             	lea    0xc(%eax),%edx
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	83 c0 5c             	add    $0x5c,%eax
80101c2d:	83 ec 04             	sub    $0x4,%esp
80101c30:	6a 34                	push   $0x34
80101c32:	52                   	push   %edx
80101c33:	50                   	push   %eax
80101c34:	e8 44 3a 00 00       	call   8010567d <memmove>
80101c39:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c3c:	83 ec 0c             	sub    $0xc,%esp
80101c3f:	ff 75 f4             	pushl  -0xc(%ebp)
80101c42:	e8 1a e6 ff ff       	call   80100261 <brelse>
80101c47:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c5b:	66 85 c0             	test   %ax,%ax
80101c5e:	75 0d                	jne    80101c6d <ilock+0x114>
      panic("ilock: no type");
80101c60:	83 ec 0c             	sub    $0xc,%esp
80101c63:	68 1b 94 10 80       	push   $0x8010941b
80101c68:	e8 9b e9 ff ff       	call   80100608 <panic>
  }
}
80101c6d:	90                   	nop
80101c6e:	c9                   	leave  
80101c6f:	c3                   	ret    

80101c70 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c70:	f3 0f 1e fb          	endbr32 
80101c74:	55                   	push   %ebp
80101c75:	89 e5                	mov    %esp,%ebp
80101c77:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c7a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c7e:	74 20                	je     80101ca0 <iunlock+0x30>
80101c80:	8b 45 08             	mov    0x8(%ebp),%eax
80101c83:	83 c0 0c             	add    $0xc,%eax
80101c86:	83 ec 0c             	sub    $0xc,%esp
80101c89:	50                   	push   %eax
80101c8a:	e8 c9 35 00 00       	call   80105258 <holdingsleep>
80101c8f:	83 c4 10             	add    $0x10,%esp
80101c92:	85 c0                	test   %eax,%eax
80101c94:	74 0a                	je     80101ca0 <iunlock+0x30>
80101c96:	8b 45 08             	mov    0x8(%ebp),%eax
80101c99:	8b 40 08             	mov    0x8(%eax),%eax
80101c9c:	85 c0                	test   %eax,%eax
80101c9e:	7f 0d                	jg     80101cad <iunlock+0x3d>
    panic("iunlock");
80101ca0:	83 ec 0c             	sub    $0xc,%esp
80101ca3:	68 2a 94 10 80       	push   $0x8010942a
80101ca8:	e8 5b e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	83 c0 0c             	add    $0xc,%eax
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	50                   	push   %eax
80101cb7:	e8 4a 35 00 00       	call   80105206 <releasesleep>
80101cbc:	83 c4 10             	add    $0x10,%esp
}
80101cbf:	90                   	nop
80101cc0:	c9                   	leave  
80101cc1:	c3                   	ret    

80101cc2 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101cc2:	f3 0f 1e fb          	endbr32 
80101cc6:	55                   	push   %ebp
80101cc7:	89 e5                	mov    %esp,%ebp
80101cc9:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccf:	83 c0 0c             	add    $0xc,%eax
80101cd2:	83 ec 0c             	sub    $0xc,%esp
80101cd5:	50                   	push   %eax
80101cd6:	e8 c3 34 00 00       	call   8010519e <acquiresleep>
80101cdb:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101cde:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce1:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ce4:	85 c0                	test   %eax,%eax
80101ce6:	74 6a                	je     80101d52 <iput+0x90>
80101ce8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ceb:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101cef:	66 85 c0             	test   %ax,%ax
80101cf2:	75 5e                	jne    80101d52 <iput+0x90>
    acquire(&icache.lock);
80101cf4:	83 ec 0c             	sub    $0xc,%esp
80101cf7:	68 80 2a 11 80       	push   $0x80112a80
80101cfc:	e8 16 36 00 00       	call   80105317 <acquire>
80101d01:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101d04:	8b 45 08             	mov    0x8(%ebp),%eax
80101d07:	8b 40 08             	mov    0x8(%eax),%eax
80101d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	68 80 2a 11 80       	push   $0x80112a80
80101d15:	e8 6f 36 00 00       	call   80105389 <release>
80101d1a:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101d1d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101d21:	75 2f                	jne    80101d52 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101d23:	83 ec 0c             	sub    $0xc,%esp
80101d26:	ff 75 08             	pushl  0x8(%ebp)
80101d29:	e8 b5 01 00 00       	call   80101ee3 <itrunc>
80101d2e:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101d31:	8b 45 08             	mov    0x8(%ebp),%eax
80101d34:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101d3a:	83 ec 0c             	sub    $0xc,%esp
80101d3d:	ff 75 08             	pushl  0x8(%ebp)
80101d40:	e8 2b fc ff ff       	call   80101970 <iupdate>
80101d45:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101d48:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4b:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d52:	8b 45 08             	mov    0x8(%ebp),%eax
80101d55:	83 c0 0c             	add    $0xc,%eax
80101d58:	83 ec 0c             	sub    $0xc,%esp
80101d5b:	50                   	push   %eax
80101d5c:	e8 a5 34 00 00       	call   80105206 <releasesleep>
80101d61:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d64:	83 ec 0c             	sub    $0xc,%esp
80101d67:	68 80 2a 11 80       	push   $0x80112a80
80101d6c:	e8 a6 35 00 00       	call   80105317 <acquire>
80101d71:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	8b 40 08             	mov    0x8(%eax),%eax
80101d7a:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d80:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d83:	83 ec 0c             	sub    $0xc,%esp
80101d86:	68 80 2a 11 80       	push   $0x80112a80
80101d8b:	e8 f9 35 00 00       	call   80105389 <release>
80101d90:	83 c4 10             	add    $0x10,%esp
}
80101d93:	90                   	nop
80101d94:	c9                   	leave  
80101d95:	c3                   	ret    

80101d96 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d96:	f3 0f 1e fb          	endbr32 
80101d9a:	55                   	push   %ebp
80101d9b:	89 e5                	mov    %esp,%ebp
80101d9d:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101da0:	83 ec 0c             	sub    $0xc,%esp
80101da3:	ff 75 08             	pushl  0x8(%ebp)
80101da6:	e8 c5 fe ff ff       	call   80101c70 <iunlock>
80101dab:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101dae:	83 ec 0c             	sub    $0xc,%esp
80101db1:	ff 75 08             	pushl  0x8(%ebp)
80101db4:	e8 09 ff ff ff       	call   80101cc2 <iput>
80101db9:	83 c4 10             	add    $0x10,%esp
}
80101dbc:	90                   	nop
80101dbd:	c9                   	leave  
80101dbe:	c3                   	ret    

80101dbf <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101dbf:	f3 0f 1e fb          	endbr32 
80101dc3:	55                   	push   %ebp
80101dc4:	89 e5                	mov    %esp,%ebp
80101dc6:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101dc9:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101dcd:	77 42                	ja     80101e11 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dd5:	83 c2 14             	add    $0x14,%edx
80101dd8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ddc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ddf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101de3:	75 24                	jne    80101e09 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101de5:	8b 45 08             	mov    0x8(%ebp),%eax
80101de8:	8b 00                	mov    (%eax),%eax
80101dea:	83 ec 0c             	sub    $0xc,%esp
80101ded:	50                   	push   %eax
80101dee:	e8 c7 f7 ff ff       	call   801015ba <balloc>
80101df3:	83 c4 10             	add    $0x10,%esp
80101df6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101df9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfc:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dff:	8d 4a 14             	lea    0x14(%edx),%ecx
80101e02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e05:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e0c:	e9 d0 00 00 00       	jmp    80101ee1 <bmap+0x122>
  }
  bn -= NDIRECT;
80101e11:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e15:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e19:	0f 87 b5 00 00 00    	ja     80101ed4 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e22:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e28:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e2f:	75 20                	jne    80101e51 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e31:	8b 45 08             	mov    0x8(%ebp),%eax
80101e34:	8b 00                	mov    (%eax),%eax
80101e36:	83 ec 0c             	sub    $0xc,%esp
80101e39:	50                   	push   %eax
80101e3a:	e8 7b f7 ff ff       	call   801015ba <balloc>
80101e3f:	83 c4 10             	add    $0x10,%esp
80101e42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e45:	8b 45 08             	mov    0x8(%ebp),%eax
80101e48:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e4b:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e51:	8b 45 08             	mov    0x8(%ebp),%eax
80101e54:	8b 00                	mov    (%eax),%eax
80101e56:	83 ec 08             	sub    $0x8,%esp
80101e59:	ff 75 f4             	pushl  -0xc(%ebp)
80101e5c:	50                   	push   %eax
80101e5d:	e8 75 e3 ff ff       	call   801001d7 <bread>
80101e62:	83 c4 10             	add    $0x10,%esp
80101e65:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e6b:	83 c0 5c             	add    $0x5c,%eax
80101e6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e71:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e74:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e7e:	01 d0                	add    %edx,%eax
80101e80:	8b 00                	mov    (%eax),%eax
80101e82:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e89:	75 36                	jne    80101ec1 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8e:	8b 00                	mov    (%eax),%eax
80101e90:	83 ec 0c             	sub    $0xc,%esp
80101e93:	50                   	push   %eax
80101e94:	e8 21 f7 ff ff       	call   801015ba <balloc>
80101e99:	83 c4 10             	add    $0x10,%esp
80101e9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ea9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eac:	01 c2                	add    %eax,%edx
80101eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eb1:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101eb3:	83 ec 0c             	sub    $0xc,%esp
80101eb6:	ff 75 f0             	pushl  -0x10(%ebp)
80101eb9:	e8 d9 1a 00 00       	call   80103997 <log_write>
80101ebe:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101ec1:	83 ec 0c             	sub    $0xc,%esp
80101ec4:	ff 75 f0             	pushl  -0x10(%ebp)
80101ec7:	e8 95 e3 ff ff       	call   80100261 <brelse>
80101ecc:	83 c4 10             	add    $0x10,%esp
    return addr;
80101ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ed2:	eb 0d                	jmp    80101ee1 <bmap+0x122>
  }

  panic("bmap: out of range");
80101ed4:	83 ec 0c             	sub    $0xc,%esp
80101ed7:	68 32 94 10 80       	push   $0x80109432
80101edc:	e8 27 e7 ff ff       	call   80100608 <panic>
}
80101ee1:	c9                   	leave  
80101ee2:	c3                   	ret    

80101ee3 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101ee3:	f3 0f 1e fb          	endbr32 
80101ee7:	55                   	push   %ebp
80101ee8:	89 e5                	mov    %esp,%ebp
80101eea:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101eed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ef4:	eb 45                	jmp    80101f3b <itrunc+0x58>
    if(ip->addrs[i]){
80101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101efc:	83 c2 14             	add    $0x14,%edx
80101eff:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f03:	85 c0                	test   %eax,%eax
80101f05:	74 30                	je     80101f37 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101f07:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f0d:	83 c2 14             	add    $0x14,%edx
80101f10:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f14:	8b 55 08             	mov    0x8(%ebp),%edx
80101f17:	8b 12                	mov    (%edx),%edx
80101f19:	83 ec 08             	sub    $0x8,%esp
80101f1c:	50                   	push   %eax
80101f1d:	52                   	push   %edx
80101f1e:	e8 e7 f7 ff ff       	call   8010170a <bfree>
80101f23:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101f26:	8b 45 08             	mov    0x8(%ebp),%eax
80101f29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f2c:	83 c2 14             	add    $0x14,%edx
80101f2f:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f36:	00 
  for(i = 0; i < NDIRECT; i++){
80101f37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f3b:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f3f:	7e b5                	jle    80101ef6 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101f41:	8b 45 08             	mov    0x8(%ebp),%eax
80101f44:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f4a:	85 c0                	test   %eax,%eax
80101f4c:	0f 84 aa 00 00 00    	je     80101ffc <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f52:	8b 45 08             	mov    0x8(%ebp),%eax
80101f55:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5e:	8b 00                	mov    (%eax),%eax
80101f60:	83 ec 08             	sub    $0x8,%esp
80101f63:	52                   	push   %edx
80101f64:	50                   	push   %eax
80101f65:	e8 6d e2 ff ff       	call   801001d7 <bread>
80101f6a:	83 c4 10             	add    $0x10,%esp
80101f6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f70:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f73:	83 c0 5c             	add    $0x5c,%eax
80101f76:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f79:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f80:	eb 3c                	jmp    80101fbe <itrunc+0xdb>
      if(a[j])
80101f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f85:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f8f:	01 d0                	add    %edx,%eax
80101f91:	8b 00                	mov    (%eax),%eax
80101f93:	85 c0                	test   %eax,%eax
80101f95:	74 23                	je     80101fba <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f9a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fa1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fa4:	01 d0                	add    %edx,%eax
80101fa6:	8b 00                	mov    (%eax),%eax
80101fa8:	8b 55 08             	mov    0x8(%ebp),%edx
80101fab:	8b 12                	mov    (%edx),%edx
80101fad:	83 ec 08             	sub    $0x8,%esp
80101fb0:	50                   	push   %eax
80101fb1:	52                   	push   %edx
80101fb2:	e8 53 f7 ff ff       	call   8010170a <bfree>
80101fb7:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101fba:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101fbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc1:	83 f8 7f             	cmp    $0x7f,%eax
80101fc4:	76 bc                	jbe    80101f82 <itrunc+0x9f>
    }
    brelse(bp);
80101fc6:	83 ec 0c             	sub    $0xc,%esp
80101fc9:	ff 75 ec             	pushl  -0x14(%ebp)
80101fcc:	e8 90 e2 ff ff       	call   80100261 <brelse>
80101fd1:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd7:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101fdd:	8b 55 08             	mov    0x8(%ebp),%edx
80101fe0:	8b 12                	mov    (%edx),%edx
80101fe2:	83 ec 08             	sub    $0x8,%esp
80101fe5:	50                   	push   %eax
80101fe6:	52                   	push   %edx
80101fe7:	e8 1e f7 ff ff       	call   8010170a <bfree>
80101fec:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101fef:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff2:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101ff9:	00 00 00 
  }

  ip->size = 0;
80101ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fff:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80102006:	83 ec 0c             	sub    $0xc,%esp
80102009:	ff 75 08             	pushl  0x8(%ebp)
8010200c:	e8 5f f9 ff ff       	call   80101970 <iupdate>
80102011:	83 c4 10             	add    $0x10,%esp
}
80102014:	90                   	nop
80102015:	c9                   	leave  
80102016:	c3                   	ret    

80102017 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80102017:	f3 0f 1e fb          	endbr32 
8010201b:	55                   	push   %ebp
8010201c:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
8010201e:	8b 45 08             	mov    0x8(%ebp),%eax
80102021:	8b 00                	mov    (%eax),%eax
80102023:	89 c2                	mov    %eax,%edx
80102025:	8b 45 0c             	mov    0xc(%ebp),%eax
80102028:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
8010202b:	8b 45 08             	mov    0x8(%ebp),%eax
8010202e:	8b 50 04             	mov    0x4(%eax),%edx
80102031:	8b 45 0c             	mov    0xc(%ebp),%eax
80102034:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	0f b7 50 50          	movzwl 0x50(%eax),%edx
8010203e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102041:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102044:	8b 45 08             	mov    0x8(%ebp),%eax
80102047:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010204b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010204e:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	8b 50 58             	mov    0x58(%eax),%edx
80102058:	8b 45 0c             	mov    0xc(%ebp),%eax
8010205b:	89 50 10             	mov    %edx,0x10(%eax)
}
8010205e:	90                   	nop
8010205f:	5d                   	pop    %ebp
80102060:	c3                   	ret    

80102061 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102061:	f3 0f 1e fb          	endbr32 
80102065:	55                   	push   %ebp
80102066:	89 e5                	mov    %esp,%ebp
80102068:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010206b:	8b 45 08             	mov    0x8(%ebp),%eax
8010206e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102072:	66 83 f8 03          	cmp    $0x3,%ax
80102076:	75 5c                	jne    801020d4 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102078:	8b 45 08             	mov    0x8(%ebp),%eax
8010207b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207f:	66 85 c0             	test   %ax,%ax
80102082:	78 20                	js     801020a4 <readi+0x43>
80102084:	8b 45 08             	mov    0x8(%ebp),%eax
80102087:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010208b:	66 83 f8 09          	cmp    $0x9,%ax
8010208f:	7f 13                	jg     801020a4 <readi+0x43>
80102091:	8b 45 08             	mov    0x8(%ebp),%eax
80102094:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102098:	98                   	cwtl   
80102099:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
801020a0:	85 c0                	test   %eax,%eax
801020a2:	75 0a                	jne    801020ae <readi+0x4d>
      return -1;
801020a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020a9:	e9 0a 01 00 00       	jmp    801021b8 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
801020ae:	8b 45 08             	mov    0x8(%ebp),%eax
801020b1:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020b5:	98                   	cwtl   
801020b6:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
801020bd:	8b 55 14             	mov    0x14(%ebp),%edx
801020c0:	83 ec 04             	sub    $0x4,%esp
801020c3:	52                   	push   %edx
801020c4:	ff 75 0c             	pushl  0xc(%ebp)
801020c7:	ff 75 08             	pushl  0x8(%ebp)
801020ca:	ff d0                	call   *%eax
801020cc:	83 c4 10             	add    $0x10,%esp
801020cf:	e9 e4 00 00 00       	jmp    801021b8 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
801020d4:	8b 45 08             	mov    0x8(%ebp),%eax
801020d7:	8b 40 58             	mov    0x58(%eax),%eax
801020da:	39 45 10             	cmp    %eax,0x10(%ebp)
801020dd:	77 0d                	ja     801020ec <readi+0x8b>
801020df:	8b 55 10             	mov    0x10(%ebp),%edx
801020e2:	8b 45 14             	mov    0x14(%ebp),%eax
801020e5:	01 d0                	add    %edx,%eax
801020e7:	39 45 10             	cmp    %eax,0x10(%ebp)
801020ea:	76 0a                	jbe    801020f6 <readi+0x95>
    return -1;
801020ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020f1:	e9 c2 00 00 00       	jmp    801021b8 <readi+0x157>
  if(off + n > ip->size)
801020f6:	8b 55 10             	mov    0x10(%ebp),%edx
801020f9:	8b 45 14             	mov    0x14(%ebp),%eax
801020fc:	01 c2                	add    %eax,%edx
801020fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102101:	8b 40 58             	mov    0x58(%eax),%eax
80102104:	39 c2                	cmp    %eax,%edx
80102106:	76 0c                	jbe    80102114 <readi+0xb3>
    n = ip->size - off;
80102108:	8b 45 08             	mov    0x8(%ebp),%eax
8010210b:	8b 40 58             	mov    0x58(%eax),%eax
8010210e:	2b 45 10             	sub    0x10(%ebp),%eax
80102111:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102114:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010211b:	e9 89 00 00 00       	jmp    801021a9 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102120:	8b 45 10             	mov    0x10(%ebp),%eax
80102123:	c1 e8 09             	shr    $0x9,%eax
80102126:	83 ec 08             	sub    $0x8,%esp
80102129:	50                   	push   %eax
8010212a:	ff 75 08             	pushl  0x8(%ebp)
8010212d:	e8 8d fc ff ff       	call   80101dbf <bmap>
80102132:	83 c4 10             	add    $0x10,%esp
80102135:	8b 55 08             	mov    0x8(%ebp),%edx
80102138:	8b 12                	mov    (%edx),%edx
8010213a:	83 ec 08             	sub    $0x8,%esp
8010213d:	50                   	push   %eax
8010213e:	52                   	push   %edx
8010213f:	e8 93 e0 ff ff       	call   801001d7 <bread>
80102144:	83 c4 10             	add    $0x10,%esp
80102147:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010214a:	8b 45 10             	mov    0x10(%ebp),%eax
8010214d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102152:	ba 00 02 00 00       	mov    $0x200,%edx
80102157:	29 c2                	sub    %eax,%edx
80102159:	8b 45 14             	mov    0x14(%ebp),%eax
8010215c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010215f:	39 c2                	cmp    %eax,%edx
80102161:	0f 46 c2             	cmovbe %edx,%eax
80102164:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102167:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010216a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010216d:	8b 45 10             	mov    0x10(%ebp),%eax
80102170:	25 ff 01 00 00       	and    $0x1ff,%eax
80102175:	01 d0                	add    %edx,%eax
80102177:	83 ec 04             	sub    $0x4,%esp
8010217a:	ff 75 ec             	pushl  -0x14(%ebp)
8010217d:	50                   	push   %eax
8010217e:	ff 75 0c             	pushl  0xc(%ebp)
80102181:	e8 f7 34 00 00       	call   8010567d <memmove>
80102186:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102189:	83 ec 0c             	sub    $0xc,%esp
8010218c:	ff 75 f0             	pushl  -0x10(%ebp)
8010218f:	e8 cd e0 ff ff       	call   80100261 <brelse>
80102194:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102197:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010219a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010219d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021a0:	01 45 10             	add    %eax,0x10(%ebp)
801021a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021a6:	01 45 0c             	add    %eax,0xc(%ebp)
801021a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021ac:	3b 45 14             	cmp    0x14(%ebp),%eax
801021af:	0f 82 6b ff ff ff    	jb     80102120 <readi+0xbf>
  }
  return n;
801021b5:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b8:	c9                   	leave  
801021b9:	c3                   	ret    

801021ba <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021ba:	f3 0f 1e fb          	endbr32 
801021be:	55                   	push   %ebp
801021bf:	89 e5                	mov    %esp,%ebp
801021c1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021c4:	8b 45 08             	mov    0x8(%ebp),%eax
801021c7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021cb:	66 83 f8 03          	cmp    $0x3,%ax
801021cf:	75 5c                	jne    8010222d <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021d1:	8b 45 08             	mov    0x8(%ebp),%eax
801021d4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021d8:	66 85 c0             	test   %ax,%ax
801021db:	78 20                	js     801021fd <writei+0x43>
801021dd:	8b 45 08             	mov    0x8(%ebp),%eax
801021e0:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021e4:	66 83 f8 09          	cmp    $0x9,%ax
801021e8:	7f 13                	jg     801021fd <writei+0x43>
801021ea:	8b 45 08             	mov    0x8(%ebp),%eax
801021ed:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021f1:	98                   	cwtl   
801021f2:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021f9:	85 c0                	test   %eax,%eax
801021fb:	75 0a                	jne    80102207 <writei+0x4d>
      return -1;
801021fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102202:	e9 3b 01 00 00       	jmp    80102342 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
80102207:	8b 45 08             	mov    0x8(%ebp),%eax
8010220a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010220e:	98                   	cwtl   
8010220f:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
80102216:	8b 55 14             	mov    0x14(%ebp),%edx
80102219:	83 ec 04             	sub    $0x4,%esp
8010221c:	52                   	push   %edx
8010221d:	ff 75 0c             	pushl  0xc(%ebp)
80102220:	ff 75 08             	pushl  0x8(%ebp)
80102223:	ff d0                	call   *%eax
80102225:	83 c4 10             	add    $0x10,%esp
80102228:	e9 15 01 00 00       	jmp    80102342 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
8010222d:	8b 45 08             	mov    0x8(%ebp),%eax
80102230:	8b 40 58             	mov    0x58(%eax),%eax
80102233:	39 45 10             	cmp    %eax,0x10(%ebp)
80102236:	77 0d                	ja     80102245 <writei+0x8b>
80102238:	8b 55 10             	mov    0x10(%ebp),%edx
8010223b:	8b 45 14             	mov    0x14(%ebp),%eax
8010223e:	01 d0                	add    %edx,%eax
80102240:	39 45 10             	cmp    %eax,0x10(%ebp)
80102243:	76 0a                	jbe    8010224f <writei+0x95>
    return -1;
80102245:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010224a:	e9 f3 00 00 00       	jmp    80102342 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
8010224f:	8b 55 10             	mov    0x10(%ebp),%edx
80102252:	8b 45 14             	mov    0x14(%ebp),%eax
80102255:	01 d0                	add    %edx,%eax
80102257:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010225c:	76 0a                	jbe    80102268 <writei+0xae>
    return -1;
8010225e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102263:	e9 da 00 00 00       	jmp    80102342 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102268:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010226f:	e9 97 00 00 00       	jmp    8010230b <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102274:	8b 45 10             	mov    0x10(%ebp),%eax
80102277:	c1 e8 09             	shr    $0x9,%eax
8010227a:	83 ec 08             	sub    $0x8,%esp
8010227d:	50                   	push   %eax
8010227e:	ff 75 08             	pushl  0x8(%ebp)
80102281:	e8 39 fb ff ff       	call   80101dbf <bmap>
80102286:	83 c4 10             	add    $0x10,%esp
80102289:	8b 55 08             	mov    0x8(%ebp),%edx
8010228c:	8b 12                	mov    (%edx),%edx
8010228e:	83 ec 08             	sub    $0x8,%esp
80102291:	50                   	push   %eax
80102292:	52                   	push   %edx
80102293:	e8 3f df ff ff       	call   801001d7 <bread>
80102298:	83 c4 10             	add    $0x10,%esp
8010229b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010229e:	8b 45 10             	mov    0x10(%ebp),%eax
801022a1:	25 ff 01 00 00       	and    $0x1ff,%eax
801022a6:	ba 00 02 00 00       	mov    $0x200,%edx
801022ab:	29 c2                	sub    %eax,%edx
801022ad:	8b 45 14             	mov    0x14(%ebp),%eax
801022b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801022b3:	39 c2                	cmp    %eax,%edx
801022b5:	0f 46 c2             	cmovbe %edx,%eax
801022b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022be:	8d 50 5c             	lea    0x5c(%eax),%edx
801022c1:	8b 45 10             	mov    0x10(%ebp),%eax
801022c4:	25 ff 01 00 00       	and    $0x1ff,%eax
801022c9:	01 d0                	add    %edx,%eax
801022cb:	83 ec 04             	sub    $0x4,%esp
801022ce:	ff 75 ec             	pushl  -0x14(%ebp)
801022d1:	ff 75 0c             	pushl  0xc(%ebp)
801022d4:	50                   	push   %eax
801022d5:	e8 a3 33 00 00       	call   8010567d <memmove>
801022da:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801022dd:	83 ec 0c             	sub    $0xc,%esp
801022e0:	ff 75 f0             	pushl  -0x10(%ebp)
801022e3:	e8 af 16 00 00       	call   80103997 <log_write>
801022e8:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801022eb:	83 ec 0c             	sub    $0xc,%esp
801022ee:	ff 75 f0             	pushl  -0x10(%ebp)
801022f1:	e8 6b df ff ff       	call   80100261 <brelse>
801022f6:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022fc:	01 45 f4             	add    %eax,-0xc(%ebp)
801022ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102302:	01 45 10             	add    %eax,0x10(%ebp)
80102305:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102308:	01 45 0c             	add    %eax,0xc(%ebp)
8010230b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230e:	3b 45 14             	cmp    0x14(%ebp),%eax
80102311:	0f 82 5d ff ff ff    	jb     80102274 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
80102317:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010231b:	74 22                	je     8010233f <writei+0x185>
8010231d:	8b 45 08             	mov    0x8(%ebp),%eax
80102320:	8b 40 58             	mov    0x58(%eax),%eax
80102323:	39 45 10             	cmp    %eax,0x10(%ebp)
80102326:	76 17                	jbe    8010233f <writei+0x185>
    ip->size = off;
80102328:	8b 45 08             	mov    0x8(%ebp),%eax
8010232b:	8b 55 10             	mov    0x10(%ebp),%edx
8010232e:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102331:	83 ec 0c             	sub    $0xc,%esp
80102334:	ff 75 08             	pushl  0x8(%ebp)
80102337:	e8 34 f6 ff ff       	call   80101970 <iupdate>
8010233c:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010233f:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102342:	c9                   	leave  
80102343:	c3                   	ret    

80102344 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102344:	f3 0f 1e fb          	endbr32 
80102348:	55                   	push   %ebp
80102349:	89 e5                	mov    %esp,%ebp
8010234b:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010234e:	83 ec 04             	sub    $0x4,%esp
80102351:	6a 0e                	push   $0xe
80102353:	ff 75 0c             	pushl  0xc(%ebp)
80102356:	ff 75 08             	pushl  0x8(%ebp)
80102359:	e8 bd 33 00 00       	call   8010571b <strncmp>
8010235e:	83 c4 10             	add    $0x10,%esp
}
80102361:	c9                   	leave  
80102362:	c3                   	ret    

80102363 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102363:	f3 0f 1e fb          	endbr32 
80102367:	55                   	push   %ebp
80102368:	89 e5                	mov    %esp,%ebp
8010236a:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010236d:	8b 45 08             	mov    0x8(%ebp),%eax
80102370:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102374:	66 83 f8 01          	cmp    $0x1,%ax
80102378:	74 0d                	je     80102387 <dirlookup+0x24>
    panic("dirlookup not DIR");
8010237a:	83 ec 0c             	sub    $0xc,%esp
8010237d:	68 45 94 10 80       	push   $0x80109445
80102382:	e8 81 e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102387:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010238e:	eb 7b                	jmp    8010240b <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102390:	6a 10                	push   $0x10
80102392:	ff 75 f4             	pushl  -0xc(%ebp)
80102395:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102398:	50                   	push   %eax
80102399:	ff 75 08             	pushl  0x8(%ebp)
8010239c:	e8 c0 fc ff ff       	call   80102061 <readi>
801023a1:	83 c4 10             	add    $0x10,%esp
801023a4:	83 f8 10             	cmp    $0x10,%eax
801023a7:	74 0d                	je     801023b6 <dirlookup+0x53>
      panic("dirlookup read");
801023a9:	83 ec 0c             	sub    $0xc,%esp
801023ac:	68 57 94 10 80       	push   $0x80109457
801023b1:	e8 52 e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
801023b6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023ba:	66 85 c0             	test   %ax,%ax
801023bd:	74 47                	je     80102406 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801023bf:	83 ec 08             	sub    $0x8,%esp
801023c2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023c5:	83 c0 02             	add    $0x2,%eax
801023c8:	50                   	push   %eax
801023c9:	ff 75 0c             	pushl  0xc(%ebp)
801023cc:	e8 73 ff ff ff       	call   80102344 <namecmp>
801023d1:	83 c4 10             	add    $0x10,%esp
801023d4:	85 c0                	test   %eax,%eax
801023d6:	75 2f                	jne    80102407 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801023d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023dc:	74 08                	je     801023e6 <dirlookup+0x83>
        *poff = off;
801023de:	8b 45 10             	mov    0x10(%ebp),%eax
801023e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023e4:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023e6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023ea:	0f b7 c0             	movzwl %ax,%eax
801023ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023f0:	8b 45 08             	mov    0x8(%ebp),%eax
801023f3:	8b 00                	mov    (%eax),%eax
801023f5:	83 ec 08             	sub    $0x8,%esp
801023f8:	ff 75 f0             	pushl  -0x10(%ebp)
801023fb:	50                   	push   %eax
801023fc:	e8 34 f6 ff ff       	call   80101a35 <iget>
80102401:	83 c4 10             	add    $0x10,%esp
80102404:	eb 19                	jmp    8010241f <dirlookup+0xbc>
      continue;
80102406:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102407:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010240b:	8b 45 08             	mov    0x8(%ebp),%eax
8010240e:	8b 40 58             	mov    0x58(%eax),%eax
80102411:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102414:	0f 82 76 ff ff ff    	jb     80102390 <dirlookup+0x2d>
    }
  }

  return 0;
8010241a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010241f:	c9                   	leave  
80102420:	c3                   	ret    

80102421 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102421:	f3 0f 1e fb          	endbr32 
80102425:	55                   	push   %ebp
80102426:	89 e5                	mov    %esp,%ebp
80102428:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010242b:	83 ec 04             	sub    $0x4,%esp
8010242e:	6a 00                	push   $0x0
80102430:	ff 75 0c             	pushl  0xc(%ebp)
80102433:	ff 75 08             	pushl  0x8(%ebp)
80102436:	e8 28 ff ff ff       	call   80102363 <dirlookup>
8010243b:	83 c4 10             	add    $0x10,%esp
8010243e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102441:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102445:	74 18                	je     8010245f <dirlink+0x3e>
    iput(ip);
80102447:	83 ec 0c             	sub    $0xc,%esp
8010244a:	ff 75 f0             	pushl  -0x10(%ebp)
8010244d:	e8 70 f8 ff ff       	call   80101cc2 <iput>
80102452:	83 c4 10             	add    $0x10,%esp
    return -1;
80102455:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010245a:	e9 9c 00 00 00       	jmp    801024fb <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010245f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102466:	eb 39                	jmp    801024a1 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246b:	6a 10                	push   $0x10
8010246d:	50                   	push   %eax
8010246e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102471:	50                   	push   %eax
80102472:	ff 75 08             	pushl  0x8(%ebp)
80102475:	e8 e7 fb ff ff       	call   80102061 <readi>
8010247a:	83 c4 10             	add    $0x10,%esp
8010247d:	83 f8 10             	cmp    $0x10,%eax
80102480:	74 0d                	je     8010248f <dirlink+0x6e>
      panic("dirlink read");
80102482:	83 ec 0c             	sub    $0xc,%esp
80102485:	68 66 94 10 80       	push   $0x80109466
8010248a:	e8 79 e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
8010248f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102493:	66 85 c0             	test   %ax,%ax
80102496:	74 18                	je     801024b0 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249b:	83 c0 10             	add    $0x10,%eax
8010249e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024a1:	8b 45 08             	mov    0x8(%ebp),%eax
801024a4:	8b 50 58             	mov    0x58(%eax),%edx
801024a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024aa:	39 c2                	cmp    %eax,%edx
801024ac:	77 ba                	ja     80102468 <dirlink+0x47>
801024ae:	eb 01                	jmp    801024b1 <dirlink+0x90>
      break;
801024b0:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801024b1:	83 ec 04             	sub    $0x4,%esp
801024b4:	6a 0e                	push   $0xe
801024b6:	ff 75 0c             	pushl  0xc(%ebp)
801024b9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024bc:	83 c0 02             	add    $0x2,%eax
801024bf:	50                   	push   %eax
801024c0:	e8 b0 32 00 00       	call   80105775 <strncpy>
801024c5:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801024c8:	8b 45 10             	mov    0x10(%ebp),%eax
801024cb:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024d2:	6a 10                	push   $0x10
801024d4:	50                   	push   %eax
801024d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024d8:	50                   	push   %eax
801024d9:	ff 75 08             	pushl  0x8(%ebp)
801024dc:	e8 d9 fc ff ff       	call   801021ba <writei>
801024e1:	83 c4 10             	add    $0x10,%esp
801024e4:	83 f8 10             	cmp    $0x10,%eax
801024e7:	74 0d                	je     801024f6 <dirlink+0xd5>
    panic("dirlink");
801024e9:	83 ec 0c             	sub    $0xc,%esp
801024ec:	68 73 94 10 80       	push   $0x80109473
801024f1:	e8 12 e1 ff ff       	call   80100608 <panic>

  return 0;
801024f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024fb:	c9                   	leave  
801024fc:	c3                   	ret    

801024fd <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801024fd:	f3 0f 1e fb          	endbr32 
80102501:	55                   	push   %ebp
80102502:	89 e5                	mov    %esp,%ebp
80102504:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102507:	eb 04                	jmp    8010250d <skipelem+0x10>
    path++;
80102509:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010250d:	8b 45 08             	mov    0x8(%ebp),%eax
80102510:	0f b6 00             	movzbl (%eax),%eax
80102513:	3c 2f                	cmp    $0x2f,%al
80102515:	74 f2                	je     80102509 <skipelem+0xc>
  if(*path == 0)
80102517:	8b 45 08             	mov    0x8(%ebp),%eax
8010251a:	0f b6 00             	movzbl (%eax),%eax
8010251d:	84 c0                	test   %al,%al
8010251f:	75 07                	jne    80102528 <skipelem+0x2b>
    return 0;
80102521:	b8 00 00 00 00       	mov    $0x0,%eax
80102526:	eb 77                	jmp    8010259f <skipelem+0xa2>
  s = path;
80102528:	8b 45 08             	mov    0x8(%ebp),%eax
8010252b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010252e:	eb 04                	jmp    80102534 <skipelem+0x37>
    path++;
80102530:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102534:	8b 45 08             	mov    0x8(%ebp),%eax
80102537:	0f b6 00             	movzbl (%eax),%eax
8010253a:	3c 2f                	cmp    $0x2f,%al
8010253c:	74 0a                	je     80102548 <skipelem+0x4b>
8010253e:	8b 45 08             	mov    0x8(%ebp),%eax
80102541:	0f b6 00             	movzbl (%eax),%eax
80102544:	84 c0                	test   %al,%al
80102546:	75 e8                	jne    80102530 <skipelem+0x33>
  len = path - s;
80102548:	8b 45 08             	mov    0x8(%ebp),%eax
8010254b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010254e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102551:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102555:	7e 15                	jle    8010256c <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102557:	83 ec 04             	sub    $0x4,%esp
8010255a:	6a 0e                	push   $0xe
8010255c:	ff 75 f4             	pushl  -0xc(%ebp)
8010255f:	ff 75 0c             	pushl  0xc(%ebp)
80102562:	e8 16 31 00 00       	call   8010567d <memmove>
80102567:	83 c4 10             	add    $0x10,%esp
8010256a:	eb 26                	jmp    80102592 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010256c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010256f:	83 ec 04             	sub    $0x4,%esp
80102572:	50                   	push   %eax
80102573:	ff 75 f4             	pushl  -0xc(%ebp)
80102576:	ff 75 0c             	pushl  0xc(%ebp)
80102579:	e8 ff 30 00 00       	call   8010567d <memmove>
8010257e:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102581:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102584:	8b 45 0c             	mov    0xc(%ebp),%eax
80102587:	01 d0                	add    %edx,%eax
80102589:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010258c:	eb 04                	jmp    80102592 <skipelem+0x95>
    path++;
8010258e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102592:	8b 45 08             	mov    0x8(%ebp),%eax
80102595:	0f b6 00             	movzbl (%eax),%eax
80102598:	3c 2f                	cmp    $0x2f,%al
8010259a:	74 f2                	je     8010258e <skipelem+0x91>
  return path;
8010259c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010259f:	c9                   	leave  
801025a0:	c3                   	ret    

801025a1 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025a1:	f3 0f 1e fb          	endbr32 
801025a5:	55                   	push   %ebp
801025a6:	89 e5                	mov    %esp,%ebp
801025a8:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025ab:	8b 45 08             	mov    0x8(%ebp),%eax
801025ae:	0f b6 00             	movzbl (%eax),%eax
801025b1:	3c 2f                	cmp    $0x2f,%al
801025b3:	75 17                	jne    801025cc <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801025b5:	83 ec 08             	sub    $0x8,%esp
801025b8:	6a 01                	push   $0x1
801025ba:	6a 01                	push   $0x1
801025bc:	e8 74 f4 ff ff       	call   80101a35 <iget>
801025c1:	83 c4 10             	add    $0x10,%esp
801025c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801025c7:	e9 ba 00 00 00       	jmp    80102686 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801025cc:	e8 3c 1f 00 00       	call   8010450d <myproc>
801025d1:	8b 40 68             	mov    0x68(%eax),%eax
801025d4:	83 ec 0c             	sub    $0xc,%esp
801025d7:	50                   	push   %eax
801025d8:	e8 3e f5 ff ff       	call   80101b1b <idup>
801025dd:	83 c4 10             	add    $0x10,%esp
801025e0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801025e3:	e9 9e 00 00 00       	jmp    80102686 <namex+0xe5>
    ilock(ip);
801025e8:	83 ec 0c             	sub    $0xc,%esp
801025eb:	ff 75 f4             	pushl  -0xc(%ebp)
801025ee:	e8 66 f5 ff ff       	call   80101b59 <ilock>
801025f3:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801025f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801025fd:	66 83 f8 01          	cmp    $0x1,%ax
80102601:	74 18                	je     8010261b <namex+0x7a>
      iunlockput(ip);
80102603:	83 ec 0c             	sub    $0xc,%esp
80102606:	ff 75 f4             	pushl  -0xc(%ebp)
80102609:	e8 88 f7 ff ff       	call   80101d96 <iunlockput>
8010260e:	83 c4 10             	add    $0x10,%esp
      return 0;
80102611:	b8 00 00 00 00       	mov    $0x0,%eax
80102616:	e9 a7 00 00 00       	jmp    801026c2 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010261b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010261f:	74 20                	je     80102641 <namex+0xa0>
80102621:	8b 45 08             	mov    0x8(%ebp),%eax
80102624:	0f b6 00             	movzbl (%eax),%eax
80102627:	84 c0                	test   %al,%al
80102629:	75 16                	jne    80102641 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010262b:	83 ec 0c             	sub    $0xc,%esp
8010262e:	ff 75 f4             	pushl  -0xc(%ebp)
80102631:	e8 3a f6 ff ff       	call   80101c70 <iunlock>
80102636:	83 c4 10             	add    $0x10,%esp
      return ip;
80102639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010263c:	e9 81 00 00 00       	jmp    801026c2 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102641:	83 ec 04             	sub    $0x4,%esp
80102644:	6a 00                	push   $0x0
80102646:	ff 75 10             	pushl  0x10(%ebp)
80102649:	ff 75 f4             	pushl  -0xc(%ebp)
8010264c:	e8 12 fd ff ff       	call   80102363 <dirlookup>
80102651:	83 c4 10             	add    $0x10,%esp
80102654:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102657:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010265b:	75 15                	jne    80102672 <namex+0xd1>
      iunlockput(ip);
8010265d:	83 ec 0c             	sub    $0xc,%esp
80102660:	ff 75 f4             	pushl  -0xc(%ebp)
80102663:	e8 2e f7 ff ff       	call   80101d96 <iunlockput>
80102668:	83 c4 10             	add    $0x10,%esp
      return 0;
8010266b:	b8 00 00 00 00       	mov    $0x0,%eax
80102670:	eb 50                	jmp    801026c2 <namex+0x121>
    }
    iunlockput(ip);
80102672:	83 ec 0c             	sub    $0xc,%esp
80102675:	ff 75 f4             	pushl  -0xc(%ebp)
80102678:	e8 19 f7 ff ff       	call   80101d96 <iunlockput>
8010267d:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102683:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102686:	83 ec 08             	sub    $0x8,%esp
80102689:	ff 75 10             	pushl  0x10(%ebp)
8010268c:	ff 75 08             	pushl  0x8(%ebp)
8010268f:	e8 69 fe ff ff       	call   801024fd <skipelem>
80102694:	83 c4 10             	add    $0x10,%esp
80102697:	89 45 08             	mov    %eax,0x8(%ebp)
8010269a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010269e:	0f 85 44 ff ff ff    	jne    801025e8 <namex+0x47>
  }
  if(nameiparent){
801026a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026a8:	74 15                	je     801026bf <namex+0x11e>
    iput(ip);
801026aa:	83 ec 0c             	sub    $0xc,%esp
801026ad:	ff 75 f4             	pushl  -0xc(%ebp)
801026b0:	e8 0d f6 ff ff       	call   80101cc2 <iput>
801026b5:	83 c4 10             	add    $0x10,%esp
    return 0;
801026b8:	b8 00 00 00 00       	mov    $0x0,%eax
801026bd:	eb 03                	jmp    801026c2 <namex+0x121>
  }
  return ip;
801026bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026c2:	c9                   	leave  
801026c3:	c3                   	ret    

801026c4 <namei>:

struct inode*
namei(char *path)
{
801026c4:	f3 0f 1e fb          	endbr32 
801026c8:	55                   	push   %ebp
801026c9:	89 e5                	mov    %esp,%ebp
801026cb:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026ce:	83 ec 04             	sub    $0x4,%esp
801026d1:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026d4:	50                   	push   %eax
801026d5:	6a 00                	push   $0x0
801026d7:	ff 75 08             	pushl  0x8(%ebp)
801026da:	e8 c2 fe ff ff       	call   801025a1 <namex>
801026df:	83 c4 10             	add    $0x10,%esp
}
801026e2:	c9                   	leave  
801026e3:	c3                   	ret    

801026e4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801026e4:	f3 0f 1e fb          	endbr32 
801026e8:	55                   	push   %ebp
801026e9:	89 e5                	mov    %esp,%ebp
801026eb:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801026ee:	83 ec 04             	sub    $0x4,%esp
801026f1:	ff 75 0c             	pushl  0xc(%ebp)
801026f4:	6a 01                	push   $0x1
801026f6:	ff 75 08             	pushl  0x8(%ebp)
801026f9:	e8 a3 fe ff ff       	call   801025a1 <namex>
801026fe:	83 c4 10             	add    $0x10,%esp
}
80102701:	c9                   	leave  
80102702:	c3                   	ret    

80102703 <inb>:
{
80102703:	55                   	push   %ebp
80102704:	89 e5                	mov    %esp,%ebp
80102706:	83 ec 14             	sub    $0x14,%esp
80102709:	8b 45 08             	mov    0x8(%ebp),%eax
8010270c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102710:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102714:	89 c2                	mov    %eax,%edx
80102716:	ec                   	in     (%dx),%al
80102717:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010271a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010271e:	c9                   	leave  
8010271f:	c3                   	ret    

80102720 <insl>:
{
80102720:	55                   	push   %ebp
80102721:	89 e5                	mov    %esp,%ebp
80102723:	57                   	push   %edi
80102724:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102725:	8b 55 08             	mov    0x8(%ebp),%edx
80102728:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010272b:	8b 45 10             	mov    0x10(%ebp),%eax
8010272e:	89 cb                	mov    %ecx,%ebx
80102730:	89 df                	mov    %ebx,%edi
80102732:	89 c1                	mov    %eax,%ecx
80102734:	fc                   	cld    
80102735:	f3 6d                	rep insl (%dx),%es:(%edi)
80102737:	89 c8                	mov    %ecx,%eax
80102739:	89 fb                	mov    %edi,%ebx
8010273b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010273e:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102741:	90                   	nop
80102742:	5b                   	pop    %ebx
80102743:	5f                   	pop    %edi
80102744:	5d                   	pop    %ebp
80102745:	c3                   	ret    

80102746 <outb>:
{
80102746:	55                   	push   %ebp
80102747:	89 e5                	mov    %esp,%ebp
80102749:	83 ec 08             	sub    $0x8,%esp
8010274c:	8b 45 08             	mov    0x8(%ebp),%eax
8010274f:	8b 55 0c             	mov    0xc(%ebp),%edx
80102752:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102756:	89 d0                	mov    %edx,%eax
80102758:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010275b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010275f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102763:	ee                   	out    %al,(%dx)
}
80102764:	90                   	nop
80102765:	c9                   	leave  
80102766:	c3                   	ret    

80102767 <outsl>:
{
80102767:	55                   	push   %ebp
80102768:	89 e5                	mov    %esp,%ebp
8010276a:	56                   	push   %esi
8010276b:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010276c:	8b 55 08             	mov    0x8(%ebp),%edx
8010276f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102772:	8b 45 10             	mov    0x10(%ebp),%eax
80102775:	89 cb                	mov    %ecx,%ebx
80102777:	89 de                	mov    %ebx,%esi
80102779:	89 c1                	mov    %eax,%ecx
8010277b:	fc                   	cld    
8010277c:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010277e:	89 c8                	mov    %ecx,%eax
80102780:	89 f3                	mov    %esi,%ebx
80102782:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102785:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102788:	90                   	nop
80102789:	5b                   	pop    %ebx
8010278a:	5e                   	pop    %esi
8010278b:	5d                   	pop    %ebp
8010278c:	c3                   	ret    

8010278d <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010278d:	f3 0f 1e fb          	endbr32 
80102791:	55                   	push   %ebp
80102792:	89 e5                	mov    %esp,%ebp
80102794:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102797:	90                   	nop
80102798:	68 f7 01 00 00       	push   $0x1f7
8010279d:	e8 61 ff ff ff       	call   80102703 <inb>
801027a2:	83 c4 04             	add    $0x4,%esp
801027a5:	0f b6 c0             	movzbl %al,%eax
801027a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801027ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027ae:	25 c0 00 00 00       	and    $0xc0,%eax
801027b3:	83 f8 40             	cmp    $0x40,%eax
801027b6:	75 e0                	jne    80102798 <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801027b8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027bc:	74 11                	je     801027cf <idewait+0x42>
801027be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027c1:	83 e0 21             	and    $0x21,%eax
801027c4:	85 c0                	test   %eax,%eax
801027c6:	74 07                	je     801027cf <idewait+0x42>
    return -1;
801027c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027cd:	eb 05                	jmp    801027d4 <idewait+0x47>
  return 0;
801027cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801027d4:	c9                   	leave  
801027d5:	c3                   	ret    

801027d6 <ideinit>:

void
ideinit(void)
{
801027d6:	f3 0f 1e fb          	endbr32 
801027da:	55                   	push   %ebp
801027db:	89 e5                	mov    %esp,%ebp
801027dd:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801027e0:	83 ec 08             	sub    $0x8,%esp
801027e3:	68 7b 94 10 80       	push   $0x8010947b
801027e8:	68 00 c6 10 80       	push   $0x8010c600
801027ed:	e8 ff 2a 00 00       	call   801052f1 <initlock>
801027f2:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801027f5:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801027fa:	83 e8 01             	sub    $0x1,%eax
801027fd:	83 ec 08             	sub    $0x8,%esp
80102800:	50                   	push   %eax
80102801:	6a 0e                	push   $0xe
80102803:	e8 bb 04 00 00       	call   80102cc3 <ioapicenable>
80102808:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010280b:	83 ec 0c             	sub    $0xc,%esp
8010280e:	6a 00                	push   $0x0
80102810:	e8 78 ff ff ff       	call   8010278d <idewait>
80102815:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102818:	83 ec 08             	sub    $0x8,%esp
8010281b:	68 f0 00 00 00       	push   $0xf0
80102820:	68 f6 01 00 00       	push   $0x1f6
80102825:	e8 1c ff ff ff       	call   80102746 <outb>
8010282a:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010282d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102834:	eb 24                	jmp    8010285a <ideinit+0x84>
    if(inb(0x1f7) != 0){
80102836:	83 ec 0c             	sub    $0xc,%esp
80102839:	68 f7 01 00 00       	push   $0x1f7
8010283e:	e8 c0 fe ff ff       	call   80102703 <inb>
80102843:	83 c4 10             	add    $0x10,%esp
80102846:	84 c0                	test   %al,%al
80102848:	74 0c                	je     80102856 <ideinit+0x80>
      havedisk1 = 1;
8010284a:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102851:	00 00 00 
      break;
80102854:	eb 0d                	jmp    80102863 <ideinit+0x8d>
  for(i=0; i<1000; i++){
80102856:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010285a:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102861:	7e d3                	jle    80102836 <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102863:	83 ec 08             	sub    $0x8,%esp
80102866:	68 e0 00 00 00       	push   $0xe0
8010286b:	68 f6 01 00 00       	push   $0x1f6
80102870:	e8 d1 fe ff ff       	call   80102746 <outb>
80102875:	83 c4 10             	add    $0x10,%esp
}
80102878:	90                   	nop
80102879:	c9                   	leave  
8010287a:	c3                   	ret    

8010287b <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010287b:	f3 0f 1e fb          	endbr32 
8010287f:	55                   	push   %ebp
80102880:	89 e5                	mov    %esp,%ebp
80102882:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102885:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102889:	75 0d                	jne    80102898 <idestart+0x1d>
    panic("idestart");
8010288b:	83 ec 0c             	sub    $0xc,%esp
8010288e:	68 7f 94 10 80       	push   $0x8010947f
80102893:	e8 70 dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
80102898:	8b 45 08             	mov    0x8(%ebp),%eax
8010289b:	8b 40 08             	mov    0x8(%eax),%eax
8010289e:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801028a3:	76 0d                	jbe    801028b2 <idestart+0x37>
    panic("incorrect blockno");
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 88 94 10 80       	push   $0x80109488
801028ad:	e8 56 dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801028b2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801028b9:	8b 45 08             	mov    0x8(%ebp),%eax
801028bc:	8b 50 08             	mov    0x8(%eax),%edx
801028bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c2:	0f af c2             	imul   %edx,%eax
801028c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801028c8:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028cc:	75 07                	jne    801028d5 <idestart+0x5a>
801028ce:	b8 20 00 00 00       	mov    $0x20,%eax
801028d3:	eb 05                	jmp    801028da <idestart+0x5f>
801028d5:	b8 c4 00 00 00       	mov    $0xc4,%eax
801028da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801028dd:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028e1:	75 07                	jne    801028ea <idestart+0x6f>
801028e3:	b8 30 00 00 00       	mov    $0x30,%eax
801028e8:	eb 05                	jmp    801028ef <idestart+0x74>
801028ea:	b8 c5 00 00 00       	mov    $0xc5,%eax
801028ef:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801028f2:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801028f6:	7e 0d                	jle    80102905 <idestart+0x8a>
801028f8:	83 ec 0c             	sub    $0xc,%esp
801028fb:	68 7f 94 10 80       	push   $0x8010947f
80102900:	e8 03 dd ff ff       	call   80100608 <panic>

  idewait(0);
80102905:	83 ec 0c             	sub    $0xc,%esp
80102908:	6a 00                	push   $0x0
8010290a:	e8 7e fe ff ff       	call   8010278d <idewait>
8010290f:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102912:	83 ec 08             	sub    $0x8,%esp
80102915:	6a 00                	push   $0x0
80102917:	68 f6 03 00 00       	push   $0x3f6
8010291c:	e8 25 fe ff ff       	call   80102746 <outb>
80102921:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102927:	0f b6 c0             	movzbl %al,%eax
8010292a:	83 ec 08             	sub    $0x8,%esp
8010292d:	50                   	push   %eax
8010292e:	68 f2 01 00 00       	push   $0x1f2
80102933:	e8 0e fe ff ff       	call   80102746 <outb>
80102938:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010293b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010293e:	0f b6 c0             	movzbl %al,%eax
80102941:	83 ec 08             	sub    $0x8,%esp
80102944:	50                   	push   %eax
80102945:	68 f3 01 00 00       	push   $0x1f3
8010294a:	e8 f7 fd ff ff       	call   80102746 <outb>
8010294f:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102952:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102955:	c1 f8 08             	sar    $0x8,%eax
80102958:	0f b6 c0             	movzbl %al,%eax
8010295b:	83 ec 08             	sub    $0x8,%esp
8010295e:	50                   	push   %eax
8010295f:	68 f4 01 00 00       	push   $0x1f4
80102964:	e8 dd fd ff ff       	call   80102746 <outb>
80102969:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010296c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010296f:	c1 f8 10             	sar    $0x10,%eax
80102972:	0f b6 c0             	movzbl %al,%eax
80102975:	83 ec 08             	sub    $0x8,%esp
80102978:	50                   	push   %eax
80102979:	68 f5 01 00 00       	push   $0x1f5
8010297e:	e8 c3 fd ff ff       	call   80102746 <outb>
80102983:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102986:	8b 45 08             	mov    0x8(%ebp),%eax
80102989:	8b 40 04             	mov    0x4(%eax),%eax
8010298c:	c1 e0 04             	shl    $0x4,%eax
8010298f:	83 e0 10             	and    $0x10,%eax
80102992:	89 c2                	mov    %eax,%edx
80102994:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102997:	c1 f8 18             	sar    $0x18,%eax
8010299a:	83 e0 0f             	and    $0xf,%eax
8010299d:	09 d0                	or     %edx,%eax
8010299f:	83 c8 e0             	or     $0xffffffe0,%eax
801029a2:	0f b6 c0             	movzbl %al,%eax
801029a5:	83 ec 08             	sub    $0x8,%esp
801029a8:	50                   	push   %eax
801029a9:	68 f6 01 00 00       	push   $0x1f6
801029ae:	e8 93 fd ff ff       	call   80102746 <outb>
801029b3:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801029b6:	8b 45 08             	mov    0x8(%ebp),%eax
801029b9:	8b 00                	mov    (%eax),%eax
801029bb:	83 e0 04             	and    $0x4,%eax
801029be:	85 c0                	test   %eax,%eax
801029c0:	74 35                	je     801029f7 <idestart+0x17c>
    outb(0x1f7, write_cmd);
801029c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801029c5:	0f b6 c0             	movzbl %al,%eax
801029c8:	83 ec 08             	sub    $0x8,%esp
801029cb:	50                   	push   %eax
801029cc:	68 f7 01 00 00       	push   $0x1f7
801029d1:	e8 70 fd ff ff       	call   80102746 <outb>
801029d6:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801029d9:	8b 45 08             	mov    0x8(%ebp),%eax
801029dc:	83 c0 5c             	add    $0x5c,%eax
801029df:	83 ec 04             	sub    $0x4,%esp
801029e2:	68 80 00 00 00       	push   $0x80
801029e7:	50                   	push   %eax
801029e8:	68 f0 01 00 00       	push   $0x1f0
801029ed:	e8 75 fd ff ff       	call   80102767 <outsl>
801029f2:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801029f5:	eb 17                	jmp    80102a0e <idestart+0x193>
    outb(0x1f7, read_cmd);
801029f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029fa:	0f b6 c0             	movzbl %al,%eax
801029fd:	83 ec 08             	sub    $0x8,%esp
80102a00:	50                   	push   %eax
80102a01:	68 f7 01 00 00       	push   $0x1f7
80102a06:	e8 3b fd ff ff       	call   80102746 <outb>
80102a0b:	83 c4 10             	add    $0x10,%esp
}
80102a0e:	90                   	nop
80102a0f:	c9                   	leave  
80102a10:	c3                   	ret    

80102a11 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a11:	f3 0f 1e fb          	endbr32 
80102a15:	55                   	push   %ebp
80102a16:	89 e5                	mov    %esp,%ebp
80102a18:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a1b:	83 ec 0c             	sub    $0xc,%esp
80102a1e:	68 00 c6 10 80       	push   $0x8010c600
80102a23:	e8 ef 28 00 00       	call   80105317 <acquire>
80102a28:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102a2b:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a30:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a37:	75 15                	jne    80102a4e <ideintr+0x3d>
    release(&idelock);
80102a39:	83 ec 0c             	sub    $0xc,%esp
80102a3c:	68 00 c6 10 80       	push   $0x8010c600
80102a41:	e8 43 29 00 00       	call   80105389 <release>
80102a46:	83 c4 10             	add    $0x10,%esp
    return;
80102a49:	e9 9a 00 00 00       	jmp    80102ae8 <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a51:	8b 40 58             	mov    0x58(%eax),%eax
80102a54:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5c:	8b 00                	mov    (%eax),%eax
80102a5e:	83 e0 04             	and    $0x4,%eax
80102a61:	85 c0                	test   %eax,%eax
80102a63:	75 2d                	jne    80102a92 <ideintr+0x81>
80102a65:	83 ec 0c             	sub    $0xc,%esp
80102a68:	6a 01                	push   $0x1
80102a6a:	e8 1e fd ff ff       	call   8010278d <idewait>
80102a6f:	83 c4 10             	add    $0x10,%esp
80102a72:	85 c0                	test   %eax,%eax
80102a74:	78 1c                	js     80102a92 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a79:	83 c0 5c             	add    $0x5c,%eax
80102a7c:	83 ec 04             	sub    $0x4,%esp
80102a7f:	68 80 00 00 00       	push   $0x80
80102a84:	50                   	push   %eax
80102a85:	68 f0 01 00 00       	push   $0x1f0
80102a8a:	e8 91 fc ff ff       	call   80102720 <insl>
80102a8f:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a95:	8b 00                	mov    (%eax),%eax
80102a97:	83 c8 02             	or     $0x2,%eax
80102a9a:	89 c2                	mov    %eax,%edx
80102a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9f:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa4:	8b 00                	mov    (%eax),%eax
80102aa6:	83 e0 fb             	and    $0xfffffffb,%eax
80102aa9:	89 c2                	mov    %eax,%edx
80102aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aae:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102ab0:	83 ec 0c             	sub    $0xc,%esp
80102ab3:	ff 75 f4             	pushl  -0xc(%ebp)
80102ab6:	e8 dc 24 00 00       	call   80104f97 <wakeup>
80102abb:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102abe:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102ac3:	85 c0                	test   %eax,%eax
80102ac5:	74 11                	je     80102ad8 <ideintr+0xc7>
    idestart(idequeue);
80102ac7:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102acc:	83 ec 0c             	sub    $0xc,%esp
80102acf:	50                   	push   %eax
80102ad0:	e8 a6 fd ff ff       	call   8010287b <idestart>
80102ad5:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102ad8:	83 ec 0c             	sub    $0xc,%esp
80102adb:	68 00 c6 10 80       	push   $0x8010c600
80102ae0:	e8 a4 28 00 00       	call   80105389 <release>
80102ae5:	83 c4 10             	add    $0x10,%esp
}
80102ae8:	c9                   	leave  
80102ae9:	c3                   	ret    

80102aea <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102aea:	f3 0f 1e fb          	endbr32 
80102aee:	55                   	push   %ebp
80102aef:	89 e5                	mov    %esp,%ebp
80102af1:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102af4:	8b 45 08             	mov    0x8(%ebp),%eax
80102af7:	83 c0 0c             	add    $0xc,%eax
80102afa:	83 ec 0c             	sub    $0xc,%esp
80102afd:	50                   	push   %eax
80102afe:	e8 55 27 00 00       	call   80105258 <holdingsleep>
80102b03:	83 c4 10             	add    $0x10,%esp
80102b06:	85 c0                	test   %eax,%eax
80102b08:	75 0d                	jne    80102b17 <iderw+0x2d>
    panic("iderw: buf not locked");
80102b0a:	83 ec 0c             	sub    $0xc,%esp
80102b0d:	68 9a 94 10 80       	push   $0x8010949a
80102b12:	e8 f1 da ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b17:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1a:	8b 00                	mov    (%eax),%eax
80102b1c:	83 e0 06             	and    $0x6,%eax
80102b1f:	83 f8 02             	cmp    $0x2,%eax
80102b22:	75 0d                	jne    80102b31 <iderw+0x47>
    panic("iderw: nothing to do");
80102b24:	83 ec 0c             	sub    $0xc,%esp
80102b27:	68 b0 94 10 80       	push   $0x801094b0
80102b2c:	e8 d7 da ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102b31:	8b 45 08             	mov    0x8(%ebp),%eax
80102b34:	8b 40 04             	mov    0x4(%eax),%eax
80102b37:	85 c0                	test   %eax,%eax
80102b39:	74 16                	je     80102b51 <iderw+0x67>
80102b3b:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102b40:	85 c0                	test   %eax,%eax
80102b42:	75 0d                	jne    80102b51 <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102b44:	83 ec 0c             	sub    $0xc,%esp
80102b47:	68 c5 94 10 80       	push   $0x801094c5
80102b4c:	e8 b7 da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b51:	83 ec 0c             	sub    $0xc,%esp
80102b54:	68 00 c6 10 80       	push   $0x8010c600
80102b59:	e8 b9 27 00 00       	call   80105317 <acquire>
80102b5e:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b61:	8b 45 08             	mov    0x8(%ebp),%eax
80102b64:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b6b:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b72:	eb 0b                	jmp    80102b7f <iderw+0x95>
80102b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b77:	8b 00                	mov    (%eax),%eax
80102b79:	83 c0 58             	add    $0x58,%eax
80102b7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b82:	8b 00                	mov    (%eax),%eax
80102b84:	85 c0                	test   %eax,%eax
80102b86:	75 ec                	jne    80102b74 <iderw+0x8a>
    ;
  *pp = b;
80102b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8b:	8b 55 08             	mov    0x8(%ebp),%edx
80102b8e:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b90:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b95:	39 45 08             	cmp    %eax,0x8(%ebp)
80102b98:	75 23                	jne    80102bbd <iderw+0xd3>
    idestart(b);
80102b9a:	83 ec 0c             	sub    $0xc,%esp
80102b9d:	ff 75 08             	pushl  0x8(%ebp)
80102ba0:	e8 d6 fc ff ff       	call   8010287b <idestart>
80102ba5:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ba8:	eb 13                	jmp    80102bbd <iderw+0xd3>
    sleep(b, &idelock);
80102baa:	83 ec 08             	sub    $0x8,%esp
80102bad:	68 00 c6 10 80       	push   $0x8010c600
80102bb2:	ff 75 08             	pushl  0x8(%ebp)
80102bb5:	e8 eb 22 00 00       	call   80104ea5 <sleep>
80102bba:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc0:	8b 00                	mov    (%eax),%eax
80102bc2:	83 e0 06             	and    $0x6,%eax
80102bc5:	83 f8 02             	cmp    $0x2,%eax
80102bc8:	75 e0                	jne    80102baa <iderw+0xc0>
  }


  release(&idelock);
80102bca:	83 ec 0c             	sub    $0xc,%esp
80102bcd:	68 00 c6 10 80       	push   $0x8010c600
80102bd2:	e8 b2 27 00 00       	call   80105389 <release>
80102bd7:	83 c4 10             	add    $0x10,%esp
}
80102bda:	90                   	nop
80102bdb:	c9                   	leave  
80102bdc:	c3                   	ret    

80102bdd <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bdd:	f3 0f 1e fb          	endbr32 
80102be1:	55                   	push   %ebp
80102be2:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102be4:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102be9:	8b 55 08             	mov    0x8(%ebp),%edx
80102bec:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bee:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bf3:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bf6:	5d                   	pop    %ebp
80102bf7:	c3                   	ret    

80102bf8 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bf8:	f3 0f 1e fb          	endbr32 
80102bfc:	55                   	push   %ebp
80102bfd:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bff:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102c04:	8b 55 08             	mov    0x8(%ebp),%edx
80102c07:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c09:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102c0e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c11:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c14:	90                   	nop
80102c15:	5d                   	pop    %ebp
80102c16:	c3                   	ret    

80102c17 <ioapicinit>:

void
ioapicinit(void)
{
80102c17:	f3 0f 1e fb          	endbr32 
80102c1b:	55                   	push   %ebp
80102c1c:	89 e5                	mov    %esp,%ebp
80102c1e:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c21:	c7 05 d4 46 11 80 00 	movl   $0xfec00000,0x801146d4
80102c28:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c2b:	6a 01                	push   $0x1
80102c2d:	e8 ab ff ff ff       	call   80102bdd <ioapicread>
80102c32:	83 c4 04             	add    $0x4,%esp
80102c35:	c1 e8 10             	shr    $0x10,%eax
80102c38:	25 ff 00 00 00       	and    $0xff,%eax
80102c3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c40:	6a 00                	push   $0x0
80102c42:	e8 96 ff ff ff       	call   80102bdd <ioapicread>
80102c47:	83 c4 04             	add    $0x4,%esp
80102c4a:	c1 e8 18             	shr    $0x18,%eax
80102c4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c50:	0f b6 05 00 48 11 80 	movzbl 0x80114800,%eax
80102c57:	0f b6 c0             	movzbl %al,%eax
80102c5a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c5d:	74 10                	je     80102c6f <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c5f:	83 ec 0c             	sub    $0xc,%esp
80102c62:	68 e4 94 10 80       	push   $0x801094e4
80102c67:	e8 ac d7 ff ff       	call   80100418 <cprintf>
80102c6c:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c76:	eb 3f                	jmp    80102cb7 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c7b:	83 c0 20             	add    $0x20,%eax
80102c7e:	0d 00 00 01 00       	or     $0x10000,%eax
80102c83:	89 c2                	mov    %eax,%edx
80102c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c88:	83 c0 08             	add    $0x8,%eax
80102c8b:	01 c0                	add    %eax,%eax
80102c8d:	83 ec 08             	sub    $0x8,%esp
80102c90:	52                   	push   %edx
80102c91:	50                   	push   %eax
80102c92:	e8 61 ff ff ff       	call   80102bf8 <ioapicwrite>
80102c97:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c9d:	83 c0 08             	add    $0x8,%eax
80102ca0:	01 c0                	add    %eax,%eax
80102ca2:	83 c0 01             	add    $0x1,%eax
80102ca5:	83 ec 08             	sub    $0x8,%esp
80102ca8:	6a 00                	push   $0x0
80102caa:	50                   	push   %eax
80102cab:	e8 48 ff ff ff       	call   80102bf8 <ioapicwrite>
80102cb0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102cb3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cba:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cbd:	7e b9                	jle    80102c78 <ioapicinit+0x61>
  }
}
80102cbf:	90                   	nop
80102cc0:	90                   	nop
80102cc1:	c9                   	leave  
80102cc2:	c3                   	ret    

80102cc3 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cc3:	f3 0f 1e fb          	endbr32 
80102cc7:	55                   	push   %ebp
80102cc8:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cca:	8b 45 08             	mov    0x8(%ebp),%eax
80102ccd:	83 c0 20             	add    $0x20,%eax
80102cd0:	89 c2                	mov    %eax,%edx
80102cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd5:	83 c0 08             	add    $0x8,%eax
80102cd8:	01 c0                	add    %eax,%eax
80102cda:	52                   	push   %edx
80102cdb:	50                   	push   %eax
80102cdc:	e8 17 ff ff ff       	call   80102bf8 <ioapicwrite>
80102ce1:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ce7:	c1 e0 18             	shl    $0x18,%eax
80102cea:	89 c2                	mov    %eax,%edx
80102cec:	8b 45 08             	mov    0x8(%ebp),%eax
80102cef:	83 c0 08             	add    $0x8,%eax
80102cf2:	01 c0                	add    %eax,%eax
80102cf4:	83 c0 01             	add    $0x1,%eax
80102cf7:	52                   	push   %edx
80102cf8:	50                   	push   %eax
80102cf9:	e8 fa fe ff ff       	call   80102bf8 <ioapicwrite>
80102cfe:	83 c4 08             	add    $0x8,%esp
}
80102d01:	90                   	nop
80102d02:	c9                   	leave  
80102d03:	c3                   	ret    

80102d04 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d04:	f3 0f 1e fb          	endbr32 
80102d08:	55                   	push   %ebp
80102d09:	89 e5                	mov    %esp,%ebp
80102d0b:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102d0e:	83 ec 08             	sub    $0x8,%esp
80102d11:	68 18 95 10 80       	push   $0x80109518
80102d16:	68 e0 46 11 80       	push   $0x801146e0
80102d1b:	e8 d1 25 00 00       	call   801052f1 <initlock>
80102d20:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102d23:	c7 05 14 47 11 80 00 	movl   $0x0,0x80114714
80102d2a:	00 00 00 
  freerange(vstart, vend);
80102d2d:	83 ec 08             	sub    $0x8,%esp
80102d30:	ff 75 0c             	pushl  0xc(%ebp)
80102d33:	ff 75 08             	pushl  0x8(%ebp)
80102d36:	e8 2e 00 00 00       	call   80102d69 <freerange>
80102d3b:	83 c4 10             	add    $0x10,%esp
}
80102d3e:	90                   	nop
80102d3f:	c9                   	leave  
80102d40:	c3                   	ret    

80102d41 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d41:	f3 0f 1e fb          	endbr32 
80102d45:	55                   	push   %ebp
80102d46:	89 e5                	mov    %esp,%ebp
80102d48:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102d4b:	83 ec 08             	sub    $0x8,%esp
80102d4e:	ff 75 0c             	pushl  0xc(%ebp)
80102d51:	ff 75 08             	pushl  0x8(%ebp)
80102d54:	e8 10 00 00 00       	call   80102d69 <freerange>
80102d59:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d5c:	c7 05 14 47 11 80 01 	movl   $0x1,0x80114714
80102d63:	00 00 00 
}
80102d66:	90                   	nop
80102d67:	c9                   	leave  
80102d68:	c3                   	ret    

80102d69 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d69:	f3 0f 1e fb          	endbr32 
80102d6d:	55                   	push   %ebp
80102d6e:	89 e5                	mov    %esp,%ebp
80102d70:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d73:	8b 45 08             	mov    0x8(%ebp),%eax
80102d76:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d83:	eb 15                	jmp    80102d9a <freerange+0x31>
    kfree(p);
80102d85:	83 ec 0c             	sub    $0xc,%esp
80102d88:	ff 75 f4             	pushl  -0xc(%ebp)
80102d8b:	e8 1b 00 00 00       	call   80102dab <kfree>
80102d90:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d93:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d9d:	05 00 10 00 00       	add    $0x1000,%eax
80102da2:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102da5:	73 de                	jae    80102d85 <freerange+0x1c>
}
80102da7:	90                   	nop
80102da8:	90                   	nop
80102da9:	c9                   	leave  
80102daa:	c3                   	ret    

80102dab <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dab:	f3 0f 1e fb          	endbr32 
80102daf:	55                   	push   %ebp
80102db0:	89 e5                	mov    %esp,%ebp
80102db2:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102db5:	8b 45 08             	mov    0x8(%ebp),%eax
80102db8:	25 ff 0f 00 00       	and    $0xfff,%eax
80102dbd:	85 c0                	test   %eax,%eax
80102dbf:	75 18                	jne    80102dd9 <kfree+0x2e>
80102dc1:	81 7d 08 48 7f 11 80 	cmpl   $0x80117f48,0x8(%ebp)
80102dc8:	72 0f                	jb     80102dd9 <kfree+0x2e>
80102dca:	8b 45 08             	mov    0x8(%ebp),%eax
80102dcd:	05 00 00 00 80       	add    $0x80000000,%eax
80102dd2:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102dd7:	76 0d                	jbe    80102de6 <kfree+0x3b>
    panic("kfree");
80102dd9:	83 ec 0c             	sub    $0xc,%esp
80102ddc:	68 1d 95 10 80       	push   $0x8010951d
80102de1:	e8 22 d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102de6:	83 ec 04             	sub    $0x4,%esp
80102de9:	68 00 10 00 00       	push   $0x1000
80102dee:	6a 01                	push   $0x1
80102df0:	ff 75 08             	pushl  0x8(%ebp)
80102df3:	e8 be 27 00 00       	call   801055b6 <memset>
80102df8:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102dfb:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e00:	85 c0                	test   %eax,%eax
80102e02:	74 10                	je     80102e14 <kfree+0x69>
    acquire(&kmem.lock);
80102e04:	83 ec 0c             	sub    $0xc,%esp
80102e07:	68 e0 46 11 80       	push   $0x801146e0
80102e0c:	e8 06 25 00 00       	call   80105317 <acquire>
80102e11:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102e14:	8b 45 08             	mov    0x8(%ebp),%eax
80102e17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e1a:	8b 15 18 47 11 80    	mov    0x80114718,%edx
80102e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e23:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e28:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e2d:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e32:	85 c0                	test   %eax,%eax
80102e34:	74 10                	je     80102e46 <kfree+0x9b>
    release(&kmem.lock);
80102e36:	83 ec 0c             	sub    $0xc,%esp
80102e39:	68 e0 46 11 80       	push   $0x801146e0
80102e3e:	e8 46 25 00 00       	call   80105389 <release>
80102e43:	83 c4 10             	add    $0x10,%esp
}
80102e46:	90                   	nop
80102e47:	c9                   	leave  
80102e48:	c3                   	ret    

80102e49 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e49:	f3 0f 1e fb          	endbr32 
80102e4d:	55                   	push   %ebp
80102e4e:	89 e5                	mov    %esp,%ebp
80102e50:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e53:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e58:	85 c0                	test   %eax,%eax
80102e5a:	74 10                	je     80102e6c <kalloc+0x23>
    acquire(&kmem.lock);
80102e5c:	83 ec 0c             	sub    $0xc,%esp
80102e5f:	68 e0 46 11 80       	push   $0x801146e0
80102e64:	e8 ae 24 00 00       	call   80105317 <acquire>
80102e69:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e6c:	a1 18 47 11 80       	mov    0x80114718,%eax
80102e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e78:	74 0a                	je     80102e84 <kalloc+0x3b>
    kmem.freelist = r->next;
80102e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e7d:	8b 00                	mov    (%eax),%eax
80102e7f:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e84:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e89:	85 c0                	test   %eax,%eax
80102e8b:	74 10                	je     80102e9d <kalloc+0x54>
    release(&kmem.lock);
80102e8d:	83 ec 0c             	sub    $0xc,%esp
80102e90:	68 e0 46 11 80       	push   $0x801146e0
80102e95:	e8 ef 24 00 00       	call   80105389 <release>
80102e9a:	83 c4 10             	add    $0x10,%esp
  cprintf("p4Debug : kalloc returns %d %x\n", PPN(V2P(r)), V2P(r));
80102e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea0:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80102ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea9:	05 00 00 00 80       	add    $0x80000000,%eax
80102eae:	c1 e8 0c             	shr    $0xc,%eax
80102eb1:	83 ec 04             	sub    $0x4,%esp
80102eb4:	52                   	push   %edx
80102eb5:	50                   	push   %eax
80102eb6:	68 24 95 10 80       	push   $0x80109524
80102ebb:	e8 58 d5 ff ff       	call   80100418 <cprintf>
80102ec0:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ec6:	c9                   	leave  
80102ec7:	c3                   	ret    

80102ec8 <inb>:
{
80102ec8:	55                   	push   %ebp
80102ec9:	89 e5                	mov    %esp,%ebp
80102ecb:	83 ec 14             	sub    $0x14,%esp
80102ece:	8b 45 08             	mov    0x8(%ebp),%eax
80102ed1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ed5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ed9:	89 c2                	mov    %eax,%edx
80102edb:	ec                   	in     (%dx),%al
80102edc:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102edf:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ee3:	c9                   	leave  
80102ee4:	c3                   	ret    

80102ee5 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ee5:	f3 0f 1e fb          	endbr32 
80102ee9:	55                   	push   %ebp
80102eea:	89 e5                	mov    %esp,%ebp
80102eec:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102eef:	6a 64                	push   $0x64
80102ef1:	e8 d2 ff ff ff       	call   80102ec8 <inb>
80102ef6:	83 c4 04             	add    $0x4,%esp
80102ef9:	0f b6 c0             	movzbl %al,%eax
80102efc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f02:	83 e0 01             	and    $0x1,%eax
80102f05:	85 c0                	test   %eax,%eax
80102f07:	75 0a                	jne    80102f13 <kbdgetc+0x2e>
    return -1;
80102f09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f0e:	e9 23 01 00 00       	jmp    80103036 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102f13:	6a 60                	push   $0x60
80102f15:	e8 ae ff ff ff       	call   80102ec8 <inb>
80102f1a:	83 c4 04             	add    $0x4,%esp
80102f1d:	0f b6 c0             	movzbl %al,%eax
80102f20:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102f23:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f2a:	75 17                	jne    80102f43 <kbdgetc+0x5e>
    shift |= E0ESC;
80102f2c:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f31:	83 c8 40             	or     $0x40,%eax
80102f34:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f39:	b8 00 00 00 00       	mov    $0x0,%eax
80102f3e:	e9 f3 00 00 00       	jmp    80103036 <kbdgetc+0x151>
  } else if(data & 0x80){
80102f43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f46:	25 80 00 00 00       	and    $0x80,%eax
80102f4b:	85 c0                	test   %eax,%eax
80102f4d:	74 45                	je     80102f94 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f4f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f54:	83 e0 40             	and    $0x40,%eax
80102f57:	85 c0                	test   %eax,%eax
80102f59:	75 08                	jne    80102f63 <kbdgetc+0x7e>
80102f5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f5e:	83 e0 7f             	and    $0x7f,%eax
80102f61:	eb 03                	jmp    80102f66 <kbdgetc+0x81>
80102f63:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f66:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f69:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f6c:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f71:	0f b6 00             	movzbl (%eax),%eax
80102f74:	83 c8 40             	or     $0x40,%eax
80102f77:	0f b6 c0             	movzbl %al,%eax
80102f7a:	f7 d0                	not    %eax
80102f7c:	89 c2                	mov    %eax,%edx
80102f7e:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f83:	21 d0                	and    %edx,%eax
80102f85:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f8a:	b8 00 00 00 00       	mov    $0x0,%eax
80102f8f:	e9 a2 00 00 00       	jmp    80103036 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f94:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f99:	83 e0 40             	and    $0x40,%eax
80102f9c:	85 c0                	test   %eax,%eax
80102f9e:	74 14                	je     80102fb4 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102fa0:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102fa7:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fac:	83 e0 bf             	and    $0xffffffbf,%eax
80102faf:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102fb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fb7:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102fbc:	0f b6 00             	movzbl (%eax),%eax
80102fbf:	0f b6 d0             	movzbl %al,%edx
80102fc2:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fc7:	09 d0                	or     %edx,%eax
80102fc9:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102fce:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fd1:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102fd6:	0f b6 00             	movzbl (%eax),%eax
80102fd9:	0f b6 d0             	movzbl %al,%edx
80102fdc:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fe1:	31 d0                	xor    %edx,%eax
80102fe3:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fe8:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fed:	83 e0 03             	and    $0x3,%eax
80102ff0:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102ff7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ffa:	01 d0                	add    %edx,%eax
80102ffc:	0f b6 00             	movzbl (%eax),%eax
80102fff:	0f b6 c0             	movzbl %al,%eax
80103002:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103005:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010300a:	83 e0 08             	and    $0x8,%eax
8010300d:	85 c0                	test   %eax,%eax
8010300f:	74 22                	je     80103033 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80103011:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103015:	76 0c                	jbe    80103023 <kbdgetc+0x13e>
80103017:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010301b:	77 06                	ja     80103023 <kbdgetc+0x13e>
      c += 'A' - 'a';
8010301d:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103021:	eb 10                	jmp    80103033 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80103023:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103027:	76 0a                	jbe    80103033 <kbdgetc+0x14e>
80103029:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010302d:	77 04                	ja     80103033 <kbdgetc+0x14e>
      c += 'a' - 'A';
8010302f:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103033:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103036:	c9                   	leave  
80103037:	c3                   	ret    

80103038 <kbdintr>:

void
kbdintr(void)
{
80103038:	f3 0f 1e fb          	endbr32 
8010303c:	55                   	push   %ebp
8010303d:	89 e5                	mov    %esp,%ebp
8010303f:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103042:	83 ec 0c             	sub    $0xc,%esp
80103045:	68 e5 2e 10 80       	push   $0x80102ee5
8010304a:	e8 59 d8 ff ff       	call   801008a8 <consoleintr>
8010304f:	83 c4 10             	add    $0x10,%esp
}
80103052:	90                   	nop
80103053:	c9                   	leave  
80103054:	c3                   	ret    

80103055 <inb>:
{
80103055:	55                   	push   %ebp
80103056:	89 e5                	mov    %esp,%ebp
80103058:	83 ec 14             	sub    $0x14,%esp
8010305b:	8b 45 08             	mov    0x8(%ebp),%eax
8010305e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103062:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103066:	89 c2                	mov    %eax,%edx
80103068:	ec                   	in     (%dx),%al
80103069:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010306c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103070:	c9                   	leave  
80103071:	c3                   	ret    

80103072 <outb>:
{
80103072:	55                   	push   %ebp
80103073:	89 e5                	mov    %esp,%ebp
80103075:	83 ec 08             	sub    $0x8,%esp
80103078:	8b 45 08             	mov    0x8(%ebp),%eax
8010307b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010307e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103082:	89 d0                	mov    %edx,%eax
80103084:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103087:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010308b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010308f:	ee                   	out    %al,(%dx)
}
80103090:	90                   	nop
80103091:	c9                   	leave  
80103092:	c3                   	ret    

80103093 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80103093:	f3 0f 1e fb          	endbr32 
80103097:	55                   	push   %ebp
80103098:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010309a:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010309f:	8b 55 08             	mov    0x8(%ebp),%edx
801030a2:	c1 e2 02             	shl    $0x2,%edx
801030a5:	01 c2                	add    %eax,%edx
801030a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801030aa:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801030ac:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030b1:	83 c0 20             	add    $0x20,%eax
801030b4:	8b 00                	mov    (%eax),%eax
}
801030b6:	90                   	nop
801030b7:	5d                   	pop    %ebp
801030b8:	c3                   	ret    

801030b9 <lapicinit>:

void
lapicinit(void)
{
801030b9:	f3 0f 1e fb          	endbr32 
801030bd:	55                   	push   %ebp
801030be:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801030c0:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030c5:	85 c0                	test   %eax,%eax
801030c7:	0f 84 0c 01 00 00    	je     801031d9 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801030cd:	68 3f 01 00 00       	push   $0x13f
801030d2:	6a 3c                	push   $0x3c
801030d4:	e8 ba ff ff ff       	call   80103093 <lapicw>
801030d9:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030dc:	6a 0b                	push   $0xb
801030de:	68 f8 00 00 00       	push   $0xf8
801030e3:	e8 ab ff ff ff       	call   80103093 <lapicw>
801030e8:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030eb:	68 20 00 02 00       	push   $0x20020
801030f0:	68 c8 00 00 00       	push   $0xc8
801030f5:	e8 99 ff ff ff       	call   80103093 <lapicw>
801030fa:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
801030fd:	68 80 96 98 00       	push   $0x989680
80103102:	68 e0 00 00 00       	push   $0xe0
80103107:	e8 87 ff ff ff       	call   80103093 <lapicw>
8010310c:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010310f:	68 00 00 01 00       	push   $0x10000
80103114:	68 d4 00 00 00       	push   $0xd4
80103119:	e8 75 ff ff ff       	call   80103093 <lapicw>
8010311e:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103121:	68 00 00 01 00       	push   $0x10000
80103126:	68 d8 00 00 00       	push   $0xd8
8010312b:	e8 63 ff ff ff       	call   80103093 <lapicw>
80103130:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103133:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103138:	83 c0 30             	add    $0x30,%eax
8010313b:	8b 00                	mov    (%eax),%eax
8010313d:	c1 e8 10             	shr    $0x10,%eax
80103140:	25 fc 00 00 00       	and    $0xfc,%eax
80103145:	85 c0                	test   %eax,%eax
80103147:	74 12                	je     8010315b <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80103149:	68 00 00 01 00       	push   $0x10000
8010314e:	68 d0 00 00 00       	push   $0xd0
80103153:	e8 3b ff ff ff       	call   80103093 <lapicw>
80103158:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010315b:	6a 33                	push   $0x33
8010315d:	68 dc 00 00 00       	push   $0xdc
80103162:	e8 2c ff ff ff       	call   80103093 <lapicw>
80103167:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010316a:	6a 00                	push   $0x0
8010316c:	68 a0 00 00 00       	push   $0xa0
80103171:	e8 1d ff ff ff       	call   80103093 <lapicw>
80103176:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103179:	6a 00                	push   $0x0
8010317b:	68 a0 00 00 00       	push   $0xa0
80103180:	e8 0e ff ff ff       	call   80103093 <lapicw>
80103185:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103188:	6a 00                	push   $0x0
8010318a:	6a 2c                	push   $0x2c
8010318c:	e8 02 ff ff ff       	call   80103093 <lapicw>
80103191:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103194:	6a 00                	push   $0x0
80103196:	68 c4 00 00 00       	push   $0xc4
8010319b:	e8 f3 fe ff ff       	call   80103093 <lapicw>
801031a0:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801031a3:	68 00 85 08 00       	push   $0x88500
801031a8:	68 c0 00 00 00       	push   $0xc0
801031ad:	e8 e1 fe ff ff       	call   80103093 <lapicw>
801031b2:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801031b5:	90                   	nop
801031b6:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031bb:	05 00 03 00 00       	add    $0x300,%eax
801031c0:	8b 00                	mov    (%eax),%eax
801031c2:	25 00 10 00 00       	and    $0x1000,%eax
801031c7:	85 c0                	test   %eax,%eax
801031c9:	75 eb                	jne    801031b6 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031cb:	6a 00                	push   $0x0
801031cd:	6a 20                	push   $0x20
801031cf:	e8 bf fe ff ff       	call   80103093 <lapicw>
801031d4:	83 c4 08             	add    $0x8,%esp
801031d7:	eb 01                	jmp    801031da <lapicinit+0x121>
    return;
801031d9:	90                   	nop
}
801031da:	c9                   	leave  
801031db:	c3                   	ret    

801031dc <lapicid>:

int
lapicid(void)
{
801031dc:	f3 0f 1e fb          	endbr32 
801031e0:	55                   	push   %ebp
801031e1:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801031e3:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031e8:	85 c0                	test   %eax,%eax
801031ea:	75 07                	jne    801031f3 <lapicid+0x17>
    return 0;
801031ec:	b8 00 00 00 00       	mov    $0x0,%eax
801031f1:	eb 0d                	jmp    80103200 <lapicid+0x24>
  return lapic[ID] >> 24;
801031f3:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031f8:	83 c0 20             	add    $0x20,%eax
801031fb:	8b 00                	mov    (%eax),%eax
801031fd:	c1 e8 18             	shr    $0x18,%eax
}
80103200:	5d                   	pop    %ebp
80103201:	c3                   	ret    

80103202 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103202:	f3 0f 1e fb          	endbr32 
80103206:	55                   	push   %ebp
80103207:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103209:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010320e:	85 c0                	test   %eax,%eax
80103210:	74 0c                	je     8010321e <lapiceoi+0x1c>
    lapicw(EOI, 0);
80103212:	6a 00                	push   $0x0
80103214:	6a 2c                	push   $0x2c
80103216:	e8 78 fe ff ff       	call   80103093 <lapicw>
8010321b:	83 c4 08             	add    $0x8,%esp
}
8010321e:	90                   	nop
8010321f:	c9                   	leave  
80103220:	c3                   	ret    

80103221 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103221:	f3 0f 1e fb          	endbr32 
80103225:	55                   	push   %ebp
80103226:	89 e5                	mov    %esp,%ebp
}
80103228:	90                   	nop
80103229:	5d                   	pop    %ebp
8010322a:	c3                   	ret    

8010322b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010322b:	f3 0f 1e fb          	endbr32 
8010322f:	55                   	push   %ebp
80103230:	89 e5                	mov    %esp,%ebp
80103232:	83 ec 14             	sub    $0x14,%esp
80103235:	8b 45 08             	mov    0x8(%ebp),%eax
80103238:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010323b:	6a 0f                	push   $0xf
8010323d:	6a 70                	push   $0x70
8010323f:	e8 2e fe ff ff       	call   80103072 <outb>
80103244:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103247:	6a 0a                	push   $0xa
80103249:	6a 71                	push   $0x71
8010324b:	e8 22 fe ff ff       	call   80103072 <outb>
80103250:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103253:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010325a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010325d:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103262:	8b 45 0c             	mov    0xc(%ebp),%eax
80103265:	c1 e8 04             	shr    $0x4,%eax
80103268:	89 c2                	mov    %eax,%edx
8010326a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010326d:	83 c0 02             	add    $0x2,%eax
80103270:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103273:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103277:	c1 e0 18             	shl    $0x18,%eax
8010327a:	50                   	push   %eax
8010327b:	68 c4 00 00 00       	push   $0xc4
80103280:	e8 0e fe ff ff       	call   80103093 <lapicw>
80103285:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103288:	68 00 c5 00 00       	push   $0xc500
8010328d:	68 c0 00 00 00       	push   $0xc0
80103292:	e8 fc fd ff ff       	call   80103093 <lapicw>
80103297:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010329a:	68 c8 00 00 00       	push   $0xc8
8010329f:	e8 7d ff ff ff       	call   80103221 <microdelay>
801032a4:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801032a7:	68 00 85 00 00       	push   $0x8500
801032ac:	68 c0 00 00 00       	push   $0xc0
801032b1:	e8 dd fd ff ff       	call   80103093 <lapicw>
801032b6:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801032b9:	6a 64                	push   $0x64
801032bb:	e8 61 ff ff ff       	call   80103221 <microdelay>
801032c0:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032c3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801032ca:	eb 3d                	jmp    80103309 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801032cc:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032d0:	c1 e0 18             	shl    $0x18,%eax
801032d3:	50                   	push   %eax
801032d4:	68 c4 00 00 00       	push   $0xc4
801032d9:	e8 b5 fd ff ff       	call   80103093 <lapicw>
801032de:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801032e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801032e4:	c1 e8 0c             	shr    $0xc,%eax
801032e7:	80 cc 06             	or     $0x6,%ah
801032ea:	50                   	push   %eax
801032eb:	68 c0 00 00 00       	push   $0xc0
801032f0:	e8 9e fd ff ff       	call   80103093 <lapicw>
801032f5:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801032f8:	68 c8 00 00 00       	push   $0xc8
801032fd:	e8 1f ff ff ff       	call   80103221 <microdelay>
80103302:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103305:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103309:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010330d:	7e bd                	jle    801032cc <lapicstartap+0xa1>
  }
}
8010330f:	90                   	nop
80103310:	90                   	nop
80103311:	c9                   	leave  
80103312:	c3                   	ret    

80103313 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80103313:	f3 0f 1e fb          	endbr32 
80103317:	55                   	push   %ebp
80103318:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010331a:	8b 45 08             	mov    0x8(%ebp),%eax
8010331d:	0f b6 c0             	movzbl %al,%eax
80103320:	50                   	push   %eax
80103321:	6a 70                	push   $0x70
80103323:	e8 4a fd ff ff       	call   80103072 <outb>
80103328:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010332b:	68 c8 00 00 00       	push   $0xc8
80103330:	e8 ec fe ff ff       	call   80103221 <microdelay>
80103335:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103338:	6a 71                	push   $0x71
8010333a:	e8 16 fd ff ff       	call   80103055 <inb>
8010333f:	83 c4 04             	add    $0x4,%esp
80103342:	0f b6 c0             	movzbl %al,%eax
}
80103345:	c9                   	leave  
80103346:	c3                   	ret    

80103347 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80103347:	f3 0f 1e fb          	endbr32 
8010334b:	55                   	push   %ebp
8010334c:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010334e:	6a 00                	push   $0x0
80103350:	e8 be ff ff ff       	call   80103313 <cmos_read>
80103355:	83 c4 04             	add    $0x4,%esp
80103358:	8b 55 08             	mov    0x8(%ebp),%edx
8010335b:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010335d:	6a 02                	push   $0x2
8010335f:	e8 af ff ff ff       	call   80103313 <cmos_read>
80103364:	83 c4 04             	add    $0x4,%esp
80103367:	8b 55 08             	mov    0x8(%ebp),%edx
8010336a:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010336d:	6a 04                	push   $0x4
8010336f:	e8 9f ff ff ff       	call   80103313 <cmos_read>
80103374:	83 c4 04             	add    $0x4,%esp
80103377:	8b 55 08             	mov    0x8(%ebp),%edx
8010337a:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010337d:	6a 07                	push   $0x7
8010337f:	e8 8f ff ff ff       	call   80103313 <cmos_read>
80103384:	83 c4 04             	add    $0x4,%esp
80103387:	8b 55 08             	mov    0x8(%ebp),%edx
8010338a:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010338d:	6a 08                	push   $0x8
8010338f:	e8 7f ff ff ff       	call   80103313 <cmos_read>
80103394:	83 c4 04             	add    $0x4,%esp
80103397:	8b 55 08             	mov    0x8(%ebp),%edx
8010339a:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010339d:	6a 09                	push   $0x9
8010339f:	e8 6f ff ff ff       	call   80103313 <cmos_read>
801033a4:	83 c4 04             	add    $0x4,%esp
801033a7:	8b 55 08             	mov    0x8(%ebp),%edx
801033aa:	89 42 14             	mov    %eax,0x14(%edx)
}
801033ad:	90                   	nop
801033ae:	c9                   	leave  
801033af:	c3                   	ret    

801033b0 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801033b0:	f3 0f 1e fb          	endbr32 
801033b4:	55                   	push   %ebp
801033b5:	89 e5                	mov    %esp,%ebp
801033b7:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801033ba:	6a 0b                	push   $0xb
801033bc:	e8 52 ff ff ff       	call   80103313 <cmos_read>
801033c1:	83 c4 04             	add    $0x4,%esp
801033c4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801033c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ca:	83 e0 04             	and    $0x4,%eax
801033cd:	85 c0                	test   %eax,%eax
801033cf:	0f 94 c0             	sete   %al
801033d2:	0f b6 c0             	movzbl %al,%eax
801033d5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801033d8:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033db:	50                   	push   %eax
801033dc:	e8 66 ff ff ff       	call   80103347 <fill_rtcdate>
801033e1:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801033e4:	6a 0a                	push   $0xa
801033e6:	e8 28 ff ff ff       	call   80103313 <cmos_read>
801033eb:	83 c4 04             	add    $0x4,%esp
801033ee:	25 80 00 00 00       	and    $0x80,%eax
801033f3:	85 c0                	test   %eax,%eax
801033f5:	75 27                	jne    8010341e <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
801033f7:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033fa:	50                   	push   %eax
801033fb:	e8 47 ff ff ff       	call   80103347 <fill_rtcdate>
80103400:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103403:	83 ec 04             	sub    $0x4,%esp
80103406:	6a 18                	push   $0x18
80103408:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010340b:	50                   	push   %eax
8010340c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010340f:	50                   	push   %eax
80103410:	e8 0c 22 00 00       	call   80105621 <memcmp>
80103415:	83 c4 10             	add    $0x10,%esp
80103418:	85 c0                	test   %eax,%eax
8010341a:	74 05                	je     80103421 <cmostime+0x71>
8010341c:	eb ba                	jmp    801033d8 <cmostime+0x28>
        continue;
8010341e:	90                   	nop
    fill_rtcdate(&t1);
8010341f:	eb b7                	jmp    801033d8 <cmostime+0x28>
      break;
80103421:	90                   	nop
  }

  // convert
  if(bcd) {
80103422:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103426:	0f 84 b4 00 00 00    	je     801034e0 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010342c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010342f:	c1 e8 04             	shr    $0x4,%eax
80103432:	89 c2                	mov    %eax,%edx
80103434:	89 d0                	mov    %edx,%eax
80103436:	c1 e0 02             	shl    $0x2,%eax
80103439:	01 d0                	add    %edx,%eax
8010343b:	01 c0                	add    %eax,%eax
8010343d:	89 c2                	mov    %eax,%edx
8010343f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103442:	83 e0 0f             	and    $0xf,%eax
80103445:	01 d0                	add    %edx,%eax
80103447:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010344a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010344d:	c1 e8 04             	shr    $0x4,%eax
80103450:	89 c2                	mov    %eax,%edx
80103452:	89 d0                	mov    %edx,%eax
80103454:	c1 e0 02             	shl    $0x2,%eax
80103457:	01 d0                	add    %edx,%eax
80103459:	01 c0                	add    %eax,%eax
8010345b:	89 c2                	mov    %eax,%edx
8010345d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103460:	83 e0 0f             	and    $0xf,%eax
80103463:	01 d0                	add    %edx,%eax
80103465:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103468:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010346b:	c1 e8 04             	shr    $0x4,%eax
8010346e:	89 c2                	mov    %eax,%edx
80103470:	89 d0                	mov    %edx,%eax
80103472:	c1 e0 02             	shl    $0x2,%eax
80103475:	01 d0                	add    %edx,%eax
80103477:	01 c0                	add    %eax,%eax
80103479:	89 c2                	mov    %eax,%edx
8010347b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010347e:	83 e0 0f             	and    $0xf,%eax
80103481:	01 d0                	add    %edx,%eax
80103483:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103486:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103489:	c1 e8 04             	shr    $0x4,%eax
8010348c:	89 c2                	mov    %eax,%edx
8010348e:	89 d0                	mov    %edx,%eax
80103490:	c1 e0 02             	shl    $0x2,%eax
80103493:	01 d0                	add    %edx,%eax
80103495:	01 c0                	add    %eax,%eax
80103497:	89 c2                	mov    %eax,%edx
80103499:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010349c:	83 e0 0f             	and    $0xf,%eax
8010349f:	01 d0                	add    %edx,%eax
801034a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801034a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034a7:	c1 e8 04             	shr    $0x4,%eax
801034aa:	89 c2                	mov    %eax,%edx
801034ac:	89 d0                	mov    %edx,%eax
801034ae:	c1 e0 02             	shl    $0x2,%eax
801034b1:	01 d0                	add    %edx,%eax
801034b3:	01 c0                	add    %eax,%eax
801034b5:	89 c2                	mov    %eax,%edx
801034b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034ba:	83 e0 0f             	and    $0xf,%eax
801034bd:	01 d0                	add    %edx,%eax
801034bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801034c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c5:	c1 e8 04             	shr    $0x4,%eax
801034c8:	89 c2                	mov    %eax,%edx
801034ca:	89 d0                	mov    %edx,%eax
801034cc:	c1 e0 02             	shl    $0x2,%eax
801034cf:	01 d0                	add    %edx,%eax
801034d1:	01 c0                	add    %eax,%eax
801034d3:	89 c2                	mov    %eax,%edx
801034d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d8:	83 e0 0f             	and    $0xf,%eax
801034db:	01 d0                	add    %edx,%eax
801034dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801034e0:	8b 45 08             	mov    0x8(%ebp),%eax
801034e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
801034e6:	89 10                	mov    %edx,(%eax)
801034e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
801034eb:	89 50 04             	mov    %edx,0x4(%eax)
801034ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
801034f1:	89 50 08             	mov    %edx,0x8(%eax)
801034f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034f7:	89 50 0c             	mov    %edx,0xc(%eax)
801034fa:	8b 55 e8             	mov    -0x18(%ebp),%edx
801034fd:	89 50 10             	mov    %edx,0x10(%eax)
80103500:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103503:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103506:	8b 45 08             	mov    0x8(%ebp),%eax
80103509:	8b 40 14             	mov    0x14(%eax),%eax
8010350c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103512:	8b 45 08             	mov    0x8(%ebp),%eax
80103515:	89 50 14             	mov    %edx,0x14(%eax)
}
80103518:	90                   	nop
80103519:	c9                   	leave  
8010351a:	c3                   	ret    

8010351b <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010351b:	f3 0f 1e fb          	endbr32 
8010351f:	55                   	push   %ebp
80103520:	89 e5                	mov    %esp,%ebp
80103522:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103525:	83 ec 08             	sub    $0x8,%esp
80103528:	68 44 95 10 80       	push   $0x80109544
8010352d:	68 20 47 11 80       	push   $0x80114720
80103532:	e8 ba 1d 00 00       	call   801052f1 <initlock>
80103537:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010353a:	83 ec 08             	sub    $0x8,%esp
8010353d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103540:	50                   	push   %eax
80103541:	ff 75 08             	pushl  0x8(%ebp)
80103544:	e8 d3 df ff ff       	call   8010151c <readsb>
80103549:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010354c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010354f:	a3 54 47 11 80       	mov    %eax,0x80114754
  log.size = sb.nlog;
80103554:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103557:	a3 58 47 11 80       	mov    %eax,0x80114758
  log.dev = dev;
8010355c:	8b 45 08             	mov    0x8(%ebp),%eax
8010355f:	a3 64 47 11 80       	mov    %eax,0x80114764
  recover_from_log();
80103564:	e8 bf 01 00 00       	call   80103728 <recover_from_log>
}
80103569:	90                   	nop
8010356a:	c9                   	leave  
8010356b:	c3                   	ret    

8010356c <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010356c:	f3 0f 1e fb          	endbr32 
80103570:	55                   	push   %ebp
80103571:	89 e5                	mov    %esp,%ebp
80103573:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103576:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010357d:	e9 95 00 00 00       	jmp    80103617 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103582:	8b 15 54 47 11 80    	mov    0x80114754,%edx
80103588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010358b:	01 d0                	add    %edx,%eax
8010358d:	83 c0 01             	add    $0x1,%eax
80103590:	89 c2                	mov    %eax,%edx
80103592:	a1 64 47 11 80       	mov    0x80114764,%eax
80103597:	83 ec 08             	sub    $0x8,%esp
8010359a:	52                   	push   %edx
8010359b:	50                   	push   %eax
8010359c:	e8 36 cc ff ff       	call   801001d7 <bread>
801035a1:	83 c4 10             	add    $0x10,%esp
801035a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801035a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035aa:	83 c0 10             	add    $0x10,%eax
801035ad:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801035b4:	89 c2                	mov    %eax,%edx
801035b6:	a1 64 47 11 80       	mov    0x80114764,%eax
801035bb:	83 ec 08             	sub    $0x8,%esp
801035be:	52                   	push   %edx
801035bf:	50                   	push   %eax
801035c0:	e8 12 cc ff ff       	call   801001d7 <bread>
801035c5:	83 c4 10             	add    $0x10,%esp
801035c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801035cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ce:	8d 50 5c             	lea    0x5c(%eax),%edx
801035d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035d4:	83 c0 5c             	add    $0x5c,%eax
801035d7:	83 ec 04             	sub    $0x4,%esp
801035da:	68 00 02 00 00       	push   $0x200
801035df:	52                   	push   %edx
801035e0:	50                   	push   %eax
801035e1:	e8 97 20 00 00       	call   8010567d <memmove>
801035e6:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801035e9:	83 ec 0c             	sub    $0xc,%esp
801035ec:	ff 75 ec             	pushl  -0x14(%ebp)
801035ef:	e8 20 cc ff ff       	call   80100214 <bwrite>
801035f4:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801035f7:	83 ec 0c             	sub    $0xc,%esp
801035fa:	ff 75 f0             	pushl  -0x10(%ebp)
801035fd:	e8 5f cc ff ff       	call   80100261 <brelse>
80103602:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103605:	83 ec 0c             	sub    $0xc,%esp
80103608:	ff 75 ec             	pushl  -0x14(%ebp)
8010360b:	e8 51 cc ff ff       	call   80100261 <brelse>
80103610:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103613:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103617:	a1 68 47 11 80       	mov    0x80114768,%eax
8010361c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010361f:	0f 8c 5d ff ff ff    	jl     80103582 <install_trans+0x16>
  }
}
80103625:	90                   	nop
80103626:	90                   	nop
80103627:	c9                   	leave  
80103628:	c3                   	ret    

80103629 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103629:	f3 0f 1e fb          	endbr32 
8010362d:	55                   	push   %ebp
8010362e:	89 e5                	mov    %esp,%ebp
80103630:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103633:	a1 54 47 11 80       	mov    0x80114754,%eax
80103638:	89 c2                	mov    %eax,%edx
8010363a:	a1 64 47 11 80       	mov    0x80114764,%eax
8010363f:	83 ec 08             	sub    $0x8,%esp
80103642:	52                   	push   %edx
80103643:	50                   	push   %eax
80103644:	e8 8e cb ff ff       	call   801001d7 <bread>
80103649:	83 c4 10             	add    $0x10,%esp
8010364c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010364f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103652:	83 c0 5c             	add    $0x5c,%eax
80103655:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103658:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010365b:	8b 00                	mov    (%eax),%eax
8010365d:	a3 68 47 11 80       	mov    %eax,0x80114768
  for (i = 0; i < log.lh.n; i++) {
80103662:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103669:	eb 1b                	jmp    80103686 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010366b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010366e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103671:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103675:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103678:	83 c2 10             	add    $0x10,%edx
8010367b:	89 04 95 2c 47 11 80 	mov    %eax,-0x7feeb8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103682:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103686:	a1 68 47 11 80       	mov    0x80114768,%eax
8010368b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010368e:	7c db                	jl     8010366b <read_head+0x42>
  }
  brelse(buf);
80103690:	83 ec 0c             	sub    $0xc,%esp
80103693:	ff 75 f0             	pushl  -0x10(%ebp)
80103696:	e8 c6 cb ff ff       	call   80100261 <brelse>
8010369b:	83 c4 10             	add    $0x10,%esp
}
8010369e:	90                   	nop
8010369f:	c9                   	leave  
801036a0:	c3                   	ret    

801036a1 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801036a1:	f3 0f 1e fb          	endbr32 
801036a5:	55                   	push   %ebp
801036a6:	89 e5                	mov    %esp,%ebp
801036a8:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801036ab:	a1 54 47 11 80       	mov    0x80114754,%eax
801036b0:	89 c2                	mov    %eax,%edx
801036b2:	a1 64 47 11 80       	mov    0x80114764,%eax
801036b7:	83 ec 08             	sub    $0x8,%esp
801036ba:	52                   	push   %edx
801036bb:	50                   	push   %eax
801036bc:	e8 16 cb ff ff       	call   801001d7 <bread>
801036c1:	83 c4 10             	add    $0x10,%esp
801036c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801036c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036ca:	83 c0 5c             	add    $0x5c,%eax
801036cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801036d0:	8b 15 68 47 11 80    	mov    0x80114768,%edx
801036d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036d9:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801036db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036e2:	eb 1b                	jmp    801036ff <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
801036e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036e7:	83 c0 10             	add    $0x10,%eax
801036ea:	8b 0c 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%ecx
801036f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036f7:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801036fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036ff:	a1 68 47 11 80       	mov    0x80114768,%eax
80103704:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103707:	7c db                	jl     801036e4 <write_head+0x43>
  }
  bwrite(buf);
80103709:	83 ec 0c             	sub    $0xc,%esp
8010370c:	ff 75 f0             	pushl  -0x10(%ebp)
8010370f:	e8 00 cb ff ff       	call   80100214 <bwrite>
80103714:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103717:	83 ec 0c             	sub    $0xc,%esp
8010371a:	ff 75 f0             	pushl  -0x10(%ebp)
8010371d:	e8 3f cb ff ff       	call   80100261 <brelse>
80103722:	83 c4 10             	add    $0x10,%esp
}
80103725:	90                   	nop
80103726:	c9                   	leave  
80103727:	c3                   	ret    

80103728 <recover_from_log>:

static void
recover_from_log(void)
{
80103728:	f3 0f 1e fb          	endbr32 
8010372c:	55                   	push   %ebp
8010372d:	89 e5                	mov    %esp,%ebp
8010372f:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103732:	e8 f2 fe ff ff       	call   80103629 <read_head>
  install_trans(); // if committed, copy from log to disk
80103737:	e8 30 fe ff ff       	call   8010356c <install_trans>
  log.lh.n = 0;
8010373c:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
80103743:	00 00 00 
  write_head(); // clear the log
80103746:	e8 56 ff ff ff       	call   801036a1 <write_head>
}
8010374b:	90                   	nop
8010374c:	c9                   	leave  
8010374d:	c3                   	ret    

8010374e <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010374e:	f3 0f 1e fb          	endbr32 
80103752:	55                   	push   %ebp
80103753:	89 e5                	mov    %esp,%ebp
80103755:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103758:	83 ec 0c             	sub    $0xc,%esp
8010375b:	68 20 47 11 80       	push   $0x80114720
80103760:	e8 b2 1b 00 00       	call   80105317 <acquire>
80103765:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103768:	a1 60 47 11 80       	mov    0x80114760,%eax
8010376d:	85 c0                	test   %eax,%eax
8010376f:	74 17                	je     80103788 <begin_op+0x3a>
      sleep(&log, &log.lock);
80103771:	83 ec 08             	sub    $0x8,%esp
80103774:	68 20 47 11 80       	push   $0x80114720
80103779:	68 20 47 11 80       	push   $0x80114720
8010377e:	e8 22 17 00 00       	call   80104ea5 <sleep>
80103783:	83 c4 10             	add    $0x10,%esp
80103786:	eb e0                	jmp    80103768 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103788:	8b 0d 68 47 11 80    	mov    0x80114768,%ecx
8010378e:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103793:	8d 50 01             	lea    0x1(%eax),%edx
80103796:	89 d0                	mov    %edx,%eax
80103798:	c1 e0 02             	shl    $0x2,%eax
8010379b:	01 d0                	add    %edx,%eax
8010379d:	01 c0                	add    %eax,%eax
8010379f:	01 c8                	add    %ecx,%eax
801037a1:	83 f8 1e             	cmp    $0x1e,%eax
801037a4:	7e 17                	jle    801037bd <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801037a6:	83 ec 08             	sub    $0x8,%esp
801037a9:	68 20 47 11 80       	push   $0x80114720
801037ae:	68 20 47 11 80       	push   $0x80114720
801037b3:	e8 ed 16 00 00       	call   80104ea5 <sleep>
801037b8:	83 c4 10             	add    $0x10,%esp
801037bb:	eb ab                	jmp    80103768 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801037bd:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037c2:	83 c0 01             	add    $0x1,%eax
801037c5:	a3 5c 47 11 80       	mov    %eax,0x8011475c
      release(&log.lock);
801037ca:	83 ec 0c             	sub    $0xc,%esp
801037cd:	68 20 47 11 80       	push   $0x80114720
801037d2:	e8 b2 1b 00 00       	call   80105389 <release>
801037d7:	83 c4 10             	add    $0x10,%esp
      break;
801037da:	90                   	nop
    }
  }
}
801037db:	90                   	nop
801037dc:	c9                   	leave  
801037dd:	c3                   	ret    

801037de <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801037de:	f3 0f 1e fb          	endbr32 
801037e2:	55                   	push   %ebp
801037e3:	89 e5                	mov    %esp,%ebp
801037e5:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801037e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801037ef:	83 ec 0c             	sub    $0xc,%esp
801037f2:	68 20 47 11 80       	push   $0x80114720
801037f7:	e8 1b 1b 00 00       	call   80105317 <acquire>
801037fc:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801037ff:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103804:	83 e8 01             	sub    $0x1,%eax
80103807:	a3 5c 47 11 80       	mov    %eax,0x8011475c
  if(log.committing)
8010380c:	a1 60 47 11 80       	mov    0x80114760,%eax
80103811:	85 c0                	test   %eax,%eax
80103813:	74 0d                	je     80103822 <end_op+0x44>
    panic("log.committing");
80103815:	83 ec 0c             	sub    $0xc,%esp
80103818:	68 48 95 10 80       	push   $0x80109548
8010381d:	e8 e6 cd ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
80103822:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103827:	85 c0                	test   %eax,%eax
80103829:	75 13                	jne    8010383e <end_op+0x60>
    do_commit = 1;
8010382b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103832:	c7 05 60 47 11 80 01 	movl   $0x1,0x80114760
80103839:	00 00 00 
8010383c:	eb 10                	jmp    8010384e <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010383e:	83 ec 0c             	sub    $0xc,%esp
80103841:	68 20 47 11 80       	push   $0x80114720
80103846:	e8 4c 17 00 00       	call   80104f97 <wakeup>
8010384b:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010384e:	83 ec 0c             	sub    $0xc,%esp
80103851:	68 20 47 11 80       	push   $0x80114720
80103856:	e8 2e 1b 00 00       	call   80105389 <release>
8010385b:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010385e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103862:	74 3f                	je     801038a3 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103864:	e8 fa 00 00 00       	call   80103963 <commit>
    acquire(&log.lock);
80103869:	83 ec 0c             	sub    $0xc,%esp
8010386c:	68 20 47 11 80       	push   $0x80114720
80103871:	e8 a1 1a 00 00       	call   80105317 <acquire>
80103876:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103879:	c7 05 60 47 11 80 00 	movl   $0x0,0x80114760
80103880:	00 00 00 
    wakeup(&log);
80103883:	83 ec 0c             	sub    $0xc,%esp
80103886:	68 20 47 11 80       	push   $0x80114720
8010388b:	e8 07 17 00 00       	call   80104f97 <wakeup>
80103890:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103893:	83 ec 0c             	sub    $0xc,%esp
80103896:	68 20 47 11 80       	push   $0x80114720
8010389b:	e8 e9 1a 00 00       	call   80105389 <release>
801038a0:	83 c4 10             	add    $0x10,%esp
  }
}
801038a3:	90                   	nop
801038a4:	c9                   	leave  
801038a5:	c3                   	ret    

801038a6 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801038a6:	f3 0f 1e fb          	endbr32 
801038aa:	55                   	push   %ebp
801038ab:	89 e5                	mov    %esp,%ebp
801038ad:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801038b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038b7:	e9 95 00 00 00       	jmp    80103951 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801038bc:	8b 15 54 47 11 80    	mov    0x80114754,%edx
801038c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038c5:	01 d0                	add    %edx,%eax
801038c7:	83 c0 01             	add    $0x1,%eax
801038ca:	89 c2                	mov    %eax,%edx
801038cc:	a1 64 47 11 80       	mov    0x80114764,%eax
801038d1:	83 ec 08             	sub    $0x8,%esp
801038d4:	52                   	push   %edx
801038d5:	50                   	push   %eax
801038d6:	e8 fc c8 ff ff       	call   801001d7 <bread>
801038db:	83 c4 10             	add    $0x10,%esp
801038de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801038e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038e4:	83 c0 10             	add    $0x10,%eax
801038e7:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801038ee:	89 c2                	mov    %eax,%edx
801038f0:	a1 64 47 11 80       	mov    0x80114764,%eax
801038f5:	83 ec 08             	sub    $0x8,%esp
801038f8:	52                   	push   %edx
801038f9:	50                   	push   %eax
801038fa:	e8 d8 c8 ff ff       	call   801001d7 <bread>
801038ff:	83 c4 10             	add    $0x10,%esp
80103902:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103905:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103908:	8d 50 5c             	lea    0x5c(%eax),%edx
8010390b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390e:	83 c0 5c             	add    $0x5c,%eax
80103911:	83 ec 04             	sub    $0x4,%esp
80103914:	68 00 02 00 00       	push   $0x200
80103919:	52                   	push   %edx
8010391a:	50                   	push   %eax
8010391b:	e8 5d 1d 00 00       	call   8010567d <memmove>
80103920:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103923:	83 ec 0c             	sub    $0xc,%esp
80103926:	ff 75 f0             	pushl  -0x10(%ebp)
80103929:	e8 e6 c8 ff ff       	call   80100214 <bwrite>
8010392e:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103931:	83 ec 0c             	sub    $0xc,%esp
80103934:	ff 75 ec             	pushl  -0x14(%ebp)
80103937:	e8 25 c9 ff ff       	call   80100261 <brelse>
8010393c:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010393f:	83 ec 0c             	sub    $0xc,%esp
80103942:	ff 75 f0             	pushl  -0x10(%ebp)
80103945:	e8 17 c9 ff ff       	call   80100261 <brelse>
8010394a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010394d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103951:	a1 68 47 11 80       	mov    0x80114768,%eax
80103956:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103959:	0f 8c 5d ff ff ff    	jl     801038bc <write_log+0x16>
  }
}
8010395f:	90                   	nop
80103960:	90                   	nop
80103961:	c9                   	leave  
80103962:	c3                   	ret    

80103963 <commit>:

static void
commit()
{
80103963:	f3 0f 1e fb          	endbr32 
80103967:	55                   	push   %ebp
80103968:	89 e5                	mov    %esp,%ebp
8010396a:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010396d:	a1 68 47 11 80       	mov    0x80114768,%eax
80103972:	85 c0                	test   %eax,%eax
80103974:	7e 1e                	jle    80103994 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103976:	e8 2b ff ff ff       	call   801038a6 <write_log>
    write_head();    // Write header to disk -- the real commit
8010397b:	e8 21 fd ff ff       	call   801036a1 <write_head>
    install_trans(); // Now install writes to home locations
80103980:	e8 e7 fb ff ff       	call   8010356c <install_trans>
    log.lh.n = 0;
80103985:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
8010398c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010398f:	e8 0d fd ff ff       	call   801036a1 <write_head>
  }
}
80103994:	90                   	nop
80103995:	c9                   	leave  
80103996:	c3                   	ret    

80103997 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103997:	f3 0f 1e fb          	endbr32 
8010399b:	55                   	push   %ebp
8010399c:	89 e5                	mov    %esp,%ebp
8010399e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801039a1:	a1 68 47 11 80       	mov    0x80114768,%eax
801039a6:	83 f8 1d             	cmp    $0x1d,%eax
801039a9:	7f 12                	jg     801039bd <log_write+0x26>
801039ab:	a1 68 47 11 80       	mov    0x80114768,%eax
801039b0:	8b 15 58 47 11 80    	mov    0x80114758,%edx
801039b6:	83 ea 01             	sub    $0x1,%edx
801039b9:	39 d0                	cmp    %edx,%eax
801039bb:	7c 0d                	jl     801039ca <log_write+0x33>
    panic("too big a transaction");
801039bd:	83 ec 0c             	sub    $0xc,%esp
801039c0:	68 57 95 10 80       	push   $0x80109557
801039c5:	e8 3e cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
801039ca:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801039cf:	85 c0                	test   %eax,%eax
801039d1:	7f 0d                	jg     801039e0 <log_write+0x49>
    panic("log_write outside of trans");
801039d3:	83 ec 0c             	sub    $0xc,%esp
801039d6:	68 6d 95 10 80       	push   $0x8010956d
801039db:	e8 28 cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
801039e0:	83 ec 0c             	sub    $0xc,%esp
801039e3:	68 20 47 11 80       	push   $0x80114720
801039e8:	e8 2a 19 00 00       	call   80105317 <acquire>
801039ed:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801039f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039f7:	eb 1d                	jmp    80103a16 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801039f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fc:	83 c0 10             	add    $0x10,%eax
801039ff:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103a06:	89 c2                	mov    %eax,%edx
80103a08:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0b:	8b 40 08             	mov    0x8(%eax),%eax
80103a0e:	39 c2                	cmp    %eax,%edx
80103a10:	74 10                	je     80103a22 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103a12:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a16:	a1 68 47 11 80       	mov    0x80114768,%eax
80103a1b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1e:	7c d9                	jl     801039f9 <log_write+0x62>
80103a20:	eb 01                	jmp    80103a23 <log_write+0x8c>
      break;
80103a22:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103a23:	8b 45 08             	mov    0x8(%ebp),%eax
80103a26:	8b 40 08             	mov    0x8(%eax),%eax
80103a29:	89 c2                	mov    %eax,%edx
80103a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2e:	83 c0 10             	add    $0x10,%eax
80103a31:	89 14 85 2c 47 11 80 	mov    %edx,-0x7feeb8d4(,%eax,4)
  if (i == log.lh.n)
80103a38:	a1 68 47 11 80       	mov    0x80114768,%eax
80103a3d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a40:	75 0d                	jne    80103a4f <log_write+0xb8>
    log.lh.n++;
80103a42:	a1 68 47 11 80       	mov    0x80114768,%eax
80103a47:	83 c0 01             	add    $0x1,%eax
80103a4a:	a3 68 47 11 80       	mov    %eax,0x80114768
  b->flags |= B_DIRTY; // prevent eviction
80103a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a52:	8b 00                	mov    (%eax),%eax
80103a54:	83 c8 04             	or     $0x4,%eax
80103a57:	89 c2                	mov    %eax,%edx
80103a59:	8b 45 08             	mov    0x8(%ebp),%eax
80103a5c:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103a5e:	83 ec 0c             	sub    $0xc,%esp
80103a61:	68 20 47 11 80       	push   $0x80114720
80103a66:	e8 1e 19 00 00       	call   80105389 <release>
80103a6b:	83 c4 10             	add    $0x10,%esp
}
80103a6e:	90                   	nop
80103a6f:	c9                   	leave  
80103a70:	c3                   	ret    

80103a71 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a71:	55                   	push   %ebp
80103a72:	89 e5                	mov    %esp,%ebp
80103a74:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a77:	8b 55 08             	mov    0x8(%ebp),%edx
80103a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a80:	f0 87 02             	lock xchg %eax,(%edx)
80103a83:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a86:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a89:	c9                   	leave  
80103a8a:	c3                   	ret    

80103a8b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a8b:	f3 0f 1e fb          	endbr32 
80103a8f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103a93:	83 e4 f0             	and    $0xfffffff0,%esp
80103a96:	ff 71 fc             	pushl  -0x4(%ecx)
80103a99:	55                   	push   %ebp
80103a9a:	89 e5                	mov    %esp,%ebp
80103a9c:	51                   	push   %ecx
80103a9d:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103aa0:	83 ec 08             	sub    $0x8,%esp
80103aa3:	68 00 00 40 80       	push   $0x80400000
80103aa8:	68 48 7f 11 80       	push   $0x80117f48
80103aad:	e8 52 f2 ff ff       	call   80102d04 <kinit1>
80103ab2:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103ab5:	e8 df 46 00 00       	call   80108199 <kvmalloc>
  mpinit();        // detect other processors
80103aba:	e8 d9 03 00 00       	call   80103e98 <mpinit>
  lapicinit();     // interrupt controller
80103abf:	e8 f5 f5 ff ff       	call   801030b9 <lapicinit>
  seginit();       // segment descriptors
80103ac4:	e8 88 41 00 00       	call   80107c51 <seginit>
  picinit();       // disable pic
80103ac9:	e8 35 05 00 00       	call   80104003 <picinit>
  ioapicinit();    // another interrupt controller
80103ace:	e8 44 f1 ff ff       	call   80102c17 <ioapicinit>
  consoleinit();   // console hardware
80103ad3:	e8 09 d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103ad8:	e8 fd 34 00 00       	call   80106fda <uartinit>
  pinit();         // process table
80103add:	e8 6e 09 00 00       	call   80104450 <pinit>
  tvinit();        // trap vectors
80103ae2:	e8 8b 30 00 00       	call   80106b72 <tvinit>
  binit();         // buffer cache
80103ae7:	e8 48 c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103aec:	e8 00 d6 ff ff       	call   801010f1 <fileinit>
  ideinit();       // disk 
80103af1:	e8 e0 ec ff ff       	call   801027d6 <ideinit>
  startothers();   // start other processors
80103af6:	e8 88 00 00 00       	call   80103b83 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103afb:	83 ec 08             	sub    $0x8,%esp
80103afe:	68 00 00 00 8e       	push   $0x8e000000
80103b03:	68 00 00 40 80       	push   $0x80400000
80103b08:	e8 34 f2 ff ff       	call   80102d41 <kinit2>
80103b0d:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103b10:	e8 34 0b 00 00       	call   80104649 <userinit>
  mpmain();        // finish this processor's setup
80103b15:	e8 1e 00 00 00       	call   80103b38 <mpmain>

80103b1a <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103b1a:	f3 0f 1e fb          	endbr32 
80103b1e:	55                   	push   %ebp
80103b1f:	89 e5                	mov    %esp,%ebp
80103b21:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103b24:	e8 8c 46 00 00       	call   801081b5 <switchkvm>
  seginit();
80103b29:	e8 23 41 00 00       	call   80107c51 <seginit>
  lapicinit();
80103b2e:	e8 86 f5 ff ff       	call   801030b9 <lapicinit>
  mpmain();
80103b33:	e8 00 00 00 00       	call   80103b38 <mpmain>

80103b38 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103b38:	f3 0f 1e fb          	endbr32 
80103b3c:	55                   	push   %ebp
80103b3d:	89 e5                	mov    %esp,%ebp
80103b3f:	53                   	push   %ebx
80103b40:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103b43:	e8 2a 09 00 00       	call   80104472 <cpuid>
80103b48:	89 c3                	mov    %eax,%ebx
80103b4a:	e8 23 09 00 00       	call   80104472 <cpuid>
80103b4f:	83 ec 04             	sub    $0x4,%esp
80103b52:	53                   	push   %ebx
80103b53:	50                   	push   %eax
80103b54:	68 88 95 10 80       	push   $0x80109588
80103b59:	e8 ba c8 ff ff       	call   80100418 <cprintf>
80103b5e:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103b61:	e8 86 31 00 00       	call   80106cec <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b66:	e8 26 09 00 00       	call   80104491 <mycpu>
80103b6b:	05 a0 00 00 00       	add    $0xa0,%eax
80103b70:	83 ec 08             	sub    $0x8,%esp
80103b73:	6a 01                	push   $0x1
80103b75:	50                   	push   %eax
80103b76:	e8 f6 fe ff ff       	call   80103a71 <xchg>
80103b7b:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b7e:	e8 1e 11 00 00       	call   80104ca1 <scheduler>

80103b83 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b83:	f3 0f 1e fb          	endbr32 
80103b87:	55                   	push   %ebp
80103b88:	89 e5                	mov    %esp,%ebp
80103b8a:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b8d:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b94:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b99:	83 ec 04             	sub    $0x4,%esp
80103b9c:	50                   	push   %eax
80103b9d:	68 0c c5 10 80       	push   $0x8010c50c
80103ba2:	ff 75 f0             	pushl  -0x10(%ebp)
80103ba5:	e8 d3 1a 00 00       	call   8010567d <memmove>
80103baa:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103bad:	c7 45 f4 20 48 11 80 	movl   $0x80114820,-0xc(%ebp)
80103bb4:	eb 79                	jmp    80103c2f <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103bb6:	e8 d6 08 00 00       	call   80104491 <mycpu>
80103bbb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bbe:	74 67                	je     80103c27 <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103bc0:	e8 84 f2 ff ff       	call   80102e49 <kalloc>
80103bc5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcb:	83 e8 04             	sub    $0x4,%eax
80103bce:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103bd1:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103bd7:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bdc:	83 e8 08             	sub    $0x8,%eax
80103bdf:	c7 00 1a 3b 10 80    	movl   $0x80103b1a,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103be5:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103bea:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf3:	83 e8 0c             	sub    $0xc,%eax
80103bf6:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfb:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c04:	0f b6 00             	movzbl (%eax),%eax
80103c07:	0f b6 c0             	movzbl %al,%eax
80103c0a:	83 ec 08             	sub    $0x8,%esp
80103c0d:	52                   	push   %edx
80103c0e:	50                   	push   %eax
80103c0f:	e8 17 f6 ff ff       	call   8010322b <lapicstartap>
80103c14:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103c17:	90                   	nop
80103c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103c21:	85 c0                	test   %eax,%eax
80103c23:	74 f3                	je     80103c18 <startothers+0x95>
80103c25:	eb 01                	jmp    80103c28 <startothers+0xa5>
      continue;
80103c27:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103c28:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103c2f:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103c34:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103c3a:	05 20 48 11 80       	add    $0x80114820,%eax
80103c3f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103c42:	0f 82 6e ff ff ff    	jb     80103bb6 <startothers+0x33>
      ;
  }
}
80103c48:	90                   	nop
80103c49:	90                   	nop
80103c4a:	c9                   	leave  
80103c4b:	c3                   	ret    

80103c4c <inb>:
{
80103c4c:	55                   	push   %ebp
80103c4d:	89 e5                	mov    %esp,%ebp
80103c4f:	83 ec 14             	sub    $0x14,%esp
80103c52:	8b 45 08             	mov    0x8(%ebp),%eax
80103c55:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103c59:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103c5d:	89 c2                	mov    %eax,%edx
80103c5f:	ec                   	in     (%dx),%al
80103c60:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c63:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103c67:	c9                   	leave  
80103c68:	c3                   	ret    

80103c69 <outb>:
{
80103c69:	55                   	push   %ebp
80103c6a:	89 e5                	mov    %esp,%ebp
80103c6c:	83 ec 08             	sub    $0x8,%esp
80103c6f:	8b 45 08             	mov    0x8(%ebp),%eax
80103c72:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c75:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c79:	89 d0                	mov    %edx,%eax
80103c7b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c7e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c82:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c86:	ee                   	out    %al,(%dx)
}
80103c87:	90                   	nop
80103c88:	c9                   	leave  
80103c89:	c3                   	ret    

80103c8a <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c8a:	f3 0f 1e fb          	endbr32 
80103c8e:	55                   	push   %ebp
80103c8f:	89 e5                	mov    %esp,%ebp
80103c91:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c94:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c9b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103ca2:	eb 15                	jmp    80103cb9 <sum+0x2f>
    sum += addr[i];
80103ca4:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80103caa:	01 d0                	add    %edx,%eax
80103cac:	0f b6 00             	movzbl (%eax),%eax
80103caf:	0f b6 c0             	movzbl %al,%eax
80103cb2:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103cb5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103cb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103cbc:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103cbf:	7c e3                	jl     80103ca4 <sum+0x1a>
  return sum;
80103cc1:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103cc4:	c9                   	leave  
80103cc5:	c3                   	ret    

80103cc6 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103cc6:	f3 0f 1e fb          	endbr32 
80103cca:	55                   	push   %ebp
80103ccb:	89 e5                	mov    %esp,%ebp
80103ccd:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd3:	05 00 00 00 80       	add    $0x80000000,%eax
80103cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103cdb:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce1:	01 d0                	add    %edx,%eax
80103ce3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cec:	eb 36                	jmp    80103d24 <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103cee:	83 ec 04             	sub    $0x4,%esp
80103cf1:	6a 04                	push   $0x4
80103cf3:	68 9c 95 10 80       	push   $0x8010959c
80103cf8:	ff 75 f4             	pushl  -0xc(%ebp)
80103cfb:	e8 21 19 00 00       	call   80105621 <memcmp>
80103d00:	83 c4 10             	add    $0x10,%esp
80103d03:	85 c0                	test   %eax,%eax
80103d05:	75 19                	jne    80103d20 <mpsearch1+0x5a>
80103d07:	83 ec 08             	sub    $0x8,%esp
80103d0a:	6a 10                	push   $0x10
80103d0c:	ff 75 f4             	pushl  -0xc(%ebp)
80103d0f:	e8 76 ff ff ff       	call   80103c8a <sum>
80103d14:	83 c4 10             	add    $0x10,%esp
80103d17:	84 c0                	test   %al,%al
80103d19:	75 05                	jne    80103d20 <mpsearch1+0x5a>
      return (struct mp*)p;
80103d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1e:	eb 11                	jmp    80103d31 <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103d20:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d27:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d2a:	72 c2                	jb     80103cee <mpsearch1+0x28>
  return 0;
80103d2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d31:	c9                   	leave  
80103d32:	c3                   	ret    

80103d33 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103d33:	f3 0f 1e fb          	endbr32 
80103d37:	55                   	push   %ebp
80103d38:	89 e5                	mov    %esp,%ebp
80103d3a:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103d3d:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d47:	83 c0 0f             	add    $0xf,%eax
80103d4a:	0f b6 00             	movzbl (%eax),%eax
80103d4d:	0f b6 c0             	movzbl %al,%eax
80103d50:	c1 e0 08             	shl    $0x8,%eax
80103d53:	89 c2                	mov    %eax,%edx
80103d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d58:	83 c0 0e             	add    $0xe,%eax
80103d5b:	0f b6 00             	movzbl (%eax),%eax
80103d5e:	0f b6 c0             	movzbl %al,%eax
80103d61:	09 d0                	or     %edx,%eax
80103d63:	c1 e0 04             	shl    $0x4,%eax
80103d66:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d69:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d6d:	74 21                	je     80103d90 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103d6f:	83 ec 08             	sub    $0x8,%esp
80103d72:	68 00 04 00 00       	push   $0x400
80103d77:	ff 75 f0             	pushl  -0x10(%ebp)
80103d7a:	e8 47 ff ff ff       	call   80103cc6 <mpsearch1>
80103d7f:	83 c4 10             	add    $0x10,%esp
80103d82:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d85:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d89:	74 51                	je     80103ddc <mpsearch+0xa9>
      return mp;
80103d8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d8e:	eb 61                	jmp    80103df1 <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d93:	83 c0 14             	add    $0x14,%eax
80103d96:	0f b6 00             	movzbl (%eax),%eax
80103d99:	0f b6 c0             	movzbl %al,%eax
80103d9c:	c1 e0 08             	shl    $0x8,%eax
80103d9f:	89 c2                	mov    %eax,%edx
80103da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da4:	83 c0 13             	add    $0x13,%eax
80103da7:	0f b6 00             	movzbl (%eax),%eax
80103daa:	0f b6 c0             	movzbl %al,%eax
80103dad:	09 d0                	or     %edx,%eax
80103daf:	c1 e0 0a             	shl    $0xa,%eax
80103db2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103db5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103db8:	2d 00 04 00 00       	sub    $0x400,%eax
80103dbd:	83 ec 08             	sub    $0x8,%esp
80103dc0:	68 00 04 00 00       	push   $0x400
80103dc5:	50                   	push   %eax
80103dc6:	e8 fb fe ff ff       	call   80103cc6 <mpsearch1>
80103dcb:	83 c4 10             	add    $0x10,%esp
80103dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103dd1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103dd5:	74 05                	je     80103ddc <mpsearch+0xa9>
      return mp;
80103dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dda:	eb 15                	jmp    80103df1 <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ddc:	83 ec 08             	sub    $0x8,%esp
80103ddf:	68 00 00 01 00       	push   $0x10000
80103de4:	68 00 00 0f 00       	push   $0xf0000
80103de9:	e8 d8 fe ff ff       	call   80103cc6 <mpsearch1>
80103dee:	83 c4 10             	add    $0x10,%esp
}
80103df1:	c9                   	leave  
80103df2:	c3                   	ret    

80103df3 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103df3:	f3 0f 1e fb          	endbr32 
80103df7:	55                   	push   %ebp
80103df8:	89 e5                	mov    %esp,%ebp
80103dfa:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103dfd:	e8 31 ff ff ff       	call   80103d33 <mpsearch>
80103e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e09:	74 0a                	je     80103e15 <mpconfig+0x22>
80103e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0e:	8b 40 04             	mov    0x4(%eax),%eax
80103e11:	85 c0                	test   %eax,%eax
80103e13:	75 07                	jne    80103e1c <mpconfig+0x29>
    return 0;
80103e15:	b8 00 00 00 00       	mov    $0x0,%eax
80103e1a:	eb 7a                	jmp    80103e96 <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1f:	8b 40 04             	mov    0x4(%eax),%eax
80103e22:	05 00 00 00 80       	add    $0x80000000,%eax
80103e27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103e2a:	83 ec 04             	sub    $0x4,%esp
80103e2d:	6a 04                	push   $0x4
80103e2f:	68 a1 95 10 80       	push   $0x801095a1
80103e34:	ff 75 f0             	pushl  -0x10(%ebp)
80103e37:	e8 e5 17 00 00       	call   80105621 <memcmp>
80103e3c:	83 c4 10             	add    $0x10,%esp
80103e3f:	85 c0                	test   %eax,%eax
80103e41:	74 07                	je     80103e4a <mpconfig+0x57>
    return 0;
80103e43:	b8 00 00 00 00       	mov    $0x0,%eax
80103e48:	eb 4c                	jmp    80103e96 <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e4d:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e51:	3c 01                	cmp    $0x1,%al
80103e53:	74 12                	je     80103e67 <mpconfig+0x74>
80103e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e58:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e5c:	3c 04                	cmp    $0x4,%al
80103e5e:	74 07                	je     80103e67 <mpconfig+0x74>
    return 0;
80103e60:	b8 00 00 00 00       	mov    $0x0,%eax
80103e65:	eb 2f                	jmp    80103e96 <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e6a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e6e:	0f b7 c0             	movzwl %ax,%eax
80103e71:	83 ec 08             	sub    $0x8,%esp
80103e74:	50                   	push   %eax
80103e75:	ff 75 f0             	pushl  -0x10(%ebp)
80103e78:	e8 0d fe ff ff       	call   80103c8a <sum>
80103e7d:	83 c4 10             	add    $0x10,%esp
80103e80:	84 c0                	test   %al,%al
80103e82:	74 07                	je     80103e8b <mpconfig+0x98>
    return 0;
80103e84:	b8 00 00 00 00       	mov    $0x0,%eax
80103e89:	eb 0b                	jmp    80103e96 <mpconfig+0xa3>
  *pmp = mp;
80103e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e91:	89 10                	mov    %edx,(%eax)
  return conf;
80103e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e96:	c9                   	leave  
80103e97:	c3                   	ret    

80103e98 <mpinit>:

void
mpinit(void)
{
80103e98:	f3 0f 1e fb          	endbr32 
80103e9c:	55                   	push   %ebp
80103e9d:	89 e5                	mov    %esp,%ebp
80103e9f:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103ea2:	83 ec 0c             	sub    $0xc,%esp
80103ea5:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103ea8:	50                   	push   %eax
80103ea9:	e8 45 ff ff ff       	call   80103df3 <mpconfig>
80103eae:	83 c4 10             	add    $0x10,%esp
80103eb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103eb4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103eb8:	75 0d                	jne    80103ec7 <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103eba:	83 ec 0c             	sub    $0xc,%esp
80103ebd:	68 a6 95 10 80       	push   $0x801095a6
80103ec2:	e8 41 c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103ec7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103ece:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed1:	8b 40 24             	mov    0x24(%eax),%eax
80103ed4:	a3 1c 47 11 80       	mov    %eax,0x8011471c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103edc:	83 c0 2c             	add    $0x2c,%eax
80103edf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ee2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103ee9:	0f b7 d0             	movzwl %ax,%edx
80103eec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eef:	01 d0                	add    %edx,%eax
80103ef1:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103ef4:	e9 8c 00 00 00       	jmp    80103f85 <mpinit+0xed>
    switch(*p){
80103ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103efc:	0f b6 00             	movzbl (%eax),%eax
80103eff:	0f b6 c0             	movzbl %al,%eax
80103f02:	83 f8 04             	cmp    $0x4,%eax
80103f05:	7f 76                	jg     80103f7d <mpinit+0xe5>
80103f07:	83 f8 03             	cmp    $0x3,%eax
80103f0a:	7d 6b                	jge    80103f77 <mpinit+0xdf>
80103f0c:	83 f8 02             	cmp    $0x2,%eax
80103f0f:	74 4e                	je     80103f5f <mpinit+0xc7>
80103f11:	83 f8 02             	cmp    $0x2,%eax
80103f14:	7f 67                	jg     80103f7d <mpinit+0xe5>
80103f16:	85 c0                	test   %eax,%eax
80103f18:	74 07                	je     80103f21 <mpinit+0x89>
80103f1a:	83 f8 01             	cmp    $0x1,%eax
80103f1d:	74 58                	je     80103f77 <mpinit+0xdf>
80103f1f:	eb 5c                	jmp    80103f7d <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f24:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103f27:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103f2c:	83 f8 07             	cmp    $0x7,%eax
80103f2f:	7f 28                	jg     80103f59 <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103f31:	8b 15 a0 4d 11 80    	mov    0x80114da0,%edx
80103f37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f3a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f3e:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103f44:	81 c2 20 48 11 80    	add    $0x80114820,%edx
80103f4a:	88 02                	mov    %al,(%edx)
        ncpu++;
80103f4c:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103f51:	83 c0 01             	add    $0x1,%eax
80103f54:	a3 a0 4d 11 80       	mov    %eax,0x80114da0
      }
      p += sizeof(struct mpproc);
80103f59:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f5d:	eb 26                	jmp    80103f85 <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f68:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f6c:	a2 00 48 11 80       	mov    %al,0x80114800
      p += sizeof(struct mpioapic);
80103f71:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f75:	eb 0e                	jmp    80103f85 <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f77:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f7b:	eb 08                	jmp    80103f85 <mpinit+0xed>
    default:
      ismp = 0;
80103f7d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f84:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f88:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f8b:	0f 82 68 ff ff ff    	jb     80103ef9 <mpinit+0x61>
    }
  }
  if(!ismp)
80103f91:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f95:	75 0d                	jne    80103fa4 <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103f97:	83 ec 0c             	sub    $0xc,%esp
80103f9a:	68 c0 95 10 80       	push   $0x801095c0
80103f9f:	e8 64 c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103fa4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fa7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103fab:	84 c0                	test   %al,%al
80103fad:	74 30                	je     80103fdf <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103faf:	83 ec 08             	sub    $0x8,%esp
80103fb2:	6a 70                	push   $0x70
80103fb4:	6a 22                	push   $0x22
80103fb6:	e8 ae fc ff ff       	call   80103c69 <outb>
80103fbb:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103fbe:	83 ec 0c             	sub    $0xc,%esp
80103fc1:	6a 23                	push   $0x23
80103fc3:	e8 84 fc ff ff       	call   80103c4c <inb>
80103fc8:	83 c4 10             	add    $0x10,%esp
80103fcb:	83 c8 01             	or     $0x1,%eax
80103fce:	0f b6 c0             	movzbl %al,%eax
80103fd1:	83 ec 08             	sub    $0x8,%esp
80103fd4:	50                   	push   %eax
80103fd5:	6a 23                	push   $0x23
80103fd7:	e8 8d fc ff ff       	call   80103c69 <outb>
80103fdc:	83 c4 10             	add    $0x10,%esp
  }
}
80103fdf:	90                   	nop
80103fe0:	c9                   	leave  
80103fe1:	c3                   	ret    

80103fe2 <outb>:
{
80103fe2:	55                   	push   %ebp
80103fe3:	89 e5                	mov    %esp,%ebp
80103fe5:	83 ec 08             	sub    $0x8,%esp
80103fe8:	8b 45 08             	mov    0x8(%ebp),%eax
80103feb:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fee:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103ff2:	89 d0                	mov    %edx,%eax
80103ff4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ff7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ffb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103fff:	ee                   	out    %al,(%dx)
}
80104000:	90                   	nop
80104001:	c9                   	leave  
80104002:	c3                   	ret    

80104003 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80104003:	f3 0f 1e fb          	endbr32 
80104007:	55                   	push   %ebp
80104008:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010400a:	68 ff 00 00 00       	push   $0xff
8010400f:	6a 21                	push   $0x21
80104011:	e8 cc ff ff ff       	call   80103fe2 <outb>
80104016:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104019:	68 ff 00 00 00       	push   $0xff
8010401e:	68 a1 00 00 00       	push   $0xa1
80104023:	e8 ba ff ff ff       	call   80103fe2 <outb>
80104028:	83 c4 08             	add    $0x8,%esp
}
8010402b:	90                   	nop
8010402c:	c9                   	leave  
8010402d:	c3                   	ret    

8010402e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010402e:	f3 0f 1e fb          	endbr32 
80104032:	55                   	push   %ebp
80104033:	89 e5                	mov    %esp,%ebp
80104035:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104038:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010403f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104042:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104048:	8b 45 0c             	mov    0xc(%ebp),%eax
8010404b:	8b 10                	mov    (%eax),%edx
8010404d:	8b 45 08             	mov    0x8(%ebp),%eax
80104050:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104052:	e8 bc d0 ff ff       	call   80101113 <filealloc>
80104057:	8b 55 08             	mov    0x8(%ebp),%edx
8010405a:	89 02                	mov    %eax,(%edx)
8010405c:	8b 45 08             	mov    0x8(%ebp),%eax
8010405f:	8b 00                	mov    (%eax),%eax
80104061:	85 c0                	test   %eax,%eax
80104063:	0f 84 c8 00 00 00    	je     80104131 <pipealloc+0x103>
80104069:	e8 a5 d0 ff ff       	call   80101113 <filealloc>
8010406e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104071:	89 02                	mov    %eax,(%edx)
80104073:	8b 45 0c             	mov    0xc(%ebp),%eax
80104076:	8b 00                	mov    (%eax),%eax
80104078:	85 c0                	test   %eax,%eax
8010407a:	0f 84 b1 00 00 00    	je     80104131 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104080:	e8 c4 ed ff ff       	call   80102e49 <kalloc>
80104085:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104088:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010408c:	0f 84 a2 00 00 00    	je     80104134 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80104092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104095:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010409c:	00 00 00 
  p->writeopen = 1;
8010409f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a2:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040a9:	00 00 00 
  p->nwrite = 0;
801040ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040af:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040b6:	00 00 00 
  p->nread = 0;
801040b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bc:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040c3:	00 00 00 
  initlock(&p->lock, "pipe");
801040c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c9:	83 ec 08             	sub    $0x8,%esp
801040cc:	68 df 95 10 80       	push   $0x801095df
801040d1:	50                   	push   %eax
801040d2:	e8 1a 12 00 00       	call   801052f1 <initlock>
801040d7:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040da:	8b 45 08             	mov    0x8(%ebp),%eax
801040dd:	8b 00                	mov    (%eax),%eax
801040df:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040e5:	8b 45 08             	mov    0x8(%ebp),%eax
801040e8:	8b 00                	mov    (%eax),%eax
801040ea:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801040ee:	8b 45 08             	mov    0x8(%ebp),%eax
801040f1:	8b 00                	mov    (%eax),%eax
801040f3:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801040f7:	8b 45 08             	mov    0x8(%ebp),%eax
801040fa:	8b 00                	mov    (%eax),%eax
801040fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040ff:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104102:	8b 45 0c             	mov    0xc(%ebp),%eax
80104105:	8b 00                	mov    (%eax),%eax
80104107:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010410d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104110:	8b 00                	mov    (%eax),%eax
80104112:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104116:	8b 45 0c             	mov    0xc(%ebp),%eax
80104119:	8b 00                	mov    (%eax),%eax
8010411b:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010411f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104122:	8b 00                	mov    (%eax),%eax
80104124:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104127:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010412a:	b8 00 00 00 00       	mov    $0x0,%eax
8010412f:	eb 51                	jmp    80104182 <pipealloc+0x154>
    goto bad;
80104131:	90                   	nop
80104132:	eb 01                	jmp    80104135 <pipealloc+0x107>
    goto bad;
80104134:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104135:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104139:	74 0e                	je     80104149 <pipealloc+0x11b>
    kfree((char*)p);
8010413b:	83 ec 0c             	sub    $0xc,%esp
8010413e:	ff 75 f4             	pushl  -0xc(%ebp)
80104141:	e8 65 ec ff ff       	call   80102dab <kfree>
80104146:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104149:	8b 45 08             	mov    0x8(%ebp),%eax
8010414c:	8b 00                	mov    (%eax),%eax
8010414e:	85 c0                	test   %eax,%eax
80104150:	74 11                	je     80104163 <pipealloc+0x135>
    fileclose(*f0);
80104152:	8b 45 08             	mov    0x8(%ebp),%eax
80104155:	8b 00                	mov    (%eax),%eax
80104157:	83 ec 0c             	sub    $0xc,%esp
8010415a:	50                   	push   %eax
8010415b:	e8 79 d0 ff ff       	call   801011d9 <fileclose>
80104160:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104163:	8b 45 0c             	mov    0xc(%ebp),%eax
80104166:	8b 00                	mov    (%eax),%eax
80104168:	85 c0                	test   %eax,%eax
8010416a:	74 11                	je     8010417d <pipealloc+0x14f>
    fileclose(*f1);
8010416c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010416f:	8b 00                	mov    (%eax),%eax
80104171:	83 ec 0c             	sub    $0xc,%esp
80104174:	50                   	push   %eax
80104175:	e8 5f d0 ff ff       	call   801011d9 <fileclose>
8010417a:	83 c4 10             	add    $0x10,%esp
  return -1;
8010417d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104182:	c9                   	leave  
80104183:	c3                   	ret    

80104184 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104184:	f3 0f 1e fb          	endbr32 
80104188:	55                   	push   %ebp
80104189:	89 e5                	mov    %esp,%ebp
8010418b:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010418e:	8b 45 08             	mov    0x8(%ebp),%eax
80104191:	83 ec 0c             	sub    $0xc,%esp
80104194:	50                   	push   %eax
80104195:	e8 7d 11 00 00       	call   80105317 <acquire>
8010419a:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010419d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041a1:	74 23                	je     801041c6 <pipeclose+0x42>
    p->writeopen = 0;
801041a3:	8b 45 08             	mov    0x8(%ebp),%eax
801041a6:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041ad:	00 00 00 
    wakeup(&p->nread);
801041b0:	8b 45 08             	mov    0x8(%ebp),%eax
801041b3:	05 34 02 00 00       	add    $0x234,%eax
801041b8:	83 ec 0c             	sub    $0xc,%esp
801041bb:	50                   	push   %eax
801041bc:	e8 d6 0d 00 00       	call   80104f97 <wakeup>
801041c1:	83 c4 10             	add    $0x10,%esp
801041c4:	eb 21                	jmp    801041e7 <pipeclose+0x63>
  } else {
    p->readopen = 0;
801041c6:	8b 45 08             	mov    0x8(%ebp),%eax
801041c9:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041d0:	00 00 00 
    wakeup(&p->nwrite);
801041d3:	8b 45 08             	mov    0x8(%ebp),%eax
801041d6:	05 38 02 00 00       	add    $0x238,%eax
801041db:	83 ec 0c             	sub    $0xc,%esp
801041de:	50                   	push   %eax
801041df:	e8 b3 0d 00 00       	call   80104f97 <wakeup>
801041e4:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041e7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ea:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041f0:	85 c0                	test   %eax,%eax
801041f2:	75 2c                	jne    80104220 <pipeclose+0x9c>
801041f4:	8b 45 08             	mov    0x8(%ebp),%eax
801041f7:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041fd:	85 c0                	test   %eax,%eax
801041ff:	75 1f                	jne    80104220 <pipeclose+0x9c>
    release(&p->lock);
80104201:	8b 45 08             	mov    0x8(%ebp),%eax
80104204:	83 ec 0c             	sub    $0xc,%esp
80104207:	50                   	push   %eax
80104208:	e8 7c 11 00 00       	call   80105389 <release>
8010420d:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104210:	83 ec 0c             	sub    $0xc,%esp
80104213:	ff 75 08             	pushl  0x8(%ebp)
80104216:	e8 90 eb ff ff       	call   80102dab <kfree>
8010421b:	83 c4 10             	add    $0x10,%esp
8010421e:	eb 10                	jmp    80104230 <pipeclose+0xac>
  } else
    release(&p->lock);
80104220:	8b 45 08             	mov    0x8(%ebp),%eax
80104223:	83 ec 0c             	sub    $0xc,%esp
80104226:	50                   	push   %eax
80104227:	e8 5d 11 00 00       	call   80105389 <release>
8010422c:	83 c4 10             	add    $0x10,%esp
}
8010422f:	90                   	nop
80104230:	90                   	nop
80104231:	c9                   	leave  
80104232:	c3                   	ret    

80104233 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104233:	f3 0f 1e fb          	endbr32 
80104237:	55                   	push   %ebp
80104238:	89 e5                	mov    %esp,%ebp
8010423a:	53                   	push   %ebx
8010423b:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
8010423e:	8b 45 08             	mov    0x8(%ebp),%eax
80104241:	83 ec 0c             	sub    $0xc,%esp
80104244:	50                   	push   %eax
80104245:	e8 cd 10 00 00       	call   80105317 <acquire>
8010424a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010424d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104254:	e9 ad 00 00 00       	jmp    80104306 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80104259:	8b 45 08             	mov    0x8(%ebp),%eax
8010425c:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104262:	85 c0                	test   %eax,%eax
80104264:	74 0c                	je     80104272 <pipewrite+0x3f>
80104266:	e8 a2 02 00 00       	call   8010450d <myproc>
8010426b:	8b 40 24             	mov    0x24(%eax),%eax
8010426e:	85 c0                	test   %eax,%eax
80104270:	74 19                	je     8010428b <pipewrite+0x58>
        release(&p->lock);
80104272:	8b 45 08             	mov    0x8(%ebp),%eax
80104275:	83 ec 0c             	sub    $0xc,%esp
80104278:	50                   	push   %eax
80104279:	e8 0b 11 00 00       	call   80105389 <release>
8010427e:	83 c4 10             	add    $0x10,%esp
        return -1;
80104281:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104286:	e9 a9 00 00 00       	jmp    80104334 <pipewrite+0x101>
      }
      wakeup(&p->nread);
8010428b:	8b 45 08             	mov    0x8(%ebp),%eax
8010428e:	05 34 02 00 00       	add    $0x234,%eax
80104293:	83 ec 0c             	sub    $0xc,%esp
80104296:	50                   	push   %eax
80104297:	e8 fb 0c 00 00       	call   80104f97 <wakeup>
8010429c:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010429f:	8b 45 08             	mov    0x8(%ebp),%eax
801042a2:	8b 55 08             	mov    0x8(%ebp),%edx
801042a5:	81 c2 38 02 00 00    	add    $0x238,%edx
801042ab:	83 ec 08             	sub    $0x8,%esp
801042ae:	50                   	push   %eax
801042af:	52                   	push   %edx
801042b0:	e8 f0 0b 00 00       	call   80104ea5 <sleep>
801042b5:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042b8:	8b 45 08             	mov    0x8(%ebp),%eax
801042bb:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042c1:	8b 45 08             	mov    0x8(%ebp),%eax
801042c4:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042ca:	05 00 02 00 00       	add    $0x200,%eax
801042cf:	39 c2                	cmp    %eax,%edx
801042d1:	74 86                	je     80104259 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801042d9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801042dc:	8b 45 08             	mov    0x8(%ebp),%eax
801042df:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042e5:	8d 48 01             	lea    0x1(%eax),%ecx
801042e8:	8b 55 08             	mov    0x8(%ebp),%edx
801042eb:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042f1:	25 ff 01 00 00       	and    $0x1ff,%eax
801042f6:	89 c1                	mov    %eax,%ecx
801042f8:	0f b6 13             	movzbl (%ebx),%edx
801042fb:	8b 45 08             	mov    0x8(%ebp),%eax
801042fe:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104302:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104309:	3b 45 10             	cmp    0x10(%ebp),%eax
8010430c:	7c aa                	jl     801042b8 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010430e:	8b 45 08             	mov    0x8(%ebp),%eax
80104311:	05 34 02 00 00       	add    $0x234,%eax
80104316:	83 ec 0c             	sub    $0xc,%esp
80104319:	50                   	push   %eax
8010431a:	e8 78 0c 00 00       	call   80104f97 <wakeup>
8010431f:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104322:	8b 45 08             	mov    0x8(%ebp),%eax
80104325:	83 ec 0c             	sub    $0xc,%esp
80104328:	50                   	push   %eax
80104329:	e8 5b 10 00 00       	call   80105389 <release>
8010432e:	83 c4 10             	add    $0x10,%esp
  return n;
80104331:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104334:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104337:	c9                   	leave  
80104338:	c3                   	ret    

80104339 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104339:	f3 0f 1e fb          	endbr32 
8010433d:	55                   	push   %ebp
8010433e:	89 e5                	mov    %esp,%ebp
80104340:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
80104346:	83 ec 0c             	sub    $0xc,%esp
80104349:	50                   	push   %eax
8010434a:	e8 c8 0f 00 00       	call   80105317 <acquire>
8010434f:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104352:	eb 3e                	jmp    80104392 <piperead+0x59>
    if(myproc()->killed){
80104354:	e8 b4 01 00 00       	call   8010450d <myproc>
80104359:	8b 40 24             	mov    0x24(%eax),%eax
8010435c:	85 c0                	test   %eax,%eax
8010435e:	74 19                	je     80104379 <piperead+0x40>
      release(&p->lock);
80104360:	8b 45 08             	mov    0x8(%ebp),%eax
80104363:	83 ec 0c             	sub    $0xc,%esp
80104366:	50                   	push   %eax
80104367:	e8 1d 10 00 00       	call   80105389 <release>
8010436c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010436f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104374:	e9 be 00 00 00       	jmp    80104437 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104379:	8b 45 08             	mov    0x8(%ebp),%eax
8010437c:	8b 55 08             	mov    0x8(%ebp),%edx
8010437f:	81 c2 34 02 00 00    	add    $0x234,%edx
80104385:	83 ec 08             	sub    $0x8,%esp
80104388:	50                   	push   %eax
80104389:	52                   	push   %edx
8010438a:	e8 16 0b 00 00       	call   80104ea5 <sleep>
8010438f:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104392:	8b 45 08             	mov    0x8(%ebp),%eax
80104395:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010439b:	8b 45 08             	mov    0x8(%ebp),%eax
8010439e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043a4:	39 c2                	cmp    %eax,%edx
801043a6:	75 0d                	jne    801043b5 <piperead+0x7c>
801043a8:	8b 45 08             	mov    0x8(%ebp),%eax
801043ab:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043b1:	85 c0                	test   %eax,%eax
801043b3:	75 9f                	jne    80104354 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043bc:	eb 48                	jmp    80104406 <piperead+0xcd>
    if(p->nread == p->nwrite)
801043be:	8b 45 08             	mov    0x8(%ebp),%eax
801043c1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043c7:	8b 45 08             	mov    0x8(%ebp),%eax
801043ca:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043d0:	39 c2                	cmp    %eax,%edx
801043d2:	74 3c                	je     80104410 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043d4:	8b 45 08             	mov    0x8(%ebp),%eax
801043d7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043dd:	8d 48 01             	lea    0x1(%eax),%ecx
801043e0:	8b 55 08             	mov    0x8(%ebp),%edx
801043e3:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043e9:	25 ff 01 00 00       	and    $0x1ff,%eax
801043ee:	89 c1                	mov    %eax,%ecx
801043f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801043f6:	01 c2                	add    %eax,%edx
801043f8:	8b 45 08             	mov    0x8(%ebp),%eax
801043fb:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104400:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104402:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104409:	3b 45 10             	cmp    0x10(%ebp),%eax
8010440c:	7c b0                	jl     801043be <piperead+0x85>
8010440e:	eb 01                	jmp    80104411 <piperead+0xd8>
      break;
80104410:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104411:	8b 45 08             	mov    0x8(%ebp),%eax
80104414:	05 38 02 00 00       	add    $0x238,%eax
80104419:	83 ec 0c             	sub    $0xc,%esp
8010441c:	50                   	push   %eax
8010441d:	e8 75 0b 00 00       	call   80104f97 <wakeup>
80104422:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104425:	8b 45 08             	mov    0x8(%ebp),%eax
80104428:	83 ec 0c             	sub    $0xc,%esp
8010442b:	50                   	push   %eax
8010442c:	e8 58 0f 00 00       	call   80105389 <release>
80104431:	83 c4 10             	add    $0x10,%esp
  return i;
80104434:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104437:	c9                   	leave  
80104438:	c3                   	ret    

80104439 <readeflags>:
{
80104439:	55                   	push   %ebp
8010443a:	89 e5                	mov    %esp,%ebp
8010443c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010443f:	9c                   	pushf  
80104440:	58                   	pop    %eax
80104441:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104444:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104447:	c9                   	leave  
80104448:	c3                   	ret    

80104449 <sti>:
{
80104449:	55                   	push   %ebp
8010444a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010444c:	fb                   	sti    
}
8010444d:	90                   	nop
8010444e:	5d                   	pop    %ebp
8010444f:	c3                   	ret    

80104450 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104450:	f3 0f 1e fb          	endbr32 
80104454:	55                   	push   %ebp
80104455:	89 e5                	mov    %esp,%ebp
80104457:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010445a:	83 ec 08             	sub    $0x8,%esp
8010445d:	68 e4 95 10 80       	push   $0x801095e4
80104462:	68 c0 4d 11 80       	push   $0x80114dc0
80104467:	e8 85 0e 00 00       	call   801052f1 <initlock>
8010446c:	83 c4 10             	add    $0x10,%esp
}
8010446f:	90                   	nop
80104470:	c9                   	leave  
80104471:	c3                   	ret    

80104472 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104472:	f3 0f 1e fb          	endbr32 
80104476:	55                   	push   %ebp
80104477:	89 e5                	mov    %esp,%ebp
80104479:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010447c:	e8 10 00 00 00       	call   80104491 <mycpu>
80104481:	2d 20 48 11 80       	sub    $0x80114820,%eax
80104486:	c1 f8 04             	sar    $0x4,%eax
80104489:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010448f:	c9                   	leave  
80104490:	c3                   	ret    

80104491 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104491:	f3 0f 1e fb          	endbr32 
80104495:	55                   	push   %ebp
80104496:	89 e5                	mov    %esp,%ebp
80104498:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
8010449b:	e8 99 ff ff ff       	call   80104439 <readeflags>
801044a0:	25 00 02 00 00       	and    $0x200,%eax
801044a5:	85 c0                	test   %eax,%eax
801044a7:	74 0d                	je     801044b6 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
801044a9:	83 ec 0c             	sub    $0xc,%esp
801044ac:	68 ec 95 10 80       	push   $0x801095ec
801044b1:	e8 52 c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
801044b6:	e8 21 ed ff ff       	call   801031dc <lapicid>
801044bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801044be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044c5:	eb 2d                	jmp    801044f4 <mycpu+0x63>
    if (cpus[i].apicid == apicid)
801044c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ca:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044d0:	05 20 48 11 80       	add    $0x80114820,%eax
801044d5:	0f b6 00             	movzbl (%eax),%eax
801044d8:	0f b6 c0             	movzbl %al,%eax
801044db:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801044de:	75 10                	jne    801044f0 <mycpu+0x5f>
      return &cpus[i];
801044e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044e9:	05 20 48 11 80       	add    $0x80114820,%eax
801044ee:	eb 1b                	jmp    8010450b <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
801044f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044f4:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801044f9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801044fc:	7c c9                	jl     801044c7 <mycpu+0x36>
  }
  panic("unknown apicid\n");
801044fe:	83 ec 0c             	sub    $0xc,%esp
80104501:	68 12 96 10 80       	push   $0x80109612
80104506:	e8 fd c0 ff ff       	call   80100608 <panic>
}
8010450b:	c9                   	leave  
8010450c:	c3                   	ret    

8010450d <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010450d:	f3 0f 1e fb          	endbr32 
80104511:	55                   	push   %ebp
80104512:	89 e5                	mov    %esp,%ebp
80104514:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104517:	e8 87 0f 00 00       	call   801054a3 <pushcli>
  c = mycpu();
8010451c:	e8 70 ff ff ff       	call   80104491 <mycpu>
80104521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010452d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104530:	e8 bf 0f 00 00       	call   801054f4 <popcli>
  return p;
80104535:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104538:	c9                   	leave  
80104539:	c3                   	ret    

8010453a <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010453a:	f3 0f 1e fb          	endbr32 
8010453e:	55                   	push   %ebp
8010453f:	89 e5                	mov    %esp,%ebp
80104541:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104544:	83 ec 0c             	sub    $0xc,%esp
80104547:	68 c0 4d 11 80       	push   $0x80114dc0
8010454c:	e8 c6 0d 00 00       	call   80105317 <acquire>
80104551:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104554:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
8010455b:	eb 11                	jmp    8010456e <allocproc+0x34>
    if(p->state == UNUSED)
8010455d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104560:	8b 40 0c             	mov    0xc(%eax),%eax
80104563:	85 c0                	test   %eax,%eax
80104565:	74 2a                	je     80104591 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104567:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
8010456e:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104575:	72 e6                	jb     8010455d <allocproc+0x23>
      goto found;

  release(&ptable.lock);
80104577:	83 ec 0c             	sub    $0xc,%esp
8010457a:	68 c0 4d 11 80       	push   $0x80114dc0
8010457f:	e8 05 0e 00 00       	call   80105389 <release>
80104584:	83 c4 10             	add    $0x10,%esp
  return 0;
80104587:	b8 00 00 00 00       	mov    $0x0,%eax
8010458c:	e9 b6 00 00 00       	jmp    80104647 <allocproc+0x10d>
      goto found;
80104591:	90                   	nop
80104592:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104599:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801045a0:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801045a5:	8d 50 01             	lea    0x1(%eax),%edx
801045a8:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
801045ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b1:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801045b4:	83 ec 0c             	sub    $0xc,%esp
801045b7:	68 c0 4d 11 80       	push   $0x80114dc0
801045bc:	e8 c8 0d 00 00       	call   80105389 <release>
801045c1:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045c4:	e8 80 e8 ff ff       	call   80102e49 <kalloc>
801045c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045cc:	89 42 08             	mov    %eax,0x8(%edx)
801045cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d2:	8b 40 08             	mov    0x8(%eax),%eax
801045d5:	85 c0                	test   %eax,%eax
801045d7:	75 11                	jne    801045ea <allocproc+0xb0>
    p->state = UNUSED;
801045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801045e3:	b8 00 00 00 00       	mov    $0x0,%eax
801045e8:	eb 5d                	jmp    80104647 <allocproc+0x10d>
  }
  sp = p->kstack + KSTACKSIZE;
801045ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ed:	8b 40 08             	mov    0x8(%eax),%eax
801045f0:	05 00 10 00 00       	add    $0x1000,%eax
801045f5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801045f8:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801045fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104602:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104605:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104609:	ba 2c 6b 10 80       	mov    $0x80106b2c,%edx
8010460e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104611:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104613:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010461d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104623:	8b 40 1c             	mov    0x1c(%eax),%eax
80104626:	83 ec 04             	sub    $0x4,%esp
80104629:	6a 14                	push   $0x14
8010462b:	6a 00                	push   $0x0
8010462d:	50                   	push   %eax
8010462e:	e8 83 0f 00 00       	call   801055b6 <memset>
80104633:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104639:	8b 40 1c             	mov    0x1c(%eax),%eax
8010463c:	ba 5b 4e 10 80       	mov    $0x80104e5b,%edx
80104641:	89 50 10             	mov    %edx,0x10(%eax)
//TODO initiailize all to -1ss
  return p;
80104644:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104647:	c9                   	leave  
80104648:	c3                   	ret    

80104649 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104649:	f3 0f 1e fb          	endbr32 
8010464d:	55                   	push   %ebp
8010464e:	89 e5                	mov    %esp,%ebp
80104650:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104653:	e8 e2 fe ff ff       	call   8010453a <allocproc>
80104658:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010465b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465e:	a3 40 c6 10 80       	mov    %eax,0x8010c640
  if((p->pgdir = setupkvm()) == 0)
80104663:	e8 94 3a 00 00       	call   801080fc <setupkvm>
80104668:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010466b:	89 42 04             	mov    %eax,0x4(%edx)
8010466e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104671:	8b 40 04             	mov    0x4(%eax),%eax
80104674:	85 c0                	test   %eax,%eax
80104676:	75 0d                	jne    80104685 <userinit+0x3c>
    panic("userinit: out of memory?");
80104678:	83 ec 0c             	sub    $0xc,%esp
8010467b:	68 22 96 10 80       	push   $0x80109622
80104680:	e8 83 bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104685:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010468a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468d:	8b 40 04             	mov    0x4(%eax),%eax
80104690:	83 ec 04             	sub    $0x4,%esp
80104693:	52                   	push   %edx
80104694:	68 e0 c4 10 80       	push   $0x8010c4e0
80104699:	50                   	push   %eax
8010469a:	e8 d6 3c 00 00       	call   80108375 <inituvm>
8010469f:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801046a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801046ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ae:	8b 40 18             	mov    0x18(%eax),%eax
801046b1:	83 ec 04             	sub    $0x4,%esp
801046b4:	6a 4c                	push   $0x4c
801046b6:	6a 00                	push   $0x0
801046b8:	50                   	push   %eax
801046b9:	e8 f8 0e 00 00       	call   801055b6 <memset>
801046be:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801046c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c4:	8b 40 18             	mov    0x18(%eax),%eax
801046c7:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d0:	8b 40 18             	mov    0x18(%eax),%eax
801046d3:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801046d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046dc:	8b 50 18             	mov    0x18(%eax),%edx
801046df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e2:	8b 40 18             	mov    0x18(%eax),%eax
801046e5:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046e9:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801046ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f0:	8b 50 18             	mov    0x18(%eax),%edx
801046f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f6:	8b 40 18             	mov    0x18(%eax),%eax
801046f9:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046fd:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104704:	8b 40 18             	mov    0x18(%eax),%eax
80104707:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010470e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104711:	8b 40 18             	mov    0x18(%eax),%eax
80104714:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010471b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471e:	8b 40 18             	mov    0x18(%eax),%eax
80104721:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472b:	83 c0 6c             	add    $0x6c,%eax
8010472e:	83 ec 04             	sub    $0x4,%esp
80104731:	6a 10                	push   $0x10
80104733:	68 3b 96 10 80       	push   $0x8010963b
80104738:	50                   	push   %eax
80104739:	e8 93 10 00 00       	call   801057d1 <safestrcpy>
8010473e:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104741:	83 ec 0c             	sub    $0xc,%esp
80104744:	68 44 96 10 80       	push   $0x80109644
80104749:	e8 76 df ff ff       	call   801026c4 <namei>
8010474e:	83 c4 10             	add    $0x10,%esp
80104751:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104754:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104757:	83 ec 0c             	sub    $0xc,%esp
8010475a:	68 c0 4d 11 80       	push   $0x80114dc0
8010475f:	e8 b3 0b 00 00       	call   80105317 <acquire>
80104764:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104771:	83 ec 0c             	sub    $0xc,%esp
80104774:	68 c0 4d 11 80       	push   $0x80114dc0
80104779:	e8 0b 0c 00 00       	call   80105389 <release>
8010477e:	83 c4 10             	add    $0x10,%esp
}
80104781:	90                   	nop
80104782:	c9                   	leave  
80104783:	c3                   	ret    

80104784 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104784:	f3 0f 1e fb          	endbr32 
80104788:	55                   	push   %ebp
80104789:	89 e5                	mov    %esp,%ebp
8010478b:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
8010478e:	e8 7a fd ff ff       	call   8010450d <myproc>
80104793:	89 45 ec             	mov    %eax,-0x14(%ebp)

  sz = curproc->sz;
80104796:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104799:	8b 00                	mov    (%eax),%eax
8010479b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int tempsize = sz;
8010479e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(n > 0){
801047a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047a8:	7e 35                	jle    801047df <growproc+0x5b>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801047aa:	8b 55 08             	mov    0x8(%ebp),%edx
801047ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b0:	01 c2                	add    %eax,%edx
801047b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047b5:	8b 40 04             	mov    0x4(%eax),%eax
801047b8:	83 ec 04             	sub    $0x4,%esp
801047bb:	52                   	push   %edx
801047bc:	ff 75 f4             	pushl  -0xc(%ebp)
801047bf:	50                   	push   %eax
801047c0:	e8 f5 3c 00 00       	call   801084ba <allocuvm>
801047c5:	83 c4 10             	add    $0x10,%esp
801047c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047cf:	0f 85 a4 00 00 00    	jne    80104879 <growproc+0xf5>
      return -1;
801047d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047da:	e9 f5 00 00 00       	jmp    801048d4 <growproc+0x150>
  } else if(n < 0){
801047df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047e3:	0f 89 90 00 00 00    	jns    80104879 <growproc+0xf5>
    int fromAddress = PGROUNDDOWN(sz+n);
801047e9:	8b 55 08             	mov    0x8(%ebp),%edx
801047ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ef:	01 d0                	add    %edx,%eax
801047f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801047f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(int i =0;i<CLOCKSIZE;i++){
801047f9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104800:	eb 43                	jmp    80104845 <growproc+0xc1>
      if(curproc->clock[i]>=fromAddress){
80104802:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104805:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104808:	83 c2 1c             	add    $0x1c,%edx
8010480b:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
8010480f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104812:	39 c2                	cmp    %eax,%edx
80104814:	72 2b                	jb     80104841 <growproc+0xbd>
      curproc->clock[i]=-1;
80104816:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104819:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010481c:	83 c2 1c             	add    $0x1c,%edx
8010481f:	c7 44 90 0c ff ff ff 	movl   $0xffffffff,0xc(%eax,%edx,4)
80104826:	ff 
      curproc->clock_hand=0;
80104827:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010482a:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
80104831:	00 00 00 
      curproc->current_searches=0;
80104834:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104837:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
8010483e:	00 00 00 
    for(int i =0;i<CLOCKSIZE;i++){
80104841:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104845:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
80104849:	7e b7                	jle    80104802 <growproc+0x7e>
      }
  }
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010484b:	8b 55 08             	mov    0x8(%ebp),%edx
8010484e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104851:	01 c2                	add    %eax,%edx
80104853:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104856:	8b 40 04             	mov    0x4(%eax),%eax
80104859:	83 ec 04             	sub    $0x4,%esp
8010485c:	52                   	push   %edx
8010485d:	ff 75 f4             	pushl  -0xc(%ebp)
80104860:	50                   	push   %eax
80104861:	e8 5d 3d 00 00       	call   801085c3 <deallocuvm>
80104866:	83 c4 10             	add    $0x10,%esp
80104869:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010486c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104870:	75 07                	jne    80104879 <growproc+0xf5>
      return -1;
80104872:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104877:	eb 5b                	jmp    801048d4 <growproc+0x150>
  }

  curproc->sz = sz;
80104879:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010487c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010487f:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104881:	83 ec 0c             	sub    $0xc,%esp
80104884:	ff 75 ec             	pushl  -0x14(%ebp)
80104887:	e8 46 39 00 00       	call   801081d2 <switchuvm>
8010488c:	83 c4 10             	add    $0x10,%esp
  int pages =(PGROUNDUP(curproc->sz)-PGROUNDUP(tempsize))/PGSIZE;
8010488f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104892:	8b 00                	mov    (%eax),%eax
80104894:	05 ff 0f 00 00       	add    $0xfff,%eax
80104899:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010489e:	89 c2                	mov    %eax,%edx
801048a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048a3:	05 ff 0f 00 00       	add    $0xfff,%eax
801048a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801048ad:	29 c2                	sub    %eax,%edx
801048af:	89 d0                	mov    %edx,%eax
801048b1:	c1 e8 0c             	shr    $0xc,%eax
801048b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
 
if(pages>0){
801048b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801048bb:	7e 12                	jle    801048cf <growproc+0x14b>
  mencrypt((char *)tempsize,pages);
801048bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048c0:	83 ec 08             	sub    $0x8,%esp
801048c3:	ff 75 e0             	pushl  -0x20(%ebp)
801048c6:	50                   	push   %eax
801048c7:	e8 c5 44 00 00       	call   80108d91 <mencrypt>
801048cc:	83 c4 10             	add    $0x10,%esp
}
  return 0;
801048cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048d4:	c9                   	leave  
801048d5:	c3                   	ret    

801048d6 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801048d6:	f3 0f 1e fb          	endbr32 
801048da:	55                   	push   %ebp
801048db:	89 e5                	mov    %esp,%ebp
801048dd:	57                   	push   %edi
801048de:	56                   	push   %esi
801048df:	53                   	push   %ebx
801048e0:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801048e3:	e8 25 fc ff ff       	call   8010450d <myproc>
801048e8:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801048eb:	e8 4a fc ff ff       	call   8010453a <allocproc>
801048f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
801048f3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801048f7:	75 0a                	jne    80104903 <fork+0x2d>
    return -1;
801048f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048fe:	e9 48 01 00 00       	jmp    80104a4b <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104903:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104906:	8b 10                	mov    (%eax),%edx
80104908:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010490b:	8b 40 04             	mov    0x4(%eax),%eax
8010490e:	83 ec 08             	sub    $0x8,%esp
80104911:	52                   	push   %edx
80104912:	50                   	push   %eax
80104913:	e8 59 3e 00 00       	call   80108771 <copyuvm>
80104918:	83 c4 10             	add    $0x10,%esp
8010491b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010491e:	89 42 04             	mov    %eax,0x4(%edx)
80104921:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104924:	8b 40 04             	mov    0x4(%eax),%eax
80104927:	85 c0                	test   %eax,%eax
80104929:	75 30                	jne    8010495b <fork+0x85>
    kfree(np->kstack);
8010492b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010492e:	8b 40 08             	mov    0x8(%eax),%eax
80104931:	83 ec 0c             	sub    $0xc,%esp
80104934:	50                   	push   %eax
80104935:	e8 71 e4 ff ff       	call   80102dab <kfree>
8010493a:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010493d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104940:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104947:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010494a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104951:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104956:	e9 f0 00 00 00       	jmp    80104a4b <fork+0x175>
  }
  np->sz = curproc->sz;
8010495b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010495e:	8b 10                	mov    (%eax),%edx
80104960:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104963:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104965:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104968:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010496b:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010496e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104971:	8b 48 18             	mov    0x18(%eax),%ecx
80104974:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104977:	8b 40 18             	mov    0x18(%eax),%eax
8010497a:	89 c2                	mov    %eax,%edx
8010497c:	89 cb                	mov    %ecx,%ebx
8010497e:	b8 13 00 00 00       	mov    $0x13,%eax
80104983:	89 d7                	mov    %edx,%edi
80104985:	89 de                	mov    %ebx,%esi
80104987:	89 c1                	mov    %eax,%ecx
80104989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010498b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010498e:	8b 40 18             	mov    0x18(%eax),%eax
80104991:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104998:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010499f:	eb 3b                	jmp    801049dc <fork+0x106>
    if(curproc->ofile[i])
801049a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801049a7:	83 c2 08             	add    $0x8,%edx
801049aa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049ae:	85 c0                	test   %eax,%eax
801049b0:	74 26                	je     801049d8 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
801049b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801049b8:	83 c2 08             	add    $0x8,%edx
801049bb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049bf:	83 ec 0c             	sub    $0xc,%esp
801049c2:	50                   	push   %eax
801049c3:	e8 bc c7 ff ff       	call   80101184 <filedup>
801049c8:	83 c4 10             	add    $0x10,%esp
801049cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
801049ce:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801049d1:	83 c1 08             	add    $0x8,%ecx
801049d4:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
801049d8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801049dc:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801049e0:	7e bf                	jle    801049a1 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
801049e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049e5:	8b 40 68             	mov    0x68(%eax),%eax
801049e8:	83 ec 0c             	sub    $0xc,%esp
801049eb:	50                   	push   %eax
801049ec:	e8 2a d1 ff ff       	call   80101b1b <idup>
801049f1:	83 c4 10             	add    $0x10,%esp
801049f4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801049f7:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801049fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049fd:	8d 50 6c             	lea    0x6c(%eax),%edx
80104a00:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a03:	83 c0 6c             	add    $0x6c,%eax
80104a06:	83 ec 04             	sub    $0x4,%esp
80104a09:	6a 10                	push   $0x10
80104a0b:	52                   	push   %edx
80104a0c:	50                   	push   %eax
80104a0d:	e8 bf 0d 00 00       	call   801057d1 <safestrcpy>
80104a12:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104a15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a18:	8b 40 10             	mov    0x10(%eax),%eax
80104a1b:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104a1e:	83 ec 0c             	sub    $0xc,%esp
80104a21:	68 c0 4d 11 80       	push   $0x80114dc0
80104a26:	e8 ec 08 00 00       	call   80105317 <acquire>
80104a2b:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104a2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a31:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104a38:	83 ec 0c             	sub    $0xc,%esp
80104a3b:	68 c0 4d 11 80       	push   $0x80114dc0
80104a40:	e8 44 09 00 00       	call   80105389 <release>
80104a45:	83 c4 10             	add    $0x10,%esp

  return pid;
80104a48:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104a4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a4e:	5b                   	pop    %ebx
80104a4f:	5e                   	pop    %esi
80104a50:	5f                   	pop    %edi
80104a51:	5d                   	pop    %ebp
80104a52:	c3                   	ret    

80104a53 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104a53:	f3 0f 1e fb          	endbr32 
80104a57:	55                   	push   %ebp
80104a58:	89 e5                	mov    %esp,%ebp
80104a5a:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104a5d:	e8 ab fa ff ff       	call   8010450d <myproc>
80104a62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104a65:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104a6a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a6d:	75 0d                	jne    80104a7c <exit+0x29>
    panic("init exiting");
80104a6f:	83 ec 0c             	sub    $0xc,%esp
80104a72:	68 46 96 10 80       	push   $0x80109646
80104a77:	e8 8c bb ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a7c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a83:	eb 3f                	jmp    80104ac4 <exit+0x71>
    if(curproc->ofile[fd]){
80104a85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a88:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a8b:	83 c2 08             	add    $0x8,%edx
80104a8e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a92:	85 c0                	test   %eax,%eax
80104a94:	74 2a                	je     80104ac0 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104a96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a99:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a9c:	83 c2 08             	add    $0x8,%edx
80104a9f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104aa3:	83 ec 0c             	sub    $0xc,%esp
80104aa6:	50                   	push   %eax
80104aa7:	e8 2d c7 ff ff       	call   801011d9 <fileclose>
80104aac:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104aaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ab2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ab5:	83 c2 08             	add    $0x8,%edx
80104ab8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104abf:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104ac0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104ac4:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104ac8:	7e bb                	jle    80104a85 <exit+0x32>
    }
  }

  begin_op();
80104aca:	e8 7f ec ff ff       	call   8010374e <begin_op>
  iput(curproc->cwd);
80104acf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ad2:	8b 40 68             	mov    0x68(%eax),%eax
80104ad5:	83 ec 0c             	sub    $0xc,%esp
80104ad8:	50                   	push   %eax
80104ad9:	e8 e4 d1 ff ff       	call   80101cc2 <iput>
80104ade:	83 c4 10             	add    $0x10,%esp
  end_op();
80104ae1:	e8 f8 ec ff ff       	call   801037de <end_op>
  curproc->cwd = 0;
80104ae6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ae9:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104af0:	83 ec 0c             	sub    $0xc,%esp
80104af3:	68 c0 4d 11 80       	push   $0x80114dc0
80104af8:	e8 1a 08 00 00       	call   80105317 <acquire>
80104afd:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104b00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b03:	8b 40 14             	mov    0x14(%eax),%eax
80104b06:	83 ec 0c             	sub    $0xc,%esp
80104b09:	50                   	push   %eax
80104b0a:	e8 41 04 00 00       	call   80104f50 <wakeup1>
80104b0f:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b12:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104b19:	eb 3a                	jmp    80104b55 <exit+0x102>
    if(p->parent == curproc){
80104b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1e:	8b 40 14             	mov    0x14(%eax),%eax
80104b21:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b24:	75 28                	jne    80104b4e <exit+0xfb>
      p->parent = initproc;
80104b26:	8b 15 40 c6 10 80    	mov    0x8010c640,%edx
80104b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2f:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b35:	8b 40 0c             	mov    0xc(%eax),%eax
80104b38:	83 f8 05             	cmp    $0x5,%eax
80104b3b:	75 11                	jne    80104b4e <exit+0xfb>
        wakeup1(initproc);
80104b3d:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104b42:	83 ec 0c             	sub    $0xc,%esp
80104b45:	50                   	push   %eax
80104b46:	e8 05 04 00 00       	call   80104f50 <wakeup1>
80104b4b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b4e:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104b55:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104b5c:	72 bd                	jb     80104b1b <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104b5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b61:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b68:	e8 f3 01 00 00       	call   80104d60 <sched>
  panic("zombie exit");
80104b6d:	83 ec 0c             	sub    $0xc,%esp
80104b70:	68 53 96 10 80       	push   $0x80109653
80104b75:	e8 8e ba ff ff       	call   80100608 <panic>

80104b7a <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b7a:	f3 0f 1e fb          	endbr32 
80104b7e:	55                   	push   %ebp
80104b7f:	89 e5                	mov    %esp,%ebp
80104b81:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b84:	e8 84 f9 ff ff       	call   8010450d <myproc>
80104b89:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b8c:	83 ec 0c             	sub    $0xc,%esp
80104b8f:	68 c0 4d 11 80       	push   $0x80114dc0
80104b94:	e8 7e 07 00 00       	call   80105317 <acquire>
80104b99:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b9c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ba3:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104baa:	e9 a4 00 00 00       	jmp    80104c53 <wait+0xd9>
      if(p->parent != curproc)
80104baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb2:	8b 40 14             	mov    0x14(%eax),%eax
80104bb5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104bb8:	0f 85 8d 00 00 00    	jne    80104c4b <wait+0xd1>
        continue;
      havekids = 1;
80104bbe:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc8:	8b 40 0c             	mov    0xc(%eax),%eax
80104bcb:	83 f8 05             	cmp    $0x5,%eax
80104bce:	75 7c                	jne    80104c4c <wait+0xd2>
        // Found one.
        pid = p->pid;
80104bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd3:	8b 40 10             	mov    0x10(%eax),%eax
80104bd6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bdc:	8b 40 08             	mov    0x8(%eax),%eax
80104bdf:	83 ec 0c             	sub    $0xc,%esp
80104be2:	50                   	push   %eax
80104be3:	e8 c3 e1 ff ff       	call   80102dab <kfree>
80104be8:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf8:	8b 40 04             	mov    0x4(%eax),%eax
80104bfb:	83 ec 0c             	sub    $0xc,%esp
80104bfe:	50                   	push   %eax
80104bff:	e8 89 3a 00 00       	call   8010868d <freevm>
80104c04:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c14:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1e:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c25:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104c36:	83 ec 0c             	sub    $0xc,%esp
80104c39:	68 c0 4d 11 80       	push   $0x80114dc0
80104c3e:	e8 46 07 00 00       	call   80105389 <release>
80104c43:	83 c4 10             	add    $0x10,%esp
        return pid;
80104c46:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c49:	eb 54                	jmp    80104c9f <wait+0x125>
        continue;
80104c4b:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c4c:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104c53:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104c5a:	0f 82 4f ff ff ff    	jb     80104baf <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c60:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c64:	74 0a                	je     80104c70 <wait+0xf6>
80104c66:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c69:	8b 40 24             	mov    0x24(%eax),%eax
80104c6c:	85 c0                	test   %eax,%eax
80104c6e:	74 17                	je     80104c87 <wait+0x10d>
      release(&ptable.lock);
80104c70:	83 ec 0c             	sub    $0xc,%esp
80104c73:	68 c0 4d 11 80       	push   $0x80114dc0
80104c78:	e8 0c 07 00 00       	call   80105389 <release>
80104c7d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c85:	eb 18                	jmp    80104c9f <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c87:	83 ec 08             	sub    $0x8,%esp
80104c8a:	68 c0 4d 11 80       	push   $0x80114dc0
80104c8f:	ff 75 ec             	pushl  -0x14(%ebp)
80104c92:	e8 0e 02 00 00       	call   80104ea5 <sleep>
80104c97:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104c9a:	e9 fd fe ff ff       	jmp    80104b9c <wait+0x22>
  }
}
80104c9f:	c9                   	leave  
80104ca0:	c3                   	ret    

80104ca1 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104ca1:	f3 0f 1e fb          	endbr32 
80104ca5:	55                   	push   %ebp
80104ca6:	89 e5                	mov    %esp,%ebp
80104ca8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104cab:	e8 e1 f7 ff ff       	call   80104491 <mycpu>
80104cb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cb6:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104cbd:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104cc0:	e8 84 f7 ff ff       	call   80104449 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104cc5:	83 ec 0c             	sub    $0xc,%esp
80104cc8:	68 c0 4d 11 80       	push   $0x80114dc0
80104ccd:	e8 45 06 00 00       	call   80105317 <acquire>
80104cd2:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cd5:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104cdc:	eb 64                	jmp    80104d42 <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ce4:	83 f8 03             	cmp    $0x3,%eax
80104ce7:	75 51                	jne    80104d3a <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cef:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104cf5:	83 ec 0c             	sub    $0xc,%esp
80104cf8:	ff 75 f4             	pushl  -0xc(%ebp)
80104cfb:	e8 d2 34 00 00       	call   801081d2 <switchuvm>
80104d00:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d06:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d10:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d13:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d16:	83 c2 04             	add    $0x4,%edx
80104d19:	83 ec 08             	sub    $0x8,%esp
80104d1c:	50                   	push   %eax
80104d1d:	52                   	push   %edx
80104d1e:	e8 27 0b 00 00       	call   8010584a <swtch>
80104d23:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104d26:	e8 8a 34 00 00       	call   801081b5 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104d2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d2e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104d35:	00 00 00 
80104d38:	eb 01                	jmp    80104d3b <scheduler+0x9a>
        continue;
80104d3a:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d3b:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104d42:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104d49:	72 93                	jb     80104cde <scheduler+0x3d>
    }
    release(&ptable.lock);
80104d4b:	83 ec 0c             	sub    $0xc,%esp
80104d4e:	68 c0 4d 11 80       	push   $0x80114dc0
80104d53:	e8 31 06 00 00       	call   80105389 <release>
80104d58:	83 c4 10             	add    $0x10,%esp
    sti();
80104d5b:	e9 60 ff ff ff       	jmp    80104cc0 <scheduler+0x1f>

80104d60 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104d60:	f3 0f 1e fb          	endbr32 
80104d64:	55                   	push   %ebp
80104d65:	89 e5                	mov    %esp,%ebp
80104d67:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104d6a:	e8 9e f7 ff ff       	call   8010450d <myproc>
80104d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104d72:	83 ec 0c             	sub    $0xc,%esp
80104d75:	68 c0 4d 11 80       	push   $0x80114dc0
80104d7a:	e8 df 06 00 00       	call   8010545e <holding>
80104d7f:	83 c4 10             	add    $0x10,%esp
80104d82:	85 c0                	test   %eax,%eax
80104d84:	75 0d                	jne    80104d93 <sched+0x33>
    panic("sched ptable.lock");
80104d86:	83 ec 0c             	sub    $0xc,%esp
80104d89:	68 5f 96 10 80       	push   $0x8010965f
80104d8e:	e8 75 b8 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104d93:	e8 f9 f6 ff ff       	call   80104491 <mycpu>
80104d98:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d9e:	83 f8 01             	cmp    $0x1,%eax
80104da1:	74 0d                	je     80104db0 <sched+0x50>
    panic("sched locks");
80104da3:	83 ec 0c             	sub    $0xc,%esp
80104da6:	68 71 96 10 80       	push   $0x80109671
80104dab:	e8 58 b8 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db3:	8b 40 0c             	mov    0xc(%eax),%eax
80104db6:	83 f8 04             	cmp    $0x4,%eax
80104db9:	75 0d                	jne    80104dc8 <sched+0x68>
    panic("sched running");
80104dbb:	83 ec 0c             	sub    $0xc,%esp
80104dbe:	68 7d 96 10 80       	push   $0x8010967d
80104dc3:	e8 40 b8 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104dc8:	e8 6c f6 ff ff       	call   80104439 <readeflags>
80104dcd:	25 00 02 00 00       	and    $0x200,%eax
80104dd2:	85 c0                	test   %eax,%eax
80104dd4:	74 0d                	je     80104de3 <sched+0x83>
    panic("sched interruptible");
80104dd6:	83 ec 0c             	sub    $0xc,%esp
80104dd9:	68 8b 96 10 80       	push   $0x8010968b
80104dde:	e8 25 b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104de3:	e8 a9 f6 ff ff       	call   80104491 <mycpu>
80104de8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104dee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104df1:	e8 9b f6 ff ff       	call   80104491 <mycpu>
80104df6:	8b 40 04             	mov    0x4(%eax),%eax
80104df9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dfc:	83 c2 1c             	add    $0x1c,%edx
80104dff:	83 ec 08             	sub    $0x8,%esp
80104e02:	50                   	push   %eax
80104e03:	52                   	push   %edx
80104e04:	e8 41 0a 00 00       	call   8010584a <swtch>
80104e09:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104e0c:	e8 80 f6 ff ff       	call   80104491 <mycpu>
80104e11:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e14:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104e1a:	90                   	nop
80104e1b:	c9                   	leave  
80104e1c:	c3                   	ret    

80104e1d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104e1d:	f3 0f 1e fb          	endbr32 
80104e21:	55                   	push   %ebp
80104e22:	89 e5                	mov    %esp,%ebp
80104e24:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104e27:	83 ec 0c             	sub    $0xc,%esp
80104e2a:	68 c0 4d 11 80       	push   $0x80114dc0
80104e2f:	e8 e3 04 00 00       	call   80105317 <acquire>
80104e34:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104e37:	e8 d1 f6 ff ff       	call   8010450d <myproc>
80104e3c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e43:	e8 18 ff ff ff       	call   80104d60 <sched>
  release(&ptable.lock);
80104e48:	83 ec 0c             	sub    $0xc,%esp
80104e4b:	68 c0 4d 11 80       	push   $0x80114dc0
80104e50:	e8 34 05 00 00       	call   80105389 <release>
80104e55:	83 c4 10             	add    $0x10,%esp
}
80104e58:	90                   	nop
80104e59:	c9                   	leave  
80104e5a:	c3                   	ret    

80104e5b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e5b:	f3 0f 1e fb          	endbr32 
80104e5f:	55                   	push   %ebp
80104e60:	89 e5                	mov    %esp,%ebp
80104e62:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e65:	83 ec 0c             	sub    $0xc,%esp
80104e68:	68 c0 4d 11 80       	push   $0x80114dc0
80104e6d:	e8 17 05 00 00       	call   80105389 <release>
80104e72:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104e75:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104e7a:	85 c0                	test   %eax,%eax
80104e7c:	74 24                	je     80104ea2 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e7e:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104e85:	00 00 00 
    iinit(ROOTDEV);
80104e88:	83 ec 0c             	sub    $0xc,%esp
80104e8b:	6a 01                	push   $0x1
80104e8d:	e8 41 c9 ff ff       	call   801017d3 <iinit>
80104e92:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104e95:	83 ec 0c             	sub    $0xc,%esp
80104e98:	6a 01                	push   $0x1
80104e9a:	e8 7c e6 ff ff       	call   8010351b <initlog>
80104e9f:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104ea2:	90                   	nop
80104ea3:	c9                   	leave  
80104ea4:	c3                   	ret    

80104ea5 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104ea5:	f3 0f 1e fb          	endbr32 
80104ea9:	55                   	push   %ebp
80104eaa:	89 e5                	mov    %esp,%ebp
80104eac:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104eaf:	e8 59 f6 ff ff       	call   8010450d <myproc>
80104eb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104eb7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ebb:	75 0d                	jne    80104eca <sleep+0x25>
    panic("sleep");
80104ebd:	83 ec 0c             	sub    $0xc,%esp
80104ec0:	68 9f 96 10 80       	push   $0x8010969f
80104ec5:	e8 3e b7 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104eca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ece:	75 0d                	jne    80104edd <sleep+0x38>
    panic("sleep without lk");
80104ed0:	83 ec 0c             	sub    $0xc,%esp
80104ed3:	68 a5 96 10 80       	push   $0x801096a5
80104ed8:	e8 2b b7 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104edd:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104ee4:	74 1e                	je     80104f04 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ee6:	83 ec 0c             	sub    $0xc,%esp
80104ee9:	68 c0 4d 11 80       	push   $0x80114dc0
80104eee:	e8 24 04 00 00       	call   80105317 <acquire>
80104ef3:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104ef6:	83 ec 0c             	sub    $0xc,%esp
80104ef9:	ff 75 0c             	pushl  0xc(%ebp)
80104efc:	e8 88 04 00 00       	call   80105389 <release>
80104f01:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f07:	8b 55 08             	mov    0x8(%ebp),%edx
80104f0a:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f10:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104f17:	e8 44 fe ff ff       	call   80104d60 <sched>

  // Tidy up.
  p->chan = 0;
80104f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1f:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104f26:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104f2d:	74 1e                	je     80104f4d <sleep+0xa8>
    release(&ptable.lock);
80104f2f:	83 ec 0c             	sub    $0xc,%esp
80104f32:	68 c0 4d 11 80       	push   $0x80114dc0
80104f37:	e8 4d 04 00 00       	call   80105389 <release>
80104f3c:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104f3f:	83 ec 0c             	sub    $0xc,%esp
80104f42:	ff 75 0c             	pushl  0xc(%ebp)
80104f45:	e8 cd 03 00 00       	call   80105317 <acquire>
80104f4a:	83 c4 10             	add    $0x10,%esp
  }
}
80104f4d:	90                   	nop
80104f4e:	c9                   	leave  
80104f4f:	c3                   	ret    

80104f50 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f50:	f3 0f 1e fb          	endbr32 
80104f54:	55                   	push   %ebp
80104f55:	89 e5                	mov    %esp,%ebp
80104f57:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f5a:	c7 45 fc f4 4d 11 80 	movl   $0x80114df4,-0x4(%ebp)
80104f61:	eb 27                	jmp    80104f8a <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104f63:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f66:	8b 40 0c             	mov    0xc(%eax),%eax
80104f69:	83 f8 02             	cmp    $0x2,%eax
80104f6c:	75 15                	jne    80104f83 <wakeup1+0x33>
80104f6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f71:	8b 40 20             	mov    0x20(%eax),%eax
80104f74:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f77:	75 0a                	jne    80104f83 <wakeup1+0x33>
      p->state = RUNNABLE;
80104f79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f7c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f83:	81 45 fc a4 00 00 00 	addl   $0xa4,-0x4(%ebp)
80104f8a:	81 7d fc f4 76 11 80 	cmpl   $0x801176f4,-0x4(%ebp)
80104f91:	72 d0                	jb     80104f63 <wakeup1+0x13>
}
80104f93:	90                   	nop
80104f94:	90                   	nop
80104f95:	c9                   	leave  
80104f96:	c3                   	ret    

80104f97 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f97:	f3 0f 1e fb          	endbr32 
80104f9b:	55                   	push   %ebp
80104f9c:	89 e5                	mov    %esp,%ebp
80104f9e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104fa1:	83 ec 0c             	sub    $0xc,%esp
80104fa4:	68 c0 4d 11 80       	push   $0x80114dc0
80104fa9:	e8 69 03 00 00       	call   80105317 <acquire>
80104fae:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104fb1:	83 ec 0c             	sub    $0xc,%esp
80104fb4:	ff 75 08             	pushl  0x8(%ebp)
80104fb7:	e8 94 ff ff ff       	call   80104f50 <wakeup1>
80104fbc:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104fbf:	83 ec 0c             	sub    $0xc,%esp
80104fc2:	68 c0 4d 11 80       	push   $0x80114dc0
80104fc7:	e8 bd 03 00 00       	call   80105389 <release>
80104fcc:	83 c4 10             	add    $0x10,%esp
}
80104fcf:	90                   	nop
80104fd0:	c9                   	leave  
80104fd1:	c3                   	ret    

80104fd2 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104fd2:	f3 0f 1e fb          	endbr32 
80104fd6:	55                   	push   %ebp
80104fd7:	89 e5                	mov    %esp,%ebp
80104fd9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104fdc:	83 ec 0c             	sub    $0xc,%esp
80104fdf:	68 c0 4d 11 80       	push   $0x80114dc0
80104fe4:	e8 2e 03 00 00       	call   80105317 <acquire>
80104fe9:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fec:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104ff3:	eb 48                	jmp    8010503d <kill+0x6b>
    if(p->pid == pid){
80104ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff8:	8b 40 10             	mov    0x10(%eax),%eax
80104ffb:	39 45 08             	cmp    %eax,0x8(%ebp)
80104ffe:	75 36                	jne    80105036 <kill+0x64>
      p->killed = 1;
80105000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105003:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010500a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500d:	8b 40 0c             	mov    0xc(%eax),%eax
80105010:	83 f8 02             	cmp    $0x2,%eax
80105013:	75 0a                	jne    8010501f <kill+0x4d>
        p->state = RUNNABLE;
80105015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105018:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010501f:	83 ec 0c             	sub    $0xc,%esp
80105022:	68 c0 4d 11 80       	push   $0x80114dc0
80105027:	e8 5d 03 00 00       	call   80105389 <release>
8010502c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010502f:	b8 00 00 00 00       	mov    $0x0,%eax
80105034:	eb 25                	jmp    8010505b <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105036:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
8010503d:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80105044:	72 af                	jb     80104ff5 <kill+0x23>
    }
  }
  release(&ptable.lock);
80105046:	83 ec 0c             	sub    $0xc,%esp
80105049:	68 c0 4d 11 80       	push   $0x80114dc0
8010504e:	e8 36 03 00 00       	call   80105389 <release>
80105053:	83 c4 10             	add    $0x10,%esp
  return -1;
80105056:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010505b:	c9                   	leave  
8010505c:	c3                   	ret    

8010505d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010505d:	f3 0f 1e fb          	endbr32 
80105061:	55                   	push   %ebp
80105062:	89 e5                	mov    %esp,%ebp
80105064:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105067:	c7 45 f0 f4 4d 11 80 	movl   $0x80114df4,-0x10(%ebp)
8010506e:	e9 da 00 00 00       	jmp    8010514d <procdump+0xf0>
    if(p->state == UNUSED)
80105073:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105076:	8b 40 0c             	mov    0xc(%eax),%eax
80105079:	85 c0                	test   %eax,%eax
8010507b:	0f 84 c4 00 00 00    	je     80105145 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105081:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105084:	8b 40 0c             	mov    0xc(%eax),%eax
80105087:	83 f8 05             	cmp    $0x5,%eax
8010508a:	77 23                	ja     801050af <procdump+0x52>
8010508c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010508f:	8b 40 0c             	mov    0xc(%eax),%eax
80105092:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105099:	85 c0                	test   %eax,%eax
8010509b:	74 12                	je     801050af <procdump+0x52>
      state = states[p->state];
8010509d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a0:	8b 40 0c             	mov    0xc(%eax),%eax
801050a3:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801050aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
801050ad:	eb 07                	jmp    801050b6 <procdump+0x59>
    else
      state = "???";
801050af:	c7 45 ec b6 96 10 80 	movl   $0x801096b6,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801050b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050b9:	8d 50 6c             	lea    0x6c(%eax),%edx
801050bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050bf:	8b 40 10             	mov    0x10(%eax),%eax
801050c2:	52                   	push   %edx
801050c3:	ff 75 ec             	pushl  -0x14(%ebp)
801050c6:	50                   	push   %eax
801050c7:	68 ba 96 10 80       	push   $0x801096ba
801050cc:	e8 47 b3 ff ff       	call   80100418 <cprintf>
801050d1:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801050d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d7:	8b 40 0c             	mov    0xc(%eax),%eax
801050da:	83 f8 02             	cmp    $0x2,%eax
801050dd:	75 54                	jne    80105133 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801050df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050e2:	8b 40 1c             	mov    0x1c(%eax),%eax
801050e5:	8b 40 0c             	mov    0xc(%eax),%eax
801050e8:	83 c0 08             	add    $0x8,%eax
801050eb:	89 c2                	mov    %eax,%edx
801050ed:	83 ec 08             	sub    $0x8,%esp
801050f0:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801050f3:	50                   	push   %eax
801050f4:	52                   	push   %edx
801050f5:	e8 e5 02 00 00       	call   801053df <getcallerpcs>
801050fa:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105104:	eb 1c                	jmp    80105122 <procdump+0xc5>
        cprintf(" %p", pc[i]);
80105106:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105109:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010510d:	83 ec 08             	sub    $0x8,%esp
80105110:	50                   	push   %eax
80105111:	68 c3 96 10 80       	push   $0x801096c3
80105116:	e8 fd b2 ff ff       	call   80100418 <cprintf>
8010511b:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010511e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105122:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105126:	7f 0b                	jg     80105133 <procdump+0xd6>
80105128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010512f:	85 c0                	test   %eax,%eax
80105131:	75 d3                	jne    80105106 <procdump+0xa9>
    }
    cprintf("\n");
80105133:	83 ec 0c             	sub    $0xc,%esp
80105136:	68 c7 96 10 80       	push   $0x801096c7
8010513b:	e8 d8 b2 ff ff       	call   80100418 <cprintf>
80105140:	83 c4 10             	add    $0x10,%esp
80105143:	eb 01                	jmp    80105146 <procdump+0xe9>
      continue;
80105145:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105146:	81 45 f0 a4 00 00 00 	addl   $0xa4,-0x10(%ebp)
8010514d:	81 7d f0 f4 76 11 80 	cmpl   $0x801176f4,-0x10(%ebp)
80105154:	0f 82 19 ff ff ff    	jb     80105073 <procdump+0x16>
  }
}
8010515a:	90                   	nop
8010515b:	90                   	nop
8010515c:	c9                   	leave  
8010515d:	c3                   	ret    

8010515e <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010515e:	f3 0f 1e fb          	endbr32 
80105162:	55                   	push   %ebp
80105163:	89 e5                	mov    %esp,%ebp
80105165:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105168:	8b 45 08             	mov    0x8(%ebp),%eax
8010516b:	83 c0 04             	add    $0x4,%eax
8010516e:	83 ec 08             	sub    $0x8,%esp
80105171:	68 f3 96 10 80       	push   $0x801096f3
80105176:	50                   	push   %eax
80105177:	e8 75 01 00 00       	call   801052f1 <initlock>
8010517c:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010517f:	8b 45 08             	mov    0x8(%ebp),%eax
80105182:	8b 55 0c             	mov    0xc(%ebp),%edx
80105185:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105188:	8b 45 08             	mov    0x8(%ebp),%eax
8010518b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105191:	8b 45 08             	mov    0x8(%ebp),%eax
80105194:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010519b:	90                   	nop
8010519c:	c9                   	leave  
8010519d:	c3                   	ret    

8010519e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010519e:	f3 0f 1e fb          	endbr32 
801051a2:	55                   	push   %ebp
801051a3:	89 e5                	mov    %esp,%ebp
801051a5:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801051a8:	8b 45 08             	mov    0x8(%ebp),%eax
801051ab:	83 c0 04             	add    $0x4,%eax
801051ae:	83 ec 0c             	sub    $0xc,%esp
801051b1:	50                   	push   %eax
801051b2:	e8 60 01 00 00       	call   80105317 <acquire>
801051b7:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801051ba:	eb 15                	jmp    801051d1 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801051bc:	8b 45 08             	mov    0x8(%ebp),%eax
801051bf:	83 c0 04             	add    $0x4,%eax
801051c2:	83 ec 08             	sub    $0x8,%esp
801051c5:	50                   	push   %eax
801051c6:	ff 75 08             	pushl  0x8(%ebp)
801051c9:	e8 d7 fc ff ff       	call   80104ea5 <sleep>
801051ce:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801051d1:	8b 45 08             	mov    0x8(%ebp),%eax
801051d4:	8b 00                	mov    (%eax),%eax
801051d6:	85 c0                	test   %eax,%eax
801051d8:	75 e2                	jne    801051bc <acquiresleep+0x1e>
  }
  lk->locked = 1;
801051da:	8b 45 08             	mov    0x8(%ebp),%eax
801051dd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801051e3:	e8 25 f3 ff ff       	call   8010450d <myproc>
801051e8:	8b 50 10             	mov    0x10(%eax),%edx
801051eb:	8b 45 08             	mov    0x8(%ebp),%eax
801051ee:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801051f1:	8b 45 08             	mov    0x8(%ebp),%eax
801051f4:	83 c0 04             	add    $0x4,%eax
801051f7:	83 ec 0c             	sub    $0xc,%esp
801051fa:	50                   	push   %eax
801051fb:	e8 89 01 00 00       	call   80105389 <release>
80105200:	83 c4 10             	add    $0x10,%esp
}
80105203:	90                   	nop
80105204:	c9                   	leave  
80105205:	c3                   	ret    

80105206 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105206:	f3 0f 1e fb          	endbr32 
8010520a:	55                   	push   %ebp
8010520b:	89 e5                	mov    %esp,%ebp
8010520d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105210:	8b 45 08             	mov    0x8(%ebp),%eax
80105213:	83 c0 04             	add    $0x4,%eax
80105216:	83 ec 0c             	sub    $0xc,%esp
80105219:	50                   	push   %eax
8010521a:	e8 f8 00 00 00       	call   80105317 <acquire>
8010521f:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105222:	8b 45 08             	mov    0x8(%ebp),%eax
80105225:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010522b:	8b 45 08             	mov    0x8(%ebp),%eax
8010522e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105235:	83 ec 0c             	sub    $0xc,%esp
80105238:	ff 75 08             	pushl  0x8(%ebp)
8010523b:	e8 57 fd ff ff       	call   80104f97 <wakeup>
80105240:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105243:	8b 45 08             	mov    0x8(%ebp),%eax
80105246:	83 c0 04             	add    $0x4,%eax
80105249:	83 ec 0c             	sub    $0xc,%esp
8010524c:	50                   	push   %eax
8010524d:	e8 37 01 00 00       	call   80105389 <release>
80105252:	83 c4 10             	add    $0x10,%esp
}
80105255:	90                   	nop
80105256:	c9                   	leave  
80105257:	c3                   	ret    

80105258 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105258:	f3 0f 1e fb          	endbr32 
8010525c:	55                   	push   %ebp
8010525d:	89 e5                	mov    %esp,%ebp
8010525f:	53                   	push   %ebx
80105260:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
80105263:	8b 45 08             	mov    0x8(%ebp),%eax
80105266:	83 c0 04             	add    $0x4,%eax
80105269:	83 ec 0c             	sub    $0xc,%esp
8010526c:	50                   	push   %eax
8010526d:	e8 a5 00 00 00       	call   80105317 <acquire>
80105272:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
80105275:	8b 45 08             	mov    0x8(%ebp),%eax
80105278:	8b 00                	mov    (%eax),%eax
8010527a:	85 c0                	test   %eax,%eax
8010527c:	74 19                	je     80105297 <holdingsleep+0x3f>
8010527e:	8b 45 08             	mov    0x8(%ebp),%eax
80105281:	8b 58 3c             	mov    0x3c(%eax),%ebx
80105284:	e8 84 f2 ff ff       	call   8010450d <myproc>
80105289:	8b 40 10             	mov    0x10(%eax),%eax
8010528c:	39 c3                	cmp    %eax,%ebx
8010528e:	75 07                	jne    80105297 <holdingsleep+0x3f>
80105290:	b8 01 00 00 00       	mov    $0x1,%eax
80105295:	eb 05                	jmp    8010529c <holdingsleep+0x44>
80105297:	b8 00 00 00 00       	mov    $0x0,%eax
8010529c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010529f:	8b 45 08             	mov    0x8(%ebp),%eax
801052a2:	83 c0 04             	add    $0x4,%eax
801052a5:	83 ec 0c             	sub    $0xc,%esp
801052a8:	50                   	push   %eax
801052a9:	e8 db 00 00 00       	call   80105389 <release>
801052ae:	83 c4 10             	add    $0x10,%esp
  return r;
801052b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052b7:	c9                   	leave  
801052b8:	c3                   	ret    

801052b9 <readeflags>:
{
801052b9:	55                   	push   %ebp
801052ba:	89 e5                	mov    %esp,%ebp
801052bc:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801052bf:	9c                   	pushf  
801052c0:	58                   	pop    %eax
801052c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801052c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052c7:	c9                   	leave  
801052c8:	c3                   	ret    

801052c9 <cli>:
{
801052c9:	55                   	push   %ebp
801052ca:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801052cc:	fa                   	cli    
}
801052cd:	90                   	nop
801052ce:	5d                   	pop    %ebp
801052cf:	c3                   	ret    

801052d0 <sti>:
{
801052d0:	55                   	push   %ebp
801052d1:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801052d3:	fb                   	sti    
}
801052d4:	90                   	nop
801052d5:	5d                   	pop    %ebp
801052d6:	c3                   	ret    

801052d7 <xchg>:
{
801052d7:	55                   	push   %ebp
801052d8:	89 e5                	mov    %esp,%ebp
801052da:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801052dd:	8b 55 08             	mov    0x8(%ebp),%edx
801052e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052e6:	f0 87 02             	lock xchg %eax,(%edx)
801052e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801052ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052ef:	c9                   	leave  
801052f0:	c3                   	ret    

801052f1 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801052f1:	f3 0f 1e fb          	endbr32 
801052f5:	55                   	push   %ebp
801052f6:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052f8:	8b 45 08             	mov    0x8(%ebp),%eax
801052fb:	8b 55 0c             	mov    0xc(%ebp),%edx
801052fe:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105301:	8b 45 08             	mov    0x8(%ebp),%eax
80105304:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010530a:	8b 45 08             	mov    0x8(%ebp),%eax
8010530d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105314:	90                   	nop
80105315:	5d                   	pop    %ebp
80105316:	c3                   	ret    

80105317 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105317:	f3 0f 1e fb          	endbr32 
8010531b:	55                   	push   %ebp
8010531c:	89 e5                	mov    %esp,%ebp
8010531e:	53                   	push   %ebx
8010531f:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105322:	e8 7c 01 00 00       	call   801054a3 <pushcli>
  if(holding(lk))
80105327:	8b 45 08             	mov    0x8(%ebp),%eax
8010532a:	83 ec 0c             	sub    $0xc,%esp
8010532d:	50                   	push   %eax
8010532e:	e8 2b 01 00 00       	call   8010545e <holding>
80105333:	83 c4 10             	add    $0x10,%esp
80105336:	85 c0                	test   %eax,%eax
80105338:	74 0d                	je     80105347 <acquire+0x30>
    panic("acquire");
8010533a:	83 ec 0c             	sub    $0xc,%esp
8010533d:	68 fe 96 10 80       	push   $0x801096fe
80105342:	e8 c1 b2 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105347:	90                   	nop
80105348:	8b 45 08             	mov    0x8(%ebp),%eax
8010534b:	83 ec 08             	sub    $0x8,%esp
8010534e:	6a 01                	push   $0x1
80105350:	50                   	push   %eax
80105351:	e8 81 ff ff ff       	call   801052d7 <xchg>
80105356:	83 c4 10             	add    $0x10,%esp
80105359:	85 c0                	test   %eax,%eax
8010535b:	75 eb                	jne    80105348 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010535d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105362:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105365:	e8 27 f1 ff ff       	call   80104491 <mycpu>
8010536a:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010536d:	8b 45 08             	mov    0x8(%ebp),%eax
80105370:	83 c0 0c             	add    $0xc,%eax
80105373:	83 ec 08             	sub    $0x8,%esp
80105376:	50                   	push   %eax
80105377:	8d 45 08             	lea    0x8(%ebp),%eax
8010537a:	50                   	push   %eax
8010537b:	e8 5f 00 00 00       	call   801053df <getcallerpcs>
80105380:	83 c4 10             	add    $0x10,%esp
}
80105383:	90                   	nop
80105384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105387:	c9                   	leave  
80105388:	c3                   	ret    

80105389 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105389:	f3 0f 1e fb          	endbr32 
8010538d:	55                   	push   %ebp
8010538e:	89 e5                	mov    %esp,%ebp
80105390:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105393:	83 ec 0c             	sub    $0xc,%esp
80105396:	ff 75 08             	pushl  0x8(%ebp)
80105399:	e8 c0 00 00 00       	call   8010545e <holding>
8010539e:	83 c4 10             	add    $0x10,%esp
801053a1:	85 c0                	test   %eax,%eax
801053a3:	75 0d                	jne    801053b2 <release+0x29>
    panic("release");
801053a5:	83 ec 0c             	sub    $0xc,%esp
801053a8:	68 06 97 10 80       	push   $0x80109706
801053ad:	e8 56 b2 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
801053b2:	8b 45 08             	mov    0x8(%ebp),%eax
801053b5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801053bc:	8b 45 08             	mov    0x8(%ebp),%eax
801053bf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801053c6:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801053cb:	8b 45 08             	mov    0x8(%ebp),%eax
801053ce:	8b 55 08             	mov    0x8(%ebp),%edx
801053d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801053d7:	e8 18 01 00 00       	call   801054f4 <popcli>
}
801053dc:	90                   	nop
801053dd:	c9                   	leave  
801053de:	c3                   	ret    

801053df <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801053df:	f3 0f 1e fb          	endbr32 
801053e3:	55                   	push   %ebp
801053e4:	89 e5                	mov    %esp,%ebp
801053e6:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801053e9:	8b 45 08             	mov    0x8(%ebp),%eax
801053ec:	83 e8 08             	sub    $0x8,%eax
801053ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053f2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801053f9:	eb 38                	jmp    80105433 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053fb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053ff:	74 53                	je     80105454 <getcallerpcs+0x75>
80105401:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105408:	76 4a                	jbe    80105454 <getcallerpcs+0x75>
8010540a:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010540e:	74 44                	je     80105454 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105410:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105413:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010541a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010541d:	01 c2                	add    %eax,%edx
8010541f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105422:	8b 40 04             	mov    0x4(%eax),%eax
80105425:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105427:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010542a:	8b 00                	mov    (%eax),%eax
8010542c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010542f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105433:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105437:	7e c2                	jle    801053fb <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80105439:	eb 19                	jmp    80105454 <getcallerpcs+0x75>
    pcs[i] = 0;
8010543b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010543e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105445:	8b 45 0c             	mov    0xc(%ebp),%eax
80105448:	01 d0                	add    %edx,%eax
8010544a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105450:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105454:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105458:	7e e1                	jle    8010543b <getcallerpcs+0x5c>
}
8010545a:	90                   	nop
8010545b:	90                   	nop
8010545c:	c9                   	leave  
8010545d:	c3                   	ret    

8010545e <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010545e:	f3 0f 1e fb          	endbr32 
80105462:	55                   	push   %ebp
80105463:	89 e5                	mov    %esp,%ebp
80105465:	53                   	push   %ebx
80105466:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
80105469:	e8 35 00 00 00       	call   801054a3 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010546e:	8b 45 08             	mov    0x8(%ebp),%eax
80105471:	8b 00                	mov    (%eax),%eax
80105473:	85 c0                	test   %eax,%eax
80105475:	74 16                	je     8010548d <holding+0x2f>
80105477:	8b 45 08             	mov    0x8(%ebp),%eax
8010547a:	8b 58 08             	mov    0x8(%eax),%ebx
8010547d:	e8 0f f0 ff ff       	call   80104491 <mycpu>
80105482:	39 c3                	cmp    %eax,%ebx
80105484:	75 07                	jne    8010548d <holding+0x2f>
80105486:	b8 01 00 00 00       	mov    $0x1,%eax
8010548b:	eb 05                	jmp    80105492 <holding+0x34>
8010548d:	b8 00 00 00 00       	mov    $0x0,%eax
80105492:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
80105495:	e8 5a 00 00 00       	call   801054f4 <popcli>
  return r;
8010549a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010549d:	83 c4 14             	add    $0x14,%esp
801054a0:	5b                   	pop    %ebx
801054a1:	5d                   	pop    %ebp
801054a2:	c3                   	ret    

801054a3 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801054a3:	f3 0f 1e fb          	endbr32 
801054a7:	55                   	push   %ebp
801054a8:	89 e5                	mov    %esp,%ebp
801054aa:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801054ad:	e8 07 fe ff ff       	call   801052b9 <readeflags>
801054b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801054b5:	e8 0f fe ff ff       	call   801052c9 <cli>
  if(mycpu()->ncli == 0)
801054ba:	e8 d2 ef ff ff       	call   80104491 <mycpu>
801054bf:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054c5:	85 c0                	test   %eax,%eax
801054c7:	75 14                	jne    801054dd <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
801054c9:	e8 c3 ef ff ff       	call   80104491 <mycpu>
801054ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054d1:	81 e2 00 02 00 00    	and    $0x200,%edx
801054d7:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801054dd:	e8 af ef ff ff       	call   80104491 <mycpu>
801054e2:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054e8:	83 c2 01             	add    $0x1,%edx
801054eb:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801054f1:	90                   	nop
801054f2:	c9                   	leave  
801054f3:	c3                   	ret    

801054f4 <popcli>:

void
popcli(void)
{
801054f4:	f3 0f 1e fb          	endbr32 
801054f8:	55                   	push   %ebp
801054f9:	89 e5                	mov    %esp,%ebp
801054fb:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801054fe:	e8 b6 fd ff ff       	call   801052b9 <readeflags>
80105503:	25 00 02 00 00       	and    $0x200,%eax
80105508:	85 c0                	test   %eax,%eax
8010550a:	74 0d                	je     80105519 <popcli+0x25>
    panic("popcli - interruptible");
8010550c:	83 ec 0c             	sub    $0xc,%esp
8010550f:	68 0e 97 10 80       	push   $0x8010970e
80105514:	e8 ef b0 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
80105519:	e8 73 ef ff ff       	call   80104491 <mycpu>
8010551e:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105524:	83 ea 01             	sub    $0x1,%edx
80105527:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010552d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105533:	85 c0                	test   %eax,%eax
80105535:	79 0d                	jns    80105544 <popcli+0x50>
    panic("popcli");
80105537:	83 ec 0c             	sub    $0xc,%esp
8010553a:	68 25 97 10 80       	push   $0x80109725
8010553f:	e8 c4 b0 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105544:	e8 48 ef ff ff       	call   80104491 <mycpu>
80105549:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010554f:	85 c0                	test   %eax,%eax
80105551:	75 14                	jne    80105567 <popcli+0x73>
80105553:	e8 39 ef ff ff       	call   80104491 <mycpu>
80105558:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010555e:	85 c0                	test   %eax,%eax
80105560:	74 05                	je     80105567 <popcli+0x73>
    sti();
80105562:	e8 69 fd ff ff       	call   801052d0 <sti>
}
80105567:	90                   	nop
80105568:	c9                   	leave  
80105569:	c3                   	ret    

8010556a <stosb>:
{
8010556a:	55                   	push   %ebp
8010556b:	89 e5                	mov    %esp,%ebp
8010556d:	57                   	push   %edi
8010556e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010556f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105572:	8b 55 10             	mov    0x10(%ebp),%edx
80105575:	8b 45 0c             	mov    0xc(%ebp),%eax
80105578:	89 cb                	mov    %ecx,%ebx
8010557a:	89 df                	mov    %ebx,%edi
8010557c:	89 d1                	mov    %edx,%ecx
8010557e:	fc                   	cld    
8010557f:	f3 aa                	rep stos %al,%es:(%edi)
80105581:	89 ca                	mov    %ecx,%edx
80105583:	89 fb                	mov    %edi,%ebx
80105585:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105588:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010558b:	90                   	nop
8010558c:	5b                   	pop    %ebx
8010558d:	5f                   	pop    %edi
8010558e:	5d                   	pop    %ebp
8010558f:	c3                   	ret    

80105590 <stosl>:
{
80105590:	55                   	push   %ebp
80105591:	89 e5                	mov    %esp,%ebp
80105593:	57                   	push   %edi
80105594:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105595:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105598:	8b 55 10             	mov    0x10(%ebp),%edx
8010559b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010559e:	89 cb                	mov    %ecx,%ebx
801055a0:	89 df                	mov    %ebx,%edi
801055a2:	89 d1                	mov    %edx,%ecx
801055a4:	fc                   	cld    
801055a5:	f3 ab                	rep stos %eax,%es:(%edi)
801055a7:	89 ca                	mov    %ecx,%edx
801055a9:	89 fb                	mov    %edi,%ebx
801055ab:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055ae:	89 55 10             	mov    %edx,0x10(%ebp)
}
801055b1:	90                   	nop
801055b2:	5b                   	pop    %ebx
801055b3:	5f                   	pop    %edi
801055b4:	5d                   	pop    %ebp
801055b5:	c3                   	ret    

801055b6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801055b6:	f3 0f 1e fb          	endbr32 
801055ba:	55                   	push   %ebp
801055bb:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801055bd:	8b 45 08             	mov    0x8(%ebp),%eax
801055c0:	83 e0 03             	and    $0x3,%eax
801055c3:	85 c0                	test   %eax,%eax
801055c5:	75 43                	jne    8010560a <memset+0x54>
801055c7:	8b 45 10             	mov    0x10(%ebp),%eax
801055ca:	83 e0 03             	and    $0x3,%eax
801055cd:	85 c0                	test   %eax,%eax
801055cf:	75 39                	jne    8010560a <memset+0x54>
    c &= 0xFF;
801055d1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801055d8:	8b 45 10             	mov    0x10(%ebp),%eax
801055db:	c1 e8 02             	shr    $0x2,%eax
801055de:	89 c1                	mov    %eax,%ecx
801055e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e3:	c1 e0 18             	shl    $0x18,%eax
801055e6:	89 c2                	mov    %eax,%edx
801055e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801055eb:	c1 e0 10             	shl    $0x10,%eax
801055ee:	09 c2                	or     %eax,%edx
801055f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f3:	c1 e0 08             	shl    $0x8,%eax
801055f6:	09 d0                	or     %edx,%eax
801055f8:	0b 45 0c             	or     0xc(%ebp),%eax
801055fb:	51                   	push   %ecx
801055fc:	50                   	push   %eax
801055fd:	ff 75 08             	pushl  0x8(%ebp)
80105600:	e8 8b ff ff ff       	call   80105590 <stosl>
80105605:	83 c4 0c             	add    $0xc,%esp
80105608:	eb 12                	jmp    8010561c <memset+0x66>
  } else
    stosb(dst, c, n);
8010560a:	8b 45 10             	mov    0x10(%ebp),%eax
8010560d:	50                   	push   %eax
8010560e:	ff 75 0c             	pushl  0xc(%ebp)
80105611:	ff 75 08             	pushl  0x8(%ebp)
80105614:	e8 51 ff ff ff       	call   8010556a <stosb>
80105619:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010561c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010561f:	c9                   	leave  
80105620:	c3                   	ret    

80105621 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105621:	f3 0f 1e fb          	endbr32 
80105625:	55                   	push   %ebp
80105626:	89 e5                	mov    %esp,%ebp
80105628:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010562b:	8b 45 08             	mov    0x8(%ebp),%eax
8010562e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105631:	8b 45 0c             	mov    0xc(%ebp),%eax
80105634:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105637:	eb 30                	jmp    80105669 <memcmp+0x48>
    if(*s1 != *s2)
80105639:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010563c:	0f b6 10             	movzbl (%eax),%edx
8010563f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105642:	0f b6 00             	movzbl (%eax),%eax
80105645:	38 c2                	cmp    %al,%dl
80105647:	74 18                	je     80105661 <memcmp+0x40>
      return *s1 - *s2;
80105649:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010564c:	0f b6 00             	movzbl (%eax),%eax
8010564f:	0f b6 d0             	movzbl %al,%edx
80105652:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105655:	0f b6 00             	movzbl (%eax),%eax
80105658:	0f b6 c0             	movzbl %al,%eax
8010565b:	29 c2                	sub    %eax,%edx
8010565d:	89 d0                	mov    %edx,%eax
8010565f:	eb 1a                	jmp    8010567b <memcmp+0x5a>
    s1++, s2++;
80105661:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105665:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105669:	8b 45 10             	mov    0x10(%ebp),%eax
8010566c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010566f:	89 55 10             	mov    %edx,0x10(%ebp)
80105672:	85 c0                	test   %eax,%eax
80105674:	75 c3                	jne    80105639 <memcmp+0x18>
  }

  return 0;
80105676:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010567b:	c9                   	leave  
8010567c:	c3                   	ret    

8010567d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010567d:	f3 0f 1e fb          	endbr32 
80105681:	55                   	push   %ebp
80105682:	89 e5                	mov    %esp,%ebp
80105684:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105687:	8b 45 0c             	mov    0xc(%ebp),%eax
8010568a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010568d:	8b 45 08             	mov    0x8(%ebp),%eax
80105690:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105693:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105696:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105699:	73 54                	jae    801056ef <memmove+0x72>
8010569b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010569e:	8b 45 10             	mov    0x10(%ebp),%eax
801056a1:	01 d0                	add    %edx,%eax
801056a3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801056a6:	73 47                	jae    801056ef <memmove+0x72>
    s += n;
801056a8:	8b 45 10             	mov    0x10(%ebp),%eax
801056ab:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801056ae:	8b 45 10             	mov    0x10(%ebp),%eax
801056b1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801056b4:	eb 13                	jmp    801056c9 <memmove+0x4c>
      *--d = *--s;
801056b6:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801056ba:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801056be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056c1:	0f b6 10             	movzbl (%eax),%edx
801056c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056c7:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056c9:	8b 45 10             	mov    0x10(%ebp),%eax
801056cc:	8d 50 ff             	lea    -0x1(%eax),%edx
801056cf:	89 55 10             	mov    %edx,0x10(%ebp)
801056d2:	85 c0                	test   %eax,%eax
801056d4:	75 e0                	jne    801056b6 <memmove+0x39>
  if(s < d && s + n > d){
801056d6:	eb 24                	jmp    801056fc <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
801056d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056db:	8d 42 01             	lea    0x1(%edx),%eax
801056de:	89 45 fc             	mov    %eax,-0x4(%ebp)
801056e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056e4:	8d 48 01             	lea    0x1(%eax),%ecx
801056e7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801056ea:	0f b6 12             	movzbl (%edx),%edx
801056ed:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056ef:	8b 45 10             	mov    0x10(%ebp),%eax
801056f2:	8d 50 ff             	lea    -0x1(%eax),%edx
801056f5:	89 55 10             	mov    %edx,0x10(%ebp)
801056f8:	85 c0                	test   %eax,%eax
801056fa:	75 dc                	jne    801056d8 <memmove+0x5b>

  return dst;
801056fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056ff:	c9                   	leave  
80105700:	c3                   	ret    

80105701 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105701:	f3 0f 1e fb          	endbr32 
80105705:	55                   	push   %ebp
80105706:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105708:	ff 75 10             	pushl  0x10(%ebp)
8010570b:	ff 75 0c             	pushl  0xc(%ebp)
8010570e:	ff 75 08             	pushl  0x8(%ebp)
80105711:	e8 67 ff ff ff       	call   8010567d <memmove>
80105716:	83 c4 0c             	add    $0xc,%esp
}
80105719:	c9                   	leave  
8010571a:	c3                   	ret    

8010571b <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010571b:	f3 0f 1e fb          	endbr32 
8010571f:	55                   	push   %ebp
80105720:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105722:	eb 0c                	jmp    80105730 <strncmp+0x15>
    n--, p++, q++;
80105724:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105728:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010572c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105730:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105734:	74 1a                	je     80105750 <strncmp+0x35>
80105736:	8b 45 08             	mov    0x8(%ebp),%eax
80105739:	0f b6 00             	movzbl (%eax),%eax
8010573c:	84 c0                	test   %al,%al
8010573e:	74 10                	je     80105750 <strncmp+0x35>
80105740:	8b 45 08             	mov    0x8(%ebp),%eax
80105743:	0f b6 10             	movzbl (%eax),%edx
80105746:	8b 45 0c             	mov    0xc(%ebp),%eax
80105749:	0f b6 00             	movzbl (%eax),%eax
8010574c:	38 c2                	cmp    %al,%dl
8010574e:	74 d4                	je     80105724 <strncmp+0x9>
  if(n == 0)
80105750:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105754:	75 07                	jne    8010575d <strncmp+0x42>
    return 0;
80105756:	b8 00 00 00 00       	mov    $0x0,%eax
8010575b:	eb 16                	jmp    80105773 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
8010575d:	8b 45 08             	mov    0x8(%ebp),%eax
80105760:	0f b6 00             	movzbl (%eax),%eax
80105763:	0f b6 d0             	movzbl %al,%edx
80105766:	8b 45 0c             	mov    0xc(%ebp),%eax
80105769:	0f b6 00             	movzbl (%eax),%eax
8010576c:	0f b6 c0             	movzbl %al,%eax
8010576f:	29 c2                	sub    %eax,%edx
80105771:	89 d0                	mov    %edx,%eax
}
80105773:	5d                   	pop    %ebp
80105774:	c3                   	ret    

80105775 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105775:	f3 0f 1e fb          	endbr32 
80105779:	55                   	push   %ebp
8010577a:	89 e5                	mov    %esp,%ebp
8010577c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010577f:	8b 45 08             	mov    0x8(%ebp),%eax
80105782:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105785:	90                   	nop
80105786:	8b 45 10             	mov    0x10(%ebp),%eax
80105789:	8d 50 ff             	lea    -0x1(%eax),%edx
8010578c:	89 55 10             	mov    %edx,0x10(%ebp)
8010578f:	85 c0                	test   %eax,%eax
80105791:	7e 2c                	jle    801057bf <strncpy+0x4a>
80105793:	8b 55 0c             	mov    0xc(%ebp),%edx
80105796:	8d 42 01             	lea    0x1(%edx),%eax
80105799:	89 45 0c             	mov    %eax,0xc(%ebp)
8010579c:	8b 45 08             	mov    0x8(%ebp),%eax
8010579f:	8d 48 01             	lea    0x1(%eax),%ecx
801057a2:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057a5:	0f b6 12             	movzbl (%edx),%edx
801057a8:	88 10                	mov    %dl,(%eax)
801057aa:	0f b6 00             	movzbl (%eax),%eax
801057ad:	84 c0                	test   %al,%al
801057af:	75 d5                	jne    80105786 <strncpy+0x11>
    ;
  while(n-- > 0)
801057b1:	eb 0c                	jmp    801057bf <strncpy+0x4a>
    *s++ = 0;
801057b3:	8b 45 08             	mov    0x8(%ebp),%eax
801057b6:	8d 50 01             	lea    0x1(%eax),%edx
801057b9:	89 55 08             	mov    %edx,0x8(%ebp)
801057bc:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801057bf:	8b 45 10             	mov    0x10(%ebp),%eax
801057c2:	8d 50 ff             	lea    -0x1(%eax),%edx
801057c5:	89 55 10             	mov    %edx,0x10(%ebp)
801057c8:	85 c0                	test   %eax,%eax
801057ca:	7f e7                	jg     801057b3 <strncpy+0x3e>
  return os;
801057cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057cf:	c9                   	leave  
801057d0:	c3                   	ret    

801057d1 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801057d1:	f3 0f 1e fb          	endbr32 
801057d5:	55                   	push   %ebp
801057d6:	89 e5                	mov    %esp,%ebp
801057d8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801057db:	8b 45 08             	mov    0x8(%ebp),%eax
801057de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801057e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057e5:	7f 05                	jg     801057ec <safestrcpy+0x1b>
    return os;
801057e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ea:	eb 31                	jmp    8010581d <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801057ec:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057f4:	7e 1e                	jle    80105814 <safestrcpy+0x43>
801057f6:	8b 55 0c             	mov    0xc(%ebp),%edx
801057f9:	8d 42 01             	lea    0x1(%edx),%eax
801057fc:	89 45 0c             	mov    %eax,0xc(%ebp)
801057ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105802:	8d 48 01             	lea    0x1(%eax),%ecx
80105805:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105808:	0f b6 12             	movzbl (%edx),%edx
8010580b:	88 10                	mov    %dl,(%eax)
8010580d:	0f b6 00             	movzbl (%eax),%eax
80105810:	84 c0                	test   %al,%al
80105812:	75 d8                	jne    801057ec <safestrcpy+0x1b>
    ;
  *s = 0;
80105814:	8b 45 08             	mov    0x8(%ebp),%eax
80105817:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010581a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010581d:	c9                   	leave  
8010581e:	c3                   	ret    

8010581f <strlen>:

int
strlen(const char *s)
{
8010581f:	f3 0f 1e fb          	endbr32 
80105823:	55                   	push   %ebp
80105824:	89 e5                	mov    %esp,%ebp
80105826:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105829:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105830:	eb 04                	jmp    80105836 <strlen+0x17>
80105832:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105836:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105839:	8b 45 08             	mov    0x8(%ebp),%eax
8010583c:	01 d0                	add    %edx,%eax
8010583e:	0f b6 00             	movzbl (%eax),%eax
80105841:	84 c0                	test   %al,%al
80105843:	75 ed                	jne    80105832 <strlen+0x13>
    ;
  return n;
80105845:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105848:	c9                   	leave  
80105849:	c3                   	ret    

8010584a <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010584a:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010584e:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80105852:	55                   	push   %ebp
  pushl %ebx
80105853:	53                   	push   %ebx
  pushl %esi
80105854:	56                   	push   %esi
  pushl %edi
80105855:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105856:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105858:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010585a:	5f                   	pop    %edi
  popl %esi
8010585b:	5e                   	pop    %esi
  popl %ebx
8010585c:	5b                   	pop    %ebx
  popl %ebp
8010585d:	5d                   	pop    %ebp
  ret
8010585e:	c3                   	ret    

8010585f <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010585f:	f3 0f 1e fb          	endbr32 
80105863:	55                   	push   %ebp
80105864:	89 e5                	mov    %esp,%ebp
80105866:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105869:	e8 9f ec ff ff       	call   8010450d <myproc>
8010586e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105874:	8b 00                	mov    (%eax),%eax
80105876:	39 45 08             	cmp    %eax,0x8(%ebp)
80105879:	73 0f                	jae    8010588a <fetchint+0x2b>
8010587b:	8b 45 08             	mov    0x8(%ebp),%eax
8010587e:	8d 50 04             	lea    0x4(%eax),%edx
80105881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105884:	8b 00                	mov    (%eax),%eax
80105886:	39 c2                	cmp    %eax,%edx
80105888:	76 07                	jbe    80105891 <fetchint+0x32>
    return -1;
8010588a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010588f:	eb 0f                	jmp    801058a0 <fetchint+0x41>
  *ip = *(int*)(addr);
80105891:	8b 45 08             	mov    0x8(%ebp),%eax
80105894:	8b 10                	mov    (%eax),%edx
80105896:	8b 45 0c             	mov    0xc(%ebp),%eax
80105899:	89 10                	mov    %edx,(%eax)
  return 0;
8010589b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058a0:	c9                   	leave  
801058a1:	c3                   	ret    

801058a2 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801058a2:	f3 0f 1e fb          	endbr32 
801058a6:	55                   	push   %ebp
801058a7:	89 e5                	mov    %esp,%ebp
801058a9:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801058ac:	e8 5c ec ff ff       	call   8010450d <myproc>
801058b1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801058b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b7:	8b 00                	mov    (%eax),%eax
801058b9:	39 45 08             	cmp    %eax,0x8(%ebp)
801058bc:	72 07                	jb     801058c5 <fetchstr+0x23>
    return -1;
801058be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c3:	eb 43                	jmp    80105908 <fetchstr+0x66>
  *pp = (char*)addr;
801058c5:	8b 55 08             	mov    0x8(%ebp),%edx
801058c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801058cb:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801058cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d0:	8b 00                	mov    (%eax),%eax
801058d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801058d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801058d8:	8b 00                	mov    (%eax),%eax
801058da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058dd:	eb 1c                	jmp    801058fb <fetchstr+0x59>
    if(*s == 0)
801058df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e2:	0f b6 00             	movzbl (%eax),%eax
801058e5:	84 c0                	test   %al,%al
801058e7:	75 0e                	jne    801058f7 <fetchstr+0x55>
      return s - *pp;
801058e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ec:	8b 00                	mov    (%eax),%eax
801058ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058f1:	29 c2                	sub    %eax,%edx
801058f3:	89 d0                	mov    %edx,%eax
801058f5:	eb 11                	jmp    80105908 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801058f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801058fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058fe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105901:	72 dc                	jb     801058df <fetchstr+0x3d>
  }
  return -1;
80105903:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105908:	c9                   	leave  
80105909:	c3                   	ret    

8010590a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010590a:	f3 0f 1e fb          	endbr32 
8010590e:	55                   	push   %ebp
8010590f:	89 e5                	mov    %esp,%ebp
80105911:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105914:	e8 f4 eb ff ff       	call   8010450d <myproc>
80105919:	8b 40 18             	mov    0x18(%eax),%eax
8010591c:	8b 40 44             	mov    0x44(%eax),%eax
8010591f:	8b 55 08             	mov    0x8(%ebp),%edx
80105922:	c1 e2 02             	shl    $0x2,%edx
80105925:	01 d0                	add    %edx,%eax
80105927:	83 c0 04             	add    $0x4,%eax
8010592a:	83 ec 08             	sub    $0x8,%esp
8010592d:	ff 75 0c             	pushl  0xc(%ebp)
80105930:	50                   	push   %eax
80105931:	e8 29 ff ff ff       	call   8010585f <fetchint>
80105936:	83 c4 10             	add    $0x10,%esp
}
80105939:	c9                   	leave  
8010593a:	c3                   	ret    

8010593b <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010593b:	f3 0f 1e fb          	endbr32 
8010593f:	55                   	push   %ebp
80105940:	89 e5                	mov    %esp,%ebp
80105942:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105945:	e8 c3 eb ff ff       	call   8010450d <myproc>
8010594a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010594d:	83 ec 08             	sub    $0x8,%esp
80105950:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105953:	50                   	push   %eax
80105954:	ff 75 08             	pushl  0x8(%ebp)
80105957:	e8 ae ff ff ff       	call   8010590a <argint>
8010595c:	83 c4 10             	add    $0x10,%esp
8010595f:	85 c0                	test   %eax,%eax
80105961:	79 07                	jns    8010596a <argptr+0x2f>
    return -1;
80105963:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105968:	eb 3b                	jmp    801059a5 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010596a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010596e:	78 1f                	js     8010598f <argptr+0x54>
80105970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105973:	8b 00                	mov    (%eax),%eax
80105975:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105978:	39 d0                	cmp    %edx,%eax
8010597a:	76 13                	jbe    8010598f <argptr+0x54>
8010597c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597f:	89 c2                	mov    %eax,%edx
80105981:	8b 45 10             	mov    0x10(%ebp),%eax
80105984:	01 c2                	add    %eax,%edx
80105986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105989:	8b 00                	mov    (%eax),%eax
8010598b:	39 c2                	cmp    %eax,%edx
8010598d:	76 07                	jbe    80105996 <argptr+0x5b>
    return -1;
8010598f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105994:	eb 0f                	jmp    801059a5 <argptr+0x6a>
  *pp = (char*)i;
80105996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105999:	89 c2                	mov    %eax,%edx
8010599b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010599e:	89 10                	mov    %edx,(%eax)
  return 0;
801059a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059a5:	c9                   	leave  
801059a6:	c3                   	ret    

801059a7 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801059a7:	f3 0f 1e fb          	endbr32 
801059ab:	55                   	push   %ebp
801059ac:	89 e5                	mov    %esp,%ebp
801059ae:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801059b1:	83 ec 08             	sub    $0x8,%esp
801059b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059b7:	50                   	push   %eax
801059b8:	ff 75 08             	pushl  0x8(%ebp)
801059bb:	e8 4a ff ff ff       	call   8010590a <argint>
801059c0:	83 c4 10             	add    $0x10,%esp
801059c3:	85 c0                	test   %eax,%eax
801059c5:	79 07                	jns    801059ce <argstr+0x27>
    return -1;
801059c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cc:	eb 12                	jmp    801059e0 <argstr+0x39>
  return fetchstr(addr, pp);
801059ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d1:	83 ec 08             	sub    $0x8,%esp
801059d4:	ff 75 0c             	pushl  0xc(%ebp)
801059d7:	50                   	push   %eax
801059d8:	e8 c5 fe ff ff       	call   801058a2 <fetchstr>
801059dd:	83 c4 10             	add    $0x10,%esp
}
801059e0:	c9                   	leave  
801059e1:	c3                   	ret    

801059e2 <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
801059e2:	f3 0f 1e fb          	endbr32 
801059e6:	55                   	push   %ebp
801059e7:	89 e5                	mov    %esp,%ebp
801059e9:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801059ec:	e8 1c eb ff ff       	call   8010450d <myproc>
801059f1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801059f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f7:	8b 40 18             	mov    0x18(%eax),%eax
801059fa:	8b 40 1c             	mov    0x1c(%eax),%eax
801059fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105a00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a04:	7e 2f                	jle    80105a35 <syscall+0x53>
80105a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a09:	83 f8 18             	cmp    $0x18,%eax
80105a0c:	77 27                	ja     80105a35 <syscall+0x53>
80105a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a11:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105a18:	85 c0                	test   %eax,%eax
80105a1a:	74 19                	je     80105a35 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1f:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105a26:	ff d0                	call   *%eax
80105a28:	89 c2                	mov    %eax,%edx
80105a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2d:	8b 40 18             	mov    0x18(%eax),%eax
80105a30:	89 50 1c             	mov    %edx,0x1c(%eax)
80105a33:	eb 2c                	jmp    80105a61 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a38:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3e:	8b 40 10             	mov    0x10(%eax),%eax
80105a41:	ff 75 f0             	pushl  -0x10(%ebp)
80105a44:	52                   	push   %edx
80105a45:	50                   	push   %eax
80105a46:	68 2c 97 10 80       	push   $0x8010972c
80105a4b:	e8 c8 a9 ff ff       	call   80100418 <cprintf>
80105a50:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a56:	8b 40 18             	mov    0x18(%eax),%eax
80105a59:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a60:	90                   	nop
80105a61:	90                   	nop
80105a62:	c9                   	leave  
80105a63:	c3                   	ret    

80105a64 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a64:	f3 0f 1e fb          	endbr32 
80105a68:	55                   	push   %ebp
80105a69:	89 e5                	mov    %esp,%ebp
80105a6b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a6e:	83 ec 08             	sub    $0x8,%esp
80105a71:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a74:	50                   	push   %eax
80105a75:	ff 75 08             	pushl  0x8(%ebp)
80105a78:	e8 8d fe ff ff       	call   8010590a <argint>
80105a7d:	83 c4 10             	add    $0x10,%esp
80105a80:	85 c0                	test   %eax,%eax
80105a82:	79 07                	jns    80105a8b <argfd+0x27>
    return -1;
80105a84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a89:	eb 4f                	jmp    80105ada <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a8e:	85 c0                	test   %eax,%eax
80105a90:	78 20                	js     80105ab2 <argfd+0x4e>
80105a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a95:	83 f8 0f             	cmp    $0xf,%eax
80105a98:	7f 18                	jg     80105ab2 <argfd+0x4e>
80105a9a:	e8 6e ea ff ff       	call   8010450d <myproc>
80105a9f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105aa2:	83 c2 08             	add    $0x8,%edx
80105aa5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ab0:	75 07                	jne    80105ab9 <argfd+0x55>
    return -1;
80105ab2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab7:	eb 21                	jmp    80105ada <argfd+0x76>
  if(pfd)
80105ab9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105abd:	74 08                	je     80105ac7 <argfd+0x63>
    *pfd = fd;
80105abf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ac5:	89 10                	mov    %edx,(%eax)
  if(pf)
80105ac7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105acb:	74 08                	je     80105ad5 <argfd+0x71>
    *pf = f;
80105acd:	8b 45 10             	mov    0x10(%ebp),%eax
80105ad0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ad3:	89 10                	mov    %edx,(%eax)
  return 0;
80105ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ada:	c9                   	leave  
80105adb:	c3                   	ret    

80105adc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105adc:	f3 0f 1e fb          	endbr32 
80105ae0:	55                   	push   %ebp
80105ae1:	89 e5                	mov    %esp,%ebp
80105ae3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105ae6:	e8 22 ea ff ff       	call   8010450d <myproc>
80105aeb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105aee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105af5:	eb 2a                	jmp    80105b21 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105afd:	83 c2 08             	add    $0x8,%edx
80105b00:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b04:	85 c0                	test   %eax,%eax
80105b06:	75 15                	jne    80105b1d <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b0e:	8d 4a 08             	lea    0x8(%edx),%ecx
80105b11:	8b 55 08             	mov    0x8(%ebp),%edx
80105b14:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1b:	eb 0f                	jmp    80105b2c <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105b1d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105b21:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105b25:	7e d0                	jle    80105af7 <fdalloc+0x1b>
    }
  }
  return -1;
80105b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b2c:	c9                   	leave  
80105b2d:	c3                   	ret    

80105b2e <sys_dup>:

int
sys_dup(void)
{
80105b2e:	f3 0f 1e fb          	endbr32 
80105b32:	55                   	push   %ebp
80105b33:	89 e5                	mov    %esp,%ebp
80105b35:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105b38:	83 ec 04             	sub    $0x4,%esp
80105b3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b3e:	50                   	push   %eax
80105b3f:	6a 00                	push   $0x0
80105b41:	6a 00                	push   $0x0
80105b43:	e8 1c ff ff ff       	call   80105a64 <argfd>
80105b48:	83 c4 10             	add    $0x10,%esp
80105b4b:	85 c0                	test   %eax,%eax
80105b4d:	79 07                	jns    80105b56 <sys_dup+0x28>
    return -1;
80105b4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b54:	eb 31                	jmp    80105b87 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b59:	83 ec 0c             	sub    $0xc,%esp
80105b5c:	50                   	push   %eax
80105b5d:	e8 7a ff ff ff       	call   80105adc <fdalloc>
80105b62:	83 c4 10             	add    $0x10,%esp
80105b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b6c:	79 07                	jns    80105b75 <sys_dup+0x47>
    return -1;
80105b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b73:	eb 12                	jmp    80105b87 <sys_dup+0x59>
  filedup(f);
80105b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b78:	83 ec 0c             	sub    $0xc,%esp
80105b7b:	50                   	push   %eax
80105b7c:	e8 03 b6 ff ff       	call   80101184 <filedup>
80105b81:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b87:	c9                   	leave  
80105b88:	c3                   	ret    

80105b89 <sys_read>:

int
sys_read(void)
{
80105b89:	f3 0f 1e fb          	endbr32 
80105b8d:	55                   	push   %ebp
80105b8e:	89 e5                	mov    %esp,%ebp
80105b90:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b93:	83 ec 04             	sub    $0x4,%esp
80105b96:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b99:	50                   	push   %eax
80105b9a:	6a 00                	push   $0x0
80105b9c:	6a 00                	push   $0x0
80105b9e:	e8 c1 fe ff ff       	call   80105a64 <argfd>
80105ba3:	83 c4 10             	add    $0x10,%esp
80105ba6:	85 c0                	test   %eax,%eax
80105ba8:	78 2e                	js     80105bd8 <sys_read+0x4f>
80105baa:	83 ec 08             	sub    $0x8,%esp
80105bad:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bb0:	50                   	push   %eax
80105bb1:	6a 02                	push   $0x2
80105bb3:	e8 52 fd ff ff       	call   8010590a <argint>
80105bb8:	83 c4 10             	add    $0x10,%esp
80105bbb:	85 c0                	test   %eax,%eax
80105bbd:	78 19                	js     80105bd8 <sys_read+0x4f>
80105bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc2:	83 ec 04             	sub    $0x4,%esp
80105bc5:	50                   	push   %eax
80105bc6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bc9:	50                   	push   %eax
80105bca:	6a 01                	push   $0x1
80105bcc:	e8 6a fd ff ff       	call   8010593b <argptr>
80105bd1:	83 c4 10             	add    $0x10,%esp
80105bd4:	85 c0                	test   %eax,%eax
80105bd6:	79 07                	jns    80105bdf <sys_read+0x56>
    return -1;
80105bd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bdd:	eb 17                	jmp    80105bf6 <sys_read+0x6d>
  return fileread(f, p, n);
80105bdf:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105be2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be8:	83 ec 04             	sub    $0x4,%esp
80105beb:	51                   	push   %ecx
80105bec:	52                   	push   %edx
80105bed:	50                   	push   %eax
80105bee:	e8 2d b7 ff ff       	call   80101320 <fileread>
80105bf3:	83 c4 10             	add    $0x10,%esp
}
80105bf6:	c9                   	leave  
80105bf7:	c3                   	ret    

80105bf8 <sys_write>:

int
sys_write(void)
{
80105bf8:	f3 0f 1e fb          	endbr32 
80105bfc:	55                   	push   %ebp
80105bfd:	89 e5                	mov    %esp,%ebp
80105bff:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c02:	83 ec 04             	sub    $0x4,%esp
80105c05:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c08:	50                   	push   %eax
80105c09:	6a 00                	push   $0x0
80105c0b:	6a 00                	push   $0x0
80105c0d:	e8 52 fe ff ff       	call   80105a64 <argfd>
80105c12:	83 c4 10             	add    $0x10,%esp
80105c15:	85 c0                	test   %eax,%eax
80105c17:	78 2e                	js     80105c47 <sys_write+0x4f>
80105c19:	83 ec 08             	sub    $0x8,%esp
80105c1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c1f:	50                   	push   %eax
80105c20:	6a 02                	push   $0x2
80105c22:	e8 e3 fc ff ff       	call   8010590a <argint>
80105c27:	83 c4 10             	add    $0x10,%esp
80105c2a:	85 c0                	test   %eax,%eax
80105c2c:	78 19                	js     80105c47 <sys_write+0x4f>
80105c2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c31:	83 ec 04             	sub    $0x4,%esp
80105c34:	50                   	push   %eax
80105c35:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c38:	50                   	push   %eax
80105c39:	6a 01                	push   $0x1
80105c3b:	e8 fb fc ff ff       	call   8010593b <argptr>
80105c40:	83 c4 10             	add    $0x10,%esp
80105c43:	85 c0                	test   %eax,%eax
80105c45:	79 07                	jns    80105c4e <sys_write+0x56>
    return -1;
80105c47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c4c:	eb 17                	jmp    80105c65 <sys_write+0x6d>
  return filewrite(f, p, n);
80105c4e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c51:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c57:	83 ec 04             	sub    $0x4,%esp
80105c5a:	51                   	push   %ecx
80105c5b:	52                   	push   %edx
80105c5c:	50                   	push   %eax
80105c5d:	e8 7a b7 ff ff       	call   801013dc <filewrite>
80105c62:	83 c4 10             	add    $0x10,%esp
}
80105c65:	c9                   	leave  
80105c66:	c3                   	ret    

80105c67 <sys_close>:

int
sys_close(void)
{
80105c67:	f3 0f 1e fb          	endbr32 
80105c6b:	55                   	push   %ebp
80105c6c:	89 e5                	mov    %esp,%ebp
80105c6e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c71:	83 ec 04             	sub    $0x4,%esp
80105c74:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c77:	50                   	push   %eax
80105c78:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c7b:	50                   	push   %eax
80105c7c:	6a 00                	push   $0x0
80105c7e:	e8 e1 fd ff ff       	call   80105a64 <argfd>
80105c83:	83 c4 10             	add    $0x10,%esp
80105c86:	85 c0                	test   %eax,%eax
80105c88:	79 07                	jns    80105c91 <sys_close+0x2a>
    return -1;
80105c8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c8f:	eb 27                	jmp    80105cb8 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c91:	e8 77 e8 ff ff       	call   8010450d <myproc>
80105c96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c99:	83 c2 08             	add    $0x8,%edx
80105c9c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105ca3:	00 
  fileclose(f);
80105ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca7:	83 ec 0c             	sub    $0xc,%esp
80105caa:	50                   	push   %eax
80105cab:	e8 29 b5 ff ff       	call   801011d9 <fileclose>
80105cb0:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cb8:	c9                   	leave  
80105cb9:	c3                   	ret    

80105cba <sys_fstat>:

int
sys_fstat(void)
{
80105cba:	f3 0f 1e fb          	endbr32 
80105cbe:	55                   	push   %ebp
80105cbf:	89 e5                	mov    %esp,%ebp
80105cc1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105cc4:	83 ec 04             	sub    $0x4,%esp
80105cc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cca:	50                   	push   %eax
80105ccb:	6a 00                	push   $0x0
80105ccd:	6a 00                	push   $0x0
80105ccf:	e8 90 fd ff ff       	call   80105a64 <argfd>
80105cd4:	83 c4 10             	add    $0x10,%esp
80105cd7:	85 c0                	test   %eax,%eax
80105cd9:	78 17                	js     80105cf2 <sys_fstat+0x38>
80105cdb:	83 ec 04             	sub    $0x4,%esp
80105cde:	6a 14                	push   $0x14
80105ce0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ce3:	50                   	push   %eax
80105ce4:	6a 01                	push   $0x1
80105ce6:	e8 50 fc ff ff       	call   8010593b <argptr>
80105ceb:	83 c4 10             	add    $0x10,%esp
80105cee:	85 c0                	test   %eax,%eax
80105cf0:	79 07                	jns    80105cf9 <sys_fstat+0x3f>
    return -1;
80105cf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf7:	eb 13                	jmp    80105d0c <sys_fstat+0x52>
  return filestat(f, st);
80105cf9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cff:	83 ec 08             	sub    $0x8,%esp
80105d02:	52                   	push   %edx
80105d03:	50                   	push   %eax
80105d04:	e8 bc b5 ff ff       	call   801012c5 <filestat>
80105d09:	83 c4 10             	add    $0x10,%esp
}
80105d0c:	c9                   	leave  
80105d0d:	c3                   	ret    

80105d0e <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105d0e:	f3 0f 1e fb          	endbr32 
80105d12:	55                   	push   %ebp
80105d13:	89 e5                	mov    %esp,%ebp
80105d15:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d18:	83 ec 08             	sub    $0x8,%esp
80105d1b:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d1e:	50                   	push   %eax
80105d1f:	6a 00                	push   $0x0
80105d21:	e8 81 fc ff ff       	call   801059a7 <argstr>
80105d26:	83 c4 10             	add    $0x10,%esp
80105d29:	85 c0                	test   %eax,%eax
80105d2b:	78 15                	js     80105d42 <sys_link+0x34>
80105d2d:	83 ec 08             	sub    $0x8,%esp
80105d30:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d33:	50                   	push   %eax
80105d34:	6a 01                	push   $0x1
80105d36:	e8 6c fc ff ff       	call   801059a7 <argstr>
80105d3b:	83 c4 10             	add    $0x10,%esp
80105d3e:	85 c0                	test   %eax,%eax
80105d40:	79 0a                	jns    80105d4c <sys_link+0x3e>
    return -1;
80105d42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d47:	e9 68 01 00 00       	jmp    80105eb4 <sys_link+0x1a6>

  begin_op();
80105d4c:	e8 fd d9 ff ff       	call   8010374e <begin_op>
  if((ip = namei(old)) == 0){
80105d51:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d54:	83 ec 0c             	sub    $0xc,%esp
80105d57:	50                   	push   %eax
80105d58:	e8 67 c9 ff ff       	call   801026c4 <namei>
80105d5d:	83 c4 10             	add    $0x10,%esp
80105d60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d67:	75 0f                	jne    80105d78 <sys_link+0x6a>
    end_op();
80105d69:	e8 70 da ff ff       	call   801037de <end_op>
    return -1;
80105d6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d73:	e9 3c 01 00 00       	jmp    80105eb4 <sys_link+0x1a6>
  }

  ilock(ip);
80105d78:	83 ec 0c             	sub    $0xc,%esp
80105d7b:	ff 75 f4             	pushl  -0xc(%ebp)
80105d7e:	e8 d6 bd ff ff       	call   80101b59 <ilock>
80105d83:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d89:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d8d:	66 83 f8 01          	cmp    $0x1,%ax
80105d91:	75 1d                	jne    80105db0 <sys_link+0xa2>
    iunlockput(ip);
80105d93:	83 ec 0c             	sub    $0xc,%esp
80105d96:	ff 75 f4             	pushl  -0xc(%ebp)
80105d99:	e8 f8 bf ff ff       	call   80101d96 <iunlockput>
80105d9e:	83 c4 10             	add    $0x10,%esp
    end_op();
80105da1:	e8 38 da ff ff       	call   801037de <end_op>
    return -1;
80105da6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dab:	e9 04 01 00 00       	jmp    80105eb4 <sys_link+0x1a6>
  }

  ip->nlink++;
80105db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105db7:	83 c0 01             	add    $0x1,%eax
80105dba:	89 c2                	mov    %eax,%edx
80105dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbf:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105dc3:	83 ec 0c             	sub    $0xc,%esp
80105dc6:	ff 75 f4             	pushl  -0xc(%ebp)
80105dc9:	e8 a2 bb ff ff       	call   80101970 <iupdate>
80105dce:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105dd1:	83 ec 0c             	sub    $0xc,%esp
80105dd4:	ff 75 f4             	pushl  -0xc(%ebp)
80105dd7:	e8 94 be ff ff       	call   80101c70 <iunlock>
80105ddc:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105ddf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105de2:	83 ec 08             	sub    $0x8,%esp
80105de5:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105de8:	52                   	push   %edx
80105de9:	50                   	push   %eax
80105dea:	e8 f5 c8 ff ff       	call   801026e4 <nameiparent>
80105def:	83 c4 10             	add    $0x10,%esp
80105df2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105df5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105df9:	74 71                	je     80105e6c <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105dfb:	83 ec 0c             	sub    $0xc,%esp
80105dfe:	ff 75 f0             	pushl  -0x10(%ebp)
80105e01:	e8 53 bd ff ff       	call   80101b59 <ilock>
80105e06:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0c:	8b 10                	mov    (%eax),%edx
80105e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e11:	8b 00                	mov    (%eax),%eax
80105e13:	39 c2                	cmp    %eax,%edx
80105e15:	75 1d                	jne    80105e34 <sys_link+0x126>
80105e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1a:	8b 40 04             	mov    0x4(%eax),%eax
80105e1d:	83 ec 04             	sub    $0x4,%esp
80105e20:	50                   	push   %eax
80105e21:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e24:	50                   	push   %eax
80105e25:	ff 75 f0             	pushl  -0x10(%ebp)
80105e28:	e8 f4 c5 ff ff       	call   80102421 <dirlink>
80105e2d:	83 c4 10             	add    $0x10,%esp
80105e30:	85 c0                	test   %eax,%eax
80105e32:	79 10                	jns    80105e44 <sys_link+0x136>
    iunlockput(dp);
80105e34:	83 ec 0c             	sub    $0xc,%esp
80105e37:	ff 75 f0             	pushl  -0x10(%ebp)
80105e3a:	e8 57 bf ff ff       	call   80101d96 <iunlockput>
80105e3f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e42:	eb 29                	jmp    80105e6d <sys_link+0x15f>
  }
  iunlockput(dp);
80105e44:	83 ec 0c             	sub    $0xc,%esp
80105e47:	ff 75 f0             	pushl  -0x10(%ebp)
80105e4a:	e8 47 bf ff ff       	call   80101d96 <iunlockput>
80105e4f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e52:	83 ec 0c             	sub    $0xc,%esp
80105e55:	ff 75 f4             	pushl  -0xc(%ebp)
80105e58:	e8 65 be ff ff       	call   80101cc2 <iput>
80105e5d:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e60:	e8 79 d9 ff ff       	call   801037de <end_op>

  return 0;
80105e65:	b8 00 00 00 00       	mov    $0x0,%eax
80105e6a:	eb 48                	jmp    80105eb4 <sys_link+0x1a6>
    goto bad;
80105e6c:	90                   	nop

bad:
  ilock(ip);
80105e6d:	83 ec 0c             	sub    $0xc,%esp
80105e70:	ff 75 f4             	pushl  -0xc(%ebp)
80105e73:	e8 e1 bc ff ff       	call   80101b59 <ilock>
80105e78:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e82:	83 e8 01             	sub    $0x1,%eax
80105e85:	89 c2                	mov    %eax,%edx
80105e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8a:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e8e:	83 ec 0c             	sub    $0xc,%esp
80105e91:	ff 75 f4             	pushl  -0xc(%ebp)
80105e94:	e8 d7 ba ff ff       	call   80101970 <iupdate>
80105e99:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e9c:	83 ec 0c             	sub    $0xc,%esp
80105e9f:	ff 75 f4             	pushl  -0xc(%ebp)
80105ea2:	e8 ef be ff ff       	call   80101d96 <iunlockput>
80105ea7:	83 c4 10             	add    $0x10,%esp
  end_op();
80105eaa:	e8 2f d9 ff ff       	call   801037de <end_op>
  return -1;
80105eaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105eb4:	c9                   	leave  
80105eb5:	c3                   	ret    

80105eb6 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105eb6:	f3 0f 1e fb          	endbr32 
80105eba:	55                   	push   %ebp
80105ebb:	89 e5                	mov    %esp,%ebp
80105ebd:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ec0:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ec7:	eb 40                	jmp    80105f09 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecc:	6a 10                	push   $0x10
80105ece:	50                   	push   %eax
80105ecf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ed2:	50                   	push   %eax
80105ed3:	ff 75 08             	pushl  0x8(%ebp)
80105ed6:	e8 86 c1 ff ff       	call   80102061 <readi>
80105edb:	83 c4 10             	add    $0x10,%esp
80105ede:	83 f8 10             	cmp    $0x10,%eax
80105ee1:	74 0d                	je     80105ef0 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105ee3:	83 ec 0c             	sub    $0xc,%esp
80105ee6:	68 48 97 10 80       	push   $0x80109748
80105eeb:	e8 18 a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105ef0:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105ef4:	66 85 c0             	test   %ax,%ax
80105ef7:	74 07                	je     80105f00 <isdirempty+0x4a>
      return 0;
80105ef9:	b8 00 00 00 00       	mov    $0x0,%eax
80105efe:	eb 1b                	jmp    80105f1b <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f03:	83 c0 10             	add    $0x10,%eax
80105f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f09:	8b 45 08             	mov    0x8(%ebp),%eax
80105f0c:	8b 50 58             	mov    0x58(%eax),%edx
80105f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f12:	39 c2                	cmp    %eax,%edx
80105f14:	77 b3                	ja     80105ec9 <isdirempty+0x13>
  }
  return 1;
80105f16:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f1b:	c9                   	leave  
80105f1c:	c3                   	ret    

80105f1d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f1d:	f3 0f 1e fb          	endbr32 
80105f21:	55                   	push   %ebp
80105f22:	89 e5                	mov    %esp,%ebp
80105f24:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f27:	83 ec 08             	sub    $0x8,%esp
80105f2a:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f2d:	50                   	push   %eax
80105f2e:	6a 00                	push   $0x0
80105f30:	e8 72 fa ff ff       	call   801059a7 <argstr>
80105f35:	83 c4 10             	add    $0x10,%esp
80105f38:	85 c0                	test   %eax,%eax
80105f3a:	79 0a                	jns    80105f46 <sys_unlink+0x29>
    return -1;
80105f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f41:	e9 bf 01 00 00       	jmp    80106105 <sys_unlink+0x1e8>

  begin_op();
80105f46:	e8 03 d8 ff ff       	call   8010374e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f4b:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f4e:	83 ec 08             	sub    $0x8,%esp
80105f51:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f54:	52                   	push   %edx
80105f55:	50                   	push   %eax
80105f56:	e8 89 c7 ff ff       	call   801026e4 <nameiparent>
80105f5b:	83 c4 10             	add    $0x10,%esp
80105f5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f65:	75 0f                	jne    80105f76 <sys_unlink+0x59>
    end_op();
80105f67:	e8 72 d8 ff ff       	call   801037de <end_op>
    return -1;
80105f6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f71:	e9 8f 01 00 00       	jmp    80106105 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105f76:	83 ec 0c             	sub    $0xc,%esp
80105f79:	ff 75 f4             	pushl  -0xc(%ebp)
80105f7c:	e8 d8 bb ff ff       	call   80101b59 <ilock>
80105f81:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f84:	83 ec 08             	sub    $0x8,%esp
80105f87:	68 5a 97 10 80       	push   $0x8010975a
80105f8c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f8f:	50                   	push   %eax
80105f90:	e8 af c3 ff ff       	call   80102344 <namecmp>
80105f95:	83 c4 10             	add    $0x10,%esp
80105f98:	85 c0                	test   %eax,%eax
80105f9a:	0f 84 49 01 00 00    	je     801060e9 <sys_unlink+0x1cc>
80105fa0:	83 ec 08             	sub    $0x8,%esp
80105fa3:	68 5c 97 10 80       	push   $0x8010975c
80105fa8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fab:	50                   	push   %eax
80105fac:	e8 93 c3 ff ff       	call   80102344 <namecmp>
80105fb1:	83 c4 10             	add    $0x10,%esp
80105fb4:	85 c0                	test   %eax,%eax
80105fb6:	0f 84 2d 01 00 00    	je     801060e9 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105fbc:	83 ec 04             	sub    $0x4,%esp
80105fbf:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105fc2:	50                   	push   %eax
80105fc3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fc6:	50                   	push   %eax
80105fc7:	ff 75 f4             	pushl  -0xc(%ebp)
80105fca:	e8 94 c3 ff ff       	call   80102363 <dirlookup>
80105fcf:	83 c4 10             	add    $0x10,%esp
80105fd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fd9:	0f 84 0d 01 00 00    	je     801060ec <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105fdf:	83 ec 0c             	sub    $0xc,%esp
80105fe2:	ff 75 f0             	pushl  -0x10(%ebp)
80105fe5:	e8 6f bb ff ff       	call   80101b59 <ilock>
80105fea:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ff4:	66 85 c0             	test   %ax,%ax
80105ff7:	7f 0d                	jg     80106006 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105ff9:	83 ec 0c             	sub    $0xc,%esp
80105ffc:	68 5f 97 10 80       	push   $0x8010975f
80106001:	e8 02 a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106009:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010600d:	66 83 f8 01          	cmp    $0x1,%ax
80106011:	75 25                	jne    80106038 <sys_unlink+0x11b>
80106013:	83 ec 0c             	sub    $0xc,%esp
80106016:	ff 75 f0             	pushl  -0x10(%ebp)
80106019:	e8 98 fe ff ff       	call   80105eb6 <isdirempty>
8010601e:	83 c4 10             	add    $0x10,%esp
80106021:	85 c0                	test   %eax,%eax
80106023:	75 13                	jne    80106038 <sys_unlink+0x11b>
    iunlockput(ip);
80106025:	83 ec 0c             	sub    $0xc,%esp
80106028:	ff 75 f0             	pushl  -0x10(%ebp)
8010602b:	e8 66 bd ff ff       	call   80101d96 <iunlockput>
80106030:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106033:	e9 b5 00 00 00       	jmp    801060ed <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80106038:	83 ec 04             	sub    $0x4,%esp
8010603b:	6a 10                	push   $0x10
8010603d:	6a 00                	push   $0x0
8010603f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106042:	50                   	push   %eax
80106043:	e8 6e f5 ff ff       	call   801055b6 <memset>
80106048:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010604b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010604e:	6a 10                	push   $0x10
80106050:	50                   	push   %eax
80106051:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106054:	50                   	push   %eax
80106055:	ff 75 f4             	pushl  -0xc(%ebp)
80106058:	e8 5d c1 ff ff       	call   801021ba <writei>
8010605d:	83 c4 10             	add    $0x10,%esp
80106060:	83 f8 10             	cmp    $0x10,%eax
80106063:	74 0d                	je     80106072 <sys_unlink+0x155>
    panic("unlink: writei");
80106065:	83 ec 0c             	sub    $0xc,%esp
80106068:	68 71 97 10 80       	push   $0x80109771
8010606d:	e8 96 a5 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
80106072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106075:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106079:	66 83 f8 01          	cmp    $0x1,%ax
8010607d:	75 21                	jne    801060a0 <sys_unlink+0x183>
    dp->nlink--;
8010607f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106082:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106086:	83 e8 01             	sub    $0x1,%eax
80106089:	89 c2                	mov    %eax,%edx
8010608b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608e:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106092:	83 ec 0c             	sub    $0xc,%esp
80106095:	ff 75 f4             	pushl  -0xc(%ebp)
80106098:	e8 d3 b8 ff ff       	call   80101970 <iupdate>
8010609d:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801060a0:	83 ec 0c             	sub    $0xc,%esp
801060a3:	ff 75 f4             	pushl  -0xc(%ebp)
801060a6:	e8 eb bc ff ff       	call   80101d96 <iunlockput>
801060ab:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801060ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b1:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801060b5:	83 e8 01             	sub    $0x1,%eax
801060b8:	89 c2                	mov    %eax,%edx
801060ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060bd:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801060c1:	83 ec 0c             	sub    $0xc,%esp
801060c4:	ff 75 f0             	pushl  -0x10(%ebp)
801060c7:	e8 a4 b8 ff ff       	call   80101970 <iupdate>
801060cc:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801060cf:	83 ec 0c             	sub    $0xc,%esp
801060d2:	ff 75 f0             	pushl  -0x10(%ebp)
801060d5:	e8 bc bc ff ff       	call   80101d96 <iunlockput>
801060da:	83 c4 10             	add    $0x10,%esp

  end_op();
801060dd:	e8 fc d6 ff ff       	call   801037de <end_op>

  return 0;
801060e2:	b8 00 00 00 00       	mov    $0x0,%eax
801060e7:	eb 1c                	jmp    80106105 <sys_unlink+0x1e8>
    goto bad;
801060e9:	90                   	nop
801060ea:	eb 01                	jmp    801060ed <sys_unlink+0x1d0>
    goto bad;
801060ec:	90                   	nop

bad:
  iunlockput(dp);
801060ed:	83 ec 0c             	sub    $0xc,%esp
801060f0:	ff 75 f4             	pushl  -0xc(%ebp)
801060f3:	e8 9e bc ff ff       	call   80101d96 <iunlockput>
801060f8:	83 c4 10             	add    $0x10,%esp
  end_op();
801060fb:	e8 de d6 ff ff       	call   801037de <end_op>
  return -1;
80106100:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106105:	c9                   	leave  
80106106:	c3                   	ret    

80106107 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106107:	f3 0f 1e fb          	endbr32 
8010610b:	55                   	push   %ebp
8010610c:	89 e5                	mov    %esp,%ebp
8010610e:	83 ec 38             	sub    $0x38,%esp
80106111:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106114:	8b 55 10             	mov    0x10(%ebp),%edx
80106117:	8b 45 14             	mov    0x14(%ebp),%eax
8010611a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010611e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106122:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106126:	83 ec 08             	sub    $0x8,%esp
80106129:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010612c:	50                   	push   %eax
8010612d:	ff 75 08             	pushl  0x8(%ebp)
80106130:	e8 af c5 ff ff       	call   801026e4 <nameiparent>
80106135:	83 c4 10             	add    $0x10,%esp
80106138:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010613b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010613f:	75 0a                	jne    8010614b <create+0x44>
    return 0;
80106141:	b8 00 00 00 00       	mov    $0x0,%eax
80106146:	e9 8e 01 00 00       	jmp    801062d9 <create+0x1d2>
  ilock(dp);
8010614b:	83 ec 0c             	sub    $0xc,%esp
8010614e:	ff 75 f4             	pushl  -0xc(%ebp)
80106151:	e8 03 ba ff ff       	call   80101b59 <ilock>
80106156:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80106159:	83 ec 04             	sub    $0x4,%esp
8010615c:	6a 00                	push   $0x0
8010615e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106161:	50                   	push   %eax
80106162:	ff 75 f4             	pushl  -0xc(%ebp)
80106165:	e8 f9 c1 ff ff       	call   80102363 <dirlookup>
8010616a:	83 c4 10             	add    $0x10,%esp
8010616d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106170:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106174:	74 50                	je     801061c6 <create+0xbf>
    iunlockput(dp);
80106176:	83 ec 0c             	sub    $0xc,%esp
80106179:	ff 75 f4             	pushl  -0xc(%ebp)
8010617c:	e8 15 bc ff ff       	call   80101d96 <iunlockput>
80106181:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106184:	83 ec 0c             	sub    $0xc,%esp
80106187:	ff 75 f0             	pushl  -0x10(%ebp)
8010618a:	e8 ca b9 ff ff       	call   80101b59 <ilock>
8010618f:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106192:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106197:	75 15                	jne    801061ae <create+0xa7>
80106199:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010619c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801061a0:	66 83 f8 02          	cmp    $0x2,%ax
801061a4:	75 08                	jne    801061ae <create+0xa7>
      return ip;
801061a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a9:	e9 2b 01 00 00       	jmp    801062d9 <create+0x1d2>
    iunlockput(ip);
801061ae:	83 ec 0c             	sub    $0xc,%esp
801061b1:	ff 75 f0             	pushl  -0x10(%ebp)
801061b4:	e8 dd bb ff ff       	call   80101d96 <iunlockput>
801061b9:	83 c4 10             	add    $0x10,%esp
    return 0;
801061bc:	b8 00 00 00 00       	mov    $0x0,%eax
801061c1:	e9 13 01 00 00       	jmp    801062d9 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801061c6:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801061ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061cd:	8b 00                	mov    (%eax),%eax
801061cf:	83 ec 08             	sub    $0x8,%esp
801061d2:	52                   	push   %edx
801061d3:	50                   	push   %eax
801061d4:	e8 bc b6 ff ff       	call   80101895 <ialloc>
801061d9:	83 c4 10             	add    $0x10,%esp
801061dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061e3:	75 0d                	jne    801061f2 <create+0xeb>
    panic("create: ialloc");
801061e5:	83 ec 0c             	sub    $0xc,%esp
801061e8:	68 80 97 10 80       	push   $0x80109780
801061ed:	e8 16 a4 ff ff       	call   80100608 <panic>

  ilock(ip);
801061f2:	83 ec 0c             	sub    $0xc,%esp
801061f5:	ff 75 f0             	pushl  -0x10(%ebp)
801061f8:	e8 5c b9 ff ff       	call   80101b59 <ilock>
801061fd:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106200:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106203:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106207:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010620b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106212:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80106216:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106219:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010621f:	83 ec 0c             	sub    $0xc,%esp
80106222:	ff 75 f0             	pushl  -0x10(%ebp)
80106225:	e8 46 b7 ff ff       	call   80101970 <iupdate>
8010622a:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010622d:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106232:	75 6a                	jne    8010629e <create+0x197>
    dp->nlink++;  // for ".."
80106234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106237:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010623b:	83 c0 01             	add    $0x1,%eax
8010623e:	89 c2                	mov    %eax,%edx
80106240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106243:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106247:	83 ec 0c             	sub    $0xc,%esp
8010624a:	ff 75 f4             	pushl  -0xc(%ebp)
8010624d:	e8 1e b7 ff ff       	call   80101970 <iupdate>
80106252:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106255:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106258:	8b 40 04             	mov    0x4(%eax),%eax
8010625b:	83 ec 04             	sub    $0x4,%esp
8010625e:	50                   	push   %eax
8010625f:	68 5a 97 10 80       	push   $0x8010975a
80106264:	ff 75 f0             	pushl  -0x10(%ebp)
80106267:	e8 b5 c1 ff ff       	call   80102421 <dirlink>
8010626c:	83 c4 10             	add    $0x10,%esp
8010626f:	85 c0                	test   %eax,%eax
80106271:	78 1e                	js     80106291 <create+0x18a>
80106273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106276:	8b 40 04             	mov    0x4(%eax),%eax
80106279:	83 ec 04             	sub    $0x4,%esp
8010627c:	50                   	push   %eax
8010627d:	68 5c 97 10 80       	push   $0x8010975c
80106282:	ff 75 f0             	pushl  -0x10(%ebp)
80106285:	e8 97 c1 ff ff       	call   80102421 <dirlink>
8010628a:	83 c4 10             	add    $0x10,%esp
8010628d:	85 c0                	test   %eax,%eax
8010628f:	79 0d                	jns    8010629e <create+0x197>
      panic("create dots");
80106291:	83 ec 0c             	sub    $0xc,%esp
80106294:	68 8f 97 10 80       	push   $0x8010978f
80106299:	e8 6a a3 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010629e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a1:	8b 40 04             	mov    0x4(%eax),%eax
801062a4:	83 ec 04             	sub    $0x4,%esp
801062a7:	50                   	push   %eax
801062a8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801062ab:	50                   	push   %eax
801062ac:	ff 75 f4             	pushl  -0xc(%ebp)
801062af:	e8 6d c1 ff ff       	call   80102421 <dirlink>
801062b4:	83 c4 10             	add    $0x10,%esp
801062b7:	85 c0                	test   %eax,%eax
801062b9:	79 0d                	jns    801062c8 <create+0x1c1>
    panic("create: dirlink");
801062bb:	83 ec 0c             	sub    $0xc,%esp
801062be:	68 9b 97 10 80       	push   $0x8010979b
801062c3:	e8 40 a3 ff ff       	call   80100608 <panic>

  iunlockput(dp);
801062c8:	83 ec 0c             	sub    $0xc,%esp
801062cb:	ff 75 f4             	pushl  -0xc(%ebp)
801062ce:	e8 c3 ba ff ff       	call   80101d96 <iunlockput>
801062d3:	83 c4 10             	add    $0x10,%esp

  return ip;
801062d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801062d9:	c9                   	leave  
801062da:	c3                   	ret    

801062db <sys_open>:

int
sys_open(void)
{
801062db:	f3 0f 1e fb          	endbr32 
801062df:	55                   	push   %ebp
801062e0:	89 e5                	mov    %esp,%ebp
801062e2:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062e5:	83 ec 08             	sub    $0x8,%esp
801062e8:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062eb:	50                   	push   %eax
801062ec:	6a 00                	push   $0x0
801062ee:	e8 b4 f6 ff ff       	call   801059a7 <argstr>
801062f3:	83 c4 10             	add    $0x10,%esp
801062f6:	85 c0                	test   %eax,%eax
801062f8:	78 15                	js     8010630f <sys_open+0x34>
801062fa:	83 ec 08             	sub    $0x8,%esp
801062fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106300:	50                   	push   %eax
80106301:	6a 01                	push   $0x1
80106303:	e8 02 f6 ff ff       	call   8010590a <argint>
80106308:	83 c4 10             	add    $0x10,%esp
8010630b:	85 c0                	test   %eax,%eax
8010630d:	79 0a                	jns    80106319 <sys_open+0x3e>
    return -1;
8010630f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106314:	e9 61 01 00 00       	jmp    8010647a <sys_open+0x19f>

  begin_op();
80106319:	e8 30 d4 ff ff       	call   8010374e <begin_op>

  if(omode & O_CREATE){
8010631e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106321:	25 00 02 00 00       	and    $0x200,%eax
80106326:	85 c0                	test   %eax,%eax
80106328:	74 2a                	je     80106354 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
8010632a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010632d:	6a 00                	push   $0x0
8010632f:	6a 00                	push   $0x0
80106331:	6a 02                	push   $0x2
80106333:	50                   	push   %eax
80106334:	e8 ce fd ff ff       	call   80106107 <create>
80106339:	83 c4 10             	add    $0x10,%esp
8010633c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010633f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106343:	75 75                	jne    801063ba <sys_open+0xdf>
      end_op();
80106345:	e8 94 d4 ff ff       	call   801037de <end_op>
      return -1;
8010634a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634f:	e9 26 01 00 00       	jmp    8010647a <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80106354:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106357:	83 ec 0c             	sub    $0xc,%esp
8010635a:	50                   	push   %eax
8010635b:	e8 64 c3 ff ff       	call   801026c4 <namei>
80106360:	83 c4 10             	add    $0x10,%esp
80106363:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106366:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010636a:	75 0f                	jne    8010637b <sys_open+0xa0>
      end_op();
8010636c:	e8 6d d4 ff ff       	call   801037de <end_op>
      return -1;
80106371:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106376:	e9 ff 00 00 00       	jmp    8010647a <sys_open+0x19f>
    }
    ilock(ip);
8010637b:	83 ec 0c             	sub    $0xc,%esp
8010637e:	ff 75 f4             	pushl  -0xc(%ebp)
80106381:	e8 d3 b7 ff ff       	call   80101b59 <ilock>
80106386:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010638c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106390:	66 83 f8 01          	cmp    $0x1,%ax
80106394:	75 24                	jne    801063ba <sys_open+0xdf>
80106396:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106399:	85 c0                	test   %eax,%eax
8010639b:	74 1d                	je     801063ba <sys_open+0xdf>
      iunlockput(ip);
8010639d:	83 ec 0c             	sub    $0xc,%esp
801063a0:	ff 75 f4             	pushl  -0xc(%ebp)
801063a3:	e8 ee b9 ff ff       	call   80101d96 <iunlockput>
801063a8:	83 c4 10             	add    $0x10,%esp
      end_op();
801063ab:	e8 2e d4 ff ff       	call   801037de <end_op>
      return -1;
801063b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b5:	e9 c0 00 00 00       	jmp    8010647a <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801063ba:	e8 54 ad ff ff       	call   80101113 <filealloc>
801063bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063c6:	74 17                	je     801063df <sys_open+0x104>
801063c8:	83 ec 0c             	sub    $0xc,%esp
801063cb:	ff 75 f0             	pushl  -0x10(%ebp)
801063ce:	e8 09 f7 ff ff       	call   80105adc <fdalloc>
801063d3:	83 c4 10             	add    $0x10,%esp
801063d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801063d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063dd:	79 2e                	jns    8010640d <sys_open+0x132>
    if(f)
801063df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063e3:	74 0e                	je     801063f3 <sys_open+0x118>
      fileclose(f);
801063e5:	83 ec 0c             	sub    $0xc,%esp
801063e8:	ff 75 f0             	pushl  -0x10(%ebp)
801063eb:	e8 e9 ad ff ff       	call   801011d9 <fileclose>
801063f0:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801063f3:	83 ec 0c             	sub    $0xc,%esp
801063f6:	ff 75 f4             	pushl  -0xc(%ebp)
801063f9:	e8 98 b9 ff ff       	call   80101d96 <iunlockput>
801063fe:	83 c4 10             	add    $0x10,%esp
    end_op();
80106401:	e8 d8 d3 ff ff       	call   801037de <end_op>
    return -1;
80106406:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640b:	eb 6d                	jmp    8010647a <sys_open+0x19f>
  }
  iunlock(ip);
8010640d:	83 ec 0c             	sub    $0xc,%esp
80106410:	ff 75 f4             	pushl  -0xc(%ebp)
80106413:	e8 58 b8 ff ff       	call   80101c70 <iunlock>
80106418:	83 c4 10             	add    $0x10,%esp
  end_op();
8010641b:	e8 be d3 ff ff       	call   801037de <end_op>

  f->type = FD_INODE;
80106420:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106423:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010642f:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106432:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106435:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010643c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010643f:	83 e0 01             	and    $0x1,%eax
80106442:	85 c0                	test   %eax,%eax
80106444:	0f 94 c0             	sete   %al
80106447:	89 c2                	mov    %eax,%edx
80106449:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010644c:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010644f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106452:	83 e0 01             	and    $0x1,%eax
80106455:	85 c0                	test   %eax,%eax
80106457:	75 0a                	jne    80106463 <sys_open+0x188>
80106459:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010645c:	83 e0 02             	and    $0x2,%eax
8010645f:	85 c0                	test   %eax,%eax
80106461:	74 07                	je     8010646a <sys_open+0x18f>
80106463:	b8 01 00 00 00       	mov    $0x1,%eax
80106468:	eb 05                	jmp    8010646f <sys_open+0x194>
8010646a:	b8 00 00 00 00       	mov    $0x0,%eax
8010646f:	89 c2                	mov    %eax,%edx
80106471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106474:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106477:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010647a:	c9                   	leave  
8010647b:	c3                   	ret    

8010647c <sys_mkdir>:

int
sys_mkdir(void)
{
8010647c:	f3 0f 1e fb          	endbr32 
80106480:	55                   	push   %ebp
80106481:	89 e5                	mov    %esp,%ebp
80106483:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106486:	e8 c3 d2 ff ff       	call   8010374e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010648b:	83 ec 08             	sub    $0x8,%esp
8010648e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106491:	50                   	push   %eax
80106492:	6a 00                	push   $0x0
80106494:	e8 0e f5 ff ff       	call   801059a7 <argstr>
80106499:	83 c4 10             	add    $0x10,%esp
8010649c:	85 c0                	test   %eax,%eax
8010649e:	78 1b                	js     801064bb <sys_mkdir+0x3f>
801064a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064a3:	6a 00                	push   $0x0
801064a5:	6a 00                	push   $0x0
801064a7:	6a 01                	push   $0x1
801064a9:	50                   	push   %eax
801064aa:	e8 58 fc ff ff       	call   80106107 <create>
801064af:	83 c4 10             	add    $0x10,%esp
801064b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064b9:	75 0c                	jne    801064c7 <sys_mkdir+0x4b>
    end_op();
801064bb:	e8 1e d3 ff ff       	call   801037de <end_op>
    return -1;
801064c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c5:	eb 18                	jmp    801064df <sys_mkdir+0x63>
  }
  iunlockput(ip);
801064c7:	83 ec 0c             	sub    $0xc,%esp
801064ca:	ff 75 f4             	pushl  -0xc(%ebp)
801064cd:	e8 c4 b8 ff ff       	call   80101d96 <iunlockput>
801064d2:	83 c4 10             	add    $0x10,%esp
  end_op();
801064d5:	e8 04 d3 ff ff       	call   801037de <end_op>
  return 0;
801064da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064df:	c9                   	leave  
801064e0:	c3                   	ret    

801064e1 <sys_mknod>:

int
sys_mknod(void)
{
801064e1:	f3 0f 1e fb          	endbr32 
801064e5:	55                   	push   %ebp
801064e6:	89 e5                	mov    %esp,%ebp
801064e8:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801064eb:	e8 5e d2 ff ff       	call   8010374e <begin_op>
  if((argstr(0, &path)) < 0 ||
801064f0:	83 ec 08             	sub    $0x8,%esp
801064f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064f6:	50                   	push   %eax
801064f7:	6a 00                	push   $0x0
801064f9:	e8 a9 f4 ff ff       	call   801059a7 <argstr>
801064fe:	83 c4 10             	add    $0x10,%esp
80106501:	85 c0                	test   %eax,%eax
80106503:	78 4f                	js     80106554 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80106505:	83 ec 08             	sub    $0x8,%esp
80106508:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010650b:	50                   	push   %eax
8010650c:	6a 01                	push   $0x1
8010650e:	e8 f7 f3 ff ff       	call   8010590a <argint>
80106513:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106516:	85 c0                	test   %eax,%eax
80106518:	78 3a                	js     80106554 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
8010651a:	83 ec 08             	sub    $0x8,%esp
8010651d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106520:	50                   	push   %eax
80106521:	6a 02                	push   $0x2
80106523:	e8 e2 f3 ff ff       	call   8010590a <argint>
80106528:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010652b:	85 c0                	test   %eax,%eax
8010652d:	78 25                	js     80106554 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010652f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106532:	0f bf c8             	movswl %ax,%ecx
80106535:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106538:	0f bf d0             	movswl %ax,%edx
8010653b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010653e:	51                   	push   %ecx
8010653f:	52                   	push   %edx
80106540:	6a 03                	push   $0x3
80106542:	50                   	push   %eax
80106543:	e8 bf fb ff ff       	call   80106107 <create>
80106548:	83 c4 10             	add    $0x10,%esp
8010654b:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010654e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106552:	75 0c                	jne    80106560 <sys_mknod+0x7f>
    end_op();
80106554:	e8 85 d2 ff ff       	call   801037de <end_op>
    return -1;
80106559:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655e:	eb 18                	jmp    80106578 <sys_mknod+0x97>
  }
  iunlockput(ip);
80106560:	83 ec 0c             	sub    $0xc,%esp
80106563:	ff 75 f4             	pushl  -0xc(%ebp)
80106566:	e8 2b b8 ff ff       	call   80101d96 <iunlockput>
8010656b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010656e:	e8 6b d2 ff ff       	call   801037de <end_op>
  return 0;
80106573:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106578:	c9                   	leave  
80106579:	c3                   	ret    

8010657a <sys_chdir>:

int
sys_chdir(void)
{
8010657a:	f3 0f 1e fb          	endbr32 
8010657e:	55                   	push   %ebp
8010657f:	89 e5                	mov    %esp,%ebp
80106581:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106584:	e8 84 df ff ff       	call   8010450d <myproc>
80106589:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010658c:	e8 bd d1 ff ff       	call   8010374e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106591:	83 ec 08             	sub    $0x8,%esp
80106594:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106597:	50                   	push   %eax
80106598:	6a 00                	push   $0x0
8010659a:	e8 08 f4 ff ff       	call   801059a7 <argstr>
8010659f:	83 c4 10             	add    $0x10,%esp
801065a2:	85 c0                	test   %eax,%eax
801065a4:	78 18                	js     801065be <sys_chdir+0x44>
801065a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065a9:	83 ec 0c             	sub    $0xc,%esp
801065ac:	50                   	push   %eax
801065ad:	e8 12 c1 ff ff       	call   801026c4 <namei>
801065b2:	83 c4 10             	add    $0x10,%esp
801065b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065bc:	75 0c                	jne    801065ca <sys_chdir+0x50>
    end_op();
801065be:	e8 1b d2 ff ff       	call   801037de <end_op>
    return -1;
801065c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c8:	eb 68                	jmp    80106632 <sys_chdir+0xb8>
  }
  ilock(ip);
801065ca:	83 ec 0c             	sub    $0xc,%esp
801065cd:	ff 75 f0             	pushl  -0x10(%ebp)
801065d0:	e8 84 b5 ff ff       	call   80101b59 <ilock>
801065d5:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801065d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065db:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801065df:	66 83 f8 01          	cmp    $0x1,%ax
801065e3:	74 1a                	je     801065ff <sys_chdir+0x85>
    iunlockput(ip);
801065e5:	83 ec 0c             	sub    $0xc,%esp
801065e8:	ff 75 f0             	pushl  -0x10(%ebp)
801065eb:	e8 a6 b7 ff ff       	call   80101d96 <iunlockput>
801065f0:	83 c4 10             	add    $0x10,%esp
    end_op();
801065f3:	e8 e6 d1 ff ff       	call   801037de <end_op>
    return -1;
801065f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065fd:	eb 33                	jmp    80106632 <sys_chdir+0xb8>
  }
  iunlock(ip);
801065ff:	83 ec 0c             	sub    $0xc,%esp
80106602:	ff 75 f0             	pushl  -0x10(%ebp)
80106605:	e8 66 b6 ff ff       	call   80101c70 <iunlock>
8010660a:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010660d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106610:	8b 40 68             	mov    0x68(%eax),%eax
80106613:	83 ec 0c             	sub    $0xc,%esp
80106616:	50                   	push   %eax
80106617:	e8 a6 b6 ff ff       	call   80101cc2 <iput>
8010661c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010661f:	e8 ba d1 ff ff       	call   801037de <end_op>
  curproc->cwd = ip;
80106624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106627:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010662a:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010662d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106632:	c9                   	leave  
80106633:	c3                   	ret    

80106634 <sys_exec>:

int
sys_exec(void)
{
80106634:	f3 0f 1e fb          	endbr32 
80106638:	55                   	push   %ebp
80106639:	89 e5                	mov    %esp,%ebp
8010663b:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106641:	83 ec 08             	sub    $0x8,%esp
80106644:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106647:	50                   	push   %eax
80106648:	6a 00                	push   $0x0
8010664a:	e8 58 f3 ff ff       	call   801059a7 <argstr>
8010664f:	83 c4 10             	add    $0x10,%esp
80106652:	85 c0                	test   %eax,%eax
80106654:	78 18                	js     8010666e <sys_exec+0x3a>
80106656:	83 ec 08             	sub    $0x8,%esp
80106659:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010665f:	50                   	push   %eax
80106660:	6a 01                	push   $0x1
80106662:	e8 a3 f2 ff ff       	call   8010590a <argint>
80106667:	83 c4 10             	add    $0x10,%esp
8010666a:	85 c0                	test   %eax,%eax
8010666c:	79 0a                	jns    80106678 <sys_exec+0x44>
    return -1;
8010666e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106673:	e9 c6 00 00 00       	jmp    8010673e <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106678:	83 ec 04             	sub    $0x4,%esp
8010667b:	68 80 00 00 00       	push   $0x80
80106680:	6a 00                	push   $0x0
80106682:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106688:	50                   	push   %eax
80106689:	e8 28 ef ff ff       	call   801055b6 <memset>
8010668e:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010669b:	83 f8 1f             	cmp    $0x1f,%eax
8010669e:	76 0a                	jbe    801066aa <sys_exec+0x76>
      return -1;
801066a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a5:	e9 94 00 00 00       	jmp    8010673e <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801066aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ad:	c1 e0 02             	shl    $0x2,%eax
801066b0:	89 c2                	mov    %eax,%edx
801066b2:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801066b8:	01 c2                	add    %eax,%edx
801066ba:	83 ec 08             	sub    $0x8,%esp
801066bd:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801066c3:	50                   	push   %eax
801066c4:	52                   	push   %edx
801066c5:	e8 95 f1 ff ff       	call   8010585f <fetchint>
801066ca:	83 c4 10             	add    $0x10,%esp
801066cd:	85 c0                	test   %eax,%eax
801066cf:	79 07                	jns    801066d8 <sys_exec+0xa4>
      return -1;
801066d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066d6:	eb 66                	jmp    8010673e <sys_exec+0x10a>
    if(uarg == 0){
801066d8:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066de:	85 c0                	test   %eax,%eax
801066e0:	75 27                	jne    80106709 <sys_exec+0xd5>
      argv[i] = 0;
801066e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e5:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801066ec:	00 00 00 00 
      break;
801066f0:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801066f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066f4:	83 ec 08             	sub    $0x8,%esp
801066f7:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066fd:	52                   	push   %edx
801066fe:	50                   	push   %eax
801066ff:	e8 2c a5 ff ff       	call   80100c30 <exec>
80106704:	83 c4 10             	add    $0x10,%esp
80106707:	eb 35                	jmp    8010673e <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80106709:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010670f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106712:	c1 e2 02             	shl    $0x2,%edx
80106715:	01 c2                	add    %eax,%edx
80106717:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010671d:	83 ec 08             	sub    $0x8,%esp
80106720:	52                   	push   %edx
80106721:	50                   	push   %eax
80106722:	e8 7b f1 ff ff       	call   801058a2 <fetchstr>
80106727:	83 c4 10             	add    $0x10,%esp
8010672a:	85 c0                	test   %eax,%eax
8010672c:	79 07                	jns    80106735 <sys_exec+0x101>
      return -1;
8010672e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106733:	eb 09                	jmp    8010673e <sys_exec+0x10a>
  for(i=0;; i++){
80106735:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106739:	e9 5a ff ff ff       	jmp    80106698 <sys_exec+0x64>
}
8010673e:	c9                   	leave  
8010673f:	c3                   	ret    

80106740 <sys_pipe>:

int
sys_pipe(void)
{
80106740:	f3 0f 1e fb          	endbr32 
80106744:	55                   	push   %ebp
80106745:	89 e5                	mov    %esp,%ebp
80106747:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010674a:	83 ec 04             	sub    $0x4,%esp
8010674d:	6a 08                	push   $0x8
8010674f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106752:	50                   	push   %eax
80106753:	6a 00                	push   $0x0
80106755:	e8 e1 f1 ff ff       	call   8010593b <argptr>
8010675a:	83 c4 10             	add    $0x10,%esp
8010675d:	85 c0                	test   %eax,%eax
8010675f:	79 0a                	jns    8010676b <sys_pipe+0x2b>
    return -1;
80106761:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106766:	e9 ae 00 00 00       	jmp    80106819 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
8010676b:	83 ec 08             	sub    $0x8,%esp
8010676e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106771:	50                   	push   %eax
80106772:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106775:	50                   	push   %eax
80106776:	e8 b3 d8 ff ff       	call   8010402e <pipealloc>
8010677b:	83 c4 10             	add    $0x10,%esp
8010677e:	85 c0                	test   %eax,%eax
80106780:	79 0a                	jns    8010678c <sys_pipe+0x4c>
    return -1;
80106782:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106787:	e9 8d 00 00 00       	jmp    80106819 <sys_pipe+0xd9>
  fd0 = -1;
8010678c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106793:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106796:	83 ec 0c             	sub    $0xc,%esp
80106799:	50                   	push   %eax
8010679a:	e8 3d f3 ff ff       	call   80105adc <fdalloc>
8010679f:	83 c4 10             	add    $0x10,%esp
801067a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067a9:	78 18                	js     801067c3 <sys_pipe+0x83>
801067ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067ae:	83 ec 0c             	sub    $0xc,%esp
801067b1:	50                   	push   %eax
801067b2:	e8 25 f3 ff ff       	call   80105adc <fdalloc>
801067b7:	83 c4 10             	add    $0x10,%esp
801067ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067c1:	79 3e                	jns    80106801 <sys_pipe+0xc1>
    if(fd0 >= 0)
801067c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067c7:	78 13                	js     801067dc <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
801067c9:	e8 3f dd ff ff       	call   8010450d <myproc>
801067ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067d1:	83 c2 08             	add    $0x8,%edx
801067d4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801067db:	00 
    fileclose(rf);
801067dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067df:	83 ec 0c             	sub    $0xc,%esp
801067e2:	50                   	push   %eax
801067e3:	e8 f1 a9 ff ff       	call   801011d9 <fileclose>
801067e8:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801067eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067ee:	83 ec 0c             	sub    $0xc,%esp
801067f1:	50                   	push   %eax
801067f2:	e8 e2 a9 ff ff       	call   801011d9 <fileclose>
801067f7:	83 c4 10             	add    $0x10,%esp
    return -1;
801067fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ff:	eb 18                	jmp    80106819 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106801:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106804:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106807:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106809:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010680c:	8d 50 04             	lea    0x4(%eax),%edx
8010680f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106812:	89 02                	mov    %eax,(%edx)
  return 0;
80106814:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106819:	c9                   	leave  
8010681a:	c3                   	ret    

8010681b <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010681b:	f3 0f 1e fb          	endbr32 
8010681f:	55                   	push   %ebp
80106820:	89 e5                	mov    %esp,%ebp
80106822:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106825:	e8 ac e0 ff ff       	call   801048d6 <fork>
}
8010682a:	c9                   	leave  
8010682b:	c3                   	ret    

8010682c <sys_exit>:

int
sys_exit(void)
{
8010682c:	f3 0f 1e fb          	endbr32 
80106830:	55                   	push   %ebp
80106831:	89 e5                	mov    %esp,%ebp
80106833:	83 ec 08             	sub    $0x8,%esp
  exit();
80106836:	e8 18 e2 ff ff       	call   80104a53 <exit>
  return 0;  // not reached
8010683b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106840:	c9                   	leave  
80106841:	c3                   	ret    

80106842 <sys_wait>:

int
sys_wait(void)
{
80106842:	f3 0f 1e fb          	endbr32 
80106846:	55                   	push   %ebp
80106847:	89 e5                	mov    %esp,%ebp
80106849:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010684c:	e8 29 e3 ff ff       	call   80104b7a <wait>
}
80106851:	c9                   	leave  
80106852:	c3                   	ret    

80106853 <sys_kill>:

int
sys_kill(void)
{
80106853:	f3 0f 1e fb          	endbr32 
80106857:	55                   	push   %ebp
80106858:	89 e5                	mov    %esp,%ebp
8010685a:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010685d:	83 ec 08             	sub    $0x8,%esp
80106860:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106863:	50                   	push   %eax
80106864:	6a 00                	push   $0x0
80106866:	e8 9f f0 ff ff       	call   8010590a <argint>
8010686b:	83 c4 10             	add    $0x10,%esp
8010686e:	85 c0                	test   %eax,%eax
80106870:	79 07                	jns    80106879 <sys_kill+0x26>
    return -1;
80106872:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106877:	eb 0f                	jmp    80106888 <sys_kill+0x35>
  return kill(pid);
80106879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010687c:	83 ec 0c             	sub    $0xc,%esp
8010687f:	50                   	push   %eax
80106880:	e8 4d e7 ff ff       	call   80104fd2 <kill>
80106885:	83 c4 10             	add    $0x10,%esp
}
80106888:	c9                   	leave  
80106889:	c3                   	ret    

8010688a <sys_getpid>:

int
sys_getpid(void)
{
8010688a:	f3 0f 1e fb          	endbr32 
8010688e:	55                   	push   %ebp
8010688f:	89 e5                	mov    %esp,%ebp
80106891:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106894:	e8 74 dc ff ff       	call   8010450d <myproc>
80106899:	8b 40 10             	mov    0x10(%eax),%eax
}
8010689c:	c9                   	leave  
8010689d:	c3                   	ret    

8010689e <sys_sbrk>:

int
sys_sbrk(void)
{
8010689e:	f3 0f 1e fb          	endbr32 
801068a2:	55                   	push   %ebp
801068a3:	89 e5                	mov    %esp,%ebp
801068a5:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801068a8:	83 ec 08             	sub    $0x8,%esp
801068ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068ae:	50                   	push   %eax
801068af:	6a 00                	push   $0x0
801068b1:	e8 54 f0 ff ff       	call   8010590a <argint>
801068b6:	83 c4 10             	add    $0x10,%esp
801068b9:	85 c0                	test   %eax,%eax
801068bb:	79 07                	jns    801068c4 <sys_sbrk+0x26>
    return -1;
801068bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068c2:	eb 27                	jmp    801068eb <sys_sbrk+0x4d>
  addr = myproc()->sz;
801068c4:	e8 44 dc ff ff       	call   8010450d <myproc>
801068c9:	8b 00                	mov    (%eax),%eax
801068cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801068ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068d1:	83 ec 0c             	sub    $0xc,%esp
801068d4:	50                   	push   %eax
801068d5:	e8 aa de ff ff       	call   80104784 <growproc>
801068da:	83 c4 10             	add    $0x10,%esp
801068dd:	85 c0                	test   %eax,%eax
801068df:	79 07                	jns    801068e8 <sys_sbrk+0x4a>
    return -1;
801068e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068e6:	eb 03                	jmp    801068eb <sys_sbrk+0x4d>
  return addr;
801068e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068eb:	c9                   	leave  
801068ec:	c3                   	ret    

801068ed <sys_sleep>:

int
sys_sleep(void)
{
801068ed:	f3 0f 1e fb          	endbr32 
801068f1:	55                   	push   %ebp
801068f2:	89 e5                	mov    %esp,%ebp
801068f4:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801068f7:	83 ec 08             	sub    $0x8,%esp
801068fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068fd:	50                   	push   %eax
801068fe:	6a 00                	push   $0x0
80106900:	e8 05 f0 ff ff       	call   8010590a <argint>
80106905:	83 c4 10             	add    $0x10,%esp
80106908:	85 c0                	test   %eax,%eax
8010690a:	79 07                	jns    80106913 <sys_sleep+0x26>
    return -1;
8010690c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106911:	eb 76                	jmp    80106989 <sys_sleep+0x9c>
  acquire(&tickslock);
80106913:	83 ec 0c             	sub    $0xc,%esp
80106916:	68 00 77 11 80       	push   $0x80117700
8010691b:	e8 f7 e9 ff ff       	call   80105317 <acquire>
80106920:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106923:	a1 40 7f 11 80       	mov    0x80117f40,%eax
80106928:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010692b:	eb 38                	jmp    80106965 <sys_sleep+0x78>
    if(myproc()->killed){
8010692d:	e8 db db ff ff       	call   8010450d <myproc>
80106932:	8b 40 24             	mov    0x24(%eax),%eax
80106935:	85 c0                	test   %eax,%eax
80106937:	74 17                	je     80106950 <sys_sleep+0x63>
      release(&tickslock);
80106939:	83 ec 0c             	sub    $0xc,%esp
8010693c:	68 00 77 11 80       	push   $0x80117700
80106941:	e8 43 ea ff ff       	call   80105389 <release>
80106946:	83 c4 10             	add    $0x10,%esp
      return -1;
80106949:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010694e:	eb 39                	jmp    80106989 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106950:	83 ec 08             	sub    $0x8,%esp
80106953:	68 00 77 11 80       	push   $0x80117700
80106958:	68 40 7f 11 80       	push   $0x80117f40
8010695d:	e8 43 e5 ff ff       	call   80104ea5 <sleep>
80106962:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106965:	a1 40 7f 11 80       	mov    0x80117f40,%eax
8010696a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010696d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106970:	39 d0                	cmp    %edx,%eax
80106972:	72 b9                	jb     8010692d <sys_sleep+0x40>
  }
  release(&tickslock);
80106974:	83 ec 0c             	sub    $0xc,%esp
80106977:	68 00 77 11 80       	push   $0x80117700
8010697c:	e8 08 ea ff ff       	call   80105389 <release>
80106981:	83 c4 10             	add    $0x10,%esp
  return 0;
80106984:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106989:	c9                   	leave  
8010698a:	c3                   	ret    

8010698b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010698b:	f3 0f 1e fb          	endbr32 
8010698f:	55                   	push   %ebp
80106990:	89 e5                	mov    %esp,%ebp
80106992:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106995:	83 ec 0c             	sub    $0xc,%esp
80106998:	68 00 77 11 80       	push   $0x80117700
8010699d:	e8 75 e9 ff ff       	call   80105317 <acquire>
801069a2:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801069a5:	a1 40 7f 11 80       	mov    0x80117f40,%eax
801069aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801069ad:	83 ec 0c             	sub    $0xc,%esp
801069b0:	68 00 77 11 80       	push   $0x80117700
801069b5:	e8 cf e9 ff ff       	call   80105389 <release>
801069ba:	83 c4 10             	add    $0x10,%esp
  return xticks;
801069bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801069c0:	c9                   	leave  
801069c1:	c3                   	ret    

801069c2 <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
801069c2:	f3 0f 1e fb          	endbr32 
801069c6:	55                   	push   %ebp
801069c7:	89 e5                	mov    %esp,%ebp
801069c9:	83 ec 18             	sub    $0x18,%esp
  int len;
  char * virtual_addr;

  if(argint(1, &len) < 0)
801069cc:	83 ec 08             	sub    $0x8,%esp
801069cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069d2:	50                   	push   %eax
801069d3:	6a 01                	push   $0x1
801069d5:	e8 30 ef ff ff       	call   8010590a <argint>
801069da:	83 c4 10             	add    $0x10,%esp
801069dd:	85 c0                	test   %eax,%eax
801069df:	79 07                	jns    801069e8 <sys_mencrypt+0x26>
    return -1;
801069e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e6:	eb 50                	jmp    80106a38 <sys_mencrypt+0x76>
  if (len <= 0) {
801069e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069eb:	85 c0                	test   %eax,%eax
801069ed:	7f 07                	jg     801069f6 <sys_mencrypt+0x34>
    return -1;
801069ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069f4:	eb 42                	jmp    80106a38 <sys_mencrypt+0x76>
  }
  if(argptr(0, &virtual_addr, 1) < 0)
801069f6:	83 ec 04             	sub    $0x4,%esp
801069f9:	6a 01                	push   $0x1
801069fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069fe:	50                   	push   %eax
801069ff:	6a 00                	push   $0x0
80106a01:	e8 35 ef ff ff       	call   8010593b <argptr>
80106a06:	83 c4 10             	add    $0x10,%esp
80106a09:	85 c0                	test   %eax,%eax
80106a0b:	79 07                	jns    80106a14 <sys_mencrypt+0x52>
    return -1;
80106a0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a12:	eb 24                	jmp    80106a38 <sys_mencrypt+0x76>
  if ((void *) virtual_addr >= P2V(PHYSTOP)) {
80106a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a17:	3d ff ff ff 8d       	cmp    $0x8dffffff,%eax
80106a1c:	76 07                	jbe    80106a25 <sys_mencrypt+0x63>
    return -1;
80106a1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a23:	eb 13                	jmp    80106a38 <sys_mencrypt+0x76>
  }
  return mencrypt(virtual_addr, len);
80106a25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a2b:	83 ec 08             	sub    $0x8,%esp
80106a2e:	52                   	push   %edx
80106a2f:	50                   	push   %eax
80106a30:	e8 5c 23 00 00       	call   80108d91 <mencrypt>
80106a35:	83 c4 10             	add    $0x10,%esp
}
80106a38:	c9                   	leave  
80106a39:	c3                   	ret    

80106a3a <sys_getpgtable>:

int sys_getpgtable(void) {
80106a3a:	f3 0f 1e fb          	endbr32 
80106a3e:	55                   	push   %ebp
80106a3f:	89 e5                	mov    %esp,%ebp
80106a41:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num;
  int wsetOnly;


  if(argint(2, &wsetOnly) < 0){
80106a44:	83 ec 08             	sub    $0x8,%esp
80106a47:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a4a:	50                   	push   %eax
80106a4b:	6a 02                	push   $0x2
80106a4d:	e8 b8 ee ff ff       	call   8010590a <argint>
80106a52:	83 c4 10             	add    $0x10,%esp
80106a55:	85 c0                	test   %eax,%eax
80106a57:	79 07                	jns    80106a60 <sys_getpgtable+0x26>
    return -1;
80106a59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a5e:	eb 56                	jmp    80106ab6 <sys_getpgtable+0x7c>
  }

  if(argint(1, &num) < 0)
80106a60:	83 ec 08             	sub    $0x8,%esp
80106a63:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a66:	50                   	push   %eax
80106a67:	6a 01                	push   $0x1
80106a69:	e8 9c ee ff ff       	call   8010590a <argint>
80106a6e:	83 c4 10             	add    $0x10,%esp
80106a71:	85 c0                	test   %eax,%eax
80106a73:	79 07                	jns    80106a7c <sys_getpgtable+0x42>
    return -1;
80106a75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a7a:	eb 3a                	jmp    80106ab6 <sys_getpgtable+0x7c>
  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
80106a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a7f:	c1 e0 03             	shl    $0x3,%eax
80106a82:	83 ec 04             	sub    $0x4,%esp
80106a85:	50                   	push   %eax
80106a86:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a89:	50                   	push   %eax
80106a8a:	6a 00                	push   $0x0
80106a8c:	e8 aa ee ff ff       	call   8010593b <argptr>
80106a91:	83 c4 10             	add    $0x10,%esp
80106a94:	85 c0                	test   %eax,%eax
80106a96:	79 07                	jns    80106a9f <sys_getpgtable+0x65>
    return -1;
80106a98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a9d:	eb 17                	jmp    80106ab6 <sys_getpgtable+0x7c>
  }
  return getpgtable(entries, num,wsetOnly);
80106a9f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106aa2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa8:	83 ec 04             	sub    $0x4,%esp
80106aab:	51                   	push   %ecx
80106aac:	52                   	push   %edx
80106aad:	50                   	push   %eax
80106aae:	e8 c3 24 00 00       	call   80108f76 <getpgtable>
80106ab3:	83 c4 10             	add    $0x10,%esp
}
80106ab6:	c9                   	leave  
80106ab7:	c3                   	ret    

80106ab8 <sys_dump_rawphymem>:


int sys_dump_rawphymem(void) {
80106ab8:	f3 0f 1e fb          	endbr32 
80106abc:	55                   	push   %ebp
80106abd:	89 e5                	mov    %esp,%ebp
80106abf:	83 ec 18             	sub    $0x18,%esp
  char * physical_addr; 
  char * buffer;

  if(argptr(1, &buffer, PGSIZE) < 0)
80106ac2:	83 ec 04             	sub    $0x4,%esp
80106ac5:	68 00 10 00 00       	push   $0x1000
80106aca:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106acd:	50                   	push   %eax
80106ace:	6a 01                	push   $0x1
80106ad0:	e8 66 ee ff ff       	call   8010593b <argptr>
80106ad5:	83 c4 10             	add    $0x10,%esp
80106ad8:	85 c0                	test   %eax,%eax
80106ada:	79 07                	jns    80106ae3 <sys_dump_rawphymem+0x2b>
    return -1;
80106adc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ae1:	eb 2f                	jmp    80106b12 <sys_dump_rawphymem+0x5a>
  if(argint(0, (int*)&physical_addr) < 0)
80106ae3:	83 ec 08             	sub    $0x8,%esp
80106ae6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ae9:	50                   	push   %eax
80106aea:	6a 00                	push   $0x0
80106aec:	e8 19 ee ff ff       	call   8010590a <argint>
80106af1:	83 c4 10             	add    $0x10,%esp
80106af4:	85 c0                	test   %eax,%eax
80106af6:	79 07                	jns    80106aff <sys_dump_rawphymem+0x47>
    return -1;
80106af8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106afd:	eb 13                	jmp    80106b12 <sys_dump_rawphymem+0x5a>
  return dump_rawphymem(physical_addr, buffer);
80106aff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b05:	83 ec 08             	sub    $0x8,%esp
80106b08:	52                   	push   %edx
80106b09:	50                   	push   %eax
80106b0a:	e8 cd 26 00 00       	call   801091dc <dump_rawphymem>
80106b0f:	83 c4 10             	add    $0x10,%esp
80106b12:	c9                   	leave  
80106b13:	c3                   	ret    

80106b14 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106b14:	1e                   	push   %ds
  pushl %es
80106b15:	06                   	push   %es
  pushl %fs
80106b16:	0f a0                	push   %fs
  pushl %gs
80106b18:	0f a8                	push   %gs
  pushal
80106b1a:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106b1b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106b1f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106b21:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106b23:	54                   	push   %esp
  call trap
80106b24:	e8 df 01 00 00       	call   80106d08 <trap>
  addl $4, %esp
80106b29:	83 c4 04             	add    $0x4,%esp

80106b2c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106b2c:	61                   	popa   
  popl %gs
80106b2d:	0f a9                	pop    %gs
  popl %fs
80106b2f:	0f a1                	pop    %fs
  popl %es
80106b31:	07                   	pop    %es
  popl %ds
80106b32:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b33:	83 c4 08             	add    $0x8,%esp
  iret
80106b36:	cf                   	iret   

80106b37 <lidt>:
{
80106b37:	55                   	push   %ebp
80106b38:	89 e5                	mov    %esp,%ebp
80106b3a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b40:	83 e8 01             	sub    $0x1,%eax
80106b43:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b47:	8b 45 08             	mov    0x8(%ebp),%eax
80106b4a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80106b51:	c1 e8 10             	shr    $0x10,%eax
80106b54:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106b58:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b5b:	0f 01 18             	lidtl  (%eax)
}
80106b5e:	90                   	nop
80106b5f:	c9                   	leave  
80106b60:	c3                   	ret    

80106b61 <rcr2>:

static inline uint
rcr2(void)
{
80106b61:	55                   	push   %ebp
80106b62:	89 e5                	mov    %esp,%ebp
80106b64:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b67:	0f 20 d0             	mov    %cr2,%eax
80106b6a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b70:	c9                   	leave  
80106b71:	c3                   	ret    

80106b72 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b72:	f3 0f 1e fb          	endbr32 
80106b76:	55                   	push   %ebp
80106b77:	89 e5                	mov    %esp,%ebp
80106b79:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b83:	e9 c3 00 00 00       	jmp    80106c4b <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b8b:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106b92:	89 c2                	mov    %eax,%edx
80106b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b97:	66 89 14 c5 40 77 11 	mov    %dx,-0x7fee88c0(,%eax,8)
80106b9e:	80 
80106b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba2:	66 c7 04 c5 42 77 11 	movw   $0x8,-0x7fee88be(,%eax,8)
80106ba9:	80 08 00 
80106bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106baf:	0f b6 14 c5 44 77 11 	movzbl -0x7fee88bc(,%eax,8),%edx
80106bb6:	80 
80106bb7:	83 e2 e0             	and    $0xffffffe0,%edx
80106bba:	88 14 c5 44 77 11 80 	mov    %dl,-0x7fee88bc(,%eax,8)
80106bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc4:	0f b6 14 c5 44 77 11 	movzbl -0x7fee88bc(,%eax,8),%edx
80106bcb:	80 
80106bcc:	83 e2 1f             	and    $0x1f,%edx
80106bcf:	88 14 c5 44 77 11 80 	mov    %dl,-0x7fee88bc(,%eax,8)
80106bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd9:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106be0:	80 
80106be1:	83 e2 f0             	and    $0xfffffff0,%edx
80106be4:	83 ca 0e             	or     $0xe,%edx
80106be7:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf1:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106bf8:	80 
80106bf9:	83 e2 ef             	and    $0xffffffef,%edx
80106bfc:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c06:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106c0d:	80 
80106c0e:	83 e2 9f             	and    $0xffffff9f,%edx
80106c11:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c1b:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106c22:	80 
80106c23:	83 ca 80             	or     $0xffffff80,%edx
80106c26:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c30:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106c37:	c1 e8 10             	shr    $0x10,%eax
80106c3a:	89 c2                	mov    %eax,%edx
80106c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c3f:	66 89 14 c5 46 77 11 	mov    %dx,-0x7fee88ba(,%eax,8)
80106c46:	80 
  for(i = 0; i < 256; i++)
80106c47:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c4b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c52:	0f 8e 30 ff ff ff    	jle    80106b88 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c58:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c5d:	66 a3 40 79 11 80    	mov    %ax,0x80117940
80106c63:	66 c7 05 42 79 11 80 	movw   $0x8,0x80117942
80106c6a:	08 00 
80106c6c:	0f b6 05 44 79 11 80 	movzbl 0x80117944,%eax
80106c73:	83 e0 e0             	and    $0xffffffe0,%eax
80106c76:	a2 44 79 11 80       	mov    %al,0x80117944
80106c7b:	0f b6 05 44 79 11 80 	movzbl 0x80117944,%eax
80106c82:	83 e0 1f             	and    $0x1f,%eax
80106c85:	a2 44 79 11 80       	mov    %al,0x80117944
80106c8a:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c91:	83 c8 0f             	or     $0xf,%eax
80106c94:	a2 45 79 11 80       	mov    %al,0x80117945
80106c99:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106ca0:	83 e0 ef             	and    $0xffffffef,%eax
80106ca3:	a2 45 79 11 80       	mov    %al,0x80117945
80106ca8:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106caf:	83 c8 60             	or     $0x60,%eax
80106cb2:	a2 45 79 11 80       	mov    %al,0x80117945
80106cb7:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106cbe:	83 c8 80             	or     $0xffffff80,%eax
80106cc1:	a2 45 79 11 80       	mov    %al,0x80117945
80106cc6:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106ccb:	c1 e8 10             	shr    $0x10,%eax
80106cce:	66 a3 46 79 11 80    	mov    %ax,0x80117946

  initlock(&tickslock, "time");
80106cd4:	83 ec 08             	sub    $0x8,%esp
80106cd7:	68 ac 97 10 80       	push   $0x801097ac
80106cdc:	68 00 77 11 80       	push   $0x80117700
80106ce1:	e8 0b e6 ff ff       	call   801052f1 <initlock>
80106ce6:	83 c4 10             	add    $0x10,%esp
}
80106ce9:	90                   	nop
80106cea:	c9                   	leave  
80106ceb:	c3                   	ret    

80106cec <idtinit>:

void
idtinit(void)
{
80106cec:	f3 0f 1e fb          	endbr32 
80106cf0:	55                   	push   %ebp
80106cf1:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106cf3:	68 00 08 00 00       	push   $0x800
80106cf8:	68 40 77 11 80       	push   $0x80117740
80106cfd:	e8 35 fe ff ff       	call   80106b37 <lidt>
80106d02:	83 c4 08             	add    $0x8,%esp
}
80106d05:	90                   	nop
80106d06:	c9                   	leave  
80106d07:	c3                   	ret    

80106d08 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106d08:	f3 0f 1e fb          	endbr32 
80106d0c:	55                   	push   %ebp
80106d0d:	89 e5                	mov    %esp,%ebp
80106d0f:	57                   	push   %edi
80106d10:	56                   	push   %esi
80106d11:	53                   	push   %ebx
80106d12:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106d15:	8b 45 08             	mov    0x8(%ebp),%eax
80106d18:	8b 40 30             	mov    0x30(%eax),%eax
80106d1b:	83 f8 40             	cmp    $0x40,%eax
80106d1e:	75 3b                	jne    80106d5b <trap+0x53>
    if(myproc()->killed)
80106d20:	e8 e8 d7 ff ff       	call   8010450d <myproc>
80106d25:	8b 40 24             	mov    0x24(%eax),%eax
80106d28:	85 c0                	test   %eax,%eax
80106d2a:	74 05                	je     80106d31 <trap+0x29>
      exit();
80106d2c:	e8 22 dd ff ff       	call   80104a53 <exit>
    myproc()->tf = tf;
80106d31:	e8 d7 d7 ff ff       	call   8010450d <myproc>
80106d36:	8b 55 08             	mov    0x8(%ebp),%edx
80106d39:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106d3c:	e8 a1 ec ff ff       	call   801059e2 <syscall>
    if(myproc()->killed)
80106d41:	e8 c7 d7 ff ff       	call   8010450d <myproc>
80106d46:	8b 40 24             	mov    0x24(%eax),%eax
80106d49:	85 c0                	test   %eax,%eax
80106d4b:	0f 84 42 02 00 00    	je     80106f93 <trap+0x28b>
      exit();
80106d51:	e8 fd dc ff ff       	call   80104a53 <exit>
    return;
80106d56:	e9 38 02 00 00       	jmp    80106f93 <trap+0x28b>
  }
  char *addr;
  switch(tf->trapno){
80106d5b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d5e:	8b 40 30             	mov    0x30(%eax),%eax
80106d61:	83 e8 0e             	sub    $0xe,%eax
80106d64:	83 f8 31             	cmp    $0x31,%eax
80106d67:	0f 87 ee 00 00 00    	ja     80106e5b <trap+0x153>
80106d6d:	8b 04 85 6c 98 10 80 	mov    -0x7fef6794(,%eax,4),%eax
80106d74:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d77:	e8 f6 d6 ff ff       	call   80104472 <cpuid>
80106d7c:	85 c0                	test   %eax,%eax
80106d7e:	75 3d                	jne    80106dbd <trap+0xb5>
      acquire(&tickslock);
80106d80:	83 ec 0c             	sub    $0xc,%esp
80106d83:	68 00 77 11 80       	push   $0x80117700
80106d88:	e8 8a e5 ff ff       	call   80105317 <acquire>
80106d8d:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d90:	a1 40 7f 11 80       	mov    0x80117f40,%eax
80106d95:	83 c0 01             	add    $0x1,%eax
80106d98:	a3 40 7f 11 80       	mov    %eax,0x80117f40
      wakeup(&ticks);
80106d9d:	83 ec 0c             	sub    $0xc,%esp
80106da0:	68 40 7f 11 80       	push   $0x80117f40
80106da5:	e8 ed e1 ff ff       	call   80104f97 <wakeup>
80106daa:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106dad:	83 ec 0c             	sub    $0xc,%esp
80106db0:	68 00 77 11 80       	push   $0x80117700
80106db5:	e8 cf e5 ff ff       	call   80105389 <release>
80106dba:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106dbd:	e8 40 c4 ff ff       	call   80103202 <lapiceoi>
    break;
80106dc2:	e9 4c 01 00 00       	jmp    80106f13 <trap+0x20b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106dc7:	e8 45 bc ff ff       	call   80102a11 <ideintr>
    lapiceoi();
80106dcc:	e8 31 c4 ff ff       	call   80103202 <lapiceoi>
    break;
80106dd1:	e9 3d 01 00 00       	jmp    80106f13 <trap+0x20b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106dd6:	e8 5d c2 ff ff       	call   80103038 <kbdintr>
    lapiceoi();
80106ddb:	e8 22 c4 ff ff       	call   80103202 <lapiceoi>
    break;
80106de0:	e9 2e 01 00 00       	jmp    80106f13 <trap+0x20b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106de5:	e8 8b 03 00 00       	call   80107175 <uartintr>
    lapiceoi();
80106dea:	e8 13 c4 ff ff       	call   80103202 <lapiceoi>
    break;
80106def:	e9 1f 01 00 00       	jmp    80106f13 <trap+0x20b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106df4:	8b 45 08             	mov    0x8(%ebp),%eax
80106df7:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80106dfd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e01:	0f b7 d8             	movzwl %ax,%ebx
80106e04:	e8 69 d6 ff ff       	call   80104472 <cpuid>
80106e09:	56                   	push   %esi
80106e0a:	53                   	push   %ebx
80106e0b:	50                   	push   %eax
80106e0c:	68 b4 97 10 80       	push   $0x801097b4
80106e11:	e8 02 96 ff ff       	call   80100418 <cprintf>
80106e16:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106e19:	e8 e4 c3 ff ff       	call   80103202 <lapiceoi>
    break;
80106e1e:	e9 f0 00 00 00       	jmp    80106f13 <trap+0x20b>
  case T_PGFLT:
    //Food for thought: How can one distinguish between a regular page fault and a decryption request?
    cprintf("p4Debug : Page fault !\n");
80106e23:	83 ec 0c             	sub    $0xc,%esp
80106e26:	68 d8 97 10 80       	push   $0x801097d8
80106e2b:	e8 e8 95 ff ff       	call   80100418 <cprintf>
80106e30:	83 c4 10             	add    $0x10,%esp
    addr = (char*)rcr2();
80106e33:	e8 29 fd ff ff       	call   80106b61 <rcr2>
80106e38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (mdecrypt(addr))
80106e3b:	83 ec 0c             	sub    $0xc,%esp
80106e3e:	ff 75 e4             	pushl  -0x1c(%ebp)
80106e41:	e8 37 1c 00 00       	call   80108a7d <mdecrypt>
80106e46:	83 c4 10             	add    $0x10,%esp
80106e49:	85 c0                	test   %eax,%eax
80106e4b:	0f 84 c1 00 00 00    	je     80106f12 <trap+0x20a>
    {
        //panic("p4Debug: Memory fault");
        exit();
80106e51:	e8 fd db ff ff       	call   80104a53 <exit>
    };
    break;
80106e56:	e9 b7 00 00 00       	jmp    80106f12 <trap+0x20a>
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106e5b:	e8 ad d6 ff ff       	call   8010450d <myproc>
80106e60:	85 c0                	test   %eax,%eax
80106e62:	74 11                	je     80106e75 <trap+0x16d>
80106e64:	8b 45 08             	mov    0x8(%ebp),%eax
80106e67:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e6b:	0f b7 c0             	movzwl %ax,%eax
80106e6e:	83 e0 03             	and    $0x3,%eax
80106e71:	85 c0                	test   %eax,%eax
80106e73:	75 39                	jne    80106eae <trap+0x1a6>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e75:	e8 e7 fc ff ff       	call   80106b61 <rcr2>
80106e7a:	89 c3                	mov    %eax,%ebx
80106e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e7f:	8b 70 38             	mov    0x38(%eax),%esi
80106e82:	e8 eb d5 ff ff       	call   80104472 <cpuid>
80106e87:	8b 55 08             	mov    0x8(%ebp),%edx
80106e8a:	8b 52 30             	mov    0x30(%edx),%edx
80106e8d:	83 ec 0c             	sub    $0xc,%esp
80106e90:	53                   	push   %ebx
80106e91:	56                   	push   %esi
80106e92:	50                   	push   %eax
80106e93:	52                   	push   %edx
80106e94:	68 f0 97 10 80       	push   $0x801097f0
80106e99:	e8 7a 95 ff ff       	call   80100418 <cprintf>
80106e9e:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106ea1:	83 ec 0c             	sub    $0xc,%esp
80106ea4:	68 22 98 10 80       	push   $0x80109822
80106ea9:	e8 5a 97 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106eae:	e8 ae fc ff ff       	call   80106b61 <rcr2>
80106eb3:	89 c6                	mov    %eax,%esi
80106eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80106eb8:	8b 40 38             	mov    0x38(%eax),%eax
80106ebb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106ebe:	e8 af d5 ff ff       	call   80104472 <cpuid>
80106ec3:	89 c3                	mov    %eax,%ebx
80106ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ec8:	8b 48 34             	mov    0x34(%eax),%ecx
80106ecb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106ece:	8b 45 08             	mov    0x8(%ebp),%eax
80106ed1:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106ed4:	e8 34 d6 ff ff       	call   8010450d <myproc>
80106ed9:	8d 50 6c             	lea    0x6c(%eax),%edx
80106edc:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106edf:	e8 29 d6 ff ff       	call   8010450d <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ee4:	8b 40 10             	mov    0x10(%eax),%eax
80106ee7:	56                   	push   %esi
80106ee8:	ff 75 d4             	pushl  -0x2c(%ebp)
80106eeb:	53                   	push   %ebx
80106eec:	ff 75 d0             	pushl  -0x30(%ebp)
80106eef:	57                   	push   %edi
80106ef0:	ff 75 cc             	pushl  -0x34(%ebp)
80106ef3:	50                   	push   %eax
80106ef4:	68 28 98 10 80       	push   $0x80109828
80106ef9:	e8 1a 95 ff ff       	call   80100418 <cprintf>
80106efe:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106f01:	e8 07 d6 ff ff       	call   8010450d <myproc>
80106f06:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106f0d:	eb 04                	jmp    80106f13 <trap+0x20b>
    break;
80106f0f:	90                   	nop
80106f10:	eb 01                	jmp    80106f13 <trap+0x20b>
    break;
80106f12:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f13:	e8 f5 d5 ff ff       	call   8010450d <myproc>
80106f18:	85 c0                	test   %eax,%eax
80106f1a:	74 23                	je     80106f3f <trap+0x237>
80106f1c:	e8 ec d5 ff ff       	call   8010450d <myproc>
80106f21:	8b 40 24             	mov    0x24(%eax),%eax
80106f24:	85 c0                	test   %eax,%eax
80106f26:	74 17                	je     80106f3f <trap+0x237>
80106f28:	8b 45 08             	mov    0x8(%ebp),%eax
80106f2b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f2f:	0f b7 c0             	movzwl %ax,%eax
80106f32:	83 e0 03             	and    $0x3,%eax
80106f35:	83 f8 03             	cmp    $0x3,%eax
80106f38:	75 05                	jne    80106f3f <trap+0x237>
    exit();
80106f3a:	e8 14 db ff ff       	call   80104a53 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106f3f:	e8 c9 d5 ff ff       	call   8010450d <myproc>
80106f44:	85 c0                	test   %eax,%eax
80106f46:	74 1d                	je     80106f65 <trap+0x25d>
80106f48:	e8 c0 d5 ff ff       	call   8010450d <myproc>
80106f4d:	8b 40 0c             	mov    0xc(%eax),%eax
80106f50:	83 f8 04             	cmp    $0x4,%eax
80106f53:	75 10                	jne    80106f65 <trap+0x25d>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106f55:	8b 45 08             	mov    0x8(%ebp),%eax
80106f58:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106f5b:	83 f8 20             	cmp    $0x20,%eax
80106f5e:	75 05                	jne    80106f65 <trap+0x25d>
    yield();
80106f60:	e8 b8 de ff ff       	call   80104e1d <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f65:	e8 a3 d5 ff ff       	call   8010450d <myproc>
80106f6a:	85 c0                	test   %eax,%eax
80106f6c:	74 26                	je     80106f94 <trap+0x28c>
80106f6e:	e8 9a d5 ff ff       	call   8010450d <myproc>
80106f73:	8b 40 24             	mov    0x24(%eax),%eax
80106f76:	85 c0                	test   %eax,%eax
80106f78:	74 1a                	je     80106f94 <trap+0x28c>
80106f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f7d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f81:	0f b7 c0             	movzwl %ax,%eax
80106f84:	83 e0 03             	and    $0x3,%eax
80106f87:	83 f8 03             	cmp    $0x3,%eax
80106f8a:	75 08                	jne    80106f94 <trap+0x28c>
    exit();
80106f8c:	e8 c2 da ff ff       	call   80104a53 <exit>
80106f91:	eb 01                	jmp    80106f94 <trap+0x28c>
    return;
80106f93:	90                   	nop
}
80106f94:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f97:	5b                   	pop    %ebx
80106f98:	5e                   	pop    %esi
80106f99:	5f                   	pop    %edi
80106f9a:	5d                   	pop    %ebp
80106f9b:	c3                   	ret    

80106f9c <inb>:
{
80106f9c:	55                   	push   %ebp
80106f9d:	89 e5                	mov    %esp,%ebp
80106f9f:	83 ec 14             	sub    $0x14,%esp
80106fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80106fa5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106fa9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106fad:	89 c2                	mov    %eax,%edx
80106faf:	ec                   	in     (%dx),%al
80106fb0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106fb3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106fb7:	c9                   	leave  
80106fb8:	c3                   	ret    

80106fb9 <outb>:
{
80106fb9:	55                   	push   %ebp
80106fba:	89 e5                	mov    %esp,%ebp
80106fbc:	83 ec 08             	sub    $0x8,%esp
80106fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80106fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
80106fc5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106fc9:	89 d0                	mov    %edx,%eax
80106fcb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106fce:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106fd2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106fd6:	ee                   	out    %al,(%dx)
}
80106fd7:	90                   	nop
80106fd8:	c9                   	leave  
80106fd9:	c3                   	ret    

80106fda <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106fda:	f3 0f 1e fb          	endbr32 
80106fde:	55                   	push   %ebp
80106fdf:	89 e5                	mov    %esp,%ebp
80106fe1:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106fe4:	6a 00                	push   $0x0
80106fe6:	68 fa 03 00 00       	push   $0x3fa
80106feb:	e8 c9 ff ff ff       	call   80106fb9 <outb>
80106ff0:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106ff3:	68 80 00 00 00       	push   $0x80
80106ff8:	68 fb 03 00 00       	push   $0x3fb
80106ffd:	e8 b7 ff ff ff       	call   80106fb9 <outb>
80107002:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107005:	6a 0c                	push   $0xc
80107007:	68 f8 03 00 00       	push   $0x3f8
8010700c:	e8 a8 ff ff ff       	call   80106fb9 <outb>
80107011:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107014:	6a 00                	push   $0x0
80107016:	68 f9 03 00 00       	push   $0x3f9
8010701b:	e8 99 ff ff ff       	call   80106fb9 <outb>
80107020:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107023:	6a 03                	push   $0x3
80107025:	68 fb 03 00 00       	push   $0x3fb
8010702a:	e8 8a ff ff ff       	call   80106fb9 <outb>
8010702f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107032:	6a 00                	push   $0x0
80107034:	68 fc 03 00 00       	push   $0x3fc
80107039:	e8 7b ff ff ff       	call   80106fb9 <outb>
8010703e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107041:	6a 01                	push   $0x1
80107043:	68 f9 03 00 00       	push   $0x3f9
80107048:	e8 6c ff ff ff       	call   80106fb9 <outb>
8010704d:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107050:	68 fd 03 00 00       	push   $0x3fd
80107055:	e8 42 ff ff ff       	call   80106f9c <inb>
8010705a:	83 c4 04             	add    $0x4,%esp
8010705d:	3c ff                	cmp    $0xff,%al
8010705f:	74 61                	je     801070c2 <uartinit+0xe8>
    return;
  uart = 1;
80107061:	c7 05 44 c6 10 80 01 	movl   $0x1,0x8010c644
80107068:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010706b:	68 fa 03 00 00       	push   $0x3fa
80107070:	e8 27 ff ff ff       	call   80106f9c <inb>
80107075:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107078:	68 f8 03 00 00       	push   $0x3f8
8010707d:	e8 1a ff ff ff       	call   80106f9c <inb>
80107082:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80107085:	83 ec 08             	sub    $0x8,%esp
80107088:	6a 00                	push   $0x0
8010708a:	6a 04                	push   $0x4
8010708c:	e8 32 bc ff ff       	call   80102cc3 <ioapicenable>
80107091:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107094:	c7 45 f4 34 99 10 80 	movl   $0x80109934,-0xc(%ebp)
8010709b:	eb 19                	jmp    801070b6 <uartinit+0xdc>
    uartputc(*p);
8010709d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a0:	0f b6 00             	movzbl (%eax),%eax
801070a3:	0f be c0             	movsbl %al,%eax
801070a6:	83 ec 0c             	sub    $0xc,%esp
801070a9:	50                   	push   %eax
801070aa:	e8 16 00 00 00       	call   801070c5 <uartputc>
801070af:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801070b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b9:	0f b6 00             	movzbl (%eax),%eax
801070bc:	84 c0                	test   %al,%al
801070be:	75 dd                	jne    8010709d <uartinit+0xc3>
801070c0:	eb 01                	jmp    801070c3 <uartinit+0xe9>
    return;
801070c2:	90                   	nop
}
801070c3:	c9                   	leave  
801070c4:	c3                   	ret    

801070c5 <uartputc>:

void
uartputc(int c)
{
801070c5:	f3 0f 1e fb          	endbr32 
801070c9:	55                   	push   %ebp
801070ca:	89 e5                	mov    %esp,%ebp
801070cc:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801070cf:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801070d4:	85 c0                	test   %eax,%eax
801070d6:	74 53                	je     8010712b <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801070df:	eb 11                	jmp    801070f2 <uartputc+0x2d>
    microdelay(10);
801070e1:	83 ec 0c             	sub    $0xc,%esp
801070e4:	6a 0a                	push   $0xa
801070e6:	e8 36 c1 ff ff       	call   80103221 <microdelay>
801070eb:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070f2:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070f6:	7f 1a                	jg     80107112 <uartputc+0x4d>
801070f8:	83 ec 0c             	sub    $0xc,%esp
801070fb:	68 fd 03 00 00       	push   $0x3fd
80107100:	e8 97 fe ff ff       	call   80106f9c <inb>
80107105:	83 c4 10             	add    $0x10,%esp
80107108:	0f b6 c0             	movzbl %al,%eax
8010710b:	83 e0 20             	and    $0x20,%eax
8010710e:	85 c0                	test   %eax,%eax
80107110:	74 cf                	je     801070e1 <uartputc+0x1c>
  outb(COM1+0, c);
80107112:	8b 45 08             	mov    0x8(%ebp),%eax
80107115:	0f b6 c0             	movzbl %al,%eax
80107118:	83 ec 08             	sub    $0x8,%esp
8010711b:	50                   	push   %eax
8010711c:	68 f8 03 00 00       	push   $0x3f8
80107121:	e8 93 fe ff ff       	call   80106fb9 <outb>
80107126:	83 c4 10             	add    $0x10,%esp
80107129:	eb 01                	jmp    8010712c <uartputc+0x67>
    return;
8010712b:	90                   	nop
}
8010712c:	c9                   	leave  
8010712d:	c3                   	ret    

8010712e <uartgetc>:

static int
uartgetc(void)
{
8010712e:	f3 0f 1e fb          	endbr32 
80107132:	55                   	push   %ebp
80107133:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107135:	a1 44 c6 10 80       	mov    0x8010c644,%eax
8010713a:	85 c0                	test   %eax,%eax
8010713c:	75 07                	jne    80107145 <uartgetc+0x17>
    return -1;
8010713e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107143:	eb 2e                	jmp    80107173 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80107145:	68 fd 03 00 00       	push   $0x3fd
8010714a:	e8 4d fe ff ff       	call   80106f9c <inb>
8010714f:	83 c4 04             	add    $0x4,%esp
80107152:	0f b6 c0             	movzbl %al,%eax
80107155:	83 e0 01             	and    $0x1,%eax
80107158:	85 c0                	test   %eax,%eax
8010715a:	75 07                	jne    80107163 <uartgetc+0x35>
    return -1;
8010715c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107161:	eb 10                	jmp    80107173 <uartgetc+0x45>
  return inb(COM1+0);
80107163:	68 f8 03 00 00       	push   $0x3f8
80107168:	e8 2f fe ff ff       	call   80106f9c <inb>
8010716d:	83 c4 04             	add    $0x4,%esp
80107170:	0f b6 c0             	movzbl %al,%eax
}
80107173:	c9                   	leave  
80107174:	c3                   	ret    

80107175 <uartintr>:

void
uartintr(void)
{
80107175:	f3 0f 1e fb          	endbr32 
80107179:	55                   	push   %ebp
8010717a:	89 e5                	mov    %esp,%ebp
8010717c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010717f:	83 ec 0c             	sub    $0xc,%esp
80107182:	68 2e 71 10 80       	push   $0x8010712e
80107187:	e8 1c 97 ff ff       	call   801008a8 <consoleintr>
8010718c:	83 c4 10             	add    $0x10,%esp
}
8010718f:	90                   	nop
80107190:	c9                   	leave  
80107191:	c3                   	ret    

80107192 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $0
80107194:	6a 00                	push   $0x0
  jmp alltraps
80107196:	e9 79 f9 ff ff       	jmp    80106b14 <alltraps>

8010719b <vector1>:
.globl vector1
vector1:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $1
8010719d:	6a 01                	push   $0x1
  jmp alltraps
8010719f:	e9 70 f9 ff ff       	jmp    80106b14 <alltraps>

801071a4 <vector2>:
.globl vector2
vector2:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $2
801071a6:	6a 02                	push   $0x2
  jmp alltraps
801071a8:	e9 67 f9 ff ff       	jmp    80106b14 <alltraps>

801071ad <vector3>:
.globl vector3
vector3:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $3
801071af:	6a 03                	push   $0x3
  jmp alltraps
801071b1:	e9 5e f9 ff ff       	jmp    80106b14 <alltraps>

801071b6 <vector4>:
.globl vector4
vector4:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $4
801071b8:	6a 04                	push   $0x4
  jmp alltraps
801071ba:	e9 55 f9 ff ff       	jmp    80106b14 <alltraps>

801071bf <vector5>:
.globl vector5
vector5:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $5
801071c1:	6a 05                	push   $0x5
  jmp alltraps
801071c3:	e9 4c f9 ff ff       	jmp    80106b14 <alltraps>

801071c8 <vector6>:
.globl vector6
vector6:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $6
801071ca:	6a 06                	push   $0x6
  jmp alltraps
801071cc:	e9 43 f9 ff ff       	jmp    80106b14 <alltraps>

801071d1 <vector7>:
.globl vector7
vector7:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $7
801071d3:	6a 07                	push   $0x7
  jmp alltraps
801071d5:	e9 3a f9 ff ff       	jmp    80106b14 <alltraps>

801071da <vector8>:
.globl vector8
vector8:
  pushl $8
801071da:	6a 08                	push   $0x8
  jmp alltraps
801071dc:	e9 33 f9 ff ff       	jmp    80106b14 <alltraps>

801071e1 <vector9>:
.globl vector9
vector9:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $9
801071e3:	6a 09                	push   $0x9
  jmp alltraps
801071e5:	e9 2a f9 ff ff       	jmp    80106b14 <alltraps>

801071ea <vector10>:
.globl vector10
vector10:
  pushl $10
801071ea:	6a 0a                	push   $0xa
  jmp alltraps
801071ec:	e9 23 f9 ff ff       	jmp    80106b14 <alltraps>

801071f1 <vector11>:
.globl vector11
vector11:
  pushl $11
801071f1:	6a 0b                	push   $0xb
  jmp alltraps
801071f3:	e9 1c f9 ff ff       	jmp    80106b14 <alltraps>

801071f8 <vector12>:
.globl vector12
vector12:
  pushl $12
801071f8:	6a 0c                	push   $0xc
  jmp alltraps
801071fa:	e9 15 f9 ff ff       	jmp    80106b14 <alltraps>

801071ff <vector13>:
.globl vector13
vector13:
  pushl $13
801071ff:	6a 0d                	push   $0xd
  jmp alltraps
80107201:	e9 0e f9 ff ff       	jmp    80106b14 <alltraps>

80107206 <vector14>:
.globl vector14
vector14:
  pushl $14
80107206:	6a 0e                	push   $0xe
  jmp alltraps
80107208:	e9 07 f9 ff ff       	jmp    80106b14 <alltraps>

8010720d <vector15>:
.globl vector15
vector15:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $15
8010720f:	6a 0f                	push   $0xf
  jmp alltraps
80107211:	e9 fe f8 ff ff       	jmp    80106b14 <alltraps>

80107216 <vector16>:
.globl vector16
vector16:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $16
80107218:	6a 10                	push   $0x10
  jmp alltraps
8010721a:	e9 f5 f8 ff ff       	jmp    80106b14 <alltraps>

8010721f <vector17>:
.globl vector17
vector17:
  pushl $17
8010721f:	6a 11                	push   $0x11
  jmp alltraps
80107221:	e9 ee f8 ff ff       	jmp    80106b14 <alltraps>

80107226 <vector18>:
.globl vector18
vector18:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $18
80107228:	6a 12                	push   $0x12
  jmp alltraps
8010722a:	e9 e5 f8 ff ff       	jmp    80106b14 <alltraps>

8010722f <vector19>:
.globl vector19
vector19:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $19
80107231:	6a 13                	push   $0x13
  jmp alltraps
80107233:	e9 dc f8 ff ff       	jmp    80106b14 <alltraps>

80107238 <vector20>:
.globl vector20
vector20:
  pushl $0
80107238:	6a 00                	push   $0x0
  pushl $20
8010723a:	6a 14                	push   $0x14
  jmp alltraps
8010723c:	e9 d3 f8 ff ff       	jmp    80106b14 <alltraps>

80107241 <vector21>:
.globl vector21
vector21:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $21
80107243:	6a 15                	push   $0x15
  jmp alltraps
80107245:	e9 ca f8 ff ff       	jmp    80106b14 <alltraps>

8010724a <vector22>:
.globl vector22
vector22:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $22
8010724c:	6a 16                	push   $0x16
  jmp alltraps
8010724e:	e9 c1 f8 ff ff       	jmp    80106b14 <alltraps>

80107253 <vector23>:
.globl vector23
vector23:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $23
80107255:	6a 17                	push   $0x17
  jmp alltraps
80107257:	e9 b8 f8 ff ff       	jmp    80106b14 <alltraps>

8010725c <vector24>:
.globl vector24
vector24:
  pushl $0
8010725c:	6a 00                	push   $0x0
  pushl $24
8010725e:	6a 18                	push   $0x18
  jmp alltraps
80107260:	e9 af f8 ff ff       	jmp    80106b14 <alltraps>

80107265 <vector25>:
.globl vector25
vector25:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $25
80107267:	6a 19                	push   $0x19
  jmp alltraps
80107269:	e9 a6 f8 ff ff       	jmp    80106b14 <alltraps>

8010726e <vector26>:
.globl vector26
vector26:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $26
80107270:	6a 1a                	push   $0x1a
  jmp alltraps
80107272:	e9 9d f8 ff ff       	jmp    80106b14 <alltraps>

80107277 <vector27>:
.globl vector27
vector27:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $27
80107279:	6a 1b                	push   $0x1b
  jmp alltraps
8010727b:	e9 94 f8 ff ff       	jmp    80106b14 <alltraps>

80107280 <vector28>:
.globl vector28
vector28:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $28
80107282:	6a 1c                	push   $0x1c
  jmp alltraps
80107284:	e9 8b f8 ff ff       	jmp    80106b14 <alltraps>

80107289 <vector29>:
.globl vector29
vector29:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $29
8010728b:	6a 1d                	push   $0x1d
  jmp alltraps
8010728d:	e9 82 f8 ff ff       	jmp    80106b14 <alltraps>

80107292 <vector30>:
.globl vector30
vector30:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $30
80107294:	6a 1e                	push   $0x1e
  jmp alltraps
80107296:	e9 79 f8 ff ff       	jmp    80106b14 <alltraps>

8010729b <vector31>:
.globl vector31
vector31:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $31
8010729d:	6a 1f                	push   $0x1f
  jmp alltraps
8010729f:	e9 70 f8 ff ff       	jmp    80106b14 <alltraps>

801072a4 <vector32>:
.globl vector32
vector32:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $32
801072a6:	6a 20                	push   $0x20
  jmp alltraps
801072a8:	e9 67 f8 ff ff       	jmp    80106b14 <alltraps>

801072ad <vector33>:
.globl vector33
vector33:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $33
801072af:	6a 21                	push   $0x21
  jmp alltraps
801072b1:	e9 5e f8 ff ff       	jmp    80106b14 <alltraps>

801072b6 <vector34>:
.globl vector34
vector34:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $34
801072b8:	6a 22                	push   $0x22
  jmp alltraps
801072ba:	e9 55 f8 ff ff       	jmp    80106b14 <alltraps>

801072bf <vector35>:
.globl vector35
vector35:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $35
801072c1:	6a 23                	push   $0x23
  jmp alltraps
801072c3:	e9 4c f8 ff ff       	jmp    80106b14 <alltraps>

801072c8 <vector36>:
.globl vector36
vector36:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $36
801072ca:	6a 24                	push   $0x24
  jmp alltraps
801072cc:	e9 43 f8 ff ff       	jmp    80106b14 <alltraps>

801072d1 <vector37>:
.globl vector37
vector37:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $37
801072d3:	6a 25                	push   $0x25
  jmp alltraps
801072d5:	e9 3a f8 ff ff       	jmp    80106b14 <alltraps>

801072da <vector38>:
.globl vector38
vector38:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $38
801072dc:	6a 26                	push   $0x26
  jmp alltraps
801072de:	e9 31 f8 ff ff       	jmp    80106b14 <alltraps>

801072e3 <vector39>:
.globl vector39
vector39:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $39
801072e5:	6a 27                	push   $0x27
  jmp alltraps
801072e7:	e9 28 f8 ff ff       	jmp    80106b14 <alltraps>

801072ec <vector40>:
.globl vector40
vector40:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $40
801072ee:	6a 28                	push   $0x28
  jmp alltraps
801072f0:	e9 1f f8 ff ff       	jmp    80106b14 <alltraps>

801072f5 <vector41>:
.globl vector41
vector41:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $41
801072f7:	6a 29                	push   $0x29
  jmp alltraps
801072f9:	e9 16 f8 ff ff       	jmp    80106b14 <alltraps>

801072fe <vector42>:
.globl vector42
vector42:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $42
80107300:	6a 2a                	push   $0x2a
  jmp alltraps
80107302:	e9 0d f8 ff ff       	jmp    80106b14 <alltraps>

80107307 <vector43>:
.globl vector43
vector43:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $43
80107309:	6a 2b                	push   $0x2b
  jmp alltraps
8010730b:	e9 04 f8 ff ff       	jmp    80106b14 <alltraps>

80107310 <vector44>:
.globl vector44
vector44:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $44
80107312:	6a 2c                	push   $0x2c
  jmp alltraps
80107314:	e9 fb f7 ff ff       	jmp    80106b14 <alltraps>

80107319 <vector45>:
.globl vector45
vector45:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $45
8010731b:	6a 2d                	push   $0x2d
  jmp alltraps
8010731d:	e9 f2 f7 ff ff       	jmp    80106b14 <alltraps>

80107322 <vector46>:
.globl vector46
vector46:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $46
80107324:	6a 2e                	push   $0x2e
  jmp alltraps
80107326:	e9 e9 f7 ff ff       	jmp    80106b14 <alltraps>

8010732b <vector47>:
.globl vector47
vector47:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $47
8010732d:	6a 2f                	push   $0x2f
  jmp alltraps
8010732f:	e9 e0 f7 ff ff       	jmp    80106b14 <alltraps>

80107334 <vector48>:
.globl vector48
vector48:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $48
80107336:	6a 30                	push   $0x30
  jmp alltraps
80107338:	e9 d7 f7 ff ff       	jmp    80106b14 <alltraps>

8010733d <vector49>:
.globl vector49
vector49:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $49
8010733f:	6a 31                	push   $0x31
  jmp alltraps
80107341:	e9 ce f7 ff ff       	jmp    80106b14 <alltraps>

80107346 <vector50>:
.globl vector50
vector50:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $50
80107348:	6a 32                	push   $0x32
  jmp alltraps
8010734a:	e9 c5 f7 ff ff       	jmp    80106b14 <alltraps>

8010734f <vector51>:
.globl vector51
vector51:
  pushl $0
8010734f:	6a 00                	push   $0x0
  pushl $51
80107351:	6a 33                	push   $0x33
  jmp alltraps
80107353:	e9 bc f7 ff ff       	jmp    80106b14 <alltraps>

80107358 <vector52>:
.globl vector52
vector52:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $52
8010735a:	6a 34                	push   $0x34
  jmp alltraps
8010735c:	e9 b3 f7 ff ff       	jmp    80106b14 <alltraps>

80107361 <vector53>:
.globl vector53
vector53:
  pushl $0
80107361:	6a 00                	push   $0x0
  pushl $53
80107363:	6a 35                	push   $0x35
  jmp alltraps
80107365:	e9 aa f7 ff ff       	jmp    80106b14 <alltraps>

8010736a <vector54>:
.globl vector54
vector54:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $54
8010736c:	6a 36                	push   $0x36
  jmp alltraps
8010736e:	e9 a1 f7 ff ff       	jmp    80106b14 <alltraps>

80107373 <vector55>:
.globl vector55
vector55:
  pushl $0
80107373:	6a 00                	push   $0x0
  pushl $55
80107375:	6a 37                	push   $0x37
  jmp alltraps
80107377:	e9 98 f7 ff ff       	jmp    80106b14 <alltraps>

8010737c <vector56>:
.globl vector56
vector56:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $56
8010737e:	6a 38                	push   $0x38
  jmp alltraps
80107380:	e9 8f f7 ff ff       	jmp    80106b14 <alltraps>

80107385 <vector57>:
.globl vector57
vector57:
  pushl $0
80107385:	6a 00                	push   $0x0
  pushl $57
80107387:	6a 39                	push   $0x39
  jmp alltraps
80107389:	e9 86 f7 ff ff       	jmp    80106b14 <alltraps>

8010738e <vector58>:
.globl vector58
vector58:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $58
80107390:	6a 3a                	push   $0x3a
  jmp alltraps
80107392:	e9 7d f7 ff ff       	jmp    80106b14 <alltraps>

80107397 <vector59>:
.globl vector59
vector59:
  pushl $0
80107397:	6a 00                	push   $0x0
  pushl $59
80107399:	6a 3b                	push   $0x3b
  jmp alltraps
8010739b:	e9 74 f7 ff ff       	jmp    80106b14 <alltraps>

801073a0 <vector60>:
.globl vector60
vector60:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $60
801073a2:	6a 3c                	push   $0x3c
  jmp alltraps
801073a4:	e9 6b f7 ff ff       	jmp    80106b14 <alltraps>

801073a9 <vector61>:
.globl vector61
vector61:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $61
801073ab:	6a 3d                	push   $0x3d
  jmp alltraps
801073ad:	e9 62 f7 ff ff       	jmp    80106b14 <alltraps>

801073b2 <vector62>:
.globl vector62
vector62:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $62
801073b4:	6a 3e                	push   $0x3e
  jmp alltraps
801073b6:	e9 59 f7 ff ff       	jmp    80106b14 <alltraps>

801073bb <vector63>:
.globl vector63
vector63:
  pushl $0
801073bb:	6a 00                	push   $0x0
  pushl $63
801073bd:	6a 3f                	push   $0x3f
  jmp alltraps
801073bf:	e9 50 f7 ff ff       	jmp    80106b14 <alltraps>

801073c4 <vector64>:
.globl vector64
vector64:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $64
801073c6:	6a 40                	push   $0x40
  jmp alltraps
801073c8:	e9 47 f7 ff ff       	jmp    80106b14 <alltraps>

801073cd <vector65>:
.globl vector65
vector65:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $65
801073cf:	6a 41                	push   $0x41
  jmp alltraps
801073d1:	e9 3e f7 ff ff       	jmp    80106b14 <alltraps>

801073d6 <vector66>:
.globl vector66
vector66:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $66
801073d8:	6a 42                	push   $0x42
  jmp alltraps
801073da:	e9 35 f7 ff ff       	jmp    80106b14 <alltraps>

801073df <vector67>:
.globl vector67
vector67:
  pushl $0
801073df:	6a 00                	push   $0x0
  pushl $67
801073e1:	6a 43                	push   $0x43
  jmp alltraps
801073e3:	e9 2c f7 ff ff       	jmp    80106b14 <alltraps>

801073e8 <vector68>:
.globl vector68
vector68:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $68
801073ea:	6a 44                	push   $0x44
  jmp alltraps
801073ec:	e9 23 f7 ff ff       	jmp    80106b14 <alltraps>

801073f1 <vector69>:
.globl vector69
vector69:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $69
801073f3:	6a 45                	push   $0x45
  jmp alltraps
801073f5:	e9 1a f7 ff ff       	jmp    80106b14 <alltraps>

801073fa <vector70>:
.globl vector70
vector70:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $70
801073fc:	6a 46                	push   $0x46
  jmp alltraps
801073fe:	e9 11 f7 ff ff       	jmp    80106b14 <alltraps>

80107403 <vector71>:
.globl vector71
vector71:
  pushl $0
80107403:	6a 00                	push   $0x0
  pushl $71
80107405:	6a 47                	push   $0x47
  jmp alltraps
80107407:	e9 08 f7 ff ff       	jmp    80106b14 <alltraps>

8010740c <vector72>:
.globl vector72
vector72:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $72
8010740e:	6a 48                	push   $0x48
  jmp alltraps
80107410:	e9 ff f6 ff ff       	jmp    80106b14 <alltraps>

80107415 <vector73>:
.globl vector73
vector73:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $73
80107417:	6a 49                	push   $0x49
  jmp alltraps
80107419:	e9 f6 f6 ff ff       	jmp    80106b14 <alltraps>

8010741e <vector74>:
.globl vector74
vector74:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $74
80107420:	6a 4a                	push   $0x4a
  jmp alltraps
80107422:	e9 ed f6 ff ff       	jmp    80106b14 <alltraps>

80107427 <vector75>:
.globl vector75
vector75:
  pushl $0
80107427:	6a 00                	push   $0x0
  pushl $75
80107429:	6a 4b                	push   $0x4b
  jmp alltraps
8010742b:	e9 e4 f6 ff ff       	jmp    80106b14 <alltraps>

80107430 <vector76>:
.globl vector76
vector76:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $76
80107432:	6a 4c                	push   $0x4c
  jmp alltraps
80107434:	e9 db f6 ff ff       	jmp    80106b14 <alltraps>

80107439 <vector77>:
.globl vector77
vector77:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $77
8010743b:	6a 4d                	push   $0x4d
  jmp alltraps
8010743d:	e9 d2 f6 ff ff       	jmp    80106b14 <alltraps>

80107442 <vector78>:
.globl vector78
vector78:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $78
80107444:	6a 4e                	push   $0x4e
  jmp alltraps
80107446:	e9 c9 f6 ff ff       	jmp    80106b14 <alltraps>

8010744b <vector79>:
.globl vector79
vector79:
  pushl $0
8010744b:	6a 00                	push   $0x0
  pushl $79
8010744d:	6a 4f                	push   $0x4f
  jmp alltraps
8010744f:	e9 c0 f6 ff ff       	jmp    80106b14 <alltraps>

80107454 <vector80>:
.globl vector80
vector80:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $80
80107456:	6a 50                	push   $0x50
  jmp alltraps
80107458:	e9 b7 f6 ff ff       	jmp    80106b14 <alltraps>

8010745d <vector81>:
.globl vector81
vector81:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $81
8010745f:	6a 51                	push   $0x51
  jmp alltraps
80107461:	e9 ae f6 ff ff       	jmp    80106b14 <alltraps>

80107466 <vector82>:
.globl vector82
vector82:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $82
80107468:	6a 52                	push   $0x52
  jmp alltraps
8010746a:	e9 a5 f6 ff ff       	jmp    80106b14 <alltraps>

8010746f <vector83>:
.globl vector83
vector83:
  pushl $0
8010746f:	6a 00                	push   $0x0
  pushl $83
80107471:	6a 53                	push   $0x53
  jmp alltraps
80107473:	e9 9c f6 ff ff       	jmp    80106b14 <alltraps>

80107478 <vector84>:
.globl vector84
vector84:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $84
8010747a:	6a 54                	push   $0x54
  jmp alltraps
8010747c:	e9 93 f6 ff ff       	jmp    80106b14 <alltraps>

80107481 <vector85>:
.globl vector85
vector85:
  pushl $0
80107481:	6a 00                	push   $0x0
  pushl $85
80107483:	6a 55                	push   $0x55
  jmp alltraps
80107485:	e9 8a f6 ff ff       	jmp    80106b14 <alltraps>

8010748a <vector86>:
.globl vector86
vector86:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $86
8010748c:	6a 56                	push   $0x56
  jmp alltraps
8010748e:	e9 81 f6 ff ff       	jmp    80106b14 <alltraps>

80107493 <vector87>:
.globl vector87
vector87:
  pushl $0
80107493:	6a 00                	push   $0x0
  pushl $87
80107495:	6a 57                	push   $0x57
  jmp alltraps
80107497:	e9 78 f6 ff ff       	jmp    80106b14 <alltraps>

8010749c <vector88>:
.globl vector88
vector88:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $88
8010749e:	6a 58                	push   $0x58
  jmp alltraps
801074a0:	e9 6f f6 ff ff       	jmp    80106b14 <alltraps>

801074a5 <vector89>:
.globl vector89
vector89:
  pushl $0
801074a5:	6a 00                	push   $0x0
  pushl $89
801074a7:	6a 59                	push   $0x59
  jmp alltraps
801074a9:	e9 66 f6 ff ff       	jmp    80106b14 <alltraps>

801074ae <vector90>:
.globl vector90
vector90:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $90
801074b0:	6a 5a                	push   $0x5a
  jmp alltraps
801074b2:	e9 5d f6 ff ff       	jmp    80106b14 <alltraps>

801074b7 <vector91>:
.globl vector91
vector91:
  pushl $0
801074b7:	6a 00                	push   $0x0
  pushl $91
801074b9:	6a 5b                	push   $0x5b
  jmp alltraps
801074bb:	e9 54 f6 ff ff       	jmp    80106b14 <alltraps>

801074c0 <vector92>:
.globl vector92
vector92:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $92
801074c2:	6a 5c                	push   $0x5c
  jmp alltraps
801074c4:	e9 4b f6 ff ff       	jmp    80106b14 <alltraps>

801074c9 <vector93>:
.globl vector93
vector93:
  pushl $0
801074c9:	6a 00                	push   $0x0
  pushl $93
801074cb:	6a 5d                	push   $0x5d
  jmp alltraps
801074cd:	e9 42 f6 ff ff       	jmp    80106b14 <alltraps>

801074d2 <vector94>:
.globl vector94
vector94:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $94
801074d4:	6a 5e                	push   $0x5e
  jmp alltraps
801074d6:	e9 39 f6 ff ff       	jmp    80106b14 <alltraps>

801074db <vector95>:
.globl vector95
vector95:
  pushl $0
801074db:	6a 00                	push   $0x0
  pushl $95
801074dd:	6a 5f                	push   $0x5f
  jmp alltraps
801074df:	e9 30 f6 ff ff       	jmp    80106b14 <alltraps>

801074e4 <vector96>:
.globl vector96
vector96:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $96
801074e6:	6a 60                	push   $0x60
  jmp alltraps
801074e8:	e9 27 f6 ff ff       	jmp    80106b14 <alltraps>

801074ed <vector97>:
.globl vector97
vector97:
  pushl $0
801074ed:	6a 00                	push   $0x0
  pushl $97
801074ef:	6a 61                	push   $0x61
  jmp alltraps
801074f1:	e9 1e f6 ff ff       	jmp    80106b14 <alltraps>

801074f6 <vector98>:
.globl vector98
vector98:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $98
801074f8:	6a 62                	push   $0x62
  jmp alltraps
801074fa:	e9 15 f6 ff ff       	jmp    80106b14 <alltraps>

801074ff <vector99>:
.globl vector99
vector99:
  pushl $0
801074ff:	6a 00                	push   $0x0
  pushl $99
80107501:	6a 63                	push   $0x63
  jmp alltraps
80107503:	e9 0c f6 ff ff       	jmp    80106b14 <alltraps>

80107508 <vector100>:
.globl vector100
vector100:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $100
8010750a:	6a 64                	push   $0x64
  jmp alltraps
8010750c:	e9 03 f6 ff ff       	jmp    80106b14 <alltraps>

80107511 <vector101>:
.globl vector101
vector101:
  pushl $0
80107511:	6a 00                	push   $0x0
  pushl $101
80107513:	6a 65                	push   $0x65
  jmp alltraps
80107515:	e9 fa f5 ff ff       	jmp    80106b14 <alltraps>

8010751a <vector102>:
.globl vector102
vector102:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $102
8010751c:	6a 66                	push   $0x66
  jmp alltraps
8010751e:	e9 f1 f5 ff ff       	jmp    80106b14 <alltraps>

80107523 <vector103>:
.globl vector103
vector103:
  pushl $0
80107523:	6a 00                	push   $0x0
  pushl $103
80107525:	6a 67                	push   $0x67
  jmp alltraps
80107527:	e9 e8 f5 ff ff       	jmp    80106b14 <alltraps>

8010752c <vector104>:
.globl vector104
vector104:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $104
8010752e:	6a 68                	push   $0x68
  jmp alltraps
80107530:	e9 df f5 ff ff       	jmp    80106b14 <alltraps>

80107535 <vector105>:
.globl vector105
vector105:
  pushl $0
80107535:	6a 00                	push   $0x0
  pushl $105
80107537:	6a 69                	push   $0x69
  jmp alltraps
80107539:	e9 d6 f5 ff ff       	jmp    80106b14 <alltraps>

8010753e <vector106>:
.globl vector106
vector106:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $106
80107540:	6a 6a                	push   $0x6a
  jmp alltraps
80107542:	e9 cd f5 ff ff       	jmp    80106b14 <alltraps>

80107547 <vector107>:
.globl vector107
vector107:
  pushl $0
80107547:	6a 00                	push   $0x0
  pushl $107
80107549:	6a 6b                	push   $0x6b
  jmp alltraps
8010754b:	e9 c4 f5 ff ff       	jmp    80106b14 <alltraps>

80107550 <vector108>:
.globl vector108
vector108:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $108
80107552:	6a 6c                	push   $0x6c
  jmp alltraps
80107554:	e9 bb f5 ff ff       	jmp    80106b14 <alltraps>

80107559 <vector109>:
.globl vector109
vector109:
  pushl $0
80107559:	6a 00                	push   $0x0
  pushl $109
8010755b:	6a 6d                	push   $0x6d
  jmp alltraps
8010755d:	e9 b2 f5 ff ff       	jmp    80106b14 <alltraps>

80107562 <vector110>:
.globl vector110
vector110:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $110
80107564:	6a 6e                	push   $0x6e
  jmp alltraps
80107566:	e9 a9 f5 ff ff       	jmp    80106b14 <alltraps>

8010756b <vector111>:
.globl vector111
vector111:
  pushl $0
8010756b:	6a 00                	push   $0x0
  pushl $111
8010756d:	6a 6f                	push   $0x6f
  jmp alltraps
8010756f:	e9 a0 f5 ff ff       	jmp    80106b14 <alltraps>

80107574 <vector112>:
.globl vector112
vector112:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $112
80107576:	6a 70                	push   $0x70
  jmp alltraps
80107578:	e9 97 f5 ff ff       	jmp    80106b14 <alltraps>

8010757d <vector113>:
.globl vector113
vector113:
  pushl $0
8010757d:	6a 00                	push   $0x0
  pushl $113
8010757f:	6a 71                	push   $0x71
  jmp alltraps
80107581:	e9 8e f5 ff ff       	jmp    80106b14 <alltraps>

80107586 <vector114>:
.globl vector114
vector114:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $114
80107588:	6a 72                	push   $0x72
  jmp alltraps
8010758a:	e9 85 f5 ff ff       	jmp    80106b14 <alltraps>

8010758f <vector115>:
.globl vector115
vector115:
  pushl $0
8010758f:	6a 00                	push   $0x0
  pushl $115
80107591:	6a 73                	push   $0x73
  jmp alltraps
80107593:	e9 7c f5 ff ff       	jmp    80106b14 <alltraps>

80107598 <vector116>:
.globl vector116
vector116:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $116
8010759a:	6a 74                	push   $0x74
  jmp alltraps
8010759c:	e9 73 f5 ff ff       	jmp    80106b14 <alltraps>

801075a1 <vector117>:
.globl vector117
vector117:
  pushl $0
801075a1:	6a 00                	push   $0x0
  pushl $117
801075a3:	6a 75                	push   $0x75
  jmp alltraps
801075a5:	e9 6a f5 ff ff       	jmp    80106b14 <alltraps>

801075aa <vector118>:
.globl vector118
vector118:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $118
801075ac:	6a 76                	push   $0x76
  jmp alltraps
801075ae:	e9 61 f5 ff ff       	jmp    80106b14 <alltraps>

801075b3 <vector119>:
.globl vector119
vector119:
  pushl $0
801075b3:	6a 00                	push   $0x0
  pushl $119
801075b5:	6a 77                	push   $0x77
  jmp alltraps
801075b7:	e9 58 f5 ff ff       	jmp    80106b14 <alltraps>

801075bc <vector120>:
.globl vector120
vector120:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $120
801075be:	6a 78                	push   $0x78
  jmp alltraps
801075c0:	e9 4f f5 ff ff       	jmp    80106b14 <alltraps>

801075c5 <vector121>:
.globl vector121
vector121:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $121
801075c7:	6a 79                	push   $0x79
  jmp alltraps
801075c9:	e9 46 f5 ff ff       	jmp    80106b14 <alltraps>

801075ce <vector122>:
.globl vector122
vector122:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $122
801075d0:	6a 7a                	push   $0x7a
  jmp alltraps
801075d2:	e9 3d f5 ff ff       	jmp    80106b14 <alltraps>

801075d7 <vector123>:
.globl vector123
vector123:
  pushl $0
801075d7:	6a 00                	push   $0x0
  pushl $123
801075d9:	6a 7b                	push   $0x7b
  jmp alltraps
801075db:	e9 34 f5 ff ff       	jmp    80106b14 <alltraps>

801075e0 <vector124>:
.globl vector124
vector124:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $124
801075e2:	6a 7c                	push   $0x7c
  jmp alltraps
801075e4:	e9 2b f5 ff ff       	jmp    80106b14 <alltraps>

801075e9 <vector125>:
.globl vector125
vector125:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $125
801075eb:	6a 7d                	push   $0x7d
  jmp alltraps
801075ed:	e9 22 f5 ff ff       	jmp    80106b14 <alltraps>

801075f2 <vector126>:
.globl vector126
vector126:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $126
801075f4:	6a 7e                	push   $0x7e
  jmp alltraps
801075f6:	e9 19 f5 ff ff       	jmp    80106b14 <alltraps>

801075fb <vector127>:
.globl vector127
vector127:
  pushl $0
801075fb:	6a 00                	push   $0x0
  pushl $127
801075fd:	6a 7f                	push   $0x7f
  jmp alltraps
801075ff:	e9 10 f5 ff ff       	jmp    80106b14 <alltraps>

80107604 <vector128>:
.globl vector128
vector128:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $128
80107606:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010760b:	e9 04 f5 ff ff       	jmp    80106b14 <alltraps>

80107610 <vector129>:
.globl vector129
vector129:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $129
80107612:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107617:	e9 f8 f4 ff ff       	jmp    80106b14 <alltraps>

8010761c <vector130>:
.globl vector130
vector130:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $130
8010761e:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107623:	e9 ec f4 ff ff       	jmp    80106b14 <alltraps>

80107628 <vector131>:
.globl vector131
vector131:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $131
8010762a:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010762f:	e9 e0 f4 ff ff       	jmp    80106b14 <alltraps>

80107634 <vector132>:
.globl vector132
vector132:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $132
80107636:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010763b:	e9 d4 f4 ff ff       	jmp    80106b14 <alltraps>

80107640 <vector133>:
.globl vector133
vector133:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $133
80107642:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107647:	e9 c8 f4 ff ff       	jmp    80106b14 <alltraps>

8010764c <vector134>:
.globl vector134
vector134:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $134
8010764e:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107653:	e9 bc f4 ff ff       	jmp    80106b14 <alltraps>

80107658 <vector135>:
.globl vector135
vector135:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $135
8010765a:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010765f:	e9 b0 f4 ff ff       	jmp    80106b14 <alltraps>

80107664 <vector136>:
.globl vector136
vector136:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $136
80107666:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010766b:	e9 a4 f4 ff ff       	jmp    80106b14 <alltraps>

80107670 <vector137>:
.globl vector137
vector137:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $137
80107672:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107677:	e9 98 f4 ff ff       	jmp    80106b14 <alltraps>

8010767c <vector138>:
.globl vector138
vector138:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $138
8010767e:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107683:	e9 8c f4 ff ff       	jmp    80106b14 <alltraps>

80107688 <vector139>:
.globl vector139
vector139:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $139
8010768a:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010768f:	e9 80 f4 ff ff       	jmp    80106b14 <alltraps>

80107694 <vector140>:
.globl vector140
vector140:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $140
80107696:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010769b:	e9 74 f4 ff ff       	jmp    80106b14 <alltraps>

801076a0 <vector141>:
.globl vector141
vector141:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $141
801076a2:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801076a7:	e9 68 f4 ff ff       	jmp    80106b14 <alltraps>

801076ac <vector142>:
.globl vector142
vector142:
  pushl $0
801076ac:	6a 00                	push   $0x0
  pushl $142
801076ae:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801076b3:	e9 5c f4 ff ff       	jmp    80106b14 <alltraps>

801076b8 <vector143>:
.globl vector143
vector143:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $143
801076ba:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801076bf:	e9 50 f4 ff ff       	jmp    80106b14 <alltraps>

801076c4 <vector144>:
.globl vector144
vector144:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $144
801076c6:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801076cb:	e9 44 f4 ff ff       	jmp    80106b14 <alltraps>

801076d0 <vector145>:
.globl vector145
vector145:
  pushl $0
801076d0:	6a 00                	push   $0x0
  pushl $145
801076d2:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801076d7:	e9 38 f4 ff ff       	jmp    80106b14 <alltraps>

801076dc <vector146>:
.globl vector146
vector146:
  pushl $0
801076dc:	6a 00                	push   $0x0
  pushl $146
801076de:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801076e3:	e9 2c f4 ff ff       	jmp    80106b14 <alltraps>

801076e8 <vector147>:
.globl vector147
vector147:
  pushl $0
801076e8:	6a 00                	push   $0x0
  pushl $147
801076ea:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801076ef:	e9 20 f4 ff ff       	jmp    80106b14 <alltraps>

801076f4 <vector148>:
.globl vector148
vector148:
  pushl $0
801076f4:	6a 00                	push   $0x0
  pushl $148
801076f6:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076fb:	e9 14 f4 ff ff       	jmp    80106b14 <alltraps>

80107700 <vector149>:
.globl vector149
vector149:
  pushl $0
80107700:	6a 00                	push   $0x0
  pushl $149
80107702:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107707:	e9 08 f4 ff ff       	jmp    80106b14 <alltraps>

8010770c <vector150>:
.globl vector150
vector150:
  pushl $0
8010770c:	6a 00                	push   $0x0
  pushl $150
8010770e:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107713:	e9 fc f3 ff ff       	jmp    80106b14 <alltraps>

80107718 <vector151>:
.globl vector151
vector151:
  pushl $0
80107718:	6a 00                	push   $0x0
  pushl $151
8010771a:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010771f:	e9 f0 f3 ff ff       	jmp    80106b14 <alltraps>

80107724 <vector152>:
.globl vector152
vector152:
  pushl $0
80107724:	6a 00                	push   $0x0
  pushl $152
80107726:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010772b:	e9 e4 f3 ff ff       	jmp    80106b14 <alltraps>

80107730 <vector153>:
.globl vector153
vector153:
  pushl $0
80107730:	6a 00                	push   $0x0
  pushl $153
80107732:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107737:	e9 d8 f3 ff ff       	jmp    80106b14 <alltraps>

8010773c <vector154>:
.globl vector154
vector154:
  pushl $0
8010773c:	6a 00                	push   $0x0
  pushl $154
8010773e:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107743:	e9 cc f3 ff ff       	jmp    80106b14 <alltraps>

80107748 <vector155>:
.globl vector155
vector155:
  pushl $0
80107748:	6a 00                	push   $0x0
  pushl $155
8010774a:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010774f:	e9 c0 f3 ff ff       	jmp    80106b14 <alltraps>

80107754 <vector156>:
.globl vector156
vector156:
  pushl $0
80107754:	6a 00                	push   $0x0
  pushl $156
80107756:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010775b:	e9 b4 f3 ff ff       	jmp    80106b14 <alltraps>

80107760 <vector157>:
.globl vector157
vector157:
  pushl $0
80107760:	6a 00                	push   $0x0
  pushl $157
80107762:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107767:	e9 a8 f3 ff ff       	jmp    80106b14 <alltraps>

8010776c <vector158>:
.globl vector158
vector158:
  pushl $0
8010776c:	6a 00                	push   $0x0
  pushl $158
8010776e:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107773:	e9 9c f3 ff ff       	jmp    80106b14 <alltraps>

80107778 <vector159>:
.globl vector159
vector159:
  pushl $0
80107778:	6a 00                	push   $0x0
  pushl $159
8010777a:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010777f:	e9 90 f3 ff ff       	jmp    80106b14 <alltraps>

80107784 <vector160>:
.globl vector160
vector160:
  pushl $0
80107784:	6a 00                	push   $0x0
  pushl $160
80107786:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010778b:	e9 84 f3 ff ff       	jmp    80106b14 <alltraps>

80107790 <vector161>:
.globl vector161
vector161:
  pushl $0
80107790:	6a 00                	push   $0x0
  pushl $161
80107792:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107797:	e9 78 f3 ff ff       	jmp    80106b14 <alltraps>

8010779c <vector162>:
.globl vector162
vector162:
  pushl $0
8010779c:	6a 00                	push   $0x0
  pushl $162
8010779e:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801077a3:	e9 6c f3 ff ff       	jmp    80106b14 <alltraps>

801077a8 <vector163>:
.globl vector163
vector163:
  pushl $0
801077a8:	6a 00                	push   $0x0
  pushl $163
801077aa:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801077af:	e9 60 f3 ff ff       	jmp    80106b14 <alltraps>

801077b4 <vector164>:
.globl vector164
vector164:
  pushl $0
801077b4:	6a 00                	push   $0x0
  pushl $164
801077b6:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801077bb:	e9 54 f3 ff ff       	jmp    80106b14 <alltraps>

801077c0 <vector165>:
.globl vector165
vector165:
  pushl $0
801077c0:	6a 00                	push   $0x0
  pushl $165
801077c2:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801077c7:	e9 48 f3 ff ff       	jmp    80106b14 <alltraps>

801077cc <vector166>:
.globl vector166
vector166:
  pushl $0
801077cc:	6a 00                	push   $0x0
  pushl $166
801077ce:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801077d3:	e9 3c f3 ff ff       	jmp    80106b14 <alltraps>

801077d8 <vector167>:
.globl vector167
vector167:
  pushl $0
801077d8:	6a 00                	push   $0x0
  pushl $167
801077da:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801077df:	e9 30 f3 ff ff       	jmp    80106b14 <alltraps>

801077e4 <vector168>:
.globl vector168
vector168:
  pushl $0
801077e4:	6a 00                	push   $0x0
  pushl $168
801077e6:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801077eb:	e9 24 f3 ff ff       	jmp    80106b14 <alltraps>

801077f0 <vector169>:
.globl vector169
vector169:
  pushl $0
801077f0:	6a 00                	push   $0x0
  pushl $169
801077f2:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801077f7:	e9 18 f3 ff ff       	jmp    80106b14 <alltraps>

801077fc <vector170>:
.globl vector170
vector170:
  pushl $0
801077fc:	6a 00                	push   $0x0
  pushl $170
801077fe:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107803:	e9 0c f3 ff ff       	jmp    80106b14 <alltraps>

80107808 <vector171>:
.globl vector171
vector171:
  pushl $0
80107808:	6a 00                	push   $0x0
  pushl $171
8010780a:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010780f:	e9 00 f3 ff ff       	jmp    80106b14 <alltraps>

80107814 <vector172>:
.globl vector172
vector172:
  pushl $0
80107814:	6a 00                	push   $0x0
  pushl $172
80107816:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010781b:	e9 f4 f2 ff ff       	jmp    80106b14 <alltraps>

80107820 <vector173>:
.globl vector173
vector173:
  pushl $0
80107820:	6a 00                	push   $0x0
  pushl $173
80107822:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107827:	e9 e8 f2 ff ff       	jmp    80106b14 <alltraps>

8010782c <vector174>:
.globl vector174
vector174:
  pushl $0
8010782c:	6a 00                	push   $0x0
  pushl $174
8010782e:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107833:	e9 dc f2 ff ff       	jmp    80106b14 <alltraps>

80107838 <vector175>:
.globl vector175
vector175:
  pushl $0
80107838:	6a 00                	push   $0x0
  pushl $175
8010783a:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010783f:	e9 d0 f2 ff ff       	jmp    80106b14 <alltraps>

80107844 <vector176>:
.globl vector176
vector176:
  pushl $0
80107844:	6a 00                	push   $0x0
  pushl $176
80107846:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010784b:	e9 c4 f2 ff ff       	jmp    80106b14 <alltraps>

80107850 <vector177>:
.globl vector177
vector177:
  pushl $0
80107850:	6a 00                	push   $0x0
  pushl $177
80107852:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107857:	e9 b8 f2 ff ff       	jmp    80106b14 <alltraps>

8010785c <vector178>:
.globl vector178
vector178:
  pushl $0
8010785c:	6a 00                	push   $0x0
  pushl $178
8010785e:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107863:	e9 ac f2 ff ff       	jmp    80106b14 <alltraps>

80107868 <vector179>:
.globl vector179
vector179:
  pushl $0
80107868:	6a 00                	push   $0x0
  pushl $179
8010786a:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010786f:	e9 a0 f2 ff ff       	jmp    80106b14 <alltraps>

80107874 <vector180>:
.globl vector180
vector180:
  pushl $0
80107874:	6a 00                	push   $0x0
  pushl $180
80107876:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010787b:	e9 94 f2 ff ff       	jmp    80106b14 <alltraps>

80107880 <vector181>:
.globl vector181
vector181:
  pushl $0
80107880:	6a 00                	push   $0x0
  pushl $181
80107882:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107887:	e9 88 f2 ff ff       	jmp    80106b14 <alltraps>

8010788c <vector182>:
.globl vector182
vector182:
  pushl $0
8010788c:	6a 00                	push   $0x0
  pushl $182
8010788e:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107893:	e9 7c f2 ff ff       	jmp    80106b14 <alltraps>

80107898 <vector183>:
.globl vector183
vector183:
  pushl $0
80107898:	6a 00                	push   $0x0
  pushl $183
8010789a:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010789f:	e9 70 f2 ff ff       	jmp    80106b14 <alltraps>

801078a4 <vector184>:
.globl vector184
vector184:
  pushl $0
801078a4:	6a 00                	push   $0x0
  pushl $184
801078a6:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801078ab:	e9 64 f2 ff ff       	jmp    80106b14 <alltraps>

801078b0 <vector185>:
.globl vector185
vector185:
  pushl $0
801078b0:	6a 00                	push   $0x0
  pushl $185
801078b2:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801078b7:	e9 58 f2 ff ff       	jmp    80106b14 <alltraps>

801078bc <vector186>:
.globl vector186
vector186:
  pushl $0
801078bc:	6a 00                	push   $0x0
  pushl $186
801078be:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801078c3:	e9 4c f2 ff ff       	jmp    80106b14 <alltraps>

801078c8 <vector187>:
.globl vector187
vector187:
  pushl $0
801078c8:	6a 00                	push   $0x0
  pushl $187
801078ca:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801078cf:	e9 40 f2 ff ff       	jmp    80106b14 <alltraps>

801078d4 <vector188>:
.globl vector188
vector188:
  pushl $0
801078d4:	6a 00                	push   $0x0
  pushl $188
801078d6:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801078db:	e9 34 f2 ff ff       	jmp    80106b14 <alltraps>

801078e0 <vector189>:
.globl vector189
vector189:
  pushl $0
801078e0:	6a 00                	push   $0x0
  pushl $189
801078e2:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801078e7:	e9 28 f2 ff ff       	jmp    80106b14 <alltraps>

801078ec <vector190>:
.globl vector190
vector190:
  pushl $0
801078ec:	6a 00                	push   $0x0
  pushl $190
801078ee:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801078f3:	e9 1c f2 ff ff       	jmp    80106b14 <alltraps>

801078f8 <vector191>:
.globl vector191
vector191:
  pushl $0
801078f8:	6a 00                	push   $0x0
  pushl $191
801078fa:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078ff:	e9 10 f2 ff ff       	jmp    80106b14 <alltraps>

80107904 <vector192>:
.globl vector192
vector192:
  pushl $0
80107904:	6a 00                	push   $0x0
  pushl $192
80107906:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010790b:	e9 04 f2 ff ff       	jmp    80106b14 <alltraps>

80107910 <vector193>:
.globl vector193
vector193:
  pushl $0
80107910:	6a 00                	push   $0x0
  pushl $193
80107912:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107917:	e9 f8 f1 ff ff       	jmp    80106b14 <alltraps>

8010791c <vector194>:
.globl vector194
vector194:
  pushl $0
8010791c:	6a 00                	push   $0x0
  pushl $194
8010791e:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107923:	e9 ec f1 ff ff       	jmp    80106b14 <alltraps>

80107928 <vector195>:
.globl vector195
vector195:
  pushl $0
80107928:	6a 00                	push   $0x0
  pushl $195
8010792a:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010792f:	e9 e0 f1 ff ff       	jmp    80106b14 <alltraps>

80107934 <vector196>:
.globl vector196
vector196:
  pushl $0
80107934:	6a 00                	push   $0x0
  pushl $196
80107936:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010793b:	e9 d4 f1 ff ff       	jmp    80106b14 <alltraps>

80107940 <vector197>:
.globl vector197
vector197:
  pushl $0
80107940:	6a 00                	push   $0x0
  pushl $197
80107942:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107947:	e9 c8 f1 ff ff       	jmp    80106b14 <alltraps>

8010794c <vector198>:
.globl vector198
vector198:
  pushl $0
8010794c:	6a 00                	push   $0x0
  pushl $198
8010794e:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107953:	e9 bc f1 ff ff       	jmp    80106b14 <alltraps>

80107958 <vector199>:
.globl vector199
vector199:
  pushl $0
80107958:	6a 00                	push   $0x0
  pushl $199
8010795a:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010795f:	e9 b0 f1 ff ff       	jmp    80106b14 <alltraps>

80107964 <vector200>:
.globl vector200
vector200:
  pushl $0
80107964:	6a 00                	push   $0x0
  pushl $200
80107966:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010796b:	e9 a4 f1 ff ff       	jmp    80106b14 <alltraps>

80107970 <vector201>:
.globl vector201
vector201:
  pushl $0
80107970:	6a 00                	push   $0x0
  pushl $201
80107972:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107977:	e9 98 f1 ff ff       	jmp    80106b14 <alltraps>

8010797c <vector202>:
.globl vector202
vector202:
  pushl $0
8010797c:	6a 00                	push   $0x0
  pushl $202
8010797e:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107983:	e9 8c f1 ff ff       	jmp    80106b14 <alltraps>

80107988 <vector203>:
.globl vector203
vector203:
  pushl $0
80107988:	6a 00                	push   $0x0
  pushl $203
8010798a:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010798f:	e9 80 f1 ff ff       	jmp    80106b14 <alltraps>

80107994 <vector204>:
.globl vector204
vector204:
  pushl $0
80107994:	6a 00                	push   $0x0
  pushl $204
80107996:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010799b:	e9 74 f1 ff ff       	jmp    80106b14 <alltraps>

801079a0 <vector205>:
.globl vector205
vector205:
  pushl $0
801079a0:	6a 00                	push   $0x0
  pushl $205
801079a2:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801079a7:	e9 68 f1 ff ff       	jmp    80106b14 <alltraps>

801079ac <vector206>:
.globl vector206
vector206:
  pushl $0
801079ac:	6a 00                	push   $0x0
  pushl $206
801079ae:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801079b3:	e9 5c f1 ff ff       	jmp    80106b14 <alltraps>

801079b8 <vector207>:
.globl vector207
vector207:
  pushl $0
801079b8:	6a 00                	push   $0x0
  pushl $207
801079ba:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801079bf:	e9 50 f1 ff ff       	jmp    80106b14 <alltraps>

801079c4 <vector208>:
.globl vector208
vector208:
  pushl $0
801079c4:	6a 00                	push   $0x0
  pushl $208
801079c6:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801079cb:	e9 44 f1 ff ff       	jmp    80106b14 <alltraps>

801079d0 <vector209>:
.globl vector209
vector209:
  pushl $0
801079d0:	6a 00                	push   $0x0
  pushl $209
801079d2:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801079d7:	e9 38 f1 ff ff       	jmp    80106b14 <alltraps>

801079dc <vector210>:
.globl vector210
vector210:
  pushl $0
801079dc:	6a 00                	push   $0x0
  pushl $210
801079de:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801079e3:	e9 2c f1 ff ff       	jmp    80106b14 <alltraps>

801079e8 <vector211>:
.globl vector211
vector211:
  pushl $0
801079e8:	6a 00                	push   $0x0
  pushl $211
801079ea:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801079ef:	e9 20 f1 ff ff       	jmp    80106b14 <alltraps>

801079f4 <vector212>:
.globl vector212
vector212:
  pushl $0
801079f4:	6a 00                	push   $0x0
  pushl $212
801079f6:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079fb:	e9 14 f1 ff ff       	jmp    80106b14 <alltraps>

80107a00 <vector213>:
.globl vector213
vector213:
  pushl $0
80107a00:	6a 00                	push   $0x0
  pushl $213
80107a02:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107a07:	e9 08 f1 ff ff       	jmp    80106b14 <alltraps>

80107a0c <vector214>:
.globl vector214
vector214:
  pushl $0
80107a0c:	6a 00                	push   $0x0
  pushl $214
80107a0e:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107a13:	e9 fc f0 ff ff       	jmp    80106b14 <alltraps>

80107a18 <vector215>:
.globl vector215
vector215:
  pushl $0
80107a18:	6a 00                	push   $0x0
  pushl $215
80107a1a:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107a1f:	e9 f0 f0 ff ff       	jmp    80106b14 <alltraps>

80107a24 <vector216>:
.globl vector216
vector216:
  pushl $0
80107a24:	6a 00                	push   $0x0
  pushl $216
80107a26:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107a2b:	e9 e4 f0 ff ff       	jmp    80106b14 <alltraps>

80107a30 <vector217>:
.globl vector217
vector217:
  pushl $0
80107a30:	6a 00                	push   $0x0
  pushl $217
80107a32:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107a37:	e9 d8 f0 ff ff       	jmp    80106b14 <alltraps>

80107a3c <vector218>:
.globl vector218
vector218:
  pushl $0
80107a3c:	6a 00                	push   $0x0
  pushl $218
80107a3e:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107a43:	e9 cc f0 ff ff       	jmp    80106b14 <alltraps>

80107a48 <vector219>:
.globl vector219
vector219:
  pushl $0
80107a48:	6a 00                	push   $0x0
  pushl $219
80107a4a:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a4f:	e9 c0 f0 ff ff       	jmp    80106b14 <alltraps>

80107a54 <vector220>:
.globl vector220
vector220:
  pushl $0
80107a54:	6a 00                	push   $0x0
  pushl $220
80107a56:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a5b:	e9 b4 f0 ff ff       	jmp    80106b14 <alltraps>

80107a60 <vector221>:
.globl vector221
vector221:
  pushl $0
80107a60:	6a 00                	push   $0x0
  pushl $221
80107a62:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a67:	e9 a8 f0 ff ff       	jmp    80106b14 <alltraps>

80107a6c <vector222>:
.globl vector222
vector222:
  pushl $0
80107a6c:	6a 00                	push   $0x0
  pushl $222
80107a6e:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a73:	e9 9c f0 ff ff       	jmp    80106b14 <alltraps>

80107a78 <vector223>:
.globl vector223
vector223:
  pushl $0
80107a78:	6a 00                	push   $0x0
  pushl $223
80107a7a:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a7f:	e9 90 f0 ff ff       	jmp    80106b14 <alltraps>

80107a84 <vector224>:
.globl vector224
vector224:
  pushl $0
80107a84:	6a 00                	push   $0x0
  pushl $224
80107a86:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a8b:	e9 84 f0 ff ff       	jmp    80106b14 <alltraps>

80107a90 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a90:	6a 00                	push   $0x0
  pushl $225
80107a92:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a97:	e9 78 f0 ff ff       	jmp    80106b14 <alltraps>

80107a9c <vector226>:
.globl vector226
vector226:
  pushl $0
80107a9c:	6a 00                	push   $0x0
  pushl $226
80107a9e:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107aa3:	e9 6c f0 ff ff       	jmp    80106b14 <alltraps>

80107aa8 <vector227>:
.globl vector227
vector227:
  pushl $0
80107aa8:	6a 00                	push   $0x0
  pushl $227
80107aaa:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107aaf:	e9 60 f0 ff ff       	jmp    80106b14 <alltraps>

80107ab4 <vector228>:
.globl vector228
vector228:
  pushl $0
80107ab4:	6a 00                	push   $0x0
  pushl $228
80107ab6:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107abb:	e9 54 f0 ff ff       	jmp    80106b14 <alltraps>

80107ac0 <vector229>:
.globl vector229
vector229:
  pushl $0
80107ac0:	6a 00                	push   $0x0
  pushl $229
80107ac2:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107ac7:	e9 48 f0 ff ff       	jmp    80106b14 <alltraps>

80107acc <vector230>:
.globl vector230
vector230:
  pushl $0
80107acc:	6a 00                	push   $0x0
  pushl $230
80107ace:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107ad3:	e9 3c f0 ff ff       	jmp    80106b14 <alltraps>

80107ad8 <vector231>:
.globl vector231
vector231:
  pushl $0
80107ad8:	6a 00                	push   $0x0
  pushl $231
80107ada:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107adf:	e9 30 f0 ff ff       	jmp    80106b14 <alltraps>

80107ae4 <vector232>:
.globl vector232
vector232:
  pushl $0
80107ae4:	6a 00                	push   $0x0
  pushl $232
80107ae6:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107aeb:	e9 24 f0 ff ff       	jmp    80106b14 <alltraps>

80107af0 <vector233>:
.globl vector233
vector233:
  pushl $0
80107af0:	6a 00                	push   $0x0
  pushl $233
80107af2:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107af7:	e9 18 f0 ff ff       	jmp    80106b14 <alltraps>

80107afc <vector234>:
.globl vector234
vector234:
  pushl $0
80107afc:	6a 00                	push   $0x0
  pushl $234
80107afe:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107b03:	e9 0c f0 ff ff       	jmp    80106b14 <alltraps>

80107b08 <vector235>:
.globl vector235
vector235:
  pushl $0
80107b08:	6a 00                	push   $0x0
  pushl $235
80107b0a:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107b0f:	e9 00 f0 ff ff       	jmp    80106b14 <alltraps>

80107b14 <vector236>:
.globl vector236
vector236:
  pushl $0
80107b14:	6a 00                	push   $0x0
  pushl $236
80107b16:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107b1b:	e9 f4 ef ff ff       	jmp    80106b14 <alltraps>

80107b20 <vector237>:
.globl vector237
vector237:
  pushl $0
80107b20:	6a 00                	push   $0x0
  pushl $237
80107b22:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107b27:	e9 e8 ef ff ff       	jmp    80106b14 <alltraps>

80107b2c <vector238>:
.globl vector238
vector238:
  pushl $0
80107b2c:	6a 00                	push   $0x0
  pushl $238
80107b2e:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107b33:	e9 dc ef ff ff       	jmp    80106b14 <alltraps>

80107b38 <vector239>:
.globl vector239
vector239:
  pushl $0
80107b38:	6a 00                	push   $0x0
  pushl $239
80107b3a:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107b3f:	e9 d0 ef ff ff       	jmp    80106b14 <alltraps>

80107b44 <vector240>:
.globl vector240
vector240:
  pushl $0
80107b44:	6a 00                	push   $0x0
  pushl $240
80107b46:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107b4b:	e9 c4 ef ff ff       	jmp    80106b14 <alltraps>

80107b50 <vector241>:
.globl vector241
vector241:
  pushl $0
80107b50:	6a 00                	push   $0x0
  pushl $241
80107b52:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b57:	e9 b8 ef ff ff       	jmp    80106b14 <alltraps>

80107b5c <vector242>:
.globl vector242
vector242:
  pushl $0
80107b5c:	6a 00                	push   $0x0
  pushl $242
80107b5e:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b63:	e9 ac ef ff ff       	jmp    80106b14 <alltraps>

80107b68 <vector243>:
.globl vector243
vector243:
  pushl $0
80107b68:	6a 00                	push   $0x0
  pushl $243
80107b6a:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b6f:	e9 a0 ef ff ff       	jmp    80106b14 <alltraps>

80107b74 <vector244>:
.globl vector244
vector244:
  pushl $0
80107b74:	6a 00                	push   $0x0
  pushl $244
80107b76:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b7b:	e9 94 ef ff ff       	jmp    80106b14 <alltraps>

80107b80 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b80:	6a 00                	push   $0x0
  pushl $245
80107b82:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b87:	e9 88 ef ff ff       	jmp    80106b14 <alltraps>

80107b8c <vector246>:
.globl vector246
vector246:
  pushl $0
80107b8c:	6a 00                	push   $0x0
  pushl $246
80107b8e:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b93:	e9 7c ef ff ff       	jmp    80106b14 <alltraps>

80107b98 <vector247>:
.globl vector247
vector247:
  pushl $0
80107b98:	6a 00                	push   $0x0
  pushl $247
80107b9a:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b9f:	e9 70 ef ff ff       	jmp    80106b14 <alltraps>

80107ba4 <vector248>:
.globl vector248
vector248:
  pushl $0
80107ba4:	6a 00                	push   $0x0
  pushl $248
80107ba6:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107bab:	e9 64 ef ff ff       	jmp    80106b14 <alltraps>

80107bb0 <vector249>:
.globl vector249
vector249:
  pushl $0
80107bb0:	6a 00                	push   $0x0
  pushl $249
80107bb2:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107bb7:	e9 58 ef ff ff       	jmp    80106b14 <alltraps>

80107bbc <vector250>:
.globl vector250
vector250:
  pushl $0
80107bbc:	6a 00                	push   $0x0
  pushl $250
80107bbe:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107bc3:	e9 4c ef ff ff       	jmp    80106b14 <alltraps>

80107bc8 <vector251>:
.globl vector251
vector251:
  pushl $0
80107bc8:	6a 00                	push   $0x0
  pushl $251
80107bca:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107bcf:	e9 40 ef ff ff       	jmp    80106b14 <alltraps>

80107bd4 <vector252>:
.globl vector252
vector252:
  pushl $0
80107bd4:	6a 00                	push   $0x0
  pushl $252
80107bd6:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107bdb:	e9 34 ef ff ff       	jmp    80106b14 <alltraps>

80107be0 <vector253>:
.globl vector253
vector253:
  pushl $0
80107be0:	6a 00                	push   $0x0
  pushl $253
80107be2:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107be7:	e9 28 ef ff ff       	jmp    80106b14 <alltraps>

80107bec <vector254>:
.globl vector254
vector254:
  pushl $0
80107bec:	6a 00                	push   $0x0
  pushl $254
80107bee:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107bf3:	e9 1c ef ff ff       	jmp    80106b14 <alltraps>

80107bf8 <vector255>:
.globl vector255
vector255:
  pushl $0
80107bf8:	6a 00                	push   $0x0
  pushl $255
80107bfa:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107bff:	e9 10 ef ff ff       	jmp    80106b14 <alltraps>

80107c04 <lgdt>:
{
80107c04:	55                   	push   %ebp
80107c05:	89 e5                	mov    %esp,%ebp
80107c07:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c0d:	83 e8 01             	sub    $0x1,%eax
80107c10:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107c14:	8b 45 08             	mov    0x8(%ebp),%eax
80107c17:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80107c1e:	c1 e8 10             	shr    $0x10,%eax
80107c21:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107c25:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107c28:	0f 01 10             	lgdtl  (%eax)
}
80107c2b:	90                   	nop
80107c2c:	c9                   	leave  
80107c2d:	c3                   	ret    

80107c2e <ltr>:
{
80107c2e:	55                   	push   %ebp
80107c2f:	89 e5                	mov    %esp,%ebp
80107c31:	83 ec 04             	sub    $0x4,%esp
80107c34:	8b 45 08             	mov    0x8(%ebp),%eax
80107c37:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107c3b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c3f:	0f 00 d8             	ltr    %ax
}
80107c42:	90                   	nop
80107c43:	c9                   	leave  
80107c44:	c3                   	ret    

80107c45 <lcr3>:

static inline void
lcr3(uint val)
{
80107c45:	55                   	push   %ebp
80107c46:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107c48:	8b 45 08             	mov    0x8(%ebp),%eax
80107c4b:	0f 22 d8             	mov    %eax,%cr3
}
80107c4e:	90                   	nop
80107c4f:	5d                   	pop    %ebp
80107c50:	c3                   	ret    

80107c51 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107c51:	f3 0f 1e fb          	endbr32 
80107c55:	55                   	push   %ebp
80107c56:	89 e5                	mov    %esp,%ebp
80107c58:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107c5b:	e8 12 c8 ff ff       	call   80104472 <cpuid>
80107c60:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107c66:	05 20 48 11 80       	add    $0x80114820,%eax
80107c6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c71:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7a:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c83:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c8e:	83 e2 f0             	and    $0xfffffff0,%edx
80107c91:	83 ca 0a             	or     $0xa,%edx
80107c94:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c9e:	83 ca 10             	or     $0x10,%edx
80107ca1:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107cab:	83 e2 9f             	and    $0xffffff9f,%edx
80107cae:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107cb8:	83 ca 80             	or     $0xffffff80,%edx
80107cbb:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cc5:	83 ca 0f             	or     $0xf,%edx
80107cc8:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cce:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cd2:	83 e2 ef             	and    $0xffffffef,%edx
80107cd5:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cdf:	83 e2 df             	and    $0xffffffdf,%edx
80107ce2:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cec:	83 ca 40             	or     $0x40,%edx
80107cef:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cf9:	83 ca 80             	or     $0xffffff80,%edx
80107cfc:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d02:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d09:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107d10:	ff ff 
80107d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d15:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107d1c:	00 00 
80107d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d21:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d32:	83 e2 f0             	and    $0xfffffff0,%edx
80107d35:	83 ca 02             	or     $0x2,%edx
80107d38:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d41:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d48:	83 ca 10             	or     $0x10,%edx
80107d4b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d54:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d5b:	83 e2 9f             	and    $0xffffff9f,%edx
80107d5e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d67:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d6e:	83 ca 80             	or     $0xffffff80,%edx
80107d71:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d81:	83 ca 0f             	or     $0xf,%edx
80107d84:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d94:	83 e2 ef             	and    $0xffffffef,%edx
80107d97:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107da7:	83 e2 df             	and    $0xffffffdf,%edx
80107daa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107dba:	83 ca 40             	or     $0x40,%edx
80107dbd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107dcd:	83 ca 80             	or     $0xffffff80,%edx
80107dd0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd9:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de3:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107dea:	ff ff 
80107dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107def:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107df6:	00 00 
80107df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfb:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e05:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e0c:	83 e2 f0             	and    $0xfffffff0,%edx
80107e0f:	83 ca 0a             	or     $0xa,%edx
80107e12:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e22:	83 ca 10             	or     $0x10,%edx
80107e25:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e35:	83 ca 60             	or     $0x60,%edx
80107e38:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e41:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e48:	83 ca 80             	or     $0xffffff80,%edx
80107e4b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e54:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e5b:	83 ca 0f             	or     $0xf,%edx
80107e5e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e67:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e6e:	83 e2 ef             	and    $0xffffffef,%edx
80107e71:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e81:	83 e2 df             	and    $0xffffffdf,%edx
80107e84:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e94:	83 ca 40             	or     $0x40,%edx
80107e97:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ea7:	83 ca 80             	or     $0xffffff80,%edx
80107eaa:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb3:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebd:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107ec4:	ff ff 
80107ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec9:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107ed0:	00 00 
80107ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed5:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edf:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ee6:	83 e2 f0             	and    $0xfffffff0,%edx
80107ee9:	83 ca 02             	or     $0x2,%edx
80107eec:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef5:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107efc:	83 ca 10             	or     $0x10,%edx
80107eff:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f0f:	83 ca 60             	or     $0x60,%edx
80107f12:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f22:	83 ca 80             	or     $0xffffff80,%edx
80107f25:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f35:	83 ca 0f             	or     $0xf,%edx
80107f38:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f41:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f48:	83 e2 ef             	and    $0xffffffef,%edx
80107f4b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f54:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f5b:	83 e2 df             	and    $0xffffffdf,%edx
80107f5e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f67:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f6e:	83 ca 40             	or     $0x40,%edx
80107f71:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f81:	83 ca 80             	or     $0xffffff80,%edx
80107f84:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8d:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f97:	83 c0 70             	add    $0x70,%eax
80107f9a:	83 ec 08             	sub    $0x8,%esp
80107f9d:	6a 30                	push   $0x30
80107f9f:	50                   	push   %eax
80107fa0:	e8 5f fc ff ff       	call   80107c04 <lgdt>
80107fa5:	83 c4 10             	add    $0x10,%esp
}
80107fa8:	90                   	nop
80107fa9:	c9                   	leave  
80107faa:	c3                   	ret    

80107fab <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107fab:	f3 0f 1e fb          	endbr32 
80107faf:	55                   	push   %ebp
80107fb0:	89 e5                	mov    %esp,%ebp
80107fb2:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fb8:	c1 e8 16             	shr    $0x16,%eax
80107fbb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80107fc5:	01 d0                	add    %edx,%eax
80107fc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fcd:	8b 00                	mov    (%eax),%eax
80107fcf:	83 e0 01             	and    $0x1,%eax
80107fd2:	85 c0                	test   %eax,%eax
80107fd4:	74 14                	je     80107fea <walkpgdir+0x3f>
    //if (!alloc)
      //cprintf("page directory is good\n");
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fd9:	8b 00                	mov    (%eax),%eax
80107fdb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fe0:	05 00 00 00 80       	add    $0x80000000,%eax
80107fe5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fe8:	eb 42                	jmp    8010802c <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107fea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107fee:	74 0e                	je     80107ffe <walkpgdir+0x53>
80107ff0:	e8 54 ae ff ff       	call   80102e49 <kalloc>
80107ff5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ff8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ffc:	75 07                	jne    80108005 <walkpgdir+0x5a>
      return 0;
80107ffe:	b8 00 00 00 00       	mov    $0x0,%eax
80108003:	eb 3e                	jmp    80108043 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108005:	83 ec 04             	sub    $0x4,%esp
80108008:	68 00 10 00 00       	push   $0x1000
8010800d:	6a 00                	push   $0x0
8010800f:	ff 75 f4             	pushl  -0xc(%ebp)
80108012:	e8 9f d5 ff ff       	call   801055b6 <memset>
80108017:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010801a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801d:	05 00 00 00 80       	add    $0x80000000,%eax
80108022:	83 c8 07             	or     $0x7,%eax
80108025:	89 c2                	mov    %eax,%edx
80108027:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010802a:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010802c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010802f:	c1 e8 0c             	shr    $0xc,%eax
80108032:	25 ff 03 00 00       	and    $0x3ff,%eax
80108037:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010803e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108041:	01 d0                	add    %edx,%eax
}
80108043:	c9                   	leave  
80108044:	c3                   	ret    

80108045 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108045:	f3 0f 1e fb          	endbr32 
80108049:	55                   	push   %ebp
8010804a:	89 e5                	mov    %esp,%ebp
8010804c:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010804f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108057:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010805a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010805d:	8b 45 10             	mov    0x10(%ebp),%eax
80108060:	01 d0                	add    %edx,%eax
80108062:	83 e8 01             	sub    $0x1,%eax
80108065:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010806a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010806d:	83 ec 04             	sub    $0x4,%esp
80108070:	6a 01                	push   $0x1
80108072:	ff 75 f4             	pushl  -0xc(%ebp)
80108075:	ff 75 08             	pushl  0x8(%ebp)
80108078:	e8 2e ff ff ff       	call   80107fab <walkpgdir>
8010807d:	83 c4 10             	add    $0x10,%esp
80108080:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108083:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108087:	75 07                	jne    80108090 <mappages+0x4b>
      return -1;
80108089:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010808e:	eb 6a                	jmp    801080fa <mappages+0xb5>
    if(*pte & (PTE_P | PTE_E))
80108090:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108093:	8b 00                	mov    (%eax),%eax
80108095:	25 01 04 00 00       	and    $0x401,%eax
8010809a:	85 c0                	test   %eax,%eax
8010809c:	74 0d                	je     801080ab <mappages+0x66>
      panic("p4Debug, remapping page");
8010809e:	83 ec 0c             	sub    $0xc,%esp
801080a1:	68 3c 99 10 80       	push   $0x8010993c
801080a6:	e8 5d 85 ff ff       	call   80100608 <panic>

    if (perm & PTE_E)
801080ab:	8b 45 18             	mov    0x18(%ebp),%eax
801080ae:	25 00 04 00 00       	and    $0x400,%eax
801080b3:	85 c0                	test   %eax,%eax
801080b5:	74 12                	je     801080c9 <mappages+0x84>
      *pte = pa | perm | PTE_E;
801080b7:	8b 45 18             	mov    0x18(%ebp),%eax
801080ba:	0b 45 14             	or     0x14(%ebp),%eax
801080bd:	80 cc 04             	or     $0x4,%ah
801080c0:	89 c2                	mov    %eax,%edx
801080c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080c5:	89 10                	mov    %edx,(%eax)
801080c7:	eb 10                	jmp    801080d9 <mappages+0x94>
    else
      *pte = pa | perm | PTE_P;
801080c9:	8b 45 18             	mov    0x18(%ebp),%eax
801080cc:	0b 45 14             	or     0x14(%ebp),%eax
801080cf:	83 c8 01             	or     $0x1,%eax
801080d2:	89 c2                	mov    %eax,%edx
801080d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080d7:	89 10                	mov    %edx,(%eax)


    if(a == last)
801080d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080dc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801080df:	74 13                	je     801080f4 <mappages+0xaf>
      break;
    a += PGSIZE;
801080e1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801080e8:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801080ef:	e9 79 ff ff ff       	jmp    8010806d <mappages+0x28>
      break;
801080f4:	90                   	nop
  }
  return 0;
801080f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080fa:	c9                   	leave  
801080fb:	c3                   	ret    

801080fc <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801080fc:	f3 0f 1e fb          	endbr32 
80108100:	55                   	push   %ebp
80108101:	89 e5                	mov    %esp,%ebp
80108103:	53                   	push   %ebx
80108104:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108107:	e8 3d ad ff ff       	call   80102e49 <kalloc>
8010810c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010810f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108113:	75 07                	jne    8010811c <setupkvm+0x20>
    return 0;
80108115:	b8 00 00 00 00       	mov    $0x0,%eax
8010811a:	eb 78                	jmp    80108194 <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
8010811c:	83 ec 04             	sub    $0x4,%esp
8010811f:	68 00 10 00 00       	push   $0x1000
80108124:	6a 00                	push   $0x0
80108126:	ff 75 f0             	pushl  -0x10(%ebp)
80108129:	e8 88 d4 ff ff       	call   801055b6 <memset>
8010812e:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108131:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108138:	eb 4e                	jmp    80108188 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010813a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813d:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80108140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108143:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108149:	8b 58 08             	mov    0x8(%eax),%ebx
8010814c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010814f:	8b 40 04             	mov    0x4(%eax),%eax
80108152:	29 c3                	sub    %eax,%ebx
80108154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108157:	8b 00                	mov    (%eax),%eax
80108159:	83 ec 0c             	sub    $0xc,%esp
8010815c:	51                   	push   %ecx
8010815d:	52                   	push   %edx
8010815e:	53                   	push   %ebx
8010815f:	50                   	push   %eax
80108160:	ff 75 f0             	pushl  -0x10(%ebp)
80108163:	e8 dd fe ff ff       	call   80108045 <mappages>
80108168:	83 c4 20             	add    $0x20,%esp
8010816b:	85 c0                	test   %eax,%eax
8010816d:	79 15                	jns    80108184 <setupkvm+0x88>
      freevm(pgdir);
8010816f:	83 ec 0c             	sub    $0xc,%esp
80108172:	ff 75 f0             	pushl  -0x10(%ebp)
80108175:	e8 13 05 00 00       	call   8010868d <freevm>
8010817a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010817d:	b8 00 00 00 00       	mov    $0x0,%eax
80108182:	eb 10                	jmp    80108194 <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108184:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108188:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
8010818f:	72 a9                	jb     8010813a <setupkvm+0x3e>
    }
  return pgdir;
80108191:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108194:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108197:	c9                   	leave  
80108198:	c3                   	ret    

80108199 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108199:	f3 0f 1e fb          	endbr32 
8010819d:	55                   	push   %ebp
8010819e:	89 e5                	mov    %esp,%ebp
801081a0:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801081a3:	e8 54 ff ff ff       	call   801080fc <setupkvm>
801081a8:	a3 44 7f 11 80       	mov    %eax,0x80117f44
  switchkvm();
801081ad:	e8 03 00 00 00       	call   801081b5 <switchkvm>
}
801081b2:	90                   	nop
801081b3:	c9                   	leave  
801081b4:	c3                   	ret    

801081b5 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801081b5:	f3 0f 1e fb          	endbr32 
801081b9:	55                   	push   %ebp
801081ba:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801081bc:	a1 44 7f 11 80       	mov    0x80117f44,%eax
801081c1:	05 00 00 00 80       	add    $0x80000000,%eax
801081c6:	50                   	push   %eax
801081c7:	e8 79 fa ff ff       	call   80107c45 <lcr3>
801081cc:	83 c4 04             	add    $0x4,%esp
}
801081cf:	90                   	nop
801081d0:	c9                   	leave  
801081d1:	c3                   	ret    

801081d2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801081d2:	f3 0f 1e fb          	endbr32 
801081d6:	55                   	push   %ebp
801081d7:	89 e5                	mov    %esp,%ebp
801081d9:	56                   	push   %esi
801081da:	53                   	push   %ebx
801081db:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801081de:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801081e2:	75 0d                	jne    801081f1 <switchuvm+0x1f>
    panic("switchuvm: no process");
801081e4:	83 ec 0c             	sub    $0xc,%esp
801081e7:	68 54 99 10 80       	push   $0x80109954
801081ec:	e8 17 84 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
801081f1:	8b 45 08             	mov    0x8(%ebp),%eax
801081f4:	8b 40 08             	mov    0x8(%eax),%eax
801081f7:	85 c0                	test   %eax,%eax
801081f9:	75 0d                	jne    80108208 <switchuvm+0x36>
    panic("switchuvm: no kstack");
801081fb:	83 ec 0c             	sub    $0xc,%esp
801081fe:	68 6a 99 10 80       	push   $0x8010996a
80108203:	e8 00 84 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
80108208:	8b 45 08             	mov    0x8(%ebp),%eax
8010820b:	8b 40 04             	mov    0x4(%eax),%eax
8010820e:	85 c0                	test   %eax,%eax
80108210:	75 0d                	jne    8010821f <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80108212:	83 ec 0c             	sub    $0xc,%esp
80108215:	68 7f 99 10 80       	push   $0x8010997f
8010821a:	e8 e9 83 ff ff       	call   80100608 <panic>

  pushcli();
8010821f:	e8 7f d2 ff ff       	call   801054a3 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108224:	e8 68 c2 ff ff       	call   80104491 <mycpu>
80108229:	89 c3                	mov    %eax,%ebx
8010822b:	e8 61 c2 ff ff       	call   80104491 <mycpu>
80108230:	83 c0 08             	add    $0x8,%eax
80108233:	89 c6                	mov    %eax,%esi
80108235:	e8 57 c2 ff ff       	call   80104491 <mycpu>
8010823a:	83 c0 08             	add    $0x8,%eax
8010823d:	c1 e8 10             	shr    $0x10,%eax
80108240:	88 45 f7             	mov    %al,-0x9(%ebp)
80108243:	e8 49 c2 ff ff       	call   80104491 <mycpu>
80108248:	83 c0 08             	add    $0x8,%eax
8010824b:	c1 e8 18             	shr    $0x18,%eax
8010824e:	89 c2                	mov    %eax,%edx
80108250:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108257:	67 00 
80108259:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108260:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108264:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010826a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108271:	83 e0 f0             	and    $0xfffffff0,%eax
80108274:	83 c8 09             	or     $0x9,%eax
80108277:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010827d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108284:	83 c8 10             	or     $0x10,%eax
80108287:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010828d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108294:	83 e0 9f             	and    $0xffffff9f,%eax
80108297:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010829d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801082a4:	83 c8 80             	or     $0xffffff80,%eax
801082a7:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801082ad:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082b4:	83 e0 f0             	and    $0xfffffff0,%eax
801082b7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082bd:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082c4:	83 e0 ef             	and    $0xffffffef,%eax
801082c7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082cd:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082d4:	83 e0 df             	and    $0xffffffdf,%eax
801082d7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082dd:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082e4:	83 c8 40             	or     $0x40,%eax
801082e7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082ed:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082f4:	83 e0 7f             	and    $0x7f,%eax
801082f7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082fd:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108303:	e8 89 c1 ff ff       	call   80104491 <mycpu>
80108308:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010830f:	83 e2 ef             	and    $0xffffffef,%edx
80108312:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108318:	e8 74 c1 ff ff       	call   80104491 <mycpu>
8010831d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108323:	8b 45 08             	mov    0x8(%ebp),%eax
80108326:	8b 40 08             	mov    0x8(%eax),%eax
80108329:	89 c3                	mov    %eax,%ebx
8010832b:	e8 61 c1 ff ff       	call   80104491 <mycpu>
80108330:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108336:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108339:	e8 53 c1 ff ff       	call   80104491 <mycpu>
8010833e:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108344:	83 ec 0c             	sub    $0xc,%esp
80108347:	6a 28                	push   $0x28
80108349:	e8 e0 f8 ff ff       	call   80107c2e <ltr>
8010834e:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108351:	8b 45 08             	mov    0x8(%ebp),%eax
80108354:	8b 40 04             	mov    0x4(%eax),%eax
80108357:	05 00 00 00 80       	add    $0x80000000,%eax
8010835c:	83 ec 0c             	sub    $0xc,%esp
8010835f:	50                   	push   %eax
80108360:	e8 e0 f8 ff ff       	call   80107c45 <lcr3>
80108365:	83 c4 10             	add    $0x10,%esp
  popcli();
80108368:	e8 87 d1 ff ff       	call   801054f4 <popcli>
}
8010836d:	90                   	nop
8010836e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108371:	5b                   	pop    %ebx
80108372:	5e                   	pop    %esi
80108373:	5d                   	pop    %ebp
80108374:	c3                   	ret    

80108375 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108375:	f3 0f 1e fb          	endbr32 
80108379:	55                   	push   %ebp
8010837a:	89 e5                	mov    %esp,%ebp
8010837c:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010837f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108386:	76 0d                	jbe    80108395 <inituvm+0x20>
    panic("inituvm: more than a page");
80108388:	83 ec 0c             	sub    $0xc,%esp
8010838b:	68 93 99 10 80       	push   $0x80109993
80108390:	e8 73 82 ff ff       	call   80100608 <panic>
  mem = kalloc();
80108395:	e8 af aa ff ff       	call   80102e49 <kalloc>
8010839a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010839d:	83 ec 04             	sub    $0x4,%esp
801083a0:	68 00 10 00 00       	push   $0x1000
801083a5:	6a 00                	push   $0x0
801083a7:	ff 75 f4             	pushl  -0xc(%ebp)
801083aa:	e8 07 d2 ff ff       	call   801055b6 <memset>
801083af:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801083b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b5:	05 00 00 00 80       	add    $0x80000000,%eax
801083ba:	83 ec 0c             	sub    $0xc,%esp
801083bd:	6a 06                	push   $0x6
801083bf:	50                   	push   %eax
801083c0:	68 00 10 00 00       	push   $0x1000
801083c5:	6a 00                	push   $0x0
801083c7:	ff 75 08             	pushl  0x8(%ebp)
801083ca:	e8 76 fc ff ff       	call   80108045 <mappages>
801083cf:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801083d2:	83 ec 04             	sub    $0x4,%esp
801083d5:	ff 75 10             	pushl  0x10(%ebp)
801083d8:	ff 75 0c             	pushl  0xc(%ebp)
801083db:	ff 75 f4             	pushl  -0xc(%ebp)
801083de:	e8 9a d2 ff ff       	call   8010567d <memmove>
801083e3:	83 c4 10             	add    $0x10,%esp
}
801083e6:	90                   	nop
801083e7:	c9                   	leave  
801083e8:	c3                   	ret    

801083e9 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801083e9:	f3 0f 1e fb          	endbr32 
801083ed:	55                   	push   %ebp
801083ee:	89 e5                	mov    %esp,%ebp
801083f0:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801083f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801083f6:	25 ff 0f 00 00       	and    $0xfff,%eax
801083fb:	85 c0                	test   %eax,%eax
801083fd:	74 0d                	je     8010840c <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801083ff:	83 ec 0c             	sub    $0xc,%esp
80108402:	68 b0 99 10 80       	push   $0x801099b0
80108407:	e8 fc 81 ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010840c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108413:	e9 8f 00 00 00       	jmp    801084a7 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108418:	8b 55 0c             	mov    0xc(%ebp),%edx
8010841b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841e:	01 d0                	add    %edx,%eax
80108420:	83 ec 04             	sub    $0x4,%esp
80108423:	6a 00                	push   $0x0
80108425:	50                   	push   %eax
80108426:	ff 75 08             	pushl  0x8(%ebp)
80108429:	e8 7d fb ff ff       	call   80107fab <walkpgdir>
8010842e:	83 c4 10             	add    $0x10,%esp
80108431:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108434:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108438:	75 0d                	jne    80108447 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
8010843a:	83 ec 0c             	sub    $0xc,%esp
8010843d:	68 d3 99 10 80       	push   $0x801099d3
80108442:	e8 c1 81 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
80108447:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010844a:	8b 00                	mov    (%eax),%eax
8010844c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108451:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108454:	8b 45 18             	mov    0x18(%ebp),%eax
80108457:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010845a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010845f:	77 0b                	ja     8010846c <loaduvm+0x83>
      n = sz - i;
80108461:	8b 45 18             	mov    0x18(%ebp),%eax
80108464:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108467:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010846a:	eb 07                	jmp    80108473 <loaduvm+0x8a>
    else
      n = PGSIZE;
8010846c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108473:	8b 55 14             	mov    0x14(%ebp),%edx
80108476:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108479:	01 d0                	add    %edx,%eax
8010847b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010847e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108484:	ff 75 f0             	pushl  -0x10(%ebp)
80108487:	50                   	push   %eax
80108488:	52                   	push   %edx
80108489:	ff 75 10             	pushl  0x10(%ebp)
8010848c:	e8 d0 9b ff ff       	call   80102061 <readi>
80108491:	83 c4 10             	add    $0x10,%esp
80108494:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108497:	74 07                	je     801084a0 <loaduvm+0xb7>
      return -1;
80108499:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010849e:	eb 18                	jmp    801084b8 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
801084a0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084aa:	3b 45 18             	cmp    0x18(%ebp),%eax
801084ad:	0f 82 65 ff ff ff    	jb     80108418 <loaduvm+0x2f>
  }
  return 0;
801084b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084b8:	c9                   	leave  
801084b9:	c3                   	ret    

801084ba <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084ba:	f3 0f 1e fb          	endbr32 
801084be:	55                   	push   %ebp
801084bf:	89 e5                	mov    %esp,%ebp
801084c1:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801084c4:	8b 45 10             	mov    0x10(%ebp),%eax
801084c7:	85 c0                	test   %eax,%eax
801084c9:	79 0a                	jns    801084d5 <allocuvm+0x1b>
    return 0;
801084cb:	b8 00 00 00 00       	mov    $0x0,%eax
801084d0:	e9 ec 00 00 00       	jmp    801085c1 <allocuvm+0x107>
  if(newsz < oldsz)
801084d5:	8b 45 10             	mov    0x10(%ebp),%eax
801084d8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084db:	73 08                	jae    801084e5 <allocuvm+0x2b>
    return oldsz;
801084dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801084e0:	e9 dc 00 00 00       	jmp    801085c1 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
801084e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801084e8:	05 ff 0f 00 00       	add    $0xfff,%eax
801084ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801084f5:	e9 b8 00 00 00       	jmp    801085b2 <allocuvm+0xf8>
    mem = kalloc();
801084fa:	e8 4a a9 ff ff       	call   80102e49 <kalloc>
801084ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108502:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108506:	75 2e                	jne    80108536 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80108508:	83 ec 0c             	sub    $0xc,%esp
8010850b:	68 f1 99 10 80       	push   $0x801099f1
80108510:	e8 03 7f ff ff       	call   80100418 <cprintf>
80108515:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108518:	83 ec 04             	sub    $0x4,%esp
8010851b:	ff 75 0c             	pushl  0xc(%ebp)
8010851e:	ff 75 10             	pushl  0x10(%ebp)
80108521:	ff 75 08             	pushl  0x8(%ebp)
80108524:	e8 9a 00 00 00       	call   801085c3 <deallocuvm>
80108529:	83 c4 10             	add    $0x10,%esp
      return 0;
8010852c:	b8 00 00 00 00       	mov    $0x0,%eax
80108531:	e9 8b 00 00 00       	jmp    801085c1 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80108536:	83 ec 04             	sub    $0x4,%esp
80108539:	68 00 10 00 00       	push   $0x1000
8010853e:	6a 00                	push   $0x0
80108540:	ff 75 f0             	pushl  -0x10(%ebp)
80108543:	e8 6e d0 ff ff       	call   801055b6 <memset>
80108548:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010854b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010854e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108557:	83 ec 0c             	sub    $0xc,%esp
8010855a:	6a 06                	push   $0x6
8010855c:	52                   	push   %edx
8010855d:	68 00 10 00 00       	push   $0x1000
80108562:	50                   	push   %eax
80108563:	ff 75 08             	pushl  0x8(%ebp)
80108566:	e8 da fa ff ff       	call   80108045 <mappages>
8010856b:	83 c4 20             	add    $0x20,%esp
8010856e:	85 c0                	test   %eax,%eax
80108570:	79 39                	jns    801085ab <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80108572:	83 ec 0c             	sub    $0xc,%esp
80108575:	68 09 9a 10 80       	push   $0x80109a09
8010857a:	e8 99 7e ff ff       	call   80100418 <cprintf>
8010857f:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108582:	83 ec 04             	sub    $0x4,%esp
80108585:	ff 75 0c             	pushl  0xc(%ebp)
80108588:	ff 75 10             	pushl  0x10(%ebp)
8010858b:	ff 75 08             	pushl  0x8(%ebp)
8010858e:	e8 30 00 00 00       	call   801085c3 <deallocuvm>
80108593:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108596:	83 ec 0c             	sub    $0xc,%esp
80108599:	ff 75 f0             	pushl  -0x10(%ebp)
8010859c:	e8 0a a8 ff ff       	call   80102dab <kfree>
801085a1:	83 c4 10             	add    $0x10,%esp
      return 0;
801085a4:	b8 00 00 00 00       	mov    $0x0,%eax
801085a9:	eb 16                	jmp    801085c1 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
801085ab:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801085b8:	0f 82 3c ff ff ff    	jb     801084fa <allocuvm+0x40>
    }
  }
  return newsz;
801085be:	8b 45 10             	mov    0x10(%ebp),%eax
}
801085c1:	c9                   	leave  
801085c2:	c3                   	ret    

801085c3 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801085c3:	f3 0f 1e fb          	endbr32 
801085c7:	55                   	push   %ebp
801085c8:	89 e5                	mov    %esp,%ebp
801085ca:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801085cd:	8b 45 10             	mov    0x10(%ebp),%eax
801085d0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085d3:	72 08                	jb     801085dd <deallocuvm+0x1a>
    return oldsz;
801085d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801085d8:	e9 ae 00 00 00       	jmp    8010868b <deallocuvm+0xc8>

  a = PGROUNDUP(newsz);
801085dd:	8b 45 10             	mov    0x10(%ebp),%eax
801085e0:	05 ff 0f 00 00       	add    $0xfff,%eax
801085e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801085ed:	e9 8a 00 00 00       	jmp    8010867c <deallocuvm+0xb9>
    pte = walkpgdir(pgdir, (char*)a, 0);
801085f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f5:	83 ec 04             	sub    $0x4,%esp
801085f8:	6a 00                	push   $0x0
801085fa:	50                   	push   %eax
801085fb:	ff 75 08             	pushl  0x8(%ebp)
801085fe:	e8 a8 f9 ff ff       	call   80107fab <walkpgdir>
80108603:	83 c4 10             	add    $0x10,%esp
80108606:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108609:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010860d:	75 16                	jne    80108625 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010860f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108612:	c1 e8 16             	shr    $0x16,%eax
80108615:	83 c0 01             	add    $0x1,%eax
80108618:	c1 e0 16             	shl    $0x16,%eax
8010861b:	2d 00 10 00 00       	sub    $0x1000,%eax
80108620:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108623:	eb 50                	jmp    80108675 <deallocuvm+0xb2>
    else if((*pte & (PTE_P | PTE_E)) != 0){
80108625:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108628:	8b 00                	mov    (%eax),%eax
8010862a:	25 01 04 00 00       	and    $0x401,%eax
8010862f:	85 c0                	test   %eax,%eax
80108631:	74 42                	je     80108675 <deallocuvm+0xb2>
      pa = PTE_ADDR(*pte);
80108633:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108636:	8b 00                	mov    (%eax),%eax
80108638:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010863d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108640:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108644:	75 0d                	jne    80108653 <deallocuvm+0x90>
        panic("kfree");
80108646:	83 ec 0c             	sub    $0xc,%esp
80108649:	68 25 9a 10 80       	push   $0x80109a25
8010864e:	e8 b5 7f ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
80108653:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108656:	05 00 00 00 80       	add    $0x80000000,%eax
8010865b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010865e:	83 ec 0c             	sub    $0xc,%esp
80108661:	ff 75 e8             	pushl  -0x18(%ebp)
80108664:	e8 42 a7 ff ff       	call   80102dab <kfree>
80108669:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010866c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010866f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108675:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010867c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108682:	0f 82 6a ff ff ff    	jb     801085f2 <deallocuvm+0x2f>
    }
  }
  return newsz;
80108688:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010868b:	c9                   	leave  
8010868c:	c3                   	ret    

8010868d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010868d:	f3 0f 1e fb          	endbr32 
80108691:	55                   	push   %ebp
80108692:	89 e5                	mov    %esp,%ebp
80108694:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108697:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010869b:	75 0d                	jne    801086aa <freevm+0x1d>
    panic("freevm: no pgdir");
8010869d:	83 ec 0c             	sub    $0xc,%esp
801086a0:	68 2b 9a 10 80       	push   $0x80109a2b
801086a5:	e8 5e 7f ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801086aa:	83 ec 04             	sub    $0x4,%esp
801086ad:	6a 00                	push   $0x0
801086af:	68 00 00 00 80       	push   $0x80000000
801086b4:	ff 75 08             	pushl  0x8(%ebp)
801086b7:	e8 07 ff ff ff       	call   801085c3 <deallocuvm>
801086bc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801086bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086c6:	eb 4a                	jmp    80108712 <freevm+0x85>
    if(pgdir[i] & (PTE_P | PTE_E)){
801086c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086d2:	8b 45 08             	mov    0x8(%ebp),%eax
801086d5:	01 d0                	add    %edx,%eax
801086d7:	8b 00                	mov    (%eax),%eax
801086d9:	25 01 04 00 00       	and    $0x401,%eax
801086de:	85 c0                	test   %eax,%eax
801086e0:	74 2c                	je     8010870e <freevm+0x81>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801086e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086ec:	8b 45 08             	mov    0x8(%ebp),%eax
801086ef:	01 d0                	add    %edx,%eax
801086f1:	8b 00                	mov    (%eax),%eax
801086f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086f8:	05 00 00 00 80       	add    $0x80000000,%eax
801086fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108700:	83 ec 0c             	sub    $0xc,%esp
80108703:	ff 75 f0             	pushl  -0x10(%ebp)
80108706:	e8 a0 a6 ff ff       	call   80102dab <kfree>
8010870b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010870e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108712:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108719:	76 ad                	jbe    801086c8 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
8010871b:	83 ec 0c             	sub    $0xc,%esp
8010871e:	ff 75 08             	pushl  0x8(%ebp)
80108721:	e8 85 a6 ff ff       	call   80102dab <kfree>
80108726:	83 c4 10             	add    $0x10,%esp
}
80108729:	90                   	nop
8010872a:	c9                   	leave  
8010872b:	c3                   	ret    

8010872c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010872c:	f3 0f 1e fb          	endbr32 
80108730:	55                   	push   %ebp
80108731:	89 e5                	mov    %esp,%ebp
80108733:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108736:	83 ec 04             	sub    $0x4,%esp
80108739:	6a 00                	push   $0x0
8010873b:	ff 75 0c             	pushl  0xc(%ebp)
8010873e:	ff 75 08             	pushl  0x8(%ebp)
80108741:	e8 65 f8 ff ff       	call   80107fab <walkpgdir>
80108746:	83 c4 10             	add    $0x10,%esp
80108749:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010874c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108750:	75 0d                	jne    8010875f <clearpteu+0x33>
    panic("clearpteu");
80108752:	83 ec 0c             	sub    $0xc,%esp
80108755:	68 3c 9a 10 80       	push   $0x80109a3c
8010875a:	e8 a9 7e ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
8010875f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108762:	8b 00                	mov    (%eax),%eax
80108764:	83 e0 fb             	and    $0xfffffffb,%eax
80108767:	89 c2                	mov    %eax,%edx
80108769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876c:	89 10                	mov    %edx,(%eax)
}
8010876e:	90                   	nop
8010876f:	c9                   	leave  
80108770:	c3                   	ret    

80108771 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108771:	f3 0f 1e fb          	endbr32 
80108775:	55                   	push   %ebp
80108776:	89 e5                	mov    %esp,%ebp
80108778:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010877b:	e8 7c f9 ff ff       	call   801080fc <setupkvm>
80108780:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108783:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108787:	75 0a                	jne    80108793 <copyuvm+0x22>
    return 0;
80108789:	b8 00 00 00 00       	mov    $0x0,%eax
8010878e:	e9 fa 00 00 00       	jmp    8010888d <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108793:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010879a:	e9 c9 00 00 00       	jmp    80108868 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010879f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a2:	83 ec 04             	sub    $0x4,%esp
801087a5:	6a 00                	push   $0x0
801087a7:	50                   	push   %eax
801087a8:	ff 75 08             	pushl  0x8(%ebp)
801087ab:	e8 fb f7 ff ff       	call   80107fab <walkpgdir>
801087b0:	83 c4 10             	add    $0x10,%esp
801087b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801087b6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087ba:	75 0d                	jne    801087c9 <copyuvm+0x58>
      panic("p4Debug: inside copyuvm, pte should exist");
801087bc:	83 ec 0c             	sub    $0xc,%esp
801087bf:	68 48 9a 10 80       	push   $0x80109a48
801087c4:	e8 3f 7e ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
801087c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087cc:	8b 00                	mov    (%eax),%eax
801087ce:	25 01 04 00 00       	and    $0x401,%eax
801087d3:	85 c0                	test   %eax,%eax
801087d5:	75 0d                	jne    801087e4 <copyuvm+0x73>
      panic("p4Debug: inside copyuvm, page not present");
801087d7:	83 ec 0c             	sub    $0xc,%esp
801087da:	68 74 9a 10 80       	push   $0x80109a74
801087df:	e8 24 7e ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801087e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087e7:	8b 00                	mov    (%eax),%eax
801087e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801087f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087f4:	8b 00                	mov    (%eax),%eax
801087f6:	25 ff 0f 00 00       	and    $0xfff,%eax
801087fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801087fe:	e8 46 a6 ff ff       	call   80102e49 <kalloc>
80108803:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108806:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010880a:	74 6d                	je     80108879 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010880c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010880f:	05 00 00 00 80       	add    $0x80000000,%eax
80108814:	83 ec 04             	sub    $0x4,%esp
80108817:	68 00 10 00 00       	push   $0x1000
8010881c:	50                   	push   %eax
8010881d:	ff 75 e0             	pushl  -0x20(%ebp)
80108820:	e8 58 ce ff ff       	call   8010567d <memmove>
80108825:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80108828:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010882b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010882e:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108837:	83 ec 0c             	sub    $0xc,%esp
8010883a:	52                   	push   %edx
8010883b:	51                   	push   %ecx
8010883c:	68 00 10 00 00       	push   $0x1000
80108841:	50                   	push   %eax
80108842:	ff 75 f0             	pushl  -0x10(%ebp)
80108845:	e8 fb f7 ff ff       	call   80108045 <mappages>
8010884a:	83 c4 20             	add    $0x20,%esp
8010884d:	85 c0                	test   %eax,%eax
8010884f:	79 10                	jns    80108861 <copyuvm+0xf0>
      kfree(mem);
80108851:	83 ec 0c             	sub    $0xc,%esp
80108854:	ff 75 e0             	pushl  -0x20(%ebp)
80108857:	e8 4f a5 ff ff       	call   80102dab <kfree>
8010885c:	83 c4 10             	add    $0x10,%esp
      goto bad;
8010885f:	eb 19                	jmp    8010887a <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108861:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010886e:	0f 82 2b ff ff ff    	jb     8010879f <copyuvm+0x2e>
    }
  }
  return d;
80108874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108877:	eb 14                	jmp    8010888d <copyuvm+0x11c>
      goto bad;
80108879:	90                   	nop

bad:
  freevm(d);
8010887a:	83 ec 0c             	sub    $0xc,%esp
8010887d:	ff 75 f0             	pushl  -0x10(%ebp)
80108880:	e8 08 fe ff ff       	call   8010868d <freevm>
80108885:	83 c4 10             	add    $0x10,%esp
  return 0;
80108888:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010888d:	c9                   	leave  
8010888e:	c3                   	ret    

8010888f <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010888f:	f3 0f 1e fb          	endbr32 
80108893:	55                   	push   %ebp
80108894:	89 e5                	mov    %esp,%ebp
80108896:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108899:	83 ec 04             	sub    $0x4,%esp
8010889c:	6a 00                	push   $0x0
8010889e:	ff 75 0c             	pushl  0xc(%ebp)
801088a1:	ff 75 08             	pushl  0x8(%ebp)
801088a4:	e8 02 f7 ff ff       	call   80107fab <walkpgdir>
801088a9:	83 c4 10             	add    $0x10,%esp
801088ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // p4Debug: Check for page's present and encrypted flags.
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
801088af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b2:	8b 00                	mov    (%eax),%eax
801088b4:	25 01 04 00 00       	and    $0x401,%eax
801088b9:	85 c0                	test   %eax,%eax
801088bb:	75 07                	jne    801088c4 <uva2ka+0x35>
    return 0;
801088bd:	b8 00 00 00 00       	mov    $0x0,%eax
801088c2:	eb 22                	jmp    801088e6 <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
801088c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c7:	8b 00                	mov    (%eax),%eax
801088c9:	83 e0 04             	and    $0x4,%eax
801088cc:	85 c0                	test   %eax,%eax
801088ce:	75 07                	jne    801088d7 <uva2ka+0x48>
    return 0;
801088d0:	b8 00 00 00 00       	mov    $0x0,%eax
801088d5:	eb 0f                	jmp    801088e6 <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
801088d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088da:	8b 00                	mov    (%eax),%eax
801088dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088e1:	05 00 00 00 80       	add    $0x80000000,%eax
}
801088e6:	c9                   	leave  
801088e7:	c3                   	ret    

801088e8 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801088e8:	f3 0f 1e fb          	endbr32 
801088ec:	55                   	push   %ebp
801088ed:	89 e5                	mov    %esp,%ebp
801088ef:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801088f2:	8b 45 10             	mov    0x10(%ebp),%eax
801088f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801088f8:	eb 7f                	jmp    80108979 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
801088fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801088fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108902:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108905:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108908:	83 ec 08             	sub    $0x8,%esp
8010890b:	50                   	push   %eax
8010890c:	ff 75 08             	pushl  0x8(%ebp)
8010890f:	e8 7b ff ff ff       	call   8010888f <uva2ka>
80108914:	83 c4 10             	add    $0x10,%esp
80108917:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010891a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010891e:	75 07                	jne    80108927 <copyout+0x3f>
    {
      //p4Debug : Cannot find page in kernel space.
      return -1;
80108920:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108925:	eb 61                	jmp    80108988 <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
80108927:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010892a:	2b 45 0c             	sub    0xc(%ebp),%eax
8010892d:	05 00 10 00 00       	add    $0x1000,%eax
80108932:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108938:	3b 45 14             	cmp    0x14(%ebp),%eax
8010893b:	76 06                	jbe    80108943 <copyout+0x5b>
      n = len;
8010893d:	8b 45 14             	mov    0x14(%ebp),%eax
80108940:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108943:	8b 45 0c             	mov    0xc(%ebp),%eax
80108946:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108949:	89 c2                	mov    %eax,%edx
8010894b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010894e:	01 d0                	add    %edx,%eax
80108950:	83 ec 04             	sub    $0x4,%esp
80108953:	ff 75 f0             	pushl  -0x10(%ebp)
80108956:	ff 75 f4             	pushl  -0xc(%ebp)
80108959:	50                   	push   %eax
8010895a:	e8 1e cd ff ff       	call   8010567d <memmove>
8010895f:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108962:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108965:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108968:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010896b:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010896e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108971:	05 00 10 00 00       	add    $0x1000,%eax
80108976:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108979:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010897d:	0f 85 77 ff ff ff    	jne    801088fa <copyout+0x12>
  }
  return 0;
80108983:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108988:	c9                   	leave  
80108989:	c3                   	ret    

8010898a <translate_and_set>:

//This function is just like uva2ka but sets the PTE_E bit and clears PTE_P
char* translate_and_set(pde_t *pgdir, char *uva) {
8010898a:	f3 0f 1e fb          	endbr32 
8010898e:	55                   	push   %ebp
8010898f:	89 e5                	mov    %esp,%ebp
80108991:	83 ec 18             	sub    $0x18,%esp
  cprintf("p4Debug: setting PTE_E for %p, VPN %d\n", uva, PPN(uva));
80108994:	8b 45 0c             	mov    0xc(%ebp),%eax
80108997:	c1 e8 0c             	shr    $0xc,%eax
8010899a:	83 ec 04             	sub    $0x4,%esp
8010899d:	50                   	push   %eax
8010899e:	ff 75 0c             	pushl  0xc(%ebp)
801089a1:	68 a0 9a 10 80       	push   $0x80109aa0
801089a6:	e8 6d 7a ff ff       	call   80100418 <cprintf>
801089ab:	83 c4 10             	add    $0x10,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, uva, 0);
801089ae:	83 ec 04             	sub    $0x4,%esp
801089b1:	6a 00                	push   $0x0
801089b3:	ff 75 0c             	pushl  0xc(%ebp)
801089b6:	ff 75 08             	pushl  0x8(%ebp)
801089b9:	e8 ed f5 ff ff       	call   80107fab <walkpgdir>
801089be:	83 c4 10             	add    $0x10,%esp
801089c1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //p4Debug: If page is not present AND it is not encrypted.
  if((*pte & PTE_P) == 0 && (*pte & PTE_E) == 0)
801089c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c7:	8b 00                	mov    (%eax),%eax
801089c9:	83 e0 01             	and    $0x1,%eax
801089cc:	85 c0                	test   %eax,%eax
801089ce:	75 18                	jne    801089e8 <translate_and_set+0x5e>
801089d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d3:	8b 00                	mov    (%eax),%eax
801089d5:	25 00 04 00 00       	and    $0x400,%eax
801089da:	85 c0                	test   %eax,%eax
801089dc:	75 0a                	jne    801089e8 <translate_and_set+0x5e>
    return 0;
801089de:	b8 00 00 00 00       	mov    $0x0,%eax
801089e3:	e9 93 00 00 00       	jmp    80108a7b <translate_and_set+0xf1>
  //p4Debug: If page is already encrypted, i.e. PTE_E is set, return NULL as error;
  if((*pte & PTE_E)) {
801089e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089eb:	8b 00                	mov    (%eax),%eax
801089ed:	25 00 04 00 00       	and    $0x400,%eax
801089f2:	85 c0                	test   %eax,%eax
801089f4:	74 07                	je     801089fd <translate_and_set+0x73>
    return 0;
801089f6:	b8 00 00 00 00       	mov    $0x0,%eax
801089fb:	eb 7e                	jmp    80108a7b <translate_and_set+0xf1>
  }
  // p4Debug: Check if users are allowed to use this page
  if((*pte & PTE_U) == 0)
801089fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a00:	8b 00                	mov    (%eax),%eax
80108a02:	83 e0 04             	and    $0x4,%eax
80108a05:	85 c0                	test   %eax,%eax
80108a07:	75 07                	jne    80108a10 <translate_and_set+0x86>
    return 0;
80108a09:	b8 00 00 00 00       	mov    $0x0,%eax
80108a0e:	eb 6b                	jmp    80108a7b <translate_and_set+0xf1>
  //p4Debug: Set Page as encrypted and not present so that we can trap(see trap.c) to decrypt page
  cprintf("p4Debug: PTE was %x and its pointer %p\n", *pte, pte);
80108a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a13:	8b 00                	mov    (%eax),%eax
80108a15:	83 ec 04             	sub    $0x4,%esp
80108a18:	ff 75 f4             	pushl  -0xc(%ebp)
80108a1b:	50                   	push   %eax
80108a1c:	68 c8 9a 10 80       	push   $0x80109ac8
80108a21:	e8 f2 79 ff ff       	call   80100418 <cprintf>
80108a26:	83 c4 10             	add    $0x10,%esp
  *pte = *pte | PTE_E;
80108a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2c:	8b 00                	mov    (%eax),%eax
80108a2e:	80 cc 04             	or     $0x4,%ah
80108a31:	89 c2                	mov    %eax,%edx
80108a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a36:	89 10                	mov    %edx,(%eax)
  *pte = *pte & ~PTE_P;
80108a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a3b:	8b 00                	mov    (%eax),%eax
80108a3d:	83 e0 fe             	and    $0xfffffffe,%eax
80108a40:	89 c2                	mov    %eax,%edx
80108a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a45:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: PTE is now %x\n", *pte);
80108a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4a:	8b 00                	mov    (%eax),%eax
80108a4c:	83 ec 08             	sub    $0x8,%esp
80108a4f:	50                   	push   %eax
80108a50:	68 f0 9a 10 80       	push   $0x80109af0
80108a55:	e8 be 79 ff ff       	call   80100418 <cprintf>
80108a5a:	83 c4 10             	add    $0x10,%esp
  *pte = *pte & ~PTE_A;
80108a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a60:	8b 00                	mov    (%eax),%eax
80108a62:	83 e0 df             	and    $0xffffffdf,%eax
80108a65:	89 c2                	mov    %eax,%edx
80108a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6a:	89 10                	mov    %edx,(%eax)
  return (char*)P2V(PTE_ADDR(*pte));
80108a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6f:	8b 00                	mov    (%eax),%eax
80108a71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a76:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108a7b:	c9                   	leave  
80108a7c:	c3                   	ret    

80108a7d <mdecrypt>:


int mdecrypt(char *virtual_addr) {
80108a7d:	f3 0f 1e fb          	endbr32 
80108a81:	55                   	push   %ebp
80108a82:	89 e5                	mov    %esp,%ebp
80108a84:	83 ec 38             	sub    $0x38,%esp
  cprintf("p4Debug:  mdecrypt VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
80108a87:	e8 81 ba ff ff       	call   8010450d <myproc>
80108a8c:	8b 40 10             	mov    0x10(%eax),%eax
80108a8f:	8b 55 08             	mov    0x8(%ebp),%edx
80108a92:	c1 ea 0c             	shr    $0xc,%edx
80108a95:	50                   	push   %eax
80108a96:	ff 75 08             	pushl  0x8(%ebp)
80108a99:	52                   	push   %edx
80108a9a:	68 08 9b 10 80       	push   $0x80109b08
80108a9f:	e8 74 79 ff ff       	call   80100418 <cprintf>
80108aa4:	83 c4 10             	add    $0x10,%esp
  //p4Debug: virtual_addr is a virtual address in this PID's userspace.
  struct proc * p = myproc();
80108aa7:	e8 61 ba ff ff       	call   8010450d <myproc>
80108aac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  pde_t* mypd = p->pgdir;
80108aaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ab2:	8b 40 04             	mov    0x4(%eax),%eax
80108ab5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0); //create required page table pages for mypd and return pte for virtual_address
80108ab8:	83 ec 04             	sub    $0x4,%esp
80108abb:	6a 00                	push   $0x0
80108abd:	ff 75 08             	pushl  0x8(%ebp)
80108ac0:	ff 75 e4             	pushl  -0x1c(%ebp)
80108ac3:	e8 e3 f4 ff ff       	call   80107fab <walkpgdir>
80108ac8:	83 c4 10             	add    $0x10,%esp
80108acb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!pte || *pte == 0) {
80108ace:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108ad2:	74 09                	je     80108add <mdecrypt+0x60>
80108ad4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ad7:	8b 00                	mov    (%eax),%eax
80108ad9:	85 c0                	test   %eax,%eax
80108adb:	75 1a                	jne    80108af7 <mdecrypt+0x7a>
    cprintf("p4Debug: walkpgdir failed\n");
80108add:	83 ec 0c             	sub    $0xc,%esp
80108ae0:	68 2f 9b 10 80       	push   $0x80109b2f
80108ae5:	e8 2e 79 ff ff       	call   80100418 <cprintf>
80108aea:	83 c4 10             	add    $0x10,%esp
    return -1;
80108aed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108af2:	e9 98 02 00 00       	jmp    80108d8f <mdecrypt+0x312>
  }
  cprintf("p4Debug: pte was %x\n", *pte);
80108af7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108afa:	8b 00                	mov    (%eax),%eax
80108afc:	83 ec 08             	sub    $0x8,%esp
80108aff:	50                   	push   %eax
80108b00:	68 4a 9b 10 80       	push   $0x80109b4a
80108b05:	e8 0e 79 ff ff       	call   80100418 <cprintf>
80108b0a:	83 c4 10             	add    $0x10,%esp
  *pte = *pte & ~PTE_E; //clear
80108b0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b10:	8b 00                	mov    (%eax),%eax
80108b12:	80 e4 fb             	and    $0xfb,%ah
80108b15:	89 c2                	mov    %eax,%edx
80108b17:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b1a:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P; //set
80108b1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b1f:	8b 00                	mov    (%eax),%eax
80108b21:	83 c8 01             	or     $0x1,%eax
80108b24:	89 c2                	mov    %eax,%edx
80108b26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b29:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: pte is %x\n", *pte);
80108b2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b2e:	8b 00                	mov    (%eax),%eax
80108b30:	83 ec 08             	sub    $0x8,%esp
80108b33:	50                   	push   %eax
80108b34:	68 5f 9b 10 80       	push   $0x80109b5f
80108b39:	e8 da 78 ff ff       	call   80100418 <cprintf>
80108b3e:	83 c4 10             	add    $0x10,%esp
  char * original = uva2ka(mypd, virtual_addr) + OFFSET(virtual_addr); //maps user virtual address to kernel virtual address; Original has offset added on to
80108b41:	83 ec 08             	sub    $0x8,%esp
80108b44:	ff 75 08             	pushl  0x8(%ebp)
80108b47:	ff 75 e4             	pushl  -0x1c(%ebp)
80108b4a:	e8 40 fd ff ff       	call   8010888f <uva2ka>
80108b4f:	83 c4 10             	add    $0x10,%esp
80108b52:	8b 55 08             	mov    0x8(%ebp),%edx
80108b55:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
80108b5b:	01 d0                	add    %edx,%eax
80108b5d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  cprintf("p4Debug: Original in decrypt was %p\n", original);
80108b60:	83 ec 08             	sub    $0x8,%esp
80108b63:	ff 75 dc             	pushl  -0x24(%ebp)
80108b66:	68 74 9b 10 80       	push   $0x80109b74
80108b6b:	e8 a8 78 ff ff       	call   80100418 <cprintf>
80108b70:	83 c4 10             	add    $0x10,%esp
  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr); //page alignment 
80108b73:	8b 45 08             	mov    0x8(%ebp),%eax
80108b76:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b7b:	89 45 08             	mov    %eax,0x8(%ebp)
  cprintf("p4Debug: mdecrypt: rounded down va is %p\n", virtual_addr);
80108b7e:	83 ec 08             	sub    $0x8,%esp
80108b81:	ff 75 08             	pushl  0x8(%ebp)
80108b84:	68 9c 9b 10 80       	push   $0x80109b9c
80108b89:	e8 8a 78 ff ff       	call   80100418 <cprintf>
80108b8e:	83 c4 10             	add    $0x10,%esp

  char * kvp = uva2ka(mypd, virtual_addr); //key value pair? same as original but not offset 
80108b91:	83 ec 08             	sub    $0x8,%esp
80108b94:	ff 75 08             	pushl  0x8(%ebp)
80108b97:	ff 75 e4             	pushl  -0x1c(%ebp)
80108b9a:	e8 f0 fc ff ff       	call   8010888f <uva2ka>
80108b9f:	83 c4 10             	add    $0x10,%esp
80108ba2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (!kvp || *kvp == 0) {
80108ba5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80108ba9:	74 0a                	je     80108bb5 <mdecrypt+0x138>
80108bab:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108bae:	0f b6 00             	movzbl (%eax),%eax
80108bb1:	84 c0                	test   %al,%al
80108bb3:	75 0a                	jne    80108bbf <mdecrypt+0x142>
    return -1;
80108bb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bba:	e9 d0 01 00 00       	jmp    80108d8f <mdecrypt+0x312>
  }
  char * slider = virtual_addr;
80108bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80108bc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  for (int offset = 0; offset < PGSIZE; offset++) {
80108bc5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108bcc:	eb 17                	jmp    80108be5 <mdecrypt+0x168>
    *slider = *slider ^ 0xFF;
80108bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd1:	0f b6 00             	movzbl (%eax),%eax
80108bd4:	f7 d0                	not    %eax
80108bd6:	89 c2                	mov    %eax,%edx
80108bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bdb:	88 10                	mov    %dl,(%eax)
    slider++;
80108bdd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108be1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108be5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80108bec:	7e e0                	jle    80108bce <mdecrypt+0x151>
  }
  p->current_searches=0;
80108bee:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bf1:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
80108bf8:	00 00 00 
  for(int i = p->clock_hand;i<CLOCKSIZE;i++){
80108bfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bfe:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108c04:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108c07:	e9 44 01 00 00       	jmp    80108d50 <mdecrypt+0x2d3>
    p->current_searches++;
80108c0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c0f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80108c15:	8d 50 01             	lea    0x1(%eax),%edx
80108c18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c1b:	89 90 a0 00 00 00    	mov    %edx,0xa0(%eax)
    if(p->clock[i]==-1){//empty clock queue add
80108c21:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c24:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108c27:	83 c2 1c             	add    $0x1c,%edx
80108c2a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108c2e:	83 f8 ff             	cmp    $0xffffffff,%eax
80108c31:	75 15                	jne    80108c48 <mdecrypt+0x1cb>
      p->clock[i]=(uint) virtual_addr;
80108c33:	8b 55 08             	mov    0x8(%ebp),%edx
80108c36:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c39:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108c3c:	83 c1 1c             	add    $0x1c,%ecx
80108c3f:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      break;
80108c43:	e9 12 01 00 00       	jmp    80108d5a <mdecrypt+0x2dd>
    }
    pte_t * pte_clock = walkpgdir(mypd, (void *)p->clock[i], 0); 
80108c48:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c4b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108c4e:	83 c2 1c             	add    $0x1c,%edx
80108c51:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108c55:	83 ec 04             	sub    $0x4,%esp
80108c58:	6a 00                	push   $0x0
80108c5a:	50                   	push   %eax
80108c5b:	ff 75 e4             	pushl  -0x1c(%ebp)
80108c5e:	e8 48 f3 ff ff       	call   80107fab <walkpgdir>
80108c63:	83 c4 10             	add    $0x10,%esp
80108c66:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    //p->current_searches++;
    
    //TODO need to check case where virtual address already in queue and then need to set refernce bit
    if(i==CLOCKSIZE-1){
80108c69:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108c6d:	75 50                	jne    80108cbf <mdecrypt+0x242>
      if(((int)pte_clock & PTE_A)==0){ //found unreferneced entry
80108c6f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c72:	83 e0 20             	and    $0x20,%eax
80108c75:	85 c0                	test   %eax,%eax
80108c77:	75 30                	jne    80108ca9 <mdecrypt+0x22c>
        ////*pte_clock = *pte_clock | PTE_A; //set referened to 1
        mencrypt((char *)p->clock[i],1);
80108c79:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c7c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108c7f:	83 c2 1c             	add    $0x1c,%edx
80108c82:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108c86:	83 ec 08             	sub    $0x8,%esp
80108c89:	6a 01                	push   $0x1
80108c8b:	50                   	push   %eax
80108c8c:	e8 00 01 00 00       	call   80108d91 <mencrypt>
80108c91:	83 c4 10             	add    $0x10,%esp
        //*pte_clock = *pte_clock & ~PTE_A;
        p->clock[i] = (uint)virtual_addr; //set data to new page TODO
80108c94:	8b 55 08             	mov    0x8(%ebp),%edx
80108c97:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c9a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108c9d:	83 c1 1c             	add    $0x1c,%ecx
80108ca0:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
        break; //break out
80108ca4:	e9 b1 00 00 00       	jmp    80108d5a <mdecrypt+0x2dd>
      }else{
        *pte_clock = *pte_clock & ~PTE_A;//array[i].accessed=false; //unset reference bit of last clock slot 
80108ca9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108cac:	8b 00                	mov    (%eax),%eax
80108cae:	83 e0 df             	and    $0xffffffdf,%eax
80108cb1:	89 c2                	mov    %eax,%edx
80108cb3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108cb6:	89 10                	mov    %edx,(%eax)
        i=0; //set pointer to beginning to loop around
80108cb8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
        
      }
    }
    if(((int)pte_clock & PTE_A)==0){ //array[i].accessed==false
80108cbf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108cc2:	83 e0 20             	and    $0x20,%eax
80108cc5:	85 c0                	test   %eax,%eax
80108cc7:	75 2d                	jne    80108cf6 <mdecrypt+0x279>
      mencrypt((char *)p->clock[i],1);
80108cc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ccc:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108ccf:	83 c2 1c             	add    $0x1c,%edx
80108cd2:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108cd6:	83 ec 08             	sub    $0x8,%esp
80108cd9:	6a 01                	push   $0x1
80108cdb:	50                   	push   %eax
80108cdc:	e8 b0 00 00 00       	call   80108d91 <mencrypt>
80108ce1:	83 c4 10             	add    $0x10,%esp
      //*pte_clock = *pte_clock & ~PTE_A;
        p->clock[i] = (int)virtual_addr;//array[i].data=new_int; TODO //set data of slot to new
80108ce4:	8b 55 08             	mov    0x8(%ebp),%edx
80108ce7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cea:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108ced:	83 c1 1c             	add    $0x1c,%ecx
80108cf0:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
        ////*pte_clock = *pte_clock | PTE_A;//s array[i].accessed=true; //set ref of newly added to true
        break;
80108cf4:	eb 64                	jmp    80108d5a <mdecrypt+0x2dd>
    }else{
      *pte_clock = *pte_clock & ~PTE_A;//array[i].accessed=false;
80108cf6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108cf9:	8b 00                	mov    (%eax),%eax
80108cfb:	83 e0 df             	and    $0xffffffdf,%eax
80108cfe:	89 c2                	mov    %eax,%edx
80108d00:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d03:	89 10                	mov    %edx,(%eax)
      //continue;
    }
    if(p->current_searches>=CLOCKSIZE){ //search through all ClOCK (full)
80108d05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d08:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80108d0e:	83 f8 07             	cmp    $0x7,%eax
80108d11:	7e 39                	jle    80108d4c <mdecrypt+0x2cf>
      ////*pte_clock = *pte_clock | PTE_A; //set referened to 1
      mencrypt((char *)p->clock[p->clock_hand],1);
80108d13:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d16:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
80108d1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d1f:	83 c2 1c             	add    $0x1c,%edx
80108d22:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108d26:	83 ec 08             	sub    $0x8,%esp
80108d29:	6a 01                	push   $0x1
80108d2b:	50                   	push   %eax
80108d2c:	e8 60 00 00 00       	call   80108d91 <mencrypt>
80108d31:	83 c4 10             	add    $0x10,%esp
      p->clock[p->clock_hand] = (int)virtual_addr;//array[i].data=new_int;
80108d34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d37:	8b 88 9c 00 00 00    	mov    0x9c(%eax),%ecx
80108d3d:	8b 55 08             	mov    0x8(%ebp),%edx
80108d40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d43:	83 c1 1c             	add    $0x1c,%ecx
80108d46:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      break;
80108d4a:	eb 0e                	jmp    80108d5a <mdecrypt+0x2dd>
  for(int i = p->clock_hand;i<CLOCKSIZE;i++){
80108d4c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108d50:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108d54:	0f 8e b2 fe ff ff    	jle    80108c0c <mdecrypt+0x18f>
    }
  
  }
  p->clock_hand++;
80108d5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d5d:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108d63:	8d 50 01             	lea    0x1(%eax),%edx
80108d66:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d69:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
if(p->clock_hand>=CLOCKSIZE){
80108d6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d72:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108d78:	83 f8 07             	cmp    $0x7,%eax
80108d7b:	7e 0d                	jle    80108d8a <mdecrypt+0x30d>
  p->clock_hand=0;
80108d7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d80:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
80108d87:	00 00 00 
}
  return 0;
80108d8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d8f:	c9                   	leave  
80108d90:	c3                   	ret    

80108d91 <mencrypt>:
int mencrypt(char *virtual_addr, int len) {
80108d91:	f3 0f 1e fb          	endbr32 
80108d95:	55                   	push   %ebp
80108d96:	89 e5                	mov    %esp,%ebp
80108d98:	83 ec 38             	sub    $0x38,%esp

  cprintf("p4Debug: mencrypt: %p %d\n", virtual_addr, len);
80108d9b:	83 ec 04             	sub    $0x4,%esp
80108d9e:	ff 75 0c             	pushl  0xc(%ebp)
80108da1:	ff 75 08             	pushl  0x8(%ebp)
80108da4:	68 c6 9b 10 80       	push   $0x80109bc6
80108da9:	e8 6a 76 ff ff       	call   80100418 <cprintf>
80108dae:	83 c4 10             	add    $0x10,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80108db1:	e8 57 b7 ff ff       	call   8010450d <myproc>
80108db6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80108db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108dbc:	8b 40 04             	mov    0x4(%eax),%eax
80108dbf:	89 45 e0             	mov    %eax,-0x20(%ebp)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80108dc5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dca:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
80108dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80108dd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108dd3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108dda:	eb 55                	jmp    80108e31 <mencrypt+0xa0>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80108ddc:	83 ec 08             	sub    $0x8,%esp
80108ddf:	ff 75 f4             	pushl  -0xc(%ebp)
80108de2:	ff 75 e0             	pushl  -0x20(%ebp)
80108de5:	e8 a5 fa ff ff       	call   8010888f <uva2ka>
80108dea:	83 c4 10             	add    $0x10,%esp
80108ded:	89 45 d0             	mov    %eax,-0x30(%ebp)
    cprintf("p4Debug: slider %p, kvp for err check is %p\n",slider, kvp);
80108df0:	83 ec 04             	sub    $0x4,%esp
80108df3:	ff 75 d0             	pushl  -0x30(%ebp)
80108df6:	ff 75 f4             	pushl  -0xc(%ebp)
80108df9:	68 e0 9b 10 80       	push   $0x80109be0
80108dfe:	e8 15 76 ff ff       	call   80100418 <cprintf>
80108e03:	83 c4 10             	add    $0x10,%esp
    if (!kvp) {
80108e06:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80108e0a:	75 1a                	jne    80108e26 <mencrypt+0x95>
      cprintf("p4Debug: mencrypt: kvp = NULL\n");
80108e0c:	83 ec 0c             	sub    $0xc,%esp
80108e0f:	68 10 9c 10 80       	push   $0x80109c10
80108e14:	e8 ff 75 ff ff       	call   80100418 <cprintf>
80108e19:	83 c4 10             	add    $0x10,%esp
      return -1;
80108e1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e21:	e9 4e 01 00 00       	jmp    80108f74 <mencrypt+0x1e3>
    }
    slider = slider + PGSIZE;
80108e26:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108e2d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e34:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e37:	7c a3                	jl     80108ddc <mencrypt+0x4b>
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
80108e39:	8b 45 08             	mov    0x8(%ebp),%eax
80108e3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  for (int i = 0; i < len; i++) {
80108e3f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108e46:	e9 07 01 00 00       	jmp    80108f52 <mencrypt+0x1c1>
    cprintf("p4Debug: mencryptr: VPN %d, %p\n", PPN(slider), slider);
80108e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e4e:	c1 e8 0c             	shr    $0xc,%eax
80108e51:	83 ec 04             	sub    $0x4,%esp
80108e54:	ff 75 f4             	pushl  -0xc(%ebp)
80108e57:	50                   	push   %eax
80108e58:	68 30 9c 10 80       	push   $0x80109c30
80108e5d:	e8 b6 75 ff ff       	call   80100418 <cprintf>
80108e62:	83 c4 10             	add    $0x10,%esp
    //kvp = kernel virtual pointer
    //virtual address in kernel space that maps to the given pointer
    char * kvp = uva2ka(mypd, slider);
80108e65:	83 ec 08             	sub    $0x8,%esp
80108e68:	ff 75 f4             	pushl  -0xc(%ebp)
80108e6b:	ff 75 e0             	pushl  -0x20(%ebp)
80108e6e:	e8 1c fa ff ff       	call   8010888f <uva2ka>
80108e73:	83 c4 10             	add    $0x10,%esp
80108e76:	89 45 dc             	mov    %eax,-0x24(%ebp)
    cprintf("p4Debug: kvp for encrypt stage is %p\n", kvp);
80108e79:	83 ec 08             	sub    $0x8,%esp
80108e7c:	ff 75 dc             	pushl  -0x24(%ebp)
80108e7f:	68 50 9c 10 80       	push   $0x80109c50
80108e84:	e8 8f 75 ff ff       	call   80100418 <cprintf>
80108e89:	83 c4 10             	add    $0x10,%esp
    pte_t * mypte = walkpgdir(mypd, slider, 0);
80108e8c:	83 ec 04             	sub    $0x4,%esp
80108e8f:	6a 00                	push   $0x0
80108e91:	ff 75 f4             	pushl  -0xc(%ebp)
80108e94:	ff 75 e0             	pushl  -0x20(%ebp)
80108e97:	e8 0f f1 ff ff       	call   80107fab <walkpgdir>
80108e9c:	83 c4 10             	add    $0x10,%esp
80108e9f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    *mypte &= (~PTE_A);
80108ea2:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108ea5:	8b 00                	mov    (%eax),%eax
80108ea7:	83 e0 df             	and    $0xffffffdf,%eax
80108eaa:	89 c2                	mov    %eax,%edx
80108eac:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108eaf:	89 10                	mov    %edx,(%eax)
    cprintf("p4Debug: pte is %x\n", *mypte);
80108eb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108eb4:	8b 00                	mov    (%eax),%eax
80108eb6:	83 ec 08             	sub    $0x8,%esp
80108eb9:	50                   	push   %eax
80108eba:	68 5f 9b 10 80       	push   $0x80109b5f
80108ebf:	e8 54 75 ff ff       	call   80100418 <cprintf>
80108ec4:	83 c4 10             	add    $0x10,%esp
    if (*mypte & PTE_E) {
80108ec7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108eca:	8b 00                	mov    (%eax),%eax
80108ecc:	25 00 04 00 00       	and    $0x400,%eax
80108ed1:	85 c0                	test   %eax,%eax
80108ed3:	74 19                	je     80108eee <mencrypt+0x15d>
      cprintf("p4Debug: already encrypted\n");
80108ed5:	83 ec 0c             	sub    $0xc,%esp
80108ed8:	68 76 9c 10 80       	push   $0x80109c76
80108edd:	e8 36 75 ff ff       	call   80100418 <cprintf>
80108ee2:	83 c4 10             	add    $0x10,%esp
      slider += PGSIZE;
80108ee5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      continue;
80108eec:	eb 60                	jmp    80108f4e <mencrypt+0x1bd>
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
80108eee:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80108ef5:	eb 17                	jmp    80108f0e <mencrypt+0x17d>
      *slider = *slider ^ 0xFF;
80108ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108efa:	0f b6 00             	movzbl (%eax),%eax
80108efd:	f7 d0                	not    %eax
80108eff:	89 c2                	mov    %eax,%edx
80108f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f04:	88 10                	mov    %dl,(%eax)
      slider++;
80108f06:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
80108f0a:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80108f0e:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
80108f15:	7e e0                	jle    80108ef7 <mencrypt+0x166>
    }

    char * kvp_translated = translate_and_set(mypd, slider-PGSIZE);
80108f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1a:	2d 00 10 00 00       	sub    $0x1000,%eax
80108f1f:	83 ec 08             	sub    $0x8,%esp
80108f22:	50                   	push   %eax
80108f23:	ff 75 e0             	pushl  -0x20(%ebp)
80108f26:	e8 5f fa ff ff       	call   8010898a <translate_and_set>
80108f2b:	83 c4 10             	add    $0x10,%esp
80108f2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    if (!kvp_translated) {
80108f31:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80108f35:	75 17                	jne    80108f4e <mencrypt+0x1bd>
      cprintf("p4Debug: translate failed!");
80108f37:	83 ec 0c             	sub    $0xc,%esp
80108f3a:	68 92 9c 10 80       	push   $0x80109c92
80108f3f:	e8 d4 74 ff ff       	call   80100418 <cprintf>
80108f44:	83 c4 10             	add    $0x10,%esp
      return -1;
80108f47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f4c:	eb 26                	jmp    80108f74 <mencrypt+0x1e3>
  for (int i = 0; i < len; i++) {
80108f4e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108f52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f55:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f58:	0f 8c ed fe ff ff    	jl     80108e4b <mencrypt+0xba>
    }//*mypte &= (~PTE_A);
    //*mypte = *mypte & ~PTE_A;
  }

  switchuvm(myproc());
80108f5e:	e8 aa b5 ff ff       	call   8010450d <myproc>
80108f63:	83 ec 0c             	sub    $0xc,%esp
80108f66:	50                   	push   %eax
80108f67:	e8 66 f2 ff ff       	call   801081d2 <switchuvm>
80108f6c:	83 c4 10             	add    $0x10,%esp
  
  return 0;
80108f6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f74:	c9                   	leave  
80108f75:	c3                   	ret    

80108f76 <getpgtable>:

int getpgtable(struct pt_entry* pt_entries, int num,int wsetOnly) {
80108f76:	f3 0f 1e fb          	endbr32 
80108f7a:	55                   	push   %ebp
80108f7b:	89 e5                	mov    %esp,%ebp
80108f7d:	83 ec 28             	sub    $0x28,%esp
  cprintf("p4Debug: getpgtable: %p, %d\n", pt_entries, num);
80108f80:	83 ec 04             	sub    $0x4,%esp
80108f83:	ff 75 0c             	pushl  0xc(%ebp)
80108f86:	ff 75 08             	pushl  0x8(%ebp)
80108f89:	68 ad 9c 10 80       	push   $0x80109cad
80108f8e:	e8 85 74 ff ff       	call   80100418 <cprintf>
80108f93:	83 c4 10             	add    $0x10,%esp
  bool ItsInthere = false;
80108f96:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
  
  struct proc *curproc = myproc();
80108f9a:	e8 6e b5 ff ff       	call   8010450d <myproc>
80108f9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t *pgdir = curproc->pgdir;
80108fa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108fa5:	8b 40 04             	mov    0x4(%eax),%eax
80108fa8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint uva = 0;
80108fab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if (curproc->sz % PGSIZE == 0)
80108fb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108fb5:	8b 00                	mov    (%eax),%eax
80108fb7:	25 ff 0f 00 00       	and    $0xfff,%eax
80108fbc:	85 c0                	test   %eax,%eax
80108fbe:	75 0f                	jne    80108fcf <getpgtable+0x59>
    uva = curproc->sz - PGSIZE;
80108fc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108fc3:	8b 00                	mov    (%eax),%eax
80108fc5:	2d 00 10 00 00       	sub    $0x1000,%eax
80108fca:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108fcd:	eb 0d                	jmp    80108fdc <getpgtable+0x66>
  else 
    uva = PGROUNDDOWN(curproc->sz);
80108fcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108fd2:	8b 00                	mov    (%eax),%eax
80108fd4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fd9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  int i = 0;
80108fdc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for (;;uva -=PGSIZE)
  {
    
    pte_t *pte = walkpgdir(pgdir, (const void *)uva, 0);
80108fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe6:	83 ec 04             	sub    $0x4,%esp
80108fe9:	6a 00                	push   $0x0
80108feb:	50                   	push   %eax
80108fec:	ff 75 e0             	pushl  -0x20(%ebp)
80108fef:	e8 b7 ef ff ff       	call   80107fab <walkpgdir>
80108ff4:	83 c4 10             	add    $0x10,%esp
80108ff7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    for(int i = 0; i<CLOCKSIZE;i++){
80108ffa:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80109001:	eb 1e                	jmp    80109021 <getpgtable+0xab>
    if(curproc->clock[i]==(uint)pte){
80109003:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109006:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109009:	83 c2 1c             	add    $0x1c,%edx
8010900c:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80109010:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109013:	39 c2                	cmp    %eax,%edx
80109015:	75 06                	jne    8010901d <getpgtable+0xa7>
      ItsInthere = true;
80109017:	c6 45 f7 01          	movb   $0x1,-0x9(%ebp)
      break;
8010901b:	eb 0a                	jmp    80109027 <getpgtable+0xb1>
    for(int i = 0; i<CLOCKSIZE;i++){
8010901d:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80109021:	83 7d e8 07          	cmpl   $0x7,-0x18(%ebp)
80109025:	7e dc                	jle    80109003 <getpgtable+0x8d>
      }
  }

    if (!(*pte & PTE_U) || !(*pte & (PTE_P | PTE_E))|| (wsetOnly && !ItsInthere))
80109027:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010902a:	8b 00                	mov    (%eax),%eax
8010902c:	83 e0 04             	and    $0x4,%eax
8010902f:	85 c0                	test   %eax,%eax
80109031:	0f 84 93 01 00 00    	je     801091ca <getpgtable+0x254>
80109037:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010903a:	8b 00                	mov    (%eax),%eax
8010903c:	25 01 04 00 00       	and    $0x401,%eax
80109041:	85 c0                	test   %eax,%eax
80109043:	0f 84 81 01 00 00    	je     801091ca <getpgtable+0x254>
80109049:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010904d:	74 0f                	je     8010905e <getpgtable+0xe8>
8010904f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80109053:	83 f0 01             	xor    $0x1,%eax
80109056:	84 c0                	test   %al,%al
80109058:	0f 85 6c 01 00 00    	jne    801091ca <getpgtable+0x254>
      continue;

    pt_entries[i].pdx = PDX(uva);
8010905e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109061:	c1 e8 16             	shr    $0x16,%eax
80109064:	89 c1                	mov    %eax,%ecx
80109066:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109069:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109070:	8b 45 08             	mov    0x8(%ebp),%eax
80109073:	01 c2                	add    %eax,%edx
80109075:	89 c8                	mov    %ecx,%eax
80109077:	66 25 ff 03          	and    $0x3ff,%ax
8010907b:	66 25 ff 03          	and    $0x3ff,%ax
8010907f:	89 c1                	mov    %eax,%ecx
80109081:	0f b7 02             	movzwl (%edx),%eax
80109084:	66 25 00 fc          	and    $0xfc00,%ax
80109088:	09 c8                	or     %ecx,%eax
8010908a:	66 89 02             	mov    %ax,(%edx)
    pt_entries[i].ptx = PTX(uva);
8010908d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109090:	c1 e8 0c             	shr    $0xc,%eax
80109093:	89 c1                	mov    %eax,%ecx
80109095:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109098:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010909f:	8b 45 08             	mov    0x8(%ebp),%eax
801090a2:	01 c2                	add    %eax,%edx
801090a4:	89 c8                	mov    %ecx,%eax
801090a6:	66 25 ff 03          	and    $0x3ff,%ax
801090aa:	0f b7 c0             	movzwl %ax,%eax
801090ad:	25 ff 03 00 00       	and    $0x3ff,%eax
801090b2:	c1 e0 0a             	shl    $0xa,%eax
801090b5:	89 c1                	mov    %eax,%ecx
801090b7:	8b 02                	mov    (%edx),%eax
801090b9:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
801090be:	09 c8                	or     %ecx,%eax
801090c0:	89 02                	mov    %eax,(%edx)
    pt_entries[i].ppage = *pte >> PTXSHIFT;
801090c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801090c5:	8b 00                	mov    (%eax),%eax
801090c7:	c1 e8 0c             	shr    $0xc,%eax
801090ca:	89 c2                	mov    %eax,%edx
801090cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090cf:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801090d6:	8b 45 08             	mov    0x8(%ebp),%eax
801090d9:	01 c8                	add    %ecx,%eax
801090db:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
801090e1:	89 d1                	mov    %edx,%ecx
801090e3:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
801090e9:	8b 50 04             	mov    0x4(%eax),%edx
801090ec:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
801090f2:	09 ca                	or     %ecx,%edx
801090f4:	89 50 04             	mov    %edx,0x4(%eax)
    pt_entries[i].present = *pte & PTE_P;
801090f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801090fa:	8b 08                	mov    (%eax),%ecx
801090fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090ff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109106:	8b 45 08             	mov    0x8(%ebp),%eax
80109109:	01 c2                	add    %eax,%edx
8010910b:	89 c8                	mov    %ecx,%eax
8010910d:	83 e0 01             	and    $0x1,%eax
80109110:	83 e0 01             	and    $0x1,%eax
80109113:	c1 e0 04             	shl    $0x4,%eax
80109116:	89 c1                	mov    %eax,%ecx
80109118:	0f b6 42 06          	movzbl 0x6(%edx),%eax
8010911c:	83 e0 ef             	and    $0xffffffef,%eax
8010911f:	09 c8                	or     %ecx,%eax
80109121:	88 42 06             	mov    %al,0x6(%edx)
    pt_entries[i].writable = (*pte & PTE_W) > 0;
80109124:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109127:	8b 00                	mov    (%eax),%eax
80109129:	83 e0 02             	and    $0x2,%eax
8010912c:	89 c2                	mov    %eax,%edx
8010912e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109131:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80109138:	8b 45 08             	mov    0x8(%ebp),%eax
8010913b:	01 c8                	add    %ecx,%eax
8010913d:	85 d2                	test   %edx,%edx
8010913f:	0f 95 c2             	setne  %dl
80109142:	83 e2 01             	and    $0x1,%edx
80109145:	89 d1                	mov    %edx,%ecx
80109147:	c1 e1 05             	shl    $0x5,%ecx
8010914a:	0f b6 50 06          	movzbl 0x6(%eax),%edx
8010914e:	83 e2 df             	and    $0xffffffdf,%edx
80109151:	09 ca                	or     %ecx,%edx
80109153:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].encrypted = (*pte & PTE_E) > 0;
80109156:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109159:	8b 00                	mov    (%eax),%eax
8010915b:	25 00 04 00 00       	and    $0x400,%eax
80109160:	89 c2                	mov    %eax,%edx
80109162:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109165:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010916c:	8b 45 08             	mov    0x8(%ebp),%eax
8010916f:	01 c8                	add    %ecx,%eax
80109171:	85 d2                	test   %edx,%edx
80109173:	0f 95 c2             	setne  %dl
80109176:	89 d1                	mov    %edx,%ecx
80109178:	c1 e1 07             	shl    $0x7,%ecx
8010917b:	0f b6 50 06          	movzbl 0x6(%eax),%edx
8010917f:	83 e2 7f             	and    $0x7f,%edx
80109182:	09 ca                	or     %ecx,%edx
80109184:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].ref = (*pte & PTE_A) > 0;
80109187:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010918a:	8b 00                	mov    (%eax),%eax
8010918c:	83 e0 20             	and    $0x20,%eax
8010918f:	89 c2                	mov    %eax,%edx
80109191:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109194:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010919b:	8b 45 08             	mov    0x8(%ebp),%eax
8010919e:	01 c8                	add    %ecx,%eax
801091a0:	85 d2                	test   %edx,%edx
801091a2:	0f 95 c2             	setne  %dl
801091a5:	89 d1                	mov    %edx,%ecx
801091a7:	83 e1 01             	and    $0x1,%ecx
801091aa:	0f b6 50 07          	movzbl 0x7(%eax),%edx
801091ae:	83 e2 fe             	and    $0xfffffffe,%edx
801091b1:	09 ca                	or     %ecx,%edx
801091b3:	88 50 07             	mov    %dl,0x7(%eax)
    //*pte &= (~PTE_A);
    //PT_A flag needs to be modified as per clock algo.
    i++;
801091b6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    if (uva == 0 || i == num) break;
801091ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801091be:	74 17                	je     801091d7 <getpgtable+0x261>
801091c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091c3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801091c6:	74 0f                	je     801091d7 <getpgtable+0x261>
801091c8:	eb 01                	jmp    801091cb <getpgtable+0x255>
      continue;
801091ca:	90                   	nop
  for (;;uva -=PGSIZE)
801091cb:	81 6d f0 00 10 00 00 	subl   $0x1000,-0x10(%ebp)
  {
801091d2:	e9 0c fe ff ff       	jmp    80108fe3 <getpgtable+0x6d>

  }

  return i;
801091d7:	8b 45 ec             	mov    -0x14(%ebp),%eax

}
801091da:	c9                   	leave  
801091db:	c3                   	ret    

801091dc <dump_rawphymem>:


int dump_rawphymem(char * physical_addr, char * buffer) {
801091dc:	f3 0f 1e fb          	endbr32 
801091e0:	55                   	push   %ebp
801091e1:	89 e5                	mov    %esp,%ebp
801091e3:	56                   	push   %esi
801091e4:	53                   	push   %ebx
801091e5:	83 ec 10             	sub    $0x10,%esp
  *buffer = *buffer;
801091e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801091eb:	0f b6 10             	movzbl (%eax),%edx
801091ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801091f1:	88 10                	mov    %dl,(%eax)
  cprintf("p4Debug: dump_rawphymem: %p, %p\n", physical_addr, buffer);
801091f3:	83 ec 04             	sub    $0x4,%esp
801091f6:	ff 75 0c             	pushl  0xc(%ebp)
801091f9:	ff 75 08             	pushl  0x8(%ebp)
801091fc:	68 cc 9c 10 80       	push   $0x80109ccc
80109201:	e8 12 72 ff ff       	call   80100418 <cprintf>
80109206:	83 c4 10             	add    $0x10,%esp
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) PGROUNDDOWN((int)P2V(physical_addr)), PGSIZE);
80109209:	8b 45 08             	mov    0x8(%ebp),%eax
8010920c:	05 00 00 00 80       	add    $0x80000000,%eax
80109211:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109216:	89 c6                	mov    %eax,%esi
80109218:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010921b:	e8 ed b2 ff ff       	call   8010450d <myproc>
80109220:	8b 40 04             	mov    0x4(%eax),%eax
80109223:	68 00 10 00 00       	push   $0x1000
80109228:	56                   	push   %esi
80109229:	53                   	push   %ebx
8010922a:	50                   	push   %eax
8010922b:	e8 b8 f6 ff ff       	call   801088e8 <copyout>
80109230:	83 c4 10             	add    $0x10,%esp
80109233:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
80109236:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010923a:	74 07                	je     80109243 <dump_rawphymem+0x67>
    return -1;
8010923c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109241:	eb 05                	jmp    80109248 <dump_rawphymem+0x6c>
  return 0;
80109243:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109248:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010924b:	5b                   	pop    %ebx
8010924c:	5e                   	pop    %esi
8010924d:	5d                   	pop    %ebp
8010924e:	c3                   	ret    
