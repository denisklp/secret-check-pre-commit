# Gitleaks Pre-Commit Hook

This script checks for sensitive information in your Git commits using [Gitleaks](https://github.com/zricethezav/gitleaks). It installs Gitleaks if it's not already installed and checks if the Gitleaks pre-commit hook is enabled.

Ensure you have `curl` and `tar` or `unzip` installed on your system.

## Installation option 1

1. Run this command in your repo directory to install the script automatically into .git hooks:

    ```bash
    curl -sSfL https://raw.githubusercontent.com/denisklp/secret-check-pre-commit/main/install.sh | sh -
    ```

## Installation option 2

1. Download file https://raw.githubusercontent.com/denisklp/secret-check-pre-commit/main/pre-commit
2. Move downloaded file to .git/hooks/pre-commit
2. Make the script executable:

    ```bash
    chmod +x secret-check.sh
    ```

## Usage

1. Enable the Gitleaks pre-commit hook:

    ```bash
    git config hooks.gitleaks enable
    ```

2. Commit your changes as usual. Gitleaks will scan your commits for sensitive information.

3. If Gitleaks detects sensitive information, it will print a warning message and prevent the commit.

4. To disable the Gitleaks pre-commit hook:

    ```bash
    git config hooks.gitleaks disable
    ```

## Notes

- The script will attempt to install Gitleaks if it's not found on your system or in the specified installation directory (`$HOME/.local/bin/`).

- For more information on Gitleaks, visit [Gitleaks on GitHub](https://github.com/zricethezav/gitleaks).

