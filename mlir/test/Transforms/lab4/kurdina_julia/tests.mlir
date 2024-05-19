// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/KurdinaMaxDepth%shlibext --pass-pipeline="builtin.module(KurdinaMaxDepth)" %s | FileCheck %s

module attributes {dlti.dl_spec = #dlti.dl_spec<#dlti.dl_entry<i1, dense<8> : vector<2xi32>>, #dlti.dl_entry<i8, dense<8> : vector<2xi32>>, #dlti.dl_entry<i16, dense<16> : vector<2xi32>>, #dlti.dl_entry<i32, dense<32> : vector<2xi32>>, #dlti.dl_entry<i64, dense<[32, 64]> : vector<2xi32>>, #dlti.dl_entry<f16, dense<16> : vector<2xi32>>, #dlti.dl_entry<f64, dense<64> : vector<2xi32>>, #dlti.dl_entry<f128, dense<128> : vector<2xi32>>>} {
  llvm.func @func1(%arg0: i32, %arg1: i32) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
// CHECK: llvm.func @func1(%arg0: i32, %arg1: i32) {{.*}}attributes {{.*}}maxDepth = 3 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(0 : i32) : i32
    %2 = llvm.mlir.constant(10 : i32) : i32
    %3 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %4 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %5 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %3 : i32, !llvm.ptr
    llvm.store %arg1, %4 : i32, !llvm.ptr
    llvm.store %1, %5 : i32, !llvm.ptr
    llvm.br ^bb1
  ^bb1:  // 2 preds: ^bb0, ^bb6
    %6 = llvm.load %5 : !llvm.ptr -> i32
    %7 = llvm.icmp "slt" %6, %2 : i32
    llvm.cond_br %7, ^bb2, ^bb7
  ^bb2:  // pred: ^bb1
    %8 = llvm.load %3 : !llvm.ptr -> i32
    %9 = llvm.load %4 : !llvm.ptr -> i32
    %10 = llvm.icmp "sgt" %8, %9 : i32
    llvm.cond_br %10, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    %11 = llvm.load %4 : !llvm.ptr -> i32
    %12 = llvm.load %3 : !llvm.ptr -> i32
    %13 = llvm.add %12, %11  : i32
    llvm.store %13, %3 : i32, !llvm.ptr
    llvm.br ^bb5
  ^bb4:  // pred: ^bb2
    %14 = llvm.load %3 : !llvm.ptr -> i32
    %15 = llvm.load %4 : !llvm.ptr -> i32
    %16 = llvm.add %15, %14  : i32
    llvm.store %16, %4 : i32, !llvm.ptr
    llvm.br ^bb5
  ^bb5:  // 2 preds: ^bb3, ^bb4
    llvm.br ^bb6
  ^bb6:  // pred: ^bb5
    %17 = llvm.load %5 : !llvm.ptr -> i32
    %18 = llvm.add %17, %0  : i32
    llvm.store %18, %5 : i32, !llvm.ptr
    llvm.br ^bb1
  ^bb7:  // pred: ^bb1
    llvm.return
  }
}