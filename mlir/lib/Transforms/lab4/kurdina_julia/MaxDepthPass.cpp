#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Tools/Plugins/PassPlugin.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"

using namespace mlir;

namespace {
class MaxDepthPass : public PassWrapper<MaxDepthPass, OperationPass<ModuleOp>> {
public:
  StringRef getArgument() const final { return "KurdinaMaxDepth"; }
  StringRef getDescription() const final {
    return "Counts the max depth of region nests in the function";
  }

  void runOnOperation() override {

    getOperation()->walk([&](Operation *op) {
      if (auto funcOp = dyn_cast<LLVM::LLVMFuncOp>(op)) {
        int maxDepth = 0;
        funcOp.walk([&](Block *block) {
          int curDepth = 0;
          DepthBlock(block, curDepth, maxDepth);
        });
        funcOp->setAttr(
            "maxDepth",
            IntegerAttr::get(IntegerType::get(funcOp.getContext(), 32),
                             maxDepth));
      }
    });
  }

private:
  void DepthBlock(Block *block, int &curDepth, int &maxDepth) {
    block->walk([&](Operation *op) {
      auto loopOp = dyn_cast<loop::LoopOp>(op);
      auto ifOp = dyn_cast<IfOp>(op);
      // ���������, �������� �� �������� �������� ��� ������
      if (loopOp != nullptr || ifOp != nullptr) {
        // ����������� ������� ������� ��� ����� � ������� ��� ����
        curDepth++;
        // ��������� ������������ �������, ���� ������� ������� ������
        if (curDepth > maxDepth) {
          maxDepth = curDepth;
        }
      }
      auto *nestedBlock = dyn_cast<Block>(op);
      if (nestedBlock != nullptr) {
        // ���������� ������� �������� ���� � ������� �������� � ������������
        // ��������
        DepthBlock(nestedBlock, curDepth, maxDepth);
      }

      if (loopOp != nullptr || ifOp != nullptr) {
        // ��������� ������� ������� ��� ������ �� ������� ��� �����
        curDepth--;
      }
    });
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