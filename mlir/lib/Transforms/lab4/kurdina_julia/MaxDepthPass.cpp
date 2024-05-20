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
        int maxDepth = getRegionDepth(op);
        funcOp->setAttr(
            "maxDepth",
            IntegerAttr::get(IntegerType::get(funcOp.getContext(), 32), maxDepth));
      }
    });  
  }

private:
  int getRegionDepth(Operation *op) {
    if (!op) {
      return 0; // ≈сли операци€ пуста, возвращаем глубину 0
    }

    int maxDepth = 0;
    op->walk([&](Operation *nestedOp) {
      if (nestedOp->getNumRegions() > 0) {
        for (Region &region : nestedOp->getRegions()) {
          int regionDepth = getRegionDepth(region.front().get());
          maxDepth = std::max(maxDepth, regionDepth);
        }
      }
    });

    return maxDepth + 1; // ”величиваем глубину на 1 дл€ текущей операции
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