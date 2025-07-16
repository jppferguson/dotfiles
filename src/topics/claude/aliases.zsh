# Prepend claude to PATH to take precedence over asdf
export PATH="$HOME/.claude/local:$HOME/.claude/local/node_modules/.bin:$PATH"

# Also keep the alias as a fallback
alias claude="~/.claude/local/claude"

# Function to create a git worktree with a dedicated worktrees folder
wt() {
    # Array of additional directories to copy (customize this list as needed)
    local copy_dirs=(.claude .cursor .vscode)
    
    # Array of additional files to copy (customize this list as needed)
    local copy_files=(.env .env.local CLAUDE.local.md)
    
    # Check if feature name argument was provided
    if [ -z "$1" ]; then
        echo "Error: Please provide a feature name"
        echo "Usage: wt feature-name"
        return 1
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi
    
    # Get the top level of the git repository
    local git_root=$(git rev-parse --show-toplevel)
    
    # Check if we're at the top level of the git repository
    if [ "$PWD" != "$git_root" ]; then
        echo "Error: Please run this command from the root of the git repository"
        echo "Current directory: $PWD"
        echo "Git root: $git_root"
        return 1
    fi
    
    # Store the feature name from the first argument
    local feature_name="$1"
    
    # Get the current directory name (project folder name)
    local current_dir_name=$(basename "$PWD")
    
    # Get the parent directory path of the current project
    local parent_dir=$(dirname "$PWD")
    
    # Define the worktrees folder path (sibling to current project)
    local worktrees_dir="${parent_dir}/${current_dir_name}-worktrees"
    
    # Create the worktrees folder if it doesn't exist
    if [ ! -d "$worktrees_dir" ]; then
        echo "Creating worktrees directory: $worktrees_dir"
        mkdir -p "$worktrees_dir"
    fi
    
    # Define the path for the new worktree
    local worktree_path="${worktrees_dir}/${feature_name}"
    
    # Create the git worktree with a new branch
    echo "Creating worktree '$feature_name' at: $worktree_path"
    git worktree add -b "$feature_name" "$worktree_path"
    
    # Check if worktree creation was successful
    if [ $? -eq 0 ]; then
        # Copy additional files from the array
        for file in "${copy_files[@]}"; do
            if [ -f "$file" ]; then
                echo "Copying $file file..."
                cp "$file" "$worktree_path/"
            fi
        done
        
        # Copy additional directories from the array
        for dir in "${copy_dirs[@]}"; do
            if [ -d "$dir" ]; then
                echo "Copying $dir directory..."
                cp -r "$dir" "$worktree_path/"
            fi
        done
        
        # Open the new worktree folder in VSCode
        echo "Opening worktree in VSCode..."
        code -n "$worktree_path"
        echo "Successfully created worktree '$feature_name'"
    else
        echo "Error: Failed to create worktree"
        return 1
    fi
}

# Function to clean up a git worktree and its branch
wt-clean() {
    # Helper function to list available worktrees
    list_worktrees() {
        local current_dir_name=$(basename "$PWD")
        local parent_dir=$(dirname "$PWD")
        local worktrees_dir="${parent_dir}/${current_dir_name}-worktrees"
        
        if [ -d "$worktrees_dir" ]; then
            local worktrees=($(ls -1 "$worktrees_dir" 2>/dev/null))
            if [ ${#worktrees[@]} -gt 0 ]; then
                echo "Available worktrees:"
                printf "  %s\n" "${worktrees[@]}"
                return 0
            else
                echo "No worktrees found in: $worktrees_dir"
                return 1
            fi
        else
            echo "No worktrees directory found: $worktrees_dir"
            return 1
        fi
    }
    
    # Check if feature name argument was provided
    if [ -z "$1" ]; then
        echo "Error: Please provide a feature name"
        echo "Usage: wt-clean feature-name"
        echo ""
        list_worktrees
        return 1
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi
    
    # Get the top level of the git repository
    local git_root=$(git rev-parse --show-toplevel)
    
    # Check if we're at the top level of the git repository
    if [ "$PWD" != "$git_root" ]; then
        echo "Error: Please run this command from the root of the git repository"
        echo "Current directory: $PWD"
        echo "Git root: $git_root"
        return 1
    fi
    
    # Store the feature name from the first argument
    local feature_name="$1"
    
    # Get the current directory name (project folder name)
    local current_dir_name=$(basename "$PWD")
    
    # Get the parent directory path of the current project
    local parent_dir=$(dirname "$PWD")
    
    # Define the worktrees folder path (sibling to current project)
    local worktrees_dir="${parent_dir}/${current_dir_name}-worktrees"
    
    # Define the path for the worktree to remove
    local worktree_path="${worktrees_dir}/${feature_name}"
    
    # Check if the worktree exists
    if [ ! -d "$worktree_path" ]; then
        echo "Error: Worktree '$feature_name' does not exist at: $worktree_path"
        echo ""
        list_worktrees
        return 1
    fi
    
    # Remove the worktree
    echo "Removing worktree '$feature_name' at: $worktree_path"
    git worktree remove "$worktree_path"
    
    # Check if worktree removal was successful
    if [ $? -eq 0 ]; then
        # Delete the branch
        echo "Deleting branch '$feature_name'..."
        git branch -D "$feature_name"
        
        # Check if branch deletion was successful
        if [ $? -eq 0 ]; then
            echo "Successfully cleaned up worktree and branch '$feature_name'"
            
            # Remove the worktrees directory if it's empty
            if [ -d "$worktrees_dir" ] && [ -z "$(ls -A "$worktrees_dir")" ]; then
                echo "Removing empty worktrees directory: $worktrees_dir"
                rmdir "$worktrees_dir"
            fi
        else
            echo "Warning: Worktree removed but failed to delete branch '$feature_name'"
        fi
    else
        echo "Error: Failed to remove worktree"
        return 1
    fi
}