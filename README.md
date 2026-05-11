You are an expert enterprise chatbot migration architect and LLM automation engineer.

I want you to walk me through a complete, detailed technical strategy for migrating 
an IBM Watson Assistant chatbot to Google Dialogflow CX. Our chatbot is very complex 
with a lot of dialogs, making migration hard. Cover everything below in sequence:

─────────────────────────────────────────────────────────────
TOPIC 1 — OVERALL MIGRATION STRATEGY
─────────────────────────────────────────────────────────────
Give me a full phase-by-phase migration strategy (6 phases, ~18–22 weeks total):
- Phase 0: Assessment & Audit
- Phase 1: Foundation Setup
- Phase 2: Intent & NLU Migration
- Phase 3: Dialog Logic Migration (flag this as the hardest phase)
- Phase 4: Fulfillment & Integration Migration
- Phase 5: Testing & Cutover

For each phase include: what to do, key tools, duration, and risks.

Also include:
- A Watson → Dialogflow CX conceptual mapping table 
  (Intents, Entities, Dialog Nodes, Context Variables, Slots, Webhooks, 
   Skills, Digressions, Jump-to, Anything_else)
- A recommendation to use Dialogflow CX (not ES) and why
- A cutover strategy using traffic splitting / shadow mode 
  (parallel run: 10% → 25% → 50% → 100%)
- Common pitfalls to avoid

─────────────────────────────────────────────────────────────
TOPIC 2 — LLM AUTOMATION FOR DIALOG LOGIC MIGRATION
─────────────────────────────────────────────────────────────
Now go deep on using LLMs to automate Phase 3 (Dialog Logic Migration).

Design a 5-stage LLM automation pipeline:

Stage 1 — LLM Parser & Classifier
  - Reads each Watson dialog node JSON
  - Classifies node type: slot_filling, conditional_branch, jump_to, 
    fallback, response_only, digression_handler, folder
  - Extracts: conditions, context vars, child nodes, response text, confidence

Stage 2 — LLM Structural Mapper  
  - Groups classified nodes into Dialogflow CX Flows and Pages
  - Identifies domain boundaries, entry intents, transitions

Stage 3 — LLM Condition Translator
  - Converts Watson DSL conditions → CX route condition syntax
  - Rules: $variable → $session.params.variable, @entity → CX entity,
    intents[0].intent == 'x' → $intent.display-name = "x",
    anything_else → true (default route)
  - Flags low-confidence translations for human review

Stage 4 — LLM Response Migrator
  - Rewrites Watson response templates for CX
  - Converts SpEL expressions (<? ?>) to CX parameter references
  - Handles rich content, buttons, cards

Stage 5 — LLM QA Validator
  - Diffs original Watson node vs migrated CX equivalent
  - Flags: missing branches, lost context vars, unreachable states
  - Severity levels: critical / warning / info

For each stage show:
- A detailed LLM prompt template with placeholders like {node_json}
- Example Watson node JSON input
- Example LLM JSON output

Also show:
- A Python automation script that chains all 5 stages using the Anthropic API
  (use model: claude-sonnet-4-20250514)
- A decision matrix: which node types to auto-apply vs require human review
  (Simple responses → auto, SpEL expressions → manual, etc.)
- Realistic outcome: ~60–70% auto-migration rate

─────────────────────────────────────────────────────────────
TOPIC 3 — INPUT METHODS FOR THE LLM PIPELINE
─────────────────────────────────────────────────────────────
Explain the 3 ways to feed Watson workspace data into the LLM automation pipeline.
No screenshots — everything is structured JSON/text.

Method 1 — Watson JSON Export (easiest, start here)
  - IBM Watson console → Download workspace → .json file
  - Show a real example Watson dialog node JSON structure
  - Show Python code to load and iterate dialog_nodes

Method 2 — Watson API Pull (best for automation/CI)
  - Call IBM /workspaces API with export=True parameter
  - Show the requests.get() code with auth=("apikey", IBM_API_KEY)

Method 3 — Conversation Logs (for test case generation)
  - Export real user conversation history
  - Use LLM to convert logs → Dialogflow CX test cases
  - Show the logs API call code

For each method show:
- Step-by-step instructions
- Python code snippet
- Format of data returned

Also clarify: the LLM receives plain text JSON as a string inside the prompt — 
no UI, no screenshots, no vision required.

─────────────────────────────────────────────────────────────
PRESENTATION
─────────────────────────────────────────────────────────────
After covering all 3 topics in detail with code examples, 
create a professional 16-slide PowerPoint (.pptx) using pptxgenjs 
covering all the above content. Use:
- Dark navy + cyan accent color palette
- Slide 1: Title slide
- Slide 2: Table of contents (8 topics)
- Slide 3: Why migrate — Watson vs Dialogflow CX comparison table
- Slide 4: 6-phase migration strategy
- Slide 5: Conceptual mapping (Watson → CX constructs)
- Slide 6: Dialog logic challenges (6 cards)
- Slide 7: LLM 5-stage pipeline overview
- Slide 8: Stage 1 — prompt template + JSON example
- Slide 9: Stages 2–4 prompt templates
- Slide 10: Stage 5 QA validator
- Slide 11: 3 input methods with code
- Slide 12: Auto-apply vs human review matrix
- Slide 13: Full Python pipeline code
- Slide 14: Cutover strategy (parallel run + rollback)
- Slide 15: Timeline + key risks
- Slide 16: Next steps / closing

Write and run the pptxgenjs Node.js script directly and provide 
the .pptx file as a download.
