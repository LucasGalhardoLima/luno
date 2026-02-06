/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        bg0: 'var(--bg-0)',
        bg1: 'var(--bg-1)',
        brand600: 'var(--brand-600)',
        brand500: 'var(--brand-500)',
        moon400: 'var(--moon-400)',
        text0: 'var(--text-0)',
        text1: 'var(--text-1)',
      },
      fontFamily: {
        display: ['Syne', 'sans-serif'],
        body: ['Instrument Sans', 'sans-serif'],
      },
      boxShadow: {
        lunar: '0 24px 80px rgba(59, 130, 246, 0.28)',
        card: '0 16px 48px rgba(2, 6, 23, 0.45)',
      },
      keyframes: {
        halo: {
          '0%, 100%': { boxShadow: '0 0 0 0 rgba(96,165,250,0.35)' },
          '50%': { boxShadow: '0 0 0 18px rgba(96,165,250,0)' },
        },
        fadeSlide: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
      animation: {
        halo: 'halo 2.5s ease-in-out infinite',
        fadeSlide: 'fadeSlide 700ms ease-out both',
      },
    },
  },
  plugins: [],
};
