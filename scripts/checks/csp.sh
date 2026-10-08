#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# csp.sh: every page of the assembled site carries a same-origin
# Content-Security-Policy that allows no inline code it does not name, and
# loads nothing from another origin.
#
#   scripts/checks/csp.sh _site
#
# For each HTML page, the landing page and every page of the family book:
#
#   * exactly one CSP <meta>, before the first <script>, <style> and <link>;
#   * no 'unsafe-inline' and no 'unsafe-eval', and every source in the policy
#     is 'self', 'none', a sha256 hash, 'unsafe-hashes' or data: for images;
#   * every inline script and every style attribute or element is covered by
#     a hash the policy lists;
#   * no script, stylesheet, image, frame or font is loaded from another
#     origin, in the page or in a stylesheet the site serves.
#
# It is the machine half of the same-origin rule in .claude/rules/site.md.

set -euo pipefail

readonly SITE="${1:?usage: $0 SITE}"
[ -d "$SITE" ] || { echo "csp: no such directory: $SITE" >&2; exit 1; }

fail=0
pages=0

while IFS= read -r page; do
  pages=$((pages + 1))
  if ! perl -0777 -ne '
    use Digest::SHA qw(sha256_base64);
    sub h { my $d = sha256_base64($_[0]); $d .= "=" while length($d) % 4; "sha256-$d" }
    my $page = $ARGV; my @bad;

    my @metas = /<meta http-equiv="Content-Security-Policy" content="([^"]*)"/g;
    if (@metas != 1) { print "csp: $page carries ", scalar(@metas), " CSP meta elements, expected 1\n"; exit 1 }
    my $policy = $metas[0];
    my $at = index($_, "Content-Security-Policy");
    for my $tag ("<script", "<style", "<link") {
      my $first = index($_, $tag);
      push @bad, "$tag comes before the policy" if $first >= 0 && $first < $at;
    }

    my %dir;
    for my $part (split /;\s*/, $policy) {
      my ($name, @sources) = split /\s+/, $part;
      $dir{$name} = { map { $_ => 1 } @sources };
      for my $s (@sources) {
        next if $s =~ /^\x27(self|none|unsafe-hashes)\x27$/ || $s =~ /^\x27sha256-[A-Za-z0-9+\/]+=*\x27$/;
        next if $s eq "data:" && $name eq "img-src";
        push @bad, "$name allows $s";
      }
    }
    push @bad, "no default-src \x27self\x27" unless $dir{"default-src"} && $dir{"default-src"}{"\x27self\x27"};
    my $script = $dir{"script-src"} // $dir{"default-src"};
    my $style = $dir{"style-src"} // $dir{"default-src"};

    while (m{<script(\s[^>]*)?>(.*?)</script>}gs) {
      my ($attrs, $body) = ($1 // "", $2);
      next if $attrs =~ /\bsrc\s*=/ || $attrs =~ /\btype\s*=\s*"application\/(ld\+)?json"/;
      push @bad, "an inline script is not hashed in script-src" unless $script->{"\x27" . h($body) . "\x27"};
    }
    while (m{<style(\s[^>]*)?>(.*?)</style>}gs) {
      push @bad, "an inline <style> is not hashed in style-src" unless $style->{"\x27" . h($2) . "\x27"};
    }
    while (m{\sstyle="([^"]*)"}g) {
      push @bad, "style=\"$1\" is not hashed in style-src"
        unless $style->{"\x27" . h($1) . "\x27"} && $style->{"\x27unsafe-hashes\x27"};
    }
    while (m{<(script|img|iframe|source|link)\b[^>]*>}g) {
      my $tag = $&;
      next if $1 eq "link" && $tag !~ /rel="(stylesheet|icon|alternate icon|shortcut icon|apple-touch-icon|preload)"/;
      push @bad, "loads from another origin: $tag" if $tag =~ /\b(src|href)="(https?:)?\/\//;
    }
    if (@bad) { print "csp: $page: $_\n" for @bad; exit 1 }
  ' "$page"; then
    fail=1
  fi
done < <(find "$SITE" -name '*.html' | sort)

# A stylesheet can load too: a font, an image or another sheet through url()
# or @import.
while IFS= read -r sheet; do
  hits="$(grep -nE '(url\(|@import)[[:space:]]*["'\'']?(https?:)?//' "$sheet" || true)"
  [ -n "$hits" ] || continue
  echo "csp: $sheet loads from another origin:" >&2
  echo "$hits" >&2
  fail=1
done < <(find "$SITE" -name '*.css')

if [ "$fail" -ne 0 ]; then
  echo "csp: FAILED" >&2
  exit 1
fi

echo "csp: $pages pages carry a same-origin policy that names all their inline code."
