import type { LandingCopy } from './types';

export const copyEn: LandingCopy = {
  locale: 'en-US',
  seo: {
    title: 'Luno - Executable clarity with PARA and voice capture',
    description:
      'Luno turns voice and text capture into organized execution using PARA, one-tap confirmation, and a focused workflow built for real use.',
  },
  nav: {
    cta: 'Join the waitlist',
  },
  chapters: {
    hookTagline: 'Chapter 01 · Chaos',
    revealTagline: 'Chapter 02 · Signal',
    proofTagline: 'Chapter 04 · Proof and flow',
    finaleTagline: 'Chapter 05 · Early access',
  },
  hook: {
    eyebrow: 'Luno for iOS',
    title: 'Fast ideas need a fast system.',
    subtitle:
      'When everything ends up in scattered notes, your energy goes to organizing instead of executing. Luno captures instantly and structures without drag.',
    ctaPrimary: 'Join the waitlist',
    ctaSecondary: 'See the structure',
    painChips: ['Scattered notes', 'Delayed review', 'Stalled projects', 'Lost context'],
  },
  reveal: {
    title: 'From mental noise to actionable structure.',
    body:
      'Luno replaces taxonomy overload with a consistent flow: capture quickly, organize with PARA, and keep moving with clarity.',
    truths: [
      'Capture by voice or text in the same flow.',
      'Get category suggestions without stopping to classify manually.',
      'Confirm with one tap and return to execution.',
    ],
  },
  paraMap: {
    title: 'Why PARA is the foundation behind Luno',
    subtitle:
      'PARA is not a heavy filing system. It is a stable structure that makes fast placement and reliable retrieval possible.',
    whyTitle: 'We chose PARA for speed and predictability.',
    whyBody:
      'At capture time, taxonomy decisions are expensive. PARA reduces that load and creates a reliable path from idea to execution.',
    centerLabel: 'Luno Capture',
    nodes: [
      {
        key: 'projects',
        title: 'Projects',
        body: 'Active outcomes with deadlines and clear next actions.',
      },
      {
        key: 'areas',
        title: 'Areas',
        body: 'Ongoing responsibilities that require recurring maintenance.',
      },
      {
        key: 'resources',
        title: 'Resources',
        body: 'Reference knowledge that supports future decisions and execution.',
      },
      {
        key: 'archive',
        title: 'Archive',
        body: 'Inactive material kept safely without polluting current focus.',
      },
    ],
    cta: 'See product proof',
  },
  proofFlow: {
    title: 'Real proof with real screens, no inflated claims.',
    subtitle:
      'The interface is built for fast reading, immediate confirmation, and consistency between capture and organization.',
    flowTitle: 'How it becomes execution',
    steps: [
      {
        title: '1. Capture',
        body: 'Speak or type the instant an idea appears, without context switching.',
      },
      {
        title: '2. Organize',
        body: 'AI suggests the PARA destination to keep your system consistent.',
      },
      {
        title: '3. Execute',
        body: 'Confirm and continue. Less maintenance, more progress.',
      },
    ],
    proofBullets: [
      'Voice-first flow with text fallback.',
      'Practical automatic PARA suggestions.',
      'One-tap categorization confirmation.',
    ],
  },
  credibility: {
    title: 'Built for serious day-to-day use',
    subtitle:
      'Privacy-oriented architecture, native iOS experience, and an organization model designed to hold over time.',
    badges: ['iOS native', 'privacy-first', 'PARA native', 'on-device + cloud fallback'],
  },
  waitlist: {
    title: 'Get early access to Luno',
    subtitle: 'Be first in line and follow the iOS launch evolution.',
    emailLabel: 'Your best email',
    emailPlaceholder: 'you@email.com',
    submit: 'Get early access',
    pending: 'Submitting...',
    success: 'Great. You are on the waitlist.',
    error: 'Could not submit now. Please try again shortly.',
    privacyHint: 'By submitting, you agree to receive launch updates.',
  },
  themeToggle: {
    dark: 'Dark theme',
    light: 'Light theme',
  },
  footer: {
    privacy: 'Privacy',
    contact: 'Contact',
    rights: 'All rights reserved.',
  },
  privacyPage: {
    title: 'Privacy Policy - Luno Waitlist',
    updatedAt: 'Updated on February 6, 2026',
    intro: 'This page explains how we handle data submitted through the Luno landing waitlist.',
    items: [
      {
        title: 'Data we collect',
        body: 'We collect the email entered in the form plus campaign metadata (such as UTM) when available.',
      },
      {
        title: 'Why we collect it',
        body: 'We use this data to share early access, product updates, and launch information for the iOS app.',
      },
      {
        title: 'Sharing',
        body: 'List management is handled by an external form and email provider. We do not sell your data.',
      },
      {
        title: 'Your rights',
        body: 'You can request removal at any time through the unsubscribe link in emails or by contacting us directly.',
      },
    ],
    back: 'Back to landing',
  },
};
