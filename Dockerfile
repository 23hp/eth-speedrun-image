FROM mcr.microsoft.com/devcontainers/javascript-node:24-bookworm

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
      openssh-server build-essential file \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd \
    && chsh -s /usr/bin/zsh node \
    && echo 'PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/node/.foundry/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' > /etc/environment

RUN printf '%s\n' \
  'Port 22' \
  'PasswordAuthentication no' \
  'PermitRootLogin no' \
  'AllowUsers node' \
  'AllowAgentForwarding yes' \
  'HostKey /home/node/.ssh-host/ssh_host_ed25519_key' \
  'AuthorizedKeysFile /etc/ssh/authorized_keys/%u' \
  > /etc/ssh/sshd_config.d/dev.conf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER node
ENV HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_ENV_HINTS=1
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/node/.foundry/bin:${PATH}"

RUN brew install gh ripgrep fd kubernetes-cli && brew cleanup

RUN curl -L https://getfoundry.sh/install | bash && /home/node/.foundry/bin/foundryup

RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc \
    && echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> ~/.bashrc

RUN sed -i '/oh-my-zsh\.sh/i eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"\nexport PATH="$HOME/.foundry/bin:$PATH"' ~/.zshrc \
    && grep -n 'brew shellenv\|oh-my-zsh.sh' ~/.zshrc

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]