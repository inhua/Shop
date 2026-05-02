#!/bin/bash
# =============================================================================
# publish_components.sh
# 按依赖顺序将各组件发布至私有 CocoaPods Spec 仓库（ShopSpecs）
#
# 使用前提：
#   1. 已执行 `pod repo add ShopSpecs <git-url>` 将私有仓库添加到本地 CocoaPods
#   2. 【重要】必须在运行本脚本之前，手动为每个组件打好 Git tag：
#        git tag 1.0.0
#        git push origin 1.0.0
#      或在各组件目录下分别执行：
#        cd Components/ShopMediator && git tag 1.0.0 && git push origin 1.0.0
#      本脚本不会自动执行 git tag，以避免误操作。
#
# 发布顺序（按依赖层级从底层到上层）：
#   1. ShopMediator        — 无依赖，最底层中间件
#   2. ShopRouter          — 依赖 ShopMediator
#   3. ShopBase            — 依赖 ShopMediator、ShopRouter
#   4. ShopBusinessBase    — 依赖 ShopBase、ShopRouter
#   5. ShopProduct         — 依赖 ShopBase、ShopRouter、ShopMediator
#   6. ShopHome            — 依赖 ShopBase、ShopRouter、ShopMediator、ShopProduct（并行组，顺序执行）
#      ShopMessage         — 依赖 ShopBase、ShopRouter
#      ShopCart            — 依赖 ShopBase、ShopRouter、ShopMediator、ShopBusinessBase
#      ShopMine            — 依赖 ShopBase、ShopRouter、ShopMediator、ShopBusinessBase
#      ShopLogin           — 依赖 ShopBase、ShopRouter、ShopMediator、ShopBusinessBase
#
# 用法：
#   chmod +x scripts/publish_components.sh
#   ./scripts/publish_components.sh
# =============================================================================

set -e

# 私有 Spec 仓库名称（与 pod repo add 时使用的名称一致）
REPO_NAME="ShopSpecs"

# 发布版本号（遵循 SemVer：主版本号.次版本号.修订号）
VERSION="1.0.0"

# 工程根目录（脚本所在目录的上一级）
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# =============================================================================
# 辅助函数
# =============================================================================

publish_component() {
    local COMPONENT_NAME="$1"
    local COMPONENT_DIR="$REPO_ROOT/Components/$COMPONENT_NAME"
    local PODSPEC="$COMPONENT_NAME.podspec"

    echo ""
    echo "============================================================"
    echo "  发布组件：$COMPONENT_NAME  (版本 $VERSION)"
    echo "============================================================"

    # 进入组件目录
    cd "$COMPONENT_DIR"
    echo "[1/2] 执行 pod lib lint ..."
    pod lib lint "$PODSPEC" --allow-warnings

    echo "[2/2] 执行 pod repo push ..."
    pod repo push "$REPO_NAME" "$PODSPEC" --allow-warnings

    echo "✅  $COMPONENT_NAME $VERSION 发布成功"
}

# =============================================================================
# 主流程：按依赖顺序依次发布
# =============================================================================

echo "开始发布所有组件至私有 Spec 仓库：$REPO_NAME"
echo "版本：$VERSION"
echo ""
echo "⚠️  请确认已在各组件目录下手动执行 git tag $VERSION 并推送至远端，再继续。"
echo ""

# --- 第 1 层：中间件组件（无依赖）---
publish_component "ShopMediator"

# --- 第 2 层：路由组件（依赖 ShopMediator）---
publish_component "ShopRouter"

# --- 第 3 层：基础组件（依赖 ShopMediator、ShopRouter）---
publish_component "ShopBase"

# --- 第 4 层：业务基础组件（依赖 ShopBase、ShopRouter）---
publish_component "ShopBusinessBase"

# --- 第 5 层：功能组件（依赖 ShopBase、ShopRouter、ShopMediator）---
publish_component "ShopProduct"

# --- 第 6 层：业务组件（并行，脚本中顺序执行）---
# ShopHome、ShopMessage、ShopCart、ShopMine、ShopLogin 之间无相互依赖，
# 可并行发布，此处为保证脚本简洁性顺序执行。
publish_component "ShopHome"
publish_component "ShopMessage"
publish_component "ShopCart"
publish_component "ShopMine"
publish_component "ShopLogin"

echo ""
echo "============================================================"
echo "  🎉 所有组件发布完成！"
echo "  仓库：$REPO_NAME  版本：$VERSION"
echo "============================================================"
echo ""
echo "后续步骤："
echo "  1. 在宿主工程根目录执行 pod install --repo-update"
echo "  2. 打开 .xcworkspace 验证各组件集成正常"
