#!/bin/bash
# Genera Assets.xcassets dagli asset legacy. Idempotente: rigenerabile da zero.
set -euo pipefail
shopt -s nullglob

LEGACY="../Woo Woo The Game/Resources"
OUT="Resources/Assets.xcassets"
rm -rf "$OUT" Resources/Audio Resources/Fonts
mkdir -p "$OUT" Resources/Audio Resources/Fonts

cat > "$OUT/Contents.json" <<'EOF'
{ "info": { "author": "xcode", "version": 1 } }
EOF

imageset() {  # $1 = nome imageset, $2 = file 2x, [$3 = file 1x]
  local name="$1" twox="$2" onex="${3:-}"
  local dir="$OUT/$name.imageset"
  mkdir -p "$dir"
  cp "$twox" "$dir/$(basename "$twox")"
  local images="{ \"filename\": \"$(basename "$twox")\", \"idiom\": \"universal\", \"scale\": \"2x\" }"
  if [[ -n "$onex" ]]; then
    cp "$onex" "$dir/$(basename "$onex")"
    images="$images, { \"filename\": \"$(basename "$onex")\", \"idiom\": \"universal\", \"scale\": \"1x\" }"
  fi
  printf '{ "images": [ %s ], "info": { "author": "xcode", "version": 1 } }\n' "$images" > "$dir/Contents.json"
}

# 1. Sprites di animazione: tutte le sottocartelle di sprites/, solo i file -hd
while read -r f; do
  base="$(basename "$f" -hd.png)"
  imageset "$base" "$f"
done < <(find "$LEGACY/sprites" -name '*-hd.png')

# 2. GamePlay: preferisci -iphone5hd, fallback -hd
for f in "$LEGACY/GamePlay/"*-iphone5hd.png; do
  [[ -e "$f" ]] || continue
  imageset "$(basename "$f" -iphone5hd.png)" "$f"
done
for f in "$LEGACY/GamePlay/"*-hd.png; do
  [[ -e "$f" ]] || continue
  base="$(basename "$f" -hd.png)"
  [[ -d "$OUT/$base.imageset" ]] || imageset "$base" "$f"
done

# 3. Pulsanti: -hd come 2x; senza -hd come 2x singolo
for f in "$LEGACY/pulsanti/"*-hd.png; do
  [[ -e "$f" ]] || continue
  base="$(basename "$f" -hd.png)"
  [[ "$base" == "btn_label" ]] && continue   # gestito sotto via root @2x
  imageset "$base" "$f"
done
for f in "$LEGACY/pulsanti/"*.png; do
  [[ -e "$f" ]] || continue
  [[ "$f" == *-hd.png ]] && continue
  base="$(basename "$f" .png)"
  [[ -d "$OUT/$base.imageset" ]] || imageset "$base" "$f"
done

# 4. Tutorial (preferisci iphone5hd), selfie, root
for f in "$LEGACY/tutorial/"*-iphone5hd.png; do
  [[ -e "$f" ]] || continue
  imageset "$(basename "$f" -iphone5hd.png)" "$f"
done
for f in "$LEGACY/selfie/"*.png; do
  [[ -e "$f" ]] || continue
  imageset "$(basename "$f" .png)" "$f"
done
imageset "splashscreeniPhone5" "$LEGACY/splashscreeniPhone5-iphone5hd.png"
imageset "woowoothegame_titolo" "$LEGACY/woowoothegame_titolo.png"
imageset "btn_label" "$LEGACY/btn_label@2x.png" "$LEGACY/btn_label.png"
imageset "spada" "$LEGACY/spada.png"
imageset "riga_pattern" "$LEGACY/riga_pattern.png"

# 5. Audio e font
# Soundlist.txt escluso di proposito (manifest dev, non asset)
cp "$LEGACY/audio/"*.mp3 Resources/Audio/
cp "$LEGACY/fonts/"*.ttf Resources/Fonts/

# 6. AppIcon dalla 1024
mkdir -p "$OUT/AppIcon.appiconset"
cp "$LEGACY/App-ico/AppIco1024.png" "$OUT/AppIcon.appiconset/AppIco1024.png"
cat > "$OUT/AppIcon.appiconset/Contents.json" <<'EOF'
{ "images": [ { "filename": "AppIco1024.png", "idiom": "universal", "platform": "ios", "size": "1024x1024" } ],
  "info": { "author": "xcode", "version": 1 } }
EOF

echo "Imageset generati: $(ls -d "$OUT"/*.imageset 2>/dev/null | wc -l | tr -d ' ') (+ AppIcon)"
