#!/usr/bin/env python3
"""Validate bundle IDs, provisioning profiles, signatures, and shared entitlements in an IPA."""

import fnmatch
import json
import os
import plistlib
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import PurePosixPath


APP_GROUPS_KEY = 'com.apple.security.application-groups'
APPLICATION_ID_KEY = 'application-identifier'
KEYCHAIN_GROUPS_KEY = 'keychain-access-groups'
TEAM_ID_KEY = 'com.apple.developer.team-identifier'
CORE_EXTENSION_SUFFIXES = (
    '.Share',
    '.NotificationContent',
    '.NotificationService',
    '.SiriIntents',
    '.Widget',
    '.BroadcastUpload',
)
WATCH_APP_SUFFIX = '.watchkitapp'
WATCH_EXTENSION_SUFFIX = '.watchkitapp.watchkitextension'


class ValidationError(Exception):
    pass


def run(command):
    result = subprocess.run(command, capture_output=True)
    if result.returncode != 0:
        detail = (result.stderr or result.stdout).decode(errors='replace').strip()
        raise ValidationError('{} failed: {}'.format(' '.join(command), detail))
    return result.stdout, result.stderr


def read_signed_entitlements(bundle_path):
    stdout, stderr = run(['codesign', '-d', '--entitlements', ':-', bundle_path])
    output = stdout + b'\n' + stderr
    for match in re.finditer(rb'<plist\b.*?</plist>', output, flags=re.DOTALL):
        try:
            value = plistlib.loads(match.group(0))
        except Exception:
            continue
        if isinstance(value, dict):
            return value
    raise ValidationError('No readable signed entitlements in {}'.format(bundle_path))


def read_profile(profile_path):
    stdout, _ = run(['security', 'cms', '-D', '-i', profile_path])
    try:
        value = plistlib.loads(stdout)
    except Exception as error:
        raise ValidationError('Cannot decode {}: {}'.format(profile_path, error))
    if not isinstance(value, dict):
        raise ValidationError('Provisioning profile is not a plist: {}'.format(profile_path))
    return value


def verify_signature(bundle_path):
    run(['codesign', '--verify', '--deep', '--strict', bundle_path])


def safe_extract(archive, destination):
    root = os.path.realpath(destination)
    for entry in archive.infolist():
        name = entry.filename.replace('\\', '/')
        path = PurePosixPath(name)
        target = os.path.realpath(os.path.join(root, *path.parts))
        if path.is_absolute() or '..' in path.parts or (target != root and not target.startswith(root + os.sep)):
            raise ValidationError('Unsafe path in IPA: {}'.format(entry.filename))
        archive.extract(entry, root)
        mode = entry.external_attr >> 16
        if mode:
            os.chmod(target, mode)


def bundle_identifier(bundle_path):
    info_path = os.path.join(bundle_path, 'Info.plist')
    try:
        with open(info_path, 'rb') as file:
            info = plistlib.load(file)
    except Exception as error:
        raise ValidationError('Cannot read {}: {}'.format(info_path, error))
    identifier = info.get('CFBundleIdentifier') if isinstance(info, dict) else None
    if not isinstance(identifier, str) or not identifier:
        raise ValidationError('Missing CFBundleIdentifier in {}'.format(bundle_path))
    return identifier


def profile_application_identifier(profile, bundle_path, expected_identifier, team_id):
    profile_entitlements = profile.get('Entitlements', {})
    profile_app_id = profile_entitlements.get(APPLICATION_ID_KEY)
    if not isinstance(profile_app_id, str):
        raise ValidationError('{} profile has no application-identifier'.format(bundle_path))

    profile_teams = profile.get('TeamIdentifier', [])
    if not isinstance(profile_teams, list) or team_id not in profile_teams:
        raise ValidationError('{} profile does not list team {}'.format(bundle_path, team_id))

    prefixes = profile.get('ApplicationIdentifierPrefix', [])
    if not isinstance(prefixes, list) or not prefixes:
        raise ValidationError('{} profile has no ApplicationIdentifierPrefix'.format(bundle_path))
    matching_ids = [
        '{}.{}'.format(prefix, expected_identifier)
        for prefix in prefixes
        if isinstance(prefix, str) and fnmatch.fnmatchcase('{}.{}'.format(prefix, expected_identifier), profile_app_id)
    ]
    if not matching_ids:
        raise ValidationError('{} profile application-identifier {} does not allow {}'.format(
            bundle_path, profile_app_id, expected_identifier))
    return matching_ids[0]


def entitlement_values(entitlements, key, bundle_path):
    values = entitlements.get(key, [])
    if not isinstance(values, list) or any(not isinstance(value, str) for value in values):
        raise ValidationError('{} has invalid {} entitlement'.format(bundle_path, key))
    return values


def validate_group_entitlement(bundle_path, profile_entitlements, signed_entitlements, key, expected_group=None):
    profile_groups = entitlement_values(profile_entitlements, key, bundle_path)
    signed_groups = entitlement_values(signed_entitlements, key, bundle_path)

    for group in signed_groups:
        if not any(fnmatch.fnmatchcase(group, allowed) for allowed in profile_groups):
            raise ValidationError('{} signature requests {} group {}, which its profile does not allow'.format(
                bundle_path, key, group))

    if expected_group is not None:
        if not any(fnmatch.fnmatchcase(expected_group, allowed) for allowed in profile_groups):
            raise ValidationError('{} profile does not allow {} group {}'.format(bundle_path, key, expected_group))
        if expected_group not in signed_groups:
            raise ValidationError('{} signature is missing {} group {}'.format(bundle_path, key, expected_group))


def validate_bundle(bundle_path, expected_identifier, team_id, expected_app_group=None,
                    profile=None):
    actual_identifier = bundle_identifier(bundle_path)
    if actual_identifier != expected_identifier:
        raise ValidationError('{} has bundle ID {}, expected {}'.format(bundle_path, actual_identifier, expected_identifier))

    profile_path = os.path.join(bundle_path, 'embedded.mobileprovision')
    if not os.path.isfile(profile_path):
        raise ValidationError('Missing embedded provisioning profile in {}'.format(bundle_path))
    if profile is None:
        profile = read_profile(profile_path)
    profile_entitlements = profile.get('Entitlements', {})
    if not isinstance(profile_entitlements, dict):
        raise ValidationError('{} profile has invalid entitlements'.format(bundle_path))
    expected_app_id = profile_application_identifier(profile, bundle_path, expected_identifier, team_id)

    signed_entitlements = read_signed_entitlements(bundle_path)
    signed_app_id = signed_entitlements.get(APPLICATION_ID_KEY)
    if signed_app_id != expected_app_id:
        raise ValidationError('{} signed application-identifier is {}, expected {}'.format(bundle_path, signed_app_id, expected_app_id))
    # Fake-signing may omit com.apple.developer.team-identifier from the main
    # app's signature; extensions carry it from the profile. Enforce only when
    # the entitlement is present.
    if TEAM_ID_KEY in signed_entitlements and signed_entitlements.get(TEAM_ID_KEY) != team_id:
        raise ValidationError('{} signed team identifier is {}, expected {}'.format(
            bundle_path, signed_entitlements.get(TEAM_ID_KEY), team_id))

    validate_group_entitlement(bundle_path, profile_entitlements, signed_entitlements,
                               APP_GROUPS_KEY, expected_app_group)
    # The templates do not request keychain-access-groups; the default access
    # group applies. Any group that is signed must still be allowed by the
    # embedded profile.
    validate_group_entitlement(bundle_path, profile_entitlements, signed_entitlements,
                               KEYCHAIN_GROUPS_KEY)
    verify_signature(bundle_path)
    print('Validated {} ({})'.format(os.path.basename(bundle_path), actual_identifier))
    return expected_app_id


def validate_ipa(ipa_path, configuration_path):
    with open(configuration_path, encoding='utf-8') as file:
        configuration = json.load(file)
    bundle_id = configuration['bundle_id']
    team_id = configuration['team_id']
    app_group = 'group.' + bundle_id

    work = tempfile.mkdtemp(prefix='netgram-ipa-check-')
    try:
        with zipfile.ZipFile(ipa_path) as archive:
            safe_extract(archive, work)
        payload_path = os.path.join(work, 'Payload')
        if not os.path.isdir(payload_path):
            raise ValidationError('IPA does not contain a Payload directory')
        apps = [os.path.join(payload_path, name) for name in os.listdir(payload_path)
                if name.endswith('.app') and os.path.isdir(os.path.join(payload_path, name))]
        if len(apps) != 1:
            raise ValidationError('Expected one app in Payload, found {}'.format(len(apps)))
        app_path = apps[0]
        app_profile_path = os.path.join(app_path, 'embedded.mobileprovision')
        if not os.path.isfile(app_profile_path):
            raise ValidationError('Missing embedded provisioning profile in {}'.format(app_path))
        app_profile = read_profile(app_profile_path)
        validate_bundle(app_path, bundle_id, team_id, app_group, app_profile)

        found_suffixes = set()
        extension_paths = []
        for root, directories, _ in os.walk(app_path):
            directories[:] = [name for name in directories if name.endswith('.appex') or not name.endswith('.app')]
            for name in directories:
                if name.endswith('.appex'):
                    extension_paths.append(os.path.join(root, name))

        for extension_path in extension_paths:
            identifier = bundle_identifier(extension_path)
            suffix = identifier[len(bundle_id):] if identifier.startswith(bundle_id) else ''
            if suffix not in CORE_EXTENSION_SUFFIXES and suffix != WATCH_EXTENSION_SUFFIX:
                raise ValidationError('Unexpected extension bundle ID {}'.format(identifier))
            if suffix in found_suffixes:
                raise ValidationError('Duplicate extension bundle ID {}'.format(identifier))
            found_suffixes.add(suffix)
            if suffix in CORE_EXTENSION_SUFFIXES:
                # Extensions need the shared App Group, but the source does not
                # grant them the host app's Keychain access group.
                validate_bundle(extension_path, identifier, team_id, app_group)
            else:
                validate_bundle(extension_path, identifier, team_id)

        missing = set(CORE_EXTENSION_SUFFIXES) - found_suffixes
        if missing:
            raise ValidationError('Missing expected extensions: {}'.format(', '.join(sorted(missing))))

        watch_apps = []
        for root, directories, _ in os.walk(app_path):
            for name in directories:
                nested_path = os.path.join(root, name)
                if name.endswith('.app') and os.path.realpath(nested_path) != os.path.realpath(app_path):
                    watch_apps.append(nested_path)
        if len(watch_apps) > 1:
            raise ValidationError('Expected at most one nested Watch app, found {}'.format(len(watch_apps)))
        for watch_app in watch_apps:
            identifier = bundle_identifier(watch_app)
            if identifier != bundle_id + WATCH_APP_SUFFIX:
                raise ValidationError('Unexpected nested app bundle ID {}'.format(identifier))
            validate_bundle(watch_app, identifier, team_id)

        print('IPA validation passed: {} and {} core extensions'.format(bundle_id, len(CORE_EXTENSION_SUFFIXES)))
    finally:
        shutil.rmtree(work, ignore_errors=True)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Usage: ValidateIPA.py <Telegram.ipa> <appstore-configuration.json>', file=sys.stderr)
        sys.exit(2)
    try:
        validate_ipa(sys.argv[1], sys.argv[2])
    except (ValidationError, KeyError, OSError, zipfile.BadZipFile) as error:
        print('IPA validation failed: {}'.format(error), file=sys.stderr)
        sys.exit(1)
