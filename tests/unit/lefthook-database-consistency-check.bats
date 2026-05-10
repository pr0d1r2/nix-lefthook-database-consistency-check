#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"

    git init "$TMP/repo" >/dev/null 2>&1

    mkdir -p "$TMP/bin"
    cat > "$TMP/bin/bundle" <<'SH'
#!/usr/bin/env bash
if [ -f "$MOCK_BUNDLE_OUTPUT" ]; then
    cat "$MOCK_BUNDLE_OUTPUT"
else
    echo ""
fi
SH
    chmod +x "$TMP/bin/bundle"

    # shellcheck disable=SC2030
    export PATH="$TMP/bin:$PATH"
}

@test "exits 0 when no output" {
    cd "$TMP/repo" || return
    # shellcheck disable=SC2031,SC2030
    export MOCK_BUNDLE_OUTPUT="$TMP/empty_output"
    touch "$MOCK_BUNDLE_OUTPUT"
    run lefthook-database-consistency-check
    assert_success
}

@test "exits 1 when fail detected" {
    cd "$TMP/repo" || return
    # shellcheck disable=SC2031,SC2030
    export MOCK_BUNDLE_OUTPUT="$TMP/fail_output"
    cat > "$MOCK_BUNDLE_OUTPUT" <<'OUTPUT'
UsersUser email column is required but do not have presence validator fail
UsersUser name column is required but do not have presence validator fail
OUTPUT
    run lefthook-database-consistency-check
    assert_failure
    assert_output --partial "fail"
}

@test "passes through non-fail output" {
    cd "$TMP/repo" || return
    # shellcheck disable=SC2031
    export MOCK_BUNDLE_OUTPUT="$TMP/pass_output"
    cat > "$MOCK_BUNDLE_OUTPUT" <<'OUTPUT'
UsersUser email column is required and has presence validator pass
UsersUser name column is required and has presence validator pass
OUTPUT
    run lefthook-database-consistency-check
    assert_success
    assert_output --partial "pass"
}
