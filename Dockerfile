
# Use the latest version of the bitnami/git image
FROM bitnami/git:latest
LABEL maintainer="@chriskyfung" 

# Update the package manager and install curl and gpg
RUN apt update && apt install -y \
  curl \
  gpg

# Download the githubcli-archive-keyring.gpg file and store it in /usr/share/keyrings/
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg;

# Add the GitHub CLI package source to the package manager
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Add the GitHub CLI package source to the package manager
RUN curl -LJO https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar \
  && chmod +x bfg-1.14.0.jar \
  && mkdir /usr/local/bin/bfg/ \
  && mv bfg-1.14.0.jar /usr/local/bin/bfg/ \
  && echo 'alias bfg="java -jar /usr/local/bin/bfg/bfg-1.14.0.jar"' >> ~/.bashrc

# Install gh (GitHub CLI) and default-jre
RUN apt update && apt install -y \
  gh \
  default-jre

# Set up GitHub CLI and Git completions in one command
RUN echo 'eval "$(gh completion -s bash)"' >> ~/.bashrc \
    && echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc

# Set the working directory
WORKDIR /project_home/
