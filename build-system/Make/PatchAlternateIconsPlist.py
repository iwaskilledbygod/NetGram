#!/usr/bin/env python3
"""Inject UIPrerenderedIcon=true into every alternate icon entry of the IPA's
Info.plist so iOS keeps white alternate icons white in dark home-screen mode
(same effect as the static entries shipped by the official Telegram app)."""
import os
import plistlib
import shutil
import subprocess
import sys
import tempfile


def main(ipa_path):
    tmp = tempfile.mkdtemp()
    try:
        subprocess.run(["ditto", "-x", "-k", ipa_path, tmp], check=True)
        plist_path = os.path.join(tmp, "Payload", "Telegram.app", "Info.plist")
        with open(plist_path, "rb") as f:
            data = plistlib.load(f)
        patched = 0
        for icons_key in ("CFBundleIcons", "CFBundleIcons~ipad"):
            icons = data.get(icons_key)
            if not isinstance(icons, dict):
                continue
            alts = icons.get("CFBundleAlternateIcons")
            if not isinstance(alts, dict):
                continue
            for entry in alts.values():
                if isinstance(entry, dict):
                    entry["UIPrerenderedIcon"] = True
                    patched += 1
        with open(plist_path, "wb") as f:
            plistlib.dump(data, f, fmt=plistlib.FMT_BINARY)
        patched_ipa = ipa_path + ".patched"
        if os.path.exists(patched_ipa):
            os.remove(patched_ipa)
        subprocess.run(
            ["zip", "-qry", os.path.abspath(patched_ipa), "Payload"],
            cwd=tmp,
            check=True,
        )
        os.replace(patched_ipa, ipa_path)
        print(f"UIPrerenderedIcon set on {patched} alternate icon entries")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main(sys.argv[1])
