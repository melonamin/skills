---
name: clockwork-plan
description: Write a complete implementation plan in ralphex/Clockwork format with Task headers, Validation Commands, and executable checkboxes. Use for requested implementation plans or ralphex planning; not for executing an existing plan or routine edits.
---

# Implementation plan

Read the supplied design and relevant repository context. Produce the complete plan in one pass when enough is known. Resolve routine choices yourself; ask only about consequential missing requirements. Do not require question quotas, per-task approval, or an interview before writing.

## Workflow

1. Establish the requested behavior, existing implementation, constraints, and acceptance criteria. Preserve decisions already made.
2. Split work into coherent, independently verifiable tasks. Identify relevant files, dependencies between tasks, and important failure paths. Do not prescribe a new test framework or one test per function.
3. Include the repository's actual validation commands. Select regression coverage by behavior and risk; include integration/browser verification where needed to prove the change.
4. Write the complete plan to the requested location, otherwise docs/plans/YYYY-MM-DD-<topic>.md. If the user requests the plan in chat, return it there instead.
5. Check the format and completeness. Report the plan location and material open decisions. Continue to implementation only if authorized. Do not automatically commit the plan or ask a ceremonial next-step question.

## Required format

```markdown
# Plan: <title>

<Goal, scope, assumptions, and acceptance criteria.>

## Validation Commands

- `<existing focused test command>`
- `<other required repository check>`

### Task 1: <coherent outcome>

<Relevant files, approach, and dependencies.>

- [ ] <specific implementation step>
- [ ] <meaningful validation of this task>

### Task 2: <next outcome>

<Context.>

- [ ] <specific step>
- [ ] <validation>
```

Use H3 Task N headers and unchecked items for work still to do. Keep external dependencies and unresolved decisions explicit; never mark unverified work complete. During authorized execution, keep the plan aligned with actual progress and scope changes.

If the user explicitly requests an interactive planning interview, use the brainstorm skill for that phase, then produce this format without repeating the interview.
