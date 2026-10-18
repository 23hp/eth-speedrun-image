FROM mcr.microsoft.com/devcontainers/base:ubuntu

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
      openssh-server build-essential file \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd \
    && usermod -s /usr/bin/zsh vscode

USER vscode
WORKDIR /home/vscode
ENV HOMEBREW_NO_ANALYTICS=1 \
    HOMEBREW_NO_ENV_HINTS=1 \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    MISE_DATA_DIR=/home/vscode/.mise \
    PATH="/home/vscode/.mise/shims:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
 && brew install mise stow \
 && brew cleanup

USER root
COPY files/sshd_dev.conf /etc/ssh/sshd_config.d/dev.conf
COPY files/zshenv /tmp/zshenv
COPY files/zshrc  /tmp/zshrc
RUN cat /tmp/zshenv >> /etc/zsh/zshenv \
 && cat /tmp/zshrc  >> /etc/zsh/zshrc \
 && rm /tmp/zshenv /tmp/zshrc

COPY --chmod=755 entrypoint.sh dev-bootstrap /usr/local/bin/

USER vscode
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]