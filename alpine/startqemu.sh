cd "$(dirname "$0")"
qemu-system-x86_64 -machine q35 -m 8192 -smp cpus=6 -cpu qemu64 \
  -drive if=pflash,format=raw,read-only=on,file=$PREFIX/share/qemu/edk2-x86_64-code.fd \
  -netdev user,id=n1,hostfwd=tcp::2222-:22,net=192.168.50.0/24\
  -device virtio-net,netdev=n1 \
  -nographic alpine.img
