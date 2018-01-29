class Cipherscan < Formula
  desc "Retrieve a list of the SSL cipher suites"
  homepage "https://github.com/mozilla/cipherscan"
  head "https://github.com/mozilla/cipherscan.git"

  depends_on "bash"
  depends_on "coreutils"
  depends_on :python if MacOS.version <= :snow_leopard

  patch :DATA

  resource "ecdsa" do
    url "https://files.pythonhosted.org/packages/source/e/ecdsa/ecdsa-0.13.tar.gz"
    sha256 "64cf1ee26d1cde3c73c6d7d107f835fed7c6a2904aef9eac223d57ad800c43fa"
  end

  resource "tlslite-ng" do
    url "https://files.pythonhosted.org/packages/18/01/5f012b5bc1e3e30dbed3d3d24b37ae7ceb8e5f8d60bfbaca41704248f2d3/tlslite-ng-0.8.0-alpha1.tar.gz"
    sha256 "cbe3b6f5a9049d17767f729c568ed87e2092bdd677823feb5a46e1a70d2302f3"
  end

  def install
    resources.each do |r|
      r.stage libexec/".#{r.name}"
    end

    ln_s libexec/".ecdsa/ecdsa", libexec/"ecdsa"
    ln_s libexec/".tlslite-ng/tlslite", libexec/"tlslite"

    libexec.install %w[cipherscan analyze.py cscan cscan.py cscan.sh openssl-darwin64]

    bin.install_symlink libexec/"cipherscan" => bin/"cipherscan"
    bin.install_symlink libexec/"analyze.py" => bin/"analyze"
  end

  test do
    system bin/"cipherscan", "brew.sh"
  end
end

__END__
diff --git a/cipherscan b/cipherscan
index feac6b1..d122a3d 100755
--- a/cipherscan
+++ b/cipherscan
@@ -78,7 +78,7 @@ else
     esac
 fi

-DIRNAMEPATH=$(dirname "$0")
+DIRNAMEPATH=$(dirname `realpath "$0"`)

 join_array_by_char() {
     # Two or less parameters (join + 0 or 1 value), then no need to set IFS because no join occurs.
@@ -2101,7 +2101,7 @@ fi

 if [[ -z $CACERTS ]] && ! [[ -n $CACERTS_ARG_SET ]]; then
     # find a list of trusted CAs on the local system, or use the provided list
-    for f in /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt; do
+    for f in /usr/local/etc/openssl/cert.pem; do
         if [[ -e "$f" ]]; then
             CACERTS="$f"
             break
diff --git a/cscan.sh b/cscan.sh
index 0572d66..15821ac 100755
--- a/cscan.sh
+++ b/cscan.sh
@@ -1,27 +1,5 @@
 #!/bin/bash
 pushd "$(dirname ${BASH_SOURCE[0]})" > /dev/null
-if [ ! -d ./tlslite ]; then
-    echo -e "\n${BASH_SOURCE[0]}: tlslite-ng not found, downloading..." 1>&2
-    git clone --depth=1 https://github.com/tomato42/tlslite-ng.git .tlslite-ng 1>&2
-    ln -s .tlslite-ng/tlslite tlslite
-fi
-if [ ! -d ./ecdsa ]; then
-    echo -e "\n${BASH_SOURCE[0]}: python-ecdsa not found, downloading..." 1>&2
-    git clone --depth=1 https://github.com/warner/python-ecdsa.git .python-ecdsa 1>&2
-    ln -s .python-ecdsa/src/ecdsa ecdsa
-fi
-
-# update the code if it is running in interactive terminal
-#if [[ -t 1 ]]; then
-if [[ $UPDATE ]]; then
-    pushd .tlslite-ng >/dev/null
-    git pull origin master --quiet
-    popd >/dev/null
-    pushd .python-ecdsa >/dev/null
-    git pull origin master --quiet
-    popd >/dev/null
-fi
-
 PYTHONPATH=. python cscan.py "$@"
 ret=$?
 popd > /dev/null
