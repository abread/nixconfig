{
  inputs,
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    delta.enable = true;
    signing = {
      key = inputs.hidden.gitSigningKey.tightpants.breda;
      signByDefault = true;
    };
    ignores = [
      ".gdb_history"
      ".vscode"
      ".envrc"
      ".direnv"
    ];

    extraConfig = {
      user = {
        email = inputs.hidden.gitEmail.tightpants.breda;
        name = "André Breda";
      };
      gpg.format = "ssh";
      pull.ff = "only";
      init.defaultBranch = "main";
      credential = {
        credentialStore = "secretservice";
        helper = "${pkgs.gitAndTools.gitFull}/bin/git-credential-libsecret";
      };
    };
  };
}
