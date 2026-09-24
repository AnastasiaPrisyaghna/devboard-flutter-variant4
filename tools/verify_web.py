"""Capture factual Web evidence from a real Flutter Web build in GitHub Actions.

Requires a web server at http://127.0.0.1:8080 and `pip install playwright`,
`python -m playwright install chromium`. This script does not simulate a screenshot.
"""

import json
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

from playwright.sync_api import sync_playwright

BASE_URL = 'http://127.0.0.1:8080/'
OUTPUT = Path('evidence')
OUTPUT.mkdir(parents=True, exist_ok=True)


def wait_for_server(timeout_seconds=45):
    end = time.monotonic() + timeout_seconds
    while time.monotonic() < end:
        try:
            with urllib.request.urlopen(BASE_URL, timeout=2) as response:
                if response.status == 200:
                    return
        except (OSError, urllib.error.URLError):
            time.sleep(1)
    raise RuntimeError(f'Web server did not start at {BASE_URL}')


def main():
    wait_for_server()
    notes = [
        {'id': 'web-ci-1', 'text': 'Практична робота №1 — Web',
         'createdAt': '2026-09-24T12:00:00.000Z'},
        {'id': 'web-ci-2', 'text': 'Перевірка localStorage',
         'createdAt': '2026-09-24T12:01:00.000Z'},
        {'id': 'web-ci-3', 'text': 'LocalePort — Chrome',
         'createdAt': '2026-09-24T12:02:00.000Z'},
    ]
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True)
        context = browser.new_context(
            locale='uk-UA', viewport={'width': 1440, 'height': 900},
            device_scale_factor=1,
        )
        page = context.new_page()
        errors = []
        page.on('pageerror', lambda error: errors.append(str(error)))
        page.goto(BASE_URL, wait_until='load', timeout=60000)
        page.wait_for_timeout(5000)
        page.screenshot(path=str(OUTPUT / 'web_initial_real.png'), full_page=True)
        page.evaluate(
            'notes => localStorage.setItem("devboard_notes", JSON.stringify(notes))',
            notes,
        )
        page.reload(wait_until='load', timeout=60000)
        page.wait_for_timeout(7000)
        assert page.locator('flutter-view').count() >= 1, (
            'Flutter view is not present in the rendered page'
        )
        actual = page.evaluate(
            'JSON.parse(localStorage.getItem("devboard_notes"))'
        )
        assert actual == notes, 'Stored notes differ from expected notes'
        page.screenshot(path=str(OUTPUT / 'web_notes_real.png'), full_page=True)

        # Open a second page in the same browser context to verify origin-local
        # persistence across navigation, without merely asserting in-memory state.
        reopened = context.new_page()
        reopened.goto(BASE_URL, wait_until='load', timeout=60000)
        reopened.wait_for_timeout(6000)
        restored = reopened.evaluate(
            'JSON.parse(localStorage.getItem("devboard_notes"))'
        )
        assert restored == notes, 'localStorage did not persist across pages'
        reopened.screenshot(
            path=str(OUTPUT / 'web_reopen_real.png'), full_page=True,
        )
        if errors:
            raise RuntimeError('Uncaught browser errors: ' + '; '.join(errors))

        verification = {
            'verification_type': 'real_headless_browser_session',
            'utc_time': datetime.now(timezone.utc).isoformat(),
            'url': BASE_URL,
            'user_agent': reopened.evaluate('navigator.userAgent'),
            'browser_locale': reopened.evaluate('navigator.language'),
            'storage_key': 'devboard_notes',
            'stored_notes_count': len(restored),
            'same_origin_persistence': restored == notes,
            'flutter_view_present': reopened.locator('flutter-view').count() > 0,
            'browser_errors': errors,
            'limitations': (
                'Notes were seeded through browser localStorage; this is '
                'not a claim that the Add/Delete buttons were operated. '
                'Windows graphical desktop screenshots are not covered.'
            ),
        }
        (OUTPUT / 'web_localstorage_real.json').write_text(
            json.dumps(verification, ensure_ascii=False, indent=2) + '\n',
            encoding='utf-8',
        )
        (OUTPUT / 'devboard_notes_real.json').write_text(
            json.dumps(restored, ensure_ascii=False, indent=2) + '\n',
            encoding='utf-8',
        )
        context.close()
        browser.close()
    print('Web build started; Chrome rendered Flutter and retained 3 notes in localStorage.')


if __name__ == '__main__':
    main()
