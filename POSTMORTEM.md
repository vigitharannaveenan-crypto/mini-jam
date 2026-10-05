---
game_title: "Blood Budget"
twist_one_liner: "ARENA, but health is ammunition, with cheap normal shots and expensive piercing shots."
twist_category: "rule-bender"
twist_from_ideas_list: adapted
how_far_from_arena: "substantial"

tools: [chatgpt-web]
models: [unavailable]
primary_model: unavailable
plan: unavailable
agent_instructions_file: no

sessions: 4
total_minutes: 180
total_prompts: unavailable
total_tokens_in: unavailable
total_tokens_out: unavailable
tokens_source: "unavailable: ChatGPT session token counts were not provided; exact model and prompt counts were not recorded. Subscription plan and prior experience categories are unconfirmed. Session durations are estimates."

code_share_llm_pct: 20
code_share_mixed_pct: 50
code_share_hand_pct: 30

odin_experience_before: unavailable
llm_coding_before: unavailable
gamedev_experience_before: unavailable

transcripts_shared: no
---

# Postmortem — Blood Budget

## 1. The game

Blood Budget is a 2D top-down arena shooter built with Odin
and Raylib. The player moves using WASD and aims with the
mouse. Left-click fires a normal shot costing 2 health, while
right-click fires a piercing shot costing 8 health. Defeating
an enemy restores 6 health, capped at 100. Enemy contact costs
20 health. The player wins by defeating 30 enemies and loses
when health reaches zero. Enter starts the game and allows
another run after winning or losing.

Compared with ARENA:

- **Kept:** top-down movement, shooting, enemies chasing the
  player, health, increasing difficulty and replay.
- **Changed:** health also serves as the ammunition budget,
  and winning requires defeating 30 enemies.
- **Removed:** shooting without a health cost.
- **Added:** piercing shots, tougher enemies, healing from
  kills, and health and kill-progress bars.

The main decision is whether to use a cheap normal shot or
spend more health on a piercing shot. Normal shots are
economical against single weak enemies. Piercing shots can
defeat tougher enemies immediately and pass through multiple
targets, but missing wastes more health.

The intended mastery is positioning enemies in a line,
aiming accurately, and choosing a shot based on health and
enemy placement. These are design intentions, not findings
from showcase feedback. I missed the showcase because I was
sick, so I did not observe classmates playing the game.

## 2. Your setup

I used VS Code and PowerShell on Windows, with Odin and its
bundled Raylib bindings. The installed Odin version was
`dev-2026-09-nightly:a2fb372`.

I used GPT through ChatGPT's web interface for suggestions,
help with ARENA code, code review and troubleshooting.
The exact model name was not recorded. I shared the course
slides, rubric, README and postmortem template to provide
assignment context.

I did not use an agent instruction file. During the final
session, I requested complete replacement files and explicit
paste instructions because separate edits were harder to
follow. For future work, I would also request an explanation
of each change.

I estimate that 20% of the final code was accepted from GPT
with little or no change, 50% was GPT-generated code that I
substantially revised, and 30% was written by me independently.
These are overall estimates; I have not documented the
authorship split for each individual feature.

## 3. Feature by feature

Separate feature times and prompt counts were not recorded.
The `who` entries are unavailable until I identify which
features I wrote, revised or accepted unchanged. The overall
code-share estimate above should not be treated as evidence
of individual feature authorship.

| Feature | Who | Prompts | First try? | Minutes | Help 1–5 | Note |
|---|---|---|---|---|---|---|
| Window and game loop | unavailable | unavailable | Reported running in final session | unavailable | 5 | Raylib window and input-update-draw loop |
| Game states and restart | unavailable | unavailable | Reported working in final session | unavailable | 5 | Title, playing, win and loss screens |
| Player movement | unavailable | unavailable | Reported working in final session | unavailable | 5 | WASD movement and window boundaries |
| Shooting | unavailable | unavailable | Reported working in final session | unavailable | 5 | Mouse aiming and bullet movement |
| Enemies and spawning | unavailable | unavailable | Earlier spawning issue; final version ran | unavailable | 5 | Edge spawning and chasing behaviour |
| Health, damage and feedback | unavailable | unavailable | Final build reported working | unavailable | 5 | Contact damage, cooldown and visual feedback |
| Difficulty over time | unavailable | unavailable | Not separately documented | unavailable | 5 | Faster enemies and shorter spawn intervals |
| HUD | unavailable | unavailable | Final build reported working | unavailable | 5 | Health and kill-progress bars |
| Health as ammunition | unavailable | unavailable | Final build reported working | unavailable | 5 | Shots cost health; kills restore health |
| Piercing shots | unavailable | unavailable | Final build reported working | unavailable | 5 | Higher-cost shots continue through enemies |
| Tough enemies | unavailable | unavailable | Final build reported working | unavailable | 5 | Three normal hits or one piercing hit |

No external sprites or audio were used in the implementation
developed in the final conversation.

## 4. Where the LLM sped you up

In session 1 on September 28, I asked GPT for game suggestions.
I rated its help 4 out of 5. In session 2 on September 29, I
asked for help with ARENA code and also rated it 4 out of 5.

In session 4 on October 4, GPT helped with an issue where
enemies were not appearing. It also assisted with movement,
shooting, game states, health and the health-as-ammunition
mechanic. I rated that session 5 out of 5.

Working through runnable versions helped me make progress.
Requesting complete files made applying the changes easier
than locating and replacing separate pieces of code.

I did not measure a reliable estimate of how long these
features would have taken without GPT, so the amount of time
saved is unavailable.

## 5. Where it did not help

In session 3 on October 1, I asked GPT to review my work.
It mainly supplied fixes without clearly explaining where
I had gone wrong or what needed to be implemented. I rated
the help 2 out of 5.

The problem was the explanation and delivery of the advice.
Corrected code alone did not help me understand the cause
of the issue. In the final session, I requested full code
files and clearer paste instructions, which made applying
changes easier.

Next time, I would ask for the cause of the problem, an
explanation of the correction, and a specific way to verify
the result.

## 6. One LLM-introduced bug: found, fixed, verified

### The reported enemy issue

Enemies were not appearing, and GPT helped resolve the code
issue. However, I have not preserved the broken code, the
exact change or a verification record. I also cannot confirm
from the available evidence whether GPT introduced the issue.

I cannot honestly present this as a fully documented
LLM-introduced bug with before-and-after verification.

### A separate issue identified in the supplied code

The GPT-generated implementation checks that a shot leaves
at least one health:

```odin
if health > cost && length > 0 {
```

Normal shots cost 2 health, and kills are the only source of
healing. At 1 or 2 health, the player cannot fire either shot
and cannot recover health through kills.

This issue was identified by inspecting the code. A fix and
a repeatable verification have not been documented. This
section therefore remains incomplete against the requirement
for a bug that was found, fixed and verified.

## 7. Pitch vs. delivered

The original Wednesday pitch has not been provided in this
record, so an accurate pitch-to-delivery comparison is
unavailable.

The delivered concept is an arena shooter where health is
ammunition. The course's health-as-ammunition idea was adapted
by adding a choice between cheap normal shots and expensive
piercing shots, together with tougher enemies and healing
from kills.

I missed the September 28 showcase because I was sick, and
the absence was not approved as excused. I did not receive
classmate feedback cards, so I cannot claim that changes were
based on showcase observations.

I recorded a gameplay video for the repository. I understand
that the rubric allows a video substitution for an excused
absence, and that my video does not automatically fulfil
that condition.

## 8. Improving the pipeline

For another jam, I would make these changes:

- Record each session immediately, including the exact model,
  duration, prompt count and features worked on.
- Ask for explanations during code review, not just corrected
  code.
- Request complete files when necessary, but compare the
  changes so I understand what was modified.
- Commit after each working feature to preserve the development
  history and before-and-after bug evidence.
- Test movement, spawning, shooting, health, endings and
  restart separately.
- Check edge cases such as insufficient health to fire.
- Record a short before-and-after demonstration or printed
  values when verifying a bug fix.
- Build from a clean clone before making the final tag.

I would want the tools to show the cause of an issue, the
specific changes made and the recommended verification more
clearly.

## 9. Anything else

GPT was useful for suggestions and implementation, but the
code-review session showed that receiving a fix is different
from understanding it. I need to be able to explain the code
I submit and support claims about fixes with evidence.