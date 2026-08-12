## 1. Diagnose And Repair Startup

- [x] 1.1 Reproduce the public phone-sized startup stall and record the fatal browser evidence.
- [x] 1.2 Serve fingerprinted and mutable WebAssembly assets as `application/wasm` without weakening cache or security headers.
- [x] 1.3 Add a bounded localized launch failure state with a reload action while preserving normal first-frame handoff.

## 2. Regression Coverage

- [x] 2.1 Add automated guards for the nginx WASM contract and static launch recovery behavior.
- [x] 2.2 Update deployment documentation with the MIME and browser-console verification checks.
- [x] 2.3 Run formatting, analysis, deterministic tests, Web release build, diff checks, and strict OpenSpec validation.

## 3. Production Activation

- [ ] 3.1 Push the scoped change and confirm exact-SHA CI succeeds.
- [ ] 3.2 Install the nginx fix with a rollback backup, deploy the matching Web build, and verify MIME, backend health, first frame, refresh, and phone-sized behavior on the public origin.
- [ ] 3.3 Synchronize the 241 checkout to the released commit without overwriting remote work.
