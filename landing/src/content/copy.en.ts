import type { LandingCopy } from './types';

export const copyEn: LandingCopy = {
  locale: 'en-US',
  seo: {
    title: 'Luno - Capture by voice and organize with PARA AI',
    description:
      'Capture ideas by voice or text. Luno automatically suggests PARA categories with one-tap confirmation.',
  },
  nav: {
    languageLabel: 'Language',
    cta: 'Join the waitlist',
  },
  hero: {
    eyebrow: 'Luno for iOS',
    title: 'Clarity for your ideas.',
    subtitle:
      'Capture by voice or text. Luno uses AI to suggest the right PARA category, then you confirm in one tap.',
    ctaPrimary: 'Join the waitlist',
    ctaSecondary: 'See how it works',
  },
  problem: {
    title: 'Fast ideas get lost when organizing feels heavy.',
    body:
      'Capturing is easy. Manual categorization is where friction starts, breaks flow, and causes abandonment.',
  },
  solution: {
    title: 'Luno removes friction between capture and organization.',
    bullets: [
      'Voice-first with text fallback.',
      'Automatic PARA suggestions: Projects, Areas, Resources, Archive.',
      'Simple one-tap confirmation, no bloated flow.',
    ],
  },
  steps: {
    title: 'How it works',
    items: [
      {
        title: '1. Capture',
        body: 'Hold the button and speak. Or type whenever privacy matters.',
      },
      {
        title: '2. AI organizes',
        body: 'Luno suggests the best PARA category based on note context.',
      },
      {
        title: '3. Confirm',
        body: 'Accept or adjust. Your note stays in flow without overhead.',
      },
    ],
  },
  credibility: {
    title: 'Built for real execution on iPhone',
    badges: ['iOS native', 'privacy-first', 'PARA native', 'on-device + cloud fallback'],
  },
  waitlist: {
    title: 'Get early access to Luno',
    subtitle: 'Join the waitlist to test first and receive launch updates.',
    emailLabel: 'Your best email',
    emailPlaceholder: 'you@email.com',
    submit: 'Get early access',
    pending: 'Submitting...',
    success: 'Thanks. You are on the waitlist.',
    error: 'Could not submit right now. Please try again shortly.',
    privacyHint: 'By submitting, you agree to receive launch emails.',
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
        body: 'Email list operations are handled by an external email provider (ConvertKit). We do not sell your data.',
      },
      {
        title: 'Your rights',
        body: 'You can request removal at any time using the unsubscribe link in emails or by contacting us directly.',
      },
    ],
    back: 'Back to landing',
  },
};
