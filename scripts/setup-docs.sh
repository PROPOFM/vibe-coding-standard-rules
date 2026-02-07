#!/bin/bash

# プロジェクト開始時に/docs配下の標準フォルダ構造を作成するスクリプト

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCS_DIR="${PROJECT_ROOT}/docs"
TEMPLATES_DIR="${PROJECT_ROOT}/.ai-rules/templates/docs-structure"

echo "📁 プロジェクトドキュメント構造のセットアップを開始します..."
echo ""

# .ai-rulesがサブモジュールとして存在する場合
if [ -d "${PROJECT_ROOT}/.ai-rules/templates/docs-structure" ]; then
    TEMPLATES_DIR="${PROJECT_ROOT}/.ai-rules/templates/docs-structure"
    echo "✅ サブモジュールからテンプレートを検出: ${TEMPLATES_DIR}"
# このリポジトリ自体の場合
elif [ -d "${PROJECT_ROOT}/templates/docs-structure" ]; then
    TEMPLATES_DIR="${PROJECT_ROOT}/templates/docs-structure"
    echo "✅ ローカルのテンプレートを検出: ${TEMPLATES_DIR}"
else
    echo "⚠️  テンプレートが見つかりません。手動でフォルダを作成します。"
    TEMPLATES_DIR=""
fi

# docsディレクトリが存在しない場合は作成
if [ ! -d "${DOCS_DIR}" ]; then
    echo "📁 ${DOCS_DIR} を作成します..."
    mkdir -p "${DOCS_DIR}"
fi

# テンプレートからコピーする場合
if [ -n "${TEMPLATES_DIR}" ] && [ -d "${TEMPLATES_DIR}" ]; then
    echo "📋 テンプレートからフォルダ構造をコピーします..."
    cp -r "${TEMPLATES_DIR}"/* "${DOCS_DIR}/"
    echo "✅ テンプレートをコピーしました。"
else
    # 手動でフォルダを作成
    echo "📁 標準フォルダ構造を手動で作成します..."
    mkdir -p "${DOCS_DIR}/consideration"
    mkdir -p "${DOCS_DIR}/todo"
    mkdir -p "${DOCS_DIR}/reference"
    mkdir -p "${DOCS_DIR}/history"
    mkdir -p "${DOCS_DIR}/requirement"
    
    # 各フォルダに.gitkeepを作成（空のフォルダをGitで管理するため）
    touch "${DOCS_DIR}/consideration/.gitkeep"
    touch "${DOCS_DIR}/todo/.gitkeep"
    touch "${DOCS_DIR}/reference/.gitkeep"
    touch "${DOCS_DIR}/history/.gitkeep"
    touch "${DOCS_DIR}/requirement/.gitkeep"
    
    echo "✅ フォルダ構造を作成しました。"
fi

echo ""
echo "📚 作成されたフォルダ構造:"
tree -L 2 "${DOCS_DIR}" || find "${DOCS_DIR}" -type d | sort

echo ""
echo "✅ セットアップが完了しました！"
echo ""
echo "次のステップ:"
echo "1. 各フォルダのREADME.mdを確認してください"
echo "2. プロジェクトに合わせてカスタマイズしてください"
echo "3. 初期ドキュメントを作成してください"
echo ""
echo "詳細は .ai-rules/core/documentation.md を参照してください。"

