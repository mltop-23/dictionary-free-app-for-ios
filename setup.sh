#!/bin/bash
set -e

cd "$(dirname "$0")"

if ! command -v xcodegen &> /dev/null; then
    echo "XcodeGen не найден. Ставлю через brew..."
    if ! command -v brew &> /dev/null; then
        echo "Brew тоже нет. Поставь сначала: https://brew.sh"
        exit 1
    fi
    brew install xcodegen
fi

echo "Генерирую Xcode проект..."
xcodegen generate

echo ""
echo "Готово! Теперь:"
echo "  1. open Kefir.xcodeproj"
echo "  2. В Xcode: выбери свой Apple ID в Signing & Capabilities"
echo "  3. Подключи iPhone, выбери его как destination"
echo "  4. Cmd+R — запустить на устройстве"
echo ""
echo "Открываю проект..."
open Kefir.xcodeproj
