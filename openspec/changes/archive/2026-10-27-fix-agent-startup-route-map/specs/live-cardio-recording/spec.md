## ADDED Requirements

### Requirement: Private route overlay on map
The map SHALL display the local route over the real base image with matching projection, automatic route bounds, start/end markers and separated recording segments. Route points MUST remain local; only the consented map center is sent through the existing relay. The loaded image and projection MUST use the same frozen viewport. Errors and closing the map SHALL leave offline route preview and recording available. Unknown coordinate systems MUST NOT be silently plotted as WGS84.

#### Scenario: Load a saved route
- **WHEN** the signed-in owner consents to load the map
- **THEN** the route fits the base image and start/end markers are visible without uploading the route

#### Scenario: Zoom request fails
- **WHEN** a new map request fails after a successful image
- **THEN** the previous image retains its original projection and the route does not shift to the failed viewport

#### Scenario: Route has a recording gap
- **WHEN** consecutive points belong to different segments
- **THEN** no connecting line is drawn between them
