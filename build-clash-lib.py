#!/usr/bin/python3
import os
import sys
import platform

if __name__ == "__main__":
    os.chdir("clash")
    os.environ["CGO_ENABLED"] = "1"
    output = "libclash"
    if sys.platform == 'win32':
        output += ".dll"
    elif sys.platform == "darwin":
        output += ".dylib"
    else:
        output += ".so"
    processor = platform.processor()
    if "arm" in processor or "Apple" in processor:
        print("[warn] arm/Apple also compiles out amd64 target")
        os.environ["GOARCH"] = "amd64"
    os.system(f"go build -buildmode=c-shared -o {output}")

    os.chdir("..")
