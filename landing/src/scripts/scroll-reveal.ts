/**
 * Scroll-reveal system using Intersection Observer.
 * Adds `.visible` class to `.reveal` and `.reveal-stagger` elements
 * when they enter the viewport. Respects prefers-reduced-motion.
 */
function initScrollReveal() {
  const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  if (prefersReducedMotion) {
    // Make all reveal elements immediately visible
    document.querySelectorAll(".reveal, .reveal-stagger").forEach((el) => {
      el.classList.add("visible");
    });
    return;
  }

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("visible");
          observer.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.15,
      rootMargin: "0px 0px -40px 0px",
    }
  );

  document.querySelectorAll(".reveal, .reveal-stagger").forEach((el) => {
    observer.observe(el);
  });
}

initScrollReveal();
document.addEventListener("astro:after-swap", initScrollReveal);
