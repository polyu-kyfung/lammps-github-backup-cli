# GitHub-CLI Docker for LAMMPS Project Backup

This repository provides a Dockerized solution for efficiently backing up LAMMPS projects hosted on GitHub. By leveraging Docker and Docker Compose, it establishes a reliable environment equipped with essential tools for comprehensive Git and GitHub operations, ensuring seamless and accessible backups of critical data.

## Dockerfile Overview

The Dockerfile in this repository sets up the environment by including essential packages:

- **GitHub CLI**: For interacting with GitHub repositories.
- **Java Runtime Environment (JRE)**: Required for running Java applications.
- **BFG Repo-Cleaner**: A tool for cleaning up Git repository history.

These packages ensure that the environment is well-equipped for comprehensive Git and GitHub operations.

## Docker Compose Overview

The `docker-compose.yml` file is configured to run the GitHub backup service with the following key components:

- **Environment Variables**: Loads configuration parameters from the `.env` file.
- **Volume Mounts**: Maps the current directory, a specified project directory.

These configurations ensure a seamless and secure environment for backing up LAMMPS projects from GitHub.

[[toc]]

## How to Use

To get started with this setup, follow these steps:

1. **Clone the repository** and navigate to the project's root directory.

2. **Create a `.env` file** by copying the existing `.env-sample` file and modifying it as needed.

Once you've completed these steps, you can proceed with the following commands:

### Create an Image from Dockerfile

Navigate to the root directory of this project, where the **Dockerfile** is stored. In your terminal, run the following command to build the Docker image:

```sh
docker build -t lammps-github-backup-cli:2.0 .
```

### Create and Start a Container Using Docker Compose

```sh
docker compose up --detach
```

To stop and remove the container, use:

```sh
docker compose down
```

### Execute an Interactive Bash Shell on the Container

```sh
docker exec -it lammps-github-backup-service bash
```

> [!NOTE]
> Ensure your local repository is accessible in the WSL2 environment. Open the WSL2 terminal and navigate to your repository to run Docker commands seamlessly.

### Install vi Editor

For interactive rebase operations, install a text editor such as **vi** on the Linux system:

```sh
apt install vim
```

### Remove Sensitive Data from the Git History

Navigate to a local repository and run **BFG** to replace sensitive texts using the following command:

```sh
bfg --replace-text /home/passwords.txt --no-blob-protection
```

## Utils (Shell Scripts)

### Interactively Create a New Folder for LAMMPS Nanocutting-SiC Results

You can use the `./mkdir-for-lammps-results.sh` script to create a new folder with a formatted name, which helps in organizing your LAMMPS nanocutting-SiC results efficiently.

This script prompts you to input various parameters of your simulation, such as:
- **Cutting Speed**: Choose a value between 1 and 3.
- **Groove Depth**: Specify "no" for defect-free or select among 3, 6, or 9.
- **Groove Shape**: Select between isosceles acute (a) or isosceles right (r) if a groove depth is specified.

Based on these inputs, the script generates and creates a new folder with a name that accurately reflects the chosen simulation parameters.


### Initialize git in a folder

To start using git in a folder, you need to initialize it as a repository. This will create a hidden `.git` directory that contains the necessary files and metadata for git to track your changes.

To initialize git in a folder, open a terminal and navigate to the folder you want to use. Then, run the `../setup-git.sh` script. It will execute the `git init` command and set up the git user name and email locally.

### Create a new remote repository on GitHub

After you have git installed and configured in your folder. You can run the `../new-gitHub-repo.sh` script to set up the remote repository. The script will prompt you to choose a file type and then create a new private repository, with a name that reflects the file type and the simulation parameters, on GitHub using the GitHub CLI.

### Quick menu to explore and edit a GitHub repository

You can use the `./explore-github-repo.sh` script to carry out the following tasks:

  1. Open the GitHub repository in the browser
  2. Display the description and the README
  3. Check the disk usage
  4. Update the description

This script will first prompt you to enter the file type and the simulation parameters. It will resolve the repository name and then ask for the action you want to take.

### Commit readme and log files

You can use the `../git-readme-and-logfiles.sh` script to create commits for the README and log files in the folder that contains the simulation results.

This script will create the "Add README file" and "Add log files" commits.

### Commit dump/force/rerun files

You can use the `../commit-results-files.sh` script to create commits for the result files.

This script will prompt you to enter the cutting speed parameter. Then, it will use a loop to sequentially create commits for the indexed files in multiple batches. This way results in a set of commits that can be pushed to the remote repository in smaller chunks, reducing the risk of conflicts and errors.

### Push commits to remote one by one

You can use the `../progressive-push-latest-commits.sh` script in the folder that contains the simulation results.

Enter the number of revisions before the HEAD. For example, input `10` to the prompt will start from `HEAD~10` and push commits to remote one by one with a 5-minute break in between.

### Open the OVITO GUI program

You can use the `./ovito.sh` script to quick open the OVITO program on Windows, and preload the state files specifying in the script file.

If you prefer to use PowerShell on Windows, run the `./ovito.ps1` script file instead.

## Useful Git Commands

### Add enable git tab completion in Linux Bash shell

```sh
source /usr/share/bash-completion/completions/git
```

### Show git history in one line

```sh
git log --oneline
```

### Remove pre_cut files

```sh
git rm -r pre_cut/ precut/
git commit -m "Remove pre_cut files"
```

### Change the date of the last commit

```sh
git commit --amend --date="........"
```

### Undo the last commit

```sh
git reset --soft HEAD^
```

### Interactive rebase the first commit

```sh
git rebase -i --root
```

### Push commits to remote (upto a special commit in the git history)

```sh
git push origin <commit ref>:<remote branch>
```

### Create a new branch from the current branch

```sh
git checkout -b <new branch name>
```

### Pick a commit from another branch and add it to the current branch

```sh
git cherry-pick <commit ref>
```

### Rebase new commits in branch B onto branch A

```sh
git rebase branch-A branch-B
```

## Useful GitHub-CLI commands

Official manual: <https://cli.GitHub.com/manual/>

### Authenticate Git with your GitHub credentials

```sh
gh auth login
```

📄 <https://cli.GitHub.com/manual/gh_auth_login>

### List all repositories

```sh
gh repo list [<owner>] [flags]
```

📄 <https://cli.GitHub.com/manual/gh_repo_list>.


### Clone a GitHub repository to local storage

```sh
gh repo clone <repository>
```

📄 <https://cli.GitHub.com/manual/gh_repo_clone>

### Create a new private repository on GitHub based on a template repository

```sh
gh repo create <owner>/<new-name> --private --template=<repository>
```

📄 <https://cli.GitHub.com/manual/gh_repo_create>.

### gh repo view

📄 <https://cli.GitHub.com/manual/gh_repo_view>.

#### Open a repository in the browser

```sh
gh repo view [<repository>] --web
```

#### List the description and topics of a remote repository in JSON format

```sh
gh repo view [<repository>] --json description,repositoryTopics
```

#### List the projects of a remote repository in JSON format

```sh
gh repo view [<repository>] --json description,repositoryTopics
```

#### Check the disk usage of a remote repository in JSON format

```sh
gh repo view [<repository>] --json diskUsage
```

### gh repo edit

📄 <https://cli.GitHub.com/manual/gh_repo_edit>.

#### Add topics to a remote repository

```sh
gh repo edit [<repository>] --add-topic <strings>
```
