/**
 * Formspree AJAX form handler.
 * Enhances the waitlist form with fetch-based submission.
 * Falls back to standard HTML form submission if JS fails.
 * Contract: specs/002-lunar-design/contracts/formspree-integration.md
 */
function initFormHandler() {
  const form = document.getElementById("waitlist-form") as HTMLFormElement | null;
  const successMsg = document.getElementById("form-success");
  const errorMsg = document.getElementById("form-error");

  if (!form) return;

  // Populate UTM fields from URL params
  const params = new URLSearchParams(window.location.search);
  const utmSource = document.getElementById("utm_source") as HTMLInputElement | null;
  const utmMedium = document.getElementById("utm_medium") as HTMLInputElement | null;
  const utmCampaign = document.getElementById("utm_campaign") as HTMLInputElement | null;
  const localeField = document.getElementById("form_locale") as HTMLInputElement | null;

  if (utmSource) utmSource.value = params.get("utm_source") || "";
  if (utmMedium) utmMedium.value = params.get("utm_medium") || "";
  if (utmCampaign) utmCampaign.value = params.get("utm_campaign") || "";
  if (localeField) localeField.value = navigator.language || "en";

  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const submitBtn = form.querySelector('button[type="submit"]') as HTMLButtonElement | null;
    const originalText = submitBtn?.textContent || "";

    // Loading state
    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.textContent = "Sending...";
    }

    // Hide previous messages
    successMsg?.classList.add("hidden");
    errorMsg?.classList.add("hidden");

    try {
      const data = new FormData(form);
      const response = await fetch(form.action, {
        method: "POST",
        body: data,
        headers: { Accept: "application/json" },
      });

      if (response.ok) {
        // Success — show thank you message, hide form
        form.classList.add("hidden");
        successMsg?.classList.remove("hidden");
      } else {
        // Validation error
        errorMsg?.classList.remove("hidden");
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.textContent = originalText;
        }
      }
    } catch {
      // Network error
      errorMsg?.classList.remove("hidden");
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.textContent = originalText;
      }
    }
  });
}

initFormHandler();
document.addEventListener("astro:after-swap", initFormHandler);
