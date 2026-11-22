#!/usr/bin/env bash

set -euo pipefail

get_package_dir() {
  local filter="$1"
  local pkg_id
  pkg_id=$(conan list "pbkdf2/0.1.0:*" -p "${filter}"  --format=json | python3 -c "
import sys, json
data = json.load(sys.stdin)
revs = data['Local Cache']['pbkdf2/0.1.0']['revisions']
pkgs = list(revs.values())[0]['packages']
assert(len(pkgs) == 1)
print(next(iter(pkgs)))
")
  conan cache path "pbkdf2/0.1.0:$pkg_id"
}

echo "=== 0. Checking required files ==="
for file in CMakeLists.txt conanfile.py conan-profiles/aarch64-linux-gnu conan-profiles/x86_64-w64-mingw32; do
  if [ ! -f "$file" ]; then
    echo "Error: Required file '$file' not found!"
    exit 1
  fi
done

conan profile detect --force

echo "=== 1. Native Linux x86_64 build (default) ==="
conan create . --build=missing

echo "=== 2. Verifying native package contents and CLI ==="
PKG_DIR=$(get_package_dir "os=Linux and arch=x86_64")

"$PKG_DIR/bin/derive_key" --version
"$PKG_DIR/bin/derive_key" "secret_password" --iter 100

echo "=== 3. Cross-compiling for Linux ARM64 (aarch64) ==="
conan create . -pr:h=conan-profiles/aarch64-linux-gnu -pr:b=default --build=missing

ARM_PKG_DIR=$(get_package_dir "arch=armv8 and os=Linux")
file "$ARM_PKG_DIR/bin/derive_key" | grep -q "ARM aarch64"

echo "=== 4. Cross-compiling for Windows x86_64 (MinGW) ==="
conan create . -pr:h=conan-profiles/x86_64-w64-mingw32 -pr:b=default --build=missing

WIN_PKG_DIR=$(get_package_dir "os=Windows and arch=x86_64")
file "$WIN_PKG_DIR/bin/derive_key.exe" | grep -q "PE32+ executable"

if x86_64-w64-mingw32-objdump -p "$WIN_PKG_DIR/bin/derive_key.exe" | grep -E "libstdc\+\+|libgcc_s|libwinpthread"; then
  echo "Error: derive_key.exe still depends on MinGW runtime DLLs!"
  exit 1
fi

echo "=== ALL CHECKS PASSED SUCCESSFULLY ==="
