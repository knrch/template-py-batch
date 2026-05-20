# shellcheck shell=bash
# Gitleaks + Semgrep helpers. Source after scripts/_lib.sh (require_tool, REPO_ROOT, log_*).

# gitleaks v8: `dir <a> <b>` scans the common ancestor entire tree. Iterate per-path
# to keep scans scoped.
collect_gitleaks_audit_targets() {
  GITLEAKS_AUDIT_TARGETS=(
    "$REPO_ROOT/README.md"
    "$REPO_ROOT/PLAN.md"
    "$REPO_ROOT/REQUIREMENTS.md"
    "$REPO_ROOT/docker-compose.yml"
    "$REPO_ROOT/Dockerfile"
    "$REPO_ROOT/pyproject.toml"
    "$REPO_ROOT/src"
    "$REPO_ROOT/tests"
    "$REPO_ROOT/scripts"
    "$REPO_ROOT/docs"
  )
}

run_gitleaks_audit_all() {
  require_tool gitleaks gitleaks "https://github.com/gitleaks/gitleaks#installing"

  collect_gitleaks_audit_targets
  local fail=0 t
  echo
  log_info "=== Gitleaks (source tree, per-path scans) ==="
  for t in "${GITLEAKS_AUDIT_TARGETS[@]}"; do
    [[ -e "$t" ]] || continue
    if ! gitleaks dir --no-banner -c "$REPO_ROOT/.gitleaks.toml" "$t"; then
      fail=1
    fi
  done
  return "$fail"
}

run_semgrep_audit_all() {
  require_tool semgrep semgrep "https://semgrep.dev/docs/getting-started/"
  echo
  log_info "=== Semgrep (p/python) src ==="
  (
    cd "$REPO_ROOT" && semgrep scan --metrics=off --error \
      --disable-version-check \
      --config=p/python \
      src
  )
}

run_semgrep_staged() {
  require_tool semgrep semgrep "https://semgrep.dev/docs/getting-started/"
  local args=()
  local f relpath
  while IFS= read -r relpath; do
    [[ -n "$relpath" ]] || continue
    case "$relpath" in
      *.py) ;;
      *) continue ;;
    esac
    f="$REPO_ROOT/$relpath"
    [[ -f "$f" ]] || continue
    args+=("$f")
  done < <(git -C "$REPO_ROOT" diff --cached --name-only --diff-filter=ACMRT)

  if [[ "${#args[@]}" -eq 0 ]]; then
    log_info "=== Pre-commit: Semgrep (no staged .py files) — skip ==="
    return 0
  fi

  echo
  log_info "=== Pre-commit: Semgrep (staged Python files) ==="
  semgrep scan --metrics=off --error \
    --disable-version-check \
    --config=p/python \
    "${args[@]}"
}

run_gitleaks_git_staged() {
  require_tool gitleaks gitleaks "https://github.com/gitleaks/gitleaks#installing"

  echo
  log_info "=== Pre-commit: gitleaks git --staged ==="
  (cd "$REPO_ROOT" && gitleaks git --staged --no-banner -c "$REPO_ROOT/.gitleaks.toml" "$REPO_ROOT")
}
