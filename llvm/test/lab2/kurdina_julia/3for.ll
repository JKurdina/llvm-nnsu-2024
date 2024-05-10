; RUN: opt -load-pass-plugin=%llvmshlibdir/kurdina_loop_pass_plugin%shlibext -passes=loop_func -S %s | FileCheck %s

; void a() {
;     int c = 10;
;     for (int i = 0; i < 10; i++) {
;         c++;
;     }
;     int q = c + 42;
; }

define dso_local void @a() {
entry:
  %c = alloca i32, align 4
  %i = alloca i32, align 4
  %q = alloca i32, align 4
  store i32 10, ptr %c, align 4
  store i32 0, ptr %i, align 4
; CHECK:    call void @loop_start()
  br label %for.cond

for.cond:
  %0 = load i32, ptr %i, align 4
  %cmp = icmp slt i32 %0, 10
  br i1 %cmp, label %for.body, label %for.end

for.body:
  %1 = load i32, ptr %c, align 4
  %inc = add nsw i32 %1, 1
  store i32 %inc, ptr %c, align 4
  br label %for.inc

for.inc:
  %2 = load i32, ptr %i, align 4
  %inc1 = add nsw i32 %2, 1
  store i32 %inc1, ptr %i, align 4
  br label %for.cond

for.end:
; CHECK:    call void @loop_end()
  %3 = load i32, ptr %c, align 4
  %add = add nsw i32 %3, 42
  store i32 %add, ptr %q, align 4
  ret void
}