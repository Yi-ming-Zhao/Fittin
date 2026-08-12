## Why

The production Flutter Web app can remain on the launch screen forever because the Alibaba Cloud nginx host serves CanvasKit WebAssembly as `application/octet-stream`. Browsers reject that response during WebAssembly compilation, so the Flutter engine never emits its first frame and users receive no recovery action.

## What Changes

- Serve every production `.wasm` asset with the required `application/wasm` media type while preserving the existing cache and security-header policy.
- Turn the static Web launch screen into a bounded startup state that reports a localized failure and offers a reload action when Flutter cannot produce a first frame.
- Add repository-owned regression checks for the nginx MIME contract and launch-screen failure recovery.
- Verify a clean and an update-affected browser session at phone dimensions after deployment.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `web-public-deployment`: Require executable WebAssembly media types and a recoverable bounded launch experience as part of public first-load verification.

## Impact

Affected surfaces are `deploy/nginx/fittin.hammerscholar.net.conf`, `web/index.html`, deployment documentation, Web regression tests, and the live Alibaba Cloud nginx configuration. Backend APIs, stored training data, and Android behavior are unchanged.
