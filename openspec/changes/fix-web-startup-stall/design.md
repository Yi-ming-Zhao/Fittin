## Context

The production app uses Flutter's CanvasKit renderer and a static HTML launch layer that is removed on `flutter-first-frame`. The deployed Ubuntu nginx MIME table does not recognize `.wasm`, so CanvasKit is delivered as `application/octet-stream`; Chromium refuses `WebAssembly.compileStreaming`, Flutter never creates a view, and the launch layer remains indefinitely. The current nginx file groups WASM with other cached assets, making a dedicated media-type location the narrowest safe correction.

## Goals / Non-Goals

**Goals:**

- Make CanvasKit executable on the current Alibaba Cloud nginx version.
- Preserve versioned deployment, cache policy, gzip-static delivery, and security headers.
- Replace an infinite launch animation with a bounded, localized recovery state when no Flutter first frame appears.
- Detect future regressions before deployment and at the real public browser boundary.

**Non-Goals:**

- Change the Flutter renderer, backend APIs, authentication flow, or stored data.
- Reintroduce a Cloudflare Tunnel or migrate the public host.
- Treat a slow network as a failure before giving the release bundle a reasonable startup window.

## Decisions

1. Add dedicated regex locations for fingerprinted and mutable `.wasm` assets with `default_type application/wasm`. This is preferred over a server-level `types` block because a partial `types` block would replace inherited MIME mappings for unrelated assets on older nginx installations.
2. Keep the existing immutable/one-hour cache split and `gzip_static` behavior. Only the response media type changes.
3. Let the launch page enter an error state after 30 seconds or immediately after an uncaught bootstrap/WebAssembly failure. A visible reload button performs a normal navigation reload, which also gives the browser another chance to activate the latest Service Worker.
4. Add a repository script that asserts the deployment template has a dedicated WASM media type and that the HTML contains first-frame cleanup plus failure recovery. The production browser smoke test remains authoritative because nginx behavior cannot be proven from static parsing alone.

## Risks / Trade-offs

- [Very slow first load reaches the 30-second recovery state] -> Keep the animation visible and allow reload; first-frame still removes the entire layer if Flutter succeeds after the message appears.
- [Regex precedence accidentally applies the generic asset location first] -> Place dedicated WASM locations before broader static-asset regexes and cover ordering in the regression script.
- [A Service Worker retains an older shell during rollout] -> Keep bootstrap and service worker entrypoints non-cacheable, then test both a fresh tab and the affected browser session after deployment.

## Migration Plan

1. Validate the updated nginx template and regression guard locally.
2. Install the template on Alibaba Cloud, run `sudo nginx -t`, and reload only after success.
3. Verify `.wasm` returns `application/wasm`, then confirm Flutter produces a first frame at 390x844.
4. Roll back the nginx configuration to its timestamped backup if config validation or browser verification fails.

## Open Questions

None.
