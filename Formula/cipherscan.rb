class Cipherscan < Formula
  desc "Retrieve a list of the SSL cipher suites"
  homepage "https://github.com/mozilla/cipherscan"
  head "https://github.com/mozilla/cipherscan.git"

  depends_on "bash"
  depends_on "coreutils"
  depends_on :python if MacOS.version <= :snow_leopard

  patch :DATA

  resource "ecdsa" do
    url "https://pypi.python.org/packages/source/e/ecdsa/ecdsa-0.13.tar.gz"
    sha256 "64cf1ee26d1cde3c73c6d7d107f835fed7c6a2904aef9eac223d57ad800c43fa"
  end

  resource "tlslite-ng" do
    url "https://pypi.python.org/packages/e3/cc/67f9dd450f74ce3f657f60d2abcb182d6cd3e0a7efb19b71cb755140afe7/tlslite-ng-0.7.0-alpha3.tar.gz"
    sha256 "64818f404bf0fab796b0436b40dc3fddad158866366b085a8430dcd4746b6ef2"
  end

  def install
    resources.each do |r|
      r.unpack libexec/".#{r.name}"
    end

    ln_s libexec/".ecdsa/ecdsa", libexec/"ecdsa"
    ln_s libexec/".tlslite-ng/tlslite", libexec/"tlslite"

    libexec.install %w[cipherscan analyze.py cscan cscan.py cscan.sh openssl-darwin64]

    bin.install_symlink libexec/"cipherscan" => bin/"cipherscan"
    bin.install_symlink libexec/"cscan.sh" => bin/"cscan.sh"
    bin.install_symlink libexec/"cscan.py" => bin/"cscan.py"
    bin.install_symlink libexec/"analyze.py" => bin/"analyze"
  end

  test do
    system bin/"cipherscan", "brew.sh"
  end
end

__END__
diff --git a/cipherscan b/cipherscan
index feac6b1..7ea55ea 100755
--- a/cipherscan
+++ b/cipherscan
@@ -2101,7 +2101,8 @@ fi

 if [[ -z $CACERTS ]] && ! [[ -n $CACERTS_ARG_SET ]]; then
     # find a list of trusted CAs on the local system, or use the provided list
-    for f in /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt; do
+    #for f in /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt; do
+    for f in /usr/local/etc/openssl/cert.pem; do
         if [[ -e "$f" ]]; then
             CACERTS="$f"
             break
diff --git a/cscan.sh b/cscan.sh
index 0572d66..fe62407 100755
--- a/cscan.sh
+++ b/cscan.sh
@@ -1,26 +1,26 @@
 #!/bin/bash
 pushd "$(dirname ${BASH_SOURCE[0]})" > /dev/null
-if [ ! -d ./tlslite ]; then
-    echo -e "\n${BASH_SOURCE[0]}: tlslite-ng not found, downloading..."
-    git clone --depth=1 https://github.com/tomato42/tlslite-ng.git .tlslite-ng
-    ln -s .tlslite-ng/tlslite tlslite
-fi
-if [ ! -d ./ecdsa ]; then
-    echo -e "\n${BASH_SOURCE[0]}: python-ecdsa not found, downloading..."
-    git clone --depth=1 https://github.com/warner/python-ecdsa.git .python-ecdsa
-    ln -s .python-ecdsa/src/ecdsa ecdsa
-fi
+#if [ ! -d ./tlslite ]; then
+#    echo -e "\n${BASH_SOURCE[0]}: tlslite-ng not found, downloading..."
+#    git clone --depth=1 https://github.com/tomato42/tlslite-ng.git .tlslite-ng
+#    ln -s .tlslite-ng/tlslite tlslite
+#fi
+#if [ ! -d ./ecdsa ]; then
+#    echo -e "\n${BASH_SOURCE[0]}: python-ecdsa not found, downloading..."
+#    git clone --depth=1 https://github.com/warner/python-ecdsa.git .python-ecdsa
+#    ln -s .python-ecdsa/src/ecdsa ecdsa
+#fi

 # update the code if it is running in interactive terminal
 #if [[ -t 1 ]]; then
-if [[ $UPDATE ]]; then
-    pushd .tlslite-ng >/dev/null
-    git pull origin master --quiet
-    popd >/dev/null
-    pushd .python-ecdsa >/dev/null
-    git pull origin master --quiet
-    popd >/dev/null
-fi
+#if [[ $UPDATE ]]; then
+#    pushd .tlslite-ng >/dev/null
+#    git pull origin master --quiet
+#    popd >/dev/null
+#    pushd .python-ecdsa >/dev/null
+#    git pull origin master --quiet
+#    popd >/dev/null
+#fi

 PYTHONPATH=. python cscan.py "$@"
 ret=$?
