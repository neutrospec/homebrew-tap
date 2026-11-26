# Formula/cuttle.rb in the neutrospec/homebrew-tap tap is a copy of
# packaging/homebrew/cuttle.rb in neutrospec/cuttle; change the source file
# and copy it. A release copy sets `url` and `sha256` for the new tag, while
# the source file keeps a placeholder checksum because a tag's tarball cannot
# contain its own. `brew pr-pull` adds the tap's `bottle do` block; the source
# file never has one.
# Design: neutrospec/cuttle docs/design/0006-packaging-paths-and-lifecycle.md, D8.
class Cuttle < Formula
  desc "Explicit HTTP and HTTPS forward proxy with rule-based routing"
  homepage "https://github.com/neutrospec/cuttle"
  url "https://github.com/neutrospec/cuttle/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "d9457b40f0a454200780b1d9e06cc7bc92e1a1723df16797e63789107f3a0b35"
  license "MIT"
  head "https://github.com/neutrospec/cuttle.git", branch: "main"

  bottle do
    root_url "https://github.com/neutrospec/homebrew-tap/releases/download/cuttle-0.2.0"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "5b5e766fe29f69c343ec0242c98fb83dd35b3f0312366acc1c3dd72a6e726a36"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2272ee9ddc708d96d30655f7858fcfe8f38d2d7001463289a4189684c903f5f3"
  end

  depends_on "go" => :build
  depends_on :macos

  # The test talks to cuttle over loopback TCP. `fetch` downloads the Go
  # modules with network access; `install` then builds offline.
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/cuttle"
  end

  def caveats
    <<~EOS
      Configuration: ~/.config/cuttle/config.toml (created on first start)
      Admin UI:      http://127.0.0.1:3129/ after `cuttle admin passwd`
      Paths:         `cuttle paths`
      Non-default XDG_* values must also be set for the service in
        $HOMEBREW_USER_CONFIG_HOME/services/cuttle.env
      Run `brew services stop cuttle` before `brew uninstall cuttle`;
        uninstalling does not stop the service.
      Uninstalling leaves ~/.config/cuttle, ~/.local/share/cuttle, and
        ~/.local/state/cuttle in place.
    EOS
  end

  service do
    run [opt_bin/"cuttle", "serve"]
    keep_alive true
    process_type :interactive
    stop_timeout 15
    log_path var/"log/cuttle.log"
    error_log_path var/"log/cuttle.log"
  end

  test do
    port = free_port
    runtime_dir = testpath/"run"
    runtime_dir.mkpath
    runtime_dir.chmod 0700
    ENV["XDG_RUNTIME_DIR"] = runtime_dir.to_s
    (testpath/".config/cuttle/config.toml").write <<~TOML
      name = "cuttle-test"
      [proxy]
      listen = ["127.0.0.1:#{port}"]
      default = "block"
      [admin]
      listen = ""
    TOML
    assert_match "config.toml: ok, 0 warning(s)", shell_output("#{bin}/cuttle check")

    # A blocked CONNECT is answered 403 without any outbound connection.
    with_test_process bin/"cuttle", "serve" do
      status_line = nil
      20.times do
        sleep 0.5
        status_line = TCPSocket.open("127.0.0.1", port) do |socket|
          socket.write "CONNECT blocked.invalid:443 HTTP/1.1\r\nHost: blocked.invalid:443\r\n\r\n"
          socket.gets
        end
        break
      rescue Errno::ECONNREFUSED
        next
      end
      assert_match %r{\AHTTP/1\.1 403 }, status_line.to_s
    end
    assert_match "cuttle #{version}", shell_output("#{bin}/cuttle version")
  end
end
