#!/bin/bash

# Function to print usage instructions
usage() {
    echo "Usage: $0 [-p PROVIDER] [-t TOKEN | -u USERNAME -w PASSWORD] URL"
    echo "  -p PROVIDER  Specify the provider (e.g., github, gitlab, bitbucket)"
    echo "  -t TOKEN     Use a personal access token for authentication"
    echo "  -u USERNAME  Use a username for authentication"
    echo "  -w PASSWORD  Use a password for authentication"
    echo "  URL          The URL of the Git repository to clone"
    exit 1
}

# Parse command-line arguments
while getopts ":p:t:u:w:" opt; do
    case $opt in
        p) PROVIDER="$OPTARG" ;;
        t) TOKEN="$OPTARG" ;;
        u) USERNAME="$OPTARG" ;;
        w) PASSWORD="$OPTARG" ;;
        \?) usage ;; # Invalid option
    esac
done

shift $((OPTIND - 1))

# Check if URL is provided
if [ -z "$1" ]; then
    usage
fi

URL="$1"

# Determine provider if not specified
if [ -z "$PROVIDER" ]; then
    if [[ $URL == *"github.com"* ]]; then
        PROVIDER="github"
    elif [[ $URL == *"gitlab.com"* ]]; then
        PROVIDER="gitlab"
    elif [[ $URL == *"bitbucket.org"* ]]; then
        PROVIDER="bitbucket"
    else
        echo "Error: Could not determine provider. Please specify using -p."
        exit 1
    fi
fi

# Set up authentication based on provider and credentials
case $PROVIDER in
    github)
        if [ -n "$TOKEN" ]; then
            git config --global credential.helper 'cache --timeout=3600'
            git config --global user.email "example@example.com"
            git config --global user.name "Name"
            echo "https://${TOKEN}:@github.com" > ~/.git-credentials
        else
            echo "Error: GitHub requires a personal access token. Use -t."
            exit 1
        fi
        ;;
    gitlab)
        if [ -n "$TOKEN" ]; then
            git config --global credential.helper 'cache --timeout=3600'
            git config --global user.email "example@example.com"
            git config --global user.name "Name"
            echo "https://oauth2:${TOKEN}@gitlab.com" > ~/.git-credentials
        elif [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
            git config --global credential.helper 'cache --timeout=3600'
            git config --global user.email "example@example.com"
            git config --global user.name "Name"
            echo "https://$USERNAME:$PASSWORD@gitlab.com" > ~/.git-credentials
        else
            echo "Error: GitLab requires either a personal access token or username/password."
            exit 1
        fi
        ;;
    bitbucket)
        if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
            git config --global credential.helper 'cache --timeout=3600'
            git config --global user.email "example@example.com"
            git config --global user.name "Name" 
            echo "https://$USERNAME:$PASSWORD@bitbucket.org" > ~/.git-credentials
        else
            echo "Error: Bitbucket requires a username and password. Use -u and -w."
            exit 1
        fi
        ;;
    *)
        echo "Error: Unsupported provider: $PROVIDER"
        exit 1
        ;;
esac

# Clone the repository using the original URL
echo "Cloning repository from $URL..."
git clone "$URL"

# Check for errors
if [ $? -ne 0 ]; then
    echo "Error: Failed to clone repository."
    exit 1
fi

echo "Repository cloned successfully!"