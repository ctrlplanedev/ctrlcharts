#!/bin/bash

# Ctrlplane Local Deployment Script
# This script deploys the ctrlplane Helm chart to your local Kubernetes cluster

set -euo pipefail

# Configuration
CHART_NAME="ctrlplane"
RELEASE_NAME="ctrlplane"
NAMESPACE="default"
CHART_PATH="./charts/ctrlplane"
VALUES_FILE="./charts/ctrlplane/local-values.yaml"
DRY_RUN=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Pre-flight checks
preflight_checks() {
    log_info "Running pre-flight checks..."
    
    # Check if helm is installed
    if ! command_exists helm; then
        log_error "Helm is not installed. Please install Helm first."
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command_exists kubectl; then
        log_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check if we can connect to the cluster
    if ! kubectl cluster-info >/dev/null 2>&1; then
        log_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    # Check if chart directory exists
    if [ ! -d "$CHART_PATH" ]; then
        log_error "Chart directory '$CHART_PATH' does not exist."
        exit 1
    fi
    
    # Check if values file exists
    if [ ! -f "$VALUES_FILE" ]; then
        log_error "Values file '$VALUES_FILE' does not exist."
        exit 1
    fi
    
    log_success "Pre-flight checks passed!"
}

# Function to update Helm dependencies
update_dependencies() {
    log_info "Updating Helm dependencies..."
    cd "$CHART_PATH"
    
    if helm dependency update; then
        log_success "Dependencies updated successfully!"
    else
        log_error "Failed to update dependencies"
        exit 1
    fi
    
    cd - >/dev/null
}

# Function to deploy the chart
deploy_chart() {
    if [ "$DRY_RUN" = true ]; then
        log_info "Running dry-run deployment for $CHART_NAME to namespace '$NAMESPACE'..."
    else
        log_info "Deploying $CHART_NAME to namespace '$NAMESPACE'..."
    fi
    
    # Prepare common Helm arguments
    HELM_ARGS=(
        --namespace "$NAMESPACE"
        --values "$VALUES_FILE"
        --timeout 10m
        --debug
    )
    
    # Add dry-run flag if enabled
    if [ "$DRY_RUN" = true ]; then
        HELM_ARGS+=(--dry-run)
    else
        HELM_ARGS+=(--wait)
    fi
    
    # Check if release already exists (skip for dry-run)
    if [ "$DRY_RUN" = true ] || helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
        if [ "$DRY_RUN" = true ]; then
            log_info "Simulating upgrade of release '$RELEASE_NAME'..."
        else
            log_info "Release '$RELEASE_NAME' already exists. Upgrading..."
        fi
        
        if helm upgrade "$RELEASE_NAME" "$CHART_PATH" "${HELM_ARGS[@]}"; then
            if [ "$DRY_RUN" = true ]; then
                log_success "Dry-run upgrade completed successfully!"
            else
                log_success "Chart upgraded successfully!"
            fi
        else
            if [ "$DRY_RUN" = true ]; then
                log_error "Dry-run upgrade failed"
            else
                log_error "Failed to upgrade chart"
            fi
            exit 1
        fi
    else
        log_info "Installing new release '$RELEASE_NAME'..."
        
        if helm install "$RELEASE_NAME" "$CHART_PATH" "${HELM_ARGS[@]}"; then
            log_success "Chart installed successfully!"
        else
            log_error "Failed to install chart"
            exit 1
        fi
    fi
}

# Function to show deployment status
show_status() {
    if [ "$DRY_RUN" = true ]; then
        log_info "Dry-run completed. No actual resources were created or modified."
        log_info "To perform the actual deployment, run the script without --dry-run flag."
        return
    fi
    
    log_info "Deployment Status:"
    echo
    
    # Show Helm release status
    helm status "$RELEASE_NAME" -n "$NAMESPACE"
    
    echo
    log_info "Pod Status:"
    kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME"
    
    echo
    log_info "Service Status:"
    kubectl get services -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME"
}

# Main deployment function
main() {
    log_info "Starting Ctrlplane deployment..."
    echo
    
    preflight_checks
    echo
    
    update_dependencies
    echo
    
    deploy_chart
    echo
    
    show_status
    echo
    
    log_success "Deployment completed successfully!"
    log_info "You can check the status anytime with: helm status $RELEASE_NAME -n $NAMESPACE"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release-name)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -v|--values-file)
            VALUES_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo
            echo "Options:"
            echo "  -n, --namespace      Kubernetes namespace (default: default)"
            echo "  -r, --release-name   Helm release name (default: ctrlplane)"
            echo "  -v, --values-file    Values file path (default: ./charts/ctrlplane/local-values.yaml)"
            echo "      --dry-run        Show what would be deployed without actually deploying"
            echo "  -h, --help           Show this help message"
            echo
            echo "Examples:"
            echo "  $0                                    # Deploy with defaults"
            echo "  $0 --dry-run                          # Test deployment without applying changes"
            echo "  $0 -n ctrlplane                      # Deploy to 'ctrlplane' namespace"
            echo "  $0 -r my-ctrlplane -n my-namespace   # Custom release name and namespace"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Run main function
main
