# tools/generate_icons.py
from PIL import Image, ImageDraw
import os

# Icon sizes required for Android
sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

# Play Store icon
play_store_size = 512

# Source logo already has the correct #0075C9 blue background
logo_path = "assets/logo/logo.png"
output_base = "android/app/src/main/res"

def generate_icon(size, output_path):
    # Load source logo (already has blue background)
    logo = Image.open(logo_path).convert("RGBA")

    # Create a fresh blue background at target size
    background = Image.new("RGBA", (size, size), (0, 117, 201, 255))

    # Resize the logo to 80% of icon size to preserve padding
    logo_size = int(size * 0.8)
    logo_resized = logo.resize((logo_size, logo_size), Image.LANCZOS)

    # Center on background
    offset = (size - logo_size) // 2
    background.paste(logo_resized, (offset, offset), logo_resized)

    # Save as RGB PNG (no alpha needed for launcher icons)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    background.convert("RGB").save(output_path, "PNG")
    print(f"Generated: {output_path}  ({size}x{size}px)")

# Generate Android launcher icons
for folder, size in sizes.items():
    output_path = f"{output_base}/{folder}/ic_launcher.png"
    generate_icon(size, output_path)

# Generate Play Store icon
generate_icon(play_store_size, "assets/logo/play_store_icon.png")
print("\nDone! Play Store icon saved to assets/logo/play_store_icon.png")
