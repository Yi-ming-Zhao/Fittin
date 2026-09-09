"""Regenerate the bundled font from app copy while retaining old codepoints."""
from pathlib import Path
from fontTools import subset
from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parent.parent
source = ROOT / 'assets/fonts/NotoSansSC-Regular.ttf'
target = ROOT / 'assets/fonts/NotoSansSC-AppSubset.ttf'
previous = TTFont(target)
codepoints = set(previous.getBestCmap())
previous.close()
for directory, pattern in [('lib', '*.dart'), ('assets/plans', '*.json'),
                           ('assets/exercises', '*.json'), ('assets/guides', '*.md')]:
    for path in (ROOT / directory).rglob(pattern):
        if path.name.endswith(('.g.dart', '.freezed.dart')):
            continue
        codepoints.update(map(ord, path.read_text(encoding='utf-8')))
font = TTFont(source)
available = set(font.getBestCmap())
options = subset.Options()
options.layout_features = ['*']
subsetter = subset.Subsetter(options=options)
subsetter.populate(unicodes=codepoints & available)
subsetter.subset(font)
font.save(target)
print(f'Kept {len(codepoints & available)} codepoints; {target.stat().st_size} bytes')
