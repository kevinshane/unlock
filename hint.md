# For errors look in dmesg for:
  - BAR3 mapped
  - Magic Found
  - Key Found
  - Failed to find ...
  - Invalid sign or blocks pointer
  - Generate signature
  - Signature does not match
  - Decrypted first block

# nvidia-smi Perf
  - P0/P1 - Maximum 3D performance
  - P2/P3 - Balanced 3D performance-power
  - P8 - Basic HD video playback
  - P10 - DVD playback
  - P12 - Minimum idle power consumption

# display total gpu memory capacity
`nvidia-smi --query-gpu=memory.total --format=csv | awk '/^memory/ {getline; print}' | awk '{print $1}'`