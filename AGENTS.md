# Personal homepage maintenance

## Scope

- This repository owns the source and published assets for Youtan Yin's personal
  homepage at `https://cuteyyt.github.io/`.
- Maintain it locally and publish through GitHub Pages. It is excluded from
  research-server deployment and does not depend on the research server.
- Edit personal information in `_pages/about.md` and `_data/socials.yml`,
  publications in `_bibliography/papers.bib`, and announcements in `_news/`.
- The current pages are About, Publications, and the 404 page. News stays inline
  on the homepage: `collections.news.output` is false and announcements use
  `inline: true`. Do not generate news listing or detail pages or link the News
  heading to a separate page. Enable optional theme features when an actual page
  needs them; do not restore starter
  example data or demonstration assets as a build workaround.
- The installed `al_folio_core` theme supplies the shared runtime. Preserve its
  license and attribution, and respect the versions in `Gemfile.lock`.
- Local Liquid overrides live under `_includes/` and `_layouts/`. The scripts
  include loads the runtime needed by the current pages. Local JS fixes live
  under `assets/js/`; `assets/css/main.scss` imports the theme Sass modules and
  `_sass/_homepage.scss` adds the shared publication styles.
- The introduction uses two columns with a compact portrait on desktop and a
  stacked layout on mobile. Keep paragraph spacing and image proportions intact.
- Show publication thumbnails only in the homepage's Selected Publications.
  The full Publications list uses the same text-only layout for every entry.
- Publication panels and author expansion use native buttons. Keep keyboard
  activation, focus styles, `aria-expanded`, and panel visibility synchronized.
  Preserve standard citation fields such as `eprint` in exported BibTeX.
- Filtering must search the same citation metadata and author names with or
  without the browser's highlight API, and malformed URL fragments must not
  break it. Show copy success only after the clipboard operation succeeds.

## Resume and publication assets

- The resume's source and final PDF are maintained in `../../latex/resume/`.
  Follow that repository's `AGENTS.md` when the user requests resume changes.
- The resume entry in `_data/socials.yml` links to a shared Google Drive file.
  After a verified resume build, provide the final PDF for the user to upload
  as a new version of that existing Drive file. Keep the shared link stable and
  check public access after an update.
- Publications link to externally hosted papers and supplements through
  `_bibliography/papers.bib`. Keep paper PDF files out of this website
  repository; use arXiv or official pages where suitable, and stable shared
  files for versions not available there. Check public access to shared links
  after each update.
- Keep resume PDF copies out of this website repository as well; the local
  LaTeX final and the shared Drive file are the maintained copies.

## Local validation

- Run from this repository root using the existing Ruby/Bundler environment:

  ```text
  bundle check
  bundle exec jekyll build
  ```

- Preview the built website with:

  ```text
  bundle exec jekyll serve --host 127.0.0.1 --port 4000 --skip-initial-build
  ```

- Keep generated website files in `_site/` and temporary checks, logs, browser
  profiles, and screenshots in `output/`. These directories stay outside Git
  version control; this guide and `output/` are excluded from the published site.
- Verify the main pages, inline news, local links and assets, the shared resume
  link, external publication links, publication filtering and buttons, search, theme
  switching, and mobile navigation after changes affecting those features.
- Inactive starter dependencies remain in the locked bundle with
  `require: false`. Keep them disabled in both `Gemfile` and `_config.yml`;
  removing a dependency is a separate lockfile change. Math, charts, comments,
  and blog integrations stay disabled until an actual page needs them.
- Keep the website portrait at a suitable display resolution and the favicon
  small. Image optimization intermediates belong in `output/`, not published
  assets. Open Graph images use absolute public URLs.

## Git and publication

- Follow the workspace requirement for explicit user approval before creating
  any Git commit.
- `main` holds the website source; `gh-pages` holds generated publishing output.
- `deploy.sh` builds the site, creates a publishing commit, and pushes
  `gh-pages`. Treat running it as a publication action requiring explicit user
  authorization. Use the local validation commands while reviewing changes.
- Use the Jekyll preview above for local review. Publishing worktrees are unique
  directories under `output/deploy/`. Successful publication removes its clean
  temporary worktree; failed publishing attempts are retained for review. Never
  force-delete a dirty or unrelated worktree, or reset the local publishing
  branch as cleanup.
- Obtain explicit user authorization before pushing or publishing. Successful
  local validation alone does not authorize a remote update.
