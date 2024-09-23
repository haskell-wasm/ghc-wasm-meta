addWasiSDKHook() {
  export AR=@out@/bin/llvm-ar
  export CC=@out@/bin/wasm32-wasi-clang
  export CC_FOR_BUILD=@cc_for_build@
  export CXX=@out@/bin/wasm32-wasi-clang++
  export LD=@out@/bin/wasm-ld
  export NM=@out@/bin/llvm-nm
  export OBJCOPY=@out@/bin/llvm-objcopy
  export OBJDUMP=@out@/bin/llvm-objdump
  export RANLIB=@out@/bin/llvm-ranlib
  export SIZE=@out@/bin/llvm-size
  export STRINGS=@out@/bin/llvm-strings
  export STRIP=@out@/bin/llvm-strip
  export CONF_CC_OPTS_STAGE2="-fno-strict-aliasing -Wno-error=int-conversion -O3 -msimd128 -mnontrapping-fptoint -msign-ext -mbulk-memory -mmutable-globals -mmultivalue -mreference-types"
  export CONF_CXX_OPTS_STAGE2="-fno-exceptions -fno-strict-aliasing -Wno-error=int-conversion -O3 -msimd128 -mnontrapping-fptoint -msign-ext -mbulk-memory -mmutable-globals -mmultivalue -mreference-types"
  export CONF_GCC_LINKER_OPTS_STAGE2="-Wl,--error-limit=0,--keep-section=ghc_wasm_jsffi,--keep-section=target_features,--stack-first,--strip-all"
  export CONF_CC_OPTS_STAGE1=$CONF_CC_OPTS_STAGE2
  export CONF_CXX_OPTS_STAGE1=$CONF_CXX_OPTS_STAGE2
  export CONF_GCC_LINKER_OPTS_STAGE1=$CONF_GCC_LINKER_OPTS_STAGE2
  export CONFIGURE_ARGS="--target=wasm32-wasi --with-intree-gmp --with-system-libffi"
}

addEnvHooks "$hostOffset" addWasiSDKHook
