// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/KurdinaMaxDepth%shlibext --pass-pipeline="builtin.module(func.func(KurdinaMaxDepth))" %s | FileCheck %s

// CHECK: func.func @one() {{.*}}attributes {{.*}}maxDepth = 1 : i32
func.func @one() {
  func.return
}

// CHECK: func.func @two() {{.*}}attributes {{.*}}maxDepth = 2 : i32
func.func @two() {
    %cond = arith.constant 1 : i1
    %0 = scf.if %cond -> (i1) {
        scf.yield %cond : i1
    } else {
        scf.yield %cond : i1
    }
    func.return
}

// CHECK: func.func @tree() {{.*}}attributes {{.*}}maxDepth = 3 : i32
func.func @three() {
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