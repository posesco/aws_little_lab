#!/bin/bash
set -e

TEMPLATE_DIR="projects/_template"
PROJECTS_DIR="projects"

validate_project_name() {
    local name="$1"

    if [[ ${#name} -gt 20 ]]; then
        echo "Error: Project name must be 20 characters or less"
        return 1
    fi

    if ! [[ "$name" =~ ^[a-z][a-z0-9_]*$ ]]; then
        echo "Error: Project name must be snake_case (lowercase letters, numbers, underscores, starting with a letter)"
        return 1
    fi

    return 0
}

if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "Error: Run this script from the repository root"
    exit 1
fi

if [[ -z "$1" ]]; then
    read -rp "Project name: " PROJECT_NAME
else
    PROJECT_NAME="$1"
fi

if [[ -z "$PROJECT_NAME" ]]; then
    echo "Error: Project name cannot be empty"
    exit 1
fi

if ! validate_project_name "$PROJECT_NAME"; then
    exit 1
fi

PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"

if [[ -d "$PROJECT_DIR" ]]; then
    echo "Error: Project '$PROJECT_NAME' already exists"
    exit 1
fi

cp -r "$TEMPLATE_DIR" "$PROJECT_DIR"

for file in "$PROJECT_DIR"/*.tf; do
    if [[ -f "$file" ]]; then
        sed -i "s/PROJECTNAME/$PROJECT_NAME/g" "$file"
    fi
done

echo ""
echo "Project '$PROJECT_NAME' created successfully!"
echo ""
echo "Files created:"
ls -halt "$PROJECT_DIR"
