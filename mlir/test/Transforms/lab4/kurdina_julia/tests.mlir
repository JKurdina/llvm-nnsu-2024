// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/KurdinaMaxDepth%shlibext --pass-pipeline="builtin.module(func.func(KurdinaMaxDepth))" %s | FileCheck %s

  llvm.func @func2(%arg0: i32, %arg1: i32) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
// CHECK: llvm.func @func2(%arg0: i32, %arg1: i32) {{.*}}attributes {{.*}}maxDepth = 2 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(-1 : i32) : i32
    %2 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %3 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %2 : i32, !llvm.ptr
    llvm.store %arg1, %3 : i32, !llvm.ptr
    %4 = llvm.load %2 : !llvm.ptr -> i32
    %5 = llvm.load %3 : !llvm.ptr -> i32
    %6 = llvm.icmp "sgt" %4, %5 : i32
    llvm.cond_br %6, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %7 = llvm.load %2 : !llvm.ptr -> i32
    %8 = llvm.add %7, %1  : i32
    llvm.store %8, %2 : i32, !llvm.ptr
    llvm.br ^bb3
  ^bb2:  // pred: ^bb0
    %9 = llvm.load %3 : !llvm.ptr -> i32
    %10 = llvm.add %9, %1  : i32
    llvm.store %10, %3 : i32, !llvm.ptr
    llvm.br ^bb3
  ^bb3:  // 2 preds: ^bb1, ^bb2
    llvm.return
  }
  llvm.func @func3(%arg0: i32, %arg1: i32) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
// CHECK: llvm.func @func3(%arg0: i32, %arg1: i32) {{.*}}attributes {{.*}}maxDepth = 3 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(0 : i32) : i32
    %2 = llvm.mlir.constant(10 : i32) : i32
    %3 = llvm.mlir.constant(-1 : i32) : i32
    %4 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %5 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %6 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %4 : i32, !llvm.ptr
    llvm.store %arg1, %5 : i32, !llvm.ptr
    llvm.store %1, %6 : i32, !llvm.ptr
    llvm.br ^bb1
  ^bb1:  // 2 preds: ^bb0, ^bb6
    %7 = llvm.load %6 : !llvm.ptr -> i32
    %8 = llvm.icmp "slt" %7, %2 : i32
    llvm.cond_br %8, ^bb2, ^bb7
  ^bb2:  // pred: ^bb1
    %9 = llvm.load %4 : !llvm.ptr -> i32
    %10 = llvm.load %5 : !llvm.ptr -> i32
    %11 = llvm.icmp "sgt" %9, %10 : i32
    llvm.cond_br %11, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    %12 = llvm.load %4 : !llvm.ptr -> i32
    %13 = llvm.add %12, %3  : i32
    llvm.store %13, %4 : i32, !llvm.ptr
    llvm.br ^bb5
  ^bb4:  // pred: ^bb2
    %14 = llvm.load %5 : !llvm.ptr -> i32
    %15 = llvm.add %14, %3  : i32
    llvm.store %15, %5 : i32, !llvm.ptr
    llvm.br ^bb5
  ^bb5:  // 2 preds: ^bb3, ^bb4
    llvm.br ^bb6
  ^bb6:  // pred: ^bb5
    %16 = llvm.load %6 : !llvm.ptr -> i32
    %17 = llvm.add %16, %0  : i32
    llvm.store %17, %6 : i32, !llvm.ptr
    llvm.br ^bb1
  ^bb7:  // pred: ^bb1
    llvm.return
  }
  llvm.func @func4(%arg0: i32, %arg1: i32, %arg2: i32) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
// CHECK: llvm.func @func4(%arg0: i32, %arg1: i32, %arg2: i32) {{.*}}attributes {{.*}}maxDepth = 4 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(0 : i32) : i32
    %2 = llvm.mlir.constant(10 : i32) : i32
    %3 = llvm.mlir.constant(-1 : i32) : i32
    %4 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %5 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %6 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %7 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %4 : i32, !llvm.ptr
    llvm.store %arg1, %5 : i32, !llvm.ptr
    llvm.store %arg2, %6 : i32, !llvm.ptr
    llvm.store %1, %7 : i32, !llvm.ptr
    llvm.br ^bb1
  ^bb1:  // 2 preds: ^bb0, ^bb8
    %8 = llvm.load %7 : !llvm.ptr -> i32
    %9 = llvm.icmp "slt" %8, %2 : i32
    llvm.cond_br %9, ^bb2, ^bb9
  ^bb2:  // pred: ^bb1
    %10 = llvm.load %4 : !llvm.ptr -> i32
    %11 = llvm.load %5 : !llvm.ptr -> i32
    %12 = llvm.icmp "sgt" %10, %11 : i32
    llvm.cond_br %12, ^bb3, ^bb6
  ^bb3:  // pred: ^bb2
    %13 = llvm.load %4 : !llvm.ptr -> i32
    %14 = llvm.add %13, %3  : i32
    llvm.store %14, %4 : i32, !llvm.ptr
    %15 = llvm.load %4 : !llvm.ptr -> i32
    %16 = llvm.load %6 : !llvm.ptr -> i32
    %17 = llvm.icmp "sgt" %15, %16 : i32
    llvm.cond_br %17, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %18 = llvm.load %4 : !llvm.ptr -> i32
    %19 = llvm.add %18, %3  : i32
    llvm.store %19, %4 : i32, !llvm.ptr
    llvm.br ^bb5
  ^bb5:  // 2 preds: ^bb3, ^bb4
    llvm.br ^bb7
  ^bb6:  // pred: ^bb2
    %20 = llvm.load %5 : !llvm.ptr -> i32
    %21 = llvm.add %20, %3  : i32
    llvm.store %21, %5 : i32, !llvm.ptr
    llvm.br ^bb7
  ^bb7:  // 2 preds: ^bb5, ^bb6
    llvm.br ^bb8
  ^bb8:  // pred: ^bb7
    %22 = llvm.load %7 : !llvm.ptr -> i32
    %23 = llvm.add %22, %0  : i32
    llvm.store %23, %7 : i32, !llvm.ptr
    llvm.br ^bb1
  ^bb9:  // pred: ^bb1
    llvm.return
  }
  llvm.func @func1(%arg0: i32, %arg1: i32) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
// CHECK: llvm.func @func1(%arg0: i32, %arg1: i32) {{.*}}attributes {{.*}}maxDepth = 1 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %2 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %1 : i32, !llvm.ptr
    llvm.store %arg1, %2 : i32, !llvm.ptr
    llvm.return
  }
