cask "agent-overlay" do
  version "1.1.2"
  # Taken from the PUBLISHED asset, not from a local build. Electron output is
  # not byte-reproducible, so every `npm run dist` yields a different hash and
  # only the uploaded file's is meaningful:
  #   curl -sL <url> | shasum -a 256
  sha256 "076cca96770abd3f69ca04136be32faa0a8ea2dcb95466d3396dcf1997086431"

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

    UPGRADING FROM 1.1.1 OR EARLIER: this version is signed by Apple, which
    changes the app's identity as far as macOS is concerned. Your existing
    Screen Recording grant does not carry over, and the old entry can look
    switched on while doing nothing. Open System Settings > Privacy & Security
    > Screen Recording, select agent-overlay, remove it with the minus button,
    then launch the app and allow it when it asks. This is a one-time step —
    the identity is stable from now on.

    The panel can answer Claude Code's permission prompts. When an agent asks
    to run a tool, it offers Allow and Deny. Your terminal prompt still works
    exactly as before; whichever you answer first wins.
  EOS

end
