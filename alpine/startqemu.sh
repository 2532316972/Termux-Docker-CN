# 获取脚本所在目录并切换到该目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 确保共享目录存在
mkdir -p "$SCRIPT_DIR/shared"

qemu-system-x86_64 -machine q35 -m 11264 -smp cpus=8 -cpu qemu64 \
  -drive if=pflash,format=raw,read-only,file=$PREFIX/share/qemu/edk2-x86_64-code.fd \
  -netdev user,id=n1,hostfwd=tcp::6099-:6099,hostfwd=tcp::8807-:8807,hostfwd=tcp::5005-:5005,hostfwd=tcp::2222-:22,net=192.168.50.0/24 -device virtio-net,netdev=n1 \
  -virtfs local,path="$SCRIPT_DIR/shared",mount_tag=shared,security_model=none,id=shared \
  -nographic alpine.img
