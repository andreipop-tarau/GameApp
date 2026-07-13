# Product vision

MindTrap AI is a one-handed mobile challenge game built around fair 5–30 second rounds, instant retries, and adaptive variety. It must remain unlimited and free to play; spending changes appearance, never outcomes.

## Product principles

1. Reach a playable round within seconds.
2. Make failure understandable and restarting immediate.
3. Adapt challenge selection without hiding unfair rules.
4. Work offline for normal play; require the server only for competitive and account-sensitive actions.
5. Prefer a small, polished challenge library over many weak mechanics.
6. Treat accessibility, privacy, security, and telemetry as product requirements.

“AI” initially means a deterministic adaptive director using player performance and configurable rules. No LLM or generative service is required for launch gameplay.

## Audience and outcomes

The primary audience is players aged 13+ who enjoy short puzzle, attention, memory, timing, and reaction sessions. Competitive players and cosmetic collectors are secondary audiences.

Primary product measures are round completion and retry rates, D1/D7 retention, rounds per session, crash-free sessions, challenge success distribution, and cosmetic conversion. Numeric targets in `Docs/V1_Chapter_1_Vision_and_Product_Philosophy.txt` are hypotheses to validate, not launch promises.

## Non-goals

- Energy, lives, mandatory ads, paid power, or purchasable leaderboard advantage.
- Real-time multiplayer, clans, tournaments, creator tools, or battle passes at launch.
- A custom backend platform when Supabase provides the needed capability.
- An online ML/LLM dependency in the round loop.

## Source references

Product intent comes primarily from `Docs/V1_Chapter_1_Vision_and_Product_Philosophy.txt`, chapters 2, 9, 12, and 14, plus the balance rules in `Docs/Appendix_A_Game_Balance_Bible.txt`.
