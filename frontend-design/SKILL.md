---
name: frontend-design
description: Design and implement frontend interfaces when creating or restyling pages, components, dashboards, or applications. Do not invoke for backend-only work or frontend logic changes without a visual design task.
---

# Frontend design

Inspect the existing interface, tokens, components, content, and technical constraints first. In an established product, extend its design system; a local change does not authorize a redesign or font replacement.

For a new interface, choose a coherent visual direction suited to its audience and purpose. Establish typography, palette, hierarchy, spacing, and responsive behavior. Distinctiveness should serve the content: system fonts, restrained layouts, and existing component libraries are valid choices. Avoid decoration without a purpose.

Resolve the brief from the request and repository. State reasonable assumptions; ask only when missing information materially changes the design. Produce a complete implementation unless the user requested exploration or a plan. Multiple variants are useful when requested or when comparing a consequential visual decision; they are not a prerequisite.

- Use real content and available assets. Do not invent customer endorsements, metrics, or product capabilities.
- Preserve the project's framework and dependencies. Reuse tokens and accessible primitives; add dependencies only for a demonstrated need.
- Use semantic structure, readable contrast, keyboard navigation, visible focus, labels, and useful loading, empty, and error states.
- Design for narrow and wide screens. Honor reduced motion and the product's theme behavior; check light and dark modes when supported or requested.
- Keep styling and interaction code maintainable. Prefer deliberate spacing and alignment over brittle positioning.

Run the relevant project checks and inspect the rendered result at representative viewport sizes. Exercise the interactions that changed. Report actual verification and any unavailable browser or asset dependency; do not call an unrendered result visually verified.
