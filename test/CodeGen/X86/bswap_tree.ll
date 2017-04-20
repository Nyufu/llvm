; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown | FileCheck %s
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefix=CHECK64

; Check reconstructing bswap from shifted masks and tree of ORs

; Match a 32-bit packed halfword bswap. That is
; ((x & 0x000000ff) << 8) |
; ((x & 0x0000ff00) >> 8) |
; ((x & 0x00ff0000) << 8) |
; ((x & 0xff000000) >> 8)
; => (rotl (bswap x), 16)
define i32 @test1(i32 %x) nounwind {
; CHECK-LABEL: test1:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movl %ecx, %edx
; CHECK-NEXT:    andl $16711680, %edx # imm = 0xFF0000
; CHECK-NEXT:    movl %ecx, %eax
; CHECK-NEXT:    andl $-16777216, %eax # imm = 0xFF000000
; CHECK-NEXT:    shll $8, %edx
; CHECK-NEXT:    shrl $8, %eax
; CHECK-NEXT:    bswapl %ecx
; CHECK-NEXT:    shrl $16, %ecx
; CHECK-NEXT:    orl %edx, %eax
; CHECK-NEXT:    orl %ecx, %eax
; CHECK-NEXT:    retl
;
; CHECK64-LABEL: test1:
; CHECK64:       # BB#0:
; CHECK64-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; CHECK64-NEXT:    movl %edi, %eax
; CHECK64-NEXT:    andl $16711680, %eax # imm = 0xFF0000
; CHECK64-NEXT:    movl %edi, %ecx
; CHECK64-NEXT:    andl $-16777216, %ecx # imm = 0xFF000000
; CHECK64-NEXT:    shll $8, %eax
; CHECK64-NEXT:    shrl $8, %ecx
; CHECK64-NEXT:    bswapl %edi
; CHECK64-NEXT:    shrl $16, %edi
; CHECK64-NEXT:    orl %eax, %ecx
; CHECK64-NEXT:    leal (%rcx,%rdi), %eax
; CHECK64-NEXT:    retq
  %byte0 = and i32 %x, 255        ; 0x000000ff
  %byte1 = and i32 %x, 65280      ; 0x0000ff00
  %byte2 = and i32 %x, 16711680   ; 0x00ff0000
  %byte3 = and i32 %x, 4278190080 ; 0xff000000
  %tmp0 = shl  i32 %byte0, 8
  %tmp1 = lshr i32 %byte1, 8
  %tmp2 = shl  i32 %byte2, 8
  %tmp3 = lshr i32 %byte3, 8
  %or0 = or i32 %tmp0, %tmp1
  %or1 = or i32 %tmp2, %tmp3
  %result = or i32 %or0, %or1
  ret i32 %result
}

; the same as test1, just shifts before the "and"
; ((x << 8) & 0x0000ff00) |
; ((x >> 8) & 0x000000ff) |
; ((x << 8) & 0xff000000) |
; ((x >> 8) & 0x00ff0000)
define i32 @test2(i32 %x) nounwind {
; CHECK-LABEL: test2:
; CHECK:       # BB#0:
; CHECK-NEXT:    pushl %esi
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl %eax, %ecx
; CHECK-NEXT:    shll $8, %ecx
; CHECK-NEXT:    shrl $8, %eax
; CHECK-NEXT:    movzwl %cx, %edx
; CHECK-NEXT:    movzbl %al, %esi
; CHECK-NEXT:    andl $-16777216, %ecx # imm = 0xFF000000
; CHECK-NEXT:    andl $16711680, %eax # imm = 0xFF0000
; CHECK-NEXT:    orl %edx, %esi
; CHECK-NEXT:    orl %ecx, %eax
; CHECK-NEXT:    orl %esi, %eax
; CHECK-NEXT:    popl %esi
; CHECK-NEXT:    retl
;
; CHECK64-LABEL: test2:
; CHECK64:       # BB#0:
; CHECK64-NEXT:    movl %edi, %ecx
; CHECK64-NEXT:    shll $8, %ecx
; CHECK64-NEXT:    shrl $8, %edi
; CHECK64-NEXT:    movzwl %cx, %edx
; CHECK64-NEXT:    movzbl %dil, %eax
; CHECK64-NEXT:    andl $-16777216, %ecx # imm = 0xFF000000
; CHECK64-NEXT:    andl $16711680, %edi # imm = 0xFF0000
; CHECK64-NEXT:    orl %edx, %eax
; CHECK64-NEXT:    orl %ecx, %edi
; CHECK64-NEXT:    orl %edi, %eax
; CHECK64-NEXT:    retq
  %byte1 = shl  i32 %x, 8
  %byte0 = lshr i32 %x, 8
  %byte3 = shl  i32 %x, 8
  %byte2 = lshr i32 %x, 8
  %tmp1 = and i32 %byte1, 65280      ; 0x0000ff00
  %tmp0 = and i32 %byte0, 255        ; 0x000000ff
  %tmp3 = and i32 %byte3, 4278190080 ; 0xff000000
  %tmp2 = and i32 %byte2, 16711680   ; 0x00ff0000
  %or0 = or i32 %tmp0, %tmp1
  %or1 = or i32 %tmp2, %tmp3
  %result = or i32 %or0, %or1
  ret i32 %result
}