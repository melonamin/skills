<!-- agterm-skill -->

# Driving agterm

agterm is a native desktop terminal with macOS and GTK Linux frontends. It exposes a programmatic control channel over a local unix
socket, driven by the companion CLI `agtermctl`. Use it to build and steer terminal layouts, run
programs in overlays, type into sessions, notify the user in the exact session you are working in,
and subscribe to control events. Events cover status, notifications, session lifecycle, and
structural tree changes. They do not stream terminal output; use `session text` to read a buffer.
