// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/KurdinaMaxDepth%shlibext --pass-pipeline="builtin.module(KurdinaMaxDepth)" %s | FileCheck %s

module {
  llvm.func @func(%arg0: i32) {
    %i = arith.constant 0 : i32
    %a = arith.constant %arg0 : i32
    br ^bb1(%a, %i : i32, i32)
    ^bb1(%a: i32, %i: i32) {
      %cmp = arith.cmpi "slt", %i, 10 : i32
      cond_br %cmp, ^bb2, ^bb3
      ^bb2 {
        %a_inc = arith.addi %a, 1 : i32
        %i_inc = arith.addi %i, 1 : i32
        br ^bb1(%a_inc, %i_inc : i32, i32)
      }
      ^bb3 {
        br ^bb4
      }
      ^bb4 {
        llvm.return
      }
    }
  }
  // CHECK: attributes { maxDepth = 2 : i32 }
}