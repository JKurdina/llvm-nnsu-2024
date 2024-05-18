// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/KurdinaMaxDepth%shlibext --pass-pipeline="builtin.module(KurdinaMaxDepth)" %s | FileCheck %s

module {
  llvm.func @func1() {
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(2 : i32) : i32
    %2 = llvm.cmpi "eq", %0, %1 : i32
    %3 = llvm.cond_br %2, ^bb1, ^bb2
    ^bb1:
      %4 = llvm.mlir.constant(3 : i32) : i32
      llvm.br ^bb3
    ^bb2:
      %5 = llvm.mlir.constant(4 : i32) : i32
      llvm.br ^bb3
    ^bb3:
      %6 = llvm.mlir.constant(5 : i32) : i32
      llvm.return
  }
  // CHECK: func1 maxDepth=2

  llvm.func @main() {
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(2 : i32) : i32
    %2 = llvm.call @func1() : () -> ()
    llvm.return
  }
}