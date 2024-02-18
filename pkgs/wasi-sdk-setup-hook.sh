addWasiSDKHook() {
  export AR=@out@/bin/llvm-ar
  export CC=@out@/bin/clang
  export CC_FOR_BUILD=@cc_for_build@
  export CXX=@out@/bin/clang++
  export LD=@out@/bin/wasm-ld
  export NM=@out@/bin/llvm-nm
  export OBJCOPY=@out@/bin/llvm-objcopy
  export OBJDUMP=@out@/bin/llvm-objdump
  export RANLIB=@out@/bin/llvm-ranlib
  export SIZE=@out@/bin/llvm-size
  export STRINGS=@out@/bin/llvm-strings
  export STRIP=@out@/bin/llvm-strip
  export CONF_CC_OPTS_STAGE2="-Wno-error=int-conversion -Wno-error=strict-prototypes -Wno-error=implicit-function-declaration -O3 -fno-strict-aliasing -msimd128 -mnontrapping-fptoint -msign-ext -mbulk-memory -mmutable-globals -mmultivalue -mreference-types"
  export CONF_CXX_OPTS_STAGE2="-Wno-error=int-conversion -Wno-error=strict-prototypes -Wno-error=implicit-function-declaration -fno-exceptions -O3 -fno-strict-aliasing -msimd128 -mnontrapping-fptoint -msign-ext -mbulk-memory -mmutable-globals -mmultivalue -mreference-types"
  export CONF_GCC_LINKER_OPTS_STAGE2="-Wl,--compress-relocations,--error-limit=0,--growable-table,--keep-section=ghc_wasm_jsffi,--stack-first,--strip-debug"
  export CONF_CC_OPTS_STAGE1="-Wno-error=int-conversion -Wno-error=strict-prototypes -Wno-error=implicit-function-declaration -O3 -fno-strict-aliasing -msimd128 -mnontrapping-fptoint -msign-ext -mbulk-memory -mmutable-globals -mmultivalue -mreference-types"
  export CONF_CXX_OPTS_STAGE1="-Wno-error=int-conversion -Wno-error=strict-prototypes -Wno-error=implicit-function-declaration -fno-exceptions -O3 -fno-strict-aliasing -msimd128 -mnontrapping-fptoint -msign-ext -mbulk-memory -mmutable-globals -mmultivalue -mreference-types"
  export CONF_GCC_LINKER_OPTS_STAGE1="-Wl,--compress-relocations,--error-limit=0,--growable-table,--keep-section=ghc_wasm_jsffi,--stack-first,--strip-debug"
  export CONFIGURE_ARGS="--target=wasm32-wasi --with-intree-gmp --with-system-libffi"
}

addEnvHooks "$hostOffset" addWasiSDKHook
