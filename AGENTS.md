# Personal homepage maintenance

## Maintenance

- Maintain this website locally and publish through GitHub Pages, independently
  of the research server.
- Enable optional theme features only for an actual need. Do not restore starter
  examples or demonstration assets as a build workaround.
- Maintain the resume's source and final PDF in `../../latex/resume/`; follow
  that repository's `AGENTS.md` when changing the resume.
- Keep resume, paper, and supplementary PDF copies out of this website
  repository. Use arXiv or official sources where suitable, and confirmed shared
  links for final versions hosted elsewhere.
- The user manages Google Drive uploads. After a verified PDF build, provide
  the final file for the user to upload as a new version of the existing shared
  file. Keep the link stable and check public access after an update.
- When changing shared EditVerse3D resource links or formal citation information,
  check consistency with `../editverse3d.github.io/`.

## Local preview

Build from the repository root with the existing Ruby/Bundler environment using
`bundle exec jekyll build`. Then run this command from `_site/`:

```text
python -m http.server 0 --bind 127.0.0.1
```

Port `0` selects an available port; use the URL printed in the terminal.
After source changes, rebuild from the repository root before refreshing the
preview; the Python server does not rebuild Jekyll automatically.

Keep temporary review artifacts in the ignored `output/` directory, outside Git
and published content.

## Publication

- `main` holds source; `gh-pages` holds generated publishing output. Publish
  through the existing `deploy.sh`: run `bash ./deploy.sh` from the repository
  root in Git Bash. The script builds the website, creates a publishing commit,
  and pushes `gh-pages`.
- Obtain explicit user authorization before pushing or publishing, including
  running `deploy.sh`. Successful local review alone does not authorize a remote
  update. After publication, check the deployment result and live website.
