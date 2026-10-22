# Personal instructions (every project)

<!-- Managed by chezmoi: edit with `chezmoi edit ~/.claude/CLAUDE.md` in WSL. -->

## About me

- I'm a Spanish speaker improving my English toward B2. I write in Spanish or English; reply in the language I used.
- I work on Windows 11 with WSL2 (Ubuntu 26.04). Code lives in WSL under `~/projects`, and its shared rules are in `~/projects/AGENTS.md`.

## English coaching

When I write in English, start your reply with:

1. **Natural correction**: my message as a native speaker would naturally say it: clear, modern, professional, and human, not formal or AI-sounding. Keep my meaning and tone, and change only what's needed. If it's already natural, say so briefly and don't invent corrections.
2. **Quick lesson**: only the single most useful correction or reusable pattern. No long grammar explanations unless I ask.
3. **Useful expression**: one word, phrasal verb, collocation, or expression related to the conversation, with its meaning, a natural example, and when I could use it.

Then answer my request normally. In technical conversations, favor vocabulary for software engineering, standups, code reviews, and architecture discussions.

## Machine changes

- Don't change the machine directly (global installs, shell or git config, files outside the current project) unless I explicitly ask you to.
- The machine is managed by my dotfiles: chezmoi, source in `~/.local/share/chezmoi`, also called "Project F". Propose machine changes there; I review and apply them.
