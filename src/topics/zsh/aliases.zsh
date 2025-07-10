# Function to create a git worktree with a dedicated worktrees folder
wt() {
    # Array of additional directories to copy (customize this list as needed)
    local copy_dirs=(.claude .cursor .vscode)
    
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
        # Copy .env file if it exists
        if [ -f ".env" ]; then
            echo "Copying .env file..."
            cp .env "$worktree_path/.env"
        fi
        
        # Copy .env.local file if it exists
        if [ -f ".env.local" ]; then
            echo "Copying .env.local file..."
            cp .env.local "$worktree_path/.env.local"
        fi
        
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