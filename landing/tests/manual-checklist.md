# Manual QA Checklist

## Conteúdo e idioma

- [ ] Abrir `/` em PT-BR por padrão quando `navigator.language` for `pt-*`.
- [ ] Alternar idioma para EN no toggle sem recarregar a página.
- [ ] Confirmar que todas as seções mantêm estrutura e copy equivalente em PT/EN.

## Conversão

- [ ] Clicar CTA do hero envia para `#waitlist` e dispara evento `hero_cta_click`.
- [ ] Enviar e-mail válido exibe mensagem de sucesso inline.
- [ ] Enviar e-mail inválido exibe mensagem de erro acessível (`aria-live`).
- [ ] Honeypot preenchido impede envio.

## UTM

- [ ] Acessar com query `?utm_source=x&utm_campaign=y`.
- [ ] Verificar hidden inputs do formulário preenchidos com UTM.
- [ ] Verificar links internos com `data-preserve-utm` preservando parâmetros.

## Responsividade

- [ ] 320px: sem overflow horizontal e CTA legível.
- [ ] 768px: grid e spacing consistentes.
- [ ] 1024px: hero em duas colunas equilibradas.
- [ ] 1440px: largura máxima e ritmo visual corretos.

## Acessibilidade

- [ ] Navegação por teclado com foco visível em botões/links/campos.
- [ ] Contraste AA em textos principais.
- [ ] Labels de input e toggle de idioma presentes.

## Performance

- [ ] Lighthouse mobile >= 95 (Performance, Best Practices, SEO).
- [ ] LCP < 2.5s e CLS < 0.1.
