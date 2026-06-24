#!/usr/bin/env bash
set -euo pipefail

SCRIPT="/baul/aplicaciones/configuracion/Scripts/Bash/compresor.sh"
PASS=0; FAIL=0; TOTAL=0

RESET='\033[0m'; GREEN='\033[0;32m'; RED='\033[0;31m'; CYAN='\033[0;36m'; BOLD='\033[1m'

TDIR=$(mktemp -d)
trap 'rm -rf "$TDIR"' EXIT

setup() {
    rm -rf "$TDIR" && mkdir -p "$TDIR"
    echo "hello world 123" > "$TDIR/file_a.txt"
    echo "data line 2" > "$TDIR/file_b.txt"
}

assert_rc() {
    local desc=$1 exp=$2 out
    TOTAL=$((TOTAL + 1))
    set +e
    eval "$3" &>/dev/null; local rc=$?
    set -e
    if [[ "$rc" -eq "$exp" ]]; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
        printf "${RED}[FAIL]${RESET} %s — RC esperado %s, obtenido %s\n" "$desc" "$exp" "$rc" >&2
    fi
}

assert_out_contains() {
    local desc=$1 pat=$2 out=$3
    TOTAL=$((TOTAL + 1))
    if echo "$out" | grep -qF -- "$pat"; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
        printf "${RED}[FAIL]${RESET} %s — output no contiene '%s'\n" "$desc" "$pat" >&2
    fi
}

# ==============================================================================
# HELP / LIST
# ==============================================================================
setup
printf "${CYAN}%s${RESET}\n" "=== HELP / LIST ==="
OUT=$("$SCRIPT" -h 2>&1 || true)
assert_out_contains "help muestra --install" "--install" "$OUT"
OUT=$("$SCRIPT" -l 2>&1 || true)
assert_out_contains "list muestra lrz" "lrz" "$OUT"

# ==============================================================================
# VALIDATION
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== VALIDATION ==="
assert_rc "sin modo falla" 1 "\"$SCRIPT\""
assert_rc "sin formato falla" 1 "\"$SCRIPT\" -c"
assert_rc "decompress sin input falla" 1 "\"$SCRIPT\" -d"
assert_rc "test sin input falla" 1 "\"$SCRIPT\" -t"

# ==============================================================================
# DRY-RUN
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== DRY-RUN ==="
OUT=$("$SCRIPT" -c gz -n test_dry --dry-run "$TDIR/file_a.txt" 2>&1 || true)
assert_out_contains "dry-run muestra pigz" "pigz" "$OUT"
OUT=$("$SCRIPT" -c zst -i --dry-run "$TDIR/file_a.txt" "$TDIR/file_b.txt" 2>&1 || true)
assert_out_contains "dry-run individual muestra Archivo" "Archivo:" "$OUT"

# ==============================================================================
# FULL CYCLE — 10 FORMATS
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== FULL CYCLE ALL FORMATS ==="
for fmt in gz xz bz2 zst lz lrz zip 7z tar; do
    setup
    case $fmt in
        gz)  ext="tar.gz"  ;; xz)  ext="tar.xz"  ;; bz2) ext="tar.bz2" ;;
        zst) ext="tar.zst" ;; lz)  ext="tar.lz"  ;; lrz) ext="tar.lrz" ;;
        zip) ext="zip"     ;; 7z)  ext="7z"      ;; tar) ext="tar"     ;;
    esac
    fn="test_${fmt}.${ext}"

    # compress
    (cd "$TDIR" && "$SCRIPT" -c "$fmt" -n "test_${fmt}" file_a.txt file_b.txt) 2>/dev/null
    assert_rc "compress $fmt" 0 "[[ -f \"$TDIR/$fn\" ]]"

    # decompress into fresh dir
    ddir="$TDIR/d_${fmt}"
    mkdir -p "$ddir"
    cp "$TDIR/$fn" "$ddir/"
    (cd "$ddir" && "$SCRIPT" -d "$fn") 2>/dev/null
    assert_rc "decompress $fmt file_a" 0 "[[ -f \"$ddir/file_a.txt\" ]]"
    assert_rc "decompress $fmt file_b" 0 "[[ -f \"$ddir/file_b.txt\" ]]"
done

# ==============================================================================
# DELETE ORIGINAL (-r)
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== DELETE ORIGINAL ==="
setup
(cd "$TDIR" && "$SCRIPT" -c gz -r -n test_rdir file_a.txt) 2>/dev/null
assert_rc "-r: original borrado" 1 "[[ -f \"$TDIR/file_a.txt\" ]]"

# ==============================================================================
# TEST INTEGRITY
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== TEST INTEGRITY ==="
setup
(cd "$TDIR" && "$SCRIPT" -c gz -n test_t file_a.txt) 2>/dev/null
assert_rc "test integrity valid gz" 0 "\"$SCRIPT\" -t \"$TDIR/test_t.tar.gz\""
(cd "$TDIR" && "$SCRIPT" -c zst -n test_t2 file_b.txt) 2>/dev/null
assert_rc "test integrity valid zst" 0 "\"$SCRIPT\" -t \"$TDIR/test_t2.tar.zst\""
echo "basura" > "$TDIR/falso.zip"
assert_rc "test corrupt file" 1 "\"$SCRIPT\" -t \"$TDIR/falso.zip\""

# ==============================================================================
# CUSTOM NAME
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== CUSTOM NAME ==="
setup
(cd "$TDIR" && "$SCRIPT" -c gz -n micustom file_a.txt) 2>/dev/null
assert_rc "custom name output existe" 0 "[[ -f \"$TDIR/micustom.tar.gz\" ]]"

# ==============================================================================
# MULTI DECOMPRESS
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== MULTI DECOMPRESS ==="
setup
(cd "$TDIR" && "$SCRIPT" -c gz -n multi_a file_a.txt 2>/dev/null)
(cd "$TDIR" && "$SCRIPT" -c zst -n multi_b file_b.txt 2>/dev/null)
mkdir -p "$TDIR/multi_d"
cp "$TDIR/multi_a.tar.gz" "$TDIR/multi_a.tar.zst" "$TDIR/multi_d/" 2>/dev/null || true
cp "$TDIR/multi_a.tar.gz" "$TDIR/multi_d/"
cp "$TDIR/multi_b.tar.zst" "$TDIR/multi_d/"
(cd "$TDIR/multi_d" && "$SCRIPT" -d multi_a.tar.gz multi_b.tar.zst) 2>/dev/null
assert_rc "multi decompress file_a" 0 "[[ -f \"$TDIR/multi_d/file_a.txt\" ]]"
assert_rc "multi decompress file_b" 0 "[[ -f \"$TDIR/multi_d/file_b.txt\" ]]"

# ==============================================================================
# BZ3 FORMAT
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== BZ3 FORMAT ==="
setup
(cd "$TDIR" && "$SCRIPT" -c bz3 -n test_bz3 file_a.txt file_b.txt) 2>/dev/null
assert_rc "compress bz3" 0 "[[ -f \"$TDIR/test_bz3.tar.bz3\" ]]"
ddir="$TDIR/d_bz3"
mkdir -p "$ddir"
cp "$TDIR/test_bz3.tar.bz3" "$ddir/"
(cd "$ddir" && "$SCRIPT" -d test_bz3.tar.bz3) 2>/dev/null
assert_rc "decompress bz3 file_a" 0 "[[ -f \"$ddir/file_a.txt\" ]]"
assert_rc "decompress bz3 file_b" 0 "[[ -f \"$ddir/file_b.txt\" ]]"

# ==============================================================================
# DECOMPRESS STANDALONE (non-tar compressed files)
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== DECOMPRESS STANDALONE ==="
# Create standalone .gz, .xz, .zst directly (without tar wrapper)
setup
echo "standalone content" > "$TDIR/standalone.txt"
pigz -9 -k -- "$TDIR/standalone.txt" 2>/dev/null
ddir="$TDIR/d_std_gz"
mkdir -p "$ddir"
cp "$TDIR/standalone.txt.gz" "$ddir/"
(cd "$ddir" && "$SCRIPT" -d standalone.txt.gz) 2>/dev/null
assert_rc "decompress standalone gz" 0 "[[ -f \"$ddir/standalone.txt\" ]]"

echo "standalone xz" > "$TDIR/standalone_xz.txt"
xz -k -- "$TDIR/standalone_xz.txt" 2>/dev/null
ddir="$TDIR/d_std_xz"
mkdir -p "$ddir"
cp "$TDIR/standalone_xz.txt.xz" "$ddir/"
(cd "$ddir" && "$SCRIPT" -d standalone_xz.txt.xz) 2>/dev/null
assert_rc "decompress standalone xz" 0 "[[ -f \"$ddir/standalone_xz.txt\" ]]"

# ==============================================================================
# EXCLUDE
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== EXCLUDE ==="
setup
mkdir -p "$TDIR/excl_dir"
echo "keep me" > "$TDIR/excl_dir/keep.txt"
echo "exclude me" > "$TDIR/excl_dir/excl.txt"
(cd "$TDIR" && "$SCRIPT" -c gz -n test_exclude --exclude=excl.txt excl_dir) 2>/dev/null
assert_rc "exclude compress ok" 0 "[[ -f \"$TDIR/test_exclude.tar.gz\" ]]"
ddir="$TDIR/d_exclude"
mkdir -p "$ddir"
cp "$TDIR/test_exclude.tar.gz" "$ddir/"
(cd "$ddir" && "$SCRIPT" -d test_exclude.tar.gz) 2>/dev/null
assert_rc "exclude keep.txt exists" 0 "[[ -f \"$ddir/excl_dir/keep.txt\" ]]"
assert_rc "exclude excl.txt absent" 1 "[[ -f \"$ddir/excl_dir/excl.txt\" ]]"

# ==============================================================================
# SPLIT
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== SPLIT ==="
setup
(cd "$TDIR" && "$SCRIPT" -c gz -n test_split --split=1K file_a.txt file_b.txt) 2>/dev/null
assert_rc "split creates part.aa" 0 "[[ -f \"$TDIR/test_split.tar.gz.part.aa\" ]]"

# ==============================================================================
# CORRUPTED TAR INSIDE VALID GZ (pipe-through integrity)
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== CORRUPTED TAR INSIDE GZ ==="
setup
(cd "$TDIR" && "$SCRIPT" -c gz -n test_corrupt file_a.txt) 2>/dev/null
# gz layer is valid, corrupt the tar inside by truncating
pigz -dc -- "$TDIR/test_corrupt.tar.gz" 2>/dev/null | head -c 50 | pigz -9 > "$TDIR/corrupt_inside.tar.gz" 2>/dev/null
assert_rc "corrupt: pigz -t passes" 0 "pigz -t -- \"$TDIR/corrupt_inside.tar.gz\""
assert_rc "corrupt: pipe test fails" 1 "\"$SCRIPT\" -t \"$TDIR/corrupt_inside.tar.gz\""

# ==============================================================================
# SPACES IN FILENAME
# ==============================================================================
printf "${CYAN}%s${RESET}\n" "=== SPACES IN FILENAME ==="
setup
echo "spaces test" > "$TDIR/my file.txt"
(cd "$TDIR" && "$SCRIPT" -c gz -n test_spaces "my file.txt") 2>/dev/null
assert_rc "spaces: compress ok" 0 "[[ -f \"$TDIR/test_spaces.tar.gz\" ]]"
ddir="$TDIR/d_spaces"
mkdir -p "$ddir"
cp "$TDIR/test_spaces.tar.gz" "$ddir/"
(cd "$ddir" && "$SCRIPT" -d test_spaces.tar.gz) 2>/dev/null
assert_rc "spaces: decompress ok" 0 "[[ -f \"$ddir/my file.txt\" ]]"

# ==============================================================================
# SUMMARY
# ==============================================================================
echo "----------------------------------------"
printf "${BOLD}RESULTADOS:${RESET}\n"
printf "${GREEN}PASS:${RESET} %d\n" "$PASS"
printf "${RED}FAIL:${RESET} %d\n" "$FAIL"
printf "${CYAN}TOTAL:${RESET} %d\n" "$TOTAL"
if [[ "$FAIL" -eq 0 ]]; then
    printf "${GREEN}%s${RESET}\n" "TODOS LOS TESTS PASARON"
else
    printf "${RED}%s${RESET}\n" "HAY TESTS FALLIDOS" >&2
    exit 1
fi
