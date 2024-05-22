// RUN: split-file %s %t
// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/KurdinaMaxDepth%shlibext --pass-pipeline="builtin.module(func.func(KurdinaMaxDepth))" %t/one.mlir | FileCheck %t/one.mlir

//--- one.mlir
func.func @one() {
// CHECK: func.func @one() {maxDepth = 1}
  func.return
}

//--- two.mlir
func.func @two() {
// CHECK: func.func @two() {maxDepth = 2}
    %cond = arith.constant 1 : i1
    %0 = scf.if %cond -> (i1) {
        scf.yield %cond : i1
    } else {
        scf.yield %cond : i1
    }
    func.return
}

//--- three.mlir
func.func @three() {
// CHECK: func.func @three() {maxDepth = 3}
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