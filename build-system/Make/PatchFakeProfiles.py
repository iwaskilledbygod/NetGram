import os
import sys
import plistlib
import argparse
import subprocess
import tempfile

# Rewrites fake provisioning profiles for a custom bundle_id:
# decrypts each .mobileprovision, replaces the old bundle id with the
# configured one, and re-signs the CMS with the self-signed certificate
# so that openssl smime -verify (used by BuildConfiguration.py) accepts it.

OLD_BUNDLE_ID = 'ph.telegra.Telegraph'


def run(args, input_bytes=None):
    proc = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = proc.communicate(input_bytes)
    if proc.returncode != 0:
        print('Command failed: {}\\n{}'.format(' '.join(args), err.decode(errors='replace')))
        sys.exit(1)
    return out


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--path', required=True, help='fake-codesigning directory')
    parser.add_argument('--bundleId', required=True, help='new bundle id')
    args = parser.parse_args()

    profiles_path = os.path.join(args.path, 'profiles')
    p12_path = os.path.join(args.path, 'certs', 'SelfSigned.p12')

    if not os.path.isdir(profiles_path) or not os.path.isfile(p12_path):
        print('Missing profiles directory or SelfSigned.p12')
        sys.exit(1)

    pem_data = run(['openssl', 'pkcs12', '-in', p12_path, '-passin', 'pass:', '-nodes', '-legacy'])

    with tempfile.NamedTemporaryFile(delete=False, suffix='.pem') as f:
        f.write(pem_data)
        signer_path = f.name

    replaced = 0
    try:
        for file_name in os.listdir(profiles_path):
            if not file_name.endswith('.mobileprovision'):
                continue
            file_path = os.path.join(profiles_path, file_name)

            with open(file_path, 'rb') as f:
                original = f.read()

            # decrypt CMS -> plist xml bytes
            plist_bytes = run(['openssl', 'smime', '-verify', '-noverify', '-inform', 'DER', '-in', file_path, '-out', '-'])
            if OLD_BUNDLE_ID not in plist_bytes.decode(errors='replace'):
                continue

            new_plist = plist_bytes.replace(OLD_BUNDLE_ID.encode(), args.bundleId.encode())
            # re-serialize to normalize the plist
            plist_obj = plistlib.loads(new_plist)
            normalized = plistlib.dumps(plist_obj, fmt=plistlib.FMT_XML)

            signed = run(['openssl', 'smime', '-sign', '-nodetach', '-in', '-', '-signer', signer_path, '-outform', 'DER'], input_bytes=normalized)

            with open(file_path, 'wb') as f:
                f.write(signed)
            replaced += 1
            print('Rewrote {} -> {}'.format(file_name, args.bundleId))

        # verify all profiles parse correctly
        for file_name in os.listdir(profiles_path):
            if not file_name.endswith('.mobileprovision'):
                continue
            run(['openssl', 'smime', '-verify', '-noverify', '-inform', 'DER', '-in', os.path.join(profiles_path, file_name), '-out', os.devnull])
        print('All {} profiles rewritten and verified.'.format(replaced))
    finally:
        os.unlink(signer_path)


if __name__ == '__main__':
    main()
