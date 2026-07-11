---
layout: page
permalink: /publications/
title: Publications
description: Publications in reversed chronological order.
nav: true
nav_order: 2
---

<style>
  /* Inline badge for entries without a preview thumbnail — sits next to the title, no left column reservation */
  .publications .badge-inline {
    display: inline-block;
    background-color: var(--global-theme-color);
    color: var(--global-card-bg-color) !important;
    padding: 0.15rem 0.55rem;
    margin-right: 0.55rem;
    margin-bottom: 0.35rem;
    font-size: 0.85rem;
    font-weight: 500;
    text-decoration: none;
    vertical-align: middle;
    line-height: 1.4;
  }
  .publications .badge-inline a {
    color: inherit !important;
    text-decoration: none;
  }
</style>

<!-- Bibsearch Feature -->

{% include bib_search.liquid %}

<div class="publications">

{% bibliography %}

</div>
