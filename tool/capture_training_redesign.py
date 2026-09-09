"""Render isolated synthetic Flutter QA routes; never access real user data."""
import json
import os
from pathlib import Path
from playwright.sync_api import sync_playwright

OUTPUT = Path('/tmp/fittin-redesign-visual')
OUTPUT.mkdir(exist_ok=True)
with sync_playwright() as p:
    options = {'headless': True}
    if os.environ.get('FITTIN_CHROME'):
        options['executable_path'] = os.environ['FITTIN_CHROME']
    browser = p.chromium.launch(**options)
    for name, query, width, height in [
        ('anatomy-dark', 'screen=anatomy', 390, 844),
        ('anatomy-light', 'screen=anatomy&theme=porcelainInk', 390, 844),
        ('home-phone', 'tab=0', 390, 844),
        ('home-narrow', 'tab=0', 320, 568),
        ('library-phone', 'screen=library', 390, 844),
        ('free-phone', 'screen=free', 390, 844),
        ('cardio-phone', 'screen=cardio', 390, 844),
        ('profile-phone', 'tab=5', 390, 844),
        ('body-long', 'tab=4', 390, 926),
        ('plans-phone', 'tab=1', 390, 844),
        ('agent-phone', 'tab=2', 390, 844),
        ('pr-phone', 'tab=3', 390, 844),
        ('cardio-library', 'screen=cardio-library', 320, 568),
        ('cardio-editor', 'screen=cardio-editor', 390, 844),
        ('exercise-editor', 'screen=exercise-editor', 390, 844),
        ('palettes', 'screen=palettes', 390, 844),
        ('palette-editor', 'screen=palette-editor', 320, 568),
        ('agent-settings', 'screen=agent-settings', 390, 844),
        ('about', 'screen=about', 390, 844),
        ('plan-editor', 'screen=plan-editor', 390, 844),
        ('preferences', 'screen=preferences', 390, 844),
        ('home-desktop', 'tab=0&lang=en', 1200, 900),
        *[(f'anatomy-{theme}', f'screen=anatomy&theme={theme}', 390, 844)
          for theme in ['midnightCobalt', 'bordeauxVelvet', 'espressoEmber',
                        'graphiteOrchid', 'inkSaffron', 'oliveManuscript']],
    ]:
        page = browser.new_page(viewport={'width': width, 'height': height}, device_scale_factor=2)
        errors = []
        page.on('pageerror', lambda error: errors.append(str(error)))
        page.goto('http://127.0.0.1:8791/?' + ('' if 'lang=' in query else 'lang=zh&') + query)
        page.wait_for_load_state('networkidle')
        page.locator('flutter-view').wait_for(state='visible')
        page.wait_for_timeout(1500)
        page.screenshot(path=str(OUTPUT / (name + '.png')), full_page=True)
        print(json.dumps({'name': name, 'errors': errors}, ensure_ascii=False))
        page.close()
    browser.close()
