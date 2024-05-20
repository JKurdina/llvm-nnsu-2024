#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Tools/Plugins/PassPlugin.h"
#include "mlir/IR/Region.h"
#include "mlir/IR/Operation.h"

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
        int maxDepth = getFunctionDepth(funcOp, d);
        funcOp->setAttr(
            "maxDepth",
            IntegerAttr::get(IntegerType::get(funcOp.getContext(), 32), maxDepth));
      }
    });  
  }

private:
  
  int getFunctionDepth(Operation *op, int depth) {
    if (!op) {
      return depth; // Можно выбрать другое поведение в случае нулевого
                    // указателя
    }
    int maxDepth = depth;

    // Рекурсивный обход операций
    op->walk([&](Operation *nestedOp) {
      // Вызов рекурсивного обхода для вложенной операции
      maxDepth = std::max(maxDepth, getFunctionDepth(nestedOp, depth + 1));
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