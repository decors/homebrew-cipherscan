class Cipherscan < Formula
  desc "Retrieve a list of the SSL cipher suites"
  homepage "https://github.com/mozilla/cipherscan"
  head "https://github.com/mozilla/cipherscan.git"

  depends_on "bash"
  depends_on "coreutils"
  depends_on :python if MacOS.version <= :snow_leopard

  patch :DATA

  resource "ecdsa" do
    url "https://files.pythonhosted.org/packages/source/e/ecdsa/ecdsa-0.13.3.tar.gz"
    sha256 "163c80b064a763ea733870feb96f9dd9b92216cfcacd374837af18e4e8ec3d4d"
  end

  resource "tlslite-ng" do
    url "https://files.pythonhosted.org/packages/e8/a3/405aa3959edd656045ac5e6c4f60c43a1121201cbb20aecf8a5176461352/tlslite-ng-0.8.0-alpha29.tar.gz"
    sha256 "0c900d2ef7247e150e3ab9fe2ff4e4a4237fbe4e29351c8c84ab20b1aeee22e4"
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
