
# Use the latest version of the bitnami/git image
FROM bitnami/git:latest
LABEL maintainer="@chriskyfung" 

# Update the package manager and install curl, gpg, gh (GitHub CLI) and default-jre
RUN apt update && apt install -y --no-install-recommends \
  curl \
  gpg \
  gh \
  default-jre \
  && rm -rf /var/lib/apt/lists/* /var/cache/apk/*

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

# Copy the local file(s)
COPY utilites/bash-completion/completions/gh-repo-clone-custom.bash /usr/share/bash-completion/completions/gh-repo-clone-custom

# Set up GitHub CLI and Git completions after installing GitHub CLI
RUN echo 'eval "$(gh completion -s bash)"' >> ~/.bashrc \
  && echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc \
  && echo "source /usr/share/bash-completion/completions/gh-repo-clone-custom" >> ~/.bashrc

# Set the working directory
WORKDIR /project_home/

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]
