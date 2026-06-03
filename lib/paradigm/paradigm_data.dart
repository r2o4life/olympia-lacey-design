class ParadigmProjectLensData {
  final String headline;
  final String metric;
  final String narrative;

  const ParadigmProjectLensData({required this.headline, required this.metric, required this.narrative});
}

class ParadigmProjectCinematic {
  /// The headline used by the cinematic narrative tile.
  final String kicker;
  final String title;
  final String subtitle;

  /// Node -> Sub nodes (used for progressive disclosure sandbox templates).
  final Map<String, List<String>> nodes;

  const ParadigmProjectCinematic({required this.kicker, required this.title, required this.subtitle, required this.nodes});
}

class ParadigmProject {
  final String id;
  final String index;
  final String title;
  final String focus;

  final ParadigmProjectCinematic cinematic;

  final Map<String, ParadigmProjectLensData> data;

  const ParadigmProject({
    required this.id,
    required this.index,
    required this.title,
    required this.focus,
    required this.cinematic,
    required this.data,
  });
}

/// Story copy for a single sandbox beat.
///
/// Used to override the default sandbox templates with project-specific,
/// objective-specific narratives.
class ParadigmStoryBeatCopy {
  final String headline;
  final String body;

  const ParadigmStoryBeatCopy({required this.headline, required this.body});
}

/// Source-of-truth narrative libraries that can be used by the cinematic sandbox.
///
/// For BridgeBound, this maps SDLC phases to unique objective framing and a
/// distinct story beat (MECE-aligned) rather than generic edtech tropes.
class ParadigmNarrativeLibrary {
  static ParadigmStoryBeatCopy? beatFor({required String projectId, required String objective, required String phase}) {
    final normalizedPhase = _normalizePhase(phase);

    if (projectId == 'bridge') {
      final obj = _bridgebound[objective];
      if (obj == null) return null;
      return obj[normalizedPhase];
    }

    if (projectId == 'tipzero') {
      final obj = _tipzero[objective];
      if (obj == null) return null;
      return obj[normalizedPhase];
    }

    if (projectId == 'crawl') {
      final obj = _crawl[objective];
      if (obj == null) return null;
      return obj[normalizedPhase];
    }

    return null;
  }

  static String _normalizePhase(String phase) {
    final p = phase.trim().toLowerCase();
    if (p.startsWith('discover')) return 'discovery';
    if (p.startsWith('signal')) return 'signal';
    if (p.startsWith('proto')) return 'prototype';
    if (p.startsWith('build')) return 'build';
    if (p.startsWith('launch')) return 'launch';
    if (p.startsWith('iter')) return 'iterate';
    return p;
  }

  static const Map<String, Map<String, ParadigmStoryBeatCopy>> _bridgebound = {
    'User Growth': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Close the loop, not the funnel',
        body:
            'BridgeBound is a structural bridge across a fragmented learning ecosystem: classroom signals, parent action, student agency.\n\n'
            'We start by mapping the real adoption constraint: parents feel blind, teachers feel overburdened, and the district feels churn risk. The win condition isn’t “more usage” — it’s fewer high-friction moments (missed context, delayed updates, unclear next steps).\n\n'
            'Output of this phase: a friction map that proves where “communication overhead” breaks the loop, and where a single, bite-sized insight can restore alignment within 30 seconds.',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Zero-latency onboarding as the wedge',
        body:
            'For growth, BridgeBound’s wedge is not a feature tour — it’s an immediate translation engine.\n\n'
            'We design the first session so a parent can see one actionable classroom micro-signal without needing an education degree. The product must feel like it replaces three tools, not adds a fourth.\n\n'
            'Success metric: time-to-first-clarity (TTFC) — the moment a parent says “I understand what changed today and what I can do tonight.”',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: A relationship-driven feedback loop',
        body:
            'We prototype the loop with three actors and one rule: micro-inputs yield macro-outputs.\n\n'
            'Teacher: one-tap observation. System: translate into parent-friendly language + suggested reinforcement. Parent: acknowledge + pick a small action. Student: sees growth framed as identity, not ranking.\n\n'
            'The prototype is judged on emotional mechanics: does it reduce anxiety for parents, protect teacher time, and preserve student psychological safety?',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Compounding growth over years, not weeks',
        body:
            'We build for longitudinal value: data must follow the student, not the building.\n\n'
            'That means a growth profile that can survive school transitions, hybrid models, and fragmented learning pathways — while keeping inputs light enough that teachers actually contribute.\n\n'
            'This is where switching costs are earned ethically: the historical log of holistic growth becomes the community’s shared memory.',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Cohorts that prove network effects',
        body:
            'We launch with cohorts where network effects can be observed: when parents engage asynchronously, teacher load decreases and data quality increases.\n\n'
            'The story we measure is systemic: activation isn’t a login — it’s a closed loop event (teacher signal → parent action → student reinforcement → teacher confidence).\n\n'
            'If the loop closes reliably, growth compounds without resorting to gamified tropes.',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Personalization with equity guardrails',
        body:
            'Iteration is where BridgeBound avoids becoming another data cemetery.\n\n'
            'We tune personalization so it improves clarity without deepening inequality: low-text, high-visual cues; multilingual affordances; and guidance that doesn’t assume time, privilege, or institutional literacy.\n\n'
            'The goal: consistent, universally accessible insight delivery that narrows the “ZIP Code Destiny” gap rather than encoding it.',
      ),
    },
    'Monetization': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Funding mechanics, not pricing slogans',
        body:
            'BridgeBound monetization is governed by institutional reality: per-pupil funding pressure, retention economics, and the rise of hybrid learning.\n\n'
            'We test packaging against two buyers: districts (systemic retention + accountability) and families/homeschool ecosystems (operational backbone + portfolio proof).\n\n'
            'The objective isn’t extracting revenue — it’s aligning the value metric to outcomes districts already must defend: engagement, retention, and documented growth.',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Prove “the tool that replaces three others”',
        body:
            'We select one monetizable promise that is concrete: reduce conference overhead by making alignment continuous.\n\n'
            'The signal is a before/after: fewer escalations, fewer “surprise” meetings, and measurable reductions in teacher time spent translating progress into parent-ready language.\n\n'
            'If we can quantify hours saved and satisfaction gained, pricing becomes legible.',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Value metric simulation (district vs family)',
        body:
            'We prototype entitlement boundaries with real usage rhythms: district administrators need governance and proof; parents need clarity and peace.\n\n'
            'We simulate paywall placement around outcomes, not features: longitudinal growth reports, intervention logs, and compliance-ready exports.\n\n'
            'Prototype constraint: monetization must never increase teacher cognitive load.',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Entitlements that respect trust boundaries',
        body:
            'We build billing and entitlements as a boundary layer: pricing decisions must not contaminate student data integrity or privacy posture.\n\n'
            'Operationally: clear role-based access, auditability for institutional buyers, and a pathway for data portability (because the market demands it).\n\n'
            'The system stays honest: what you pay for is what you can verify.',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Outcome-based funding alignment',
        body:
            'We launch offers that speak directly to market mechanics: outcome-based funding is rising, and districts need continuous documentation of growth.\n\n'
            'BridgeBound becomes the instrumented layer that makes growth legible over time — not a test-prep product, but a coordination system.\n\n'
            'Launch success is measured in renewals driven by retained enrollment and improved parent satisfaction.',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Packaging that scales across fragmented ecosystems',
        body:
            'We iterate packaging for decoupled education: public, hybrid, micro-school, homeschool.\n\n'
            'The winning monetization model is resilient across fragments because the product connects fragments.\n\n'
            'Iteration focuses on lowering procurement friction while increasing perceived inevitability: “This is our student-growth home.”',
      ),
    },
    'Improved Governance': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Governance as proactive trust',
        body:
            'Governance in BridgeBound isn’t bureaucracy — it’s the permission to scale a sensitive feedback loop.\n\n'
            'We map roles (teacher, parent, admin, homeschool instructor) and the policies they’re already accountable to. The constraint is clarity under scrutiny: when questioned, the system must show who saw what, when, and why.\n\n'
            'This phase outputs a decision inventory: approvals, overrides, dispute paths, and the minimum audit trail required to keep districts confident.',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Make the audit trail feel invisible',
        body:
            'The governance wedge is paradoxical: users must feel less friction, while the institution gains more verifiable structure.\n\n'
            'We prove this by designing workflows where teachers don’t “do governance.” They simply record a micro-observation, and the system handles logging, versioning, and permissioning automatically.\n\n'
            'Signal metric: reduced admin intervention per classroom, without sacrificing accountability.',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Approval flows that don’t collapse UX',
        body:
            'We prototype content approval and correction paths: what happens when a parent disputes an interpretation, or an admin needs to lock a record?\n\n'
            'We design override paths that are explicit, rare, and legible — so governance events don’t feel like random product behavior.\n\n'
            'If governance is done right, the UX reads as calm confidence.',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Immutable change history (with humane interfaces)',
        body:
            'We build an audit event system that is immutable and queryable, but we present it in human language.\n\n'
            'This supports two realities: parents need understandable explanations; districts need defensible records.\n\n'
            'The outcome is governance that increases trust without demanding new behavior from already-burdened educators.',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Operational playbooks for real schools',
        body:
            'We launch governance with playbooks: escalation paths, incident handling, and data requests.\n\n'
            'This is where BridgeBound becomes “infrastructure,” not an app.\n\n'
            'Launch success is not just adoption — it’s institutional confidence that the system holds up under audits and complaints.',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Policy tuning cadence',
        body:
            'We iterate governance by measuring where policy creates friction or ambiguity.\n\n'
            'We tune defaults to reduce teacher overhead, expand parent clarity, and keep administrators in control without micromanaging.\n\n'
            'The loop: fewer disputes, faster resolution, higher trust — at scale.',
      ),
    },
    'Improved Security': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Privacy is the foundation, not a checkbox',
        body:
            'BridgeBound sits at the intersection of child development data, family context, and institutional accountability. Security is the boundary that keeps the narrative honest.\n\n'
            'We begin with threat modeling plus FERPA/COPPA-aware privacy requirements, focusing on the true risk: not just breaches, but misuse, over-collection, and surveillance dynamics that erode student safety.\n\n'
            'This phase defines what must never happen — and designs the system so it can’t.',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Trust in two minutes',
        body:
            'We prove security to non-security users through UX: clear permission prompts, transparent data explanations, and “why you’re seeing this” microcopy.\n\n'
            'Administrators need confidence that the platform creates proactive data trust; parents need to feel safe; students need to feel respected.\n\n'
            'Signal metric: fewer privacy-related objections during onboarding and procurement.',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Dual-stream isolation (home vs school)',
        body:
            'We prototype the core security architecture: separate streams for school-generated signals and home-generated context.\n\n'
            'This prevents accidental commingling and keeps the system policy-compliant without forcing manual discipline on users.\n\n'
            'We validate that the same insight can be delivered without exposing raw sensitive inputs.',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Least privilege + safe AI boundaries',
        body:
            'We build least-privilege access control and ensure any AI/LLM components operate within strict prompting and data-minimization boundaries.\n\n'
            'Security includes operational safety: rate limits, audit logs, secure defaults, and principled data retention.\n\n'
            'This is how the app supports both web and mobile responsibly: consistent security posture across platforms.',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Monitoring + incident readiness',
        body:
            'We launch with monitoring thresholds and incident runbooks because school systems can’t afford ambiguity.\n\n'
            'Security is treated as an operational capability: detect anomalies, respond fast, communicate clearly, and learn.\n\n'
            'Launch success: administrators can say “we can defend this system,” not just “it seems secure.”',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Hardening sprints + dependency reviews',
        body:
            'We iterate security with a cadence: hardening sprints, dependency audits, and adversarial reviews.\n\n'
            'Because BridgeBound is systemic infrastructure, security work is never “done.”\n\n'
            'The product remains a bridge, not a breach point — even as features expand.',
      ),
    },
    'Increased App Engagement': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Engagement as micro-wins, not noise',
        body:
            'Engagement in BridgeBound is not dopamine design. It’s the felt sense that progress is visible and actionable.\n\n'
            'We map micro-win moments: a parent understands a milestone, a child sees effort reframed as growth, a teacher records a breakthrough without extra work.\n\n'
            'We explicitly avoid surveillance vibes and ranking mechanics that undermine agency.',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Clarity beats novelty',
        body:
            'We prove that engagement can be driven by clarity: the interface must translate curriculum targets into everyday benchmarks parents can celebrate at dinner.\n\n'
            'The product wins when it reduces anxiety and increases confidence — not when it keeps users “scrolling.”\n\n'
            'Signal metric: repeated weekly engagement anchored to new, bite-sized insights.',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Motion language for understanding',
        body:
            'We prototype interaction and motion as comprehension tools: subtle transitions that explain hierarchy, not distract.\n\n'
            'The UX must be consumer-grade elegant (Slack/Spotify expectations) while handling institutional complexity underneath.\n\n'
            'Prototype success: users feel “this is simple,” even though the system is doing hard translation work.',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Performance budgets for real classrooms',
        body:
            'We build with performance budgets: no jank, fast first paint, resilient offline behavior where appropriate.\n\n'
            'Because BridgeBound sits on the critical path of trust, reliability is engagement.\n\n'
            'If the product is slow, engagement collapses — not because users are impatient, but because the loop is fragile.',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Instrument the loop, not vanity metrics',
        body:
            'We launch instrumentation that measures loop health: time-to-clarity, completion of reinforcement actions, teacher input frequency, and dispute rates.\n\n'
            'We watch where the loop breaks and treat it as a systems problem, not a marketing problem.\n\n'
            'Engagement is validated when the system reduces teacher load and increases parent confidence simultaneously.',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Adaptive cadence without inequity',
        body:
            'We iterate content cadence and difficulty adaptively, but with equity guardrails: the system must work for parents with limited time, English fluency, or institutional familiarity.\n\n'
            'The goal is durable engagement rooted in empowerment — not behavioral addiction.\n\n'
            'When done right, engagement becomes the visible footprint of a repaired ecosystem.',
      ),
    },
  };

  /// TipZero story library.
  ///
  /// TipZero is an infrastructure-level intervention: it normalizes a
  /// pressure-free zero-tip default while preserving (and stabilizing) worker
  /// supplemental income via asynchronous, sponsor-funded micro-incentives.
  static const Map<String, Map<String, ParadigmStoryBeatCopy>> _tipzero = {
    'User Growth': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Map tipping fatigue as a churn engine',
        body:
            'TipZero growth starts with a cultural reversal: POS systems turned gratuity into coercion, and customers responded with avoidance, resentment, and lower repeat visits.\n\n'
            'We observe real checkout behavior: where people hesitate on 18–25% prompts, how staff braces for awkwardness, and how merchants absorb reputational damage.\n\n'
            'Output: a friction map that treats tipping fatigue as a retention problem — not a moral debate.',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Prove the zero-pressure default increases return visits',
        body:
            'The wedge is simple: make “Zero Tip” socially normal and operationally fast.\n\n'
            'We validate that removing the forced prompt reduces checkout dwell time and restores privacy — while worker bonuses still land via alternative rails.\n\n'
            'Success metric: repeat-visit lift + faster lines, without worker income collapsing.',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: “TipZero Certified” as a trust badge',
        body:
            'We prototype the network effect: customers seek establishments that don’t tip-shame.\n\n'
            'The experience is a permission slip: pay the base price now, reward later if you choose — or let sponsors fund the bonus.\n\n'
            'Prototype success: sentiment improves instantly and merchants feel safer adopting.',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Frictionless onboarding for merchants + staff',
        body:
            'We build growth as operations: a clean merchant onboarding path, a staff enrollment flow that doesn’t feel like surveillance, and a customer experience that never blocks checkout.\n\n'
            'The system must integrate with existing POS rails or fall back to standalone QR infrastructure.\n\n'
            'Outcome: density compounds — each venue becomes a node in a trust network.',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Hyper-local clusters to trigger network effects',
        body:
            'We launch in neighborhood clusters where “TipZero Certified” has visible meaning.\n\n'
            'We measure a systemic story: more trust → more visits → higher sponsor demand → more worker bonuses.\n\n'
            'If the loop closes, growth compounds without paid acquisition becoming the only lever.',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Reduce friction until the default feels inevitable',
        body:
            'Iteration removes anything that reintroduces guilt or confusion.\n\n'
            'We tune messaging, timing, and the post-transaction engagement so the platform stays non-adversarial — a quiet infrastructure layer.\n\n'
            'Win condition: customers stop thinking about the tip screen entirely, and merchants see retention rise.',
      ),
    },
    'Monetization': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Outside liquidity, not higher percentages',
        body:
            'TipZero monetization redesigns who funds supplemental income.\n\n'
            'Merchants can’t raise wages enough without breaking demand; customers are exhausted by hidden “tip inflation.” The system needs outside liquidity — sponsors and post-transaction value exchange — to bridge the gap.\n\n'
            'Output: a multi-sided value model where the customer is not the sole payer of worker stability.',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Make the value exchange instantly legible',
        body:
            'The monetization moment works only if it reads as fair.\n\n'
            'We prove sponsor-funded bonuses can produce predictable micro-income without hijacking checkout.\n\n'
            'Success metric: sponsor conversion + payout reliability + customer sentiment (no coercion).',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Bonus triggers without “invalid traffic” risk',
        body:
            'We prototype bonus triggers (reviews, lightweight engagements, sponsor matches) while designing explicitly against ad-fraud dynamics.\n\n'
            'Principle: the UX event (customer intent) and the revenue attribution event (ad network rules) cannot be the same thing.\n\n'
            'Prototype success: compliance-safe incentives that still feel human.',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: A provable ledger for bonuses and payouts',
        body:
            'We build a performance ledger that can answer one question without ambiguity: why did this worker receive this bonus?\n\n'
            'Payout boundaries are hardened: transparent states, reconciliations, and safe-fail behaviors.\n\n'
            'This is the infrastructure layer that prevents the system from degrading into suspicion.',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Instrument revenue quality, not vanity clicks',
        body:
            'We launch measurement focused on integrity: payout correctness, anomaly rates, and sponsor ROI tied to real-world attention.\n\n'
            'Worker metrics track stability (volatility reduction), not spikes.\n\n'
            'If the numbers lie, the marketplace collapses — so measurement is part of the product.',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Tune the pool toward predictable income',
        body:
            'Iteration stabilizes worker earnings without reintroducing customer pressure.\n\n'
            'We tune sponsor matching, bonus timing, and eligibility rules so income is steady and understandable.\n\n'
            'Goal: a dignified, multi-source supplemental income stream that feels like infrastructure.',
      ),
    },
    'Improved Governance': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Governance is the right to operate',
        body:
            'TipZero sits inside contested terrain: tip-credit laws, tax reporting, wage optics, and platform policy.\n\n'
            'We identify where merchants get punished (audits, disputes, confusion) and where workers lose trust (unclear payout status).\n\n'
            'Output: a governance model that treats compliance as product design, not paperwork.',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Transparent reporting without extra labor',
        body:
            'We prove that structured supplemental income tracking reduces merchant risk.\n\n'
            'The system produces human-readable records: what was earned, why, and how it is reported.\n\n'
            'Success metric: fewer disputes, faster reconciliation, higher worker trust.',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Guardrails that don’t collapse UX',
        body:
            'We prototype overrides, corrections, sponsor rule changes, and edge-case disputes.\n\n'
            'Principle: dignity first — the customer never feels policed and the worker never feels tricked.\n\n'
            'If controls are heavy-handed, adoption fails.',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Auditability that survives scrutiny',
        body:
            'We build immutable histories where it matters: payout events, eligibility decisions, and sponsor matches.\n\n'
            'Policies are explicit and versioned so changes can be explained.\n\n'
            'This is how the product scales across jurisdictions and partners.',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Operational playbooks for real-world edge cases',
        body:
            'We ship playbooks for disputes, audit requests, payout reversals, and merchant offboarding.\n\n'
            'Governance isn’t theoretical — it’s the decisions you’ll be forced to make under pressure.\n\n'
            'If playbooks are missing, the product becomes a liability.',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Policy tuning driven by friction + disputes',
        body:
            'Iteration updates rules based on dispute patterns, abuse attempts, and regulatory shifts.\n\n'
            'Changes are communicated in plain language to workers and merchants.\n\n'
            'Win: compliance that feels like stability, not bureaucracy.',
      ),
    },
    'Improved Security': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Threat model the bonus economy',
        body:
            'TipZero creates an incentive surface: wherever money flows, abuse follows.\n\n'
            'We map threats: spoofed engagement, collusion, location fraud, and invalid traffic that can get partners banned.\n\n'
            'Output: a risk taxonomy aligned to ad network compliance and payout integrity.',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Make abuse expensive and failure safe',
        body:
            'We prove the system can resist obvious abuse without harming legitimate users.\n\n'
            'Security must not slow checkout; it must operate as invisible boundaries.\n\n'
            'Success metric: reduced anomaly rates with minimal false positives.',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Secure state transitions for payouts',
        body:
            'We prototype the lifecycle of a bonus: intent → eligibility → attribution → payout → reporting.\n\n'
            'Every step is an explicit state transition, so exploits can’t hide in undefined behavior.\n\n'
            'Prototype success: it fails safely, clearly, and recoverably.',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Least-privilege access + hardened boundaries',
        body:
            'We build strict server-side validation, least-privilege access control, and defensive logging.\n\n'
            'Payout actions require strong guarantees; sponsor events require integrity checks.\n\n'
            'Security is the boundary that keeps the marketplace credible.',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Monitoring + incident readiness',
        body:
            'We launch monitoring for real adversaries: spikes, replay patterns, suspicious location behavior, and invalid traffic signals.\n\n'
            'Incidents are not “if” — they’re “when.” We ship thresholds and operator tools.\n\n'
            'If we can’t respond fast, partners will leave.',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Hardening sprints + dependency reviews',
        body:
            'Iteration is continuous hardening: adjust heuristics, review dependencies, and patch exploit patterns.\n\n'
            'Security work is not a hidden tax — it’s why the system remains operable at scale.\n\n'
            'A secure bonus economy is a durable one.',
      ),
    },
    'Increased App Engagement': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Engagement is dignity, not dopamine',
        body:
            'TipZero doesn’t gamify tipping. It removes coercion and replaces it with optional, value-driven participation.\n\n'
            'We study what each actor needs: customers want privacy and control; workers want clarity and predictability; merchants want stability.\n\n'
            'Output: an engagement model built on micro-wins that reduce awkwardness.',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Asynchronous reward moments that feel voluntary',
        body:
            'We prove engagement without pressure: post-transaction prompts that can be ignored, sponsor matches that feel positive, and transparent worker dashboards.\n\n'
            'The system earns attention by respecting it.\n\n'
            'Success metric: repeat engagement without increased checkout time.',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Post-transaction touchpoints that build trust',
        body:
            'We prototype touchpoints after payment: leave a review, sponsor a bonus, send a thank-you.\n\n'
            'Because the payment is complete, the user feels agency — not guilt.\n\n'
            'Prototype success: tone stays non-adversarial, respectful, fast.',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Performance budgets (reliability is engagement)',
        body:
            'We build latency-first UI: fast loading, clear states, and zero ambiguity around payout outcomes.\n\n'
            'Workers get transparent dashboards; customers get frictionless checkout; merchants get operational clarity.\n\n'
            'Reliability becomes the engagement engine.',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Measure loop health, not vanity metrics',
        body:
            'We launch “loop health” instrumentation: return rates, sponsor funding rate, and worker income predictability.\n\n'
            'We avoid metrics that incentivize coercive prompts.\n\n'
            'If the loop stays healthy, the social contract is restored.',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Sharpen timing until it feels natural',
        body:
            'Iteration tunes timing and language.\n\n'
            'We remove anything that feels like tip-shaming and keep what feels like optional support.\n\n'
            'Finish line: rewarding service is easy — and refusing is not socially punished.',
      ),
    },
  };

  /// Crawl (Cottage Crawl) story library.
  ///
  /// Crawl is an infrastructure-level intervention: it unlocks the decentralized
  /// cottage economy by mapping residential micro-businesses into a verified,
  /// privacy-safe, geo-spatial marketplace that turns neighborhoods into
  /// micro-commercial zones.
  static const Map<String, Map<String, ParadigmStoryBeatCopy>> _crawl = {
    'User Growth': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Map the unmapped cottage economy',
        body: '''Crawl growth starts with a discovery problem, not a marketing problem: the supply already exists (home bakers, soap makers, knife sharpeners), but it is structurally invisible.

Traditional platforms privilege commercial addresses and global shipping. Crawl measures what they ignore: pop-up hours, finite inventory, residential pickup logic, and hyper-local walkability.

Output: a neighborhood “asset map” that shows where demand concentrates, which categories trigger walking behavior, and where the marketplace can densify into repeat weekly routes.''',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Prove “Saturday morning crawl” activation',
        body: '''The wedge is a fast, visual map that makes hidden commerce feel safe and standard.

We validate the moment a customer opens the app, sees who is open within a 1-mile radius, and can commit to a pickup without awkward messaging.

Success metric: time-to-first-walk (TTFW) — the first real-world neighborhood visit triggered by the map, not by social feeds.''',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Open/Closed toggles + crawl routes as behavior design',
        body: '''We prototype the key behavioral mechanic: creators control visibility.

Open/Closed toggles, scheduled windows, and “porch pickup” instructions make residential commerce predictable. Route previews turn the marketplace into a physical scavenger hunt — without exposing private addresses outside operating hours.

Prototype success: users feel guided (not creeped out), and creators feel protected (not exposed).''',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Density flywheels (events, clusters, repeat circuits)',
        body: '''We build growth as a local density problem.

The system supports “Crawl Events” (time-boxed neighborhood drops), category-based circuits (bread + coffee + crafts), and notification rails that convert one-off novelty into weekly habit.

If density rises, the marketplace stops being an app — it becomes a neighborhood ritual.''',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Neighborhood pilots with verifiable safety signals',
        body: '''We launch in pilot neighborhoods where verification has visible meaning.

Creators onboard with license proof; customers see trust badges; cities/communities see structured participation rather than informal chaos.

Launch story: higher local foot traffic + higher seller consistency + lower “is this safe?” anxiety.''',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Reduce friction until discovery feels inevitable',
        body: '''Iteration removes the reasons people fall back to group chats.

We tune map clarity, pickup instructions, supply caps, and notification cadence so the experience becomes calmer and more predictable each cycle.

Finish line: customers reliably “check Crawl” the way they check the weather — because it is the neighborhood’s live commerce layer.''',
      ),
    },
    'Monetization': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Monetize the coordination layer (not the craft)',
        body: '''Crawl monetization is not about taxing tiny creators — it’s about pricing the infrastructure that makes residential commerce legible.

We validate what creators will pay for: predictable demand, capacity controls, verified trust, and reduced regulatory anxiety.

Output: a value model spanning listing tiers, transaction rails, and hyper-local ad inventory that is contextual (not spammy).''',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Make payouts + fees feel fair and transparent',
        body: '''We prove that a creator can see “what I earned, what I paid, and why” in plain language.

Consumers must see total cost and pickup terms before committing. Creators must see fee policy and payout timing without surprises.

Success metric: low dispute rate + high re-listing rate (creators keep coming back).''',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Capacity caps as a premium control surface',
        body: '''We prototype finite inventory as first-class.

Creators set caps (e.g., 30 loaves/week), sell-out behavior is explicit, and the marketplace doesn’t over-promise. Premium tools include label templates, scheduled drops, and waitlists.

Prototype success: creators avoid overwhelm, customers avoid disappointment — and monetization aligns with reliability.''',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Local payments + escrow-like confidence',
        body: '''We build transaction rails that feel as safe as mainstream e-commerce while operating in residential contexts.

Clear states (reserved, ready, picked up, refunded) prevent ambiguity. Receipts, tax notes, and category constraints are embedded so creators stay compliant.

The product becomes a financial utility layer for the cottage economy.''',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Marketplace integrity as the monetization story',
        body: '''We launch monetization around integrity: reliability is what users pay for.

We measure seller retention, order completion rate, and customer repeat purchases as the core revenue predictors.

If the platform is trustworthy, monetization becomes sustainable without predatory tactics.''',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Tune for high-signal local ads (brands without noise)',
        body: '''Iteration expands revenue without contaminating trust.

We tune local ads to be context-aware: ingredient suppliers for bakers, tool suppliers for makers, neighborhood lifestyle partners — always tied to active foot traffic and creator intent.

Win: ads feel like infrastructure sponsorship, not interruption.''',
      ),
    },
    'Improved Governance': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Make compliance a product surface',
        body: '''Crawl operates inside governance terrain: cottage food laws, licensing, labeling, revenue caps, and local zoning norms.

We map what creators fear (getting shut down, being reported, operating unknowingly out of bounds) and what customers need (proof that “homemade” is legitimate).

Output: a compliance UX that guides rather than polices.''',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Verification that increases safety without exposing homes',
        body: '''We prove a verification gate that reassures customers while protecting creators.

Licenses can be verified, badges can be shown, but addresses are only revealed during operating windows and only to committed buyers.

Success metric: higher conversion on verified listings + lower safety-related drop-off.''',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Policy-aware listing templates',
        body: '''We prototype listing flows that encode the law.

Category constraints, allergen/ingredient labels, pickup rules, and revenue caps are reflected directly in UI defaults — reducing accidental non-compliance.

Prototype success: creators feel “guided” instead of “watched.”''',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Audit-ready histories (human-readable)',
        body: '''We build event histories that can answer: who listed what, when, under what license state.

This supports creators in disputes and gives the platform the right to operate as it scales across municipalities.

Governance becomes stability: rules are explicit, versioned, and explainable.''',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Cities see structure, not informal chaos',
        body: '''We launch governance as legitimacy.

Communities gain visibility into a previously informal economy; creators gain protection via structured participation; customers gain trust.

Launch success: fewer complaints + clearer dispute resolution + higher license adoption.''',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Regional policy tuning + creator education loop',
        body: '''Iteration localizes governance.

We tune flows per jurisdiction, update templates as laws evolve, and add micro-education that reduces mistakes (labeling, category limits, pickup etiquette).

Goal: compliance that feels like enablement — and scales region by region.''',
      ),
    },
    'Improved Security': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Threat model residential commerce',
        body: '''Security in Crawl is not optional: it’s the boundary between community and harm.

We map threats: address scraping, stalking risk, fraudulent listings, payment disputes, and inventory spoofing.

Output: a security model that protects home privacy by default while still enabling legitimate discovery.''',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: Privacy-first location reveal',
        body: '''We prove that location can be useful without being exposed.

Geo-fenced approximations for browsing; exact pickup details only after commitment; time-window access that expires.

Success metric: high browse-to-commit conversion with no increase in privacy incidents.''',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Trust + abuse controls without “paranoia UX”',
        body: '''We prototype reports, blocks, and identity checks that feel calm.

Security must not turn the product into a warning screen. Controls are present, clear, and rarely needed — but strong when invoked.

Prototype success: creators feel safe enough to participate; customers feel confident enough to walk.''',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Least-privilege access + hardened transaction states',
        body: '''We build strict access boundaries: sensitive location data is segmented and time-scoped.

Transaction state machines prevent ambiguous outcomes; logs support dispute resolution; rate limits prevent scraping.

Security becomes an enabling layer, not a drag.''',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Monitoring for scraping + fraud patterns',
        body: '''We launch with monitors tuned to the actual adversary: automated scraping, repeated address requests, suspicious account creation, and chargeback spikes.

We ship operator playbooks because residential context raises the stakes.

Launch success: low incident rate + fast response when anomalies appear.''',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Hardening cycles as the marketplace scales',
        body: '''Iteration strengthens defenses as density increases.

We adjust heuristics, verification thresholds, and privacy defaults region-by-region.

Outcome: the platform remains safe enough to be normal — which is the only way it becomes infrastructure.''',
      ),
    },
    'Increased App Engagement': {
      'discovery': ParadigmStoryBeatCopy(
        headline: 'Discovery: Engagement is a neighborhood ritual',
        body: '''Engagement in Crawl is not infinite scroll — it’s real-world walking.

We map repeatable moments: Saturday morning circuits, seasonal maker drops, and community crawl events.

Output: an engagement model rooted in place-making and local discovery.''',
      ),
      'signal': ParadigmStoryBeatCopy(
        headline: 'Signal: “Who’s open near me?” as a daily question',
        body: '''We prove a daily-check behavior anchored in utility.

If the map reliably reflects live availability and finite supply, users return without needing gimmicks.

Success metric: weekly active walkers + repeat purchases per neighborhood.''',
      ),
      'prototype': ParadigmStoryBeatCopy(
        headline: 'Prototype: Crawl events as lightweight game mechanics',
        body: '''We prototype events that gamify discovery without turning it into noise.

Badges for completing a circuit, route suggestions, and “drop windows” create urgency tied to real inventory — not artificial scarcity.

Prototype success: engagement feels like community participation.''',
      ),
      'build': ParadigmStoryBeatCopy(
        headline: 'Build: Notification cadence + inventory truth',
        body: '''We build the engagement engine around truth: inventory and hours must be accurate.

Notifications are opt-in, category-specific, and local — a utility layer, not a spam channel.

Reliability is what keeps people coming back.''',
      ),
      'launch': ParadigmStoryBeatCopy(
        headline: 'Launch: Instrument real-world loop health',
        body: '''We launch measurement that respects the phenomenon: walks, pickups, sell-outs, and repeat circuits.

Vanity metrics are avoided because they distort incentives.

If loop health is strong, the neighborhood becomes the product.''',
      ),
      'iterate': ParadigmStoryBeatCopy(
        headline: 'Iterate: Expand categories without breaking safety + trust',
        body: '''Iteration expands the cottage economy surface area: food, crafts, services.

Each new category requires its own trust and compliance affordances.

Win: more variety and density while the platform stays calm, safe, and legible.''',
      ),
    },
  };
}

class ParadigmProjects {
  static const String lensMarket = 'Market Strategy';
  static const String lensSystems = 'Systems Architecture';

  static const projects = <String, ParadigmProject>{
    'bridge': ParadigmProject(
      id: 'bridge',
      index: '01',
      title: 'BridgeBound',
      focus: 'Learning’s Third Place',
      cinematic: ParadigmProjectCinematic(
        kicker: 'Index narrative sandbox',
        title: 'BridgeBound — execution mapped to objectives',
        subtitle:
            'A cinematic, SDLC-driven view of BridgeBound as a systemic intervention — each objective becomes a phase-by-phase story about repairing the learning ecosystem. Tap nodes to enter the sandbox viewport.',
        nodes: {
          'User Growth': [
            'Discovery: map the broken feedback loop (parents + teachers + students)',
            'Signal: time-to-first-clarity onboarding (the translational wedge)',
            'Prototype: micro-input → macro-output relationship loop',
            'Build: longitudinal growth profile + data portability',
            'Launch: cohorts that prove network effects (engagement reduces teacher load)',
            'Iterate: personalization with equity guardrails',
          ],
          'Monetization': [
            'Discovery: funding mechanics (retention, per-pupil, hybrid learning)',
            'Signal: prove “replaces three tools” via hours-saved + satisfaction gains',
            'Prototype: outcome-based value metric simulation (district vs family)',
            'Build: entitlements that respect trust + privacy boundaries',
            'Launch: outcome-based funding alignment + renewals narrative',
            'Iterate: packaging across fragmented ecosystems (public/hybrid/homeschool)',
          ],
          'Improved Governance': [
            'Discovery: governance as proactive trust (roles, policies, accountability)',
            'Signal: auditability without added teacher overhead',
            'Prototype: approval + override paths that don’t collapse UX',
            'Build: immutable change history presented in human language',
            'Launch: operational playbooks for districts (escalations, audits, requests)',
            'Iterate: policy tuning cadence driven by friction + dispute metrics',
          ],
          'Improved Security': [
            'Discovery: threat model + privacy foundation (COPPA/FERPA-aware)',
            'Signal: trust in two minutes (clear data explanations + permissions)',
            'Prototype: dual-stream isolation (home vs school)',
            'Build: least privilege + safe AI boundaries + data minimization',
            'Launch: monitoring thresholds + incident readiness',
            'Iterate: hardening sprints + dependency reviews',
          ],
          'Increased App Engagement': [
            'Discovery: micro-wins that reduce anxiety (not dopamine mechanics)',
            'Signal: clarity beats novelty (actionable milestones)',
            'Prototype: motion language that improves understanding',
            'Build: performance budgets (reliability is engagement)',
            'Launch: instrument loop health, not vanity metrics',
            'Iterate: adaptive cadence without inequity',
          ],
        },
      ),
      data: {
        lensMarket: ParadigmProjectLensData(
          headline: 'Close the Loop in a Fragmented Learning Ecosystem',
          metric: 'Time-to-First-Clarity (TTFC)',
          narrative:
              'BridgeBound is positioned as a systemic intervention — a structural bridge that translates classroom micro-progress into bite-sized, actionable insights for families. The go-to-market narrative centers on “closing the loop”: reducing teacher communication overhead while eliminating parental blind spots. Adoption succeeds when onboarding is near-instant for parents (mobile-first, low text, high visual intuition) and the product feels like it replaces multiple tools instead of adding another.',
        ),
        lensSystems: ParadigmProjectLensData(
          headline: 'Proactive Data Trust with Dual-Stream Boundaries',
          metric: 'Auditability + Privacy Posture',
          narrative:
              'BridgeBound’s architecture is designed around trust mechanics: dual-stream isolation for home vs school context, least-privilege roles, and verifiable audit trails that don’t add burden to teachers. The system favors continuous, longitudinal growth profiles (data follows the student) while remaining universally accessible to avoid widening inequality. Reliability and privacy are treated as foundational infrastructure — because the feedback loop only works when stakeholders feel safe.',
        ),
      },
    ),
    'tipzero': ParadigmProject(
      id: 'tipzero',
      index: '02',
      title: 'TipZero',
      focus: 'Sponsored Supplemental Income',
      cinematic: ParadigmProjectCinematic(
        kicker: 'Index narrative sandbox',
        title: 'TipZero — execution mapped to objectives',
        subtitle:
            'A cinematic SDLC narrative that treats TipZero as infrastructure: normalize a pressure-free zero-tip default while stabilizing worker income through asynchronous, sponsor-funded micro-incentives.',
        nodes: {
          'User Growth': [
            'Discovery: quantify tipping fatigue as churn + reputational drag',
            'Signal: prove “zero-pressure default” increases repeat visits',
            'Prototype: TipZero Certified trust badge + hyper-local discovery',
            'Build: POS/QR onboarding rails for merchants + staff',
            'Launch: neighborhood clusters to trigger network effects',
            'Iterate: reduce friction until the default feels inevitable',
          ],
          'Monetization': [
            'Discovery: outside liquidity (sponsors) vs tip inflation',
            'Signal: value exchange legibility + payout reliability',
            'Prototype: bonus triggers without invalid-traffic exposure',
            'Build: provable ledger for bonuses + reconciliation boundaries',
            'Launch: instrument revenue quality (integrity > clicks)',
            'Iterate: tune the pool toward predictable worker income',
          ],
          'Improved Governance': [
            'Discovery: tip-credit, tax, and platform policy constraints',
            'Signal: transparent reporting without added merchant labor',
            'Prototype: guardrails + overrides that preserve dignity',
            'Build: auditability + versioned policy rules',
            'Launch: operational playbooks for disputes and audits',
            'Iterate: tune rules driven by friction + dispute patterns',
          ],
          'Improved Security': [
            'Discovery: threat model the bonus economy (fraud + invalid traffic)',
            'Signal: make abuse expensive with minimal false positives',
            'Prototype: secure state transitions for eligibility → payout',
            'Build: least-privilege access + hardened payout boundaries',
            'Launch: monitoring, thresholds, and incident readiness',
            'Iterate: hardening sprints + dependency reviews',
          ],
          'Increased App Engagement': [
            'Discovery: engagement as dignity (not dopamine mechanics)',
            'Signal: voluntary, asynchronous reward moments',
            'Prototype: post-transaction touchpoints that build trust',
            'Build: transparency dashboards + reliability budgets',
            'Launch: measure loop health (stability + sentiment)',
            'Iterate: sharpen timing until it feels socially natural',
          ],
        },
      ),
      data: {
        lensMarket: ParadigmProjectLensData(
          headline: 'Restore the Social Contract at Checkout',
          metric: 'Checkout Dwell Time + Repeat Visit Lift',
          narrative:
              'TipZero is positioned as an infrastructure intervention, not a “tipping app.” Modern POS flows weaponized guilt with intrusive percentage screens, breaking consumer trust while leaving workers exposed to volatile income. TipZero normalizes a pressure-free “zero tip” default at the moment of payment and shifts supplemental earning into asynchronous, value-driven mechanisms (sponsor-funded matches, post-transaction engagements), so customers regain dignity without collapsing worker earnings. Merchants adopt because reduced friction increases retention and protects reputation; the system scales as “TipZero Certified” becomes a trust signal that drives intentional consumer migration.',
        ),
        lensSystems: ParadigmProjectLensData(
          headline: 'Ledger-First Bonuses with Compliance Boundaries',
          metric: 'Payout Correctness + Revenue Integrity',
          narrative:
              'TipZero’s system design treats incentives as a high-stakes marketplace: money moves, so abuse follows. The architecture separates the customer’s checkout experience from sponsor/ad attribution rules, so the product can remain fast, pressure-free, and compliant under “invalid traffic” scrutiny. A ledger-first bonus model makes every payout explainable (“why did this worker receive this bonus?”) while hardened state transitions, least-privilege access, and monitoring thresholds protect the platform from fraud, spoofing, and dispute-driven churn. Governance is embedded as product: transparent reporting, versioned policies, and audit-ready histories that scale across jurisdictions.',
        ),
      },
    ),
    'crawl': ParadigmProject(
      id: 'crawl',
      index: '03',
      title: 'Crawl',
      focus: 'Cottage Crawl Marketplace',
      cinematic: ParadigmProjectCinematic(
        kicker: 'Index narrative sandbox',
        title: 'Crawl (Cottage Crawl) — execution mapped to objectives',
        subtitle:
            'A cinematic SDLC narrative that treats Cottage Crawl as infrastructure: reveal and commercialize the hyper-local cottage economy by turning neighborhoods into verified, privacy-safe micro-commercial zones.',
        nodes: {
          'User Growth': [
            'Discovery: map the unmapped cottage economy (residential micro-businesses)',
            'Signal: prove “Saturday morning crawl” activation (time-to-first-walk)',
            'Prototype: open/closed toggles + route previews with privacy windows',
            'Build: density flywheels (events, clusters, repeat circuits)',
            'Launch: neighborhood pilots with verifiable safety signals',
            'Iterate: reduce friction until discovery feels inevitable',
          ],
          'Monetization': [
            'Discovery: monetize the coordination layer (not the craft)',
            'Signal: transparent fees + payouts (low disputes, high re-listing)',
            'Prototype: capacity caps, sell-outs, labels as premium control surface',
            'Build: local payments + explicit order state machine',
            'Launch: marketplace integrity as the monetization story',
            'Iterate: high-signal hyper-local ads (brands without noise)',
          ],
          'Improved Governance': [
            'Discovery: compliance as product surface (licenses, labels, caps)',
            'Signal: verification that increases safety without exposing homes',
            'Prototype: policy-aware listing templates that guide creators',
            'Build: audit-ready histories (human-readable)',
            'Launch: legitimacy for cities + communities (structure vs chaos)',
            'Iterate: regional policy tuning + creator education loop',
          ],
          'Improved Security': [
            'Discovery: threat model residential commerce (privacy + fraud)',
            'Signal: privacy-first location reveal (browse ≠ exact address)',
            'Prototype: calm trust + abuse controls (no paranoia UX)',
            'Build: least-privilege location access + hardened transaction states',
            'Launch: monitoring for scraping and fraud patterns',
            'Iterate: hardening cycles as density scales',
          ],
          'Increased App Engagement': [
            'Discovery: engagement as a neighborhood ritual (walking)',
            'Signal: “who’s open near me?” as a daily question',
            'Prototype: crawl events as lightweight game mechanics',
            'Build: notification cadence + inventory truth',
            'Launch: instrument real-world loop health (walks, pickups, repeats)',
            'Iterate: expand categories without breaking safety + trust',
          ],
        },
      ),
      data: {
        lensMarket: ParadigmProjectLensData(
          headline: 'Turn Residential Streets into a Verified Local Marketplace',
          metric: 'Time-to-First-Walk (TTFW) + Repeat Circuits',
          narrative:
              'Cottage Crawl is positioned as a geo-spatial discovery and transaction layer for the hyper-local cottage economy. Traditional commerce forces makers into cost-prohibitive leases or global shipping platforms; meanwhile, cottage food/craft laws legalize residential production but leave it undiscoverable. Crawl’s go-to-market frames “re-imagining neighborhood walking”: localized crawl events turn discovery into a safe, social ritual while verification gates convert “homemade” into trusted, regulated micro-commerce.',
        ),
        lensSystems: ParadigmProjectLensData(
          headline: 'Privacy-Safe Mapping with Compliance-by-Design',
          metric: 'Verification Conversion + Incident Rate + Order Integrity',
          narrative:
              'Crawl’s architecture treats neighborhoods as distributed micro-commercial zones: real-time open/closed visibility, finite inventory truth, and time-windowed address reveal. Security and governance are embedded as product surfaces: least-privilege access for sensitive location data, hardened transaction state machines to prevent ambiguity, and compliance-aware listing templates (licenses, labeling, category constraints) that guide creators without surveillance vibes. The platform scales by density: as more verified creators join, more walkers join, and the neighborhood becomes a living commerce graph.',
        ),
      },
    ),
  };
}
