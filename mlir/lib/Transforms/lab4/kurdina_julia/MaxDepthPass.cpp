#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Tools/Plugins/PassPlugin.h"
#include "mlir/IR/Region.h"
#include "mlir/IR/Operation.h"
#include <vector>
#include <iostream>
#include <stack>

using namespace mlir;

namespace {
class MaxDepthPass : public PassWrapper<MaxDepthPass, OperationPass<ModuleOp>> {
public:
  StringRef getArgument() const final { return "KurdinaMaxDepth"; }
  StringRef getDescription() const final {
    return "Counts the max depth of region nests in the function";
  }

  void runOnOperation() override {
    getOperation().walk([&](Operation *op) {
      if (auto funcOp = dyn_cast<LLVM::LLVMFuncOp>(op)) {
        int d = 1;
        int maxDepth = getFunctionDepth(op);
        funcOp->setAttr(
            "maxDepth",
            IntegerAttr::get(IntegerType::get(funcOp.getContext(), 32), maxDepth));
      }
    });  
  }

private:
  int getFunctionDepth(Operation *op) {
    if (!op) {
      return 0; // ≈сли операци€ пуста, возвращаем глубину 0
    }

    int maxDepth = 0;
    std::stack<std::pair<Operation *, int>> opStack;
    opStack.push({op, 1});

    while (!opStack.empty()) {
      auto [currentOp, depth] = opStack.top();
      opStack.pop();

      maxDepth = std::max(maxDepth, depth);

      currentOp->walk([&](Operation *nestedOp) {
        opStack.push({nestedOp, depth + 1});
      });
    }

    return maxDepth;
  }
};
} // namespace

MLIR_DECLARE_EXPLICIT_TYPE_ID(MaxDepthPass)
MLIR_DEFINE_EXPLICIT_TYPE_ID(MaxDepthPass)

PassPluginLibraryInfo getMaxDepthPassPluginInfo() {
  return {MLIR_PLUGIN_API_VERSION, "KurdinaMaxDepth", LLVM_VERSION_STRING,
          []() { PassRegistration<MaxDepthPass>(); }};
}

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo mlirGetPassPluginInfo() {
  return getMaxDepthPassPluginInfo();
}