#!/usr/bin/env python3
"""Replace the word Telegram with NetGram in .string VALUES only (keys untouched)."""
import glob
import re
import sys

FILES = [
    'Telegram/Telegram-iOS/en.lproj/Localizable.strings',
    'Telegram/Share/en.lproj/Localizable.strings',
    'Telegram/WidgetKitWidget/en.lproj/Localizable.strings',
] + sorted(glob.glob('Telegram/Telegram-iOS/*.lproj/InfoPlist.strings'))

# Entry line:  "Key" = "Value";
LINE_RE = re.compile(r'^(\s*"(?:[^"\\]|\\.)*"\s*=\s*")((?:[^"\\]|\\.)*)("\s*;?\s*)$')

total = 0
for path in FILES:
    try:
        with open(path, encoding='utf-8') as f:
            lines = f.readlines()
    except FileNotFoundError:
        continue
    changed = 0
    out = []
    for line in lines:
        m = LINE_RE.match(line)
        if m and 'Telegram' in m.group(2):
            value = m.group(2).replace('Telegram', 'NetGram')
            line = m.group(1) + value + m.group(3) + ('\n' if not line.endswith('\n') else '')
            changed += 1
        out.append(line)
    if changed:
        with open(path, 'w', encoding='utf-8') as f:
            f.writelines(out)
    print('%-60s %d values replaced' % (path, changed))
    total += changed
print('TOTAL:', total)
