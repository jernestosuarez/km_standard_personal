# Working Docs

Team output files produced by the initiative team: memos, briefings, strategy notes, reports,
advisory notes, presentation decks, and similar documents authored in-house.

**These files are NOT source files** (i.e. not external input to be digested). They are the
team's own outputs. Files land here after being moved from `_inbox/` via the proposal/approval
workflow.

## Suggested subfolders

Create subfolders to match your output types:

```
working-docs/
├── memos/          ← internal memos and briefings
├── strategy/       ← strategy notes and position papers
├── reports/        ← formal reports and assessments
├── partner-briefs/ ← briefs prepared for partner meetings
└── platform/       ← platform and technical documents
```

Create only the subfolders you need. There is no requirement to use all of them.

## Governance note

Files in `working-docs/` are **not integrity-monitored** by `hub-scan.sh`: they are not hub docs,
so the scan does not require them to be committed, to carry OKF frontmatter, or to match an entity
shape. The curated hub docs (01–07+) remain the source of truth for initiative content, and
`working-docs/` is the output filing cabinet.

One check does read them. `[ CURRENCY ]` reports any file here that carries no `lifecycle:` field,
because a generated document with no lifecycle marker is draft-grade by definition and a reader
cannot tell it from a current one (STANDARD.md §"Currency of generated documents"). It is an
advisory, not an error, and it names each file so the marking can be done. Not being monitored has
never meant not being governed: currency is exactly the thing that fails when nobody looks.

Drafting into `working-docs/` still needs no proposal or approval. Marking a draft is not approval,
it is stating which generation is current.
