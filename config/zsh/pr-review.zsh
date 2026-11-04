# PR reviews in OMP with the saved prompts of config/review-prompts.
#
#   omp-review [PR] [extra focus]        first review (OMP's /review)
#   omp-review-final [PR] [extra focus]  merge-readiness check
#
# PR is a number or a URL; without it, the PR of the current branch. Set
# OMP_REVIEW_DRY_RUN=1 to print the message instead of starting OMP.

_PR_REVIEW_PROMPTS="${${(%):-%x}:A:h:h}/review-prompts"

_omp_pr_review() {
  local prompt_file="$_PR_REVIEW_PROMPTS/$1"
  shift
  local pr="${1:-}"
  (( $# )) && shift
  local url
  if [[ "$pr" == https://* ]]; then
    url="$pr"
  else
    # /review only takes a PR by URL; gh resolves a number or the branch's PR.
    url=$(gh pr view ${pr:+"$pr"} --json url -q .url) || return
  fi
  local message="/review $url $(<"$prompt_file")"
  (( $# )) && message+=$'\n\n'"Foco extra: $*"
  if [[ -n "$OMP_REVIEW_DRY_RUN" ]]; then
    print -r -- "$message"
    return
  fi
  omp "$message"
}

omp-review() { _omp_pr_review omp-review.md "$@"; }
omp-review-final() { _omp_pr_review omp-final.md "$@"; }
