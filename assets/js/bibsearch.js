import { highlightSearchTerm } from "./highlight-search-term.js";

document.addEventListener("DOMContentLoaded", () => {
  const input = document.getElementById("bibsearch");
  const publications = document.querySelector(".publications");
  if (!input || !publications) return;

  const normalize = (text) => text.toLowerCase().replace(/\s+/g, " ").trim();
  // Include citation metadata and collapsed authors regardless of browser features.
  const items = Array.from(publications.querySelectorAll("ol.bibliography > li"), (element) => ({
    element,
    text: normalize(element.textContent + " " + (element.querySelector(".more-authors")?.dataset.authors ?? "")),
  }));
  const filterItems = (value) => {
    const search = normalize(value);
    if (CSS.highlights) highlightSearchTerm({ search, selector: ".publications .bibliography > li" });
    items.forEach(({ element, text }) => element.classList.toggle("unloaded", !text.includes(search)));

    publications.querySelectorAll("ol.bibliography").forEach((list) => {
      const empty = !list.querySelector(":scope > li:not(.unloaded)");
      list.classList.toggle("unloaded", empty);
      const heading = list.previousElementSibling;
      if (heading?.matches("h2.bibliography")) heading.classList.toggle("unloaded", empty);
    });
  };

  let timeoutId;
  input.addEventListener("input", () => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => filterItems(input.value), 300);
  });

  const updateFromHash = () => {
    let value = window.location.hash.slice(1);
    try {
      value = decodeURIComponent(value);
    } catch {
      // A malformed fragment remains a literal search instead of breaking the filter.
    }
    clearTimeout(timeoutId);
    input.value = value;
    filterItems(value);
  };
  window.addEventListener("hashchange", updateFromHash);
  updateFromHash();
});
