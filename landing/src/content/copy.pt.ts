import type { LandingCopy } from './types';

export const copyPt: LandingCopy = {
  locale: 'pt-BR',
  seo: {
    title: 'Luno - Capture por voz e organize com IA no método PARA',
    description:
      'Capture ideias por voz ou texto. O Luno organiza automaticamente no método PARA com confirmação em um toque.',
  },
  nav: {
    languageLabel: 'Idioma',
    cta: 'Entrar na waitlist',
  },
  hero: {
    eyebrow: 'Luno para iOS',
    title: 'Clareza para suas ideias.',
    subtitle:
      'Capture por voz ou texto. O Luno aplica IA para sugerir a categoria certa no método PARA e você confirma em um toque.',
    ctaPrimary: 'Entrar na waitlist',
    ctaSecondary: 'Ver como funciona',
  },
  problem: {
    title: 'Ideias rápidas se perdem quando organizar dá trabalho.',
    body:
      'Capturar é fácil. O atrito está na categorização manual, que quebra o fluxo e leva ao abandono do sistema.',
  },
  solution: {
    title: 'Luno reduz a fricção entre capturar e organizar.',
    bullets: [
      'Voice-first com alternativa de digitação.',
      'Sugestão automática em Projects, Areas, Resources ou Archive.',
      'Confirmação simples em 1 toque, sem fluxo pesado.',
    ],
  },
  steps: {
    title: 'Como funciona',
    items: [
      {
        title: '1. Capturar',
        body: 'Segure o botão e fale. Ou digite quando preferir discrição.',
      },
      {
        title: '2. IA organiza',
        body: 'Luno sugere a categoria PARA com base no contexto da nota.',
      },
      {
        title: '3. Confirmar',
        body: 'Aceite ou ajuste. Sua nota entra no fluxo sem burocracia.',
      },
    ],
  },
  credibility: {
    title: 'Feito para execução real no iPhone',
    badges: ['iOS native', 'privacy-first', 'PARA native', 'on-device + cloud fallback'],
  },
  waitlist: {
    title: 'Acesso antecipado ao Luno',
    subtitle: 'Entre na waitlist para testar primeiro e receber novidades do lançamento.',
    emailLabel: 'Seu melhor e-mail',
    emailPlaceholder: 'voce@email.com',
    submit: 'Quero acesso antecipado',
    pending: 'Enviando...',
    success: 'Obrigado. Você entrou na waitlist.',
    error: 'Não foi possível enviar agora. Tente novamente em instantes.',
    privacyHint: 'Ao enviar, você aceita receber e-mails sobre o lançamento.',
  },
  footer: {
    privacy: 'Privacidade',
    contact: 'Contato',
    rights: 'Todos os direitos reservados.',
  },
  privacyPage: {
    title: 'Política de Privacidade - Waitlist Luno',
    updatedAt: 'Atualizado em 06 de fevereiro de 2026',
    intro: 'Esta página explica como tratamos os dados enviados na waitlist da landing do Luno.',
    items: [
      {
        title: 'Dados coletados',
        body: 'Coletamos apenas o e-mail informado no formulário, além de metadados de campanha (como UTM) quando disponíveis.',
      },
      {
        title: 'Finalidade',
        body: 'Usamos esses dados para avisar sobre acesso antecipado, novidades do produto e lançamento da versão iOS.',
      },
      {
        title: 'Compartilhamento',
        body: 'A gestão da lista é feita por provedor externo de e-mail marketing (ConvertKit). Não vendemos seus dados.',
      },
      {
        title: 'Seus direitos',
        body: 'Você pode solicitar remoção da lista a qualquer momento pelo link de descadastro no e-mail ou contato direto.',
      },
    ],
    back: 'Voltar para a landing',
  },
};
