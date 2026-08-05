# Sol Advisor orchestration flow

```mermaid
flowchart TD
    U[User requests implementation] --> P[Primary Hermes session<br/>stronger architect and acceptor]
    P --> H[Installed Sol Advisor plugin<br/>pre_llm_call injects top-level policy]

    H --> C{Delegation config matches?}
    C -->|No| S[Stop and set with<br/>hermes config set]
    S --> C
    C -->|Yes| F[Frame requirements,<br/>architecture, ownership, and checks]

    F --> T[Build complete task packet<br/>objective · files · interfaces · constraints<br/>base state · verification · return format]
    T --> D[Call native delegate_task]

    G[Global Hermes delegation config<br/>gpt-5.6-luna · openai-codex · max] -. routes .-> D
    D --> L[Fresh Luna / Max child<br/>parent_session_id skips duplicate policy]
    L --> W[Implement only owned work<br/>run requested checks]
    W --> R[Return summary and evidence<br/>to the primary conversation]

    R --> I[Primary inspects actual status,<br/>complete diff, scope, and artifacts]
    I --> V[Primary reruns verification]
    V --> A{Change accepted?}

    A -->|No| X[Create a new precise correction packet]
    X --> D
    A -->|Yes| O[Primary reports acceptance]
    O --> B{Commit or push authorized?}
    B -->|No| E[Leave verified working tree]
    B -->|Yes| PUB[Primary performs Git publication]

    classDef primary fill:#e0f2fe,stroke:#0284c7,color:#0c4a6e;
    classDef child fill:#f3e8ff,stroke:#9333ea,color:#581c87;
    classDef config fill:#fef3c7,stroke:#d97706,color:#78350f;
    classDef gate fill:#dcfce7,stroke:#16a34a,color:#14532d;

    class P,F,T,I,V,X,O,H,PUB primary;
    class L,W,R child;
    class C,S,G config;
    class A,B,E gate;
```

## Responsibilities

| Primary Hermes session | Luna / Max child |
|---|---|
| Resolves intent and architecture | Receives a complete, fresh-context task packet |
| Defines exact ownership and verification | Modifies only its owned files |
| Inspects the real working tree and complete diff | Runs the packet's requested checks |
| Reruns checks and decides acceptance | Returns evidence as a claim for primary review |
| Owns corrections, commits, pushes, and final reporting | Does not publish unless explicitly authorized |

## Important boundaries

- `delegate_task` does not select a model per call; the three global `delegation.*` settings route the child.
- The plugin's `pre_llm_call` policy is top-level only; a non-empty `parent_session_id` skips it for delegated children.
- The plugin's `pre_tool_call` gate blocks only `delegate_task`; other tools pass through unchanged.
- A completed leaf child is not resumed. Corrections use a new, precise delegation packet.
- Delegation is asynchronous but process-local, not a durable background job.
- Independent, non-overlapping work may be batched; shared-file and dependent work stays serial.
