; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mattr=rdpid | FileCheck %s --check-prefix=CHECK --check-prefix=X86-64
; RUN: llc < %s -mtriple=i686-- -mattr=rdpid | FileCheck %s --check-prefix=CHECK --check-prefix=X86

define i32 @test_builtin_rdpid() {
; X86-64-LABEL: test_builtin_rdpid:
; X86-64:       # %bb.0:
; X86-64-NEXT:    rdpid %rax
; X86-64-NEXT:    # kill: def %eax killed %eax killed %rax
; X86-64-NEXT:    retq
;
; X86-LABEL: test_builtin_rdpid:
; X86:       # %bb.0:
; X86-NEXT:    rdpid %eax
; X86-NEXT:    retl
  %1 = tail call i32 @llvm.x86.rdpid()
  ret i32 %1
}

declare i32 @llvm.x86.rdpid()

