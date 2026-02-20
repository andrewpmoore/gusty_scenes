#!/bin/bash

# Directory to process
TARGET_DIR="scenes"
SRC_DIR="$TARGET_DIR/src"

# Create src directory if it doesn't exist
mkdir -p "$SRC_DIR"

echo "Starting optimization of PNG files in $TARGET_DIR..."

for f in "$TARGET_DIR"/*.png; do
    # Skip if no png files found
    [ -e "$f" ] || continue
    
    # Skip files already in src (just in case)
    if [[ "$f" == *"manchester_old.png"* ]]; then 
        echo "Skipping $f"
        continue
    fi

    filename=$(basename "$f")
    base="${filename%.*}"
    
    echo "Processing $filename..."

    # 1. Despill (Remove green fringes)
    magick "$f" -channel G -fx "p.g > (p.r+p.b)/1.8 ? (p.r+p.b)/1.8 : p.g" "$TARGET_DIR/${base}-clean.png"
    
    # 2. Quantize (Reduce color depth/noise)
    pngquant --quality 65-80 --speed 1 --ext -quant.png "$TARGET_DIR/${base}-clean.png"
    
    # 3. Convert to WebP (High efficiency)
    cwebp -q 75 -m 6 -mt -alpha_q 100 "$TARGET_DIR/${base}-clean-quant.png" -o "$TARGET_DIR/${base}.webp"
    
    # 4. Cleanup temporary files
    rm "$TARGET_DIR/${base}-clean.png" "$TARGET_DIR/${base}-clean-quant.png"
    
    # 5. Move original to src
    mv "$f" "$SRC_DIR/"
    
    echo "Done: ${base}.webp"
done

echo "Optimization complete. Originals moved to $SRC_DIR."
