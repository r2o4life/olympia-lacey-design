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
    if (projectId != 'bridge') return null;
    final obj = _bridgebound[objective];
    if (obj == null) return null;
    return obj[_normalizePhase(phase)];
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
      focus: 'Sponsored Micropayments',
      cinematic: ParadigmProjectCinematic(
        kicker: 'Index narrative sandbox',
        title: 'TipZero — execution mapped to objectives',
        subtitle:
            'A cinematic SDLC narrative that ties market mechanics to systems constraints. Each node expands into a live viewport showing the phase-by-phase scaffolding needed to ship safely.',
        nodes: {
          'User Growth': [
            'Discovery: merchant acquisition + employee adoption wedges',
            'Prototype: “tap-to-reward” activation loop + education UX',
            'Build: lightweight account model + frictionless entry',
            'Launch: store listing experiments + onboarding cohorts',
            'Iterate: retention loops + referral incentives',
          ],
          'Monetization': [
            'Discovery: rewarded-ad economics + payout constraints',
            'Prototype: tip trigger moments + value exchange clarity',
            'Build: performance ledger + strategic decoupling for SDK attribution',
            'Launch: funnel instrumentation + revenue-per-session',
            'Iterate: partner optimization + payout tuning',
          ],
          'Improved Governance': [
            'Discovery: policy constraints (App Store + ad networks)',
            'Prototype: compliance-first flow design + guardrails',
            'Build: quality gates + fraud-prevention checks (invalid-traffic aware)',
            'Launch: audit visibility + operational overrides',
            'Iterate: rule refinement + anomaly playbooks',
          ],
          'Improved Security': [
            'Discovery: risk model (abuse, spoofing, invalid traffic)',
            'Prototype: secure state transitions + hardened flows',
            'Build: access control + safe payout boundaries',
            'Launch: monitoring + incident response thresholds',
            'Iterate: security reviews + dependency hardening',
          ],
          'Increased App Engagement': [
            'Discovery: habit loop design + reward timing',
            'Prototype: micro-interactions + feedback cues',
            'Build: performance budgets + latency-first UI',
            'Launch: feature flags + A/B motion variants',
            'Iterate: engagement scoring + nudges',
          ],
        },
      ),
      data: {
        lensMarket: ParadigmProjectLensData(
          headline: 'Eradicating Wallet Fatigue',
          metric: 'Net-New Monetization Funnel',
          narrative:
              'Analyzed the cashless paradox: consumers want to reward good service, but wallet fatigue prevents action. We designed a Digital Tip Jar that triggers merchant-funded employee bonuses via rewarded ad engagement. We led the end-to-end 0-to-1 lifecycle, navigating stringent App Store review processes to launch a market-ready product that opens a new funding avenue.',
        ),
        lensSystems: ParadigmProjectLensData(
          headline: 'Friction Decoupling & Ad SDK Compliance',
          metric: 'Proprietary Performance Ledger',
          narrative:
              'Identified strict AdSense and AppLovin SDK compliance constraints regarding "Invalid Traffic". We architected a "Strategic Decoupling" mechanism—a proprietary Performance Credit ledger separating frontend UX triggers from backend SDK compliance. This decoupled architecture ensures accurate attribution of ad revenue generation versus verifiable employee micropayment payouts.',
        ),
      },
    ),
  };
}
