cask "agent-overlay" do
  version "1.2.1"
  # Two builds now, not one. Both hashes are taken from the PUBLISHED assets,
  # not from a local build:
  #   curl -sL <url> | shasum -a 256
  #
  # The URL and sha live inside on_arm/on_intel rather than at the top level
  # because they genuinely differ per architecture -- a single sha256 would
  # fail the checksum for whichever Mac did not happen to build it.
  #
  # The PUBLIC releases repo, not the private source repo. Homebrew downloads
  # anonymously, so a private repo's release asset returns 404 for everyone
  # except the account that owns it.
  #
  # The tag is prefixed because that repo already holds v1.0.0 for the previous
  # product (Attention Instrument). Two products, one release repo, so the tag
  # has to say which.
  on_arm do
    sha256 "bafdc1e0d446d35f14c5a793eaec564043a6ecf47522dcf2ba1b4f3b1145a614"
    url "https://github.com/RayyanDarugar/attentionexchange-releases/releases/download/agent-overlay-v#{version}/agent-overlay-#{version}-arm64.dmg"
  end
  on_intel do
    sha256 "379a277a932fe46cababfe458083f9cd179cb5a55e8e90636c11170c9eb7d1bc"
    url "https://github.com/RayyanDarugar/attentionexchange-releases/releases/download/agent-overlay-v#{version}/agent-overlay-#{version}-x64.dmg"
  end
  name "agent-overlay"
  desc "Shows what your Claude Code sessions are doing, in blank space on screen"
  homepage "https://github.com/RayyanDarugar/attentionexchange-releases"

  # The bare symbol already means "or newer" — the DSL parses it with a ">="
  # comparator by default, which is why the string form is both redundant and
  # deprecated.
  #
  # Ventura rather than Sonoma: the real floor is ScreenCaptureKit, which needs
  # 12.3, and Sonoma was an arbitrary guess that would refuse machines the app
  # runs on perfectly well.
  depends_on macos: :ventura

  app "agent-overlay.app"

  # Everything the app creates, so `brew uninstall --zap` genuinely removes it.
  # The Claude Code hooks in ~/.claude/settings.json are deliberately NOT listed:
  # that file is the user's own and holds their permissions and plugins. Zapping
  # it would be the single most destructive thing this package could do, and the
  # hooks are inert without the app anyway — they append to a log nothing reads.
  zap trash: [
    "~/Library/Application Support/agent-overlay",
    "~/Library/Application Support/prototype",
    "~/.attention-exchange",
  ]

  caveats <<~EOS
    On first launch it asks for Screen Recording. Nothing is recorded — it is
    the only macOS permission for "what does this region of the screen look
    like", which is how it finds space that is actually blank.

ALREADY HAD 1.2.0 OR EARLIER? Two things. Its helper programs were
    built requiring macOS 26 by mistake, so on anything older the panel never
    appeared at all — that is fixed here, and it was never anything you did.
    And if you first installed before the app was signed by Apple, macOS sees
    a new identity: open System Settings > Privacy & Security > Screen
    Recording, select agent-overlay, remove it with the minus button, then
    launch and allow it when it asks. One time only.

    The panel can answer Claude Code's permission prompts. When an agent asks
    to run a tool, it offers Allow and Deny. Your terminal prompt still works
    exactly as before; whichever you answer first wins.
  EOS

end
