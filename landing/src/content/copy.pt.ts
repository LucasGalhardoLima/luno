import type { LandingCopy } from './types';

export const copyPt: LandingCopy = {
  locale: 'pt-BR',
  seo: {
    title: 'Luno - Clareza executável com método PARA e captura por voz',
    description:
      'Luno transforma captura por voz e texto em execução organizada com método PARA, confirmação em um toque e foco real no que importa.',
  },
  nav: {
    cta: 'Entrar na waitlist',
  },
  chapters: {
    hookTagline: 'Capítulo 01 · Caos',
    revealTagline: 'Capítulo 02 · Sinal',
    proofTagline: 'Capítulo 04 · Prova e fluxo',
    finaleTagline: 'Capítulo 05 · Lançamento antecipado',
  },
  hook: {
    eyebrow: 'Luno para iOS',
    title: 'Ideias rápidas pedem um sistema rápido.',
    subtitle:
      'Quando tudo fica em notas soltas, a energia vai para organizar e não para executar. Luno captura no impulso e organiza sem fricção.',
    ctaPrimary: 'Entrar na waitlist',
    ctaSecondary: 'Ver estrutura',
    painChips: ['Notas sem destino', 'Revisão adiada', 'Projetos sem tração', 'Contexto perdido'],
  },
  reveal: {
    title: 'Do ruído mental para estrutura acionável.',
    body:
      'Luno troca a sobrecarga de microdecisões por um fluxo consistente: capturar rápido, organizar com PARA e seguir com clareza.',
    truths: [
      'Capture por voz ou texto no mesmo fluxo.',
      'Receba sugestão de categoria sem parar para classificar manualmente.',
      'Confirme em um toque e volte ao que importa.',
    ],
  },
  paraMap: {
    title: 'Por que PARA é a fundação do Luno',
    subtitle:
      'PARA não é um catálogo complexo. É uma estrutura estável para decidir rápido onde cada ideia vive, sem travar a captura.',
    whyTitle: 'Escolhemos PARA por velocidade e previsibilidade.',
    whyBody:
      'No momento da ideia, o custo de pensar em taxonomia é alto. PARA reduz essa carga e cria um caminho claro para recuperar e executar depois.',
    centerLabel: 'Luno Capture',
    nodes: [
      {
        key: 'projects',
        title: 'Projects',
        body: 'Resultados ativos com prazo e próxima ação definida.',
      },
      {
        key: 'areas',
        title: 'Areas',
        body: 'Responsabilidades contínuas que precisam de manutenção recorrente.',
      },
      {
        key: 'resources',
        title: 'Resources',
        body: 'Conhecimento de referência para decisões e execução futura.',
      },
      {
        key: 'archive',
        title: 'Archive',
        body: 'Materiais inativos preservados sem poluir seu foco atual.',
      },
    ],
    cta: 'Ver prova no produto',
  },
  proofFlow: {
    title: 'Prova real em telas reais, sem promessas artificiais.',
    subtitle:
      'A interface foi desenhada para leitura rápida, confirmação imediata e consistência entre captura e organização.',
    flowTitle: 'Como vira execução',
    steps: [
      {
        title: '1. Capture',
        body: 'Fale ou digite no instante da ideia, sem quebrar contexto.',
      },
      {
        title: '2. Organize',
        body: 'A IA sugere o destino PARA para manter consistência.',
      },
      {
        title: '3. Execute',
        body: 'Você confirma e segue. Menos manutenção, mais avanço.',
      },
    ],
    proofBullets: [
      'Fluxo voice-first com fallback para texto.',
      'Sugestão PARA automática e prática.',
      'Confirmação de categorização em um toque.',
    ],
  },
  credibility: {
    title: 'Construído para uso sério no dia a dia',
    subtitle:
      'Arquitetura orientada a privacidade, experiência nativa iOS e um sistema de organização pensado para durar.',
    badges: ['iOS native', 'privacy-first', 'PARA native', 'on-device + cloud fallback'],
  },
  waitlist: {
    title: 'Acesso antecipado ao Luno',
    subtitle: 'Receba o convite primeiro e acompanhe a evolução da versão iOS.',
    emailLabel: 'Seu melhor e-mail',
    emailPlaceholder: 'voce@email.com',
    submit: 'Quero acesso antecipado',
    pending: 'Enviando...',
    success: 'Perfeito. Você entrou na waitlist.',
    error: 'Não foi possível enviar agora. Tente novamente em instantes.',
    privacyHint: 'Ao enviar, você aceita receber atualizações do lançamento.',
  },
  themeToggle: {
    dark: 'Tema escuro',
    light: 'Tema claro',
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
        body: 'A gestão da lista é feita por provedor externo de formulários e e-mail. Não vendemos seus dados.',
      },
      {
        title: 'Seus direitos',
        body: 'Você pode solicitar remoção da lista a qualquer momento pelo link de descadastro no e-mail ou contato direto.',
      },
    ],
    back: 'Voltar para a landing',
  },
};
