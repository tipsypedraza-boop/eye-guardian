#!/usr/bin/env python3
"""Create ICO file from PNG"""

try:
    from PIL import Image
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
    print("Error: Pillow not installed")
    print("Install: pip install Pillow")
    exit(1)

# Load PNG and save as ICO
img = Image.open('src-tauri/icons/128x128.png')
img.save('src-tauri/icons/icon.ico', format='ICO', sizes=[(32, 32), (64, 64), (128, 128), (256, 256)])
print("✅ Created icon.ico")

# For macOS (just copy for now, proper ICNS needs special tools)
img.save('src-tauri/icons/icon.icns', format='PNG')
print("✅ Created icon.icns (as PNG)")
