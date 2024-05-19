#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Tools/Plugins/PassPlugin.h"
#include "mlir/IR/Region.h"

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
        int maxDepth = getMaxDepth(funcOp);
        funcOp->setAttr(
            "maxDepth",
            IntegerAttr::get(IntegerType::get(funcOp.getContext(), 32), maxDepth));
      }
    });  
  }

private:
  int getMaxDepth(LLVM::LLVMFuncOp funcOp) {
    int maxDepth = 1;
    std::vector<Operation *> operations;
    funcOp.walk([&](Operation *op) { operations.push_back(op); });
    Operation *curOp;
    while (!operations.empty()) {
      int depth = -1;
      curOp = operations.back();
      operations.pop_back();
      while (curOp->getParentOp()) {
        depth++;
        curOp = curOp->getParentOp();
      }
      maxDepth = std::max(maxDepth, depth);
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