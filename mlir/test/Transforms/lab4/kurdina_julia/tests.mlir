// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/KurdinaMaxDepth%shlibext --pass-pipeline="builtin.module(func.func(KurdinaMaxDepth))" %s | FileCheck %s

func.func @one() {
// CHECK: func.func @one() { maxDepth = 1 }
  func.return
}

func.func @two() {
// CHECK: func.func @two() { maxDepth = 2 }
    %cond = arith.constant 1 : i1
    %0 = scf.if %cond -> (i1) {
        scf.yield %cond : i1
    } else {
        scf.yield %cond : i1
    }
    func.return
}

func.func @three() {
// CHECK: func.func @three() { maxDepth = 3 }
%cond = arith.constant 1 : i1
    %0 = scf.if %cond -> (i1) {
        %1 = scf.if %cond -> (i1) {
            scf.yield %cond : i1
        } else {
            scf.yield %cond : i1
        }
        scf.yield %cond : i1
    } else {
        scf.yield %cond : i1
    }
    func.return
}