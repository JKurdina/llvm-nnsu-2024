// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/KurdinaMaxDepth%shlibext --pass-pipeline="builtin.module(KurdinaMaxDepth)" %s | FileCheck %s

module attributes {dlti.dl_spec = #dlti.dl_spec<#dlti.dl_entry<i1, dense<8> : vector<2xi32>>, #dlti.dl_entry<i8, dense<8> : vector<2xi32>>, #dlti.dl_entry<i16, dense<16> : vector<2xi32>>, #dlti.dl_entry<i32, dense<32> : vector<2xi32>>, #dlti.dl_entry<i64, dense<[32, 64]> : vector<2xi32>>, #dlti.dl_entry<f16, dense<16> : vector<2xi32>>, #dlti.dl_entry<f64, dense<64> : vector<2xi32>>, #dlti.dl_entry<f128, dense<128> : vector<2xi32>>>} {
  llvm.func @func1(%arg0: i32) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
// CHECK: llvm.func @func1() {{.*}}attributes {{.*}}maxDepth = 2 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(0 : i32) : i32
    %2 = llvm.mlir.constant(10 : i32) : i32
    %3 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %4 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %3 : i32, !llvm.ptr
    llvm.store %1, %4 : i32, !llvm.ptr
    llvm.br ^bb1
  ^bb1:  // 2 preds: ^bb0, ^bb3
    %5 = llvm.load %4 : !llvm.ptr -> i32
    %6 = llvm.icmp "slt" %5, %2 : i32
    llvm.cond_br %6, ^bb2, ^bb4
  ^bb2:  // pred: ^bb1
    %7 = llvm.load %3 : !llvm.ptr -> i32
    %8 = llvm.add %7, %0  : i32
    llvm.store %8, %3 : i32, !llvm.ptr
    llvm.br ^bb3
  ^bb3:  // pred: ^bb2
    %9 = llvm.load %4 : !llvm.ptr -> i32
    %10 = llvm.add %9, %0  : i32
    llvm.store %10, %4 : i32, !llvm.ptr
    llvm.br ^bb1
  ^bb4:  // pred: ^bb1
    llvm.return
  }
}