---
name: brainstorm
description: Explore a feature or architectural decision when the user asks to brainstorm, compare approaches, or design a solution. Deliver a complete recommendation by default; interview interactively when requested. Do not invoke for routine fixes or an already-approved implementation plan.
---

# Brainstorm

Turn an idea into an implementable design grounded in the existing system.

1. Read the relevant code, repository guidance, and supplied requirements. Identify the goal, constraints, affected ownership boundaries, and success criteria.
2. Resolve routine choices from that context. Ask only when missing information materially changes the design. Do not ask for facts you can inspect, a title you can choose, or approval of each section.
3. Compare credible alternatives when they exist. Recommend one and explain the important tradeoffs. Do not manufacture alternatives to meet a quota.
4. Present the complete design: behavior, components and ownership, data flow, relevant failure modes, integration points, and verification. State assumptions and unresolved decisions together.
5. If implementation planning was requested, continue to the plan; use the clockwork-plan skill for ralphex format. If implementation was authorized, continue within that scope. Otherwise end with the design.

## Interactive mode

When the user asks for an interview or step-by-step exploration, ask one consequential question at a time and incorporate each answer. Stop interviewing once enough is known. Do not re-ask settled decisions.

## Design judgment

- Reuse existing capabilities before adding new services, abstractions, or configuration.
- Explain complexity in terms of the requirement or failure mode it addresses.
- Match the depth to the decision. A small feature does not need a full architecture document.
- Respect the repository's design and plan conventions. Skill invocation alone does not authorize committing, publishing, or implementing a proposed design.
