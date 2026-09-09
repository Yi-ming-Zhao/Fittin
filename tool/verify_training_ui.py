"""Exercise the isolated QA app through accessible UI, using synthetic data."""
import os
from pathlib import Path
from playwright.sync_api import sync_playwright

out = Path('/tmp/fittin-redesign-visual')
out.mkdir(exist_ok=True)
with sync_playwright() as p:
    options = {'headless': True}
    if os.environ.get('FITTIN_CHROME'):
        options['executable_path'] = os.environ['FITTIN_CHROME']
    browser = p.chromium.launch(**options)
    page = browser.new_page(viewport={'width': 390, 'height': 844})
    page.goto('http://127.0.0.1:8791/?lang=zh&screen=free')
    page.wait_for_timeout(2000)
    page.get_by_role('button', name='Enable accessibility').evaluate('e=>e.click()')
    page.get_by_role('button', name='从动作库添加').click()
    page.wait_for_timeout(500)
    print(page.get_by_role('button').all_text_contents())
    page.get_by_role('button').filter(has_text='阿诺德推举').click()
    page.get_by_role('button', name='开始 / 继续自由训练').click()
    page.wait_for_timeout(1200)
    page.screenshot(path=str(out / 'free-dumbbell-recording.png'))
    print(page.locator('flt-semantics-host').inner_text())
    print(page.get_by_role('button').all_text_contents())
    page.get_by_role('button', name='增加重量', exact=True).click()
    page.get_by_role('button', name='记录当前组', exact=True).click()
    page.wait_for_timeout(300)
    page.get_by_role('button', name='记录当前组', exact=True).click()
    page.wait_for_timeout(300)
    page.get_by_role('button', name='记录当前组', exact=True).click()
    page.get_by_role('button', name='完成本次训练', exact=True).click()
    page.wait_for_timeout(400)
    print('CONCLUSION', page.locator('flt-semantics-host').inner_text())
    page.get_by_role('button', name='完成本次训练', exact=True).last.click()
    page.wait_for_timeout(800)
    print('AFTER SAVE', page.locator('flt-semantics-host').inner_text())
    page.goto('http://127.0.0.1:8791/?lang=zh&screen=advanced')
    page.wait_for_timeout(1600)
    page.get_by_role('button', name='Enable accessibility').evaluate('e=>e.click()')
    print('HISTORY', page.locator('flt-semantics-host').inner_text()[:6000])
    page.screenshot(path=str(out / 'free-history-analytics.png'))
    browser.close()
