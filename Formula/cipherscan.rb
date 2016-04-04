class Cipherscan < Formula
  desc "Retrieve a list of the SSL cipher suites"
  homepage "https://github.com/jvehent/cipherscan"
  head "https://github.com/jvehent/cipherscan.git"

  depends_on "bash"
  depends_on "coreutils"

  patch :DATA

  def install
    libexec.install "cipherscan", "openssl-darwin64", "analyze.py"
    bin.install_symlink libexec/"cipherscan" => bin/"cipherscan"
  end

  test do
    system bin/"cipherscan", "brew.sh"
  end
end

__END__
diff --git a/cipherscan b/cipherscan
index 236b34f..2c1fa58 100755
--- a/cipherscan
+++ b/cipherscan
@@ -2042,7 +2042,7 @@ fi

 if [[ -z $CACERTS ]] && ! [[ -n $CACERTS_ARG_SET ]]; then
     # find a list of trusted CAs on the local system, or use the provided list
-    for f in /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt; do
+    for f in /usr/local/etc/openssl/cert.pem; do
         if [[ -e "$f" ]]; then
             CACERTS="$f"
             break
