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
            'A cinematic, SDLC-driven view of the work: each objective expands into the phases, decisions, and guardrails required to ship responsibly. Tap nodes to reveal a live template viewport.',
        nodes: {
          'User Growth': [
            'Discovery: parent/teacher friction mapping + demand signals',
            'Signal: “zero-latency” onboarding as the adoption wedge',
            'Prototype: onboarding loop + instant value reveal',
            'Build: low-latency curriculum ingestion + scenario generation',
            'Launch: cohort-based activation metrics + referral hooks',
            'Iterate: retention drivers + personalization guardrails',
          ],
          'Monetization': [
            'Discovery: pricing hypotheses (district / family / hybrid)',
            'Prototype: paywall placement + value metric simulation',
            'Build: entitlements + billing boundary isolation',
            'Launch: conversion funnels + offer experiments',
            'Iterate: LTV/CAC tuning + packaging refinement',
          ],
          'Improved Governance': [
            'Discovery: role mapping (parent / teacher / admin) + policies',
            'Prototype: permission model + content approval flows',
            'Build: audit events + immutable change history',
            'Launch: quality gates + operational playbooks',
            'Iterate: governance metrics + policy tuning cadence',
          ],
          'Improved Security': [
            'Discovery: threat model + privacy requirements (COPPA/FERPA-aware)',
            'Prototype: secure boundaries for home vs school data streams',
            'Build: least-privilege access + secure LLM prompting + dual-stream isolation',
            'Launch: incident runbooks + monitoring thresholds',
            'Iterate: hardening sprints + dependency risk reviews',
          ],
          'Increased App Engagement': [
            'Discovery: engagement loops (micro-wins + progress cues)',
            'Prototype: interaction + motion language for clarity',
            'Build: performance budgets + zero-jank UI patterns',
            'Launch: instrumentation + funnel drop-off detection',
            'Iterate: content cadence + adaptive difficulty tuning',
          ],
        },
      ),
      data: {
        lensMarket: ParadigmProjectLensData(
          headline: 'Frictionless Adoption via Invisible AI',
          metric: 'Zero-Latency Beta Onboarding',
          narrative:
              'Identified parent cognitive overload as the primary friction point. We architected a dual-stream data model to ingest teacher curricula and parent interactions, translating them instantly via LLMs into applied, real-world educational scenarios. We shipped the native iOS MVP under strict privacy frameworks, realizing the initial vision while setting the stage for district-wide scaling.',
        ),
        lensSystems: ParadigmProjectLensData(
          headline: 'Secure Dual-Stream LLM Pipelines',
          metric: 'Closed-Loop Feedback Architecture',
          narrative:
              'Defined system boundaries early to bridge distinct home and school ecosystems without complex manual data entry. We established a secure digital thread from unstructured user input to LLM generation to front-end display. The operational boundaries empowered rapid shipping of iOS features completely independent of the core AI model tuning.',
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
