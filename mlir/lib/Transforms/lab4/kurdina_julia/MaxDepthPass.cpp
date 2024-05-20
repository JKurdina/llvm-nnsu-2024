#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Tools/Plugins/PassPlugin.h"
#include "mlir/IR/Region.h"
#include "mlir/IR/Operation.h"
#include <vector>

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
        int maxDepth = getMaxDepthFunc(op);
        funcOp->setAttr(
            "maxDepth",
            IntegerAttr::get(IntegerType::get(funcOp.getContext(), 32), maxDepth));
      }
    });  
  }

private:
  int getMaxDepthFunc(Operation* funcOp) {
    std::vector<Operation *> lastStack;
    int maxDepth = 1;
    int depth = 0;
    funcOp->walk([&](Operation *op) {
      bool hasNested = false;
      Operation *curOp = op;
      Operation *lastOp;
      std::vector<Operation *> opStack;
      curOp->walk([&](Operation *o) {
        opStack.push_back(o);
        hasNested = true;
      });
      if (hasNested) {
        depth++;
        lastOp = opStack.back();
        lastStack.push_back(lastOp);
        opStack.clear();
      } else if (op == lastStack.back()) {
        maxDepth = std::max(maxDepth, depth);
        depth--;
        lastStack.pop_back();
      }

    });
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