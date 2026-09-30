document.addEventListener("DOMContentLoaded", () => {
  const setPanelState = (button, open) => {
    const panel = document.getElementById(button.getAttribute("aria-controls"));
    if (!panel) return;
    button.setAttribute("aria-expanded", String(open));
    panel.hidden = !open;
    panel.classList.toggle("open", open);
  };

  document.querySelectorAll("button[data-publication-panel]").forEach((button) => {
    button.addEventListener("click", () => {
      const open = button.getAttribute("aria-expanded") !== "true";
      const scope = button.closest(".links");
      scope?.querySelectorAll("button[data-publication-panel]").forEach((other) => setPanelState(other, false));
      setPanelState(button, open);
    });
  });

  document.querySelectorAll("button.more-authors").forEach((button) => {
    button.addEventListener("click", () => {
      const open = button.getAttribute("aria-expanded") !== "true";
      button.innerHTML = open ? button.dataset.authors : button.dataset.summary;
      button.setAttribute("aria-expanded", String(open));
    });
  });

  document.querySelectorAll(".publications .bibtex pre code").forEach((code) => {
    const pre = code.closest("pre");
    const wrapper = document.createElement("div");
    wrapper.className = "code-display-wrapper";
    pre.before(wrapper);
    wrapper.append(pre);

    const button = document.createElement("button");
    button.className = "copy";
    button.type = "button";
    button.setAttribute("aria-live", "polite");
    const reset = () => {
      button.innerHTML = '<i class="fa-solid fa-clipboard" aria-hidden="true"></i>';
      button.setAttribute("aria-label", "Copy BibTeX");
      button.title = "Copy BibTeX";
    };
    reset();
    wrapper.append(button);

    let resetTimer;
    button.addEventListener("click", async () => {
      clearTimeout(resetTimer);
      button.disabled = true;
      try {
        await navigator.clipboard.writeText(code.textContent.trim());
        button.innerHTML = '<i class="fa-solid fa-clipboard-check" aria-hidden="true"></i>';
        button.setAttribute("aria-label", "BibTeX copied");
        button.title = "Copied";
      } catch {
        button.textContent = "Copy failed";
        button.setAttribute("aria-label", "Copy failed. Select the BibTeX and copy manually.");
        button.title = "Select the BibTeX and copy manually.";
      } finally {
        button.disabled = false;
        resetTimer = setTimeout(reset, 3000);
      }
    });
  });
});
