cask "agent-overlay" do
  version "1.0.0"
  sha256 "cdb8ac4d3b1bb001811f23a78af17aa7b649c3965219a8d36d4c45b02b5366e0"

  # The PUBLIC releases repo, not the private source repo. Homebrew downloads
  # anonymously, so a private repo's release asset returns 404 for everyone
  # except the account that owns it — the cask would work only on the machine
  # that published it.
  #
  # The tag is prefixed because that repo already holds v1.0.0 for the previous
  # product (Attention Instrument). Two products, one release repo, so the tag
  # has to say which.
  url "https://github.com/RayyanDarugar/attentionexchange-releases/releases/download/agent-overlay-v#{version}/agent-overlay-#{version}-arm64.dmg"
  name "agent-overlay"
  desc "Shows what your Claude Code sessions are doing, in blank space on screen"
  homepage "https://github.com/RayyanDarugar/attentionexchange-releases"

  # Apple Silicon only: the build is arm64, and the Swift helpers that read
  # window geometry are compiled for it. An Intel Mac fails at launch in a way
  # a non-technical person cannot describe back to you, so it is refused here
  # with an explanation instead.
  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"

  app "agent-overlay.app"

  # Everything the app creates, so `brew uninstall --zap` genuinely removes it.
  # The Claude Code hooks in ~/.claude/settings.json are deliberately NOT listed:
  # that file is the user's own and holds their permissions and plugins. Zapping
  # it would be the single most destructive thing this package could do, and the
  # hooks are inert without the app anyway — they append to a log nothing reads.
  zap trash: [
    "~/Library/Application Support/prototype",
    "~/.attention-exchange",
  ]

  caveats <<~EOS
    One more step, because agent-overlay is not notarised by Apple:

      xattr -dr com.apple.quarantine "/Applications/agent-overlay.app"

    Without it macOS reports the app as "damaged", which is untrue and is the
    same message a genuinely corrupt download gives. Homebrew used to offer
    --no-quarantine for exactly this; it was removed, and there is no
    replacement flag, so the step has to be run by hand.

    On first launch it asks for Screen Recording. Nothing is recorded — it is
    the only macOS permission for "what does this region of the screen look
    like", which is how it finds space that is actually blank.
  EOS
end
