class Cipherscan < Formula
  desc "Retrieve a list of the SSL cipher suites"
  homepage "https://github.com/jvehent/cipherscan"
  head "https://github.com/jvehent/cipherscan.git"

  depends_on "bash"
  depends_on "coreutils"

  def install
    bin.install "cipherscan", "openssl-darwin64", "analyze.py"
  end

  test do
    system bin/"cipherscan", "brew.sh"
  end
end
